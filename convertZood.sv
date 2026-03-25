`default_nettype none

module convertZood
    (input logic [2:0] Zood3,
     output logic [3:0] Zood4);

    assign Zood4 = {1'b0, Zood3};

endmodule : convertZood
