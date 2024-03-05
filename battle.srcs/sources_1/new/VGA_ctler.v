`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/06/24 12:26:09
// Design Name: 
// Module Name: VGA_ctler
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


module VGA_ctler (
    input clk,
    input clr,
    //input [7:0] data,//�������Ϊ��������
    input   [7:0] sw,//�������Ϊ���뿪������
    input [4:0] key,
    output  hs,
    output  vs,
    output  [3:0] red,
    output  [3:0] grn,
    output  [3:0] blu,
    output [3:0] enable_n,
    output [6:0] seg
);

wire [9:0] hc, vc;
wire [11:0] data;  // pixel data
wire [15:0] rom_addr;
wire vga_en;
wire clk_25m;
wire [15:0] datain;

vga_bsprite y_vga_bsprite (
    .clk       ( clk_25m  ),
    .clr       ( clr      ),
    .hc        ( hc       ),
    .vc        ( vc       ),
    .data      ( data     ),
    .key        ( key       ),////////8'b01010101
    .vga_en    ( vga_en   ),
    .rom_addr  ( rom_addr ), //寰呮樉绀哄浘鍍忓湴鍧�?
    .RED       ( red      ), // 绾㈣�?
    .GRN       ( grn      ), // 缁胯�?
    .BLU       ( blu      ),  // 钃濊�?
    .data_out  ( datain)
);

vga_core u_vga_core (
    .clk       ( clk_25m  ),
    .clr       ( clr      ),
    .HS        ( hs       ),  // 杈撳嚭琛屽悓姝ヤ俊鍙�?
    .VS        ( vs       ),  // 杈撳嚭鍦哄悓姝ヤ俊鍙�?
    .hc        ( hc       ),
    .vc        ( vc       ),
    .vga_en    ( vga_en   )   // VGA鏄剧ず鍣ㄤ娇鑳�
);

clk_div u_clk_div (
    .clk       ( clk      ),
    .clr       ( clr      ),
    .clk_div4  ( clk_25m  )
);

blk_mem_gen_1 u_blk_mem_gen_1 (
    .clka      ( clk_25m  ),
    .ena       ( 1'b1     ), 
    .addra     ( rom_addr ), 
    .douta     ( data     ) 
);

LED LED( //�����ļ���ʱ�ӷ�Ƶ������������ģ�������ܿ���ģ��
.clk   (clk_25m),
.clr_n  (clr),
.datain (datain),
.enable_n (enable_n),
.seg (seg)
    );
   
endmodule

