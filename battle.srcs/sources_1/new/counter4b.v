`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/20 16:18:02
// Design Name: 
// Module Name: counter4b
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

module counter4b (
clk, // 时钟
clr_n, // 清零，低有效
q
); 

input clk;
input clr_n;
output reg [3:0] q;

always @ (posedge clk or negedge clr_n) begin
if (!clr_n)
    q <= 4'b0;
else
    q <= q+1;

end
endmodule

