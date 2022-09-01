// Copyright 2022 Antmicro
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Synchronous bridge from AHB(Subordinate) to TL-UL(Master)

typedef enum logic[2:0] {
  IDLE            = 3'h0,
  GET_DATA        = 3'h1,
  SEND_TL         = 3'h2,
  DRIVE_HRESP     = 3'h3,
  DRIVE_HREADYOUT = 3'h4
} h_state_t;

typedef struct packed {
  logic [Default_pkg::TL_DW-1:0] d_data;
  logic                          d_error;
} tl_response_t;

typedef enum logic [1:0] {
  TL_IDLE   = 2'h0,
  TL_A_SEND = 2'h1,
  TL_D_RECV = 2'h2,
  TL_DONE   = 2'h3
} tl_state_t;

module AHB_TileLinkUL_Same_Size_Bridge
  import Default_pkg::*;
  import TileLinkUL_pkg::*;
  import AHB_pkg::*;
#(
  parameter [Default_pkg::TL_SRCW-1:0] SourceId = 0 // For TileLink
)(
  input clk_i,
  input rst_ni,

  input  h_subordinate_in_t  ahb_i,
  output h_subordinate_out_t ahb_o,

  input  tl_s2m_t            tl_i,
  output tl_m2s_t            tl_o
);

  logic              select, idle_type_cmd, tl_done, write, got_resp;

  logic [TL_SZW-1:0] size;
  logic [ TL_AW-1:0] address;
  logic [TL_DBW-1:0] mask, read_mask;
  logic [ TL_DW-1:0] data;

  h_state_t     state;
  tl_response_t resp;

// TL side of bridge

  tl_state_t    tl_fsm_state;

  logic [TL_DBW-1:0] mask_lookup [$clog2(TL_DBW)+1];

  generate
    for(genvar i=0; i <= $clog2(TL_DBW); i+=1) begin
      assign mask_lookup[i] = {{(TL_DBW-(1<<i)){1'b0}}, {(1<<i){1'b1}}};
    end
  endgenerate

  always_comb begin
    tl_o = '0;
    if (tl_fsm_state == TL_A_SEND | (tl_fsm_state == TL_IDLE & state == SEND_TL)) begin
      tl_o = '{
        a_valid:    1'b1,
        a_opcode:   write ? &mask ? PutFullData
                                  : PutPartialData
                          : Get,
        a_param:    '0,
        a_size:     size,
        a_source:   SourceId,
        a_address:  address,
        a_mask:     write ? mask : read_mask,
        a_data:     write ? data : '0,
        default:    '0
      };
    end
    tl_o.d_ready = tl_i.d_valid;
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      tl_fsm_state <= TL_IDLE;
    end else if (tl_fsm_state == TL_IDLE & state == SEND_TL) begin
      if (tl_i.a_ready & tl_i.d_valid) begin
        tl_fsm_state <= TL_IDLE;
      end else if (tl_i.a_ready) begin
        tl_fsm_state <= TL_D_RECV;
      end else begin
        tl_fsm_state <= TL_A_SEND;
      end
    end else if (tl_fsm_state == TL_A_SEND & tl_i.a_ready) begin
     if (tl_i.d_valid) begin
        tl_fsm_state <= TL_IDLE;
     end else begin
        tl_fsm_state <= TL_D_RECV;
      end
    end else if (tl_fsm_state == TL_D_RECV & tl_i.d_valid) begin
      tl_fsm_state <= TL_IDLE;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      resp <= '0;
    end else if (tl_i.d_valid) begin
      resp.d_data  <= tl_i.d_data;
      resp.d_error <= tl_i.d_error;
    end else if (ahb_i.h_ready) begin
      resp <= '0;
    end
  end

  assign got_resp = tl_i.d_valid;

// AHB side of bridge

  assign select = ahb_i.h_ready & ahb_i.h_sel;
  assign idle_type_cmd = ahb_i.h_trans inside {Idle, Busy};

  always_comb begin
    ahb_o = AHB_SUBORDINATE_OUT_DEFAULT;
    if(state inside {GET_DATA, SEND_TL}) begin
      ahb_o = AHB_SUBORDINATE_OUT_STALL;
    end else if (state inside {DRIVE_HRESP, DRIVE_HREADYOUT}) begin
      ahb_o.h_rdata    = resp.d_data;
      ahb_o.h_exokay   = 1'b0;
      ahb_o.h_resp     = resp.d_error;
      ahb_o.h_readyout = state == DRIVE_HREADYOUT;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      address   <= '0;
      size      <= '0;
      write     <= '0;
      mask      <= '0;
    end else if (select) begin
      address   <= ahb_i.h_address;
      size      <= ahb_i.h_size[TL_SZW-1:0];
      write     <= ahb_i.h_write;
      mask      <= ahb_i.h_wstrb;
      read_mask <= mask_lookup[ahb_i.h_size[TL_SZW-1:0]] << (ahb_i.h_address[TL_SZW-1:0]);
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      data      <= '0;
    end else if (state == GET_DATA) begin
      data      <= ahb_i.h_wdata;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state <= IDLE;
    end else if (state == IDLE & select & idle_type_cmd) begin
      state <= IDLE;
    end else if (state == IDLE & select & ahb_i.h_write) begin
      state <= GET_DATA;
    end else if (state == IDLE & select) begin
      state <= SEND_TL;
    end else if (state == GET_DATA) begin
      state <= SEND_TL;
    end else if (state == SEND_TL & got_resp & tl_i.d_error) begin
      state <= DRIVE_HRESP;
    end else if (state == SEND_TL & got_resp & !tl_i.d_error) begin
      state <= DRIVE_HREADYOUT;
    end else if (state == DRIVE_HRESP) begin
      state <= DRIVE_HREADYOUT;
    end else if (state == DRIVE_HREADYOUT & select & idle_type_cmd) begin
      state <= IDLE;
    end else if (state == DRIVE_HREADYOUT & select & ahb_i.h_write) begin
      state <= GET_DATA;
    end else if (state == DRIVE_HREADYOUT & select) begin
      state <= SEND_TL;
    end else if (state == DRIVE_HREADYOUT) begin
      state <= IDLE;
    end
  end

endmodule
