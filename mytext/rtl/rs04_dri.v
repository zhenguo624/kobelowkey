module rs04_dri(clk, rst_n, trig, echo, dis);

	input clk;
	input rst_n;
	
	output reg trig;
	input echo;
	
	output [31:0] dis;

	parameter T10usMAX = 480;
	parameter ECHO_TMAX = 312000 + 480;
	
	reg [31:0] t10us_cnt;
	reg [31:0] echo_t; 
	reg [31:0] echo_t_tmp;
	
	
	always @ (posedge clk, negedge rst_n) begin
		if(rst_n == 0) begin
			t10us_cnt <= 0;
			trig <= 0;
			echo_t <= 0;
			echo_t_tmp <= 0;
			end
		else begin
			if(t10us_cnt <= (T10usMAX - 1)) begin
				t10us_cnt <= t10us_cnt + 1;	
				trig <= 1;		
				end
			else if((t10us_cnt > (T10usMAX - 1)) && (t10us_cnt <= (ECHO_TMAX - 1))) begin
					t10us_cnt <= t10us_cnt + 1;	
					trig <= 0;
					if(echo == 1) begin
						echo_t <= echo_t + 1;
						end
					else  if(echo_t > 0)begin
						echo_t_tmp <= echo_t;
						end
				end
			else begin
				t10us_cnt <= 0;
				echo_t <= 0;
				end
		end
	end
	
	assign dis = (echo_t_tmp / 24) * 17000 / 1000_000 ;
	
endmodule
