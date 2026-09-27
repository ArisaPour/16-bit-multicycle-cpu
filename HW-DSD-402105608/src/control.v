module control_unit(
    input wire clk,
    input wire reset,
    output reg [15:0] mem_addr,
    input wire [15:0] mem_data,
    output reg mem_write_enable,
    output reg [15:0] mem_write_data,

    output reg reg_write_enable,
    output reg [1:0] reg_write_addr,
    output reg [15:0] reg_write_data,
    output reg [1:0] reg_read_addr1,
    output reg [1:0] reg_read_addr2,

    input wire [15:0] reg_read_data1,
    input wire [15:0] reg_read_data2,

    output reg alu_start,
    output reg [2:0] alu_opcode,
    output reg [15:0] alu_A, alu_B,
    input wire [15:0] alu_result,
    input wire alu_done,

    output reg ready
);

    reg [10:0] PC;
    reg [2:0] state;
    reg [15:0] instruction;

    reg [2:0] opcode;
    reg [1:0] rs1, rs2, rd;
    reg [8:0] addr;

    localparam IF  = 3'd0,
               ID  = 3'd1,
               EX  = 3'd2,
               MEM = 3'd3,
               WB  = 3'd4;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 0;
            state <= IF;
            ready <= 0;
            alu_start <= 0;
            mem_write_enable <= 0;
            reg_write_enable <= 0;
        end else begin
            case (state)
                IF: begin
                    mem_addr <= PC;
                    mem_write_enable <= 0;
                    reg_write_enable <= 0;
                    alu_start <= 0;
                    ready <= 0;
                    state <= ID;
                end

                ID: begin
                    instruction <= mem_data;
                    opcode <= mem_data[15:13];
                    case (mem_data[15:13])
                        3'b000, 3'b001, 3'b010, 3'b011: begin
                            rd  <= mem_data[12:11];
                            rs1 <= mem_data[10:9];
                            rs2 <= mem_data[8:7];
                            reg_read_addr1 <= mem_data[10:9];
                            reg_read_addr2 <= mem_data[8:7];
                        end
                        3'b100, 3'b101: begin
                            rd  <= mem_data[12:11];
                            rs1 <= mem_data[10:9];
                            addr <= mem_data[8:0];
                            reg_read_addr1 <= mem_data[10:9];
                            if (mem_data[15:13] == 3'b101)
                                reg_read_addr2 <= mem_data[12:11];
                        end
                    endcase
                    state <= EX;
                end

                EX: begin
                    case (opcode)
                        3'b000, 3'b001, 3'b010, 3'b011: begin
                            alu_opcode <= opcode;
                            alu_A <= reg_read_data1;
                            alu_B <= reg_read_data2;
                            alu_start <= 1;
                            if (alu_done) begin
                                alu_start <= 0;
                                state <= WB;
                            end
                        end
                        3'b100, 3'b101: begin
                            alu_opcode <= 3'b000;
                            alu_A <= reg_read_data1;
                            alu_B <= {{7{addr[8]}}, addr};
                            alu_start <= 1;
                            if (alu_done) begin
                                alu_start <= 0;
                                mem_addr <= alu_result[15:0];
                                state <= MEM;
                            end
                        end
                    endcase
                end

                MEM: begin
                    case (opcode)
                        3'b100: begin
                            mem_write_enable <= 0;
                            state <= WB;
                        end
                        3'b101: begin
                            mem_write_enable <= 1;
                            mem_write_data <= reg_read_data2;
                            state <= IF;
                            PC <= PC + 1;
                        end
                    endcase
                end

                WB: begin
                    reg_write_enable <= 1;
                    reg_write_addr <= rd;
                    reg_write_data <= (opcode == 3'b100) ? mem_data : alu_result;

                    PC <= PC + 1;
                    ready <= 1;
                    state <= IF;
                end
            endcase
        end
    end
endmodule
