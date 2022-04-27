module key_gen (
    input   wire    [3:0]   rnd_idx,
    input   wire    [127:0] key,
    output  wire    [127:0] keyout
);

wire    [31:0]  w0, w1, w2, w3, tempa;

assign  w0  =   key[127:96];
assign  w1  =   key[95:64];
assign  w2  =   key[63:32];
assign  w3  =   key[31:0];

assign  keyout[127:96]  =   w0 ^ tempa ^ rcon_val(rnd_idx);
assign  keyout[95:64]   =   w0 ^ tempa ^ rcon_val(rnd_idx) ^ w1;
assign  keyout[63:32]   =   w0 ^ tempa ^ rcon_val(rnd_idx) ^ w1 ^ w2;
assign  keyout[31:0]    =   w0 ^ tempa ^ rcon_val(rnd_idx) ^ w1 ^ w2 ^ w3;

sbox a1 (
    .a     (w3[23:16]),
    .c    (tempa[31:24])
);

sbox a2 (
    .a     (w3[15:8]),
    .c    (tempa[23:16])
);

sbox a3 (
    .a     (w3[7:0]),
    .c    (tempa[15:8])
);

sbox a4 (
    .a     (w3[31:24]),
    .c    (tempa[7:0])
);

function [31:0] rcon_val;
input   [3:0]   idx;
begin
    case(idx)
        4'h1: rcon_val=32'h01_00_00_00;
        4'h2: rcon_val=32'h02_00_00_00;
        4'h3: rcon_val=32'h04_00_00_00;
        4'h4: rcon_val=32'h08_00_00_00;
        4'h5: rcon_val=32'h10_00_00_00;
        4'h6: rcon_val=32'h20_00_00_00;
        4'h7: rcon_val=32'h40_00_00_00;
        4'h8: rcon_val=32'h80_00_00_00;
        4'h9: rcon_val=32'h1b_00_00_00;
        4'hA: rcon_val=32'h36_00_00_00;
        default: rcon_val=32'h00_00_00_00;
    endcase
end
endfunction

endmodule
