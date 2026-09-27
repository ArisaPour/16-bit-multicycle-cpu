`timescale 1ns / 1ns

module cpu_tb;
    reg clk;
    reg reset;

    cpu_top uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        $dumpfile("cpu_tb1.vcd");
        $dumpvars(0, cpu_tb);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $monitor("Time: %0t | R0: %d | R1: %d | R2: %d | R3: %d | Mem[16]: %d", 
            $time,
            $signed(uut.regfile.X[0]),
            $signed(uut.regfile.X[1]),
            $signed(uut.regfile.X[2]),
            $signed(uut.regfile.X[3]),
            $signed(uut.memory_inst.mem[16])
        );
    end

    initial begin
        reset = 1;
        #20;
        reset = 0;

        uut.memory_inst.mem[0] = 16'h8205;  // LOAD R0, R1, #5
        uut.memory_inst.mem[1] = 16'h0300;  // ADD R0, R1, R2
        uut.memory_inst.mem[2] = 16'hA206;  // STORE R0, R1, #6
        uut.memory_inst.mem[3] = 16'h3B00;  // SUB R3, R1, R2
        uut.memory_inst.mem[4] = 16'h5080;  // MUL R2, R0, R1
        uut.memory_inst.mem[5] = 16'h6D80;  // DIV R1, R2, R3

        uut.regfile.X[0] = 16'd0;
        uut.regfile.X[1] = 16'd10;
        uut.regfile.X[2] = 16'd20;

        uut.memory_inst.mem[15] = 16'd123;

        #1000;

        $display("\n--- Final Register Values ---");
        $display("R0        = %d", $signed(uut.regfile.X[0]));
        $display("R1        = %d", $signed(uut.regfile.X[1]));
        $display("R2        = %d", $signed(uut.regfile.X[2]));
        $display("R3        = %d", $signed(uut.regfile.X[3]));
        $display("Mem[16]   = %d", $signed(uut.memory_inst.mem[16]));

        $stop;
    end
endmodule