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

from cpython.datetime cimport datetime

from nautilus_trader.core.uuid cimport UUID
from nautilus_trader.data.base cimport DataType


cdef class DataCommand(Command):
    """
    The abstract base class for all data commands.

    This class should not be used directly, but through its concrete subclasses.
    """

    def __init__(
        self,
        str provider not None,
        DataType data_type not None,
        handler not None: callable,
        UUID command_id not None,
        datetime command_timestamp not None,
    ):
        """

        Parameters
        ----------
        provider : str
            The data client name for the command.
        data_type : type
            The data type for the command.
        handler : callable
            The handler for the command.
        command_id : UUID
            The command identifier.
        command_timestamp : datetime
            The command timestamp.

        """
        super().__init__(command_id, command_timestamp)

        self.provider = provider
        self.data_type = data_type
        self.handler = handler

    def __str__(self) -> str:
        return f"{type(self).__name__}({self.data_type})"

    def __repr__(self) -> str:
        return (f"{type(self).__name__}("
                f"provider={self.provider}, "
                f"data_type={self.data_type}, "
                f"handler={self.handler}, "
                f"id={self.id}, "
                f"timestamp={self.timestamp})")


cdef class Subscribe(DataCommand):
    """
    Represents a command to subscribe to data.
    """

    def __init__(
        self,
        str provider not None,
        DataType data_type not None,
        handler not None: callable,
        UUID command_id not None,
        datetime command_timestamp not None,
    ):
        """
        Initialize a new instance of the `Subscribe` class.

        Parameters
        ----------
        provider : str
            The data client name for the command.
        data_type : type
            The data type for the subscription.
        handler : callable
            The handler for the subscription.
        command_id : UUID
            The command identifier.
        command_timestamp : datetime
            The command timestamp.

        """
        super().__init__(
            provider,
            data_type,
            handler,
            command_id,
            command_timestamp,
        )


cdef class Unsubscribe(DataCommand):
    """
    Represents a command to unsubscribe from data.
    """

    def __init__(
        self,
        str provider not None,
        DataType data_type not None,
        handler not None: callable,
        UUID command_id not None,
        datetime command_timestamp not None,
    ):
        """
        Initialize a new instance of the `Unsubscribe` class.

        Parameters
        ----------
        provider : str
            The data client name for the command.
        data_type : type
            The data type to unsubscribe from.
        handler : callable
            The handler for the subscription.
        command_id : UUID
            The command identifier.
        command_timestamp : datetime
            The command timestamp.

        """
        super().__init__(
            provider,
            data_type,
            handler,
            command_id,
            command_timestamp,
        )


cdef class DataRequest(Request):
    """
    Represents a request for data.
    """

    def __init__(
        self,
        str provider not None,
        DataType data_type not None,
        callback not None: callable,
        UUID request_id not None,
        datetime request_timestamp not None,
    ):
        """
        Initialize a new instance of the `DataRequest` class.

        Parameters
        ----------
        provider : str
            The data client name for the request.
        data_type : type
            The data type for the request.
        callback : callable
            The callback to receive the data.
        request_id : UUID
            The request identifier.
        request_timestamp : datetime
            The request timestamp.

        """
        super().__init__(
            request_id,
            request_timestamp,
        )

        self.provider = provider
        self.data_type = data_type
        self.callback = callback

    def __str__(self) -> str:
        return f"{type(self).__name__}({self.data_type})"

    def __repr__(self) -> str:
        return (f"{type(self).__name__}("
                f"provider={self.provider}, "
                f"data_type={self.data_type}, "
                f"callback={self.callback}, "
                f"id={self.id}, "
                f"timestamp={self.timestamp})")


cdef class DataResponse(Response):
    """
    Represents a response with data.
    """

    def __init__(
        self,
        str provider not None,
        DataType data_type not None,
        data not None,
        UUID correlation_id not None,
        UUID response_id not None,
        datetime response_timestamp not None,
    ):
        """
        Initialize a new instance of the `DataResponse` class.

        Parameters
        ----------
        provider : str
            The data provider name of the response.
        data_type : type
            The data type of the response.
        data : object
            The data of the response.
        correlation_id : UUID
            The correlation identifier.
        response_id : UUID
            The response identifier.
        response_timestamp : datetime
            The response timestamp.

        """
        super().__init__(
            correlation_id,
            response_id,
            response_timestamp,
        )

        self.provider = provider
        self.data_type = data_type
        self.data = data

    def __str__(self) -> str:
        return f"{type(self).__name__}({self.data_type})"

    def __repr__(self) -> str:
        return (f"{type(self).__name__}("
                f"provider={self.provider}, "
                f"data_type={self.data_type}, "
                f"correlation_id={self.correlation_id}, "
                f"id={self.id}, "
                f"timestamp={self.timestamp})")
