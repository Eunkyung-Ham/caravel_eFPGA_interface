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
// FILE NAME       : aes_core.v
// DEPARTMENT      : Digital System Architecture Lab.
// AUTHOR          : Ji-Hoon Kim
// AUTHOR'S EMAIL  : jihoonkim@ewha.ac.kr
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE         AUTHOR         DESCRIPTION
// 1.0     2021-08-01   Ji-Hoon Kim    AES Core Top Module
// -----------------------------------------------------------------------------
// PURPOSE         :  AES Core (Supporting only 128-bit AES ECB Mode)
// -----------------------------------------------------------------------------

module aes_core (
`ifdef USE_POWER_PINS
    inout   vccd1,	// User area 1 1.8V supply
    inout   vssd1,	// User area 1 digital ground
`endif

    input   wire                clk, 
    input   wire                rst, 
    
    input   wire                aes_start, 
    output  wire                aes_ready, 
    output  wire                aes_valid, 
    
    input   wire    [127:0]     aes_plaintext, 
    input   wire    [127:0]     aes_key, 
    output  wire    [127:0]     aes_ciphertext
);

wire    [3:0]   rnd_idx;
wire            plaintext_en;
wire            ciphertext_en;
wire            key_en;
wire            rndkey_en;
wire            sb_mux_ctrl;
wire            keygen_mux_ctrl;
wire            skip_mux_ctrl;

aes_dp u_dp (
`ifdef USE_POWER_PINS
	.vccd1(vccd1),	// User area 1 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
`endif

    .clk                (clk), 
    .rst                (rst), 
                      
    .rnd_idx            (rnd_idx),  
                      
    .plaintext_en       (plaintext_en), 
    .plaintext_in       (aes_plaintext), 
                      
    .key_en             (key_en), 
    .key_in             (aes_key),
                      
    .ciphertext_en      (ciphertext_en), 
    .rndkey_en          (rndkey_en), 
                      
    .sb_mux_ctrl        (sb_mux_ctrl), 
    .keygen_mux_ctrl    (keygen_mux_ctrl), 
    .skip_mux_ctrl      (skip_mux_ctrl),
                      
    .ciphertext_out     (aes_ciphertext)

);


aes_ctrl u_ctrl (
    .clk                (clk), 
    .rst                (rst), 
                      
    .aes_start          (aes_start), 
    .aes_ready          (aes_ready),
    .aes_valid          (aes_valid),

    .rnd_idx            (rnd_idx),   
                      
    .plaintext_en       (plaintext_en), 
    .key_en             (key_en), 
    .ciphertext_en      (ciphertext_en), 
    .rndkey_en          (rndkey_en), 
                      
    .sb_mux_ctrl        (sb_mux_ctrl), 
    .keygen_mux_ctrl    (keygen_mux_ctrl), 
    .skip_mux_ctrl      (skip_mux_ctrl)
);


endmodule

