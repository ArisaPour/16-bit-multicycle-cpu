module shiftadd (
    input clk,
    input rst,
    input start,
    input [7:0] A,
    input [7:0] B,
    output reg [15:0] P,
    output reg done
);

    reg [1:0] state;
    reg [15:0] result;
    reg [15:0] multiplicand;
    reg [7:0]  multiplier;
    reg [2:0]  count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= 2'b00;
            result       <= 16'b0;
            multiplicand <= 16'b0;
            multiplier   <= 8'b0;
            count        <= 3'b000;
            P            <= 16'b0;
            done         <= 1'b0;
        end else begin
            case (state)
                2'b00: begin
                    done <= 1'b0;
                    if (start)
                        state <= 2'b01;
                end

                2'b01: begin
                    result       <= 16'b0;
                    multiplicand <= {8'b0, A};
                    multiplier   <= B;
                    count        <= 3'd7;
                    state        <= 2'b10;
                end

                2'b10: begin
                    if (multiplier[0])
                        result <= result + multiplicand;

                    multiplicand <= multiplicand << 1;
                    multiplier   <= multiplier >> 1;

                    if (count == 0)
                        state <= 2'b11;
                    else
                        count <= count - 1;
                end

                2'b11: begin
                    P    <= result;
                    done <= 1'b1;
                    state <= 2'b00;
                end
            endcase
        end
    end

endmodule