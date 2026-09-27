module multiply (
    input clk,
    input reset,
    input start,
    input signed [15:0] a, b,
    output reg signed [31:0] product,
    output reg done
);

    wire sign_a = a[15];
    wire sign_b = b[15];
    wire result_sign = sign_a ^ sign_b;

    wire [15:0] abs_a = sign_a ? (~a + 1) : a;
    wire [15:0] abs_b = sign_b ? (~b + 1) : b;

    wire [7:0] a_low  = abs_a[7:0];
    wire [7:0] a_high = abs_a[15:8];
    wire [7:0] b_low  = abs_b[7:0];
    wire [7:0] b_high = abs_b[15:8];

    wire [15:0] z0, z2, w0;
    wire done_z0, done_z2, done_w0;

    reg start_z0, start_z2, start_w0;
    reg [15:0] z1;

    parameter WAIT = 2'b00, START_MULT = 2'b01, CALCULATE = 2'b10, DONE = 2'b11;
    reg [1:0] state;

    shiftadd mul_low (
        .clk(clk),
        .rst(reset),
        .start(start_z0),
        .A(a_low),
        .B(b_low),
        .P(z0),
        .done(done_z0)
    );

    shiftadd mul_high (
        .clk(clk),
        .rst(reset),
        .start(start_z2),
        .A(a_high),
        .B(b_high),
        .P(z2),
        .done(done_z2)
    );

    shiftadd mul_mid (
        .clk(clk),
        .rst(reset),
        .start(start_w0),
        .A(a_low + a_high),
        .B(b_low + b_high),
        .P(w0),
        .done(done_w0)
    );

    reg signed [31:0] unsigned_product;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= WAIT;
            done <= 0;
            start_z0 <= 0; start_z2 <= 0; start_w0 <= 0;
            product <= 0;
            z1 <= 0;
        end else begin
            case (state)
                WAIT: begin
                    done <= 0;
                    if (start) begin
                        start_z0 <= 1;
                        start_z2 <= 1;
                        start_w0 <= 1;
                        state <= START_MULT;
                    end
                end

                START_MULT: begin
                    start_z0 <= 0;
                    start_z2 <= 0;
                    start_w0 <= 0;
                    state <= CALCULATE;
                end

                CALCULATE: begin
                    if (done_z0 && done_z2 && done_w0) begin
                        z1 <= w0 - z0 - z2;
                        unsigned_product = ({z2,16'b0}) + ({z1,8'b0}) + z0;
                        product <= result_sign ? (~unsigned_product + 1) : unsigned_product;
                        state <= DONE;
                    end
                end

                DONE: begin
                    done <= 1;
                    state <= WAIT;
                end
            endcase
        end
    end

endmodule
