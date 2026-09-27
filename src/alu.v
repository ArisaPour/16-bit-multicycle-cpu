module ALU (
    input clk,
    input reset,
    input start,
    input [2:0] opcode,
    input signed [15:0] A, B,
    output reg [15:0] result,
    output reg done
);

    wire signed [15:0] add_sub_out;
    wire add_sub_done;
    wire carry_out;

    wire signed [31:0] mul_out;
    wire mul_done;

    wire [15:0] div_quotient, div_remainder;
    wire div_done;

    reg start_mul, start_div;
    wire [15:0] sub_B = ~B + 1;

    reg [15:0] add_A, add_B;
    reg add_start;

    wire signed [15:0] add_result;
    wire add_carry;

    csa_16bit add_sub_unit (
        .A(add_A),
        .B(add_B),
        .c_in(1'b0),
        .S(add_result),
        .c_out(add_carry)
    );

    multiply mult_unit (
        .clk(clk),
        .reset(reset),
        .start(start_mul),
        .a(A),
        .b(B),
        .product(mul_out),
        .done(mul_done)
    );

    divide div_unit (
        .clk(clk),
        .reset(reset),
        .start(start_div),
        .dividend(A),
        .divisor(B),
        .quotient(div_quotient),
        .remainder(div_remainder),
        .done(div_done)
    );

    localparam IDLE = 2'b00, EXECUTE = 2'b01, DONE_STATE = 2'b10;
    reg [1:0] state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done <= 0;
            result <= 0;
            start_mul <= 0;
            start_div <= 0;
            add_start <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    result <= 0;
                    start_mul <= 0;
                    start_div <= 0;
                    add_start <= 0;

                    if (start) begin
                        case (opcode)
                            3'b000: begin
                                add_A <= A;
                                add_B <= B;
                                state <= EXECUTE;
                            end
                            3'b001: begin
                                add_A <= A;
                                add_B <= sub_B;
                                state <= EXECUTE;
                            end
                            3'b010: begin
                                start_mul <= 1;
                                state <= EXECUTE;
                            end
                            3'b011: begin
                                start_div <= 1;
                                state <= EXECUTE;
                            end
                            default: begin
                                result <= 16'hdead;
                                done <= 1;
                            end
                        endcase
                    end
                end

                EXECUTE: begin
                    case (opcode)
                        3'b000, 3'b001: begin
                            result <= add_result;
                            done <= 1;
                            state <= DONE_STATE;
                        end
                        3'b010: begin
                            if (mul_done) begin
                                result <= mul_out[15:0];
                                done <= 1;
                                state <= DONE_STATE;
                            end
                        end
                        3'b011: begin
                            if (div_done) begin
                                result <= div_quotient;
                                done <= 1;
                                state <= DONE_STATE;
                            end
                        end
                    endcase
                end

                DONE_STATE: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
