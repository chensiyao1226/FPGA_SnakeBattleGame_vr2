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
    //input [7:0] data,//可以设计为数据输入
    input   [7:0] sw,//可以设计为拨码开关输入
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
    .rom_addr  ( rom_addr ), //瀵板懏妯夌粈鍝勬禈閸嶅繐婀撮崸锟?
    .RED       ( red      ), // 缁俱垼澹?
    .GRN       ( grn      ), // 缂佽儻澹?
    .BLU       ( blu      ),  // 閽冩繆澹?
    .data_out  ( datain)
);

vga_core u_vga_core (
    .clk       ( clk_25m  ),
    .clr       ( clr      ),
    .HS        ( hs       ),  // 鏉堟挸鍤悰灞芥倱濮濄儰淇婇崣锟?
    .VS        ( vs       ),  // 鏉堟挸鍤崷鍝勬倱濮濄儰淇婇崣锟?
    .hc        ( hc       ),
    .vc        ( vc       ),
    .vga_en    ( vga_en   )   // VGA閺勫墽銇氶崳銊ゅ▏閼筹拷
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

LED LED( //顶层文件，时钟分频，例化计数器模块和数码管控制模块
.clk   (clk_25m),
.clr_n  (clr),
.datain (datain),
.enable_n (enable_n),
.seg (seg)
    );
   
endmodule

