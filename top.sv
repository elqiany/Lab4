`default_nettype none

module top(
    input logic CLOCK_100,
    input logic reset,
    input logic [1:0] coinValue,
    input logic coinInserted,

    input logic [1:0] ShapeLocation,
    input logic LoadShapeNow,
    input logic [2:0] LoadShape,

    input logic [11:0] Guess,
    input logic GradeIt,
    input logic StartGame,

    output logic [3:0] NumGames,
    output logic [3:0] RoundNumber,
    output logic [3:0] Znarly,
    output logic [3:0] Zood,
    output logic GameWon);

    logic [1:0] coinValue_sync;
    logic coinInserted_sync;
    logic startGame_sync;
    logic [11:0] guess_sync;
    logic gradeIt_sync;
    logic [2:0] loadShape_sync;
    logic [1:0] shapeLocation_sync;
    logic [1:0] state;
    logic [1:0] state0;
    logic [1:0] state2;
    logic loadShapeNow_sync;
    logic Restart_Game; //This is new logic because can't have same input and output to FSM

    Synchronizer sync_coin0 (.async(CoinValue[0]), .clock(CLOCK_100), . sync(coinValue_sync[0]);
    Synchronizer sync_coin1 (.async(CoinValue[1]), .clock(CLOCK_100), . sync(coinValue_sync[1]);

    Synchronizer sync_coinIns (.async(coinInserted), .clock(CLOCK_100), . sync(coinInserted_sync);
    Synchronizer sync_start (.async(StartGame), .clock(CLOCK_100), . sync(StartGame_sync);
    Synchronizer sync_grade (.async(GradeIt), .clock(CLOCK_100), . sync(GradeIt_sync);
    Synchronizer sync_loadNow (.async(LoadShapeNow), .clock(CLOCK_100), . sync(LoadShapeNow_sync);


    //myAbstractFSM outputs
    logic [1:0] state;
    logic [3:0] credit;

    //will declare masterPattern later
    logic [11:0] masterPattern;

    //MPMemory outputs
    logic [11:0] memTot;
    logic [3:0] FSMTot;
    logic isMPLoaded;

    //Part1 outputs
    logic [3:0] Znarlygreen;
    logic [2:0] Zoodyellow;

    //MagComp output
    logic magComp_out;

    //comparator output
    logic comp_out;

    //and output
    logic and_out1;

    //or output
    logic or_out;

    //edgeDetectorFSM output
    logic gradeIt_out;

    //output from comparator to see if there are 4 znarly's
    logic znarlyComp_out;

    //missing the box before the Abstract not sure how or what it means
    myAbstractFSM coinFSM (
        .clock(CLOCK_100),
        .reset(reset),
        .coin(coinValue_sync),
        .credit(credit),
        .drop(drop));

    MPMemory mem (
        .clock(CLOCK_100),
        .shapeLocation(shapeLocation),
        .loadShapeNow(.loadShapeNow),
        .loadShape(loadShape),
        .memTot(memTot),
        .FSMTot(FSMTot),
        .isMPLoaded(isMPLoaded));

    Part1 grader (
        .Guess(Guess),
        .masterPattern(masterPattern),
        .GradeIt(GradeIt),
        .yellows(Zoodyellow),
        .greens(Znarlygreen));

    controlFSM ctrl (
        .CLOCK_100(CLOCK_100),
        .reset(reset),
        .startGame(paid_start),
        .MPLoaded(isMPLoaded),
        .gameWon(GameWon)
        .roundNumber(RoundNumber),
        .state(state));

    MagComp gameComp (
        .A(numGames),
        .B(4'b0110),
        .AltB(),
        .AeqB(),
        .AgtB(comp_out));

    Comparator state0comp (
        .A(2'b00),
        .B(state),
        .AeqB(state0)); //unsure if this is meant to be output or clear in diagram

    Comparator state2comp (
        .A(2'b10),
        .B(state),
        .AeqB(state2));

    //calculations before NumGames counter
    and a1 (magComp_out, drop, and_out1);
    or o1 (startGame, and_out1, or_out);

    Counter #(.WIDTH(4)) gameCounter (
                    .D(4'b0000),
                    .en(or_out),
                    .clear(state0),
                    .load(comp_out),
                    .clock(CLOCK_100),
                    .up(startGame), //im unsure if this is what diagram wants, looks to be a circle (?) before  so idk
                    .Q(NumGames));


    //Grade It Button detector
    edgeDetectorFSM edgeGrade (
        .CLOCK_100(CLOCK_100),
        .reset(reset),
        .btn(GradeIt),
        .grade_it(gradeIt_out));

    Counter #(.WIDTH(4)) roundCount (
        .D(4'b0000),
        .en(gradeIt_out),
        .clear(state0),
        .load(state0),
        .clock(CLOCK_100),
        .up(1'b1),
        .Q(RoundNumber));

    //output znarly and zood
    convertZood czood (
        .Zood3(Zoodyellow),
        .Zood4(Zood));

    convertZnarly cznarly (
        .ZnarlyBit(Znarlygreen),
        .ZnarlyVal(Znarly));

    //output GameWon
    Comparator znarlyComp (
        .A(Znarlygreen),
        .B(4'b1111),
        .AeqB(znarlyComp_out));

    and a2 (znarlyComp_out, state2, GameWon);

endmodule : top
