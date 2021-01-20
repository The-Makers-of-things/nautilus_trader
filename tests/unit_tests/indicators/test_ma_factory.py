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

import unittest

from nautilus_trader.indicators.average.ema import ExponentialMovingAverage
from nautilus_trader.indicators.average.hma import HullMovingAverage
from nautilus_trader.indicators.average.ma_factory import MovingAverageFactory
from nautilus_trader.indicators.average.moving_average import MovingAverageType
from nautilus_trader.indicators.average.sma import SimpleMovingAverage
from nautilus_trader.indicators.average.wma import WeightedMovingAverage
from tests.test_kit.providers import TestInstrumentProvider
from tests.test_kit.stubs import TestStubs


AUDUSD_SIM = TestInstrumentProvider.default_fx_ccy(TestStubs.symbol_audusd())


class MovingAverageConvergenceDivergenceTests(unittest.TestCase):

    def test_simple_returns_expected_indicator(self):
        # Arrange
        # Act
        indicator = MovingAverageFactory.create(10, MovingAverageType.SIMPLE)

        # Assert
        self.assertTrue(isinstance(indicator, SimpleMovingAverage))

    def test_exponential_returns_expected_indicator(self):
        # Arrange
        # Act
        indicator = MovingAverageFactory.create(10, MovingAverageType.EXPONENTIAL)

        # Assert
        self.assertTrue(isinstance(indicator, ExponentialMovingAverage))

    def test_hull_returns_expected_indicator(self):
        # Arrange
        # Act
        indicator = MovingAverageFactory.create(10, MovingAverageType.HULL)

        # Assert
        self.assertTrue(isinstance(indicator, HullMovingAverage))

    def test_weighted_returns_expected_indicator(self):
        # Arrange
        # Act
        indicator = MovingAverageFactory.create(10, MovingAverageType.WEIGHTED)

        # Assert
        self.assertTrue(isinstance(indicator, WeightedMovingAverage))
