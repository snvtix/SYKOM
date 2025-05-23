/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSED */
/* verilator lint_off MULTIDRIVEN */
/* verilator lint_off COMBDLY */
/* verilator lint_off WIDTH */
/* verilator lint_off COMBDLY */

module gpioemu(
	n_reset,
	saddress[15:0],
	srd,
	swr,
	sdata_in[31:0],
	sdata_out[31:0], 
	gpio_in[31:0],
	gpio_latch,
	gpio_out[31:0],
	clk,
	gpio_in_s_insp[31:0]
 );
 
	input n_reset;
	input [15:0] saddress;
	input srd;
	input swr;
	
	input [31:0] sdata_in;
	output reg [31:0] sdata_out;
	reg [31:0] sdata_out_s;

	input [31:0] gpio_in;
	input gpio_latch;
	output reg [31:0] gpio_out;
	output reg [31:0] gpio_in_s_insp;
	
	reg [31:0] gpio_in_s;
	reg [31:0] gpio_out_s;
	
	input clk;
	
	// input - sygnal wejsciowy do modulu (z procesora)
	// output - sygnal wyjsciowy z modulu (do procesora)
	// reg -  nie odnosi się do fizycznego rejestru sprzętowego, 
	// ale jest typem danych używanym do przechowywania wartości między zdarzeniami zegara.
	
	// -----------------------------------------------------------------
	
	reg [7:0] in;
	reg [1:0] ctrl;
	reg [1:0] state;
	reg [15:0] result;
	
	reg [7:0] memory [0:249]; 
	reg [7:0] alloc_num; // wspolrzedna obecnej alokacji
	reg [7:0] alloc_num_all; // liczba alokacji
	reg zero_sig; // sygnal zerowania pamieci
	reg [7:0] counter;
	
	reg crc_count_sig; // sygnal liczenia crc
	reg [15:0] polynomial;
	reg [15:0] crc;
	reg [7:0] byte_num;
	reg [3:0] bit_num;
	
	// -----------------------------------------------------------------
	
	// reset poczatkowy
	always @( negedge n_reset ) begin
		gpio_out_s <= 16'b0;
		gpio_in_s <= 16'b0; 
		sdata_out_s <= 16'b0;
		
		in <= 8'b0;
		ctrl <= 2'b0;
		state <= 2'b0;
		result <= 16'b0;
		
		alloc_num <= 8'b0;
		alloc_num_all <= 8'b0;
		zero_sig <= 1'b0;
		counter <= 8'b0;
		
		crc_count_sig <= 1'b0;
		polynomial <= 16'h589;
		crc <= 16'h0;
		byte_num <= 8'b0;
		bit_num <= 4'b0;
	end

	// zatrzasniecie
	always @(posedge gpio_latch) begin
		gpio_in_s <= gpio_in;
	end
	
	// -----------------------------------------------------------------
	
	// CRC
	always @(posedge clk)
	begin
		if(crc_count_sig == 1'b1) begin
			if(byte_num < alloc_num_all) begin
				if(bit_num == 0) begin 
					crc <= crc ^ (memory[byte_num] << 8);
					bit_num <= bit_num + 1;
				end
				else if (bit_num <= 8) begin
					crc <= (crc[15]) ? ((crc << 1) ^ polynomial) : (crc << 1);
					bit_num <= bit_num + 1;
				end
				else begin
					bit_num <= 4'b0;
					byte_num <= byte_num + 1;
				end
			end
			else begin
				result <= crc ^ 16'h0001;
				state <= 2'b11;
				crc_count_sig <= 1'b0;
			end
		end
		else if (crc_count_sig == 1'b0) begin
			bit_num <= 4'b0;
			byte_num <= 8'b0;
			crc <= 16'h0;
		end
	end

	// -----------------------------------------------------------------

	// zapis
	always @(posedge swr) begin
		if(saddress == 16'hcc0) begin
			// in
			if(alloc_num_all < 250) begin
				gpio_out_s[7:0] <= sdata_in[7:0];
				in <= sdata_in[7:0];
				memory[alloc_num] <= sdata_in[7:0];
				
				if(alloc_num == alloc_num_all) begin
					alloc_num <= alloc_num + 1;
					alloc_num_all <= alloc_num_all + 1;
				end
				else begin
					alloc_num <= alloc_num + 1;
				end
				state <= 2'b01;
			end
		end
		else if(saddress == 16'hcd8) begin 
			// ctrl
			ctrl <= sdata_in[9:8];
			gpio_out_s[9:8] <= sdata_in[9:8];
			if(sdata_in[9:8] == 2'b0) begin
				// 0 - wyzerowanie pamieci
				in <= 8'b0;
				zero_sig <= 1'b1;
				result <= 16'b0;
				state <= 2'b00;
			end
			else if(sdata_in[9:8]== 2'b1) begin
				// 1 - numer alokacji na 0
				alloc_num <= 8'b0;
			end
			else if(sdata_in[9:8] == 2'b10) begin
				// 2 - sygnal startujacy liczenie na 1 - start
				state <= 2'b10;
				crc_count_sig <= 1'b1;
			end
		end
	end
	
	// -----------------------------------------------------------------

	// odczyt
	always @(posedge srd) begin
		sdata_out_s <= 16'b0;
		if(saddress == 16'hcc8) begin 
			// state
			gpio_in_s[11:10] <= state; 
			sdata_out_s[11:10] <= state;
		end
		else if(saddress == 16'hcd0) begin 
			// result
			gpio_in_s[15:0] <= result; 
			sdata_out_s[15:0] <= result;
		end
	end
	
	// -----------------------------------------------------------------
	
	// zerowanie pamieci
	always @(posedge clk)
	begin
		if(zero_sig == 1'b1) begin
			if(counter < alloc_num_all) begin
				memory[counter] <= 8'b0;
				counter <= counter + 1;
			end
			else begin
				counter <= 8'b0;
				alloc_num <= 8'b0;
				zero_sig <= 1'b0;
			end
		end
	end
	
	// -----------------------------------------------------------------

	always @(*) begin
		gpio_out = gpio_out_s;
		sdata_out = sdata_out_s;
		gpio_in_s_insp = gpio_in_s;
	end
	
endmodule
