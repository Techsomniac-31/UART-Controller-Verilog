module uart_top_tb;

reg clk, rst;
reg [7:0] data_in;
reg wr_en;
wire rdy;
reg rdy_clr;
wire [7:0] dout;
wire busy;

uart_top dut(
    .rst(rst),
    .data_in(data_in),
    .wr_en(wr_en),
    .clk(clk),
    .rdy_clr(rdy_clr),
    .rdy(rdy),
    .busy(busy),
    .data_out(dout)
);

always #5 clk = ~clk;

initial begin
    clk     = 0;
    rst     = 0;
    data_in = 0;
    rdy_clr = 0;
    wr_en   = 0;
end

task send_byte(input [7:0] din);
begin
    wait(!busy);
    @(negedge clk);
    data_in = din;
    wr_en   = 1'b1;
    @(negedge clk);
    wr_en   = 1'b0;
end
endtask

task clear_ready;
begin
    @(negedge clk);
    rdy_clr = 1'b1;
    @(negedge clk);
    rdy_clr = 1'b0;
end
endtask

initial begin
    #2000000;
    $display("ERROR: Timeout - rdy never asserted!");
    $finish;
end

initial begin
    @(negedge clk);
    rst = 1'b1;
    #20;
    rst = 1'b0;

    send_byte(8'h41);
    wait(rdy);
    $display("received data is %h", dout);
    clear_ready;

    send_byte(8'h55);
    wait(rdy);
    $display("received data is %h", dout);
    clear_ready;

    #1000 $finish;
end

endmodule