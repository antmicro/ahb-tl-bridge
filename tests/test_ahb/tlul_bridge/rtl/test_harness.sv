// Copyright 2022 Antmicro
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//

module test_harness
  import Default_pkg::*;
  import TileLinkUL_pkg::*;
  import AHB_pkg::*;
(
  input  wire                       clk_i,
  input  wire                       rst_ni,

  output wire                            a_valid,
  input  wire                            a_ready,
  output wire                      [2:0] a_opcode,
  output wire                      [2:0] a_param,
  output wire  [Default_pkg::TL_SZW-1:0] a_size,
  output wire [Default_pkg::TL_SRCW-1:0] a_source,
  output wire   [Default_pkg::TL_AW-1:0] a_address,
  output wire  [Default_pkg::TL_DBW-1:0] a_mask,
  output wire   [Default_pkg::TL_DW-1:0] a_data,

  input  wire                             d_valid,
  output wire                             d_ready,
  input  wire                       [2:0] d_opcode,
  input  wire                       [2:0] d_param,
  input  wire   [Default_pkg::TL_SZW-1:0] d_size,
  input  wire  [Default_pkg::TL_SRCW-1:0] d_source,
  input  wire [Default_pkg::TL_SINKW-1:0] d_sink,
  input  wire    [Default_pkg::TL_DW-1:0] d_data,
  input  wire                             d_error,


  input  wire [Default_pkg::AHB_AW-1:0] haddr,
  input  wire                     [2:0] hburst,
  input  wire                           hmastlock,
  input  wire                     [6:0] hprot,
  input  wire                     [2:0] hsize,
  input  wire                           hnonsec,
  input  wire                           hexcl,
  input  wire [Default_pkg::AHB_NM-1:0] hmaster,
  input  wire                     [1:0] htrans,
  input  wire [Default_pkg::AHB_DW-1:0] hwdata,
  input  wire [Default_pkg::AHB_DS-1:0] hwstrb,
  input  wire                           hwrite,
  input  wire                           hready,
  input  wire                           hsel,

  output wire [Default_pkg::AHB_DW-1:0] hrdata,
  output wire                           hreadyout,
  output wire                           hresp,
  output wire                           hexokay
);

  h_subordinate_out_t ahb_o;
  h_subordinate_in_t  ahb_i;

  tl_m2s_t        tl_o;
  tl_s2m_t        tl_i;

  assign tl_i = '{
    d_valid:  d_valid,
    d_opcode: d_opcode,
    d_param:  d_param,
    d_size:   d_size,
    d_source: d_source,
    d_sink:   d_sink,
    d_error:  d_error,
    d_data:   d_data,
    a_ready:  a_ready,
    default:  '0
  };

  assign d_ready   = tl_o.d_ready;
  assign a_valid   = tl_o.a_valid;
  assign a_opcode  = tl_o.a_opcode;
  assign a_param   = tl_o.a_param;
  assign a_size    = tl_o.a_size;
  assign a_source  = tl_o.a_source;
  assign a_address = tl_o.a_address;
  assign a_data    = tl_o.a_data;
  assign a_mask    = tl_o.a_mask;

  assign ahb_i = '{
    h_address:  haddr,
    h_burst:    hburst,
    h_mastlock: hmastlock,
    h_prot:     hprot,
    h_size:     hsize,
    h_nonsec:   hnonsec,
    h_excl:     hexcl,
    h_master:   hmaster,
    h_trans:    htrans,
    h_wdata:    hwdata,
    h_wstrb:    hwstrb,
    h_write:    hwrite,

    h_ready:    hready,
    h_sel:      hsel
  };

  assign hrdata    = ahb_o.h_rdata;
  assign hreadyout = ahb_o.h_readyout;
  assign hresp     = ahb_o.h_resp;
  assign hexokay   = ahb_o.h_exokay;

  AHB_TileLinkUL_Bridge u_bridge (
    .clk_i,
    .rst_ni,

    .tl_i,
    .tl_o,

    .ahb_i,
    .ahb_o
  );
endmodule
