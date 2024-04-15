module GpioEmu_tb;
	reg n_reset = 1;
	reg [15:0] saddress = 0;
	reg srd = 0;
	reg swr = 0; 
	reg [31:0] sdata_in = 0;
	reg [31:0] gpio_in = 0;
	reg gpio_latch = 0;
	reg clk = 0;
	
	wire [31:0] gpio_out_wire = 16'hz;
	wire [31:0] sdata_out_wire = 16'hz;
	
	initial begin
		forever begin
			# 1 clk = ~clk;
		end
	end
	
	GpioEmu test(n_reset, saddress, srd, swr, sdata_in, sdata_out_wire, gpio_in, gpio_latch, gpio_out_wire, clk);
	
	initial begin
		# 0 n_reset = 1;
		# 1 n_reset = 0;
		# 2 n_reset = 1;
		
		// zapis 4 adresy
		// os 1
		# 5 saddress = 16'h1094;
		// 8:5
		# 5 sdata_in = 16'b00111100000;
		# 6 swr = 1'b1;
		# 7 swr = 1'b0;
		# 8 saddress = 16'h0;
		# 8 sdata_in = 16'b0;
		
		// os 2
		# 10 saddress = 16'h1098;
		// 10:7
		# 10 sdata_in = 16'b11110000000;
		# 11 swr = 1'b1;
		# 12 swr = 1'b0;
		# 13 saddress = 16'h0;
		# 13 sdata_in = 16'b0;
		
		// zatrzymanie licznika
		# 15 saddress = 16'h109c;
		// 8 i 6
		# 15 sdata_in = 16'b0;
		# 16 swr = 1'b1;
		# 17 swr = 1'b0;
		# 18 saddress = 16'h0;
		# 18 sdata_in = 16'b0;
		
		// zly adres - test neutralnosci
		# 20 saddress = 16'h1090;
		# 20 sdata_in = 16'b11111111111;
		# 21 swr = 1'b1;
		# 22 swr = 1'b0;
		# 23 saddress = 16'h0;
		# 23 sdata_in = 16'b0;
		
		// odczyt
		// os 1
		# 26 gpio_in = 16'b00000001111;
		# 27 gpio_latch = 1'b1;
		# 28 gpio_latch = 1'b0;
		# 28 saddress = 16'h1094;
		# 29 srd = 1'b1;
		# 30 srd = 1'b0;
		# 31 saddress = 16'b0;
		
		// os 2
		# 34 gpio_in = 16'b1111000000000000;
		# 35 gpio_latch = 1'b1;
		# 36 gpio_latch = 1'b0;
		# 36 saddress = 16'h1098;
		# 37 srd = 1'b1;
		# 38 srd = 1'b0;
		# 39 saddress = 16'b0;
		
		// licznik - bit statusu - potwierdzenie ze licznik dziala
		# 44 saddress = 16'h109c;
		# 45 srd = 1'b1;
		# 46 srd = 1'b0;
		# 47 saddress = 16'b0;
		
		// zly adres - test neutralnosci
		# 50 gpio_in = 16'b11111111111;
		# 51 gpio_latch = 1'b1;
		# 52 gpio_latch = 1'b0;
		# 53 saddress = 16'h1090;
		# 53 srd = 1'b1;
		# 54 srd = 1'b0;
		# 55 saddress = 16'b0;

		
		// wlaczenie licznika
		# 58 saddress = 16'h109c;
		// 8 i 6
		# 58 sdata_in = 16'b00101000000;
		# 59 swr = 1'b1;
		# 60 swr = 1'b0;
		# 61 saddress = 16'h0;
		# 61 sdata_in = 16'b0;

		# 1000 $finish;
	end
	
	initial begin
		$dumpfile("GpioEmu.vcd");
		$dumpvars(0, GpioEmu_tb);
	end
	
	// $monitor
	
endmodule