`timescale 1ns / 1ps

// A BankGroup module model that bundles multiple Bank modules.
// parameter `BAWIDTH` determines the number of Banks
module BankGroup
    #(parameter BAWIDTH = 2,
    parameter COLWIDTH = 10,
    parameter DEVICE_WIDTH = 4,
    parameter CHWIDTH = 5,
    
    localparam BANKSPERGROUP = 2**BAWIDTH
    )
    (
    input logic clk,
    // the Bank inputs are bundled together for easy indexing
    input logic  [0:0]             rd_o_wr [BANKSPERGROUP-1:0],
    input logic  [DEVICE_WIDTH-1:0]dqin    [BANKSPERGROUP-1:0],
    output logic [DEVICE_WIDTH-1:0]dqout   [BANKSPERGROUP-1:0],
    input logic  [CHWIDTH-1:0]     row     [BANKSPERGROUP-1:0],
    input logic  [COLWIDTH-1:0]    column  [BANKSPERGROUP-1:0]
    );
    
    // generating BANKSPERGROUP Bank instances and mapping the bi'th wires
    genvar bi;
    generate
        for (bi = 0; bi < BANKSPERGROUP; bi=bi+1)
        begin:B
            Bank #(.DEVICE_WIDTH(DEVICE_WIDTH),
            .COLWIDTH(COLWIDTH),
            .CHWIDTH(CHWIDTH)) Bi (
            .clk(clk),
            .rd_o_wr(rd_o_wr[bi]),
            .dqin(dqin[bi]),
            .dqout(dqout[bi]),
            .row(row[bi]),
            .column(column[bi])
            );
        end
    endgenerate
    
endmodule

// References
// https://www.verilogpro.com/systemverilog-arrays-synthesizable/