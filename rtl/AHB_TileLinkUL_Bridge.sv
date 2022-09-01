// Copyright 2022 Antmicro
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Synchronous bridge from TL-UL(Slave) to AHB(Manager)

module AHB_TileLinkUL_Bridge
  import Default_pkg::*;
  import TileLinkUL_pkg::*;
  import AHB_pkg::*;
#(
  parameter [Default_pkg::TL_SRCW-1:0] SourceId = '0
) (
  input clk_i,
  input rst_ni,

  input  h_subordinate_in_t  ahb_i,
  output h_subordinate_out_t ahb_o,

  input  tl_s2m_t            tl_i,
  output tl_m2s_t            tl_o
);

  generate
    if (AHB_DW == TL_DW) begin
      AHB_TileLinkUL_Same_Size_Bridge #(
        .SourceId
      ) bridge(
        .clk_i,
        .rst_ni,

        .ahb_i,
        .ahb_o,

        .tl_i,
        .tl_o
      );
    end else begin
      $fatal("No bridge found for AHB data width and TL data width");
    end
  endgenerate

endmodule
