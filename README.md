# ESP32-With-ESP-PROG-Demo
Debug your embedded software with ESP32, ESP-PROG, and JTAG. This project is part of a course at University of Massachusetts Lowell, and some details may need to be changed to work for other readers.

## Overview

The ESP32 supports the JTAG debugging interface, which can allow users to debug their embedded applications much like they would a normal Windows/Linux executable. For instance, JTAG allows users to place breakpoints in code, view the memory stack, view registers, and more. However, most ESP32 boards on the market do not contain the required hardware for communicating with an external JTAG adapter. This hardware can be found on chips such as FT2232HL, which is implemented by the ESP-PROG. Other technical details will be spared here. You may refer to Espressif's guides on [JTAG debugging](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/api-guides/jtag-debugging/index.html) and [ESP-PROG](https://docs.espressif.com/projects/espressif-esp-iot-solution/en/latest/hw-reference/ESP-Prog_guide.html) for more information on these topics.

See below for a look at how the Hiletgo ESP-WROOM-32 board may connect to ESP-PROG:

![HiLetgo with ESP-PROG](https://user-images.githubusercontent.com/11084018/153796531-704a58bf-50ef-4992-ae5d-9f0b53731219.png)


The purpose of this project is to show users how to pair the ESP-WROOM-32 development board with the ESP-PROG device. We will use Visual Studio Code and PlatformIO, which is a software plugin that enables app development on numerous IoT microcontrollers such as ESP32. Using VSCode and PlatformIO, we will import an example ESP32 project into our workspace, compile it, upload it, and perform some debugging all through the ESP-PROG debugger board.

## Prerequisites

Download the Ubuntu VM, which already has VSCode and PlatformIO installed: https://www.dropbox.com/s/0g7w8qduzj2rb1k/UbuntuIoT.ova?dl=0

Import the VM into VirtualBox and launch it. The default username is `iot`. The password is `toi`.

The debugging software has a dependency on libpython2.7.so.1.0, so we need to install it. Open a terminal and run the following commands:

```
sudo apt update
sudo apt install libpython2.7
```

## Hardware Setup

You will need the following hardware to complete this project:

* A Hiletgo ESP32-WROOM-32 development board
* ESP-PROG
* 1 USB cable
* 6 male-to-female jumper wires

ESP-PROG contains a 10-pin header which allows wiring to the JTAG interface. For reference, each pin on the header is numbered in the figure below: 

![Pinout](https://user-images.githubusercontent.com/11084018/153796581-d6774911-debe-4abe-91eb-457aa0a2b53a.png)

<img src="JTAG_pin.png" width="250">

To wire the ESP32 to the ESP-PROG, use the table below as a guide. Note that four of the pins on the headers will go unused.

| **ESP-PROG pin** | **ESP32 pin** |
| - | - |
| 1 (VDD) | 5V |
| 2 (TMS) | 14 |
| 3 (GND) | GND |
| 4 (TCK) | 13 |
| 5 (GND) | - |
| 6 (TDO) | 15 |
| 7 (GND) | - |
| 8 (TDI) | 12 |
| 9 (GND) | - |
| 10 (NC) | - |


To connect the devices to your host computer, you can connect the ESP-PROG to the computer directly via a USB cable. You do **not** need to connect the ESP32 to your computer directly. It will receive power from the ESP-PROG via the VDD pin. The JTAG interface also enables programming capabilities for uploading the application to the ESP32, so there is no need to connect to the UART controller on the development board.

## Software Setup

After connecting the ESP-PROG to the computer, make sure your Operating System can see the USB controller (FTDI). In VirtualBox, you should attach the following USB controller to your virtual machine:

* **Devices -> USB -> FTDI Dual RS232-HS**

The USB controller may also be named **Future Devices Dual RS232-HS**

Open VSCode. We are going to import an example "hello world" project into our workspace. Click on the PlatformIO icon on the left side of the screen. In the `Quick Access` tab, click on `PIO Home -> Open` to open the PIO Home page. The screenshot below shows how to do this:

![Open PIO Home](https://user-images.githubusercontent.com/11084018/153796619-b1bdca9d-b231-451e-8597-e3abfddc1d2c.png)

Click on `Project Examples`, and type `espidf-hello-world`. Select it, then hit `import`. This will install the project into your workspace. 

By default, the file `platformio.ini` should open, but if not, you can easily open it by clicking the Explorer icon on the left side of the screen, which will show all files in this project.

Replace the contents of `platformio.ini` with the following:

```
[env]
platform = espressif32
framework = espidf
monitor_speed = 115200

[env:hiletgo-with-jtag]
board = esp32dev
debug_tool = esp-prog
upload_protocol = esp-prog
debug_init_break = tbreak app_main
```

### Build Project

To build the project, open the PlatformIO menu by clicking on its icon, and under the `Project Tasks` tab, select `hiletgo-with-jtag -> General -> Build`.

![Build Project](https://user-images.githubusercontent.com/11084018/153796643-564e0303-0783-4845-82c2-01e46b881284.png)

A terminal will open, and you will see the output from the build task. After a few minutes, the build will finish.

### Upload Firmware

To upload the firmware, select the `Upload` task from the previous menu. Since we configured `platformio.ini` to use ESP-PROG, the upload task will use JTAG (rather than the default UART) to upload the firmware binary. You will see in the terminal that PlatformIO uses the Open On-chip Debugger (OpenOCD) software to communicate to the ESP-PROG. After a short time, the upload should succeed.

![image](https://user-images.githubusercontent.com/11084018/153781182-b54333ed-7d73-4630-91bc-1a9e9817517c.png)

### Launch Debugger

To launch the debugger, navigate to the `Run and Debug` menu by selecting its icon on the left side of the screen. Select the dropdown menu and choose the option `PIO Debug (skip Pre-Debug) ...`.

![image](https://user-images.githubusercontent.com/11084018/153781419-1b0ec1e0-7457-4a42-904d-06f4336a5b96.png)

Switch to the Debug Console. After a few seconds, OpenOCD will launch a GDB session and you will hit a temporary breakpoint in the main function of our application (`app_main`). We added this breakpoint when we added the line `debug_init_break = tbreak app_main` to `platformio.ini`. At the top of the screen, you will see some new buttons have appeared, which are used for controlling the program in the debug state. However, we will use the Debug Console for the majority of our debugging tasks.

![image](https://user-images.githubusercontent.com/11084018/153781742-68132709-8210-4348-84d3-3a7eea3ec587.png)

### Debug

To illustrate a simple example of how to debug a program, we will place a breakpoint in a function and analyze the program when it reaches that function. In the Debug Console, place a breakpoint in the `printf` function:

```
hb printf
```

Now run the program until it reaches this function:

```
cont
```

The ESP32 architecture (Xtensa LX6) contains an `entry` instruction at the beginning of most subroutines. This instruction modifies an internal mechanism of the ESP32 called the **register window**, allowing the current subroutine to access its arguments. In order to view the arguments passed to `printf` (in this case, the string that will be printed out to the console), we need to first execute the `entry` instruction. To do this, run the following:

```
nexti
```

Now you can view the arguments passed to `printf`:

```
i args
```

![image](https://user-images.githubusercontent.com/11084018/153783242-2ae7b69d-25e6-48b8-b076-8a97098a04a0.png)

Our breakpoint still exists, so we can continue (`c`) the program until it re-enters `printf` again. Then, we can execute `entry` (`nexti`) before checking the arguments again. Now you will see that the string has updated.

Here are a couple other useful commands you should know about:
* To view the stack frame details, run `i f`. This provides information on the current function, arguments, local variables, etc.
* To view the backtrace of the call stack, type `bt`.
* To view registers, type `i r`.

### Change Registers

We can also use JTAG and GDB to modify our program. For example, we can modify the register values in the CPU. Set the register A8 to 12345678:

```
set $a8=12345678
```

Now print the value of A8, in both hexadecimal and decimal format:

```
i r a8
```

You can even modify the instruction pointer using this method:

```
set $pc=0
```

Now continue the program:

```
cont
```

The program will crash because it tries to execute at address 0x0. However, no instruction exists at this address. To restart the debugger, close it by either typing `quit` in the Debug Console or clicking the red square a the top of the screen, then re-launch the debugger from the `Run and Debug` menu.

### Change Memory

Open the source file `hello_world_main.c`. This file contains the code that is currently being run by the debugger (when we ran the build task, we compiled this code into a binary image, and the upload task programmed that binary image into the ESP32). Scroll down in the file until you see the following for loop: 

![image](https://user-images.githubusercontent.com/11084018/153785433-882f6f93-20c0-493d-8794-408859a71439.png)

To show an example of how to modify memory, we are going to enter this loop and change the `i` variable. First, place a breakpoint at the beginning of the loop (line 34):

```
hb 34
```

Print the current value of `i`:

```
print i
```

Now modify the value of `i`. For example, you can see it to 100:

```
set variable i = 100
```

Now re-print the variable, and you will see it has changed:

```
print i
```

![image](https://user-images.githubusercontent.com/11084018/153786790-32d0722c-b2cb-43ea-b607-f883d054626a.png)

### Download Firmware

A more advanced usage of debugging is to dump the memory contents, which can effectively recover the firmware. The ESP32 address space ranges from 0x0 to 0xFFFFFFFF. However, dumping the complete memory would take many hours, so it is impractical.

Section 1.3.1 of the [ESP32 technical reference manual](https://www.espressif.com/sites/default/files/documentation/esp32_technical_reference_manual_en.pdf) specifies the address mapping used by the ESP32. Section 1.3.3 specifies the address mapping of external memory, including external flash and external SRAM. The program code (`.text`) and constant variables (`.rodata`) are typically stored in the external flash. Constant variables are stored in the address range 0x3F400000 to 0x3F7FFFFF, and external code is stored in the address range 0x400C2000 to 0x40BFFFFF.

Now return to the Debug Console while the debugging session is active. Dump the program constants:

```
dump binary memory rodata.bin 0x3f400000 0x3f7fffff
```

Dump the program code:

```
dump binary memory text.bin 0x400c2000 0x40bfffff
```

Most likely, the majority of both files will be empty, since this application is small. To confirm that the download succeeded, you can open a terminal and view the file contents; for example:

```
strings rodata.bin | head
```

![image](https://user-images.githubusercontent.com/11084018/153796456-47d2c80d-12b8-43b4-8da5-3bd936651614.png)

## Disable JTAG

In production environments, it is **heavily** recommended that the user disables the JTAG functionality. To do so, open a new terminal and install the `esptool` suite of tools:

```
sudo apt install esptool
```

One of the installed tools is `espefuse`, which provides read and write access to the ESP32's **eFuses**, which is a special kind of nonvolatile memory with the following restriction: once an eFuse bit is set to 1, it can never be set back to 0. One of these eFuses is `JTAG_DISABLE`, a single-bit fuse that controls access to the JTAG interface. By default, `JTAG_DIABLE` is set to 0. Setting it to 1 shall disable the JTAG access. _**This process is irreversible.**_

Unplug the USB cable from the ESP-PROG, and plug in the ESP32. Ensure the USB controller is connected to your VM.

In the terminal we just opened, type the following to disable JTAG:

```
espefuse burn_efuse JTAG_DISABLE
```

The prompt will warn you that the operation is irreversible. You are instructed to type `BURN` if you want to proceed with the process.
