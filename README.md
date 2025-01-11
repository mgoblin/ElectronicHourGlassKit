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

LEDs are grouped into 12 lines. Line numeration started from 0.
Each line excepth the last have 5 LEDs. Last line with number 11 have 2 LEDs.
Inside the line LEDs grouped by columns. There are 5 columns with numbers 0..4.

LEDs are driven by P3 and P1 pins. P1[0..6] and P30, P31, P33, P36, P37 used.
P1 select line and P3 select column.

P32 is used to connect push button.

LEDs doesnt have current-limiting resistors. MCU have total maximum current ~90mA. One MCU pin have maximum current ~20mA. Pin current is enough to drive LED, but in one moment only one LED should be turn on. The LEDs are multiplexed.

Even lines 0, 2, 4...10 are direct and odd lines 1, 3, 5.. 11 are reverse. 

To turn on LED in direct line P1x pin should have LOW value (logical zero) and P3x should have HIGH value (logical 1).
To turn on LED in reverse line P1x pin should have HIGH value (logical 1) and P3.x pin should have LOW value (logical 0).

To control this kind of matrix, the I/O pins have to be 'tri-state' type.
The microcontroller must be able to power each pin high, power the same pin low, or put that same pin into a high impedance ‘input’ state, where it effectively blocks any significant current from flowing in or out of it.

The STC15 chips achieve the tri-state operation (and more) for their I/O pins, by having PxM0 and PxM1 special function registers. That registers allow to control pins 
mode. There are four modes

| P1M1[0..7] | P1M0[0..7] | Mode                         |
|------------|------------|------------------------------|
|  0         |  0         |  quasi bidirectional         |
|  0         |  1         |  push-pull                   |
|  1         |  0         |  input-only (high-impedance )|
|  1         |  1         |  open Drain                  |

| P1M3[0..7] | P3M0[0..7] | Mode                         |
|------------|------------|------------------------------|
|  0         |  0         |  quasi bidirectional         |
|  0         |  1         |  push-pull                   |
|  1         |  0         |  input-only (high-impedance )|
|  1         |  1         |  open Drain                  |

We need push pull mode to turn LED on/off and input only otherwise.

For example for L1: line 0 driven by P10 and column 0 driven by P30. 
Line 0 is direct. L1 driven by P10 and P30.

Set the following values:

* P1M1 bit 0 to 0
* P1M0 bit 0 to 1
* P10 to 0
* P3M1 bit 0 to 0
* P3M0 bit 0 to 1
* P30 to 1 

Other bits of P1M1 = 1, P1M0 = 0

For L8: line is 1 and column 2. Line 1 is reverse. L8 driven by P11 and P33.
Set the following values:

* P1M1 bit 1 to 0
* P1M1 bit 0 to 1
* P11 to 1
* P3M1 bit 3 to 0
* P3M0 bit 3 to 1
* P33 to 0

# LED driving algorithms

C or assembler can be used to programming STC MCU. This examples is written on C programming language.

There are two popular C language compilers for 8051 MCU architecture: Keil and SDCC.
Keil is commertial, SDCC is free opensource compiler. Both have custom extensions. Keil C-language extentions doesnt compatible with SDCC, but may be easy translated.

This examples developed with STC15204S and STC15W201S compatibility in mind. 
Therefore maximum firmware size is less 1024 bytes. 

Examples split to stages. Stages demonstrate the growth of functionalty from simple to more complex levels. 

Stages source code is placed in stages subfolders.

## Stage 0. Install/configure sources and tools

Install and configure tools and build firmware from empty C language program. 

## Stage 1. Turn single LED on. 

***Step 1. Add STC hardware library.***  
Platfromio maintains centralized library registry. 

To programming STC MCU add STC15 hardware library. This library includes MCU registers definition and covinient routines to manipulate with MCU resources (frequency, timers and so on). 

Add to platfrom.io file lines
```ini
lib_deps = https://github.com/mgoblin/STC15lib.git#0.9.0
```

***Step 2. Create local library 'leds1' to turn led on/off*** 
A library is a way to manage complexity and separation of concerns.
Local libraries in platformio are located in the libs folder.

As an example of good firmware structure LEDs manipulation lib was created. Main method use library.

Leds1 library declares in leds1.h to functions:
 - ```void leds_off()``` to turn all leds off
 - ```void led_1_on()``` to turn on LED1.

 The STC hardware library makes implementation of the leds1 library functions very clear and straightforward.

 ```C
void leds_off()
{
    // All P3 and P1 pins should be in input only mode.
    // Pins in nnput only mode have high impedance and low current consuption.  
    pin_port_input_only_init(P3);
    pin_port_input_only_init(P1);
}
 ```

 See [STC hardware library pin module docs](https://mgoblin.github.io/STC15lib/docs/html/group__pin.html) for additional details.

***Step 3. Fast led on/off***  
All details of LED state manipulation is under the hood in the leds1 library. Main method of firmware is simple

```C
void main()
{
    while (1)
    {
        // Put all LEDs off 
        leds_off();
        f_delay_ms(LED_BLINK_DELAY_MS);
        
        // Put L1 on
        led_1_on();
        f_delay_ms(LED_BLINK_DELAY_MS);
    }
}
```
Rapid switching of the LED on and off is perceived by the human eye as the LED being constantly on.

>[!NOTE]
> LED1 and some other LEDs are biased by USB-2-TTL adapter. After firmware upload diconnect Rx and Tx pins from USB-2-TTL adapter.   

## Stage 2

In the stage1 led on/of code was placed in the main function and fast blinking was implemented using delays.

In stage2 code is moved to timer interrupt service routine.

***Step1. Initialize and start timer 0.***

As a first step timer is initialized and started in main function and main function go to endles waiting.

```C
void main()
{
    timer0_mode0_1T_init();
    timer0_mode0_start(TIMER_TICKS);

    while (1) {}
}
```

Timer interrupt routine is declared as 
```C
void timerISR() __interrupt(1) __naked
```

SDCC keyword `__interrupt` means that this is interrupt handler and argument 1 is interrupt number. Timer0 has interrupt number 1.

The second SDCC keyword `__naked` means that compiler shouled not generate prolog and epilog with stack pop/push for register save/restore and other auxiliary code. This allows you to reduce the firmware size, but requires explicit code to rerun from interrup`reti`.

We will not use `__naked` interrupt handlers in the next stages because it need manual controlling save/restore registers. But its possible.

***Step2. Implement timer0 interrupt handler.***

The second of the programming techniques is using bit flag variable inside interrupt handler (interrupt serive routine).

```C
__bit is_led_1_on = 0; // L1 On/Off bit flag 
```

STC15 have special SRAM bit addressable area and SDCC compiler have keyword `__bit` for bit flag type.

Alternative way to implement "memoizing" L1 state is check P3.0 and P1.0 pin values and mode. See the pseudo code below.

```C
bool is_led1_on()
{
    return P10 == 0 && P3.0 == 1 && <check P10 and P30 mode is push pull>
}
```

This way doesnt need additional SRAM, but increase code size.

We have the requirement to frimware size less then 1K and we dont exhause SRAM. Therefore bit flag is more preferable way to implement "memoizing" L1 state in this firmware.

## Stage 3

Stage 3 demostrate how to turn on line 0. Line 0 consists of L1, L2, L3, L4, L5. Line 0 is even line.

***Step 1. Initialize pins mode and timer 0***

Lets see the main function code. Its obviousю

```C
void main()
{
    // Initialzie P3 pins
    pin_port_pull_push_init(P3);
    P3 = LOW;

    // Initialzie P1 pins
    pin_port_input_only_init(P1);
    pin_push_pull_init(P1, 0);
    P10 = LOW;

    // Initialize and start timer 0 for L1-L5 turn on
    timer0_mode0_1T_init();
    timer0_mode0_start(TICKS_COUNT);

    while (1) {}
}
```

All P3 pins set to push pull mode and LOW (logical 0) value.
Only P10 pin initialized to push pull mode, other P1 pins is in input only mode.  
This combinataion of P1 and P3 modes is enabling put L1-L5 leds on/off by changing only P3 pins value. 


***Step 2. Turn L1-L5 on***

Timer 0 interrupt handler is responsible for cyclically fast sequentialy on/off one of L1-L5.

The P3 values ​​corresponding to the L1-L5 on/off states are stored in the P3_pins array. The current LED index is stored in the pins_idx variable.

The timer 0 interrupt handler sets the P3 value and increments pins_idx. In the case of L5 on, pins_idx is cleared to the initial value of 0.

```C
void timerISR() __interrupt(1)
{
    P3 = P3_pins[pins_idx];
    pins_idx == P3_PINS_COUNT - 1 ? pins_idx = 0 : pins_idx++;
}
```

The timer 0 interrupt period is set small enough to give the impression that all LEDs are on.

## Stage 4

## Stage 5

## Stage 6

## Stage 7

## Stage 8

## Stage 9

# Similar DIY projects

# Next ideas

