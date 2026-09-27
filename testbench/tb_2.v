`timescale 1ns / 1ns

module cpu_tb2;
    reg clk;
    reg reset;

    cpu_top uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        $dumpfile("cpu_tb2.vcd");
        $dumpvars(0, cpu_tb2);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $monitor("Time: %0t | R0: %d | R1: %d | R2: %d | R3: %d | Mem[59]: %d", 
            $time,
            $signed(uut.regfile.X[0]),
            $signed(uut.regfile.X[1]),
            $signed(uut.regfile.X[2]),
            $signed(uut.regfile.X[3]),
            $signed(uut.memory_inst.mem[59])
        );
    end

    initial begin
        reset = 1;
        #20;
        reset = 0;

        uut.memory_inst.mem[0] = 16'h2300; // SUB R0, R1, R2  => R0 = R1 - R2 = -17 - (-5) = -12
        uut.memory_inst.mem[1] = 16'h5900; // MUL R3, R0, R2  => R3 = -12 * -5 = 60
        uut.memory_inst.mem[2] = 16'h7680; // DIV R2, R3, R1  => R2 = 60 / -17 = -3 (integer div)
        uut.memory_inst.mem[3] = 16'h0900; // ADD R1, R0, R2  => R1 = -12 + (-3) = -15
        uut.memory_inst.mem[4] = 16'hB7FF; // STORE R2, R3, #-1

        uut.regfile.X[0] = 16'd0;
        uut.regfile.X[1] = -17;
        uut.regfile.X[2] = -5;
        uut.regfile.X[3] = 0;

        #1000;

        $display("\n--- Final Register Values ---");
        $display("R0        = %d", $signed(uut.regfile.X[0]));
        $display("R1        = %d", $signed(uut.regfile.X[1]));
        $display("R2        = %d", $signed(uut.regfile.X[2]));
        $display("R3        = %d", $signed(uut.regfile.X[3]));
        $display("Mem[59]   = %d", $signed(uut.memory_inst.mem[59]));

        $stop;
    end
endmodule

