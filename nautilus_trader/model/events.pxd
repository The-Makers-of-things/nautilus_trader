# -------------------------------------------------------------------------------------------------
# <copyright file="events.pxd" company="Nautech Systems Pty Ltd">
#  Copyright (C) 2015-2019 Nautech Systems Pty Ltd. All rights reserved.
#  The use of this source code is governed by the license as found in the LICENSE.md file.
#  https://nautechsystems.io
# </copyright>
# -------------------------------------------------------------------------------------------------

from cpython.datetime cimport datetime

from nautilus_trader.core.types cimport ValidString
from nautilus_trader.core.message cimport Event
from nautilus_trader.model.c_enums.currency cimport Currency
from nautilus_trader.model.c_enums.order_side cimport OrderSide
from nautilus_trader.model.c_enums.order_type cimport OrderType
from nautilus_trader.model.c_enums.order_purpose cimport OrderPurpose
from nautilus_trader.model.c_enums.time_in_force cimport TimeInForce
from nautilus_trader.model.objects cimport Quantity, Price, Money
from nautilus_trader.model.identifiers cimport (
    Symbol,
    Label,
    Brokerage,
    AccountNumber,
    AccountId,
    ExecutionId,
    ExecutionTicket,
    StrategyId,
    OrderId,
    OrderIdBroker
)
from nautilus_trader.model.position cimport Position


cdef class AccountStateEvent(Event):
    cdef readonly AccountId account_id
    cdef readonly Brokerage broker
    cdef readonly AccountNumber number
    cdef readonly Currency currency
    cdef readonly Money cash_balance
    cdef readonly Money cash_start_day
    cdef readonly Money cash_activity_day
    cdef readonly Money margin_used_liquidation
    cdef readonly Money margin_used_maintenance
    cdef readonly object margin_ratio
    cdef readonly ValidString margin_call_status


cdef class OrderEvent(Event):
    cdef readonly OrderId order_id


cdef class OrderFillEvent(OrderEvent):
    cdef readonly AccountId account_id
    cdef readonly ExecutionId execution_id
    cdef readonly ExecutionTicket execution_ticket
    cdef readonly Symbol symbol
    cdef readonly OrderSide order_side
    cdef readonly Quantity filled_quantity
    cdef readonly Price average_price
    cdef readonly datetime execution_time


cdef class OrderInitialized(OrderEvent):
    cdef readonly Symbol symbol
    cdef readonly Label label
    cdef readonly OrderSide order_side
    cdef readonly OrderType order_type
    cdef readonly Quantity quantity
    cdef readonly Price price
    cdef readonly OrderPurpose order_purpose
    cdef readonly TimeInForce time_in_force
    cdef readonly datetime expire_time


cdef class OrderSubmitted(OrderEvent):
    cdef readonly AccountId account_id
    cdef readonly datetime submitted_time


cdef class OrderRejected(OrderEvent):
    cdef readonly AccountId account_id
    cdef readonly datetime rejected_time
    cdef readonly ValidString rejected_reason


cdef class OrderAccepted(OrderEvent):
    cdef readonly AccountId account_id
    cdef readonly datetime accepted_time


cdef class OrderWorking(OrderEvent):
    cdef readonly OrderIdBroker order_id_broker
    cdef readonly AccountId account_id
    cdef readonly Symbol symbol
    cdef readonly Label label
    cdef readonly OrderSide order_side
    cdef readonly OrderType order_type
    cdef readonly Quantity quantity
    cdef readonly Price price
    cdef readonly TimeInForce time_in_force
    cdef readonly datetime working_time
    cdef readonly datetime expire_time


cdef class OrderCancelReject(OrderEvent):
    cdef readonly AccountId account_id
    cdef readonly datetime rejected_time
    cdef readonly ValidString rejected_response_to
    cdef readonly ValidString rejected_reason


cdef class OrderCancelled(OrderEvent):
    cdef readonly AccountId account_id
    cdef readonly datetime cancelled_time


cdef class OrderExpired(OrderEvent):
    cdef readonly AccountId account_id
    cdef readonly datetime expired_time


cdef class OrderModified(OrderEvent):
    cdef readonly AccountId account_id
    cdef readonly OrderIdBroker order_id_broker
    cdef readonly Price modified_price
    cdef readonly datetime modified_time


cdef class OrderFilled(OrderFillEvent):
    pass


cdef class OrderPartiallyFilled(OrderFillEvent):
    cdef readonly Quantity leaves_quantity


cdef class PositionEvent(Event):
    cdef readonly Position position
    cdef readonly StrategyId strategy_id
    cdef readonly OrderEvent order_fill


cdef class PositionOpened(PositionEvent):
    pass


cdef class PositionModified(PositionEvent):
    pass


cdef class PositionClosed(PositionEvent):
    pass


cdef class TimeEvent(Event):
    cdef readonly Label label
