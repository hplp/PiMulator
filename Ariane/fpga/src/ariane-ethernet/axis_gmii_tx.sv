/*

Copyright (c) 2015-2018 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

origin	https://github.com/alexforencich/verilog-ethernet.git
commit ebe31e811cee9db615a7d5ec8472f972f3368b90
Author: Alex Forencich <alex@alexforencich.com>
Date:   Thu Nov 8 13:15:47 2018 -0800

Modified by Jonathan Kimmitt to extract CRC bytes
 
lfsr submodule renamed rgmii_lfsr to avoid name clash with main project
*/

// Language: Verilog 2001

/*
 * AXI4-Stream GMII frame transmitter (AXI in, GMII out)
 */
module axis_gmii_tx #
(
    parameter ENABLE_PADDING = 1,
    parameter MIN_FRAME_LENGTH = 64
)
(
    input  wire        clk,
    input  wire        rst,

    /*
     * AXI input
     */
    input  wire [7:0]  s_axis_tdata,
    input  wire        s_axis_tvalid,
    output wire        s_axis_tready,
    input  wire        s_axis_tlast,
    input  wire        s_axis_tuser,

    /*
     * GMII output
     */
    output wire [7:0]  gmii_txd,
    output wire        gmii_tx_en,
    output wire        gmii_tx_er,

    /*
     * Control
     */
    input  wire        clk_enable,
    input  wire        mii_select,

    /*
     * Configuration
     */
    input wire [7:0]  ifg_delay,

    /* debug */
    output reg [31:0] fcs_reg
);

localparam [7:0]
    ETH_PRE = 8'h55,
    ETH_SFD = 8'hD5;

localparam [2:0]
    STATE_IDLE = 3'd0,
    STATE_PREAMBLE = 3'd1,
    STATE_PAYLOAD = 3'd2,
    STATE_LAST = 3'd3,
    STATE_PAD = 3'd4,
    STATE_FCS = 3'd5,
    STATE_WAIT_END = 3'd6,
    STATE_IFG = 3'd7;

reg [2:0] state_reg, state_next;

// datapath control signals
reg reset_crc;
reg update_crc;

reg [7:0] s_tdata_reg, s_tdata_next, ifg_reg, ifg_next;

reg mii_odd_reg, mii_odd_next;
reg [3:0] mii_msn_reg, mii_msn_next;

reg [15:0] frame_ptr_reg, frame_ptr_next;

reg [7:0] gmii_txd_reg, gmii_txd_next;
reg gmii_tx_en_reg, gmii_tx_en_next;
reg gmii_tx_er_reg, gmii_tx_er_next;

reg s_axis_tready_reg, s_axis_tready_next;
reg [31:0] crc_state, fcs_next;   

wire [31:0] crc_next;

assign s_axis_tready = s_axis_tready_reg;

assign gmii_txd = gmii_txd_reg;
assign gmii_tx_en = gmii_tx_en_reg;
assign gmii_tx_er = gmii_tx_er_reg;

rgmii_lfsr #(
    .LFSR_WIDTH(32),
    .LFSR_POLY(32'h4c11db7),
    .LFSR_CONFIG("GALOIS"),
    .LFSR_FEED_FORWARD(0),
    .REVERSE(1),
    .DATA_WIDTH(8),
    .STYLE("AUTO")
)
eth_crc_8 (
    .data_in(s_tdata_reg),
    .state_in(crc_state),
    .data_out(),
    .state_out(crc_next)
);

always @* begin
    state_next = STATE_IDLE;

    reset_crc = 1'b0;
    update_crc = 1'b0;

    mii_odd_next = mii_odd_reg;
    mii_msn_next = mii_msn_reg;

    frame_ptr_next = frame_ptr_reg;
    fcs_next = fcs_reg;
    ifg_next = ifg_reg;

    s_axis_tready_next = 1'b0;

    s_tdata_next = s_tdata_reg;

    gmii_txd_next = 8'd0;
    gmii_tx_en_next = 1'b0;
    gmii_tx_er_next = 1'b0;

    if (!clk_enable) begin
        // clock disabled - hold state and outputs
        gmii_txd_next = gmii_txd_reg;
        gmii_tx_en_next = gmii_tx_en_reg;
        gmii_tx_er_next = gmii_tx_er_reg;
        state_next = state_reg;
    end else if (mii_select && mii_odd_reg) begin
        // MII odd cycle - hold state, output MSN
        mii_odd_next = 1'b0;
        gmii_txd_next = {4'd0, mii_msn_reg};
        gmii_tx_en_next = gmii_tx_en_reg;
        gmii_tx_er_next = gmii_tx_er_reg;
        state_next = state_reg;
    end else begin
        case (state_reg)
            STATE_IDLE: begin
                // idle state - wait for packet
                reset_crc = 1'b1;
                mii_odd_next = 1'b0;

                if (s_axis_tvalid) begin
                    mii_odd_next = 1'b1;
                    frame_ptr_next = 16'd1;
                    gmii_txd_next = ETH_PRE;
                    gmii_tx_en_next = 1'b1;
                    state_next = STATE_PREAMBLE;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
            STATE_PREAMBLE: begin
                // send preamble
                reset_crc = 1'b1;

                mii_odd_next = 1'b1;
                frame_ptr_next = frame_ptr_reg + 16'd1;

                gmii_txd_next = ETH_PRE;
                gmii_tx_en_next = 1'b1;

                if (frame_ptr_reg == 16'd6) begin
                    s_axis_tready_next = 1'b1;
                    s_tdata_next = s_axis_tdata;
                    state_next = STATE_PREAMBLE;
                end else if (frame_ptr_reg == 16'd7) begin
                    // end of preamble; start payload
                    frame_ptr_next = 16'd0;
                    if (s_axis_tready_reg) begin
                        s_axis_tready_next = 1'b1;
                        s_tdata_next = s_axis_tdata;
                    end
                    gmii_txd_next = ETH_SFD;
                    state_next = STATE_PAYLOAD;
                end else begin
                    state_next = STATE_PREAMBLE;
                end
            end
            STATE_PAYLOAD: begin
                // send payload

                update_crc = 1'b1;
                s_axis_tready_next = 1'b1;

                mii_odd_next = 1'b1;
                frame_ptr_next = frame_ptr_reg + 16'd1;

                gmii_txd_next = s_tdata_reg;
                gmii_tx_en_next = 1'b1;

                s_tdata_next = s_axis_tdata;

                if (s_axis_tvalid) begin
                    if (s_axis_tlast) begin
                        s_axis_tready_next = !s_axis_tready_reg;
                        if (s_axis_tuser) begin
                            gmii_tx_er_next = 1'b1;
                            frame_ptr_next = 1'b0;
                            state_next = STATE_IFG;
                        end else begin
                            state_next = STATE_LAST;
                        end
                    end else begin
                        state_next = STATE_PAYLOAD;
                    end
                end else begin
                    // tvalid deassert, fail frame
                    gmii_tx_er_next = 1'b1;
                    frame_ptr_next = 16'd0;
                    state_next = STATE_WAIT_END;
                end
            end
            STATE_LAST: begin
                // last payload word

                update_crc = 1'b1;

                mii_odd_next = 1'b1;
                frame_ptr_next = frame_ptr_reg + 16'd1;

                gmii_txd_next = s_tdata_reg;
                gmii_tx_en_next = 1'b1;

                if (ENABLE_PADDING && frame_ptr_reg < MIN_FRAME_LENGTH-5) begin
                    s_tdata_next = 8'd0;
                    state_next = STATE_PAD;
                end else begin
                    frame_ptr_next = 16'd0;
                    state_next = STATE_FCS;
                end
            end
            STATE_PAD: begin
                // send padding

                update_crc = 1'b1;
                mii_odd_next = 1'b1;
                frame_ptr_next = frame_ptr_reg + 16'd1;

                gmii_txd_next = 8'd0;
                gmii_tx_en_next = 1'b1;

                s_tdata_next = 8'd0;

                if (frame_ptr_reg < MIN_FRAME_LENGTH-5) begin
                    state_next = STATE_PAD;
                end else begin
                    frame_ptr_next = 16'd0;
                    state_next = STATE_FCS;
                end
            end
            STATE_FCS: begin
                // send FCS

                mii_odd_next = 1'b1;
                frame_ptr_next = frame_ptr_reg + 16'd1;

                case (frame_ptr_reg)
                    2'd0: gmii_txd_next = ~crc_state[7:0];
                    2'd1: gmii_txd_next = ~crc_state[15:8];
                    2'd2: gmii_txd_next = ~crc_state[23:16];
                    2'd3: gmii_txd_next = ~crc_state[31:24];
                    default:;
                endcase
                gmii_tx_en_next = 1'b1;

                if (frame_ptr_reg < 3) begin
                    state_next = STATE_FCS;
                end else begin
                    frame_ptr_next = 16'd0;
                    fcs_next = crc_state;
                    state_next = STATE_IFG;
                end
            end
            STATE_WAIT_END: begin
                // wait for end of frame

                reset_crc = 1'b1;

                mii_odd_next = 1'b1;
                frame_ptr_next = frame_ptr_reg + 16'd1;
                s_axis_tready_next = 1'b1;

                if (s_axis_tvalid) begin
                    if (s_axis_tlast) begin
                        s_axis_tready_next = 1'b0;
                        ifg_next = 8'b0;
                            state_next = STATE_IFG;
                    end else begin
                        state_next = STATE_WAIT_END;
                    end
                end else begin
                    state_next = STATE_WAIT_END;
                end
            end
            STATE_IFG: begin
                // send IFG

                reset_crc = 1'b1;

                mii_odd_next = 1'b1;
                frame_ptr_next = frame_ptr_reg + 16'd1;

                if (ifg_reg < ifg_delay-1) begin
                    ifg_next = ifg_reg + 1;
                    state_next = STATE_IFG;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
        endcase

        if (mii_select) begin
            mii_msn_next = gmii_txd_next[7:4];
            gmii_txd_next[7:4] = 4'd0;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        state_reg <= STATE_IDLE;

        frame_ptr_reg <= 16'd0;

        s_axis_tready_reg <= 1'b0;

        gmii_tx_en_reg <= 1'b0;
        gmii_tx_er_reg <= 1'b0;

        crc_state <= 32'hFFFFFFFF;
        fcs_reg <= 32'hFFFFFFFF;
    end else begin
        state_reg <= state_next;

        frame_ptr_reg <= frame_ptr_next;

        s_axis_tready_reg <= s_axis_tready_next;

        gmii_tx_en_reg <= gmii_tx_en_next;
        gmii_tx_er_reg <= gmii_tx_er_next;

        fcs_reg <= fcs_next;
        ifg_reg <= ifg_next;
        // datapath
        if (reset_crc) begin
            crc_state <= 32'hFFFFFFFF;
        end else if (update_crc) begin
            crc_state <= crc_next;
        end
    end

    mii_odd_reg <= mii_odd_next;
    mii_msn_reg <= mii_msn_next;

    s_tdata_reg <= s_tdata_next;

    gmii_txd_reg <= gmii_txd_next;
end

endmodule
