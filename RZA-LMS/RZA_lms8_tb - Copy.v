`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.04.2026 14:07:36
// Design Name: 
// Module Name: RZA_lms8_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RZA_lms8_tb;
    reg  clk, rst;
    reg  signed [15:0] x_in;
    wire signed [15:0] y_out, err;
    wire signed [15:0] w0, w1, w2, w3, w4, w5, w6, w7;
    wire signed [15:0] d_in;
 
    reg  signed [15:0] input_data[0:2999];
    integer i, f;
 
    localparam SF = 2.0**-12.0;
 
    RZA_lms8 dut(
        .clk  (clk),
        .rst  (rst),
        .x_in (x_in),
        .y_out(y_out),
        .w0(w0), .w1(w1), .w2(w2), .w3(w3),
        .w4(w4), .w5(w5), .w6(w6), .w7(w7),
        .err  (err)
    );
 
    assign d_in = dut.fir.d_in;
 
    always #5 clk = ~clk;
 
    initial begin
        clk  = 0;
        rst  = 1;
        x_in = 0;
        $readmemb("sample_inputs.txt", input_data);
 
        f = $fopen("rza_lms8_outputs.txt", "w");
        $fwrite(f, "iter x d y err w0 w1 w2 w3 w4 w5 w6 w7\n");
 
        repeat(5) @(posedge clk);
        rst = 0;
 
        for (i = 0; i < 3000; i = i + 1) begin
            @(negedge clk);
            x_in = input_data[i];
            @(posedge clk);
            check_out();
            write_to_file();
        end
 
        repeat(20) @(posedge clk);
        $fclose(f);
        $finish;
    end
 
    task check_out;
    begin
        if (i % 5 == 0)
            $display("Time:%0t | Iter:%0d | x:%f | d:%f | y:%f | e:%f | w:[%f %f %f %f %f %f %f %f]",
                $time, i,
                x_in*SF, d_in*SF, y_out*SF, err*SF,
                w0*SF, w1*SF, w2*SF, w3*SF,
                w4*SF, w5*SF, w6*SF, w7*SF);
    end
    endtask
 
    task write_to_file;
    begin
        $fwrite(f, "%0d %f %f %f %f %f %f %f %f %f %f %f %f\n",
            i,
            x_in*SF, d_in*SF, y_out*SF, err*SF,
            w0*SF, w1*SF, w2*SF, w3*SF,
            w4*SF, w5*SF, w6*SF, w7*SF);
    end
    endtask
 
    initial begin
        $dumpfile("dump_RZA_lms8.vcd");
        $dumpvars(0, RZA_lms8_tb);
    end
endmodule
