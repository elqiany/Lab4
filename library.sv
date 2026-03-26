//`default_nettype none

//------------------------------ COMBINATIONAL COMPONENTS ------------------------------
module Comparator
  #(parameter WIDTH = 8)
  (output logic AeqB,
  input logic [WIDTH-1:0] A, B);
  assign AeqB = (A == B);
endmodule : Comparator

module MagComp
  #(parameter WIDTH = 8)
  (output logic AltB, AeqB, AgtB,
  input logic [WIDTH-1:0] A,B);
   assign AeqB = (A == B);
   assign AltB = (A < B);
   assign AgtB = (A > B);
endmodule : MagComp

module Adder
  #(parameter WIDTH = 8)
  (input logic cin,
   input logic [WIDTH-1:0] A,B,
   output logic cout,
   output logic [WIDTH-1:0] sum);
   assign {cout, sum} = A + B + cin;
endmodule : Adder

module Subtracter
  #(parameter WIDTH = 8)
  (input logic bin,
   input logic [WIDTH-1:0] A,B,
   output logic bout,
   output logic [WIDTH-1:0] diff);
   assign {bout, diff} = A - B - bin;
endmodule : Subtracter

module Multiplexer
  #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] I,
  input logic [$clog2(WIDTH)-1:0] S, //ceil(log2(WIDTH)) size
   output logic Y);
  assign Y = I[S]; //Y is the Sth bit of the signal I
endmodule : Multiplexer

module Mux2to1
  #(parameter WIDTH = 8)
  (input logic [WIDTH-1:0] I0, I1,
   input logic S,
   output logic [WIDTH-1:0] Y);
  assign Y = (S) ? I0: I1;
endmodule : Mux2to1

//Decoder creates a 1s-hot signal on the Ith wire
module Decoder
  #(parameter WIDTH = 8)
  (input logic [$clog2(WIDTH)-1:0] I,
   input logic en,
   output logic [WIDTH-1:0] D);
  always_comb begin
    D = 0; //default case
    if(en) D[I] = 1'b1; //Set the 1s hot value if the decoder is enabled
  end
endmodule : Decoder

//------------------------------ SEQUENTIAL COMPONENTS ------------------------------

//D Flip-Flop is a memory unit.
//It passes the input value to the output value on the clock edge.
module DFlipFlop
  (input logic preset_L, D, clock, reset_L,
   output logic Q);
  //Active low signals are on the negedge.
  always_ff @(posedge clock or negedge preset_L or negedge reset_L) begin
    //negedge preset_L then change:
    if (!preset_L) Q <= 1; //preset is activated, set output to high
    //negedge reset_L then change:
    else if(!reset_L) Q <= 0; //reset is activated, set output to low
    //At this point, what must have changed is posedge clock, so:
    else Q <= D;
  end
endmodule : DFlipFlop

//A register is a collection of flip-flops used to store multiple values.
//It is basically a multi-bit flip-flop.
module Register
  #(parameter WIDTH = 8)
  (input logic en, clear, clock,
  input logic [WIDTH-1:0] D,
  output logic [WIDTH-1:0] Q);
  always_ff @(posedge clock or posedge clear) begin
    //posedge clear then change:
    if (clear) Q <= 0; //clear is activated, set output to low
    else if (en) Q <= D;
  end
endmodule : Register

//A counter counts up or down - very useful for timers
module Counter
  #(parameter WIDTH = 8)
  (input logic en, clear, load, up, clock,
  input logic [WIDTH-1:0] D,
  output logic [WIDTH-1:0] Q);
  always_ff @(posedge clock or posedge clear) begin
    if (clear) Q <= 0;
  else if (load) Q <= D;
    else if (en) begin
      if (up) Q <= Q+1; //Must use blocking assignment, so not Q++
      else Q <= Q-1;
    end
  end
endmodule : Counter

//SIPO = Serial In, Parallel Out
//SIPO inputs bits one by one (serially) over cycles but outputs all bits at once
//The ShiftRegisterSIPO is a SIPO register that logically shifts either left or right. It will
//consume the bit on the serial input and place it in either the MSB or LSB position of the
//output. When not enabled, nothing will change.
module ShiftRegisterSIPO
  #(parameter WIDTH = 8)
  (input logic en, left, serial, clock,
  output logic [WIDTH-1:0] Q);
  always_ff @(posedge clock) begin
    if (en) begin
      if (left) Q <= {Q[WIDTH-2:0], serial};
      else Q <= {serial, Q[WIDTH-1:1]};
    end
  end
endmodule : ShiftRegisterSIPO

//PIPO = Parallel In, Parallel Out
//PIPO inputs and outputs all bits at once, acts as multi-bit flip-flop
//The ShiftRegisterPIPO is a PIPO register that logically shifts either left or right depending
//on the left control input. It only shifts when enabled and load is not active.
module ShiftRegisterPIPO
  #(parameter WIDTH=8)
  (input  logic en, left, load, clock,
    input  logic [WIDTH-1:0] D,
    output logic [WIDTH-1:0] Q);
  always_ff @(posedge clock) begin
    if (load) Q <= D;
    else if (en) begin
      if (left) Q <= Q << 1;
      else Q <= Q >> 1;
    end
  end
endmodule : ShiftRegisterPIPO

//Shifts the incoming data by a variable number of bits
//The BarrelShiftRegister is a PIPO register that shifts left. It shifts left either 0, 1, 2 or 3
//positions based on the 2-bit by input (short for "shift by this amount"). It only shifts when
//enabled, of course. Load has priority over shifting.
module BarrelShiftRegister
  #(parameter WIDTH=8)
  ( input  logic en, load, clock,
    input  logic [1:0] by,
    input  logic [WIDTH-1:0] D,
    output logic [WIDTH-1:0] Q);
  always_ff @(posedge clock) begin
    if (load) Q <= D;
    else if (en) Q <= Q << by;
  end
endmodule : BarrelShiftRegister

//The Synchronizer is the circuitry that protects an FSM or hardware thread from an asyn-
//chronous input signal, which could be asserted at any time and thus cause setup/hold violations
//or metastable situations. The result is a signal synchronized to the local clock (the clock input).
module Synchronizer
  (input  logic async, clock,
    output logic sync);
  logic temp;
  always_ff @(posedge clock) begin
    temp <= async;
    sync <= temp;
  end
endmodule : Synchronizer

//The BusDriver is used to control access to a shared wire or bus. When enabled, whatever value
//of data will be driven onto the bus, otherwise the bus driver will not drive anything.
module BusDriver
  #(parameter WIDTH=8)
  (input  logic en,
    input  logic [WIDTH-1:0] data,
    inout  tri [WIDTH-1:0] bus,
    output logic [WIDTH-1:0] buff);
  assign bus  = en ? data : 'z;
  assign buff = bus;
endmodule : BusDriver

//The Memory is our memory module, which stores a number of words. It is combinational read,
//sequential write.
module Memory
  #(parameter AW = 2, DW = 4)
  (input  logic [AW-1:0] addr,
  input  logic re, we, clock,
  inout  tri [DW-1:0] data);
  //Creating the internal variables memoryStorage and busDriver
  logic [DW-1:0] memoryStorage [0:(2**AW)-1];  // memory storage
  logic [DW-1:0] busDriver;    // internal signal that drives the bus
  // combinational read logic
  always_comb begin
    if (re) busDriver = memoryStorage[addr];
    else busDriver = 1'b0;
  end
  assign data = (re) ? busDriver : 'z; // actually drive bus
  // sequential write logic
  always_ff @(posedge clock) begin
    if (we) memoryStorage[addr] <= data;
  end
endmodule : Memory

