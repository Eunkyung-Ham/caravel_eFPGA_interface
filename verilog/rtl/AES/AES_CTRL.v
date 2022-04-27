`timescale 1ns / 1ps
module aes_ctrl(
    input   wire                clk, 
    input   wire                rst, 

    input   wire                aes_start, 
    output  reg                aes_ready, 
    output  reg                aes_valid, 

    output   reg    [3:0]       rnd_idx,   

    output   reg                plaintext_en, 
    output   reg                key_en, 
    output   reg                ciphertext_en, 
    output   reg                rndkey_en, 
                      
    output   reg                sb_mux_ctrl, 
    output   reg                keygen_mux_ctrl, 
    output   reg                skip_mux_ctrl
    );
    
    //RND index count
    //mux control
    //enable control
 localparam IDLE = 2'd0, COUNT = 2'd1;
 reg [1:0] state, nstate;
 
 
 always @*
 begin
    case( state )
        IDLE:   nstate = (aes_start) ? COUNT : IDLE;
        COUNT:  nstate = (aes_valid) ? IDLE  : COUNT;
    endcase    
 end
 
 always @ (posedge clk or posedge rst)
 begin
    if ( rst )   state <= IDLE;
    else begin
        state <= nstate;
        case ( nstate )
            IDLE:   rnd_idx <= 4'b0;
            COUNT:  rnd_idx <= rnd_idx + 4'b1; 
        endcase
    end
 end
 
 always @ (posedge clk or posedge rst)
 begin
    if ( rst )  begin
                    plaintext_en    <=  0;
                    key_en          <=  0;
                    ciphertext_en   <=  0;
                    rndkey_en       <=  0;
                    sb_mux_ctrl     <=  0;
                    keygen_mux_ctrl <=  0;
                    skip_mux_ctrl   <=  0;
                    aes_valid       <=  0;
                    aes_ready       <=  1;
    end
    else begin
        case ( rnd_idx )
            4'd0 :  begin
                    plaintext_en    <=  1;
                    key_en          <=  1;
                    ciphertext_en   <=  1;
                    rndkey_en       <=  1;
                    sb_mux_ctrl     <=  1;
                    keygen_mux_ctrl <=  0;
                    skip_mux_ctrl   <=  1;
                    aes_ready       <=  0;
                    aes_valid       <=  0;
                    end
            4'd9:  begin
                    plaintext_en    <=  0;
                    key_en          <=  0;
                    ciphertext_en   <=  1;
                    rndkey_en       <=  1;
                    sb_mux_ctrl     <=  0;
                    keygen_mux_ctrl <=  1;
                    skip_mux_ctrl   <=  0;
                    end
            4'd10:  begin
                    plaintext_en    <=  0;
                    key_en          <=  0;
                    ciphertext_en   <=  0;
                    rndkey_en       <=  0;
                    aes_valid       <=  1;
                    aes_ready       <=  1;
                    end
            4'd11:  begin
                    aes_valid       <=  0;
                    end
            default: begin
                    plaintext_en    <=  0;
                    key_en          <=  0;
                    ciphertext_en   <=  1;
                    rndkey_en       <=  1;
                    sb_mux_ctrl     <=  0;
                    keygen_mux_ctrl <=  1;
                    skip_mux_ctrl   <=  1;
                    end
        endcase
    end
 end
    
endmodule
