`timescale 1ns / 1ps

`define DDR4
// `define DDR3

// testbench for Bank module
module testbnch_CMD(
    );
    
    parameter ADDRWIDTH = 17;
    parameter COLWIDTH = 10;
    parameter BGWIDTH = 2;
    parameter BANKGROUPS = 2**BGWIDTH;
    parameter BAWIDTH = 2;
    parameter BL = 8; // Burst Length
    
    localparam BANKSPERGROUP = 2**BAWIDTH;
    
    // time for a clk cycle
    localparam tCK = 0.75;
    
    // registers and wire for in and out of CMD module
    logic cke; // Clock Enable; HIGH activates internal clock signals and device input buffers and output drivers
    logic cs_n; // Chip select; The memory looks at all the other inputs only if this is LOW todo: scale to more than 1 rank
    logic clk;
    `ifdef DDR4
    logic act_n;
    `endif
    `ifdef DDR3
    logic ras_n;
    logic cas_n;
    logic we_n;
    `endif
    logic [BGWIDTH-1:0] bg;
    logic [BAWIDTH-1:0] ba;
    logic [ADDRWIDTH-1:0] A;
    wire [ADDRWIDTH-1:0] RowId [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    wire [COLWIDTH-1:0] ColId [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    wire rd_o_wr [BANKGROUPS-1:0][BANKSPERGROUP-1:0];
    wire [18:0] commands;
    
    integer i; // loop variable
    
    // dut instance of Bank
    CMD #(.ADDRWIDTH(ADDRWIDTH),
    .COLWIDTH(COLWIDTH),
    .BGWIDTH(BGWIDTH),
    .BANKGROUPS(BANKGROUPS),
    .BAWIDTH(BAWIDTH), .BL(BL)) dut (
    .cke(cke), .cs_n(cs_n), .clk(clk), .act_n(act_n),
    `ifdef DDR3
    .ras_n(ras_n),
    .cas_n(cas_n),
    .we_n(we_n),
    `endif
    .bg(bg),
    .ba(ba), .A(A),
    .RowId(RowId), .ColId(ColId), .rd_o_wr(rd_o_wr), .commands(commands)
    );
    
    // clk behavior
    always #(tCK*0.5) clk = ~clk;
    
    initial
    begin
        // init
        clk = 1;
        cke = 1;
        cs_n = 0;
        act_n = 1; // no ACT
        A = {ADDRWIDTH{1'b0}};
        bg = 0;
        ba = 0;
        #(tCK*0.99) // use a propagation delay because of (suspected) bug in Vivado Simulator
        
        // activating
        act_n = 0;
        A = 17'b00000000000000001;
        ba = 1;
        #tCK;
        assert (dut.ACT == 1) $display("OK: ACT"); else $display(dut.ACT);
        assert (RowId[bg][ba] == A) $display("OK: RowId[bg][ba]"); else $display(RowId[bg][ba]);
        
        act_n = 1;
        A = 17'b00000000000000000;
        ba = 0;
        #tCK;
        
        // write test
        for (i = 0; i < BL; i = i + 1)
        begin
            A = (i==0)? 17'b10000000000001000 : 17'b00000000000000000;
            ba = (i==0)? 1:0;
            #tCK;
            assert ((dut.WR == 1) || (i!=0)) $display("OK: writing"); else $display(dut.WR);
            assert (dut.ColId[0][1] == 8+i) $display("OK: ColId[0][1] value"); else $display(dut.ColId[0][1]);
            assert (dut.Burst[0][1] == 1) $display("OK: Burst[0][1] value"); else $display(dut.Burst[0][1]);
            assert (dut.rd_o_wr[0][1] == 1) $display("OK: rd_o_wr[0][1] value"); else $display(dut.rd_o_wr[0][1]);
        end
        #tCK;
        
        // read test
        for (i = 0; i < BL; i = i + 1)
        begin
            A = (i==0)? 17'b10100000000001000 : 17'b00000000000000000;
            ba = (i==0)? 1:0;
            #tCK;
            assert ((dut.RD == 1) || (i!=0)) $display("OK: reading"); else $display(dut.RD);
            assert (dut.ColId[0][1] == 8+i) $display("OK: ColId[0][1] value"); else $display(dut.ColId[0][1]);
            assert (dut.Burst[0][1] == 1) $display("OK: Burst[0][1] value"); else $display(dut.Burst[0][1]);
            assert (dut.rd_o_wr[0][1] == 0) $display("OK: rd_o_wr[0][1] value"); else $display(dut.rd_o_wr[0][1]);
        end
        #tCK;
        
        // precharge
        A = 17'b01000000000000000;
        ba = 1;
        #tCK;
        assert ((dut.PR == 1) || (i!=0)) $display("OK: precharge"); else $display(dut.PR);
        assert (dut.Burst[0][1] == 0) $display("OK: Burst[0][1] value"); else $display(dut.Burst[0][1]);
        assert (dut.rd_o_wr[0][1] == 0) $display("OK: rd_o_wr[0][1] value"); else $display(dut.rd_o_wr[0][1]);
        
        // end
        A = 17'b00000000000000000;
        ba = 0;
        #tCK;
        $finish();
    end;
    
endmodule