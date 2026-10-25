import serial.tools.list_ports
from typing import List, Optional


class SerialPortInfo:
    """Represents a single serial port with its metadata."""

    def __init__(self, device: str, description: str, hwid: str):
        self.device = device
        self.description = description
        self.hwid = hwid

    def __str__(self) -> str:
        return f"{self.device} — {self.description}"

    def __repr__(self) -> str:
        return (
            f"SerialPortInfo(device={self.device!r}, "
            f"description={self.description!r}, hwid={self.hwid!r})"
        )


class SerialPortLister:
    """Lists and filters serial ports available on the system."""

    def __init__(self):
        self._ports: List[SerialPortInfo] = []

    def refresh(self) -> "SerialPortLister":
        """Re-scan the system for serial ports. Returns self for chaining."""
        self._ports = [
            SerialPortInfo(
                device=port.device,
                description=port.description or "N/A",
                hwid=port.hwid or "N/A",
            )
            for port in serial.tools.list_ports.comports()
        ]
        return self

    @property
    def ports(self) -> List[SerialPortInfo]:
        """Return the cached list of ports found during the last scan."""
        return self._ports

    def find_by_device(self, device: str) -> Optional[SerialPortInfo]:
        """Find a port by its system name (e.g. /dev/ttyUSB0 or COM3)."""
        for port in self._ports:
            if port.device == device:
                return port
        return None

    def find_by_keyword(self, keyword: str) -> List[SerialPortInfo]:
        """Find ports whose description or hwid contains the keyword (case-insensitive)."""
        keyword = keyword.lower()
        return [
            port
            for port in self._ports
            if keyword in port.description.lower() or keyword in port.hwid.lower()
        ]

    def print_ports(self) -> None:
        """Print all detected ports in a human-readable format."""
        if not self._ports:
            print("No serial ports found.")
            return

        print(f"Found {len(self._ports)} port(s):")
        print("-" * 60)
        for port in self._ports:
            print(f"Device:      {port.device}")
            print(f"Description: {port.description}")
            print(f"HWID:        {port.hwid}")
            print("-" * 60)