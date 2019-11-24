
`timescale 1ns/1ps

module eglm35_tb;

   reg clk;
   reg rst_n;

	 wire [7:0] seg;
	 wire [3:0] sel;

	eglm35 DUT (
		.clk(clk), 
		.rst_n(rst_n), 
		.seg(seg), 
		.sel(sel)
		);
	
	initial begin
	     	clk = 1;
        rst_n = 0;
        #200
        @ (posedge clk)
        #3
        rst_n = 1;
        #2000
        $stop;
  end	
  
always #5 clk = ~clk;
  		
endmodule
