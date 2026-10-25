from unittest.mock import patch, MagicMock

import pytest

from serial_upload.lister import SerialPortInfo, SerialPortLister


class MockPort:
    """Mock for serial.tools.list_ports.common.PortInfo."""

    def __init__(self, device: str, description: str = "CP2102 USB to UART", hwid: str = "USB-VCP-001"):
        self.device = device
        self.description = description
        self.hwid = hwid


class TestSerialPortInfo:
    """Tests for the SerialPortInfo data class."""

    def test_basic_creation(self):
        port = SerialPortInfo("/dev/ttyUSB0", "CP2102 USB to UART", "USB-VCP-001")
        assert port.device == "/dev/ttyUSB0"
        assert port.description == "CP2102 USB to UART"
        assert port.hwid == "USB-VCP-001"

    def test_str_representation(self):
        port = SerialPortInfo("/dev/ttyUSB0", "CP2102 USB to UART", "USB-VCP-001")
        assert str(port) == "/dev/ttyUSB0 — CP2102 USB to UART"

    def test_repr_representation(self):
        port = SerialPortInfo("/dev/ttyUSB0", "CP2102 USB to UART", "USB-VCP-001")
        expected = "SerialPortInfo(device='/dev/ttyUSB0', description='CP2102 USB to UART', hwid='USB-VCP-001')"
        assert repr(port) == expected

    def test_defaults_for_none_fields(self):
        port = SerialPortInfo("/dev/ttyACM0", "N/A", "N/A")
        assert port.device == "/dev/ttyACM0"
        assert port.description == "N/A"
        assert port.hwid == "N/A"


class TestSerialPortLister:
    """Tests for the SerialPortLister class."""

    @pytest.fixture
    def lister(self):
        return SerialPortLister()

    @pytest.fixture
    def mock_ports(self):
        return [
            MockPort("/dev/ttyUSB0", "CP2102 USB to UART", "USB-VCP-001"),
            MockPort("/dev/ttyUSB1", "FT232R USB UART", "FTDIBUS-0000:00:1a.0"),
            MockPort("/dev/ttyACM0", "Arduino Mega USB Serial", "Arduino__Mega_2560_12345"),
            MockPort("/dev/ttyS0", "Serial USB Port", "PCI-VCP-000"),
        ]

    def test_refresh_populates_ports(self, lister, mock_ports):
        with patch("serial.tools.list_ports.comports", return_value=mock_ports):
            result = lister.refresh()

        assert len(lister.ports) == 4
        assert result is lister  # returns self for chaining

    def test_refresh_handles_none_description(self, lister):
        mock = [MockPort("/dev/ttyUSB0", description=None, hwid=None)]
        with patch("serial.tools.list_ports.comports", return_value=mock):
            lister.refresh()

        port = lister.ports[0]
        assert port.description == "N/A"
        assert port.hwid == "N/A"

    def test_refresh_handles_empty_list(self, lister):
        with patch("serial.tools.list_ports.comports", return_value=[]):
            lister.refresh()

        assert lister.ports == []

    def test_find_by_device_found(self, lister, mock_ports):
        with patch("serial.tools.list_ports.comports", return_value=mock_ports):
            lister.refresh()

        port = lister.find_by_device("/dev/ttyUSB1")
        assert port is not None
        assert port.device == "/dev/ttyUSB1"
        assert port.description == "FT232R USB UART"

    def test_find_by_device_not_found(self, lister, mock_ports):
        with patch("serial.tools.list_ports.comports", return_value=mock_ports):
            lister.refresh()

        port = lister.find_by_device("/dev/ttyUSB99")
        assert port is None

    def test_find_by_keyword_in_description(self, lister, mock_ports):
        with patch("serial.tools.list_ports.comports", return_value=mock_ports):
            lister.refresh()

        results = lister.find_by_keyword("CP2102")
        assert len(results) == 1
        assert results[0].device == "/dev/ttyUSB0"

    def test_find_by_keyword_in_hwid(self, lister, mock_ports):
        with patch("serial.tools.list_ports.comports", return_value=mock_ports):
            lister.refresh()

        results = lister.find_by_keyword("FTDIBUS")
        assert len(results) == 1
        assert results[0].device == "/dev/ttyUSB1"

    def test_find_by_keyword_case_insensitive(self, lister, mock_ports):
        with patch("serial.tools.list_ports.comports", return_value=mock_ports):
            lister.refresh()

        results = lister.find_by_keyword("cp2102")
        assert len(results) == 1
        assert results[0].device == "/dev/ttyUSB0"

    def test_find_by_keyword_no_match(self, lister, mock_ports):
        with patch("serial.tools.list_ports.comports", return_value=mock_ports):
            lister.refresh()

        results = lister.find_by_keyword("nonexistent")
        assert results == []

    def test_find_by_keyword_matches_multiple(self, lister, mock_ports):
        with patch("serial.tools.list_ports.comports", return_value=mock_ports):
            lister.refresh()

        results = lister.find_by_keyword("usb")
        assert len(results) == 4

    def test_print_ports_no_ports(self, lister, capsys):
        with patch("serial.tools.list_ports.comports", return_value=[]):
            lister.refresh()

        lister.print_ports()
        captured = capsys.readouterr()
        assert "No serial ports found." in captured.out

    def test_print_ports_with_ports(self, lister, capsys, mock_ports):
        with patch("serial.tools.list_ports.comports", return_value=mock_ports):
            lister.refresh()

        lister.print_ports()
        captured = capsys.readouterr()
        assert "Found 4 port(s):" in captured.out
        assert "/dev/ttyUSB0" in captured.out
        assert "/dev/ttyUSB1" in captured.out
        assert "/dev/ttyACM0" in captured.out
        assert "/dev/ttyS0" in captured.out
        assert "CP2102 USB to UART" in captured.out

    def test_ports_property_returns_list(self, lister, mock_ports):
        with patch("serial.tools.list_ports.comports", return_value=mock_ports):
            lister.refresh()

        ports = lister.ports
        assert isinstance(ports, list)
        assert all(isinstance(p, SerialPortInfo) for p in ports)

    def test_refresh_chain(self, lister, mock_ports):
        with patch("serial.tools.list_ports.comports", return_value=mock_ports):
            result = lister.refresh()

        assert result is lister

    def test_multiple_refreshes(self, lister, mock_ports):
        with patch("serial.tools.list_ports.comports", return_value=mock_ports):
            lister.refresh()
            lister.refresh()

        assert len(lister.ports) == 4

    def test_find_by_device_before_refresh(self, lister):
        port = lister.find_by_device("/dev/ttyUSB0")
        assert port is None

    def test_find_by_keyword_before_refresh(self, lister):
        results = lister.find_by_keyword("test")
        assert results == []
