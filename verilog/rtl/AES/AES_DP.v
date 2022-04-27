// --=========================================================================--
// Copyright (c) 2021 DSAL, EWHA Womans University. All rights reserved
//                     DSAL Confidential Proprietary
//  ----------------------------------------------------------------------------
//        This confidential and proprietary software may be used only as
//            authorised by a licensing agreement from DSAL.
//
//         The entire notice above must be reproduced on all authorised
//          copies and copies may only be made to the extent permitted
//                by a licensing agreement from DSAL.
//
//      The entire notice above must be reproduced on all authorized copies.

// -----------------------------------------------------------------------------
// FILE NAME       : aes_dp.v
// DEPARTMENT      : Digital System Architecture Lab.
// AUTHOR          : Ji-Hoon Kim
// AUTHOR'S EMAIL  : jihoonkim@ewha.ac.kr
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE         AUTHOR         DESCRIPTION
// 1.0     2021-08-01   Ji-Hoon Kim    AES Datapath
// -----------------------------------------------------------------------------
// PURPOSE         :  AES Datapath
// -----------------------------------------------------------------------------

module aes_dp (
`ifdef USE_POWER_PINS
    inout   vccd1,	// User area 1 1.8V supply
    inout   vssd1,	// User area 1 digital ground
`endif

    input   wire                clk, 
    input   wire                rst, 

    input   wire    [3:0]       rnd_idx, 

    input   wire                plaintext_en, 
    input   wire    [127:0]     plaintext_in, 

    input   wire                key_en, 
    input   wire    [127:0]     key_in,
    
    input   wire                ciphertext_en, 
    input   wire                rndkey_en, 

    input   wire                sb_mux_ctrl, 
    input   wire                keygen_mux_ctrl, 
    input   wire                skip_mux_ctrl,
    
    output  wire    [127:0]     ciphertext_out
);

wire    [127:0] plaintext_q;
wire    [127:0] key_q;
wire    [127:0] rnd1_in;
wire    [127:0] sb_in, sb_out;
wire    [127:0] sr_in, sr_out;
wire    [127:0] mc_in, mc_out;
wire    [127:0] keygen_in, keygen_out;
wire    [127:0] skip_mux_out;
wire    [127:0] rndkey_q;
wire    [127:0] ciphertext_in;

dff_reg #(.WIDTH(128)) u_plaintext(
    .clk        (clk),
    .rst        (rst),
    .en         (plaintext_en),
    .d_in       (plaintext_in),
    .q_out      (plaintext_q)
);

dff_reg #(.WIDTH(128)) u_key(
    .clk        (clk),
    .rst        (rst),
    .en         (key_en),
    .d_in       (key_in),
    .q_out      (key_q)
);

sky130_fd_sc_hd__xor2 u_xor1 [127:0] (
`ifdef USE_POWER_PINS
    .VPWR   (vccd1),
    .VGND   (vssd1),
    .VPB    (vccd1),
    .VNB    (vssd1),
`endif
    .A      (plaintext_q),
    .B      (key_q),
    .X      (rnd1_in)
);

sky130_fd_sc_hd__mux2 u_sb_mux [127:0] (
`ifdef USE_POWER_PINS
    .VPWR   (vccd1),
    .VGND   (vssd1),
    .VPB    (vccd1),
    .VNB    (vssd1),
`endif
    .A0     (ciphertext_out),
    .A1     (rnd1_in),
    .S      (sb_mux_ctrl),
    .X      (sb_in)
);

sky130_fd_sc_hd__mux2 u_keygen_mux [127:0] (
`ifdef USE_POWER_PINS
    .VPWR   (vccd1),
    .VGND   (vssd1),
    .VPB    (vccd1),
    .VNB    (vssd1),
`endif
    .A0     (key_q),
    .A1     (rndkey_q),
    .S      (keygen_mux_ctrl),
    .X      (keygen_in)
);

key_gen u_keygen (
    .rnd_idx    (rnd_idx),
    .key        (keygen_in),
    .keyout     (keygen_out)
);

subbytes u_sb (
    .in   (sb_in),
    .out  (sb_out)
);

assign  sr_in = sb_out;

shiftrow u_sr (
    .in   (sr_in),
    .out  (sr_out)
);

assign  mc_in = sr_out;

mixcolumn u_mc (
    .in   (mc_in), 
    .out  (mc_out)
);

sky130_fd_sc_hd__mux2 u_skip_mux [127:0] (
`ifdef USE_POWER_PINS
    .VPWR   (vccd1),
    .VGND   (vssd1),
    .VPB    (vccd1),
    .VNB    (vssd1),
`endif
    .A0     (sr_out),
    .A1     (mc_out),
    .S      (skip_mux_ctrl),
    .X      (skip_mux_out)
);

sky130_fd_sc_hd__xor2 u_xor2 [127:0] (
`ifdef USE_POWER_PINS
    .VPWR   (vccd1),
    .VGND   (vssd1),
    .VPB    (vccd1),
    .VNB    (vssd1),
`endif
    .A      (skip_mux_out),
    .B      (keygen_out),
    .X      (ciphertext_in)
);

dff_reg #(.WIDTH(128)) u_ciphertext(
    .clk        (clk),
    .rst        (rst),
    .en         (ciphertext_en),
    .d_in       (ciphertext_in),
    .q_out      (ciphertext_out)
);

dff_reg #(.WIDTH(128)) u_rndkey(
    .clk        (clk),
    .rst        (rst),
    .en         (rndkey_en),
    .d_in       (keygen_out),
    .q_out      (rndkey_q)
);

endmodule

