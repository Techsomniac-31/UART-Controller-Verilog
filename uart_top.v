module uart_top(input rst,input [7:0] data_in, input wr_en, input clk, input rdy_clr, 
                output rdy, output busy, output [7:0] data_out);

wire rx_clk_en;
wire tx_clk_en;
wire tx_temp;

baude_rate_generator bg(.clk(clk), .rst(rst), .tx_enb(tx_clk_en), .rx_enb(rx_clk_en));

transmitter tx(.clk(clk), .wr_en(wr_en), .rst(rst), .data_in(data_in), .tx_clk_en(tx_clk_en), .tx(tx_temp), .busy(busy));
receiver rx(.clk(clk),.rst(rst),.rdy_clr(rdy_clr),.clk_enb(rx_clk_en),.rx(tx_temp),.rdy(rdy),.data_out(data_out));

endmodule


