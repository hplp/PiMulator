// Created by fizzim.pl version 5.20 on 2020:10:05 at 18:44:10 (www.fizzim.com)

module cache (
  output logic Check,
  output logic [4:0] cRowId,
  output logic hold,
  input logic MemOK,
  input logic RD,
  input logic [16:0] RowId,
  input logic WR,
  input logic clk,
  input logic rst
  );
  
  typedef struct packed {
    logic valid;
    logic dirty;
    logic [5-1:0] tag;
    logic [17-1:0] rowaddr;
    logic [64-1:0] addr;
  }cache_tag_type;
  
  cache_tag_type cache_tag [0:32-1];
  logic hit = 1;
  
  // state bits
  enum logic [1:0] {
    Idle     = 2'b00, 
    CheckRow = 2'b01, 
    Miss     = 2'b10, 
    RDWR     = 2'b11
  } state, nextstate;
  
  
  // comb always block
  always_comb begin
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      Idle    : begin
        if (RD || WR) begin
          nextstate = CheckRow;
        end
        else begin
          nextstate = Idle;
        end
      end
      CheckRow: begin // row valid or not
        if (hit) begin
          nextstate = RDWR;
        end
        else if (!hit) begin
          nextstate = Miss;
        end
      end
      Miss    : begin
        if (MemOK) begin
          nextstate = RDWR;
        end
        else begin
          nextstate = Miss;
        end
      end
      RDWR    : begin
        if (!(RD || WR)) begin
          nextstate = Idle;
        end
        else begin
          nextstate = RDWR;
        end
      end
    endcase
  end
  
  // Assign reg'd outputs to state bits
  
  // sequential always block
  always_ff @(posedge clk or posedge rst) begin
    if (rst)
    state <= Idle;
    else
    state <= nextstate;
  end
  
  // datapath sequential always block
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      Check <= 0;
      cRowId[4:0] <= 5'b0;
      hold <= 0;
    end
    else begin
      Check <= 0; // default
      cRowId[4:0] <= 5'b0; // default
      hold <= 0; // default
      case (nextstate)
        CheckRow: begin
          Check <= 1;
          for (int i = 0; i < 32; i++) begin
            if(RowId == cache_tag[i].rowaddr)
            cRowId = cache_tag[i].tag;
          end
        end
        Miss    : begin
          hold <= 1;
        end
      endcase
    end
  end
endmodule
