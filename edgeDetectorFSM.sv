`default_nettype none


module edgeDetectorFSM
    (input logic CLOCK_100,
     input logic reset,
     input logic btn,
     output logic grade_it);

    typedef enum logic {
        wait_press,
        held
    } state_t;

    state_t currState, nextState;

    always_ff @(posedge CLOCK_100 or posedge reset) begin
        if (reset)
            currState <= wait_press;
        else
            currState <= nextState;
    end

    always_comb begin
        nextState = currState;
        grade_it = 1'b0;

        case (currState)
            wait_press: begin
                if (btn) begin
                    grade_it = 1'b1;
                    nextState = held;
                end
            end

            held: begin
                if (!btn)
                    nextState = wait_press;
            end

            default: begin
                nextState = wait_press;
                grade_it = 1'b0;
            end
        endcase
    end

endmodule : edgeDetectorFSM
