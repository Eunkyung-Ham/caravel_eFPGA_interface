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
// FILE NAME       : aes_wrapper.v
// DEPARTMENT      : Digital System Architecture Lab.
// AUTHOR          : Ji-Hoon Kim
// AUTHOR'S EMAIL  : jihoonkim@ewha.ac.kr
// -----------------------------------------------------------------------------
// RELEASE HISTORY
// VERSION DATE         AUTHOR         DESCRIPTION
// 1.0     2021-08-01   Ji-Hoon Kim    aes_ahb template
// -----------------------------------------------------------------------------
// PURPOSE         :  Lab#05 - Build Your Own AES (Encryption Only)
// -----------------------------------------------------------------------------
// REFERENCE       :  Caravel User project wrapper
// -----------------------------------------------------------------------------

/* verilator lint_off WIDTH */
/* verilator lint_off UNUSED */

module aes_wrapper #(
		parameter DATA_WIDTH = 32,
		parameter ADDR_WIDTH = 32 )
	(
`ifdef USE_POWER_PINS
    inout 	vccd1,	// User area 1 1.8V supply
    inout 	vssd1,	// User area 1 digital ground
`endif

		// Wishbone Slave ports (WB MI A)
    	input wb_clk_i,
    	input wb_rst_i,
    	input wbs_stb_i,
    	input wbs_cyc_i,
    	input wbs_we_i,
    	input [3:0] wbs_sel_i,
    	input [DATA_WIDTH - 1:0] wbs_dat_i,
    	input [ADDR_WIDTH - 1:0] wbs_adr_i,
    	output wbs_ack_o,
    	output [DATA_WIDTH - 1:0] wbs_dat_o,

		// Logic Analyzer Signals
    	input  [127:0] la_data_in,
    	output [127:0] la_data_out,
    	input  [127:0] la_oenb,

    	// IOs
    	input  [`MPRJ_IO_PADS-1:0] io_in,
    	output [`MPRJ_IO_PADS-1:0] io_out,
    	output [`MPRJ_IO_PADS-1:0] io_oeb,

    	// IRQ
		output  [2:0] irq
	);

	wire CLK;
	wire RST;
	
	reg [3:0] ack_reg;
	wire valid;
	wire [3:0] wstrb;
	wire [DATA_WIDTH - 1:0] wdata;
	reg [DATA_WIDTH - 1:0] rdata;

	assign CLK = wb_clk_i;
	assign RST = wb_rst_i;
	//assign irq = {2'b00, aes_valid};
	assign irq = 3'b000;
	
	localparam KEY_WIDTH       = 128;
	localparam BLOCK_WIDTH     = 128;
	localparam STATUS_WORDS    = 1;
	localparam KEY_WORDS       = ( KEY_WIDTH/DATA_WIDTH );
	localparam BLOCK_WORDS     = ( BLOCK_WIDTH/DATA_WIDTH );
	localparam RESULT_WORDS    = ( BLOCK_WIDTH/DATA_WIDTH );
	localparam TOTAL_WORDS     = ( STATUS_WORDS + KEY_WORDS + BLOCK_WORDS + RESULT_WORDS );
	localparam BLOCK_WORDS_LOG = 2;  // Log of BLOCK_WORDS
	localparam KEY_WORDS_LOG   = 2;  // Log of KEY_WORDS

// --------------------------------------------------------------------------
// Register Addresses (Word Address, Not Byte Address)
// --------------------------------------------------------------------------
	localparam STATUS_REG_ADDR = ( 30'b0011_0000_0000_0000_0000_0000_0000_00 );		  // 0x3000_0000
	localparam BLOCK_REG_ADDR    = ( STATUS_REG_ADDR + 30'd01 ); // 0x3000_0004
	localparam KEY_REG_ADDR  = ( BLOCK_REG_ADDR + 30'd04 );    // 0x3000_0014
	localparam RESULT_REG_ADDR = ( KEY_REG_ADDR + 30'd04 );  // 0x3000_0024

// --------------------------------------------------------------------------
// Status Register bits
// --------------------------------------------------------------------------
	localparam START_BIT    = 0;
	localparam READY_BIT    = 1;
	localparam ENCDEC_BIT   = 2;
	localparam RESVALID_BIT = 3;

// --------------------------------------------------------------------------
// AES Accelerator wires
// --------------------------------------------------------------------------
	wire                       aes_start;
	wire                       aes_ready;
    wire                       aes_encdec;
	wire [KEY_WIDTH - 1 : 0]   aes_key;
	wire [BLOCK_WIDTH - 1 : 0] aes_plaintext;
	wire [BLOCK_WIDTH - 1 : 0] aes_ciphertext;
	wire                       aes_valid;

// --------------------------------------------------------------------------
// Wishbone MI A
// --------------------------------------------------------------------------
	assign wstrb = wbs_sel_i & {4{wbs_we_i}};
	assign wbs_dat_o = (read_enable)? read_mux : rdata;
	assign wbs_ack_o = (|ack_reg);
	assign wdata = wbs_dat_i;

// --------------------------------------------------------------------------
// Logic Analyzer 
// --------------------------------------------------------------------------
	reg [127:0] ciphertext_reg;
	assign la_data_out = ciphertext_reg;

	always @ ( posedge CLK or posedge RST ) begin
		if ( RST )
			ciphertext_reg <= 128'h0;
		else if ( aes_valid )
			ciphertext_reg <= aes_ciphertext;
	end

// --------------------------------------------------------------------------
// Internal wires
// --------------------------------------------------------------------------
	reg [ADDR_WIDTH - 1 : 0] addr_strobe;

	// Registers
	reg  [DATA_WIDTH - 1 : 0] key_reg [KEY_WORDS - 1 : 0];
	reg  [DATA_WIDTH - 1 : 0] block_reg [BLOCK_WORDS - 1 : 0];
	wire [DATA_WIDTH - 1 : 0] status_reg;
	reg  [DATA_WIDTH - 1 : 0] read_mux;

	// Selection and control signals
	reg  start_reg, encdec_reg;
	wire is_selected, write_enable, read_enable;
	wire write_status, write_key, write_block;
	reg  write_status_reg, write_key_reg, write_block_reg;

	// Counters and muxs selection signals
	wire [BLOCK_WORDS_LOG - 1 : 0] block_word_sel;
	wire [KEY_WORDS_LOG - 1 : 0]   key_word_sel;

// --------------------------------------------------------------------------
// Address Mux and Counters
// --------------------------------------------------------------------------
	// This slave is selected 
	assign is_selected = wbs_cyc_i && wbs_stb_i;

	// Word selection calculation
	assign block_word_sel = wbs_adr_i[ 3 : 2 ];   
	assign key_word_sel   = wbs_adr_i[ 3 : 2 ];

	always @ ( posedge CLK ) begin
		if ( read_enable )
			addr_strobe <= wbs_adr_i;
	end

// --------------------------------------------------------------------------
// Read Mux
// --------------------------------------------------------------------------
	// Status register declaration
	assign read_enable = is_selected & ~wbs_we_i;
	assign status_reg  = {28'b0, aes_valid, encdec_reg, start_reg, aes_ready};

	// Read multiplexer
	always @* begin
		case( addr_strobe[ADDR_WIDTH - 1 : 2] )
			0  : read_mux = status_reg; // 0x000
			1  : read_mux = block_reg[1]; // 0x004
			2  : read_mux = block_reg[2]; // 0x008
			3  : read_mux = block_reg[3]; // 0x00C
			4  : read_mux = block_reg[0]; // 0x010
			5  : read_mux = key_reg[1]; // 0x014
			6  : read_mux = key_reg[2]; // 0x018
			7  : read_mux = key_reg[3]; // 0x01C
			8  : read_mux = key_reg[0]; // 0x020
			9  : read_mux = ciphertext_reg[31 : 0];   // 0x024
			10 : read_mux = ciphertext_reg[63 : 32];  // 0x028
			11 : read_mux = ciphertext_reg[95 : 64];  // 0x02C
			12 : read_mux = ciphertext_reg[127 : 96]; // 0x030
			default :
				read_mux = {DATA_WIDTH{1'b0}};
		endcase
	end

// --------------------------------------------------------------------------
// Write Mux
// --------------------------------------------------------------------------
	wire key_selected;
	wire block_selected;

	assign key_selected 	= (wbs_adr_i[ADDR_WIDTH - 1 : 2] == KEY_REG_ADDR 
								|| wbs_adr_i[ADDR_WIDTH - 1 : 2] == KEY_REG_ADDR + 30'd1
								|| wbs_adr_i[ADDR_WIDTH - 1 : 2] == KEY_REG_ADDR + 30'd2
								|| wbs_adr_i[ADDR_WIDTH - 1 : 2] == KEY_REG_ADDR + 30'd3 );
	assign block_selected 	= ( wbs_adr_i[ADDR_WIDTH - 1 : 2] == BLOCK_REG_ADDR
								|| wbs_adr_i[ADDR_WIDTH - 1 : 2] == BLOCK_REG_ADDR + 30'd1
								|| wbs_adr_i[ADDR_WIDTH - 1 : 2] == BLOCK_REG_ADDR + 30'd2
								|| wbs_adr_i[ADDR_WIDTH - 1 : 2] == BLOCK_REG_ADDR + 30'd3);
	
	assign write_enable = is_selected & wbs_we_i;
	assign write_status = write_enable & ( wbs_adr_i[ADDR_WIDTH - 1 : 2] == STATUS_REG_ADDR );
	assign write_key    = write_enable & key_selected;
	assign write_block  = write_enable & block_selected;	

// --------------------------------------------------------------------------
// Write Operands - Status Register
// --------------------------------------------------------------------------
    // Just Single-Cycle Active
	always @ ( posedge CLK or posedge RST) begin
		ack_reg[0] <= 1'b0;
		if ( RST ) begin
			start_reg <= 1'b0;
		end else
			if ( write_status && !ack_reg[0] ) begin
				start_reg <= wdata[START_BIT];
				ack_reg[0] <= 1'b1;
			end else begin
				start_reg <= 1'b0;
			end
	end

	always @ ( posedge CLK or posedge RST ) begin
		ack_reg[1] <= 1'b0;
		if ( RST ) begin
			encdec_reg     <= 1'b0;
		end else
			if ( write_status && !ack_reg[1] ) begin
				encdec_reg     <= wdata[ENCDEC_BIT];
				ack_reg[1] <= 1'b1;
			end
	end

// --------------------------------------------------------------------------
// Write Operands - Key and Block
// --------------------------------------------------------------------------
	// Block write Multiplexer
	always @ ( posedge CLK ) begin
		ack_reg[2] <= 1'b0;
		if ( write_block && !ack_reg[2] ) begin
			block_reg [block_word_sel][31 : 0] <= wdata [31 : 0];
			ack_reg[2] <= 1'b1;
		end
	end
	// Key write Multiplexer
	always @ ( posedge CLK ) begin
		ack_reg[3] <= 1'b0;
		if ( write_key && !ack_reg[3] ) begin
			key_reg [key_word_sel][31 : 0] <= wdata [31 : 0];
			ack_reg[3] <= 1'b1;
		end
	end

// --------------------------------------------------------------------------
// AES Accelerator
// --------------------------------------------------------------------------
	genvar i;
	generate
		for ( i = 0; i < BLOCK_WORDS; i = i + 1 ) begin : BLOCK_ASSIGN
			assign aes_plaintext[DATA_WIDTH * ( i + 1 ) - 1 : DATA_WIDTH * i] = block_reg[i];
		end

		for ( i = 0; i < KEY_WORDS; i = i + 1 ) begin : KEY_ASSIGN
			assign aes_key[DATA_WIDTH * ( i + 1 ) - 1 : DATA_WIDTH * i] = key_reg[i];
		end
	endgenerate

	assign aes_start  = start_reg;
	//assign aes_encdec = encdec_reg; Encryption only!

	aes_core u_custom_aes (
	`ifdef USE_POWER_PINS
		.vccd1			(vccd1),	// User area 1 1.8V power
		.vssd1			(vssd1),	// User area 1 digital ground
    `endif
		.clk             ( CLK             ),
		.rst             ( RST          ),
		.aes_start       ( aes_start        ),
		.aes_ready       ( aes_ready        ),
		.aes_key         ( aes_key          ),
		.aes_plaintext   ( aes_plaintext    ),
		.aes_ciphertext  ( aes_ciphertext   ),
		.aes_valid       ( aes_valid        )
	);

endmodule

