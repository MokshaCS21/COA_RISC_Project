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
    // 1️⃣ COMBINATIONAL BLOCK – operation selection
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
            8'h11: begin   // MOVI  RD = IMM
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
    // 2️⃣ SEQUENTIAL BLOCK – registered outputs + flags
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
