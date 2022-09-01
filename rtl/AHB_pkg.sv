// Copyright 2022 Antmicro
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//

package AHB_pkg;
  typedef enum logic [1:0] {
    Idle   = 2'h0,
    Busy   = 2'h1,
    NonSeq = 2'h2,
    Seq    = 2'h3
  } h_trans_e;

  typedef enum logic [2:0] {
    Single = 3'h0,
    Incr   = 3'h1,
    Wrap4  = 3'h2,
    Incr4  = 3'h3,
    Wrap8  = 3'h4,
    Incr8  = 3'h5,
    Wrap16 = 3'h6,
    Incr16 = 3'h7
  } h_burst_e;

  typedef enum logic [2:0] {
    Byte        = 3'h0,
    Halfword    = 3'h1,
    Word        = 3'h2,
    Doubleword  = 3'h3,
    Quadword    = 3'h4,
    Octupleword = 3'h5,
    Bit512      = 3'h6,
    Bit1024     = 3'h7
  } h_size_e;

  typedef enum logic {
    InstAcs = 1'b0,
    DataAcs = 1'b1
  } acs_type_e;

  typedef enum logic {
    UnPrivAcs = 1'b0,
    PrivAcs   = 1'b1
  } priv_type_e;

  typedef enum logic {
    UnBuff = 1'b0,
    Buff   = 1'b1
  } buff_type_e;

  typedef enum logic {
    Strict = 1'b0,
    Allow  = 1'b1
  } modifiable_e;

  typedef enum logic {
    Allowed = 1'b0,
    Forced  = 1'b1
  } lookup_e;

  typedef enum logic {
    NoAlloc  = 1'b0,
    Alloc    = 1'b1
  } alloc_e;

  typedef enum logic {
    NotShared = 1'b0,
    Shared    = 1'b1
  } shareable_e;

  typedef struct packed {
    acs_type_e   op;
    priv_type_e  priv;
    buff_type_e  buff;
    modifiable_e modifiable;
    lookup_e     lookup;
    alloc_e      alloc;
    shareable_e  share;
  } h_prot_t;

  typedef enum logic {
    Secure = 1'b0,
    NonSecure = 1'b1
  } h_nonsec_e;

  typedef enum logic {
    UnLocked = 1'b0,
    Locked = 1'b1
  } h_lock_e;

  typedef enum logic {
    NonExclusive = 1'b0,
    Exclusive = 1'b1
  } h_excl_e;

  typedef enum logic {
    Wait = 1'b0,
    Ready = 1'b1
  } h_hreadyout_e;

  typedef enum logic {
    Okay = 1'b0,
    Error = 1'b1
  } h_resp_e;

  typedef struct packed {
    logic [Default_pkg::AHB_AW-1:0] h_address;
    h_burst_e                       h_burst;
    h_lock_e                        h_mastlock;
    h_prot_t                        h_prot;
    h_size_e                        h_size;
    h_nonsec_e                      h_nonsec;
    h_excl_e                        h_excl;
    logic [Default_pkg::AHB_NM-1:0] h_master;
    h_trans_e                       h_trans;
    logic [Default_pkg::AHB_DW-1:0] h_wdata;
    logic [Default_pkg::AHB_DS-1:0] h_wstrb;
    logic                           h_write;
  } h_manager_out_t;

  typedef struct packed {
    logic [Default_pkg::AHB_AW-1:0] h_address;
    h_burst_e                       h_burst;
    h_lock_e                        h_mastlock;
    h_prot_t                        h_prot;
    h_size_e                        h_size;
    h_nonsec_e                      h_nonsec;
    h_excl_e                        h_excl;
    logic [Default_pkg::AHB_NM-1:0] h_master;
    h_trans_e                       h_trans;
    logic [Default_pkg::AHB_DW-1:0] h_wdata;
    logic [Default_pkg::AHB_DS-1:0] h_wstrb;
    logic                           h_write;

    logic                           h_ready;
    logic                           h_sel;
  } h_subordinate_in_t;

  localparam h_manager_out_t AHB_MANAGER_OUT_DEFAULT = '{
    h_address:  '0,
    h_burst:    Single,
    h_mastlock: UnLocked,
    h_prot:     {InstAcs, PrivAcs, UnBuff, Allow, Allowed, NoAlloc, Shared},
    h_size:     Byte,
    h_nonsec:   NonSecure,
    h_excl:     NonExclusive,
    h_master:   '0,
    h_trans:    Idle,
    h_wdata:    '0,
    h_wstrb:    '0,
    h_write:    '0
  };

  typedef struct packed {
    logic [Default_pkg::AHB_DW-1:0] h_rdata;
    logic                           h_ready;
    h_resp_e                        h_resp;
    logic                           h_exokay;
  } h_manager_in_t;

  typedef struct packed {
    logic [Default_pkg::AHB_DW-1:0] h_rdata;
    h_hreadyout_e                   h_readyout;
    h_resp_e                        h_resp;
    logic                           h_exokay;
  } h_subordinate_out_t;

  localparam h_subordinate_out_t AHB_SUBORDINATE_OUT_DEFAULT = '{
    h_rdata:    '0,
    h_readyout: Ready,
    h_resp:     Okay,
    h_exokay:   1'b0
  };

  localparam h_subordinate_out_t AHB_SUBORDINATE_OUT_STALL = '{
    h_rdata:    '0,
    h_readyout: Wait,
    h_resp:     Okay,
    h_exokay:   1'b0
  };

endpackage
