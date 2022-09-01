// Copyright 2022 Antmicro
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//

package Default_pkg;
  localparam TL_AW=32;                          // Address width in bits
  localparam TL_DW=32;                          // Data width in bits
  localparam TL_SRCW=8;                         // Source id width in bits
  localparam TL_SINKW=1;                        // Sink id width in bits
  localparam TL_DBW=(TL_DW>>3);                 // Data mask width in bits
  localparam TL_SZW=$clog2($clog2(TL_DBW)+1);   // Size width in bits

  localparam AHB_AW=32;         // Address width in bits
  localparam AHB_DW=32;         // Data width in bits
  localparam AHB_DS=(TL_DW>>3); // Data strobe width in bits
  localparam AHB_NM=8;          // Manager id width in bits
endpackage
