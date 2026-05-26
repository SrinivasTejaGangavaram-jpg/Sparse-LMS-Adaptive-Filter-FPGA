`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2026 15:13:06
// Design Name: 
// Module Name: fir_filter
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


module fir_filter
(
    input clk,
    input rst,
    input signed [15:0] x_in,
    output signed [15:0] d_in
);
    parameter signed [15:0] w0 = 16'sd2458;  //  0.6
    parameter signed [15:0] w1 = -16'sd410;  // -0.1
    parameter signed [15:0] w2 = 16'sd1638;  //  0.4
    parameter signed [15:0] w3 = 16'sd205;   //  0.05
    parameter signed [15:0] w4 = -16'sd819;  // -0.2
    parameter signed [15:0] w5 = 16'sd614;   //  0.15
    parameter signed [15:0] w6 = -16'sd2048; // -0.5
    parameter signed [15:0] w7 = 16'sd1229;  //  0.3
    
    reg signed [15:0] xn[0:7];
    wire signed [31:0] y;
    integer i;
    
    always@(posedge clk)
    begin
        if(rst)
        begin
            for(i=0;i<8;i=i+1)
                xn[i] <= 0;
                
        end 
        
        else
        begin
            for(i=7;i>0;i=i-1)
                xn[i] <= xn[i-1];
                
            xn[0] <= x_in; 
        end
    end
    assign y = w0*xn[0] + w1*xn[1] + w2*xn[2] + w3*xn[3] + w4*xn[4] + w5*xn[5] + w6*xn[6] + w7*xn[7];
    assign d_in = y[27:12];
    
endmodule
