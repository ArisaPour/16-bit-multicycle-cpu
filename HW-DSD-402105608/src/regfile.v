module register_file (
    input wire clk,
    input wire reset,              
    input wire write_enable,
    input wire [1:0] read_addr1,
    input wire [1:0] read_addr2,
    input wire [1:0] write_addr,
    input wire [15:0] write_data,
    output reg [15:0] read_data1,
    output reg [15:0] read_data2
);

    reg [15:0] X [0:3];

    always @(negedge clk) begin
        read_data1 <= X[read_addr1];
        read_data2 <= X[read_addr2];
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            X[0] <= 16'b0;
            X[1] <= 16'b0;
            X[2] <= 16'b0;
            X[3] <= 16'b0;
        end else if (write_enable) begin
            X[write_addr] <= write_data;
        end
    end

endmodule