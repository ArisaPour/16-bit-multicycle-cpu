module memory(
    input clk,
    input write_enable,
    input [15:0] address,
    input signed [15:0] write_data,
    output signed [15:0] read_data
);
    reg signed [15:0] mem [0:2047];

    always @(posedge clk ) begin
        if (write_enable) begin
            mem[address] <= write_data;
        end
    end

    assign read_data = mem[address];
endmodule
