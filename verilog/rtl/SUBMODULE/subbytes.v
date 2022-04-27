`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/02 12:04:37
// Design Name: 
// Module Name: subbytes
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module subbytes(
    input   wire    [127:0] in,
    output  wire    [127:0] out
    );
    
sbox u0 (   .a(in[127:120]),   .c(out[127:120]));
sbox u1 (   .a(in[119:112]),   .c(out[119:112]));
sbox u2 (   .a(in[111:104]),   .c(out[111:104]));
sbox u3 (   .a(in[103:96]),   .c(out[103:96]));

sbox u4 (   .a(in[95:88]),   .c(out[95:88]));
sbox u5 (   .a(in[87:80]),   .c(out[87:80]));
sbox u6 (   .a(in[79:72]),   .c(out[79:72]));
sbox u7 (   .a(in[71:64]),   .c(out[71:64]));

sbox u8 (   .a(in[63:56]),   .c(out[63:56]));
sbox u9 (   .a(in[55:48]),   .c(out[55:48]));
sbox u10 (   .a(in[47:40]),   .c(out[47:40]));
sbox u11 (   .a(in[39:32]),   .c(out[39:32]));

sbox u12 (   .a(in[31:24]),   .c(out[31:24]));
sbox u13 (   .a(in[23:16]),   .c(out[23:16]));
sbox u14 (   .a(in[15:8]),   .c(out[15:8]));
sbox u15 (   .a(in[7:0]),   .c(out[7:0]));

endmodule

