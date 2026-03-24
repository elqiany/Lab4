`default_nettype none

//Puts together to form Task1
//outputs BIT so if 111 that means 3 yellows
//if 1111 that means 4 greens
module Part1
    (input logic [11:0] Guess,
     input logic [11:0] masterPattern,
     input logic GradeIt,
     input logic reset,
     input CLOCK_100,
     output [2:0] yellows,
     output [3:0] greens);

     logic [2:0]  cmOut;
     logic [3:0] znarlyHigh;

     countMatch cm (.Guess(Guess), .masterPattern(masterPattern), .znarlyHigh(znarlyHigh), .countMatch(cmOut));

     checkIsZnarly cIZ (.Guess(Guess), .masterPattern(masterPattern), .znarlyCount(znarlyHigh));

     and a1(yellows[0], GradeIt, cmOut[0]);
     and a2(yellows[1], GradeIt, cmOut[1]);
     and a3(yellows[2], GradeIt, cmOut[2]);

     and a4(greens[0], GradeIt, znarlyHigh[0]);
     and a5(greens[1], GradeIt, znarlyHigh[1]);
     and a6(greens[2], GradeIt, znarlyHigh[2]);
     and a7(greens[3], GradeIt, znarlyHigh[3]);

endmodule : Part1

