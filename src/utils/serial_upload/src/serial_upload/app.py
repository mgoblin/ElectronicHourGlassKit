from serial_upload.lister import SerialPortLister


def main() -> None:
    lister = SerialPortLister().refresh()
    lister.print_ports()

if __name__ == "__main__":
    main()
