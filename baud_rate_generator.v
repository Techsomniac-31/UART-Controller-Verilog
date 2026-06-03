module baude_rate_generator(input clk, input rst, output tx_enb, output rx_enb);

  reg [12:0] tx_counter = 0;
  reg [9:0]  rx_counter = 0;

  always @(posedge clk)
  begin
    if(rst)
      tx_counter <= 0;
    // 5200 total cycles (0 to 5199)
    else if(tx_counter == 5199) 
      tx_counter <= 0;
    else
      tx_counter <= tx_counter + 1'b1;
  end

  always @(posedge clk)
  begin
    if(rst)
      rx_counter <= 0;
    // 325 total cycles (0 to 324)
    else if(rx_counter == 324) 
      rx_counter <= 0;
    else
      rx_counter <= rx_counter + 1'b1;
  end

  assign tx_enb = (tx_counter == 5199) ? 1'b1 : 1'b0;
  assign rx_enb = (rx_counter == 324)  ? 1'b1 : 1'b0;

endmodule