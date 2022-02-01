`timescale 1ns / 1ps

// testbench for Bank module
module testbnch_Bank(
);

    // parameters for Bank module
    parameter DEVICE_WIDTH = 4;
    parameter COLWIDTH = 10;
    parameter CHWIDTH = 5;

    // time for a clk cycle
    localparam tCK = 0.75;

    // registers and wire for in and out of Bank module
    logic clk;
    logic  [0:0]             rd_o_wr;
    logic  [DEVICE_WIDTH-1:0]dqin;
    wire [DEVICE_WIDTH-1:0]dqout;
    logic  [CHWIDTH-1:0]row;
    logic  [COLWIDTH-1:0]column;

    logic  [DEVICE_WIDTH-1:0]data[8-1:0];

    integer i; // loop variable

    // dut instance of Bank
    Bank #(.DEVICE_WIDTH(DEVICE_WIDTH),
    .COLWIDTH(COLWIDTH),
    .CHWIDTH(CHWIDTH)) dut (
        .clk(clk),
        .rd_o_wr(rd_o_wr),
        .dqin(dqin),
        .dqout(dqout),
        .row(row),
        .column(column)
    );

    // clk behavior
    always #(tCK*0.5) clk = ~clk;

    initial
    begin
        // init
        clk = 1;
        rd_o_wr = 0;
        row = 0;
        column = 0;
        dqin = 0;
        #tCK

        // write
        for (i = 0; i < 8; i = i + 1)
            begin
                rd_o_wr = 1;
                row = 1;
                column = i;
                dqin = $random;
                data[column] = dqin;
                #tCK;
            end

        rd_o_wr = 0;
        row = 0;
        dqin = 0;
        #tCK;

        // read
        for (i = 0; i < 8; i = i + 1)
            begin
                rd_o_wr = 0;
                row = 1;
                column = i;
                #tCK;
                $display(dqout, data[column]);
                assert (dqout == data[column]);
            end

        row = 0;
        column = 0;
        #(2*tCK);
        $finish();
    end;

endmodule