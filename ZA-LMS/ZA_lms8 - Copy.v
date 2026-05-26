`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.04.2026 13:04:18
// Design Name: 
// Module Name: ZA_lms8
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


module ZA_lms8(
    input clk,
    input rst,
    input signed [15:0] x_in,
    output signed [15:0] y_out,
    output signed [15:0] w0,w1,w2,w3,w4,w5,w6,w7,
    output signed [15:0] err
    );

reg signed [15:0] x[0:7], w[0:7];
wire signed [31:0] m[0:7];
wire signed [34:0] y;
wire signed [15:0] d_in,wn[0:7],upd[0:7],sgn[0:7],za[0:7];
integer i;
genvar j;
parameter signed [15:0] rho = 16'sd1;  // ~0.001

fir_filter fir(
    .clk(clk),
    .rst(rst),
    .x_in(x_in),
    .d_in(d_in)
    ); 


always@(posedge clk or posedge rst)
begin
    if(rst)
        for(i=0;i<8;i=i+1)
            x[i] <= 0;
    else
    begin
        for(i=7;i>0;i=i-1)
            x[i] <= x[i-1];
        
        x[0] <= x_in;
    end
end

assign y = w[0]*x[0] + w[1]*x[1] + w[2]*x[2] + w[3]*x[3]+ w[4]*x[4] + w[5]*x[5] + w[6]*x[6] + w[7]*x[7];
assign y_out = y[27:12];

assign err = d_in - y_out;
 
generate
    for (j = 0; j < 8; j = j + 1) begin : lms_calc
        assign m[j]   = err * x[j];    
        assign upd[j] = m[j] >>> 17;  // 12 + 5 , 12 for fixed point scaling & 4 for mu = 1/32 
        assign sgn[j] = (w[j] > 0) ? 16'sd1 : (w[j] < 0) ? -16'sd1 : 16'sd0;
        assign za[j] = (rho * sgn[j]) >>> 12;
        assign wn[j]  = w[j] + upd[j] - za[j]; // lms equation 
    end
endgenerate

always@(posedge clk or posedge rst)
begin
    if(rst)
        for(i=0;i<8;i=i+1)
            w[i] <= 0;
    else
        for(i=0;i<8;i=i+1)
            w[i] <= wn[i];
end

assign w0 = w[0];
assign w1 = w[1];
assign w2 = w[2];
assign w3 = w[3];
assign w4 = w[4];
assign w5 = w[5];
assign w6 = w[6];
assign w7 = w[7];

endmodule
