module Top(clk, rst_n, trig, echo, seg, sel,led,relay_out,beep);

	input clk;
	input rst_n;
	
	output trig;
	input echo;
	
	output [7:0] seg;
	output [3:0] sel;
	output reg relay_out;
	output reg beep;
	output reg[1:0] led;	
	
	wire [11:0] adc_vla;//温度
	reg [11:0] adc_vla_tmp;	
	
	wire eoc;
	reg soc = 1;
	wire [2:0] s = 3'b001;
	wire pd = 1'b0;

	wire clk0_out;
	wire stdby = 1'b0;
	wire extlock = 1'b1;	
	
	wire [15:0] dis;//超声波
	reg [15:0] dis_tmp;

	wire [3:0] k_dat;
	wire [3:0] h_dat;
	wire [3:0] d_dat;
	wire [3:0] u_dat;
	
	wire [7:0] k_num;
	wire [7:0] h_num;
	wire [7:0] d_num;
	wire [7:0] u_num;
	
	rs04_dri RSDRI(
		.clk(clk), 
		.rst_n(rst_n), 
		.trig(trig), 
		.echo(echo), 
		.dis(dis)
		);
	
	reg [31:0] del_cnt1;
	wire [31:0] del_cnt_max = 48_000_00;
	
	reg [31:0] vla_sun_cut;
	
	always @ (posedge clk, negedge rst_n) begin
		if(rst_n == 0) begin
			del_cnt1 <= 0;
			dis_tmp <= 0;
			vla_sun_cut <= 0;
			end
		else
			if(del_cnt1 <= (del_cnt_max - 1))
				del_cnt1 <= del_cnt1 + 1'b1;	
			else begin
				dis_tmp <= dis;
				del_cnt1 <= 0;
				if(dis < 60 )
					begin
						
						beep <= 1'b1;
					end

				else
					begin
						
						beep <= 1'b0;
					end
			end
	end	
	
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
				if(adc_vla > 265*1.25 && adc_vla < 300*1.25)
					relay_out <= 1'b0;
				else 
					relay_out <=1'b1;
			end
	end


	wire [63:0] adc_vla_tmp2;	
	
	assign adc_vla_tmp2 = ((adc_vla_tmp*1000) / 4096) * 3300 / 100;
	
	
	reg [31:0] view_cnt;
	reg [9:0] view_cnt1;
	wire [31:0] view_cnt_max = 24_000_000;
	wire [4:0] view_cnt_max1 =5'b11111;
	
	always @ (posedge clk, negedge rst_n) begin
		if(rst_n == 0) begin
			view_cnt <= 0;
			view_cnt1 <= 0;
			end
		else
			if(view_cnt == view_cnt_max)
				begin
					view_cnt <= 0;
					view_cnt1 <= view_cnt1 + 1'b1;
				end
			else if(view_cnt1 == view_cnt_max1)begin
				view_cnt1 <= 0;
			end
			else begin
				view_cnt <= view_cnt + 1'b1;
				view_cnt1 <= view_cnt1;
			end
			
	end
	
	reg [63:0] view_num;
	
	always @ (posedge clk, negedge rst_n) begin	
	if(rst_n == 0)
		begin
			view_num <= view_num;
		 	led <= 2'b00;
		end
	else if(view_cnt1 < 5'b01111)
		begin
		view_num <= adc_vla_tmp2;
			led <= 2'b10;
		end
	else if(view_cnt1 >= 5'b01111 && view_cnt1 < view_cnt_max1)
		 begin
			view_num <= dis;
			 led <= 2'b01;
		end
	else 
		begin
			view_num <= view_num;
			led <= led;
		end
	end
	
		
		//数据分离
	data_handling DATA_HANDLING (
		.dat(view_num), 
		.k_dat(k_dat), 
		.h_dat(h_dat), 
		.d_dat(d_dat), 
		.u_dat(u_dat)
		);	
	
	//数据显示译码
	//thousand
	de_code DE_CODE_K(
		.src_num(k_dat), 
		.ed_num(k_num)
		);
	//hundred
	de_code_p DE_CODE_H(
		.src_num(h_dat), 
		.ed_num(h_num)
		);	
	//decade
	de_code DE_CODE_D(
		.src_num(d_dat), 
		.ed_num(d_num)
		);
	
	
	//unit	
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
