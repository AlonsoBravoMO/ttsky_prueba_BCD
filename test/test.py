# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


clk_period = 100

@cocotb.test()
async def test_D7S_reset(dut):
  dut._log.info("iniciando tb reset")
  
  clock = Clock(dut.clk, clk_period, unit="us")
  cocotb.start_soon(clock.start())  
  
  
  
  #reset acctivo en bajo
  dut.rst_n.value = 0
  dut.ena.value = 1
  dut.ui_in.value = 0
  await ClockCycles(dut.clk, 2)
  
  #liberar reset 
  dut.rst_n.value = 1
  await ClockCycles(dut.clk, 1)
  dut._log.info("Si jalo :D")
