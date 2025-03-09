module testbench;
reg clk,rst_n,seq_rdy;
reg [1:0]rx;
wire data_ack;
reg [23:0]conv_code;

integer k;

Top t1(
	.clk(clk),
	.rst_n(rst_n),
	.rx(rx),
	.seq_rdy(seq_rdy),
	.data_ack(data_ack)
);

initial begin
	clk = 0;
	forever begin
		clk = ~clk;
		#10 ;
	end
end

initial begin
	rst_n = 0;
	seq_rdy = 0;
	#20;
	rst_n = 1;
	seq_rdy = 1;
	conv_code = 26'b110100010001110000111101;
end


always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		k = 23;
	end else if(k <= 0) begin
		#400;
		$stop;
	end
end

always @(posedge data_ack) begin
	rx <= conv_code[k -: 2];
	k  <= k-2;
end

endmodule



