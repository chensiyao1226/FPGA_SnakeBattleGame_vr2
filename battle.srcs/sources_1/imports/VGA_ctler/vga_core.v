module vga_core (
        input clk,
        input clr,
        output HS,  // 输出行同步信卿
        output VS,  // 输出场同步信卿
        output reg [9:0] hc,
        output reg [9:0] vc,
        output reg vga_en // VGA显示器使聿
);

parameter DLY = 1;//延时1ns
parameter hpixles = 10'b1100100000; // 行像素点? 800 时序下最大范围？？
parameter vrows   = 10'b1000010001; // 行数? 521
parameter hbp     = 10'b0010010000; // 行显示后沿， 144?128+16?
parameter hfp     = 10'b1100010000; // 行显示前沿， 784?128+16+640?
parameter vbp     = 10'b0000011111; // 场显示后沿， 31?2+29?
parameter vfp     = 10'b0111111111; // 场显示前沿， 511?2+29+480?
reg vs_en; // vc使能

always @ (posedge clk or negedge clr)
    if (!clr) begin
        hc    <= #DLY 1'b0;
        vs_en <= #DLY 1'b1;
    end
    else if (hc == hpixles - 1) begin //一行的最后
        hc    <= #DLY 1'b0;
        vs_en <= #DLY 1'b1;//只此一点为1
    end
    else begin
        hc    <= #DLY hc + 1;//从0累加hc
        vs_en <= 1'b0;
    end

assign HS = (hc < 96) ? 1'b0 : 1'b1;

always @ (posedge clk or negedge clr)
    if (!clr) 
        vc    <= #DLY 1'b0;
    else if (vs_en == 1'b1) begin
        if (vc == vrows - 1)
            vc <= #DLY 1'b0;//vc只初始化一次 
        else
            vc <= #DLY vc + 1;//vc只在行末换
    end

assign VS = (vc < 2) ? 1'b0 : 1'b1;

always @ (posedge clk or negedge clr)
    if (!clr)
        vga_en <= #DLY 1'b0;
    else if ((hc < hfp) && (hc >= hbp) && (vc < vfp) && (vc >= vbp))//前后沿只在赋值使能位有用
        vga_en <= #DLY 1'b1;
    else
        vga_en <= #DLY 1'b0;

endmodule
