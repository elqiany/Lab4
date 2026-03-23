`default_nettype none

module Task1_test;

    logic [11:0] Guess;
    logic GradeIt;
    logic CLOCK_100;
    logic reset;
    logic [3:0] Znarly;
    logic [3:0] Zood;

    Task1 DUT (.Guess(Guess),
               .GradeIt(GradeIt),
               .*);

    initial begin
        CLOCK_100 = 0;
        forever #5 CLOCK_100 = ~CLOCK_100;
    end

    initial begin
        $monitor($time,,
            "Guess = %b, GradeIt = %b, Znarly = %b, Zood = %b",
            Guess, GradeIt, Znarly, Zood);

        //start
        reset = 0; Guess = 12'b0; GradeIt = 0;

        #10;

        //= masterpattern
        Guess = 12'b001_010_011_100; GradeIt = 1;
        #10;
        GradeIt = 0;
        #10;

        //4 zoods
        Guess = 12'b100_011_010_001; GradeIt = 1;
        #10;
        GradeIt = 0;
        #10;

        //1 znarly, 3 zoods ?
        Guess = 12'b001_001_001_001; GradeIt = 1;
        #10;
        GradeIt = 0;
        #10;

        //2 znarly, 1 zood
        Guess = 12'b001_010_100_111; GradeIt = 1;
        #10;
        GradeIt = 0;
        #10;

        #10; $finish;

    end

endmodule : Task1_test
