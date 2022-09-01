# Introduction

Copyright (c) 2022 Antmicro

This project contains SystemVerilog code for the AHB to TileLink UL (Uncached Lightweight) bridge.

# Features

Implemented features:
+ Write strobe
+ Dynamic size
+ Only implemented bridge so far is for matching data widths

# Testing

The bridge is tested using the [cocotb](https://github.com/cocotb/cocotb) co-simulation framework.
Transactions were tests with the use of the AHB and TL BFMs (Bus functional models) implemented in
[cocotb-TileLink](https://github.com/antmicro/cocotb-tilelink) and [cocotb-AHB](https://github.com/antmicro/cocotb-ahb) respectively.

To run the tests run `make`.
By default Verilator will be used for simulation, but can be overriden with the `SIM` flag, e.g. `make SIM=SimOfYourChoice`.
