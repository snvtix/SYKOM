module GpioEmu(n_reset, saddress[15:0], srd, swr, sdata_in[31:0], sdata_out[31:0],
gpio_in[31:0], gpio_latch, gpio_out[31:0], clk);

	input n_reset;
	input [15:0] saddress;
	input srd;
	input swr;
	input [31:0] sdata_in;
	output[31:0] sdata_out;

	input [31:0] gpio_in;
	input gpio_latch;
	output [31:0] gpio_out;
	reg [31:0] gpio_in_s;
	reg [31:0] gpio_out_s;
	reg [31:0] sdata_out;
	input clk;

	reg BS;
	reg start;
	reg stop;
	reg [7:0] counter;

	assign gpio_out = gpio_out_s;

	always @(negedge n_reset)
	begin
		sdata_out <= 16'hz;
		gpio_in_s <= 16'h0;
		gpio_out_s <= 16'hz;
		BS <= 1'b0;
		counter <= 8'd134;
		start <= 1'b1;
		stop <= 1'b1;
	end

	// zatrzasniecie
	always @(posedge gpio_latch)
	begin
		gpio_in_s <= gpio_in;
	end

	// licznik
	always @(posedge clk)
	begin
		if(stop == 1'b0)
			begin 
				counter <= 8'd134;
				BS <= 1'b0;
			end
		else if(start == 1'b1)
			begin 
				if(counter == 8'd255)
					begin 
						BS <= 1'b1;
						start <= 1'b0;
						stop <= 1'b0;
					end
				else if(counter != 8'd255)
					begin
						counter <= counter + 8'd1;
					end
			end
	end

	// zapis
	always @(posedge swr)
	begin
		if(saddress == 16'h1094)
			begin 
				gpio_out_s[3:0] <= sdata_in[8:5];
			end
		else if(saddress == 16'h1098)
			begin 
				gpio_out_s[15:12] <= sdata_in[10:7];
			end
		else if(saddress == 16'h109c)
			begin
				gpio_out_s[8] <= sdata_in[8];
				gpio_out_s[6] <= sdata_in[6];
				start <= sdata_in[8];
				stop <= sdata_in[6];
			end
		else 
			begin
				gpio_out_s[31:0] <= 32'hz;
			end
	end

	// odczyt
	always @(posedge srd)
	begin
		if(saddress == 16'h1094)
			begin
				sdata_out[8:5] <= gpio_in_s[3:0];
			end
		else if(saddress == 16'h1098)
			begin 
				sdata_out[10:7] <= gpio_in_s[15:12];
			end
		else if(saddress == 16'h109c)
			begin 
				sdata_out[3] <= BS;
			end
		else 
			begin
				sdata_out[31:0] <= 32'hz;
			end
	end

endmodule