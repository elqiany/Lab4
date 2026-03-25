`default_nettype none

module edgeDetectorFSM_test;

    logic clock, reset, btn;
    logic edge_detected;

    edgeDetectorFSM dut (
        .clock(clock),
        .reset(reset),
        .btn(btn),
        .edge_detected(edge_detected)
    );

    // clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    initial begin
        $monitor($time,,
            " Current State: %b, btn = %b, Next State = %b, edge_detected = %b",
            dut.currState, btn, dut.nextState, edge_detected);

        reset = 1;
        btn = 0;

        @(posedge clock);
        reset = 0;
        btn = 0;

        @(posedge clock);
        #1;
        btn = 1;   // first press should pulse grade_it

        @(posedge clock);
        #1;
        btn = 0;   // release back to wait_press

        @(posedge clock);
        #1;
        btn = 1;   // second press should pulse again

        @(posedge clock);
        #1;
        btn = 1;   // held down should NOT pulse again

        @(posedge clock);
        #1;
        btn = 0;   // release

        @(posedge clock);
        #1;
        btn = 1;   // press again should pulse again

        @(posedge clock);
        #1;
        btn = 0;

        @(posedge clock);
        #1;
        $finish;
    end

endmodule : edgeDetectorFSM_test
