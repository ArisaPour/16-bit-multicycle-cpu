module divide (
    input clk,
    input reset,
    input start,
    input [15:0] dividend,
    input [15:0] divisor,
    output reg [15:0] quotient,
    output reg [15:0] remainder,
    output reg done
);

    reg [15:0] A;
    reg [15:0] Q;
    reg [15:0] M;
    reg [4:0]  n;
    reg [1:0]  state;
    reg [15:0] A_next;

    reg dividend_sign;
    reg divisor_sign;
    reg result_sign;

    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam FINISH  = 2'b10;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            A <= 16'd0;
            Q <= 16'd0;
            M <= 16'd0;
            n <= 5'd0;
            quotient <= 16'd0;
            remainder <= 16'd0;
            done <= 1'b0;
            state <= IDLE;
            dividend_sign <= 1'b0;
            divisor_sign <= 1'b0;
            result_sign <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        dividend_sign <= dividend[15];
                        divisor_sign  <= divisor[15];
                        result_sign   <= dividend[15] ^ divisor[15];

                        A <= 16'd0;
                        Q <= dividend[15] ? (~dividend + 1) : dividend;
                        M <= divisor[15]  ? (~divisor + 1)  : divisor;
                        n <= 5'd16;
                        state <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    A <= {A[14:0], Q[15]};
                    Q <= {Q[14:0], 1'b0};
                    A_next = {A[14:0], Q[15]} - M;

                    if (A_next[15] == 1'b1) begin
                        Q[0] <= 1'b0;
                    end else begin
                        A <= A_next;
                        Q[0] <= 1'b1;
                    end

                    n <= n - 1;

                    if (n == 1) begin
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    quotient <= result_sign ? (~Q + 1) : Q;
                    remainder <= dividend_sign ? (~A + 1) : A;
                    done <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
