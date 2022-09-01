// Copyright 2022 Antmicro
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//

package TileLinkUL_pkg;
  typedef enum logic [2:0] {
    PutFullData    = 3'h 0,
    PutPartialData = 3'h 1,
    Get            = 3'h 4
  } tl_a_opcode_e;

  typedef enum logic [2:0] {
    AccessAck     = 3'h 0,
    AccessAckData = 3'h 1
  } tl_d_opcode_e;

  typedef struct packed {
    logic                            a_valid;
    tl_a_opcode_e                    a_opcode;
    logic                      [2:0] a_param;
    logic  [Default_pkg::TL_SZW-1:0] a_size;
    logic [Default_pkg::TL_SRCW-1:0] a_source;
    logic   [Default_pkg::TL_AW-1:0] a_address;
    logic  [Default_pkg::TL_DBW-1:0] a_mask;
    logic   [Default_pkg::TL_DW-1:0] a_data;

    logic                            d_ready;
  } tl_m2s_t;

  typedef struct packed {
    logic                             d_valid;
    tl_d_opcode_e                     d_opcode;
    logic                       [2:0] d_param;
    logic   [Default_pkg::TL_SZW-1:0] d_size;
    logic  [Default_pkg::TL_SRCW-1:0] d_source;
    logic [Default_pkg::TL_SINKW-1:0] d_sink;
    logic    [Default_pkg::TL_DW-1:0] d_data;
    logic                             d_error;

    logic                             a_ready;
  } tl_s2m_t;
endpackage
