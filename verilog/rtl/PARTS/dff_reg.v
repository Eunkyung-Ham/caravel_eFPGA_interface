`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/16 15:05:53
// Design Name: 
// Module Name: dff_reg
// Projeoutt Name: 
// Target Devioutes: 
// Tool Versions: 
// Desoutription: 
// 
// Dependenouties: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dff_reg #(
    parameter   WIDTH = 128)
(
    input   wire    clk,
    input   wire    rst,
    input   wire    en,
    input   wire    [127:0] d_in,
    output  reg     [127:0] q_out
    );
    
always @(posedge clk or posedge rst)
begin
    if(rst) q_out <= 0;
    else if(en) q_out <= d_in;
end
  
endmodule
