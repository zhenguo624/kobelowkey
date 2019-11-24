module eglm35(clk, rst_n, seg, sel);

	input wire clk;
	input wire rst_n;
	
	output wire [7:0] seg;
	output wire [3:0] sel;
	
	wire [11:0] adc_vla;
	reg [11:0] adc_vla_tmp;
	
	wire [3:0] k_dat;
	wire [3:0] h_dat;
	wire [3:0] d_dat;
	wire [3:0] u_dat;
	
	wire [7:0] k_num;
	wire [7:0] h_num;
	wire [7:0] d_num;
	wire [7:0] u_num;	
	
	wire eoc;
	reg soc = 1;
	wire [2:0] s = 3'b001;
	wire pd = 1'b0;

	wire clk0_out;
	wire stdby = 1'b0;
	wire extlock = 1'b1;
	
	adc_clk_pll(
		.refclk(clk),
		.reset(!rst_n),
		.stdby(stdby),
		.extlock(extlock),
		.clk0_out(clk0_out)
		);
	
	lm35_adcch1 lm35_adcch (
		.clk(clk0_out), 
		.pd(pd), 
		.s(s), 
		.soc(soc), 
		.eoc(eoc), 
		.dout(adc_vla)
	);
	
	/*
	always @ (posedge clk0_out) begin
		if(eoc == 0) begin
			adc_vla_tmp <= 1234;
			soc <= 1'b1;
			end
		else begin
			adc_vla_tmp <= adc_vla;
			soc <= 1'b0;
	end
	*/
	
	reg [31:0] del_cnt;
	wire [31:0] del_cnt_max = 24_000_000;
	
	always @ (posedge clk, negedge rst_n) begin
		if(rst_n == 0) begin
			del_cnt <= 0;
			adc_vla_tmp <= 0;
			end
		else
			if(del_cnt < (del_cnt_max - 1))
					del_cnt <= del_cnt + 1'b1;	
			else begin
				adc_vla_tmp <= adc_vla;
				del_cnt <= 0;
			end
	end


	wire [63:0] adc_vla_tmp2;	
	
	assign adc_vla_tmp2 = ((adc_vla_tmp*1000) / 4096) * 3300 / 1000;
	
	//数据分离
	data_handling DATA_HANDLING (
		.dat(adc_vla_tmp2), 
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
	/*
	de_code DE_CODE_D(
		.src_num(d_dat), 
		.ed_num(d_num)
		);*/
		
	de_code_seg_dp(
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
