`default_nettype none

module top(
    input logic CLOCK_100,
    input logic reset,
    input logic [1:0] coinValue,
    input logic coinInserted,

    input logic [1:0] shapeLocation,
    input logic loadShapeNow,
    input logic [2:0] loadShape,

    input logic [11:0] Guess,
    input logic GradeIt,
    input logic startGame,

    output logic [1:0] state,
    output logic [3:0] numGames,
    output logic [3:0] roundNumber,
    output logic [3:0] Znarly,
    output logic [3:0] Zood,
    output logic gameWon);

    logic [1:0] coinValue_sync;
    logic coinInserted_sync;
    logic startGame_sync;
    logic [11:0] guess_sync;
    logic gradeIt_sync;
    logic [2:0] loadShape_sync;
    logic [1:0] shapeLocation_sync;
    logic loadShapeNow_sync;

    Synchronizer sync_coin0 (.async(CoinValue[0]), .clock(CLOCK_100), . sync(coinValue_sync[0]);
    Synchronizer sync_coin1 (.async(CoinValue[1]), .clock(CLOCK_100), . sync(coinValue_sync[1]);

    Synchronizer sync_coinIns (.async(coinInserted), .clock(CLOCK_100), . sync(coinInserted_sync);
    Synchronizer sync_start (.async(startGame), .clock(CLOCK_100), . sync(startGame_sync);
    Synchronizer sync_grade (.async(gradeIt), .clock(CLOCK_100), . sync(gradeIt_sync);
    Synchronizer sync_loadNow (.async(loadShapeNow), .clock(CLOCK_100), . sync(loadShapeNow_sync);


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

    //missing the box before the Abstract not sure how or what it means
    myAbstractFSM coinFSM (
        .clock(CLOCK_100),
        .reset(reset),
        .coinValue(coinValue_sync),
        .coinInserted(coinInserted_sync),
        .credit(credit),
        .drop(drop));

    MagComp gameComp (
        .A(numGames),
        .B(4'b0110),
        .AltB(),
        .AeqB(),
        .AgtB(comp_out));

    MPMemory mem (
        .clock(CLOCK_100),
        .shapeLocation(shapeLocation),
        .loadShapeNow(.loadShapeNow),
        .loadShape(loadShape),
        .memTot(memTot),
        .FSMTot(FSMTot),
        .isMPLoaded(isMPLoaded));


    controlFSM ctrl (
        .CLOCK_100(CLOCK_100),
        .reset(reset),
        .startGame(paid_start),
        .MPLoaded(isMPLoaded),
        .gameWon(gameWon)
        .roundNumber(RoundNumber),
        .state(state));

    Part1 grader (
        .Guess(Guess),
        .masterPattern(masterPattern),
        .GradeIt(GradeIt),
        .yellows(Zoodyellow),
        .greens(Znarlygreen));

    Comparator comp (
        .A(2'b00),
        .B(state),
        .AeqB(comp_out));

    and a1 (magComp_out, drop, and_out1);
    or o1 (startGame, and_out1, or_out);

    Counter #(.WIDTH(4)) gameCounter (
                    .D(4'b0000),
                    .en(or_out),
                    .clear(state0),
                    .load(comp_out),
                    .clock(CLOCK_100),
                    .up(startGame), //im unsure if this is what diagram wants, looks to be a circle (?) before  so idk
                    .Q(numGames));


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


