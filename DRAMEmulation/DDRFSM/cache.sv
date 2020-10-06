// Created by fizzim.pl version 5.20 on 2020:10:06 at 16:33:52 (www.fizzim.com)

module cache #(
  parameter CHWIDTH = 5,
  parameter ADDRWIDTH = 17,
  
  localparam CHROWS = 2**CHWIDTH,
  localparam ROWS = 2**ADDRWIDTH
  )
  (
  output logic [CHWIDTH-1:0] cRowId,
  output logic hold,
  input logic RD,
  input logic [ADDRWIDTH-1:0] RowId,
  input logic WR,
  input logic clk,
  input logic rst,
  input logic sync
  );
  
  typedef struct packed {
    logic valid;
    logic dirty;
    logic [CHWIDTH-1:0] age; // for LRU
    logic [CHWIDTH-1:0] tag;
    logic [ADDRWIDTH-1:0] rowaddr;
    logic [64-1:0] addr;
  } cache_tag_type;
  
  cache_tag_type cache_tag [0:CHROWS-1];
  genvar idx;
  generate
    for (idx = 0; idx < CHROWS; idx++) begin
      initial cache_tag[idx].valid=0;
      initial cache_tag[idx].dirty=0;
      initial cache_tag[idx].age='0;
      initial cache_tag[idx].tag=idx;
      initial cache_tag[idx].rowaddr='0;
      initial cache_tag[idx].addr='0;
    end
  endgenerate
  logic hit=0, miss=0, newrow=0;
  
  // state bits
  enum logic [2:0] {
    Idle    = 3'b000, 
    RDCheck = 3'b001, 
    RDMiss  = 3'b010, 
    READ    = 3'b011, 
    WRCheck = 3'b100, 
    WRITE   = 3'b101, 
    WRMiss  = 3'b110
  } state, nextstate;
  
  
  // comb always block
  always_comb begin
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      Idle   : begin
        if (WR) begin
          nextstate = WRCheck;
        end
        else if (RD) begin
          nextstate = RDCheck;
        end
        else begin
          nextstate = Idle;
        end
      end
      RDCheck: begin
        if (miss) begin
          nextstate = RDMiss;
        end
        else if (hit) begin
          nextstate = READ;
        end
      end
      RDMiss : begin
        if (sync) begin
          nextstate = READ;
        end
        else begin
          nextstate = RDMiss;
        end
      end
      READ   : begin
        begin
          nextstate = Idle;
        end
      end
      WRCheck: begin
        if (miss) begin
          nextstate = WRMiss;
        end
        else if (hit) begin
          nextstate = WRITE;
        end
      end
      WRITE  : begin
        begin
          nextstate = Idle;
        end
      end
      WRMiss : begin
        if (sync) begin
          nextstate = WRITE;
        end
        else begin
          nextstate = WRMiss;
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
      cRowId[4:0] <= 5'b0;
      hold <= 0;
    end
    else begin
      cRowId[4:0] <= 5'b0; // default
      hold <= 0; // default
      case (nextstate)
        Idle   : begin
          hit <= 0;
          newrow <= 0;
        end
        RDCheck: begin
          
        end
        RDMiss : begin
          hold <= 1;
        end
        READ   : begin
          
        end
        WRCheck: begin
          if(newrow) begin
            for (int i=CHROWS; i>0; i--) begin
              if(!cache_tag[i-1].valid) begin
                cRowId <= cache_tag[i-1].tag;
                hit <= 1;
              end
            end
          end
          else
          for (int i = 0; i < CHROWS; i++) begin
            if((RowId == cache_tag[i].rowaddr) && (cache_tag[i].valid)) begin
              cRowId <= cache_tag[i].tag;
              hit <= 1;
            end
            else
            newrow <= 1;
          end
        end
        WRMiss : begin
          hold <= 1;
        end
        WRITE  : begin
          for (int i = 0; i < CHROWS; i++) begin
            if(cRowId == cache_tag[i].tag) begin
              cache_tag[i].valid <= 1;
              cache_tag[i].rowaddr <= RowId;
            end
          end
        end
      endcase
    end
  end
endmodule
