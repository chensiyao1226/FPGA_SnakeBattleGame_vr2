module vga_core (
        input clk,
        input clr,
        output HS,  // �����ͬ������
        output VS,  // �����ͬ������
        output reg [9:0] hc,
        output reg [9:0] vc,
        output reg vga_en // VGA��ʾ��ʹ�
);

parameter DLY = 1;//��ʱ1ns
parameter hpixles = 10'b1100100000; // �����ص�? 800 ʱ�������Χ����
parameter vrows   = 10'b1000010001; // ����? 521
parameter hbp     = 10'b0010010000; // ����ʾ���أ� 144?128+16?
parameter hfp     = 10'b1100010000; // ����ʾǰ�أ� 784?128+16+640?
parameter vbp     = 10'b0000011111; // ����ʾ���أ� 31?2+29?
parameter vfp     = 10'b0111111111; // ����ʾǰ�أ� 511?2+29+480?
reg vs_en; // vcʹ��

always @ (posedge clk or negedge clr)
    if (!clr) begin
        hc    <= #DLY 1'b0;
        vs_en <= #DLY 1'b1;
    end
    else if (hc == hpixles - 1) begin //һ�е����
        hc    <= #DLY 1'b0;
        vs_en <= #DLY 1'b1;//ֻ��һ��Ϊ1
    end
    else begin
        hc    <= #DLY hc + 1;//��0�ۼ�hc
        vs_en <= 1'b0;
    end

assign HS = (hc < 96) ? 1'b0 : 1'b1;

always @ (posedge clk or negedge clr)
    if (!clr) 
        vc    <= #DLY 1'b0;
    else if (vs_en == 1'b1) begin
        if (vc == vrows - 1)
            vc <= #DLY 1'b0;//vcֻ��ʼ��һ�� 
        else
            vc <= #DLY vc + 1;//vcֻ����ĩ��
    end

assign VS = (vc < 2) ? 1'b0 : 1'b1;

always @ (posedge clk or negedge clr)
    if (!clr)
        vga_en <= #DLY 1'b0;
    else if ((hc < hfp) && (hc >= hbp) && (vc < vfp) && (vc >= vbp))//ǰ����ֻ�ڸ�ֵʹ��λ����
        vga_en <= #DLY 1'b1;
    else
        vga_en <= #DLY 1'b0;

endmodule
