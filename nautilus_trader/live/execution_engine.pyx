# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2021 Nautech Systems Pty Ltd. All rights reserved.
#  https://nautechsystems.io
#
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------

import asyncio
from asyncio import AbstractEventLoop
from asyncio import CancelledError

from cpython.datetime cimport datetime
from cpython.datetime cimport timedelta

from nautilus_trader.common.clock cimport LiveClock
from nautilus_trader.common.logging cimport LogColor
from nautilus_trader.common.logging cimport Logger
from nautilus_trader.common.queue cimport Queue
from nautilus_trader.core.correctness cimport Condition
from nautilus_trader.core.message cimport Message
from nautilus_trader.core.message cimport MessageType
from nautilus_trader.execution.database cimport ExecutionDatabase
from nautilus_trader.execution.engine cimport ExecutionEngine
from nautilus_trader.execution.reports cimport ExecutionStateReport
from nautilus_trader.live.execution_client cimport LiveExecutionClient
from nautilus_trader.model.c_enums.order_state cimport OrderState
from nautilus_trader.model.commands cimport TradingCommand
from nautilus_trader.model.events cimport Event
from nautilus_trader.model.identifiers cimport Venue
from nautilus_trader.model.order.base cimport Order
from nautilus_trader.trading.portfolio cimport Portfolio


cdef class LiveExecutionEngine(ExecutionEngine):
    """
    Provides a high-performance asynchronous live execution engine.
    """

    def __init__(
        self,
        loop not None: AbstractEventLoop,
        ExecutionDatabase database not None,
        Portfolio portfolio not None,
        LiveClock clock not None,
        Logger logger not None,
        dict config=None,
    ):
        """
        Initialize a new instance of the `LiveExecutionEngine` class.

        Parameters
        ----------
        loop : asyncio.AbstractEventLoop
            The event loop for the engine.
        database : ExecutionDatabase
            The execution database for the engine.
        portfolio : Portfolio
            The portfolio for the engine.
        clock : Clock
            The clock for the engine.
        logger : Logger
            The logger for the engine.
        config : dict[str, object], optional
            The configuration options.

        """
        if config is None:
            config = {}
        super().__init__(
            database,
            portfolio,
            clock,
            logger,
            config,
        )

        self._loop = loop
        self._queue = Queue(maxsize=config.get("qsize", 10000))

        self._run_queue_task = None
        self.is_running = False

    cpdef object get_event_loop(self):
        """
        Return the internal event loop for the engine.

        Returns
        -------
        asyncio.AbstractEventLoop

        """
        return self._loop

    cpdef object get_run_queue_task(self):
        """
        Return the internal run queue task for the engine.

        Returns
        -------
        asyncio.Task

        """
        return self._run_queue_task

    cpdef int qsize(self) except *:
        """
        Return the number of messages buffered on the internal queue.

        Returns
        -------
        int

        """
        return self._queue.qsize()

    async def reconcile_state(self) -> bool:
        """
        Reconcile the execution engines state with all execution clients.

        The execution engine will collect all cached active orders and send
        those to the relevant execution client(s) for a comparison with the
        exchange(s) order states.

        If a cached order does not match the exchanges order status then
        the missing events will be generated. If there is not enough information
        to resolve a state then errors will be logged.

        Returns
        -------
        bool
            True if states resolve within timeout, else False.

        """
        self._log.info("Resolving states...")

        cdef list orders = self.cache.orders()
        cdef list open_orders = [order for order in orders if not order.is_completed_c()]

        # Initialize order state map
        cdef dict venue_orders = {}   # type: dict[Venue, list[Order]]
        cdef Venue venue
        for venue in self._clients.keys():
            venue_orders[venue] = []

        # Build order state map
        cdef Order order
        for order in open_orders:
            if order.security.venue in venue_orders:
                venue_orders[order.security.venue].append(order)
            else:
                self._log.error(f"Cannot resolve state. No registered"
                                f"execution client for active {order}.")
                continue

        cdef dict venue_reports = {}  # type: dict[Venue, ExecutionStateReport]

        cdef LiveExecutionClient client
        # Get state report from each client
        for venue, client in self._clients.items():
            venue_reports[venue] = await client.state_report(venue_orders[venue])

        cdef int seconds = 10  # Hard coded for now
        cdef datetime timeout = self._clock.utc_now() + timedelta(seconds=seconds)
        cdef OrderState target_state
        cdef bint resolved
        while True:
            if self._clock.utc_now() >= timeout:
                self._log.error(f"Timed out ({seconds}s) waiting for "
                                f"execution states to resolve.")
                return False

            resolved = True
            for order in open_orders:
                target_state = venue_reports[order.security.venue].order_states.get(order.id, 0)
                if order.state_c() != target_state:
                    resolved = False  # Incorrect state
                if target_state in (OrderState.FILLED, OrderState.PARTIALLY_FILLED):
                    filled_qty = venue_reports[order.security.venue].order_filled[order.id]
                    if order.filled_qty != filled_qty:
                        resolved = False  # Incorrect filled quantity
            if resolved:
                break
            await asyncio.sleep(0.001)  # One millisecond sleep

        self._log.info(f"State reconciled.", LogColor.GREEN)
        return True  # Execution states resolved

    cpdef void kill(self) except *:
        """
        Kill the engine by abruptly cancelling the queue task and calling stop.
        """
        self._log.warning("Killing engine...")
        if self._run_queue_task:
            self._log.debug("Cancelling run_queue_task...")
            self._run_queue_task.cancel()
        if self.is_running:
            self.is_running = False  # Avoids sentinel messages for queues
            self.stop()

    cpdef void execute(self, TradingCommand command) except *:
        """
        Execute the given command.

        If the internal queue is already full then will log a warning and block
        until queue size reduces.

        Parameters
        ----------
        command : TradingCommand
            The command to execute.

        Warnings
        --------
        This method should only be called from the same thread the event loop is
        running on.

        """
        Condition.not_none(command, "command")
        # Do not allow None through (None is a sentinel value which stops the queue)

        try:
            self._queue.put_nowait(command)
        except asyncio.QueueFull:
            self._log.warning(f"Blocking on `_queue.put` as queue full at {self._queue.qsize()} items.")
            self._queue.put(command)  # Block until qsize reduces below maxsize

    cpdef void process(self, Event event) except *:
        """
        Process the given event.

        If the internal queue is already full then will log a warning and block
        until queue size reduces.

        Parameters
        ----------
        event : Event
            The event to process.

        Warnings
        --------
        This method should only be called from the same thread the event loop is
        running on.

        """
        Condition.not_none(event, "event")
        # Do not allow None through (None is a sentinel value which stops the queue)

        try:
            self._queue.put_nowait(event)
        except asyncio.QueueFull:
            self._log.warning(f"Blocking on `_queue.put` as queue full at {self._queue.qsize()} items.")
            self._queue.put(event)  # Block until qsize reduces below maxsize

    cpdef void _on_start(self) except *:
        if not self._loop.is_running():
            self._log.warning("Started when loop is not running.")

        self.is_running = True  # Queue will continue to process
        self._run_queue_task = self._loop.create_task(self._run())

        self._log.debug(f"Scheduled {self._run_queue_task}")

    cpdef void _on_stop(self) except *:
        if self.is_running:
            self.is_running = False
            self._queue.put_nowait(None)  # Sentinel message pattern
            self._log.debug(f"Sentinel message placed on message queue.")

    async def _run(self):
        self._log.debug(f"Message queue processing starting (qsize={self.qsize()})...")
        cdef Message message
        try:
            while self.is_running:
                message = await self._queue.get()
                if message is None:  # Sentinel message (fast C-level check)
                    continue         # Returns to the top to check `self.is_running`
                if message.type == MessageType.EVENT:
                    self._handle_event(message)
                elif message.type == MessageType.COMMAND:
                    self._execute_command(message)
                else:
                    self._log.error(f"Cannot handle message: unrecognized {message}.")
        except CancelledError:
            if self.qsize() > 0:
                self._log.warning(f"Running cancelled "
                                  f"with {self.qsize()} message(s) on queue.")
            else:
                self._log.debug(f"Message queue processing stopped (qsize={self.qsize()}).")
