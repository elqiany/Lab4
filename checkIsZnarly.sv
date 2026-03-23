`default_nettype none

//Outputs how many znarly there are
//If Output is 1111, 4 znarly's
//Each bit corresponds to one znarly
module checkIsZnarly
    (input logic [12:0] masterPattern,
     input logic [12:0] Guess,
     output logic [3:0] znarlyCount);

    logic [2:0] g0, g1, g2, g3;
    logic [2:0] m0, m1, m2, m3;
    logic out0, out1, out2, out3;

    assign g3 = Guess[11:9];
    assign g2 = Guess[8:6];
    assign g1 = Guess[5:3];
    assign g0 = Guess[2:0];

    assign m3 = masterPattern[11:9];
    assign m2 = masterPattern[8:6];
    assign m1 = masterPattern[5:3];
    assign m0 = masterPattern[2:0];

    //comparing each bit
    Comparator #(.WIDTH(3)) c0 (.A(m0), .B(g0), .AeqB(out0));
    Comparator #(.WIDTH(3)) c1 (.A(m1), .B(g1), .AeqB(out1));
    Comparator #(.WIDTH(3)) c2 (.A(m2), .B(g2), .AeqB(out2));
    Comparator #(.WIDTH(3)) c3 (.A(m3), .B(g3), .AeqB(out3));

    assign znarlyCount = {out3, out2, out1, out0};

endmodule : checkIsZnarly




