`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date: 2020/11/08 22:02:34
// Design Name: BNN Processor
// Module Name: BPUG
// Project Name: BNN Processor
// Target Devices: Zed Board
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module BPUG(
    input clk,
    input rst,
    input [7:0]data_in,// input data, both image and weight
    input wire[7:0] instruction_in,//instructions bus
    output wire signed[7:0][6:0] bpu_out//calculation of BPU
    );
    
    wire[4:0] instruction;//calculation instruction to BPU
    assign instruction =instruction_in[4:0];
    wire data_sel;//image data selector
    assign data_sel = instruction_in[5];// =0, [6:0]of image data; =1, [7:1] of image data
    //data_sel at the same time controls the address of pooling
    wire[1:0]en;//img and wgt shift register's enable signal, the 0nd bit for wgt, 1st bit for img
    assign en = instruction_in[7:6];
    ////////////////////////////////////////////////////////////
    
    wire [7:0]img_in;//image data in
    assign img_in = data_in;
    wire [6:0]wgt_in;//weight data in
    assign wgt_in = data_in[6:0];
    
    wire img_en;//enable the image shift register
    assign img_en = en[1];
    wire wgt_en;//enable the weight shift register
    assign wgt_en = en[0];
    
    reg [55:0][6:0]wgt;// wgt[56] is this layer's bias, the rest is
    always@(posedge clk)begin
        if(rst)begin
            wgt <= 0;
        end
        else if(wgt_en) begin
            wgt <= {wgt[54:0],wgt_in};//shift register
        end
    end
    
    reg [7:0][6:0]img_reg;//register to store image data
    always@(posedge clk)begin
        if(rst) begin
            img_reg<=0;
        end
        else if(en[1])begin
            img_reg[0] <= {img_reg[0][5:0],img_in[0]};//another shift register
            img_reg[1] <= {img_reg[1][5:0],img_in[1]};
            img_reg[2] <= {img_reg[2][5:0],img_in[2]};
            img_reg[3] <= {img_reg[3][5:0],img_in[3]};
            img_reg[4] <= {img_reg[4][5:0],img_in[4]};
            img_reg[5] <= {img_reg[5][5:0],img_in[5]};
            img_reg[6] <= {img_reg[6][5:0],img_in[6]};
            img_reg[7] <= {img_reg[7][5:0],img_in[7]};
        end
    end
    
    wire [6:0][6:0]img;
    assign img = data_sel? img_reg[7:1]:img_reg[6:0];
    
    //instance
    BPU bpu0(.clk(clk),
    .rst(rst),
    .instruction(instruction),
    .img(img),
    .wgt(wgt[6:0]),
    .popcnt_add(bpu_out[0]));
    BPU bpu1(.clk(clk),
    .rst(rst),
    .instruction(instruction),
    .img(img),
    .wgt(wgt[13:7]),
    .popcnt_add(bpu_out[1]));
    BPU bpu2(.clk(clk),
    .rst(rst),
    .instruction(instruction),
    .img(img),
    .wgt(wgt[20:14]),
    .popcnt_add(bpu_out[2]));
    BPU bpu3(.clk(clk),
    .rst(rst),
    .instruction(instruction),
    .img(img),
    .wgt(wgt[27:21]),
    .popcnt_add(bpu_out[3]));
    BPU bpu4(.clk(clk),
    .rst(rst),
    .instruction(instruction),
    .img(img),
    .wgt(wgt[34:28]),
    .popcnt_add(bpu_out[4]));
    BPU bpu5(.clk(clk),
    .rst(rst),
    .instruction(instruction),
    .img(img),
    .wgt(wgt[41:35]),
    .popcnt_add(bpu_out[5]));
    BPU bpu6(.clk(clk),
    .rst(rst),
    .instruction(instruction),
    .img(img),
    .wgt(wgt[48:42]),
    .popcnt_add(bpu_out[6]));
    BPU bpu7(.clk(clk),
    .rst(rst),
    .instruction(instruction),
    .img(img),
    .wgt(wgt[55:49]),
    .popcnt_add(bpu_out[7]));
    
endmodule