module egsr04(clk, rst_n, trig, echo, seg, sel);

	input clk;
	input rst_n;
	
	output trig;
	input echo;
	
	output [7:0] seg;
	output [3:0] sel;

	wire [15:0] dis;
	reg [15:0] dis_tmp;

	wire [3:0] k_dat;
	wire [3:0] h_dat;
	wire [3:0] d_dat;
	wire [3:0] u_dat;
	
	wire [7:0] k_num;
	wire [7:0] h_num;
	wire [7:0] d_num;
	wire [7:0] u_num;
	
	//HC-SR04驱动
	rs04_dri RSDRI(
		.clk(clk), 
		.rst_n(rst_n), 
		.trig(trig), 
		.echo(echo), 
		.dis(dis)
		);
		
	reg [31:0] del_cnt;
	wire [31:0] del_cnt_max = 48_000_00;
	
	reg [31:0] vla_sun_cut;
	
	always @ (posedge clk, negedge rst_n) begin
		if(rst_n == 0) begin
			del_cnt <= 0;
			dis_tmp <= 0;
			vla_sun_cut <= 0;
			end
		else
			if(del_cnt <= (del_cnt_max - 1))
					del_cnt <= del_cnt + 1'b1;	
			else begin
				dis_tmp <= dis;
				del_cnt <= 0;
				
			end
	end	
	
		//数据分离
	data_handling DATA_HANDLING (
		.dat(dis_tmp), 
		.k_dat(k_dat), 
		.h_dat(h_dat), 
		.d_dat(d_dat), 
		.u_dat(u_dat)
		);	
	
	//数据显示译码
	de_code DE_CODE_K(
		.src_num(k_dat), 
		.ed_num(k_num)
		);
		
	de_code DE_CODE_H(
		.src_num(h_dat), 
		.ed_num(h_num)
		);	
	
	de_code DE_CODE_D(
		.src_num(d_dat), 
		.ed_num(d_num)
		);
		
	de_code DE_CODE_U(
		.src_num(u_dat), 
		.ed_num(u_num)
		);
		
	nitu_dre NITU_DRE (
		.clk(clk), 
		.rst_n(rst_n), 
		.k_num(k_num), 
		.h_num(h_num), 
		.d_num(d_num), 
		.u_num(u_num), 
		.seg(seg), 
		.sel(sel)
		);	

endmodule
