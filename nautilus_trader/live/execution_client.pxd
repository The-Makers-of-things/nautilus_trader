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

from decimal import Decimal

from cpython.datetime cimport datetime

from nautilus_trader.execution.client cimport ExecutionClient
from nautilus_trader.live.providers cimport InstrumentProvider
from nautilus_trader.model.c_enums.liquidity_side cimport LiquiditySide
from nautilus_trader.model.c_enums.order_side cimport OrderSide
from nautilus_trader.model.identifiers cimport ClientOrderId
from nautilus_trader.model.identifiers cimport ExecutionId
from nautilus_trader.model.identifiers cimport OrderId
from nautilus_trader.model.identifiers cimport Security


cdef class LiveExecutionClient(ExecutionClient):
    cdef object _loop

    cdef InstrumentProvider _instrument_provider
    cdef dict _account_last_free
    cdef dict _account_last_used
    cdef dict _account_last_total

    cdef void _on_reset(self) except *
    cdef inline void _generate_order_invalid(self, ClientOrderId cl_ord_id, str reason) except *
    cdef inline void _generate_order_submitted(self, ClientOrderId cl_ord_id, datetime timestamp) except *
    cdef inline void _generate_order_rejected(self, ClientOrderId cl_ord_id, str reason, datetime timestamp) except *
    cdef inline void _generate_order_accepted(self, ClientOrderId cl_ord_id, OrderId order_id, datetime timestamp) except *
    cdef inline void _generate_order_filled(
        self,
        ClientOrderId cl_ord_id,
        OrderId order_id,
        ExecutionId execution_id,
        Security security,
        OrderSide order_side,
        fill_qty: Decimal,
        cum_qty: Decimal,
        leaves_qty: Decimal,
        avg_px: Decimal,
        commission_amount: Decimal,
        str commission_currency,
        LiquiditySide liquidity_side,
        datetime timestamp
    ) except *
    cdef inline void _generate_order_cancelled(self, ClientOrderId cl_ord_id, OrderId order_id, datetime timestamp) except *
    cdef inline void _generate_order_expired(self, ClientOrderId cl_ord_id, OrderId order_id, datetime timestamp) except *
