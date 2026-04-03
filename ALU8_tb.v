`timescale 1ns/1ps

module ALU8_tb();
    reg clk, Reset;
    reg [7:0] Operand1, Operand2, Opcode;
    reg ALUSave, ZflagSave, CflagSave;
    wire Zflag, Cflag;
    wire [7:0] ALUout, ALUout2;

    // Instantiate ALU8
    ALU8 dut(
        .clk(clk),
        .Reset(Reset),
        .Operand1(Operand1),
        .Operand2(Operand2),
        .Opcode(Opcode),
        .ALUSave(ALUSave),
        .ZflagSave(ZflagSave),
        .CflagSave(CflagSave),
        .Zflag(Zflag),
        .Cflag(Cflag),
        .ALUout(ALUout),
        .ALUout2(ALUout2)
    );

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        Reset = 1;
        Operand1 = 0;
        Operand2 = 0;
        Opcode = 0;
        ALUSave = 0;
        ZflagSave = 0;
        CflagSave = 0;

        #20 Reset = 0;
        #10;

        // --- TEST 1: ADD (01H) ---
        // 10 + 20 = 30, Z=0, C=0
        $display("Testing ADD: 10 + 20");
        Operand1 = 8'd10; Operand2 = 8'd20; Opcode = 8'h01;
        ALUSave = 1; ZflagSave = 1; CflagSave = 1;
        #10; // posedge
        ALUSave = 0; ZflagSave = 0; CflagSave = 0;
        #5;
        $display("Result: %d, Z: %b, C: %b", ALUout, Zflag, Cflag);

        // --- TEST 2: ADD with Carry (01H) ---
        // 250 + 10 = 260 -> 4, Z=0, C=1
        $display("Testing ADD (Carry): 250 + 10");
        Operand1 = 8'd250; Operand2 = 8'd10; Opcode = 8'h01;
        ALUSave = 1; ZflagSave = 1; CflagSave = 1;
        #10;
        ALUSave = 0; ZflagSave = 0; CflagSave = 0;
        #5;
        $display("Result: %d, Z: %b, C: %b", ALUout, Zflag, Cflag);

        // --- TEST 3: ADDC (03H) ---
        // Previous Carry was 1. 5 + 5 + 1 = 11
        $display("Testing ADDC: 5 + 5 + Carry(1)");
        Operand1 = 8'd5; Operand2 = 8'd5; Opcode = 8'h03;
        ALUSave = 1; ZflagSave = 1; CflagSave = 1;
        #10;
        ALUSave = 0; ZflagSave = 0; CflagSave = 0;
        #5;
        $display("Result: %d, Z: %b, C: %b", ALUout, Zflag, Cflag);

        // --- TEST 4: SUB (04H) ---
        // 20 - 10 = 10, Z=0, C=1 (No borrow)
        $display("Testing SUB: 20 - 10");
        Operand1 = 8'd20; Operand2 = 8'd10; Opcode = 8'h04;
        ALUSave = 1; ZflagSave = 1; CflagSave = 1;
        #10;
        ALUSave = 0; ZflagSave = 0; CflagSave = 0;
        #5;
        $display("Result: %d, Z: %b, C: %b", ALUout, Zflag, Cflag);

        // --- TEST 5: SUB (Borrow) (04H) ---
        // 10 - 20 = -10 (246), Z=0, C=0 (Borrow)
        $display("Testing SUB (Borrow): 10 - 20");
        Operand1 = 8'd10; Operand2 = 8'd20; Opcode = 8'h04;
        ALUSave = 1; ZflagSave = 1; CflagSave = 1;
        #10;
        ALUSave = 0; ZflagSave = 0; CflagSave = 0;
        #5;
        $display("Result: %d, Z: %b, C: %b", ALUout, Zflag, Cflag);

        // --- TEST 6: CMP (07H) ---
        // 15 - 15 = 0. ALUout should NOT change from 246. Z should be 1.
        $display("Testing CMP: 15 == 15");
        Operand1 = 8'd15; Operand2 = 8'd15; Opcode = 8'h07;
        ALUSave = 1; ZflagSave = 1; CflagSave = 1;
        #10;
        ALUSave = 0; ZflagSave = 0; CflagSave = 0;
        #5;
        $display("Result: %d (Should stay 246), Z: %b, C: %b", ALUout, Zflag, Cflag);

        // --- TEST 7: UMULT (27H) ---
        // 20 * 10 = 200 (ALUout=200, ALUout2=0)
        $display("Testing UMULT: 20 * 10");
        Operand1 = 8'd20; Operand2 = 8'd10; Opcode = 8'h27;
        ALUSave = 1; ZflagSave = 1; CflagSave = 1;
        #10;
        ALUSave = 0; ZflagSave = 0; CflagSave = 0;
        #5;
        $display("Result Low: %d, High: %d", ALUout, ALUout2);

        // --- TEST 8: UMULT Large ---
        // 255 * 2 = 510 (0x01FE -> ALUout=254, ALUout2=1)
        $display("Testing UMULT: 255 * 2");
        Operand1 = 8'd255; Operand2 = 8'd2; Opcode = 8'h27;
        ALUSave = 1; ZflagSave = 1; CflagSave = 1;
        #10;
        ALUSave = 0; ZflagSave = 0; CflagSave = 0;
        #5;
        $display("Result Low: %d, High: %d", ALUout, ALUout2);

        // --- TEST 9: Shift (18H Logical Right) ---
        // 8'b00000001 >> 1 = 0, C=1
        $display("Testing LRS: 1 >> 1");
        Operand1 = 8'b00000001; Opcode = 8'h18;
        ALUSave = 1; ZflagSave = 1; CflagSave = 1;
        #10;
        ALUSave = 0; ZflagSave = 0; CflagSave = 0;
        #5;
        $display("Result: %b, Z: %b, C: %b", ALUout, Zflag, Cflag);

        // --- TEST 10: MOVF (13H) ---
        // Should load {C, 000000, Z}. Current C=1, Z=1.
        $display("Testing MOVF: Load flags");
        Opcode = 8'h13;
        ALUSave = 1; ZflagSave = 1; CflagSave = 1;
        #10;
        ALUSave = 0; ZflagSave = 0; CflagSave = 0;
        #5;
        $display("Result: %b", ALUout);

        $display("=== Unit Tests Complete ===");
        $finish;
    end

endmodule
