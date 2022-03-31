`timescale 1ns / 1ps

// Module to handle the input-output interface signals
module tristate #(parameter W=8) (
    input [W-1:0]dqi,
    output [W-1:0]dqo,
    inout [W-1:0]dq,
    input enable
    );
    
    assign dq = (enable) ? dqi : {W{1'bZ}};
    assign dqo = (enable) ? {W{1'b0}} : dq;
    
endmodule
