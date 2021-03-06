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

from datetime import datetime
from datetime import timedelta

import pandas as pd
import pytest
import pytz

from nautilus_trader.core.datetime import as_utc_index
from nautilus_trader.core.datetime import as_utc_timestamp
from nautilus_trader.core.datetime import format_iso8601
from nautilus_trader.core.datetime import from_unix_time_ms
from nautilus_trader.core.datetime import is_datetime_utc
from nautilus_trader.core.datetime import is_tz_aware
from nautilus_trader.core.datetime import is_tz_naive
from nautilus_trader.core.datetime import to_unix_time_ms
from tests.test_kit.stubs import UNIX_EPOCH


class TestDatetimeFunctions:

    @pytest.mark.parametrize(
        "value, expected",
        [[datetime(1969, 12, 1, 1, 0, tzinfo=pytz.utc), -2674800000],
         [datetime(1970, 1, 1, 0, 0, tzinfo=pytz.utc), 0],
         [datetime(2013, 1, 1, 1, 0, tzinfo=pytz.utc), 1357002000000],
         [datetime(2020, 1, 2, 3, 2, microsecond=1000, tzinfo=pytz.utc), 1577934120001]],
    )
    def test_to_posix_ms_with_various_values_returns_expected_long(self, value, expected):
        # Arrange
        # Act
        posix = to_unix_time_ms(value)

        # Assert
        assert expected == posix

    @pytest.mark.parametrize(
        "value, expected",
        [[-2674800000, datetime(1969, 12, 1, 1, 0, tzinfo=pytz.utc)],
         [0, datetime(1970, 1, 1, 0, 0, tzinfo=pytz.utc)],
         [1357002000000, datetime(2013, 1, 1, 1, 0, tzinfo=pytz.utc)],
         [1577934120001, datetime(2020, 1, 2, 3, 2, 0, 1000, tzinfo=pytz.utc)]],
    )
    def test_from_posix_ms_with_various_values_returns_expected_datetime(self, value, expected):
        # Arrange
        # Act
        dt = from_unix_time_ms(value)

        # Assert
        assert expected == dt

    def test_is_datetime_utc_given_tz_naive_datetime_returns_false(self):
        # Arrange
        dt = datetime(2013, 1, 1, 1, 0)

        # Act
        # Assert
        assert is_datetime_utc(dt) is False

    def test_is_datetime_utc_given_utc_datetime_returns_true(self):
        # Arrange
        dt = datetime(2013, 1, 1, 1, 0, tzinfo=pytz.utc)

        # Act
        # Assert
        assert is_datetime_utc(dt) is True

    def test_is_tz_awareness_given_unrecognized_type_raises_exception(self):
        # Arrange
        # Act
        # Assert
        with pytest.raises(ValueError):
            is_tz_aware("hello")

    def test_is_tz_awareness_with_various_aware_objects_returns_true(self):
        # Arrange
        time_object1 = UNIX_EPOCH
        time_object2 = pd.Timestamp(UNIX_EPOCH)

        time_object3 = pd.DataFrame({"timestamp": ["2019-05-21T12:00:00+00:00",
                                                   "2019-05-21T12:15:00+00:00"]})
        time_object3.set_index("timestamp")
        time_object3.index = pd.to_datetime(time_object3.index)

        # Act
        # Assert
        assert is_tz_aware(time_object1) is True
        assert is_tz_aware(time_object2) is True
        assert is_tz_aware(time_object3) is True
        assert is_tz_naive(time_object1) is False
        assert is_tz_naive(time_object2) is False
        assert is_tz_naive(time_object3) is False

    def test_is_tz_awareness_with_various_objects_returns_false(self):
        # Arrange
        time_object1 = datetime(1970, 1, 1, 0, 0, 0, 0)
        time_object2 = pd.Timestamp(datetime(1970, 1, 1, 0, 0, 0, 0))

        # Act
        # Assert
        assert is_tz_aware(time_object1) is False
        assert is_tz_aware(time_object2) is False
        assert is_tz_naive(time_object1) is True
        assert is_tz_naive(time_object2) is True

    def test_format_iso8601(self):
        # Arrange
        dt1 = UNIX_EPOCH
        dt2 = UNIX_EPOCH + timedelta(microseconds=1)
        dt3 = UNIX_EPOCH + timedelta(milliseconds=1)
        dt4 = UNIX_EPOCH + timedelta(seconds=1)
        dt5 = UNIX_EPOCH + timedelta(hours=1, minutes=1, seconds=2, milliseconds=3)

        # Act
        result1 = format_iso8601(dt1)
        result2 = format_iso8601(dt2)
        result3 = format_iso8601(dt3)
        result4 = format_iso8601(dt4)
        result5 = format_iso8601(dt5)

        # Assert
        assert "1970-01-01 00:00:00+00:00" == str(pd.to_datetime(dt1, utc=True))
        assert "1970-01-01T00:00:00.000Z" == result1
        assert "1970-01-01T00:00:00.000Z" == result2
        assert "1970-01-01T00:00:00.001Z" == result3
        assert "1970-01-01T00:00:01.000Z" == result4
        assert "1970-01-01T01:01:02.003Z" == result5

    def test_datetime_and_pd_timestamp_equality(self):
        # Arrange
        timestamp1 = datetime(1970, 1, 1, 0, 0, 0, 0)
        timestamp2 = pd.Timestamp(1970, 1, 1, 0, 0, 0, 0)
        min1 = timedelta(minutes=1)

        # Act
        timestamp3 = timestamp1 + min1
        timestamp4 = timestamp2 + min1
        timestamp5 = UNIX_EPOCH
        timestamp6 = timestamp2.tz_localize("UTC")

        # Assert
        assert timestamp1 == timestamp2
        assert timestamp3 == timestamp4
        assert timestamp1.tzinfo == timestamp2.tzinfo
        assert timestamp2.tz is None
        assert timestamp5 == timestamp6

    def test_as_utc_timestamp_given_tz_naive_datetime(self):
        # Arrange
        timestamp = datetime(2013, 2, 1, 0, 0, 0, 0)

        # Act
        result = as_utc_timestamp(timestamp)

        # Assert
        assert pd.Timestamp("2013-02-01 00:00:00+00:00") == result
        assert pytz.utc == result.tz

    def test_as_utc_timestamp_given_tz_naive_pandas_timestamp(self):
        # Arrange
        timestamp = pd.Timestamp(2013, 2, 1, 0, 0, 0, 0)

        # Act
        result = as_utc_timestamp(timestamp)

        # Assert
        assert pd.Timestamp("2013-02-01 00:00:00+00:00") == result
        assert pytz.utc == result.tz

    def test_as_utc_timestamp_given_tz_aware_datetime(self):
        # Arrange
        timestamp = datetime(2013, 2, 1, 0, 0, 0, 0, tzinfo=pytz.utc)

        # Act
        result = as_utc_timestamp(timestamp)

        # Assert
        assert pd.Timestamp("2013-02-01 00:00:00+00:00") == result
        assert pytz.utc == result.tz

    def test_as_utc_timestamp_given_tz_aware_pandas(self):
        # Arrange
        timestamp = pd.Timestamp(2013, 2, 1, 0, 0, 0, 0).tz_localize("UTC")

        # Act
        result = as_utc_timestamp(timestamp)

        # Assert
        assert pd.Timestamp("2013-02-01 00:00:00+00:00") == result
        assert pytz.utc == result.tz

    def test_as_utc_timestamp_equality(self):
        # Arrange
        timestamp1 = datetime(1970, 1, 1, 0, 0, 0, 0)
        timestamp2 = UNIX_EPOCH
        timestamp3 = pd.Timestamp(1970, 1, 1, 0, 0, 0, 0)
        timestamp4 = pd.Timestamp(1970, 1, 1, 0, 0, 0, 0).tz_localize("UTC")

        # Act
        timestamp1_converted = as_utc_timestamp(timestamp1)
        timestamp2_converted = as_utc_timestamp(timestamp2)
        timestamp3_converted = as_utc_timestamp(timestamp3)
        timestamp4_converted = as_utc_timestamp(timestamp4)

        # Assert
        assert timestamp1_converted == timestamp2_converted
        assert timestamp2_converted == timestamp3_converted
        assert timestamp3_converted == timestamp4_converted

    def test_as_utc_index_given_empty_dataframe_returns_empty_dataframe(self):
        # Arrange
        data = pd.DataFrame()

        # Act
        result = as_utc_index(data)

        # Assert
        assert result.empty

    def test_with_utc_index_given_tz_unaware_dataframe(self):
        # Arrange
        data = pd.DataFrame({"timestamp": ["2019-05-21T12:00:00+00:00",
                                           "2019-05-21T12:15:00+00:00"]})
        data.set_index("timestamp")
        data.index = pd.to_datetime(data.index)

        # Act
        result = as_utc_index(data)

        # Assert
        assert pytz.utc == result.index.tz

    def test_with_utc_index_given_tz_aware_dataframe(self):
        # Arrange
        data = pd.DataFrame({"timestamp": ["2019-05-21T12:00:00+00:00",
                                           "2019-05-21T12:15:00+00:00"]})
        data.set_index("timestamp")
        data.index = pd.to_datetime(data.index, utc=True)

        # Act
        result = as_utc_index(data)

        # Assert
        assert pytz.utc == result.index.tz

    def test_with_utc_index_given_tz_aware_different_timezone_dataframe(self):
        # Arrange
        data1 = pd.DataFrame({"timestamp": ["2019-05-21 12:00:00",
                                            "2019-05-21 12:15:00"]})
        data1.set_index("timestamp")
        data1.index = pd.to_datetime(data1.index)

        data2 = pd.DataFrame({"timestamp": [datetime(1970, 1, 1, 0, 0, 0, 0),
                                            datetime(1970, 1, 1, 0, 0, 0, 0)]})
        data2.set_index("timestamp")
        data2.index = pd.to_datetime(data2.index, utc=True)

        # Act
        result1 = as_utc_index(data1)
        result2 = as_utc_index(data2)

        # Assert
        assert result1.index[0] == result2.index[0]
        assert result1.index.tz == result2.index.tz
