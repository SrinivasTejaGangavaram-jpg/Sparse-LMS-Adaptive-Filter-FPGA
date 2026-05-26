`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.04.2026 14:08:55
// Design Name: 
// Module Name: RZA_lms8
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

module RZA_lms8(
    input  clk,
    input  rst,
    input  signed [15:0] x_in,
    output signed [15:0] y_out,
    output signed [15:0] w0, w1, w2, w3, w4, w5, w6, w7,
    output signed [15:0] err
);
    reg  signed [15:0] x[0:7];
    reg  signed [15:0] w[0:7];
    reg         [15:0] recip_lut[0:255];
 
    wire signed [34:0] y;
    wire signed [15:0] d_in;
    wire signed [15:0] wn  [0:7];
    wire signed [31:0] m   [0:7];
    wire signed [15:0] upd [0:7];
    wire        [15:0] abs_w [0:7];
    wire        [18:0] denom [0:7];
    wire        [15:0] recip [0:7];
    wire signed [31:0] rza1  [0:7];
    wire signed [15:0] rza   [0:7];
 
    integer i;
    genvar  j;
 
    parameter signed [15:0] rho = 16'sd1;
 
    fir_filter fir(
        .clk  (clk),
        .rst  (rst),
        .x_in (x_in),
        .d_in (d_in)
    );
 
    always @(posedge clk or posedge rst) begin
        if (rst)
            for (i = 0; i < 8; i = i + 1) x[i] <= 0;
        else begin
            for (i = 7; i > 0; i = i - 1)
                x[i] <= x[i-1];
            x[0] <= x_in;
        end
    end
 
    assign y     = w[0]*x[0] + w[1]*x[1] + w[2]*x[2] + w[3]*x[3]
                 + w[4]*x[4] + w[5]*x[5] + w[6]*x[6] + w[7]*x[7];
    assign y_out = y[27:12];
    assign err   = d_in - y_out;
 
    initial begin
        $readmemh("recip_lut.txt", recip_lut);
    end
 
    generate
        for (j = 0; j < 8; j = j + 1) begin : rza_calc
            assign m[j]     = err * x[j];
            assign upd[j]   = m[j] >>> 17;
            assign abs_w[j] = w[j][15] ? (-w[j]) : w[j];
            assign denom[j] = 19'h01000 + ({3'b0, abs_w[j]} << 8);
            assign recip[j] = recip_lut[denom[j][18:11]];
            assign rza1[j]  = w[j][15]
                              ? -(rho * $signed({1'b0, recip[j]}))
                              :  (rho * $signed({1'b0, recip[j]}));
            assign rza[j]   = rza1[j] >>> 12;
            assign wn[j]    = w[j] + upd[j] - rza[j];
        end
    endgenerate
 
    always @(posedge clk or posedge rst) begin
        if (rst)
            for (i = 0; i < 8; i = i + 1) w[i] <= 0;
        else
            for (i = 0; i < 8; i = i + 1) w[i] <= wn[i];
    end
 
    assign w0 = w[0]; assign w1 = w[1];
    assign w2 = w[2]; assign w3 = w[3];
    assign w4 = w[4]; assign w5 = w[5];
    assign w6 = w[6]; assign w7 = w[7];
endmodule
