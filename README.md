# caravel eFPGA interface
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/user_project_ci.yml) [![Caravel Build](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml/badge.svg)](https://github.com/efabless/caravel_project_example/actions/workflows/caravel_build.yml)

## Project Description
When implementing several different systems in an SoC, an ip for each system is required, which increases the chip size and increases the complexity.
In addition, the flexibility of the system is also limited because these digital IPs are not after manufacturing or modify.
But we can solve this by connecting FPGA to SoC.
FPGA is an integrated circuit that can be programmed by a user after it has been manufactured.
There will be many advantages if it is integrated into the SoC and used as a reconfigurable IP. (high density, low price, smaller size, low complexity)

In this project, we considered ways to improve the use efficiency of eFPGA by adding a structure that can load bitstream while using eFPGA by connecting it to SoC.
So, we propose an eFPGA configuration interface allowing convenient reconfiguration.
The bitstream of several systems to be implemented by chip is created, stored in on-chip memory, and the bitstream is accessed to the stored address whenever necessary to load immediately to the eFPGA.

For more detail about the entire system, the entire chip is designed through Skywater Opposition FPGA (SOFA) connected to the caravel SoC.
The user uses VTR (Verilog to Routing) to generate a bitstream for each multiple system to be operated by the chip and stores it in the bitstream bank of the on-chip SRAM.
Using the proposed eFPGA configuration interface, the user accesses the address of the SRAM where the bitstream of the digital system to be operated is stored.
And that configuration data will be loaded from SRAM to eFPGA.
If you want to switch to another system and operate it, SRAM will access another address where the bitstream of the system is stored, load it to the eFPGA, reconfigure the eFPGA, and processing will proceed.

After all, with our proposed design, the user can create a chip that can perform various functions with a single IP block (eFPGA) by simply selecting several systems to implement in SoC, creating each bitstream, and storing it in SRAM.
Users who do not know much about eFPGA can also make low price, high density, smaller size, and reconfigurable chips.


## Block diagram
### User project area
<img width="572" alt="eFPGA_interface_uprj" src="https://user-images.githubusercontent.com/102022220/166154071-20df7a52-f333-47fd-bc63-900762061309.PNG">

### Interface flow
<img width="450" alt="interface_flow" src="https://user-images.githubusercontent.com/102022220/166154346-5e654090-f93e-4d29-a240-79b50d561cc2.PNG">


## Team member
Eunkyung Ham, M.S student of EWHA woman's University.
Yujin Jeon, M.S student of EWHA woman's University.
Jaeyun Lim, M.S student of EWHA woman's University.
Sohyeon Kim, Researcher of Digital System Architecture Lab.
