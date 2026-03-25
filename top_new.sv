`default_nettype none

module top
  (input logic CLOCK_100, reset, coinInserted,
    input logic LoadShapeNow, GradeIt, StartGame,
    input logic [1:0] coinValue, ShapeLocation,
    input logic [2:0] LoadShape,
    input logic [11:0] Guess,
    output logic [3:0] NumGames, RoundNumber, Znarly, Zood,
    output logic GameWon);

    logic state0, state1, state2, state3;
    logic [11:0] masterPattern;
    logic isMPLoaded;
    logic [3:0] Znarlygreen;
    logic [2:0] Zoodyellow, ZnarlyTemp;
    logic shouldIncreaseGames;
    logic [1:0] coinDropped;
    logic [1:0] state;
    logic RestartGame;
    logic drop;

//----------------- Processing the Inputs to be Synchronous  --------------------
    logic [2:0] LoadShape_sync;
    logic [1:0] coinValue_sync, ShapeLocation_sync;
    logic coinInserted_sync, StartGame_sync, GradeIt_sync;
    logic LoadShapeNow_sync;
    logic [11:0] Guess_sync;

  // Put an edge detector on every input with a button, this
  // also synchronizes the inputs.
  edgeDetectorFSM edgeCoin (.clock(CLOCK_100),
        .reset(reset), .btn(coinInserted), .edge_detected(coinInserted_sync));
  edgeDetectorFSM edgeStartGame (.clock(CLOCK_100),
        .reset(reset), .btn(StartGame), .edge_detected(StartGame_sync));
  edgeDetectorFSM edgeGradeIt (.clock(CLOCK_100),
        .reset(reset), .btn(GradeIt), .edge_detected(GradeIt_sync));
  edgeDetectorFSM edgeLoadShape (.clock(CLOCK_100),
        .reset(reset), .btn(LoadShapeNow), .edge_detected(LoadShapeNow_sync));

  // Put a synchronizer on every input with a button
    Synchronizer sync_coin0 (.async(coinValue[0]), .clock(CLOCK_100), .sync(coinValue_sync[0]));
    Synchronizer sync_coin1 (.async(coinValue[1]), .clock(CLOCK_100), . sync(coinValue_sync[1]));
    Synchronizer sync_shapeloc1 (.async(ShapeLocation[0]), .clock(CLOCK_100), . sync(ShapeLocation_sync[0]));
    Synchronizer sync_shapeloc2 (.async(ShapeLocation[1]), .clock(CLOCK_100), . sync(ShapeLocation_sync[1]));
    Synchronizer sync_LoadShape1 (.async(LoadShape[0]), .clock(CLOCK_100), . sync(LoadShape_sync[0]));
    Synchronizer sync_LoadShape2 (.async(LoadShape[1]), .clock(CLOCK_100), . sync(LoadShape_sync[1]));
    Synchronizer sync_LoadShape3 (.async(LoadShape[2]), .clock(CLOCK_100), . sync(LoadShape_sync[2]));
    Synchronizer sync_guess0 (.async(Guess[0]), .clock(CLOCK_100), . sync(Guess_sync[0]));
    Synchronizer sync_guess1 (.async(Guess[1]), .clock(CLOCK_100), . sync(Guess_sync[1]));
    Synchronizer sync_guess2 (.async(Guess[2]), .clock(CLOCK_100), . sync(Guess_sync[2]));
    Synchronizer sync_guess3 (.async(Guess[3]), .clock(CLOCK_100), . sync(Guess_sync[3]));
    Synchronizer sync_guess4 (.async(Guess[4]), .clock(CLOCK_100), . sync(Guess_sync[4]));
    Synchronizer sync_guess5 (.async(Guess[5]), .clock(CLOCK_100), . sync(Guess_sync[5]));
    Synchronizer sync_guess6 (.async(Guess[6]), .clock(CLOCK_100), . sync(Guess_sync[6]));
    Synchronizer sync_guess7 (.async(Guess[7]), .clock(CLOCK_100), . sync(Guess_sync[7]));
    Synchronizer sync_guess8 (.async(Guess[8]), .clock(CLOCK_100), . sync(Guess_sync[8]));
    Synchronizer sync_guess9 (.async(Guess[9]), .clock(CLOCK_100), . sync(Guess_sync[9]));
    Synchronizer sync_guess10 (.async(Guess[10]), .clock(CLOCK_100), . sync(Guess_sync[10]));
    Synchronizer sync_guess11 (.async(Guess[11]), .clock(CLOCK_100), . sync(Guess_sync[11]));
//----------------------------------------------------------------------------------
    MPMemory mem (
        .loadShapeNow(LoadShapeNow),
        .clock(CLOCK_100), .state0(state0),
        .shapeLocation(ShapeLocation),
        .loadShape(LoadShape),
        .memTot(masterPattern),
        .FFSTot(), .isMPLoaded(isMPLoaded));

//-----------------ZNARLY, ZNOOD, GAME WON LOGIC --------------
    Part1 grader (
        .Guess(Guess_sync),
        .masterPattern(masterPattern),
        .GradeIt(GradeIt),
        .yellows(Zoodyellow),
        .greens(Znarlygreen));
    assign Zood = {1'b0, Zoodyellow};
    FourInputAdder fia3 (.A(Znarlygreen[0]), .B(Znarlygreen[1]), .C(Znarlygreen[2]), .D(Znarlygreen[3]), .sum(ZnarlyTemp));
    assign Znarly = {1'b0, ZnarlyTemp};
    logic allGreen;
    Comparator #(.WIDTH(3)) comp13 (.A(ZnarlyTemp), .B(3'b100), .AeqB(allGreen));
    and a15 (GameWon, state2, allGreen);
//---------------------------------------------------------------------------

  //The state signals are created from the main FSM output
  // and are used by other components.
  Comparator #(.WIDTH(2)) comp14 (.A(state), .B(2'b00), .AeqB(state0));
  Comparator #(.WIDTH(2)) comp15 (.A(state), .B(2'b01), .AeqB(state1));
  Comparator #(.WIDTH(2)) comp16 (.A(state), .B(2'b10), .AeqB(state2));
  Comparator #(.WIDTH(2)) comp17 (.A(state), .B(2'b11), .AeqB(state3));

//---------------------------NUM GAMES LOGIC ------------------------
  MagComp #(.WIDTH(4)) mc2 (.A(NumGames), .B(4'b0111),
        .AltB(shouldIncreaseGames), .AeqB(), .AgtB());
  logic s2D;
  and a16 (s2D, shouldIncreaseGames, drop);
  logic shouldCountGame;
  or o5 (shouldCountGame, RestartGame, s2D);
  Counter #(.WIDTH(4)) gameCounter (
        .en(shouldCountGame), .clear(reset),
        .load(), .up(StartGame_sync), .D(), .clock(CLOCK_100), .Q(NumGames));

//---------------------------ROUND NUMBER LOGIC ------------------------
  Counter #(.WIDTH(4)) roundCounter (
        .en(GradeIt_sync), .clear(state0),
        .load(), .up(1'b1), .D(), .clock(CLOCK_100), .Q(RoundNumber));

//--------------------------------- FSMs ------------------------------

  Mux2to1 #(.WIDTH(2)) mux2 (.I0(2'b00), .I1(coinValue_sync),
         .S(coinInserted_sync), .Y(coinDropped));
  myAbstractFSM coinFSM (
        .coin(coinDropped), .clock(CLOCK_100), .reset(reset),
        .credit(), .drop(drop));

  controlFSM mainFSM
    (.clock(CLOCK_100), .reset(reset), .StartGame(StartGame_sync),
     .MPLoaded(isMPLoaded), .GameWon(GameWon),
     .GradeIt(GradeIt_sync), .RoundNumber(RoundNumber),
     .NumGames(NumGames),
     .state(state), .RestartGame(RestartGame));
endmodule : top

