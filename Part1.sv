//`default_nettype none

//Outputs how many znarly there are
//If Output is 1111, 4 znarly's
//Each bit corresponds to one znarly
module checkIsZnarly
    (input logic [11:0] masterPattern,
     input logic [11:0] Guess,
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
    Comparator #(.WIDTH(3)) comp0 (.A(m0), .B(g0), .AeqB(out0));
    Comparator #(.WIDTH(3)) comp1 (.A(m1), .B(g1), .AeqB(out1));
    Comparator #(.WIDTH(3)) comp2 (.A(m2), .B(g2), .AeqB(out2));
    Comparator #(.WIDTH(3)) comp3 (.A(m3), .B(g3), .AeqB(out3));
    assign znarlyCount = {out3, out2, out1, out0};
endmodule : checkIsZnarly

//Adds 4 1-bit inputs into a 3-bit output
module FourInputAdder
  (input logic A, B, C, D,
  output logic [2:0] sum);
  logic [2:0] s1,s2;
  Adder #(.WIDTH(3)) adder0 (.cin(1'b0), .A({2'b0, A}), .B({2'b0, B}), .cout(), .sum(s1));
  Adder #(.WIDTH(3)) adder1 (.cin(1'b0), .A(s1), .B({2'b0, C}), .cout(), .sum(s2));
  Adder #(.WIDTH(3)) adder2 (.cin(1'b0), .A(s2), .B({2'b0, D}), .cout(), .sum(sum));
endmodule : FourInputAdder

//Count finds how many of a shape is in a 12-bit signal, but only counts them if
//they have not already been found green.
module Count
  (input logic [11:0] signal,
  input logic [3:0] znarlyHigh,
  input logic [2:0] elem,
  output logic [2:0] sumOut);
  logic out0, out1, out2, out3;
  logic [2:0] s1, s2; //intermediary adder logic
  Comparator #(.WIDTH(3)) comp4 (.A(signal[2:0]), .B(elem), .AeqB(out0));
  Comparator #(.WIDTH(3)) comp5 (.A(signal[5:3]), .B(elem), .AeqB(out1));
  Comparator #(.WIDTH(3)) comp6 (.A(signal[8:6]), .B(elem), .AeqB(out2));
  Comparator #(.WIDTH(3)) comp7 (.A(signal[11:9]), .B(elem), .AeqB(out3));
  FourInputAdder fia1 (.A(out0), .B(out1), .C(out2), .D(out3), .sum(sumOut));
endmodule : Count

//Gets the total number of greens of a given shape
module GreenOfShape
  (input logic [3:0] znarlyHigh,
  input logic [11:0] masterPattern,
  input logic [2:0] shape,
  output logic [2:0] greenOfShape);
  logic ab1, ab2, ab3, ab4, bit1, bit2, bit3, bit4;
  Comparator #(.WIDTH(3)) comp8 (.A(masterPattern[2:0]), .B(shape), .AeqB(ab1));
  Comparator #(.WIDTH(3)) comp9 (.A(masterPattern[5:3]), .B(shape), .AeqB(ab2));
  Comparator #(.WIDTH(3)) comp10 (.A(masterPattern[8:6]), .B(shape), .AeqB(ab3));
  Comparator #(.WIDTH(3)) comp11 (.A(masterPattern[11:9]), .B(shape), .AeqB(ab4));
  and a1 (bit1, znarlyHigh[0], ab1);
  and a2 (bit2, znarlyHigh[1], ab2);
  and a3 (bit3, znarlyHigh[2], ab3);
  and a4 (bit4, znarlyHigh[3], ab4);
  FourInputAdder fia2 (.A(bit1), .B(bit2), .C(bit3), .D(bit4), .sum(greenOfShape));
endmodule : GreenOfShape

//Gets the minimum yellow count for a single shape.
module CM
  (input logic [11:0] Guess, masterPattern,
  input logic [3:0] znarlyHigh,
  input logic [2:0] shape,
  output logic [2:0] count);
  logic [2:0] so1, so2, ZHBinary, diff1, diff2;
  logic MPisMin, A, B, C, D;
  logic [2:0] greenOfShape;
  Count c0 (.signal(masterPattern), .znarlyHigh(znarlyHigh), .elem(shape), .sumOut(so1));
  Count c1 (.signal(Guess), .znarlyHigh(znarlyHigh), .elem(shape), .sumOut(so2));
  GreenOfShape gos (.znarlyHigh(znarlyHigh), .masterPattern(masterPattern),
             .shape(shape), .greenOfShape(greenOfShape));
  Subtracter #(.WIDTH(3)) sub1 (.bin(1'b0), .A(so1), .B(greenOfShape), .bout(), .diff(diff1));
  Subtracter #(.WIDTH(3)) sub2 (.bin(1'b0), .A(so2), .B(greenOfShape), .bout(), .diff(diff2));
  MagComp #(.WIDTH(3)) mc1 (.A(diff1), .B(diff2), .AltB(MPisMin), .AeqB(), .AgtB());
  Mux2to1 #(.WIDTH(3)) mux1 (.I0(diff1), .I1(diff2), .S(MPisMin), .Y(count));
endmodule : CM

//Finds the number of yellows in a given pattern.
module countMatch
  (input logic [11:0] Guess, masterPattern,
  input logic [3:0] znarlyHigh,
  output logic [2:0] countMatch);
  logic [2:0] c1, c2, c3, c4, c5, c6;
  logic [2:0] s1, s2, s3, s4;
  CM cm001 (.Guess(Guess), .masterPattern(masterPattern),
        .znarlyHigh(znarlyHigh), .shape(3'b001), .count(c1));
  CM cm010 (.Guess(Guess), .masterPattern(masterPattern),
        .znarlyHigh(znarlyHigh), .shape(3'b010), .count(c2));
  CM cm011 (.Guess(Guess), .masterPattern(masterPattern),
        .znarlyHigh(znarlyHigh), .shape(3'b011), .count(c3));
  CM cm100 (.Guess(Guess), .masterPattern(masterPattern),
        .znarlyHigh(znarlyHigh), .shape(3'b100), .count(c4));
  CM cm101 (.Guess(Guess), .masterPattern(masterPattern),
        .znarlyHigh(znarlyHigh), .shape(3'b101), .count(c5));
  CM cm110 (.Guess(Guess), .masterPattern(masterPattern),
        .znarlyHigh(znarlyHigh), .shape(3'b110), .count(c6));
  Adder #(.WIDTH(3)) adder3 (.cin(1'b0), .A(c1), .B(c2), .cout(), .sum(s1));
  Adder #(.WIDTH(3)) adder4 (.cin(1'b0), .A(c3), .B(s1), .cout(), .sum(s2));
  Adder #(.WIDTH(3)) adder5 (.cin(1'b0), .A(c4), .B(s2), .cout(), .sum(s3));
  Adder #(.WIDTH(3)) adder6 (.cin(1'b0), .A(c5), .B(s3), .cout(), .sum(s4));
  Adder #(.WIDTH(3)) adder7 (.cin(1'b0), .A(c6), .B(s4), .cout(), .sum(countMatch));
endmodule : countMatch

//Puts together to form Task1
//outputs BIT so if 111 that means 3 yellows
//if 1111 that means 4 greens
module Part1
    (input logic [11:0] Guess,masterPattern,
     input logic GradeIt,
     output [2:0] yellows,
     output [3:0] greens);
     logic [2:0]  cmOut;
     logic [3:0] znarlyHigh;
     checkIsZnarly cIZ (.Guess(Guess), .masterPattern(masterPattern), .znarlyCount(znarlyHigh));
     countMatch cm (.Guess(Guess), .masterPattern(masterPattern), .znarlyHigh(znarlyHigh), .countMatch(cmOut));
     and a5(yellows[0], GradeIt, cmOut[0]);
     and a6(yellows[1], GradeIt, cmOut[1]);
     and a7(yellows[2], GradeIt, cmOut[2]);
     and a8(greens[0], GradeIt, znarlyHigh[0]);
     and a9(greens[1], GradeIt, znarlyHigh[1]);
     and a10(greens[2], GradeIt, znarlyHigh[2]);
     and a11(greens[3], GradeIt, znarlyHigh[3]);
endmodule : Part1
