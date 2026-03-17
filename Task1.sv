`default_nettype none

//Task 1 module, acting as grader, we output
//amount of znarly and zood
module Task1
    (input logic [11:0] Guess,
     input logic GradeIt,
     input logic CLOCK_100,
     input logic reset,
     output logic [3:0] Znarly,
     output logic [3:0] Zood);

    //TCOD
    logic [11:0] masterPattern = 12'b001_010_011_100;

    logic [2:0] g0, g1, g2, g3;
    logic [2:0] m0, m1, m2, m3;

    //how many of each znarly and zood
    logic [3:0] znarlyval,zoodval;

    always_comb begin
        //split up by guess
        g3 = Guess[11:9];
        g2 = Guess[8:6];
        g1 = Guess[5:3];
        g0 = Guess[2:0];

        //split up by answer
        m3 = masterPattern[11:9];
        m2 = masterPattern[8:6];
        m1 = masterPattern[5:3];
        m0 = masterPattern[2:0];

        znarlyval = 0;
        zoodval = 0;

        //if correct spot and correct val add znarly
        if (g0 == m0)
            znarlyval = znarlyval + 1;
        if (g1 == m1)
            znarlyval = znarlyval + 1;
        if (g2 == m2)
            znarlyval = znarlyval + 1;
        if (g3 == m3)
            znarlyval = znarlyval + 1;

        //checks fr not znarly, then checks guess
        //with the other answer vals to see if zood
        //however also checks that znarly does not occur
        //since znarly takes precedence over zood
        if (g0 != m0) begin
            if ((g0 == m1 && g1 != m1) ||
                (g0 == m2 && g2 != m2) ||
                (g0 == m3 && g3 != m3))
                zoodval = zoodval + 1;
        end

        if (g1 != m1) begin
            if ((g1 == m0 && g0 != m0) ||
                (g1 == m2 && g2 != m2) ||
                (g1 == m3 && g3 != m3))
                zoodval = zoodval + 1;
        end

        if (g2 != m2) begin
            if ((g2 == m0 && g0 != m0) ||
                (g2 == m1 && g1 != m1) ||
                (g2 == m3 && g3 != m3))
                zoodval = zoodval + 1;
        end

        if (g3 != m3) begin
            if ((g3 == m0 && g0 != m0) ||
                (g3 == m1 && g1 != m1) ||
                (g3 == m2 && g2 != m2))
                zoodval = zoodval + 1;
        end

        //if grade it is pushed
        if (GradeIt) begin
            Znarly = znarlyval;
            Zood = zoodval;
        end
        else begin
            Znarly = 4'd0;
            Zood = 4'd0;
        end
    end

endmodule : Task1
