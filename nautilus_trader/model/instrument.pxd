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

from nautilus_trader.model.c_enums.liquidity_side cimport LiquiditySide
from nautilus_trader.model.c_enums.position_side cimport PositionSide
from nautilus_trader.model.currency cimport Currency
from nautilus_trader.model.identifiers cimport Security
from nautilus_trader.model.objects cimport Money
from nautilus_trader.model.objects cimport Price
from nautilus_trader.model.objects cimport Quantity


cdef class Instrument:
    cdef readonly Security security
    """The security identifier of the instrument.\n\n:returns: `Security`"""
    cdef readonly Currency base_currency
    """The base currency of the instrument.\n\n:returns: `Currency` or `None`"""
    cdef readonly Currency quote_currency
    """The quote currency of the instrument.\n\n:returns: `Currency`"""
    cdef readonly Currency settlement_currency
    """The settlement currency of the instrument.\n\n:returns: `Currency`"""
    cdef readonly bint is_inverse
    """If the quantity is expressed in quote currency.\n\n:returns: `Currency`"""
    cdef readonly bint is_quanto
    """If settlement currency different to base and quote.\n\n:returns: `Currency`"""
    cdef readonly int price_precision
    """The price precision of the instrument.\n\n:returns: `int`"""
    cdef readonly int size_precision
    """The size precision of the instrument.\n\n:returns: `int`"""
    cdef readonly int cost_precision
    """The cost precision of the instrument.\n\n:returns: `int`"""
    cdef readonly object tick_size
    """The tick size of the instrument.\n\n:returns: `Decimal`"""
    cdef readonly object multiplier
    """The multiplier of the instrument.\n\n:returns: `Decimal`"""
    cdef readonly object leverage
    """The leverage of the instrument.\n\n:returns: `Decimal`"""
    cdef readonly Quantity lot_size
    """The lot size of the instrument.\n\n:returns: `Quantity`"""
    cdef readonly Quantity max_quantity
    """The maximum order quantity for the instrument.\n\n:returns: `Quantity`"""
    cdef readonly Quantity min_quantity
    """The minimum order quantity for the instrument.\n\n:returns: `Quantity`"""
    cdef readonly Money max_notional
    """The maximum notional order value for the instrument.\n\n:returns: `Money`"""
    cdef readonly Money min_notional
    """The minimum notional order value for the instrument.\n\n:returns: `Money`"""
    cdef readonly Price max_price
    """The maximum printable price for the instrument.\n\n:returns: `Price`"""
    cdef readonly Price min_price
    """The minimum printable price for the instrument.\n\n:returns: `Price`"""
    cdef readonly object margin_init
    """The initial margin rate for the instrument.\n\n:returns: `Decimal`"""
    cdef readonly object margin_maint
    """The maintenance margin rate for the instrument.\n\n:returns: `Decimal`"""
    cdef readonly object maker_fee
    """The maker fee rate for the instrument.\n\n:returns: `Decimal`"""
    cdef readonly object taker_fee
    """The taker fee rate for the instrument.\n\n:returns: `Decimal`"""
    cdef readonly dict financing
    """The financing information for the instrument.\n\n:returns: `dict[str, object]`"""
    cdef readonly datetime timestamp
    """The initialization timestamp of the instrument.\n\n:returns: `datetime`"""
    cdef readonly dict info
    """The additional instrument information.\n\n:returns: `dict[str, object]`"""

    cdef bint _is_quanto(
        self,
        Currency base_currency,
        Currency quote_currency,
        Currency settlement_currency,
    ) except *

    cpdef Money market_value(self, Quantity quantity, close_price: Decimal)
    cpdef Money notional_value(self, Quantity quantity, close_price: Decimal)
    cpdef Money calculate_initial_margin(self, Quantity quantity, Price price)
    cpdef Money calculate_maint_margin(
        self,
        PositionSide side,
        Quantity quantity,
        Price last,
    )

    cpdef Money calculate_commission(
        self,
        Quantity quantity,
        avg_price: Decimal,
        LiquiditySide liquidity_side,
    )


# cdef class Future(Instrument):
#
#     cdef readonly int contract_id
#     cdef readonly str last_trade_date_or_contract_month
#     cdef readonly str local_symbol
#     cdef readonly str trading_class
#     cdef readonly str market_name
#     cdef readonly str long_name
#     cdef readonly str contract_month
#     cdef readonly str time_zone_id
#     cdef readonly str trading_hours
#     cdef readonly str liquid_hours
#     cdef readonly str last_trade_time
