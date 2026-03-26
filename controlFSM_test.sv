`default_nettype none

//testbench for control FSM
module controlFSM_test;

    logic clock;
    logic reset;

    logic StartGame;
    logic MPLoaded;
    logic GameWon;
    logic GradeIt;
    logic [3:0] RoundNumber;

    logic [1:0] state;
    logic RestartGame;
    logic [3:0] NumGames;

    controlFSM dut (
        .clock(clock),
        .reset(reset),
        .StartGame(StartGame),
        .MPLoaded(MPLoaded),
        .GameWon(GameWon),
        .GradeIt(GradeIt),
        .RoundNumber(RoundNumber),
        .NumGames(NumGames),
        .state(state),
        .RestartGame(RestartGame)
    );

    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    initial begin
        $monitor($time,,
            "currState = %b, nextState = %b, StartGame = %b,"dut.currState, dut.nextState, StartGame,
            "MPLoaded = %b, GameWon = %b, GradeIt = %b, RoundNumber = %d,",MPLoaded, GameWon, GradeIt, RoundNumber,
            "state = %b, RestartGame = %b", state, RestartGame);

        // initial values
        reset = 1'b1;
        StartGame = 1'b0;
        MPLoaded = 1'b0;
        GameWon = 1'b0;
        GradeIt = 1'b0;
        RoundNumber = 4'd0;
        NumGames = 4'b0000;

        @(posedge clock);
        #1;
        reset = 1'b0;

        // first_tick -> pre_game
        @(posedge clock);
        #1;

        // stay in pre_game
        StartGame = 1'b0;
        MPLoaded = 1'b0;
        @(posedge clock);
        #1;

        // still stay in pre_game
        StartGame = 1'b1;
        MPLoaded = 1'b0;
        @(posedge clock);
        #1;

        // go to play
        StartGame = 1'b1;
        MPLoaded = 1'b1;
        NumGames = 4'b0001;
        @(posedge clock);
        #1;

        // stay in play
        StartGame = 1'b0;
        MPLoaded = 1'b0;
        RoundNumber = 4'd3;
        GameWon = 1'b0;
        @(posedge clock);
        #1;

        // go to final_guess when RoundNumber = 7
        RoundNumber = 4'd7;
        GameWon = 1'b0;
        @(posedge clock);
        #1;

        // stay in final_guess until GradeIt = 1
        GradeIt = 1'b0;
        @(posedge clock);
        #1;

        // final_guess -> first_tick
        GradeIt = 1'b1;
        @(posedge clock);
        #1;

        // first_tick -> pre_game again
        GradeIt = 1'b0;
        @(posedge clock);
        #1;

        // go to play again
        StartGame = 1'b1;
        MPLoaded = 1'b1;
        RoundNumber = 4'd2;
        @(posedge clock);
        #1;

        // play -> first_tick when GameWon = 1
        StartGame = 1'b0;
        MPLoaded = 1'b0;
        GameWon = 1'b1;
        @(posedge clock);
        #1;

        $finish;
    end

endmodule : controlFSM_test
