// ====================================================================
// subcomponents.v  –  2026 Edition  (CSE302)
// Five-cycle non-pipelined RISC processor - 32-bit instruction format
// ====================================================================
`include "MUX.v"

// ------------------------------------------------------------------
// Basic combinational / utility modules  (unchanged from 2025)
// ------------------------------------------------------------------

module full_adder (A, B, Cin, Sum, Cout);
    input A, B, Cin;
    output Sum, Cout;
    assign Sum  = A ^ B ^ Cin;
    assign Cout = (A & B) | (Cin & (A ^ B));
endmodule

module ripple_carry_adder(A, B, Cin, S, Cout, C7);
    input  [7:0] A, B;
    input  Cin;
    output wire [7:0] S;
    output wire Cout, C7;
    wire temp1, temp2, temp3, temp4, temp5, temp6;
    full_adder inst1(A[0], B[0], Cin, S[0], temp1);
    full_adder inst2(A[1], B[1], temp1, S[1], temp2);
    full_adder inst3(A[2], B[2], temp2, S[2], temp3);
    full_adder inst4(A[3], B[3], temp3, S[3], temp4);
    full_adder inst5(A[4], B[4], temp4, S[4], temp5);
    full_adder inst6(A[5], B[5], temp5, S[5], temp6);
    full_adder inst7(A[6], B[6], temp6, S[6], C7);
    full_adder inst8(A[7], B[7], C7, S[7], Cout);
endmodule

module Adder_Subtractor(A, B, M, S, Cout, Overflow);
    input  [7:0] A, B;
    input  M;
    output wire [7:0] S;
    output wire Cout, Overflow;
    wire [7:0] tempB;
    wire C7;
    assign tempB = B ^ {8{M}};
    ripple_carry_adder inst1(A, tempB, M, S, Cout, C7);
    assign Overflow = Cout ^ C7;
endmodule

module DFFwithSynReset(clk, D, Rst, Q);
    input  clk, D, Rst;
    output reg Q;
    always @(posedge clk)
        if (Rst) Q <= 1'b0; else Q <= D;
endmodule

module onebitRegwithLoad(clk, Reset, load, Datain, Dataout);
    input  clk, Reset, load;
    input  Datain;
    output reg Dataout;
    always @(posedge clk) begin
        if (Reset)       Dataout <= 1'b0;
        else if (load)   Dataout <= Datain;
    end
endmodule

// ------------------------------------------------------------------
// eightbitRegwithLoad  (UNCHANGED)
// ------------------------------------------------------------------
module eightbitRegwithLoad(clk, Reset, load, Datain, Dataout);
    input  clk, Reset, load;
    input  [7:0] Datain;
    output reg [7:0] Dataout;
    always @(posedge clk) begin
        if (Reset)       Dataout <= 8'h00;
        else if (load)   Dataout <= Datain;
    end
endmodule

// ------------------------------------------------------------------
// Small utility muxes used inside sub-modules
// ------------------------------------------------------------------
module Mux16to1_8bit_withoutE(S, I15, I14, I13, I12, I11, I10, I9, I8,
                               I7,  I6,  I5,  I4,  I3,  I2,  I1, I0, Y);
    input  [3:0] S;
    input  [7:0] I15,I14,I13,I12,I11,I10,I9,I8,I7,I6,I5,I4,I3,I2,I1,I0;
    output wire [7:0] Y;
    wire [7:0] arr [0:15];
    assign {arr[15],arr[14],arr[13],arr[12],arr[11],arr[10],arr[9],arr[8],
            arr[7], arr[6], arr[5], arr[4], arr[3], arr[2], arr[1], arr[0]}
         = {I15,I14,I13,I12,I11,I10,I9,I8,I7,I6,I5,I4,I3,I2,I1,I0};
    assign Y = arr[S];
endmodule

module Mux4to1_8bit_withoutE(S, I3, I2, I1, I0, Y);
    input  [1:0] S;
    input  [7:0] I3, I2, I1, I0;
    output wire [7:0] Y;
    wire [7:0] arr [0:3];
    assign {arr[3], arr[2], arr[1], arr[0]} = {I3, I2, I1, I0};
    assign Y = arr[S];
endmodule

// 4-to-16 decoder with enable (used by RegisterFile)
module decoder4to16_withE(A, E, D);
    input  [3:0] A;
    input  E;
    output wire [15:0] D;
    assign D[0] = E & (A == 4'd0);
    assign D[1] = E & (A == 4'd1);
    assign D[2] = E & (A == 4'd2);
    assign D[3] = E & (A == 4'd3);
    assign D[4] = E & (A == 4'd4);
    assign D[5] = E & (A == 4'd5);
    assign D[6] = E & (A == 4'd6);
    assign D[7] = E & (A == 4'd7);
    assign D[8] = E & (A == 4'd8);
    assign D[9] = E & (A == 4'd9);
    assign D[10] = E & (A == 4'd10);
    assign D[11] = E & (A == 4'd11);
    assign D[12] = E & (A == 4'd12);
    assign D[13] = E & (A == 4'd13);
    assign D[14] = E & (A == 4'd14);
    assign D[15] = E & (A == 4'd15);
endmodule

// ------------------------------------------------------------------
// Mux256to1_1bit – Structural wrapper around LargeMuX_withE
// ------------------------------------------------------------------
module Mux256to1_1bit (I, S, E, Y);
    input  [255:0] I;
    input  [7:0]   S;
    input          E;
    output wire    Y;

    LargeMuX_withE #(.n(8), .twopn(256)) structural_mux (
        .I(I),
        .S(S),
        .E(E),
        .Y(Y)
    );
endmodule

// ------------------------------------------------------------------
// Mux256to1_8bit – Structural multibit mux using bit-slicing
// ------------------------------------------------------------------
module Mux256to1_8bit (I, S, E, Y);
    input  [2047:0] I;
    input  [7:0]    S;
    input           E;
    output wire [7:0] Y;

    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : bit_slice_8
            wire [255:0] bit_vector_8;
            for (j = 0; j < 256; j = j + 1) begin : bit_collect_8
                assign bit_vector_8[j] = I[j*8 + i];
            end
            LargeMuX_withE #(.n(8), .twopn(256)) mux_bit_8 (
                .I(bit_vector_8),
                .S(S),
                .E(E),
                .Y(Y[i])
            );
        end
    endgenerate
endmodule

// ------------------------------------------------------------------
// Mux256to1_12bit – Structural multibit mux using bit-slicing
// ------------------------------------------------------------------
module Mux256to1_12bit (I, S, E, Y);
    input  [3071:0] I;
    input  [7:0]    S;
    input           E;
    output wire [11:0] Y;

    genvar i, j;
    generate
        for (i = 0; i < 12; i = i + 1) begin : bit_slice_12
            wire [255:0] bit_vector_12;
            for (j = 0; j < 256; j = j + 1) begin : bit_collect_12
                assign bit_vector_12[j] = I[j*12 + i];
            end
            LargeMuX_withE #(.n(8), .twopn(256)) mux_bit_12 (
                .I(bit_vector_12),
                .S(S),
                .E(E),
                .Y(Y[i])
            );
        end
    endgenerate
endmodule


module Comparator_Unsigned_8bit(A, B, Greater, Less, Equal);
    input [7:0] A, B;
    output Greater, Less, Equal;
    assign Greater = (A > B);
    assign Less    = (A < B);
    assign Equal   = (A == B);
endmodule

module PriorityEncoder_4to2bit(I, Y);
    input [3:0] I;
    output reg [1:0] Y;
    always @(*) begin
        if (I[3])      Y = 2'b11;
        else if (I[2]) Y = 2'b10;
        else if (I[1]) Y = 2'b01;
        else           Y = 2'b00;
    end
endmodule

// ====================================================================
// Register_File  (Renamed)
// ====================================================================
module Register_File(clk, Reset, RegFileRead, RegFileWrite,
                    Datain,
                    AddressR1, AddressR2, AddressR3, AddressW,
                    Dataout1, Dataout2, Dataout3);

    input  clk, Reset, RegFileRead, RegFileWrite;
    input  [7:0] Datain;
    input  [3:0] AddressR1, AddressR2, AddressR3, AddressW;
    output wire [7:0] Dataout1, Dataout2, Dataout3;

    wire [15:0] write_enable_vector;
    wire [7:0]  R[0:15];
    wire [7:0]  read_data1_comb, read_data2_comb, read_data3_comb;

    decoder4to16_withE decoder_inst(AddressW, RegFileWrite, write_enable_vector);

    genvar gi;
    generate
        for (gi = 0; gi < 16; gi = gi + 1)
            eightbitRegwithLoad register_inst(clk, Reset, write_enable_vector[gi], Datain, R[gi]);
    endgenerate

    Mux16to1_8bit_withoutE mux_read1(AddressR1,
        R[15],R[14],R[13],R[12],R[11],R[10],R[9],R[8],
        R[7], R[6], R[5], R[4], R[3], R[2], R[1], R[0], read_data1_comb);

    Mux16to1_8bit_withoutE mux_read2(AddressR2,
        R[15],R[14],R[13],R[12],R[11],R[10],R[9],R[8],
        R[7], R[6], R[5], R[4], R[3], R[2], R[1], R[0], read_data2_comb);

    Mux16to1_8bit_withoutE mux_read3(AddressR3, 
        R[15],R[14],R[13],R[12],R[11],R[10],R[9],R[8],
        R[7], R[6], R[5], R[4], R[3], R[2], R[1], R[0], read_data3_comb);

    eightbitRegwithLoad buffer_read1(clk, Reset, RegFileRead, read_data1_comb, Dataout1);
    eightbitRegwithLoad buffer_read2(clk, Reset, RegFileRead, read_data2_comb, Dataout2);
    eightbitRegwithLoad buffer_read3(clk, Reset, RegFileRead, read_data3_comb, Dataout3); 
endmodule

// ====================================================================
// Instruction_Memory_4096 (Renamed)
// ====================================================================
module Instruction_Memory_4096(clk, Reset, Address, InstRead,
                   Dataout,
                   OPCODE, AddressW, AddressR1, AddressR2, AddressR3,
                   ADDR, IMMDATA, ADDR4);
    input  clk, Reset, InstRead;
    input  [11:0] Address;
    output reg [31:0] Dataout;
    output reg [7:0]  OPCODE;
    output reg [3:0]  AddressW, AddressR1, AddressR2, AddressR3;
    output reg [11:0] ADDR;
    output reg [7:0]  IMMDATA;
    output reg [3:0]  ADDR4;

    reg [31:0] instmemory [0:4095];
    integer i;

    initial begin
        for (i = 0; i < 4096; i = i + 1)
            instmemory[i] = 32'h0;
        $readmemb("memfile.txt", instmemory);
    end

    always @(posedge clk) begin
        if (InstRead) begin
            Dataout   <= instmemory[Address];
            OPCODE    <= instmemory[Address][31:24];
            AddressW  <= instmemory[Address][23:20];
            AddressR1 <= instmemory[Address][19:16];
            AddressR2 <= instmemory[Address][15:12];
            AddressR3 <= instmemory[Address][3:0];
            ADDR      <= instmemory[Address][11:0];
            IMMDATA   <= instmemory[Address][7:0];
            ADDR4     <= instmemory[Address][3:0];
        end
    end
endmodule

// ====================================================================
// SRAM256  (NEW – 8-bit address, used inside Stack256)
// ====================================================================
module SRAM_256(clk, Reset, Address, SRAMRead, SRAMWrite, Datain, Dataout);
    input  clk, Reset, SRAMRead, SRAMWrite;
    input  [7:0] Address;
    input  [11:0] Datain;
    output reg [11:0] Dataout;
    reg [11:0] mem [0:255];
    integer i;
    always @(posedge clk) begin
        if (Reset) begin
            for (i = 0; i < 256; i = i + 1) mem[i] <= 12'h000;
        end else if (SRAMWrite) begin
            mem[Address] <= Datain;
        end else if (SRAMRead) begin
            Dataout <= mem[Address];
        end
    end
endmodule

// ====================================================================
// SRAM_4096  (Renamed)
// ====================================================================
module SRAM_4096(clk, Reset, Address, SRAMRead, SRAMWrite, Datain, Dataout);
    input  clk, Reset, SRAMRead, SRAMWrite;
    input  [11:0] Address;
    input  [7:0]  Datain;
    output reg [7:0] Dataout;
    reg [7:0] mem [0:4095];
    integer i;
    always @(posedge clk) begin
        if (Reset) begin
            for (i = 0; i < 4096; i = i + 1) mem[i] <= 8'h00;
        end else if (SRAMWrite) begin
            mem[Address] <= Datain;
        end else if (SRAMRead) begin
            Dataout <= mem[Address];
        end
    end
endmodule

// ====================================================================
// Stack_256  (Renamed)
// ====================================================================
module Stack_256(clk, Reset, StackRead, StackWrite, Datain, Dataout);
    input  clk, Reset, StackRead, StackWrite;
    input  [11:0] Datain;
    output wire [11:0] Dataout;

    // 8rd-bit stack pointer (points to next free slot; empty = 0)
    reg [7:0] SP;
    wire [7:0] SP_write_addr;   
    wire [7:0] SP_read_addr;    
    wire [7:0] sram_addr;
    wire sram_wr;

    assign SP_write_addr = SP;
    assign SP_read_addr  = SP - 8'h01;

    assign sram_addr = StackWrite ? SP_write_addr : SP_read_addr;
    assign sram_wr   = StackWrite;

    always @(posedge clk) begin
        if (Reset)
            SP <= 8'h00;
        else if (StackWrite)
            SP <= SP + 8'h01;   
        else if (StackRead)
            SP <= SP - 8'h01;   
    end

    SRAM_256 sram(clk, Reset, sram_addr, StackRead, sram_wr, Datain, Dataout);
endmodule

module and_8bit (a, b, y);
    input  [7:0] a, b;
    output [7:0] y;
    assign y = a & b;
endmodule

module or_8bit (a, b, y);
    input  [7:0] a, b;
    output [7:0] y;
    assign y = a | b;
endmodule

module xor_8bit (a, b, y);
    input  [7:0] a, b;
    output [7:0] y;
    assign y = a ^ b;
endmodule

module left_shift_8bit(A, Y);
    input  [7:0] A;
    output wire [7:0] Y;
    assign Y = {A[6:0], 1'b0};
endmodule

module right_shift_8bit(A, Y, sign_extend);
    input  [7:0] A;
    input  sign_extend;
    output wire [7:0] Y;
    assign Y = sign_extend ? {A[7], A[7:1]} : {1'b0, A[7:1]};
endmodule

module rotate_right_8bit(A, Y, C_in, rotate_carry);
    input  [7:0] A;
    input  C_in, rotate_carry;
    output wire [7:0] Y;
    assign Y = rotate_carry ? {C_in, A[7:1]} : {A[0], A[7:1]};
endmodule

module rotate_left_8bit(A, Y, C_in, rotate_carry);
    input  [7:0] A;
    input  C_in, rotate_carry;
    output wire [7:0] Y;
    assign Y = rotate_carry ? {A[6:0], C_in} : {A[6:0], A[7]};
endmodule

// ------------------------------------------------------------------
// Mux25to1_1bit_behavioral_fallback
// Simple 2-to-1 mux: selects I1 (carry_from_shifter) when S=1,
// else I0 (Cout_AS).  Named with legacy name used in ALU8.
// ------------------------------------------------------------------
module Mux25to1_1bit_behavioral_fallback(I1, I0, S, Y);
    input  I1, I0, S;
    output wire Y;
    assign Y = S ? I1 : I0;
endmodule

// ====================================================================
// ALU8  –  8-bit ALU for 32-bit RISC Processor (2026 Spec)
// Two always blocks:
//   1. Combinational  – operation selection via case(Opcode)
//   2. Sequential     – registered outputs + flags on posedge clk / Reset
// Port interface matches specification exactly.
// ====================================================================
module ALU8(
    input  clk,
    input  Reset,
    input  [7:0] Operand1,
    input  [7:0] Operand2,
    input  [7:0] Opcode,
    input  ALUSave,
    input  ZflagSave,
    input  CflagSave,
    output reg Zflag,
    output reg Cflag,
    output reg [7:0] ALUout,
    output reg [7:0] ALUout2
);

    // -----------------------------------------------------------------
    // Combinational result wires
    // -----------------------------------------------------------------
    reg  [7:0]  result;      // primary 8-bit result (combinational)
    reg  [15:0] result16;    // 16-bit product for UMULT
    reg         c_out;       // carry out (combinational)
    reg         z_out;       // zero flag (combinational)
    reg         write_alu;   // suppress ALUout write for CMP/CMPI
    reg  [8:0]  add_bus;     // 9-bit adder bus to capture carry

    // -----------------------------------------------------------------
    // 1  COMBINATIONAL BLOCK – operation selection
    // -----------------------------------------------------------------
    always @(*) begin
        // Safe defaults (prevent latches)
        result    = 8'h00;
        result16  = 16'h0000;
        c_out     = 1'b0;
        z_out     = 1'b0;
        write_alu = 1'b1;
        add_bus   = 9'h000;

        case (Opcode)

            // ---- ARITHMETIC ------------------------------------------
            8'h01: begin   // ADD   RD = RS1 + RS2
                add_bus = {1'b0, Operand1} + {1'b0, Operand2};
                result  = add_bus[7:0];
                c_out   = add_bus[8];
            end

            8'h02: begin   // ADDI  RD = RS1 + IMM
                add_bus = {1'b0, Operand1} + {1'b0, Operand2};
                result  = add_bus[7:0];
                c_out   = add_bus[8];
            end

            8'h03: begin   // ADDC  RD = RS1 + RS2 + C
                add_bus = {1'b0, Operand1} + {1'b0, Operand2} + {8'h00, Cflag};
                result  = add_bus[7:0];
                c_out   = add_bus[8];
            end

            8'h04: begin   // SUB   RS1 - RS2  (two’s complement: A + ~B + 1)
                add_bus = {1'b0, Operand1} + {1'b0, (~Operand2)} + 9'h001;
                result  = add_bus[7:0];
                c_out   = add_bus[8]; // Carry=1 means No Borrow
            end

            8'h05: begin   // SUBI  RS1 - IMM
                add_bus = {1'b0, Operand1} + {1'b0, (~Operand2)} + 9'h001;
                result  = add_bus[7:0];
                c_out   = add_bus[8];
            end

            8'h06: begin   // SUBC  RS1 - RS2 - Borrow (A + ~B + Cflag)
                add_bus = {1'b0, Operand1} + {1'b0, (~Operand2)} + {8'h00, Cflag};
                result  = add_bus[7:0];
                c_out   = add_bus[8];
            end

            8'h07: begin   // CMP   flags only, no write to ALUout
                add_bus   = {1'b0, Operand1} + {1'b0, (~Operand2)} + 9'h001;
                result    = add_bus[7:0];
                c_out     = add_bus[8];
                write_alu = 1'b0;   // suppress ALUout update
            end

            8'h08: begin   // CMPI  flags only
                add_bus   = {1'b0, Operand1} + {1'b0, (~Operand2)} + 9'h001;
                result    = add_bus[7:0];
                c_out     = add_bus[8];
                write_alu = 1'b0;   // suppress ALUout update
            end

            // ---- LOGICAL ---------------------------------------------
            8'h09: begin   // AND
                result = Operand1 & Operand2;
                c_out  = 1'b0;
            end

            8'h0A: begin   // ANDI
                result = Operand1 & Operand2;
                c_out  = 1'b0;
            end

            8'h0B: begin   // OR
                result = Operand1 | Operand2;
                c_out  = 1'b0;
            end

            8'h0C: begin   // ORI
                result = Operand1 | Operand2;
                c_out  = 1'b0;
            end

            8'h0D: begin   // XOR
                result = Operand1 ^ Operand2;
                c_out  = 1'b0;
            end

            8'h0E: begin   // XORI
                result = Operand1 ^ Operand2;
                c_out  = 1'b0;
            end

            // ---- INC / DEC -------------------------------------------
            8'h0F: begin   // INC
                add_bus = {1'b0, Operand1} + 9'h001;
                result  = add_bus[7:0];
                c_out   = add_bus[8];
            end

            8'h10: begin   // DEC
                add_bus = {1'b0, Operand1} + 9'h1FF;  // A + (-1)
                result  = add_bus[7:0];
                c_out   = add_bus[8];
            end

            // ---- MOVE ------------------------------------------------
            8'h11: begin   // MOVI  RD = IMM  (Operand2 carries immediate)
                result = Operand2;
                c_out  = 1'b0;
            end

            8'h12: begin   // MOV   RD = RS1
                result = Operand1;
                c_out  = 1'b0;
            end

            8'h13: begin   // MOVF  RD = {Cflag, 6'b000000, Zflag}
                result = {Cflag, 6'b000000, Zflag};
                c_out  = 1'b0;
            end

            // ---- SHIFT -----------------------------------------------
            8'h18: begin   // LRS  logical right shift
                c_out  = Operand1[0];               // LSB → carry
                result = {1'b0, Operand1[7:1]};
            end

            8'h19: begin   // ARS  arithmetic right shift (sign-extend)
                c_out  = Operand1[0];               // LSB → carry
                result = {Operand1[7], Operand1[7:1]};
            end

            8'h1A: begin   // LLS  logical left shift
                c_out  = Operand1[7];               // MSB → carry
                result = {Operand1[6:0], 1'b0};
            end

            // ---- ROTATE ----------------------------------------------
            8'h1B: begin   // ROTR  rotate right (circular, no carry)
                c_out  = Operand1[0];
                result = {Operand1[0], Operand1[7:1]};
            end

            8'h1C: begin   // ROTL  rotate left (circular, no carry)
                c_out  = Operand1[7];
                result = {Operand1[6:0], Operand1[7]};
            end

            8'h1D: begin   // ROTRC  rotate right through carry
                c_out  = Operand1[0];
                result = {Cflag, Operand1[7:1]};
            end

            8'h1E: begin   // ROTLC  rotate left through carry
                c_out  = Operand1[7];
                result = {Operand1[6:0], Cflag};
            end

            // ---- MULTIPLY --------------------------------------------
            8'h27: begin   // UMULT  unsigned 8×8 → 16-bit
                result16 = Operand1 * Operand2;
                result   = result16[7:0];   // low byte → ALUout
                c_out    = 1'b0;
                // high byte → ALUout2 (handled in sequential block)
            end

            // ---- DEFAULT ---------------------------------------------
            default: begin
                result    = 8'h00;
                c_out     = 1'b0;
                write_alu = 1'b0;
            end

        endcase

        // Zero flag: 1 when result == 0
        z_out = ~|result;
    end

    // -----------------------------------------------------------------
    // 2  SEQUENTIAL BLOCK – registered outputs + flags
    // -----------------------------------------------------------------
    always @(posedge clk or posedge Reset) begin
        if (Reset) begin
            ALUout  <= 8'h00;
            ALUout2 <= 8'h00;
            Zflag   <= 1'b0;
            Cflag   <= 1'b0;
        end else begin
            // ALUout: update only when ALUSave=1 AND not CMP/CMPI
            if (ALUSave && write_alu)
                ALUout <= result;

            // ALUout2: high byte of multiply, only for UMULT (0x27)
            if (ALUSave && (Opcode == 8'h27))
                ALUout2 <= result16[15:8];

            // Zero flag
            if (ZflagSave)
                Zflag <= z_out;

            // Carry flag
            if (CflagSave)
                Cflag <= c_out;
        end
    end

endmodule

// ------------------------------------------------------------------
// Mux2to1_1bit – Structural 2-to-1 multiplexer
// ------------------------------------------------------------------
module Mux2to1_1bit(I1, I0, S, Y);
    input I1, I0, S;
    output wire Y;
    assign Y = S ? I1 : I0;
endmodule

// ====================================================================
// Timing_Generator  (UNCHANGED logic, renamed)
// ====================================================================
module Timing_Generator(clk, Reset, T0, T1, T2, T3, T4);
    input  clk, Reset;
    output reg T0, T1, T2, T3, T4;
    reg [2:0] counter;
    always @(posedge clk or posedge Reset)
        if (Reset) counter <= 3'b000;
        else       counter <= (counter == 3'b100) ? 3'b000 : counter + 3'b001;
    always @(*) begin
        T0 = (counter == 3'b000);
        T1 = (counter == 3'b001);
        T2 = (counter == 3'b010);
        T3 = (counter == 3'b011);
        T4 = (counter == 3'b100);
    end
endmodule

// ====================================================================
// Program_Counter  (Renamed)
// ====================================================================
module Program_Counter(clk, Reset, PCenable, PCupdate, Address, PC);
    input  clk, Reset, PCenable, PCupdate;
    input  [11:0] Address;
    output reg [11:0] PC;
    always @(posedge clk) begin
        if (Reset)       PC <= 12'h000;
        else if (PCupdate) PC <= Address;
        else if (PCenable) PC <= PC + 12'h001;
    end
endmodule

module Comparator_4bit(A, B, Equal);
    input [3:0] A, B;
    output Equal;
    assign Equal = (A == B);
endmodule

// ====================================================================
// Input_Port  (Structural)
// ====================================================================
module Input_Port(clk, Reset, INportRead,
                  InpExtWorld1, InpExtWorld2, InpExtWorld3, InpExtWorld4,
                  Address, Dataout);
    input  clk, Reset, INportRead;
    input  [7:0] InpExtWorld1, InpExtWorld2, InpExtWorld3, InpExtWorld4;
    input  [3:0] Address;
    output wire [7:0] Dataout;

    wire [7:0] data1, data2, data3, data4, selected_data;
    wire eq0, eq1, eq2, eq3;

    eightbitRegwithLoad input_register1(clk, Reset, 1'b1, InpExtWorld1, data1);
    eightbitRegwithLoad input_register2(clk, Reset, 1'b1, InpExtWorld2, data2);
    eightbitRegwithLoad input_register3(clk, Reset, 1'b1, InpExtWorld3, data3);
    eightbitRegwithLoad input_register4(clk, Reset, 1'b1, InpExtWorld4, data4);

    Comparator_4bit comparator0(Address, 4'h0, eq0);
    Comparator_4bit comparator1(Address, 4'h1, eq1);
    Comparator_4bit comparator2(Address, 4'h2, eq2);
    Comparator_4bit comparator3(Address, 4'h3, eq3);

    // Using a 4-to-1 mux for selection based on bits [1:0] of address
    Mux4to1_8bit_withoutE selection_mux(Address[1:0], data4, data3, data2, data1, selected_data); 

    eightbitRegwithLoad output_buffer_reg(clk, Reset, INportRead, selected_data, Dataout);
endmodule

// ====================================================================
// Output_Port  (Structural)
// ====================================================================
module Output_Port(clk, Reset, OUTportWrite, Address, Datain,
                  OutExtWorld1, OutExtWorld2, OutExtWorld3, OutExtWorld4);
    input  clk, Reset, OUTportWrite;
    input  [3:0] Address;
    input  [7:0] Datain;
    output wire [7:0] OutExtWorld1, OutExtWorld2, OutExtWorld3, OutExtWorld4;

    wire e8, e9, eA, eB;
    Comparator_4bit c8(Address, 4'h8, e8);
    Comparator_4bit c9(Address, 4'h9, e9);
    Comparator_4bit cA(Address, 4'hA, eA);
    Comparator_4bit cB(Address, 4'hB, eB);

    eightbitRegwithLoad r8(clk, Reset, OUTportWrite & e8, Datain, OutExtWorld1);
    eightbitRegwithLoad r9(clk, Reset, OUTportWrite & e9, Datain, OutExtWorld2);
    eightbitRegwithLoad rA(clk, Reset, OUTportWrite & eA, Datain, OutExtWorld3);
    eightbitRegwithLoad rB(clk, Reset, OUTportWrite & eB, Datain, OutExtWorld4);
endmodule

// ====================================================================
// ControlLogic  (MODIFIED – 8-bit Opcode, full 43-instruction coverage)
//
// Five-cycle sequence:
//  T0 : IF  – InstRead, PCenable
//  T1 : ID  – RegFileRead
//  T2 : EX  – ALUSave, ZflagSave, CflagSave (when applicable)
//  T3 : MEM – SRAMRead / SRAMWrite / StackRead / StackWrite /
//             INportRead / OUTportWrite
//  T4 : WB  – RegFileWrite
// ====================================================================
module Control_Logic(clk, Reset, T0, T1, T2, T3, T4, Zflag, Cflag, OPCODE, PCenable, PCupdate, InstRead, RegFileRead, RegFileWrite, ALUSave, ZflagSave, CflagSave, SRAMRead, SRAMWrite, StackRead, StackWrite, INportRead, OUTportWrite);
    input  clk, Reset;
    input  T0, T1, T2, T3, T4;
    input  Zflag, Cflag;
    input  [7:0] OPCODE;
    output wire PCenable, PCupdate;
    output wire InstRead;
    output wire RegFileRead, RegFileWrite;
    output wire ALUSave, ZflagSave, CflagSave;
    output wire SRAMRead, SRAMWrite;
    output wire StackRead, StackWrite;
    output wire INportRead, OUTportWrite;

    // Vectors for each control signal (1 bit per OPCODE)
    wire [255:0] V_RegFileRead, V_RegFileWrite, V_ALUSave, V_ZflagSave, V_CflagSave, V_SRAMRead, V_SRAMWrite, V_StackRead, V_StackWrite, V_INportRead, V_OUTportWrite;

    assign V_RegFileRead = (256'h1 << 8'h01) | (256'h1 << 8'h02) | (256'h1 << 8'h03) | (256'h1 << 8'h04) | (256'h1 << 8'h05) | (256'h1 << 8'h06) | (256'h1 << 8'h07) | (256'h1 << 8'h08) | 
                           (256'h1 << 8'h09) | (256'h1 << 8'h0A) | (256'h1 << 8'h0B) | (256'h1 << 8'h0C) | (256'h1 << 8'h0D) | (256'h1 << 8'h0E) |
                           (256'h1 << 8'h0F) | (256'h1 << 8'h10) | (256'h1 << 8'h12) | (256'h1 << 8'h15) | (256'h1 << 8'h16) | (256'h1 << 8'h17) |
                           (256'h1 << 8'h18) | (256'h1 << 8'h19) | (256'h1 << 8'h1A) | (256'h1 << 8'h1B) | (256'h1 << 8'h1C) | (256'h1 << 8'h1D) | (256'h1 << 8'h1E) |
                           (256'h1 << 8'h25) | (256'h1 << 8'h27) | (256'h1 << 8'h29);

    assign V_ALUSave = (256'h1 << 8'h01) | (256'h1 << 8'h02) | (256'h1 << 8'h03) | (256'h1 << 8'h04) | (256'h1 << 8'h05) | (256'h1 << 8'h06) | (256'h1 << 8'h07) | (256'h1 << 8'h08) |
                       (256'h1 << 8'h09) | (256'h1 << 8'h0A) | (256'h1 << 8'h0B) | (256'h1 << 8'h0C) | (256'h1 << 8'h0D) | (256'h1 << 8'h0E) |
                       (256'h1 << 8'h0F) | (256'h1 << 8'h10) | (256'h1 << 8'h11) | (256'h1 << 8'h12) | (256'h1 << 8'h13) |
                       (256'h1 << 8'h18) | (256'h1 << 8'h19) | (256'h1 << 8'h1A) | (256'h1 << 8'h1B) | (256'h1 << 8'h1C) | (256'h1 << 8'h1D) | (256'h1 << 8'h1E) |
                       (256'h1 << 8'h27);

    assign V_ZflagSave = (256'h1 << 8'h01) | (256'h1 << 8'h02) | (256'h1 << 8'h03) | (256'h1 << 8'h04) | (256'h1 << 8'h05) | (256'h1 << 8'h06) | (256'h1 << 8'h07) | (256'h1 << 8'h08) |
                         (256'h1 << 8'h09) | (256'h1 << 8'h0A) | (256'h1 << 8'h0B) | (256'h1 << 8'h0C) | (256'h1 << 8'h0D) | (256'h1 << 8'h0E) |
                         (256'h1 << 8'h0F) | (256'h1 << 8'h10) |
                         (256'h1 << 8'h18) | (256'h1 << 8'h19) | (256'h1 << 8'h1A) | (256'h1 << 8'h1B) | (256'h1 << 8'h1C) | (256'h1 << 8'h1D) | (256'h1 << 8'h1E);

    assign V_CflagSave = (256'h1 << 8'h01) | (256'h1 << 8'h02) | (256'h1 << 8'h03) | (256'h1 << 8'h04) | (256'h1 << 8'h05) | (256'h1 << 8'h06) | (256'h1 << 8'h07) | (256'h1 << 8'h08) |
                         (256'h1 << 8'h18) | (256'h1 << 8'h19) | (256'h1 << 8'h1A) | (256'h1 << 8'h1B) | (256'h1 << 8'h1C) | (256'h1 << 8'h1D) | (256'h1 << 8'h1E);

    assign V_RegFileWrite = (256'h1 << 8'h01) | (256'h1 << 8'h02) | (256'h1 << 8'h03) | (256'h1 << 8'h04) | (256'h1 << 8'h05) | (256'h1 << 8'h06) |
                            (256'h1 << 8'h09) | (256'h1 << 8'h0A) | (256'h1 << 8'h0B) | (256'h1 << 8'h0C) | (256'h1 << 8'h0D) | (256'h1 << 8'h0E) |
                            (256'h1 << 8'h0F) | (256'h1 << 8'h10) | (256'h1 << 8'h11) | (256'h1 << 8'h12) | (256'h1 << 8'h13) |
                            (256'h1 << 8'h14) | (256'h1 << 8'h15) |
                            (256'h1 << 8'h18) | (256'h1 << 8'h19) | (256'h1 << 8'h1A) | (256'h1 << 8'h1B) | (256'h1 << 8'h1C) | (256'h1 << 8'h1D) | (256'h1 << 8'h1E) |
                            (256'h1 << 8'h26) | (256'h1 << 8'h27) | (256'h1 << 8'h28);

    assign V_SRAMRead = (256'h1 << 8'h14) | (256'h1 << 8'h15);
    assign V_SRAMWrite = (256'h1 << 8'h16) | (256'h1 << 8'h17);
    assign V_StackRead = (256'h1 << 8'h24) | (256'h1 << 8'h26);
    assign V_StackWrite = (256'h1 << 8'h23) | (256'h1 << 8'h25) | (256'h1 << 8'h27);
    assign V_INportRead = (256'h1 << 8'h28);
    assign V_OUTportWrite = (256'h1 << 8'h29);

    // Control signal mux instantiations
    assign InstRead = T0;
    assign PCenable = T0;

    Mux256to1_1bit RegFileRead_Mux_inst(V_RegFileRead, OPCODE, T1, RegFileRead);
    Mux256to1_1bit ALUSave_Mux_inst(V_ALUSave, OPCODE, T2, ALUSave);
    Mux256to1_1bit ZflagSave_Mux_inst(V_ZflagSave, OPCODE, T2, ZflagSave);
    Mux256to1_1bit CflagSave_Mux_inst(V_CflagSave, OPCODE, T2, CflagSave);
    Mux256to1_1bit SRAMRead_Mux_inst(V_SRAMRead, OPCODE, T3, SRAMRead);
    Mux256to1_1bit SRAMWrite_Mux_inst(V_SRAMWrite, OPCODE, T3, SRAMWrite);
    Mux256to1_1bit StackRead_Mux_inst(V_StackRead, OPCODE, T3, StackRead);
    Mux256to1_1bit StackWrite_Mux_inst(V_StackWrite, OPCODE, T3, StackWrite);
    Mux256to1_1bit INportRead_Mux_inst(V_INportRead, OPCODE, T3, INportRead);
    Mux256to1_1bit OUTportWrite_Mux_inst(V_OUTportWrite, OPCODE, T3, OUTportWrite);
    Mux256to1_1bit RegFileWrite_Mux_inst(V_RegFileWrite, OPCODE, T4, RegFileWrite);
    
    // PCupdate vector needs logic for jumps
    wire jump_z  = Zflag;
    wire jump_nz = ~Zflag;
    wire jump_c  = Cflag;
    wire jump_nc = ~Cflag;

    Mux256to1_1bit PCupdate_Mux_inst(
        {213'b0, 1'b1, 5'b0, 1'b1, 1'b1, jump_nc, jump_c, jump_nz, jump_z, 31'b0}, 
        OPCODE, T4, PCupdate
    );

endmodule
