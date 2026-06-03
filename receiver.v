module receiver(input clk, rst, rdy_clr, clk_enb, rx,
                output reg rdy,
                output reg [7:0] data_out);

  parameter start_state    = 2'b00;
  parameter data_out_state = 2'b01;
  parameter stop_state     = 2'b10;

  reg [1:0] state = start_state;
  reg [3:0] sample = 0;
  reg [2:0] index = 0;
  reg [7:0] temp_register = 8'b0;

  always @(posedge clk)
  begin
    if(rst)
    begin
      rdy <= 1'b0;
      data_out <= 8'b0;
      state <= start_state;
      sample <= 0;
      index <= 0;
      temp_register <= 0;
    end
    else
    begin
      if(rdy_clr)
        rdy <= 0;

      if(clk_enb)
      begin
        case(state)

          start_state : begin
            if(rx == 0) begin
              if(sample == 4'd7) begin
                state        <= data_out_state;
                sample       <= 0;
                index        <= 0;
                temp_register <= 0;
              end else
                sample <= sample + 1'b1;
            end else
              sample <= 0;  
          end

          data_out_state : begin
            if(sample == 4'd15) begin
              temp_register[index] <= rx;
              sample <= 0;
              if(index == 3'd7)
                state <= stop_state;  
              else
                index <= index + 1;
            end else
              sample <= sample + 1;
          end

          stop_state : begin
            if(sample == 4'd15)
            begin
              state    <= start_state;
              data_out <= temp_register;
              rdy      <= 1'b1;
              sample   <= 0;
            end
            else
              sample <= sample + 1'b1;
          end

          default : state <= start_state;

        endcase
      end
    end
  end
endmodule