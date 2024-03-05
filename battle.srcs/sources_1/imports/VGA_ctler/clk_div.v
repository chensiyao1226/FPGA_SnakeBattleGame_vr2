module clk_div (
        input clk,
        input clr,
        output reg clk_div4
);

reg [1:0] clk_cnt;
parameter DLY = 1;

always @ (posedge clk or negedge clr)
    if (!clr)
        clk_div4 <= #DLY 1'b0;
    else if (clk_cnt == 2'b01)
        clk_div4 <= #DLY ~clk_div4;

always @ (posedge clk or negedge clr)
    if (!clr)
        clk_cnt <= #DLY 2'b0;
    else if ( clk_cnt == 2'b01)
        clk_cnt <= #DLY 2'b0;
    else
        clk_cnt <= #DLY clk_cnt + 1'b1;

endmodule
