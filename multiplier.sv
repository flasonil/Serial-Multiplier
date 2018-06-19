
module multiplier
(
	input logic [15:0] in1,
	input logic [15:0] in2,
	input logic start,
	input logic reset,
	input logic clk,

	output logic [31:0] out,
	output logic done
);


enum {IDLE,RUN,DONE} state, next_state;

logic load,clear;
logic [31:0] partial,par_out_a;
logic [15:0] par_out_b;
logic [5:0] count;


always_ff@ (posedge clk, posedge reset)				//SHIFT REGISTER A 32 bit
begin 
	if (reset == 1'b1)
		par_out_a <= 32'd0;
	else if(load == 1'b1)
		par_out_a <= {16'd0,in1}; 	
	else	
		par_out_a <= {par_out_a[30:0],1'b0};
				
end

always_ff@ (posedge clk, posedge reset)				//SHIFT REGISTER B 16 bit
begin
	if (reset == 1'b1)
		par_out_b <= 16'd0;
	else if(load == 1'b1)
		par_out_b <= in2; 	
	else	
		par_out_b <= {1'b0, par_out_b[15:1]};
				
end

always @(par_out_b,par_out_a)					//MULTIPLEXER
begin
	if(par_out_b[0] == 1'b0)
		partial <= 32'd0;
	else
		partial <= par_out_a;
end

always_ff@ (posedge clk, posedge reset)				//ACCUMULATOR
begin
	if (reset == 1'b1 || clear)
		out <= 32'd0;
	else
		out <= out+partial;
end;


always@ (posedge clk, posedge reset)				//COUNTER
begin
	if (reset == 1'b1 || state!=RUN)
		count <= 5'b10001;
	else 
		count <= count-5'b00001;
end;

always_ff@ (posedge clk, posedge reset)				//STATE REGISTER
begin
	if (reset == 1'b1)
		state <= IDLE;
	else
		state <= next_state;
end;


always@(start,count,state)					//FSM COMB
begin
	case(state)
		IDLE:
		begin
			if(start == 1)
				next_state <= RUN;
			else
				next_state <= IDLE;
			
			load <= 0;
			clear <= 1;
			done <= 0;
		end
		
		RUN:
		begin
			if(count == 5'b00000)
				next_state <= DONE;
			else
				next_state <= RUN;
			
			if(count == 5'b10000) 
				load <= 1;
			else
				load <= 0;
			clear <= 0;
			done <= 0;
		end

		DONE:
		begin
			next_state <= IDLE;
			load <= 0;
			clear <= 0;
			done <= 1;
		end
		
		default:
		begin
			next_state <= IDLE;
			load <= 0;
			clear <= 1;
			done <= 0;
		end
		
	endcase
end;
	
endmodule
