# 16-bit Multicycle CPU

A Verilog implementation of a 16-bit multicycle CPU, built for a Digital System Design (DSD) course assignment. The design follows a classic 5-stage multicycle control flow (IF → ID → EXE → MEM → WB), similar in spirit to a simplified MIPS pipeline but executed one stage at a time per instruction.

**Author:** Arisa Arzan Pour (402105608)

## Repository Structure

```
.
├── src/         # Verilog source modules
├── syn/         # Synthesis-related files
├── testbench/   # Testbenches and simulation scripts
└── doc.pdf      # Full project report (design notes, in Persian)
```

## Architecture Overview

The CPU is controlled by a 5-state FSM in the Control Unit:

| Stage | Description |
|-------|-------------|
| **IF** (Instruction Fetch) | `PC` is driven onto the memory address bus to fetch the next instruction. |
| **ID** (Instruction Decode) | The fetched word is latched into an instruction register; the opcode and instruction type (R-type or M-type) are extracted. |
| **EXE** (Execute) | R-type instructions read operands from the register file and feed them into the ALU. M-type instructions additionally compute a memory address via the ALU. |
| **MEM** (Memory Access) | For M-type instructions, memory read (Load) or write (Store) control signals are asserted. R-type instructions skip this stage. |
| **WB** (Write Back) | The result (from the ALU or from memory) is written back to the register file. `PC` is updated and the FSM returns to IF. |

A `ready` output pulses high whenever an instruction completes.

## Modules

### 1. Carry Save Adder (CSA)
A gate-level 4-bit carry-save adder (`csa`), built from full adders. `bit16_csa` instantiates the 4-bit CSA four times, chaining each block's carry-out into the next block's carry-in to produce a full 16-bit sum and final carry-out. A supporting `mux` module implements basic multiplexer logic used throughout the design.

### 2. Multiplier (Karatsuba)
Implements 16×16-bit signed multiplication using the Karatsuba method.

- **`shiftadd`** — an 8×8-bit unsigned shift-and-add multiplier. A 4-state FSM extends the multiplicand to 16 bits, then repeatedly checks the LSB of the multiplier: if set, adds the (shifting) multiplicand into the running result. After 8 cycles it asserts `done` with the final 16-bit product.
- **`multiply`** — the top-level signed multiplier. It extracts the sign of each operand from its MSB, XORs them to determine the sign of the result, and converts negative operands to two's complement so the core multiplication is always unsigned. It splits the 16-bit operands per the Karatsuba decomposition and instantiates `shiftadd` three times to compute the partial products. Its own FSM (`WAIT → START_MULT → CALCULATE → DONE`) starts the three sub-multiplications, waits for all three `done` signals, combines the partial products per the Karatsuba formula, reapplies the sign, and asserts `done`.

### 3. Divider (Restoring Division)
Implements signed division using the restoring division algorithm. Structurally similar to the multiplier module (register naming follows the standard restoring-division flowchart: `A`, `Q`, `M`, `N`):

1. Initialize `A = 0`, load divisor into `M`, dividend into `Q`.
2. Shift `AQ` left.
3. `A = A - M`.
4. If the MSB of `A` is 0 → set quotient bit, keep `A`. If 1 → clear quotient bit, restore `A` (add `M` back).
5. Repeat for `N` bits.
6. Quotient ends up in `Q`, remainder in `A`.

Asserts `done` in its final FSM state once the operation completes.

### 4. ALU
Aggregates the CSA/adder, multiplier, and divider behind a single interface. Inputs: clock, reset, two signed 16-bit operands, and a 3-bit opcode. Outputs: 16-bit result and a `done` signal.

FSM: `IDLE → EXECUTE → DONE`.

- **IDLE**: control signals are cleared; on `start`, the opcode selects the operation and routes inputs to the corresponding sub-module. An unrecognized opcode drives a `dead` result.
- **EXECUTE**: ADD/SUB (opcodes `000`/`001`) resolve combinationally in the same cycle. MUL (`010`) and DIV (`011`) wait for their sub-module's `done` before latching the result.
- **DONE**: returns to IDLE.

### 5. Memory
A simple synchronous-write, asynchronous-read data memory:
- Write on `posedge clk` when `write_enable` is high.
- Read is combinational (`assign read_data = mem[address]`).
- Sized to 2048 words (rather than the full 16-bit address space) to keep synthesis tractable.

### 6. Register File
4 general-purpose 16-bit registers (`X[0]`–`X[3]`):
- Reads are registered on `negedge clk`.
- Writes (and reset, which clears all registers to 0) happen on `posedge clk` / `posedge reset`.

### 7. Control Unit
The central FSM described in the architecture overview above. Decodes R-type instructions (opcode selects ADD/SUB/MUL/DIV) and M-type instructions (Load/Store, using an ALU-computed address), and drives the ALU, register file, and memory accordingly.

### 8. CPU_top
The top-level module. Takes only `clk` and `reset` as inputs; contains no combinational or sequential logic of its own. It declares the internal wires and instantiates every module above, connecting them into the complete CPU.

## Simulation / Testbenches

Two testbenches are provided under `testbench/`, each preloading instruction memory, initial register values, and (in testbench 2) an initial memory value, then running a short instruction sequence covering LOAD, STORE, ADD, SUB, MUL, and DIV.

Example run (ModelSim/QuestaSim):
```
vsim work.cpu_top_tb
run -all
```

Each testbench prints register and memory contents at every state transition, followed by a final register/memory summary, e.g.:

```
--- Final Register Values ---
R0 = 30
R1 = -30
R2 = 300
R3 = -10
Mem[16] = 30
```

See `doc.pdf` for the full waveform traces and worked-through instruction sequences for both testbenches.

## Notes

- All arithmetic operates on signed 16-bit values.
- MUL and DIV are multi-cycle operations gated by internal `done` signals; ADD and SUB complete combinationally within a single ALU EXECUTE cycle.
- Full design rationale, block diagrams, and FSM flowcharts are documented in `doc.pdf`.
