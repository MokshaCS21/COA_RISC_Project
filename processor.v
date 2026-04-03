`timescale 100ns/1ps
`include "subcomponents.v"

// ====================================================================
// RISC_Processor  –  2026 Edition (CSE302)
// Five-cycle non-pipelined RISC processor, 32-bit instruction format
// ====================================================================
module RISC_Processor(clk, Reset,
                      InpExtWorld1, InpExtWorld2, InpExtWorld3, InpExtWorld4,
                      OutExtWorld1, OutExtWorld2, OutExtWorld3, OutExtWorld4);

    input  clk, Reset;
    input  [7:0] InpExtWorld1, InpExtWorld2, InpExtWorld3, InpExtWorld4;
    output wire [7:0] OutExtWorld1, OutExtWorld2, OutExtWorld3, OutExtWorld4;

    // ----------------------------------------------------------------
    // Internal signals
    // ----------------------------------------------------------------
    wire [11:0] Program_Counter_Value;           
    wire [31:0] Instruction_Word;  

    // Decoded fields from Instruction_Memory
    wire [7:0]  OPCODE;
    wire [3:0]  Address_Write, Address_Read1, Address_Read2, Address_Read3;
    wire [11:0] Direct_Address;         
    wire [7:0]  Immediate_Data;      
    wire [3:0]  Address_IO_Port;        

    // Register file outputs
    wire [7:0] Register_Data_1;      
    wire [7:0] Register_Data_2;      
    wire [7:0] Register_Data_3;      
    
    // ALU outputs
    wire [7:0] ALU_Output_Primary;       
    wire [7:0] ALU_Output_Secondary;       
    wire       Zero_Flag, Carry_Flag;

    // Memory / Stack / IO outputs
    wire [7:0]  SRAM_Data_Output;
    wire [11:0] Stack_Data_Output;
    wire [7:0]  Input_Port_Data_Output;

    // Control signals
    wire PC_Enable, PC_Update;
    wire Instruction_Memory_Read;
    wire Register_File_Read, Register_File_Write;
    wire ALU_Save, Zero_Flag_Save, Carry_Flag_Save;
    wire SRAM_Read, SRAM_Write;
    wire Stack_Read, Stack_Write;
    wire Input_Port_Read, Output_Port_Write;

    // Timing
    wire Cycle_T0, Cycle_T1, Cycle_T2, Cycle_T3, Cycle_T4;

    // ----------------------------------------------------------------
    // Timing Generator
    // ----------------------------------------------------------------
    Timing_Generator Timing_Generator_inst(clk, Reset, Cycle_T0, Cycle_T1, Cycle_T2, Cycle_T3, Cycle_T4);

    // ----------------------------------------------------------------
    // Control Logic
    // ----------------------------------------------------------------
    Control_Logic Control_Logic_inst(
        .clk             (clk),
        .Reset           (Reset),
        .T0              (Cycle_T0), .T1(Cycle_T1), .T2(Cycle_T2), .T3(Cycle_T3), .T4(Cycle_T4),
        .Zflag           (Zero_Flag),
        .Cflag           (Carry_Flag),
        .OPCODE          (OPCODE),
        .PCenable        (PC_Enable),
        .PCupdate        (PC_Update),
        .InstRead        (Instruction_Memory_Read),
        .RegFileRead     (Register_File_Read),
        .RegFileWrite    (Register_File_Write),
        .ALUSave         (ALU_Save),
        .ZflagSave       (Zero_Flag_Save),
        .CflagSave       (Carry_Flag_Save),
        .SRAMRead        (SRAM_Read),
        .SRAMWrite       (SRAM_Write),
        .StackRead       (Stack_Read),
        .StackWrite      (Stack_Write),
        .INportRead      (Input_Port_Read),
        .OUTportWrite    (Output_Port_Write)
    );

    // ----------------------------------------------------------------
    // Program Counter Logic
    // ----------------------------------------------------------------
    wire [11:0] Program_Counter_Target_Address;
    
    Mux256to1_12bit Program_Counter_Target_Mux_inst(
        .I({
            2556'h0,                  // [255:43]  - 213 entries
            Direct_Address,           // [42]      - 0x2A JMP
            60'h0,                    // [41:37]   - 5 entries (PUSH, POP, UMULT, IN, OUT)
            Stack_Data_Output,        // [36]      - 0x24 RET
            Direct_Address,           // [35]      - 0x23 CALL
            Direct_Address,           // [34]      - 0x22 JMPNC
            Direct_Address,           // [33]      - 0x21 JMPC
            Direct_Address,           // [32]      - 0x20 JMPNZ
            Direct_Address,           // [31]      - 0x1F JMPZ
            372'h0                    // [30:0]    - 31 entries
        }),
        .S(OPCODE),
        .E(1'b1),
        .Y(Program_Counter_Target_Address)
    );

    Program_Counter Program_Counter_inst(
        .clk      (clk),
        .Reset    (Reset),
        .PCenable (PC_Enable),
        .PCupdate (PC_Update),
        .Address  (Program_Counter_Target_Address),
        .PC       (Program_Counter_Value)
    );

    // ----------------------------------------------------------------
    // Instruction Memory
    // ----------------------------------------------------------------
    Instruction_Memory_4096 Instruction_Memory_inst(
        .clk      (clk),
        .Reset    (Reset),
        .Address  (Program_Counter_Value),
        .InstRead (Instruction_Memory_Read),
        .Dataout  (Instruction_Word),
        .OPCODE   (OPCODE),
        .AddressW (Address_Write),
        .AddressR1(Address_Read1),
        .AddressR2(Address_Read2),
        .AddressR3(Address_Read3),
        .ADDR     (Direct_Address),
        .IMMDATA  (Immediate_Data),
        .ADDR4    (Address_IO_Port)
    );

    // ----------------------------------------------------------------
    // Register File
    // ----------------------------------------------------------------
    wire [7:0] Register_File_Data_In;
    Register_File Register_File_inst(
        .clk         (clk),
        .Reset       (Reset),
        .RegFileRead (Register_File_Read),
        .RegFileWrite(Register_File_Write),
        .Datain      (Register_File_Data_In),
        .AddressR1   (Address_Read1),
        .AddressR2   (Address_Read2),
        .AddressR3   (Address_Read3),
        .AddressW    (Address_Write),
        .Dataout1    (Register_Data_1),
        .Dataout2    (Register_Data_2),
        .Dataout3    (Register_Data_3)
    );

    // ----------------------------------------------------------------
    // ALU Operand Selection
    // ----------------------------------------------------------------
    wire [7:0] ALU_Operand_2;
    Mux256to1_8bit ALU_Operand_2_Mux_inst(
        .I({
            1816'h0,                  // [255:29]  - 227 entries
            Register_Data_2,          // [28]      - 0x1C ROTL
            Register_Data_2,          // [27]      - 0x1B ROTR
            Register_Data_2,          // [26]      - 0x1A LLS
            Register_Data_2,          // [25]      - 0x19 ARS
            Register_Data_2,          // [24]      - 0x18 LRS
            Register_Data_1,          // [23]      - 0x17 STOREI
            8'h0,                     // [22]      - 0x16 STORE
            Immediate_Data,           // [21]      - 0x15 LOADI
            8'h0,                     // [20]      - 0x14 LOAD
            Register_Data_2,          // [19]      - 0x13 MOVF
            Register_Data_2,          // [18]      - 0x12 MOV
            Immediate_Data,           // [17]      - 0x11 MOVI
            Register_Data_2,          // [16]      - 0x10 DEC
            Register_Data_2,          // [15]      - 0x0F INC
            Immediate_Data,           // [14]      - 0x0E EXORI
            Register_Data_2,          // [13]      - 0x0D EXOR
            Immediate_Data,           // [12]      - 0x0C ORI
            Register_Data_2,          // [11]      - 0x0B OR
            Immediate_Data,           // [10]      - 0x0A ANDI
            Register_Data_2,          // [09]      - 0x09 AND
            Immediate_Data,           // [08]      - 0x08 CMPI
            Register_Data_2,          // [07]      - 0x07 CMP
            Register_Data_2,          // [06]      - 0x06 SUBC
            Immediate_Data,           // [05]      - 0x05 SUBI
            Register_Data_2,          // [04]      - 0x04 SUB
            Register_Data_2,          // [03]      - 0x03 ADDC
            Immediate_Data,           // [02]      - 0x02 ADDI
            Register_Data_2,          // [01]      - 0x01 ADD
            8'h0                      // [00]      - 0x00 NOP
        }),
        .S(OPCODE),
        .E(1'b1),
        .Y(ALU_Operand_2)
    );

    ALU8 ALU_inst(
        .clk       (clk),
        .Reset     (Reset),
        .Operand1  (Register_Data_1),
        .Operand2  (ALU_Operand_2),
        .Opcode    (OPCODE),
        .ALUSave   (ALU_Save),
        .ZflagSave (Zero_Flag_Save),
        .CflagSave (Carry_Flag_Save),
        .Zflag     (Zero_Flag),
        .Cflag     (Carry_Flag),
        .ALUout    (ALU_Output_Primary),
        .ALUout2   (ALU_Output_Secondary)
    );

    // ----------------------------------------------------------------
    // SRAM Data Memory
    // ----------------------------------------------------------------
    wire [11:0] Pointer_XP = {Register_Data_1[3:0], Register_Data_2};
    wire [11:0] SRAM_Address;
    wire [7:0]  SRAM_Data_In;

    Mux256to1_12bit SRAM_Address_Mux_inst(
        .I({
            2784'h0,                  // [255:24]  - 232 entries
            Pointer_XP,               // [23]      - 0x17 STOREI
            Direct_Address,           // [22]      - 0x16 STORE
            Pointer_XP,               // [21]      - 0x15 LOADI
            Direct_Address,           // [20]      - 0x14 LOAD
            240'h0                    // [19:0]    - 20 entries
        }),
        .S(OPCODE),
        .E(1'b1),
        .Y(SRAM_Address)
    );

    Mux256to1_8bit SRAM_Data_In_Mux_inst(
        .I({
            1856'h0,                  // [255:24]  - 232 entries
            Register_Data_3,          // [23]      - 0x17 STOREI
            Register_Data_1,          // [22]      - 0x16 STORE
            176'h0                    // [21:0]    - 22 entries
        }),
        .S(OPCODE),
        .E(1'b1),
        .Y(SRAM_Data_In)
    );

    SRAM_4096 SRAM_Data_Memory_inst(
        .clk      (clk),
        .Reset    (Reset),
        .Address  (SRAM_Address),
        .SRAMRead (SRAM_Read),
        .SRAMWrite(SRAM_Write),
        .Datain   (SRAM_Data_In),
        .Dataout  (SRAM_Data_Output)
    );

    // ----------------------------------------------------------------
    // Stack Memory
    // ----------------------------------------------------------------
    wire [11:0] Stack_Data_In;
    Mux256to1_12bit Stack_Data_In_Mux_inst(
        .I({
            2592'h0,                  // [255:40]  - 216 entries
            {4'h0, ALU_Output_Secondary}, // [39] - 0x27 UMULT
            12'h0,                    // [38]      - 0x26 POP
            {4'h0, Register_Data_1},  // [37]      - 0x25 PUSH
            12'h0,                    // [36]      - 0x24 RET
            Program_Counter_Value,    // [35]      - 0x23 CALL
            420'h0                    // [34:0]    - 35 entries
        }),
        .S(OPCODE),
        .E(1'b1),
        .Y(Stack_Data_In)
    );

    Stack_256 Stack_Memory_inst(
        .clk       (clk),
        .Reset     (Reset),
        .StackRead (Stack_Read),
        .StackWrite(Stack_Write),
        .Datain    (Stack_Data_In),
        .Dataout   (Stack_Data_Output)
    );

    // ----------------------------------------------------------------
    // Register Data In Selection
    // ----------------------------------------------------------------
    Mux256to1_8bit Register_Data_In_Mux_inst(
        .I({
            1720'h0,                  // [255:41]  - 215 entries
            Input_Port_Data_Output,   // [40]      - 0x28 IN
            ALU_Output_Primary,       // [39]      - 0x27 UMULT
            Stack_Data_Output[7:0],   // [38]      - 0x26 POP
            128'h0,                   // [37:31]   - 7 entries (PUSH, RET, CALL, JMPs, etc.)
            ALU_Output_Primary,       // [30]      - 0x1E ROTLC
            ALU_Output_Primary,       // [29]      - 0x1D ROTRC
            ALU_Output_Primary,       // [28]      - 0x1C ROTL
            ALU_Output_Primary,       // [27]      - 0x1B ROTR
            ALU_Output_Primary,       // [26]      - 0x1A LLS
            ALU_Output_Primary,       // [25]      - 0x19 ARS
            ALU_Output_Primary,       // [24]      - 0x18 LRS
            16'h0,                    // [23:22]   - STOREI, STORE (no write back)
            SRAM_Data_Output,         // [21]      - 0x15 LOADI
            SRAM_Data_Output,         // [20]      - 0x14 LOAD
            ALU_Output_Primary,       // [19]      - 0x13 MOVF
            ALU_Output_Primary,       // [18]      - 0x12 MOV
            ALU_Output_Primary,       // [17]      - 0x11 MOVI
            ALU_Output_Primary,       // [16]      - 0x10 DEC
            ALU_Output_Primary,       // [15]      - 0x0F INC
            ALU_Output_Primary,       // [14]      - 0x0E EXORI
            ALU_Output_Primary,       // [13]      - 0x0D EXOR
            ALU_Output_Primary,       // [12]      - 0x0C ORI
            ALU_Output_Primary,       // [11]      - 0x0B OR
            ALU_Output_Primary,       // [10]      - 0x0A ANDI
            ALU_Output_Primary,       // [09]      - 0x09 AND
            8'h0,                     // [08]      - 0x08 CMPI (no write back)
            8'h0,                     // [07]      - 0x07 CMP (no write back)
            ALU_Output_Primary,       // [06]      - 0x06 SUBC
            ALU_Output_Primary,       // [05]      - 0x05 SUBI
            ALU_Output_Primary,       // [04]      - 0x04 SUB
            ALU_Output_Primary,       // [03]      - 0x03 ADDC
            ALU_Output_Primary,       // [02]      - 0x02 ADDI
            ALU_Output_Primary,       // [01]      - 0x01 ADD
            8'h0                      // [00]      - NOP
        }),
        .S(OPCODE),
        .E(1'b1),
        .Y(Register_File_Data_In)
    );

    // ----------------------------------------------------------------
    // Input Port
    // ----------------------------------------------------------------
    Input_Port Input_Port_inst(
        .clk             (clk),
        .Reset           (Reset),
        .INportRead      (Input_Port_Read),
        .InpExtWorld1    (InpExtWorld1),
        .InpExtWorld2    (InpExtWorld2),
        .InpExtWorld3    (InpExtWorld3),
        .InpExtWorld4    (InpExtWorld4),
        .Address         (Address_IO_Port),
        .Dataout         (Input_Port_Data_Output)
    );

    // ----------------------------------------------------------------
    // Output Port
    // ----------------------------------------------------------------
    Output_Port Output_Port_inst(
        .clk             (clk),
        .Reset           (Reset),
        .OUTportWrite    (Output_Port_Write),
        .Address         (Address_IO_Port),
        .Datain          (Register_Data_1),
        .OutExtWorld1    (OutExtWorld1),
        .OutExtWorld2    (OutExtWorld2),
        .OutExtWorld3    (OutExtWorld3),
        .OutExtWorld4    (OutExtWorld4)
    );

endmodule