# Copyright 2022 Antmicro
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#

from typing import List, Dict, Tuple
from random import randrange, randint

import cocotb # type: ignore
from cocotb.clock import Clock # type: ignore
from cocotb.handle import SimHandle, SimHandleBase # type: ignore
from cocotb.log import SimLog # type: ignore
from cocotb.triggers import ClockCycles, Combine, Join, RisingEdge, ReadOnly, ReadWrite, Timer # type: ignore

from cocotb_AHB.AHB_common.AHB_types import *
from cocotb_AHB.drivers.SimSimpleManager import SimSimpleManager

from cocotb_AHB.interconnect.SimInterconnect import SimInterconnect
from cocotb_AHB.AHB_common.InterconnectInterface import InterconnectWrapper

from cocotb_AHB.drivers.DutSubordinate import DUTSubordinate

from cocotb_AHB.monitors.AHBSignalMonitor import AHBSignalMonitor
from cocotb_AHB.monitors.AHBPacketMonitor import AHBPacketMonitor

from cocotb_TileLink.TileLink_common.TileLink_types import *
from cocotb_TileLink.TileLink_common.Interfaces import MemoryInterface
from cocotb_TileLink.drivers.DutMasterMultiSlaveUL import DutMasterMultiSlaveUL
from cocotb_TileLink.drivers.SimSimpleSlaveUL import SimSimpleSlaveUL

from cocotb_TileLink.monitors.TileLinkULMonitor import TileLinkULMonitor

CLK_PERIOD = (10, "ns")

def update_expected_value(previous_value: List[int], write_value: List[int], mask: List[bool]) -> List[int]:
    result = [0 for i in range(len(previous_value))]
    for  i in range(len(previous_value)):
        result[i] = write_value[i] if mask[i] else previous_value[i]
    return result


def compare_read_values(expected_value: List[int], read_value: List[int], address: int) -> None:
    assert len(expected_value) == len (read_value)
    for i in range(len(read_value)):
        assert expected_value[i] == read_value[i], \
            "Read {:#x} at address {:#x}, but was expecting {:#x}".format(read_value[i], address+i, expected_value[i])


async def setup_dut(dut: SimHandle) -> None:
    cocotb.fork(Clock(dut.clk_i, *CLK_PERIOD).start())
    dut.rst_ni.value = 0
    await ClockCycles(dut.clk_i, 10)
    await RisingEdge(dut.clk_i)
    await Timer(1, units='ns')
    dut.rst_ni.value = 1
    await ClockCycles(dut.clk_i, 1)


def mem_init(TLs: MemoryInterface, size: int) -> None:
    mask = []
    write_value = []
    for i in range(size):
        write_value.append(randint(0, 255))
        mask.append(bool(randint(0, 1)))
    mem_init_array = []
    for _mask, _value in zip(mask, write_value):
        if _mask:
            mem_init_array.append(_value)
        else:
            mem_init_array.append(0)
    TLs.init_memory(mem_init_array, 0)

async def init_random_data(Am: SimSimpleManager, TLs: MemoryInterface, size: int) -> None:
    before_mem = TLs.memory_dump()
    mask = []
    write_value = []
    for i in range(size):
        write_value.append(randint(0, 255))
        mask.append(bool(randint(0, 1)))
    Am.write(0, size, write_value, mask)
    await Am.transfer_done()
    Am.get_rsp(0, 4)
    modified_mem = TLs.memory_dump()
    expected_mem = update_expected_value(before_mem, write_value, mask)
    compare_read_values(expected_mem, modified_mem, 0)


@cocotb.test() # type: ignore
async def simple_AHB_to_TL_transfer(dut: SimHandle) -> None:
    TLs = SimSimpleSlaveUL(size=0x4000)
    TLs.register_clock(dut.clk_i).register_reset(dut.rst_ni, True)

    TLm = DutMasterMultiSlaveUL(dut, "clk_i")
    TLm.register_slave(TLs.get_slave_interface())
    TLs.register_master(TLm.get_master_interface())

    AHBSubordinate = DUTSubordinate(dut, bus_width=32)
    AHBManager     = SimSimpleManager(bus_width=32)
    AHBManager.register_clock(dut.clk_i).register_reset(dut.rst_ni, True)

    interconnect = SimInterconnect().register_subordinate(AHBSubordinate)
    interconnect.register_clock(dut.clk_i).register_reset(dut.rst_ni, True)
    interconnect.register_manager(AHBManager).register_manager_subordinate_addr(AHBManager, AHBSubordinate, 0x0, 0x4000)
    wrapper = InterconnectWrapper()
    wrapper.register_interconnect(interconnect).register_clock(dut.clk_i).register_reset(dut.rst_ni, True)

    cocotb.fork(TLs.process())
    cocotb.fork(TLm.process())
    cocotb.fork(wrapper.start())
    cocotb.fork(AHBManager.start())

    await setup_dut(dut)
    mem_init(TLs, 0x4000)
    await init_random_data(AHBManager, TLs, 0x4000)
    for i in range(0x1000):
        address = randrange(0, 0x4000, 4)
        write_value = []
        mask = []
        for i in range(4):
            write_value.append(randint(0,255))
            mask.append(bool(randint(0,1)))
        AHBManager.read(address, 4)
        await AHBManager.transfer_done()
        previous_value = AHBManager.get_rsp(address, 4)
        AHBManager.write(address, len(mask), write_value, mask)
        await AHBManager.transfer_done()
        AHBManager.read(address, 4)
        await AHBManager.transfer_done()
        read_value = AHBManager.get_rsp(address, 4)

        expected_value = update_expected_value(previous_value,
                                               write_value, mask)

        compare_read_values(expected_value, read_value, address)
