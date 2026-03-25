//`default_nettype none

//FSM module abstract version that directly
//assigns the next state
module myAbstractFSM(
    output logic [3:0] credit,
    output logic drop,
    input logic [1:0] coin,
    input logic clock, reset);

    enum logic [2:0] {S0, S1, S2, S3,
                      D0, D1, D2, D3}
                      currState, nextState;

    always_comb begin
        case(currState)
            //start case
            S0: begin
                case (coin)
                    2'b00: nextState = S0;
                    2'b01: nextState = S1;
                    2'b10: nextState = S3;
                    2'b11: nextState = D1;
                endcase
            end
            //1Cred case
            S1: begin
                case (coin)
                    2'b00: nextState = S1;
                    2'b01: nextState = S2;
                    2'b10: nextState = D0;
                    2'b11: nextState = D2;
                endcase
            end
            //2Cred case
            S2: begin
                case (coin)
                    2'b00: nextState = S2;
                    2'b01: nextState = S3;
                    2'b10: nextState = D1;
                    2'b11: nextState = D3;
                endcase
            end
            //3Cred case
            S3: begin
                case (coin)
                    2'b00: nextState = S3;
                    2'b01: nextState = D0;
                    2'b10: nextState = D2;
                    2'b11: nextState = D0;
                endcase
            end
            //0Drop case
            D0: begin
                case (coin)
                    2'b00: nextState = S0;
                    2'b01: nextState = S1;
                    2'b10: nextState = S3;
                    2'b11: nextState = D1;
                endcase
            end
            //1Drop case
            D1: begin
                case (coin)
                    2'b00: nextState = S1;
                    2'b01: nextState = S2;
                    2'b10: nextState = D0;
                    2'b11: nextState = D2;
                endcase
            end
            //2Drop case
            D2: begin
                case (coin)
                    2'b00: nextState = S2;
                    2'b01: nextState = S3;
                    2'b10: nextState = D1;
                    2'b11: nextState = D3;
                endcase
            end
            //3Drop case
            D3: begin
                case (coin)
                    2'b00: nextState = S3;
                    2'b01: nextState = D0;
                    2'b10: nextState = D2;
                    2'b11: nextState = D0;
                endcase
            end

            default: nextState = S0;

        endcase
    end

    //declaring drop and credits (output) for each state
    always_comb begin
        credit = 4'b0000; drop = 1'b0;
        case (currState)
            S0: begin
                credit = 4'b0000; drop = 1'b0;
            end
            S1: begin
                credit = 4'b0001; drop = 1'b0;
            end
            S2: begin
                credit = 4'b0010; drop = 1'b0;
            end
            S3: begin
                credit = 4'b0011; drop = 1'b0;
            end
            D0: begin
                credit = 4'b0000; drop = 1'b1;
            end

            D1: begin
                credit = 4'b0001; drop = 1'b1;
            end

            D2: begin
                credit = 4'b0010; drop = 1'b1;
            end

            D3: begin
                credit = 4'b0011; drop = 1'b1;
            end
        endcase
    end

    always_ff @(posedge clock)
        if (reset)
            currState <= S0;
        else
            currState <= nextState;

endmodule : myAbstractFSM
