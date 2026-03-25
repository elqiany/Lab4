`default_nettype none

module top_testbench;

    logic CLOCK_100;
    logic reset, coinInserted;
    logic LoadShapeNow, GradeIt, StartGame;
    logic [1:0] coinValue, ShapeLocation;
    logic [2:0] LoadShape;
    logic [11:0] Guess;

    logic [3:0] NumGames, RoundNumber, Znarly, Zood;
    logic GameWon;

    top dut (
        .CLOCK_100(CLOCK_100),
        .reset(reset),
        .coinInserted(coinInserted),
        .LoadShapeNow(LoadShapeNow),
        .GradeIt(GradeIt),
        .StartGame(StartGame),
        .coinValue(coinValue),
        .ShapeLocation(ShapeLocation),
        .LoadShape(LoadShape),
        .Guess(Guess),
        .NumGames(NumGames),
        .RoundNumber(RoundNumber),
        .Znarly(Znarly),
        .Zood(Zood),
        .GameWon(GameWon)
    );

    // clock
    initial begin
        CLOCK_100 = 1'b0;
        forever #5 CLOCK_100 = ~CLOCK_100;
    end

    initial begin
        $monitor($time,,
            "reset = %b, coinInsrt = %b, LoadShapeNow = %b, GradeIt = %b, Start = %b, coinVal = %b, ShapeLo = %b, LoadShape = %b, Guess = %b, NumGames = %b, RoundNum = %b, Znarly = %b, Zood = %b, GameWon = %b",
            reset, coinInserted,LoadShapeNow,GradeIt,StartGame,coinValue,ShapeLocation,LoadShape,Guess,NumGames,RoundNumber,Znarly,Zood,GameWon);


        // reset
        reset = 1'b1;
        coinInserted = 1'b0;
        LoadShapeNow = 1'b0;
        GradeIt = 1'b0;
        StartGame = 1'b0;
        coinValue = 2'b00;
        ShapeLocation = 2'b00;
        LoadShape = 3'b000;
        Guess = 12'b0;

        #20;
        reset = 1'b0;

        // wait a little after reset
        #20;

        // Load master pattern one shape at a time
        // Guess = 12'b100_011_010_001

        // load location 00 with 001
        ShapeLocation = 2'b00;
        LoadShape = 3'b001;
        #20;
        LoadShapeNow = 1'b1;
        #20;
        LoadShapeNow = 1'b0;
        #20;

        // load location 01 with 010
        ShapeLocation = 2'b01;
        LoadShape = 3'b010;
        #20;
        LoadShapeNow = 1'b1;
        #20;
        LoadShapeNow = 1'b0;
        #20;

        // load location 10 with 011
        ShapeLocation = 2'b10;
        LoadShape = 3'b011;
        #20;
        LoadShapeNow = 1'b1;
        #20;
        LoadShapeNow = 1'b0;
        #20;

        // load location 11 with 100
        ShapeLocation = 2'b11;
        LoadShape = 3'b100;
        #20;
        LoadShapeNow = 1'b1;
        #20;
        LoadShapeNow = 1'b0;
        #40;

        // Insert enough coins for one game
        // Cost is 4 circles, and 01 = circle
        coinValue = 2'b01;

        coinInserted = 1'b1; #20;
        coinInserted = 1'b0; #20;
        coinInserted = 1'b1; #20;
        coinInserted = 1'b0; #20;
        coinInserted = 1'b1; #20;
        coinInserted = 1'b0; #20;
        coinInserted = 1'b1; #20;
        coinInserted = 1'b0; #40;

        // Start game
        StartGame = 1'b1;
        #20;
        StartGame = 1'b0;
        #40;

        // Guess 1: wrong guess
        // all 001's
        Guess = 12'b001_001_001_001;
        #20;
        GradeIt = 1'b1;
        #20;
        GradeIt = 1'b0;
        #40;

        // Should be 3 zoods
        Guess = 12'b001_100_011_010;
        #20;
        GradeIt = 1'b1;
        #20;
        GradeIt = 1'b0;
        #40;

        // Should be 4 zoods
        Guess = 12'b010_100_011_010;
        #20;
        GradeIt = 1'b1;
        #20;
        GradeIt = 1'b0;
        #40;

        // Guess 2: correct guess
        // should match loaded master pattern exactly
        Guess = 12'b100_011_010_001;
        #20;
        GradeIt = 1'b1;
        #20;
        GradeIt = 1'b0;
        #60;

        $finish;
    end

endmodule : top_testbench
