`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 20:46:39
// Design Name: 
// Module Name: ZA_LMS8pip
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


module ZA_LMS8pip(
    input clk,
    input rst,
    input signed [15:0] x_in,
    output signed [15:0] y_out,
    output signed [15:0] err,
    output signed [15:0] w0,w1,w2,w3,w4,w5,w6,w7
    );
    
reg signed [15:0] x[0:7],x_t[0:6],xL[0:7],xL_t[0:6],d_delay[0:7],x_delay[0:7], w[0:7],errL[0:6];
reg signed [34:0] acc[0:7];
wire signed [31:0] m[0:7];
wire signed [15:0] d_in,wn[0:7],upd[0:7],sgn[0:7],za[0:7];
integer i;
genvar j;
parameter signed [15:0] rho = 16'sd4;

fir_filter fir(
    .clk(clk),
    .rst(rst),
    .x_in(x_in),
    .d_in(d_in)
    ); 

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 8; i = i + 1) begin
            d_delay[i] <= 0;
        end
    end else begin                                      
        d_delay[0] <= d_in;         
        for (i = 1; i < 8; i = i + 1) begin
            d_delay[i] <= d_delay[i-1];
        end   
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 8; i = i + 1) begin
            x_delay[i] <= 0;
        end
    end else begin
        x_delay[0] <= x_in;         
        for (i = 1; i < 8; i = i + 1) begin
            x_delay[i] <= x_delay[i-1];
        end   
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst)
    begin
        for(i=0;i<8;i=i+1)
        begin
            x[i] <= 0;
            xL[i] <= 0;
        end
        for(i=0;i<7;i=i+1)
        begin
            x_t[i] <= 0;
            xL_t[i] <= 0;
        end
    end
    else
    begin
        for(i=7;i>0;i=i-1)
        begin
            x[i] <= x_t[i-1];
            x_t[i-1] <= x[i-1];
            xL[i] <= xL_t[i-1];
            xL_t[i-1] <= xL[i-1];
        end 
        x[0] <= x_in;
        xL[0] <= x_delay[7];
    end
end

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        for(i=0;i<8;i=i+1)
        begin
            acc[i] <= 0;
        end
    end
    else
    begin
        acc[0] <= w[0]*x[0];
        for (i = 1; i < 8; i = i + 1)
        begin
            acc[i] <= acc[i-1] + (w[i] * x[i]);
        end
    end
end 

assign y_out = acc[7][27:12];
assign err = d_delay[7] - y_out;

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        for (i = 0; i < 7; i = i + 1)
        begin
            errL[i] <= 0;
        end
    end
    else
    begin
        errL[0] <= err;
        for (i = 1; i < 7; i = i + 1)
        begin
            errL[i] <= errL[i-1];
        end
    end
end

generate
        assign m[0]    = err * xL[0];
        assign upd[0]  = m[0] >>> 17;
        assign sgn[0]  = (w[0] > 0) ? 16'sd1 : (w[0] < 0) ? -16'sd1 : 16'sd0;
        assign za[0]   = (rho * sgn[0]) >>> 12;
        assign wn[0]   = w[0] + upd[0] - za[0];

    for (j = 1; j < 8; j = j + 1) begin : zalms
        assign m[j]    = errL[j-1] * xL[j];
        assign upd[j]  = m[j] >>> 17;
        assign sgn[j]  = (w[j] > 0) ? 16'sd1 : (w[j] < 0) ? -16'sd1 : 16'sd0;
        assign za[j]   = (rho * sgn[j]) >>> 12;
        assign wn[j]   = w[j] + upd[j] - za[j];
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