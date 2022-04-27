module addrndkey (
    input   wire    [127:0] state_in,
    input   wire    [127:0] key,
    output  wire    [127:0] state_out
);

assign  state_out   =   state_in ^ key;

endmodule
