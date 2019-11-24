module data_handling(dat, k_dat, h_dat, d_dat, u_dat);

	input wire [15:0] dat;

	output reg [3:0] k_dat;	//ǧλ
	output reg [3:0] h_dat;	//��λ
	output reg [3:0] d_dat;	
	output reg [3:0] u_dat;	//��λ
	
	always @ (*) begin
		k_dat = dat % 10000 / 1000;
		h_dat = dat % 1000 / 100;
		d_dat = dat % 100 / 10;
		u_dat = dat % 10;
	end

endmodule
