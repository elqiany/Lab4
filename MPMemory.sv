`default_nettype none

//SaveShape stores a shape value and a bit to check that it has been stored.
module SaveShape
  (input logic thisLoc, loadShapeNow, state0, clock,
  input logic [2:0] loadShape,
  output logic FFS,
  output logic [2:0] mem);
  logic locS, stateStored, w1;
  and a12 (locS, thisLoc, loadShapeNow);
  Comparator #(.WIDTH(1)) comp12 (.A(FFS), .B(1'b0), .AeqB(stateStored));
  and a13 (w1, locS, stateStored);
  Register #(.WIDTH(3)) reg1(.en(w1), .clear(state0), .clock(clock), .D(loadShape), .Q(mem));
  Register #(.WIDTH(1)) reg2(.en(locS), .clear(state0), .clock(clock), .D(1'b1), .Q(FFS));
endmodule : SaveShape

module MPMemory
  (input logic loadShapeNow, clock, state0,
  input logic [1:0] shapeLocation,
  input logic [2:0] loadShape,
  output logic [11:0] memTot,
  output logic [3:0] FFSTot,
  output logic isMPLoaded);

  logic [3:0] en;
  logic en00, en01, en10, en11;
  logic [2:0] mem0, mem1, mem2, mem3;
  logic FFS0, FFS1, FFS2, FFS3;
  Decoder #(.WIDTH(4)) dec1 (.I(shapeLocation), .en(1'b1), .D(en));
  assign en00 = en[0];
  assign en01 = en[1];
  assign en10 = en[2];
  assign en11 = en[3];
  SaveShape ss1 ( .thisLoc(en00), .loadShapeNow(loadShapeNow),
             .state0(state0), .clock(clock), .loadShape(loadShape),
             .FFS(FFS0), .mem(mem0));
  SaveShape ss2 ( .thisLoc(en01), .loadShapeNow(loadShapeNow),
             .state0(state0), .clock(clock), .loadShape(loadShape),
             .FFS(FFS1), .mem(mem1));
  SaveShape ss3 ( .thisLoc(en10), .loadShapeNow(loadShapeNow),
             .state0(state0), .clock(clock), .loadShape(loadShape),
             .FFS(FFS2), .mem(mem2));
  SaveShape ss4 ( .thisLoc(en11), .loadShapeNow(loadShapeNow),
             .state0(state0), .clock(clock), .loadShape(loadShape),
             .FFS(FFS3), .mem(mem3));
  assign memTot = {mem3, mem2, mem1, mem0};
  assign FFSTot = {FFS3, FFS2, FFS1, FFS0};
  and a14 (isMPLoaded, FFS0, FFS1, FFS2, FFS3);
endmodule : MPMemory

