module gpioemu_tb;
	reg n_reset = 1;
	reg [15:0] saddress = 0;
	reg srd = 0;
	reg swr = 0; 
	reg [31:0] sdata_in = 0;
	reg [31:0] gpio_in = 0;
	reg gpio_latch = 0;
	reg clk = 0;
	
	wire [31:0] gpio_out_s = 0;
	wire [31:0] sdata_out_s = 0;
	wire [31:0] gpio_in_s_insp = 0;
	
	initial begin
		forever begin
			# 1 clk = ~clk;
		end
	end
	
	gpioemu test(n_reset, saddress, srd, swr, sdata_in, sdata_out_s, gpio_in, gpio_latch, gpio_out_s, clk, gpio_in_s_insp);
	
	initial begin
		// 0 reset
		# 0 n_reset = 1;
		# 1 n_reset = 0;
		# 1 n_reset = 1;
		
		// 1 odczyt state - powinien byc 00 (czeka na dane)
		# 10 gpio_in = 16'b1;
		# 1 gpio_latch = 1'b1;
		# 1 gpio_latch = 1'b0;
		# 1 saddress = 16'hcc8;
		# 0 srd = 1;
		# 1 srd = 0;
		# 1 saddress = 0;
		# 0 gpio_in = 16'b0;
		
		// 2 zapis danych in
		# 10 saddress = 16'hcc0;
		# 0 sdata_in = 16'b10101010;
		# 0 swr = 1;
		# 1 swr = 0;
		# 1 saddress = 0;
		# 0 sdata_in = 16'b0;
		
		// 3 odczyt state powinien byc 01 (czeka na liczenie)
		# 10 gpio_in = 16'b1;
		# 1 gpio_latch = 1'b1;
		# 1 gpio_latch = 1'b0;
		# 1 saddress = 16'hcc8;
		# 0 srd = 1;
		# 1 srd = 0;
		# 1 saddress = 0;
		# 0 gpio_in = 16'b0;
		
		// 4 zapis komendy ctrl - 10 start liczenia
		# 10 saddress = 16'hcd8;
		# 0 sdata_in = 16'b1000000000;
		# 0 swr = 1;
		# 1 swr = 0;
		# 1 saddress = 0;
		# 0 sdata_in = 16'b0;
		
		// 5 odczyt state - powinien byc 10 (liczy)
		# 10 gpio_in = 16'b1;
		# 1 gpio_latch = 1'b1;
		# 1 gpio_latch = 1'b0;
		# 1 saddress = 16'hcc8;
		# 0 srd = 1;
		# 1 srd = 0;
		# 1 saddress = 0;
		# 0 gpio_in = 16'b0;
		
		// 6 odczyt result
		# 20 gpio_in = 16'b0;
		# 1 gpio_latch = 1'b1;
		# 1 gpio_latch = 1'b0;
		# 1 saddress = 16'hcd0;
		# 0 srd = 1;
		# 1 srd = 0;
		# 1 saddress = 0;
		# 0 gpio_in = 16'b0;
		
		// 7 odczyt state  - powinien byc 11 (policzyl)
		# 10 gpio_in = 16'b1;
		# 1 gpio_latch = 1'b1;
		# 1 gpio_latch = 1'b0;
		# 1 saddress = 16'hcc8;
		# 0 srd = 1;
		# 1 srd = 0;
		# 1 saddress = 0;
		# 0 gpio_in = 16'b0;
		
		// 8 zapis komendy ctrl - 01 indeks na 0
		# 10 saddress = 16'hcd8;
		# 0 sdata_in = 16'b100000000;
		# 0 swr = 1;
		# 1 swr = 0;
		# 1 saddress = 0;
		# 0 sdata_in = 16'b0;
		
		// 9 zapis danych in
		# 10 saddress = 16'hcc0;
		# 0 sdata_in = 16'b1010101;
		# 0 swr = 1;
		# 1 swr = 0;
		# 1 saddress = 0;
		# 0 sdata_in = 16'b0;
		
		// 10 zapis komendy ctrl - 10 start liczenia
		# 10 saddress = 16'hcd8;
		# 0 sdata_in = 16'b1000000000;
		# 0 swr = 1;
		# 1 swr = 0;
		# 1 saddress = 0;
		# 0 sdata_in = 16'b0;
		
		// 11 odczyt result
		# 20 gpio_in = 16'b0;
		# 1 gpio_latch = 1'b1;
		# 1 gpio_latch = 1'b0;
		# 1 saddress = 16'hcd0;
		# 0 srd = 1;
		# 1 srd = 0;
		# 1 saddress = 0;
		# 0 gpio_in = 16'b0;
		
		// 12 zapis danych in
		# 10 saddress = 16'hcc0;
		# 0 sdata_in = 16'b1111;
		# 0 swr = 1;
		# 1 swr = 0;
		# 1 saddress = 0;
		# 0 sdata_in = 16'b0;
		
		// 13 zapis komendy ctrl - 10 start liczenia
		# 10 saddress = 16'hcd8;
		# 0 sdata_in = 16'b1000000000;
		# 0 swr = 1;
		# 1 swr = 0;
		# 1 saddress = 0;
		# 0 sdata_in = 16'b0;
		
		// 14 odczyt result
		# 40 gpio_in = 16'b0;
		# 1 gpio_latch = 1'b1;
		# 1 gpio_latch = 1'b0;
		# 1 saddress = 16'hcd0;
		# 0 srd = 1;
		# 1 srd = 0;
		# 1 saddress = 0;
		# 0 gpio_in = 16'b0;
		
		// 15 zapis komendy ctrl - 00 wyzerowanie pamieci
		# 10 saddress = 16'hcd8;
		# 0 sdata_in = 16'b1;
		# 0 swr = 1;
		# 1 swr = 0;
		# 1 saddress = 0;
		# 0 sdata_in = 16'b0;
		
		// 16 odczyt state - powinien byc 00 (czeka na dane)
		# 10 gpio_in = 16'b1;
		# 1 gpio_latch = 1'b1;
		# 1 gpio_latch = 1'b0;
		# 1 saddress = 16'hcc8;
		# 0 srd = 1;
		# 1 srd = 0;
		# 1 saddress = 0;
		# 0 gpio_in = 16'b0;
		
		// test neutralnosci
		# 10 gpio_in = 16'b1101;
		# 1 gpio_latch = 1'b1;
		# 1 gpio_latch = 1'b0;
		# 1 saddress = 16'hcc4;
		# 0 srd = 1;
		# 1 srd = 0;
		# 1 saddress = 0;
		# 0 gpio_in = 16'b0;
		
		// test podtrzymania
		# 10 saddress = 16'hcc4;
		# 0 sdata_in = 16'b1011;
		# 0 swr = 1;
		# 1 swr = 0;
		# 1 saddress = 0;
		# 0 sdata_in = 16'b0;
		
		// test neutralnosci
		# 10 gpio_in = 16'b1101;
		# 1 gpio_latch = 1'b1;
		# 1 gpio_latch = 1'b0;
		# 1 saddress = 16'hccc;
		# 0 srd = 1;
		# 1 srd = 0;
		# 1 saddress = 0;
		# 0 gpio_in = 16'b0;
		
		// test podtrzymania
		# 10 saddress = 16'hccc;
		# 0 sdata_in = 16'b1011;
		# 0 swr = 1;
		# 1 swr = 0;
		# 1 saddress = 0;
		# 0 sdata_in = 16'b0;
		
		# 1000 $finish;
	end
	
	initial begin
		$dumpfile("gpioemu.vcd");
		$dumpvars(0, gpioemu_tb);
	end
	
	// $monitor
	
endmodule