`default_nettype none

module convertZnarly
    (input logic [3:0] ZnarlyBit,
     output logic [3:0] ZnarlyVal);

    assign ZnarlyVal = ZnarlyBit[0] + ZnarlyBit[1] + ZnarlyBit[2] + ZnarlyBit[3];

endmodule : convertZnarly
