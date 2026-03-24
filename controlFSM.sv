`default_nettype none

module controlFSM
    (input logic CLOCK_100,
     input logic reset,

     input logic MPLoaded,
     input logic gameWon,
     input logic [3:0] roundNumber,
     input logic finalDone,

     output logic [1:0] state,
     output logic startGame);

     typedef enum logic [1:0] {
         first_tick = 2'b00,
         pre_game = 2'b01,
         play = 2'b10,
         final_guess = 2'b11
     } state_t;

     state_t currState, nextState;


     always_ff @(posedge CLOCK_100 or posedge reset) begin
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
                if (MPLoaded)
                    nextState = play;
                else
                    nextState = pre_game;
            end

            play: begin
                if (gameWon)
                    nextState = first_tick;
                else if (roundNumber == 4'd7)
                    nextState = final_guess;
                else
                    nextState = play;
            end

            final_guess: begin
                if (finalDone)
                    nextState = first_tick;
                else
                    nextState = final_guess;
            end

            default: begin
                nextState = first_tick;
            end
        endcase
    end

    always_comb begin
        state = currState;
        startGame = 1'b0;

        case (currState)
            first_tick: startGame = 1'b1;
            default: startGame = 1'b0;
        endcase
    end

endmodule : controlFSM



