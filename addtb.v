module fa32bit_tb;
	parameter n = 32;
  	wire [n-1:0] s;
	wire cout;
	reg [n-1:0] a,b;
	reg cin;
	reg clk;
	reg reset;

	carry_save_adder_pipeline inst(
      		.sum(s),
		//.cout(cout),
		//.cin(cin),
		.reset(reset),
		.A(a),
      		.B(b),
      		.clk(clk)
	);

initial begin
  	$dumpfile("dump.vcd");
  	$dumpvars(1);
  	reset = 0;
	a = 32'b00000000000000000000000000000000;
	b = 32'b00000000000000000000000000000000;
  	clk = 1;
	cin = 1;
	reset = 1;
	end
	always #20 a = a+1;
	always #10 b = b+1;
  	always #1 clk = ~clk;
	//always #40 cin = ~cin;
	initial #1000 $finish;

endmodule

