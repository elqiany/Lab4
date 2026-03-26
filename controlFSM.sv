`default_nettype none


//FSM that controls everything
module controlFSM
    (input logic clock,
     input logic reset, StartGame, MPLoaded,
     input logic GameWon, GradeIt,
     input logic [3:0] RoundNumber,
     input logic [3:0] NumGames,
     output logic [1:0] state,
     output logic RestartGame);

    //states
     typedef enum logic [1:0] {
         first_tick = 2'b00,
         pre_game = 2'b01,
         play = 2'b10,
         final_guess = 2'b11
     } state_t;

     state_t currState, nextState;


     always_ff @(posedge clock or posedge reset) begin
         if (reset)
             currState <= first_tick;
         else
             currState <= nextState;
     end

     always_comb begin
         nextState = currState;

         case (currState)
             first_tick: begin
                 nextState = pre_game;
            end

            pre_game: begin
                if (StartGame && MPLoaded && NumGames > 4'b0000)
                    nextState = play;
                else
                    nextState = pre_game;
            end

            play: begin
                if (GameWon)
                    nextState = first_tick;
                else if (RoundNumber == 4'b0110)
                    nextState = final_guess;
                else
                    nextState = play;
            end

            final_guess: begin
                if (GradeIt)
                    nextState = first_tick;
                else
                    nextState = final_guess;
            end

            default: begin
                nextState = first_tick;
            end
        endcase
    end

    //sets outputs
    always_comb begin
        state = currState;
        RestartGame = 1'b0;

        case (currState)
            play: RestartGame = 1'b1;
            default: RestartGame = 1'b0;
        endcase
    end

endmodule : controlFSM





