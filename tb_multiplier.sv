
`timescale 1ns/1ps

module testbench ();
  
   logic RESET;
   logic CLK;
   logic START;
   logic [31:0] OUT;
   logic DONE;
   logic [15:0] IN1;   
   logic [15:0] IN2;

   multiplier DUT(.clk(CLK), .reset(RESET), .start(START), .in1(IN1), .in2(IN2), .out(OUT), .done(DONE));
   
   always
     begin 
        #5 CLK = !CLK;
     end
   
   initial
     begin
        CLK = 0;
        RESET = 0;
	START = 0;        

        #2 RESET = 1;
        
        @(negedge CLK);
        
	RESET = 0;
	
        @(negedge CLK);
        
	IN1 = 16'd8648;
	IN2 = 16'd2301;

	// expected out: 19899048

        @(negedge CLK);

	START = 1;

	@(negedge CLK);

	@(negedge CLK);

	@(negedge CLK);

	START = 0;

	#200
     
        $stop;
     end
   
endmodule
