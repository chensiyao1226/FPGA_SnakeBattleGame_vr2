`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/20 14:13:17
// Design Name: 
// Module Name: LED
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

module LED( //顶层文件，时钟分频，例化计数器模块和数码管控制模块
input clk,
input clr_n,
input [15:0] datain,
output [3:0] enable_n,
output [7:0] seg
    );
    


/*
show7seg u_show7seg(
.datain   (q),
.enable_n (enable_n),
.seg      (seg)
);
endmodule
*/

reg [3:0] d1, d2, d3, d4; //d[7]-dp, d[6:0]-ASCII
reg [3:0] enable_n_r;
reg [7:0] seg_r;

 assign enable_n=enable_n_r;
 assign seg=seg_r;
//扫描频率:50Hz
parameter update_interval = 500000 / 20 - 1;
 
reg [7:0] dat;
 
reg [1:0] cursel;
integer selcnt;

always @(*) begin
    d1=datain[3:0];
    d2=datain[7:4];
    d3=datain[11:8];
    d4=datain[15:12];
end

always @(posedge clk)
begin
	selcnt <= selcnt + 1;
		
	if (selcnt == update_interval)
	begin
		selcnt <= 0;
		cursel <= cursel + 1;
	end
end
 
//切换扫描位选线和数据
always @(*)
begin
	case (cursel)
		2'b00: begin dat = d1; enable_n_r = 4'b1110; end
		2'b01: begin dat = d2; enable_n_r = 4'b1101; end
		2'b10: begin dat = d3; enable_n_r = 4'b1011; end
		2'b11: begin dat = d4; enable_n_r = 4'b0111; end
	endcase
end


always @ (*)
    case (dat)
        4'h0:seg_r = 7'b0000001;
        4'h1:seg_r = 7'b1001111;
        4'h2:seg_r = 7'b0010010;
        4'h3:seg_r = 7'b0000110;
        4'h4:seg_r = 7'b1001100;
        4'h5:seg_r = 7'b0100100;
        4'h6:seg_r = 7'b0100000;
        4'h7:seg_r = 7'b0001111;
        4'h8:seg_r = 7'b0000000;
        4'h9:seg_r = 7'b0000100;
        4'hA:seg_r = 7'b0001000;
        4'hB:seg_r = 7'b1100000;
        4'hC:seg_r = 7'b0110001;
        4'hD:seg_r = 7'b1000010;
        4'hE:seg_r = 7'b0110000;
        4'hF:seg_r = 7'b0111000;
    endcase
endmodule

