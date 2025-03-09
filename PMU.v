module PMU (
    input clk,
    input rst_n,
    input [2:0] hamming_dist,
    input [1:0] currentState,
    input inputBit,
	output reg [15:0]decoded_msg,
	output reg [15:0]decoded_msg_test
	); 
parameter depth = 15;
reg [3:0] path_metrics [0:3];
reg [3:0] new_metrics [0:3];
wire [3:0] candidate_metric;
reg [1:0] nextState;
reg [3:0] count;
reg [15:0] survivors [0:3];
reg [15:0] new_survivors [0:3];
reg [1:0] new_path;
reg [3:0] bit_count [0:3]; 
reg [3:0] min_value;
reg [1:0] final_state;
reg [3:0] valid_count;

assign candidate_metric = path_metrics[currentState] + hamming_dist;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		path_metrics[0] <= 4'd0;
		path_metrics[1] <= 4'd3;
		path_metrics[2] <= 4'd3;
		path_metrics[3] <= 4'd3;
	end else if (count == 8) begin
		path_metrics[0] <= new_metrics[0];
		path_metrics[1] <= new_metrics[1];
		path_metrics[2] <= new_metrics[2];
		path_metrics[3] <= new_metrics[3];
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		new_metrics[0] <= 4'd3;
		new_metrics[1] <= 4'd3;
		new_metrics[2] <= 4'd3;
		new_metrics[3] <= 4'd3;
	end else if (count == 8 && valid_count < 12) begin
		new_metrics[0] <= 4'd3;
		new_metrics[1] <= 4'd3;
		new_metrics[2] <= 4'd3;
		new_metrics[3] <= 4'd3;
	end else begin
		
		if (candidate_metric < new_metrics[nextState]) begin
			case (nextState)
				2'd0: new_metrics[0] <= candidate_metric;
				2'd1: new_metrics[1] <= candidate_metric;
				2'd2: new_metrics[2] <= candidate_metric;
				2'd3: new_metrics[3] <= candidate_metric;
			endcase
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		survivors[0] <= 0;
		survivors[1] <= 0;
		survivors[2] <= 0;
		survivors[3] <= 0;
	end else begin
		if(count == 8)begin
			survivors[0] <= new_survivors[0];
			survivors[1] <= new_survivors[1];
			survivors[2] <= new_survivors[2];
			survivors[3] <= new_survivors[3];
		end
		if(bit_count[0] >= depth || bit_count[1] >= depth || bit_count[2] >= depth || bit_count[3] >= depth)begin
			survivors[0] <= 16'd0;
			survivors[1] <= 16'd0;
			survivors[2] <= 16'd0;
			survivors[3] <= 16'd0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		bit_count[0] <= 4'd0;
		bit_count[1] <= 4'd0;
		bit_count[2] <= 4'd0;
		bit_count[3] <= 4'd0;
	end else begin
		if(count == 8)begin
			bit_count[0] <= bit_count[0] + 4'd1;
			bit_count[1] <= bit_count[1] + 4'd1;
			bit_count[2] <= bit_count[2] + 4'd1;
			bit_count[3] <= bit_count[3] + 4'd1;
		end
		if(bit_count[0] >= depth || bit_count[1] >= depth || bit_count[2] >= depth || bit_count[3] >= depth)begin
			bit_count[0] <= 4'd0;
			bit_count[1] <= 4'd0;
			bit_count[2] <= 4'd0;
			bit_count[3] <= 4'd0;
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		decoded_msg <= 16'b0;
	end else if(bit_count[0] >= depth || bit_count[1] >= depth || bit_count[2] >= depth || bit_count[3] >= depth)begin
		decoded_msg <= survivors[final_state];
	end else begin
		decoded_msg_test <= survivors[final_state];
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		min_value <= 4'b0;
		final_state <= 2'b0;
	end else begin
		min_value <= new_metrics[0];
		if(new_metrics[1] < min_value)begin
			min_value <= new_metrics[1];
			final_state <= 1;
		end else if(new_metrics[2] < min_value)begin
			min_value <= new_metrics[2];
			final_state <= 2;
		end else if(new_metrics[3] < min_value) begin
			min_value <= new_metrics[3];
			final_state <= 3;
		end
	end
end

//always @(posedge clk or negedge rst_n) begin
//	if(!rst_n)begin
//		final_state <= 2'b0;
//	end else begin
//		final_state <= 0;
//		if(path_metrics[1] < min_value)begin
//			final_state <= 1;
//		end else if(path_metrics[2] < min_value)begin
//			final_state <= 2;
//		end else if(path_metrics[3] < min_value) begin
//			final_state <= 3;
//		end
//	end
//end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		new_survivors[0] <= 0;
		new_survivors[1] <= 0;
		new_survivors[2] <= 0;
		new_survivors[3] <= 0;
	end else begin
		if (candidate_metric < new_metrics[nextState]) begin
			case (nextState)
				2'd0:new_survivors[0] <= {survivors[currentState][11:0], inputBit}; 
				2'd1:new_survivors[1] <= {survivors[currentState][11:0], inputBit}; 
				2'd2:new_survivors[2] <= {survivors[currentState][11:0], inputBit}; 
				2'd3:new_survivors[3] <= {survivors[currentState][11:0], inputBit}; 
			endcase
			
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count <= 0;
	end else begin
		if (count == 8) begin
			count <= 1;
		end else begin
			count <= count + 1;
		end    
	end
end


always @(count) begin
	if (!rst_n) begin
		valid_count <= 0;
	end else begin
		if(count == 8)begin
			valid_count <= valid_count +1;
		end
	end
end

always @(*) begin
	if (!rst_n) begin
		nextState = 0;
	end else begin
		case (currentState)
			2'd0: nextState <= (inputBit == 0) ? 2'd0 : 2'd2;
			2'd1: nextState <= (inputBit == 0) ? 2'd0 : 2'd2;
			2'd2: nextState <= (inputBit == 0) ? 2'd1 : 2'd3;
			2'd3: nextState <= (inputBit == 0) ? 2'd1 : 2'd3;
			default: nextState <= 2'd0;
		endcase
	end
end

endmodule
