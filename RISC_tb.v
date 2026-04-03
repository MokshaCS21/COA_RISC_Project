`timescale 100ns/1ps
`include "processor.v"

// ====================================================================
// Testbench for RISCprocessor (2026 Edition)
// ====================================================================
module testbench();
    reg [7:0] InpExtWorld1, InpExtWorld2, InpExtWorld3, InpExtWorld4;
    wire [7:0] OutExtWorld1, OutExtWorld2, OutExtWorld3, OutExtWorld4;
    reg clk, Reset;

    RISC_Processor dut(clk, Reset,
                      InpExtWorld1, InpExtWorld2, InpExtWorld3, InpExtWorld4,
                      OutExtWorld1, OutExtWorld2, OutExtWorld3, OutExtWorld4);

    // 50 MHz clock (period = 20 time units)
    always #10 clk = ~clk;

    initial begin
        clk          = 1'b0;
        InpExtWorld1 = 8'h42;   // Input port 0H = 0x42
        InpExtWorld2 = 8'h10;
        InpExtWorld3 = 8'h20;
        InpExtWorld4 = 8'h30;

        $dumpfile("Wavedump.vcd");
        $dumpvars(0, testbench);

        // Assert reset for 5 clock cycles
        Reset = 1'b1;
        #100;
        Reset = 1'b0;

        // Run for 2000 time units (~100 cycles)
        #2000;
        $display("=== Simulation Complete ===");
        $display("OutExtWorld1 = %h", OutExtWorld1);
        $display("OutExtWorld2 = %h", OutExtWorld2);
        $display("OutExtWorld3 = %h", OutExtWorld3);
        $display("OutExtWorld4 = %h", OutExtWorld4);
        $finish;
    end
endmodule