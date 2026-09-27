module cpu_top(
    input wire clk,
    input wire reset
);

    wire [15:0] mem_addr;
    wire [15:0] mem_data_out;
    wire [15:0] mem_write_data;
    wire mem_write_enable;

    wire [1:0] reg_write_addr, reg_read_addr1, reg_read_addr2;
    wire [15:0] reg_write_data;
    wire [15:0] reg_read_data1, reg_read_data2;
    wire reg_write_enable;

    wire alu_start;
    wire [2:0] alu_opcode;
    wire [15:0] alu_A, alu_B;
    wire [15:0] alu_result;
    wire alu_done;

    wire ready;

    memory memory_inst (
        .clk(clk),
        .write_enable(mem_write_enable),
        .address(mem_addr),
        .write_data(mem_write_data),
        .read_data(mem_data_out)
    );

    register_file regfile (
        .clk(clk),
        .reset(reset),
        .write_enable(reg_write_enable),
        .read_addr1(reg_read_addr1),
        .read_addr2(reg_read_addr2),
        .write_addr(reg_write_addr),
        .write_data(reg_write_data),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );

    ALU alu (
        .clk(clk),
        .reset(reset),
        .start(alu_start),
        .opcode(alu_opcode),
        .A(alu_A),
        .B(alu_B),
        .result(alu_result),
        .done(alu_done)
    );

    control_unit cu (
        .clk(clk),
        .reset(reset),
        .mem_addr(mem_addr),
        .mem_data(mem_data_out),
        .mem_write_enable(mem_write_enable),
        .mem_write_data(mem_write_data),

        .reg_write_enable(reg_write_enable),
        .reg_write_addr(reg_write_addr),
        .reg_write_data(reg_write_data),
        .reg_read_addr1(reg_read_addr1),
        .reg_read_addr2(reg_read_addr2),
        .reg_read_data1(reg_read_data1),
        .reg_read_data2(reg_read_data2),

        .alu_start(alu_start),
        .alu_opcode(alu_opcode),
        .alu_A(alu_A),
        .alu_B(alu_B),
        .alu_result(alu_result),
        .alu_done(alu_done),

        .ready(ready)
    );

endmodule

