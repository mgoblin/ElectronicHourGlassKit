# Electronic hourglass kit programming examples  

This repository contains programming examples for electronic hourglass kit.

Examples written on C language and compiled with [SDCC](https://sdcc.sourceforge.net/)

> [!CAUTION]
> There is no way to download and save original firmware of the microcontroller.After first firmware upload orignal firmware was removed. 


## What is electronic hourglass kit
Electronic houglass kit is 57 LEDs driven by STC15W204S (or STC15W201S)

[Electronic houglass kit](https://www.icstation.com/hourglass-shaped-flashing-light-kits-simple-lamp-electronics-soldering-practice-stem-teaching-kits-p-12309.html)

![Electronic houglass kit image](http://www.icstation.com/images/uploads/12309_1.jpg)

## Additional hardware
To upload firmware you need USB-2-TTL adapter. I use CHG340g.

![CHG340g](https://github.com/mgoblin/STC-programmator/blob/main/images/ch340g.jpeg)

STC programmator is optional, but recommended for use.
[Additional info ](https://github.com/mgoblin/STC-programmator)    

# Fast track

All examples are prebuilded in firmware folder. You need stage8.hex or stage9.hex in your choice.

To upload firmare follow this steps
1. Install [stcgal](https://github.com/grigorig/stcgal)
2. Dont turn on power via other connectors. Connect USB-2-TTL adapter to hourglass kit board and plug it into USB. USB-2-TTL Rx to hourglass kit board Tx, USB-2-TTL Tx to hourglass kit board Rx, 5V to 5V. If you not use programmator do not connect board GND pin to USB-2-TTL in this step. 
4. Clone this code repository and open terminal in the cloned repository root directory
5. Run command 
```bash
    stcgal firmware/stage9.hex
```
6. Waiting for stcgal output 
``` Waiting for MCU, please cycle power: ``` and connect USB-2-TTL adapter GND to hourglass kit board GND. Waiting for stcgal output 
``` Disconnected! ```
7. Disconnect USB-2-TTL adapter and turn on power. As alternative way you can connect to hourglass kit board only GND and VCC pins of USB-2-TTL adapter.
8. Enjoy :)  

# Deep dive
Build tested in by me on Debian 12. You can build source code using Platformio IDE (recommended way) or from command line.

## Build examples prerequisites

This examples was developed in [Platformio IDE](https://platformio.org/) using C programming language.

You can build source code using Platformio IDE (recommended way) or from command line.

### Platformio (mandatory)
Follow instructions from [Platformio IDE](https://platformio.org/).
Run Platformio IDE and install 'c' and 'Native' platforms.

### SDCC compiler (optional)
SDCC is a C-compiler for small devices including STC microchips.
Its installed with Platformio Intel MCS-51 (8051) platform.
But you can install it separately for using in the command line.
On Debian SDCC can be installed via apt. 

Install need superuser permissions.
```bash
apt-get install sdcc
```

### gcc compiler (optional)
GCC used for run tests. I wonder why you dont install gcc yet. 

### Scons (optional)
[SCons](https://scons.org/) is build tool used inside Platfromio. 
SCons based on Python

But you can install it separately for using in the command line.

```bash
pipx install scons
```


### stcgal (optional)
Stcgal is a firmware upload tool. Its installed inside and used by Platfromio.
Stcgal is written on Python and can be install separately from Platfromio. 

```bash
pipx install stcgal
```

## How to build examples

There are three ways to build the code.

### Build from Platformio IDE
Simpliest way to build firmware is to use Platformio IDE.

Run Platformio IDE.

![Build firmware](images/Build_from_IDE.png)

You can also run local library tests.

![Run tests](images/Run_tests.png)


### Build from command line using Platfromio core

To build firmware from root directory run in terminal 

```bash
pio run -e STC15W204S
```

For tests run 
```bash
pio test -e Native
```

### Build from command line using only SCons
To build firmware from root directory run in terminal
```bash
scons
```

Tests run doesnt supported yet.

## Upload firmware

### Upload from Platformio IDE

1. Connect USB-2-TTL adapter to hourglass kit board except GND
2. Select upload menu item from Platformio STC15W204S environment.
![Upload](images/Firmware_upload.png) and waiting for ```Cycling power: done``` output
3. Connect USB-2-TTL adapter GND pin to hourglass kit board except GND pin. 

### Upload from command line using Platfromio core

1. Connect USB-2-TTL adapter to hourglass kit board except GND
2. In the terminal from root folder run command
```bash
pio run -t upload -e STC15W204S
```
and waiting for ```Cycling power: done``` output

3. Connect USB-2-TTL adapter GND pin to hourglass kit board except GND pin.

### Upload from command line

Before upload firmware should be builded.

1. Connect USB-2-TTL adapter to hourglass kit board except GND
2. In the terminal from root folder run command
```bash
stcgal <file>
```
where file file is name of firmware hex file.

3. Waiting for ```Cycling power: done``` output
4. Connect USB-2-TTL adapter GND pin to hourglass kit board except GND pin.

# Electrical schema

The hourglass board has 57 LEDs, any combination of which the microcontroller can light, using just 12 I/O pins: the whole chip only has sixteen pins, and some of those are used for power, and sensing the push button.

Take a look at the circuit diagram

![Schema](images/Electrical_schema.jpg)

LEDs are grouped into 12 lines. Each line excepth the last have 5 LEDs that drives by P3 and P1 pins.


# LED driving algorithms

## Stage 1

## Stage 2

## Stage 3

## Stage 4

## Stage 5

## Stage 6

## Stage 7

## Stage 8

## Stage 9

# Next ideas

