
module MEMSync #(
    parameter CHWIDTH = 6,
    parameter ADDRWIDTH = 17,

    localparam CHROWS = 2**CHWIDTH,
    localparam ROWS = 2**ADDRWIDTH
)
  (
    output logic [CHWIDTH-1:0] cRowId, // Current MEM row to be used
    output logic dirty,
    output logic hit,
    output logic [CHWIDTH-1:0] nRowId, // Next MEM row to be used
    output logic ready,
    output logic stall, // stall signal
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
        logic [CHWIDTH-1:0] tag; // id of rows in memory model
        logic [ADDRWIDTH-1:0] rowaddr; // id of rows in memory
    } tag_table_type;

    tag_table_type tag_tbl [CHROWS];

    // state bits
    enum logic [2:0] {
        Idle       = 3'b000,
        Allocate   = 3'b001,
        CompareTag = 3'b010,
        UpdateTag  = 3'b011,
        WriteBack  = 3'b100,
        hitRD      = 3'b101,
        hitWR      = 3'b110
    } state, nextstate;


    // comb always block
    always_comb begin
        nextstate = state; // default to hold value because implied_loopback is set
        case (state)
            Idle      : begin // wait for RD/WR request from BankFSM
                if (RD || WR) begin
                    nextstate = CompareTag;
                end
            end
            Allocate  : begin // fetch block from memory
                if (sync) begin
                    nextstate = CompareTag;
                end
            end
            CompareTag: begin // determine hit or miss
                if (hit && RD) begin
                    nextstate = hitRD;
                end
                else if (hit && WR) begin
                    nextstate = hitWR;
                end
                else if (!hit) begin
                    nextstate = UpdateTag;
                end
            end
            UpdateTag : begin
                if (dirty) begin
                    nextstate = WriteBack;
                end
                else if (!dirty) begin
                    nextstate = Allocate;
                end
            end
            WriteBack : begin // write data to memory
                if (sync) begin
                    nextstate = Allocate;
                end
            end
            hitRD     : begin // data read
                if (!RD) begin
                    nextstate = Idle;
                end
            end
            hitWR     : begin // data write
                if (!WR) begin
                    nextstate = Idle;
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
            // reset tag table values
            for (int i = 0; i < CHROWS; i++) begin
                tag_tbl[i].valid=0;
                tag_tbl[i].dirty=0;
                tag_tbl[i].tag=i;
                tag_tbl[i].rowaddr='0;
            end
            cRowId[CHWIDTH-1:0] <= 0;
            dirty <= 0;
            hit <= 0;
            nRowId[CHWIDTH-1:0] <= 0;
            ready <= 0;
            stall <= 0;
        end
        else begin
            cRowId[CHWIDTH-1:0] <= cRowId; // default
            dirty <= 0; // default
            hit <= 0; // default
            nRowId[CHWIDTH-1:0] <= nRowId; // default
            ready <= 0; // default
            stall <= 0; // default
            case (nextstate)
                Allocate  : begin
                    stall <= 1;
                    tag_tbl[cRowId].valid <= 1;
                    tag_tbl[cRowId].rowaddr <= RowId;
                end
                CompareTag: begin
                    for (int i = 0; i < CHROWS; i++) begin
                        // look for the RowId in the emulation memory tag table
                        if((RowId == tag_tbl[i].rowaddr) && (tag_tbl[i].valid == 1)) begin
                            // this tag_tbl_i rowaddr equals RowId and is valid
                            cRowId <= tag_tbl[i].tag; // will focus on this row
                            hit <= 1;
                        end
                    end
                end
                UpdateTag : begin
                    cRowId[CHWIDTH-1:0] <= nRowId;
                    dirty <= tag_tbl[nRowId].dirty;
                    nRowId[CHWIDTH-1:0] <= nRowId+1;
                end
                WriteBack : begin
                    stall <= 1;
                    tag_tbl[cRowId].dirty <= 0;
                end
                hitRD     : begin
                    ready <= 1;
                end
                hitWR     : begin
                    ready <= 1;
                    tag_tbl[cRowId].dirty <= 1;
                end
            endcase
        end
    end
endmodule
