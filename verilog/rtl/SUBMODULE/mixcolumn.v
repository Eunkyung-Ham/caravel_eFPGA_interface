module mixcolumn (
    input   wire    [127:0] in,
    output  wire    [127:0] out
);

assign out[127:120] = mixcolumn2311 (in[127:120], in[119:112], in[111:104], in[103:96]);
assign out[119:112] = mixcolumn2311 (in[119:112], in[111:104], in[103:96], in[127:120]);
assign out[111:104] = mixcolumn2311 (in[111:104], in[103:96], in[127:120], in[119:112]);
assign out[103:96] = mixcolumn2311 (in[103:96], in[127:120], in[119:112], in[111:104]);

assign out[95:88] = mixcolumn2311 (in[95:88], in[87:80], in[79:72], in[71:64]);
assign out[87:80] = mixcolumn2311 (in[87:80], in[79:72], in[71:64], in[95:88]);
assign out[79:72] = mixcolumn2311 (in[79:72], in[71:64], in[95:88], in[87:80]);
assign out[71:64] = mixcolumn2311 (in[71:64], in[95:88], in[87:80], in[79:72]);

assign out[63:56] = mixcolumn2311 (in[63:56], in[55:48], in[47:40], in[39:32]);
assign out[55:48] = mixcolumn2311 (in[55:48], in[47:40], in[39:32], in[63:56]);
assign out[47:40] = mixcolumn2311 (in[47:40], in[39:32], in[63:56], in[55:48]);
assign out[39:32] = mixcolumn2311 (in[39:32], in[63:56], in[55:48], in[47:40]);

assign out[31:24] = mixcolumn2311 (in[31:24], in[23:16], in[15:8], in[7:0]);
assign out[23:16] = mixcolumn2311 (in[23:16], in[15:8], in[7:0], in[31:24]);
assign out[15:8] = mixcolumn2311 (in[15:8], in[7:0], in[31:24], in[23:16]);
assign out[7:0] = mixcolumn2311 (in[7:0], in[31:24], in[23:16], in[15:8]);


function [7:0] mixcolumn2311;
input [7:0] i1, i2, i3, i4;
begin
    mixcolumn2311[7] = i1[6] ^         i2[6] ^ i2[7]         ^ i3[7] ^ i4[7];
    mixcolumn2311[6] = i1[5] ^         i2[5] ^ i2[6]         ^ i3[6] ^ i4[6];
    mixcolumn2311[5] = i1[4] ^         i2[4] ^ i2[5]         ^ i3[5] ^ i4[5];
    mixcolumn2311[4] = i1[3] ^ i1[7] ^ i2[3] ^ i2[4] ^ i2[7] ^ i3[4] ^ i4[4];
    mixcolumn2311[3] = i1[2] ^ i1[7] ^ i2[2] ^ i2[3] ^ i2[7] ^ i3[3] ^ i4[3];
    mixcolumn2311[2] = i1[1] ^         i2[1] ^ i2[2]         ^ i3[2] ^ i4[2];
    mixcolumn2311[1] = i1[0] ^ i1[7] ^ i2[0] ^ i2[1] ^ i2[7] ^ i3[1] ^ i4[1];
    mixcolumn2311[0] =         i1[7]         ^ i2[0] ^ i2[7] ^ i3[0] ^ i4[0];
end
endfunction

endmodule
