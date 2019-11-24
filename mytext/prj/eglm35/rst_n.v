module rst_n
(
	input	wire	clk,
	output	reg		rst_n
);

reg[3:0] cnt;

always@(posedge clk)
begin
	if(cnt == 4'hf)
		cnt <= cnt;
	else
		cnt <= cnt + 1'b1;
end

always@(posedge clk)
begin
	if(cnt == 4'hf)
		rst_n <= 1'b1;
	else
		rst_n <= 1'b0;
end

endmodule