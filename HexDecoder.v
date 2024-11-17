module HexDecoder(
    input iClk,
    input iReset_n,
    input iChip_select_n,
    input iWrite_n,
    input [31:0] iData,
    output reg [31:0] HEX
);

always @(posedge iClk or negedge iReset_n)
begin
    if (~iReset_n) 
    begin
        HEX <= 32'd0; // Reset the output to 0
    end 
    else if (~iChip_select_n && ~iWrite_n) 
    begin
        // Map 4-bit input (iData[3:0]) to 7-segment display values
        case (iData[3:0])
            4'h0: HEX <= {25'd0, 7'b1000000}; // 0
            4'h1: HEX <= {25'd0, 7'b1111001}; // 1
            4'h2: HEX <= {25'd0, 7'b0100100}; // 2
            4'h3: HEX <= {25'd0, 7'b0110000}; // 3
            4'h4: HEX <= {25'd0, 7'b0011001}; // 4
            4'h5: HEX <= {25'd0, 7'b0010010}; // 5
            4'h6: HEX <= {25'd0, 7'b0000010}; // 6
            4'h7: HEX <= {25'd0, 7'b0111000}; // 7
            4'h8: HEX <= {25'd0, 7'b0000000}; // 8
            4'h9: HEX <= {25'd0, 7'b0010000}; // 9
            4'hA: HEX <= {25'd0, 7'b0001000}; // A (10)
            4'hB: HEX <= {25'd0, 7'b0000011}; // B (11)
            4'hC: HEX <= {25'd0, 7'b1000110}; // C (12)
            4'hD: HEX <= {25'd0, 7'b0100001}; // D (13)
            4'hE: HEX <= {25'd0, 7'b0000110}; // E (14)
            4'hF: HEX <= {25'd0, 7'b0001110}; // F (15)
            default: HEX <= {25'd0, 7'b0111111}; // Default: display nothing (error state)
        endcase
    end
end

endmodule
