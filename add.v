module CLA_Adder(a,b,cin,sum,cout);

	input[3:0] a,b;
	input cin;
	output [3:0] sum;
	output cout;
	wire p0,p1,p2,p3,g0,g1,g2,g3,c1,c2,c3,c4;
	
	assign p0 = (a[0]^b[0]),
	p1 = (a[1]^b[1]),
	p2 = (a[2]^b[2]),
	p3 = (a[3]^b[3]);
	assign g0 = (a[0]&b[0]),
	g1 = (a[1]&b[1]),
	g2 = (a[2]&b[2]),
	g3 = (a[3]&b[3]);
	assign c0 = cin,
	c1 = g0 | (p0&cin),
	c2 = g1 | (p1&g0) | (p1&p0&cin),
	c3 = g2 | (p2&g1) | (p2&p1&g0) | (p1&p1&p0&cin),
	c4 = g3 | (p3&g2) | (p3&p2&g1) | (p3&p2&p1&g0) | (p3&p2&p1&p0&cin);
	assign sum[0]=p0^c0,
	sum[1] = p1^c1,
	sum[2] = p2^c2,
	sum[3] = p3^c3;
	assign cout = c4;
	
endmodule

	module mux2X14b( in0,in1,sel,out);
	input [3:0] in0,in1;
	input sel;
	output [3:0] out;
	assign out = (sel) ? in1 : in0;
endmodule

	module mux2X11b( in0,in1,sel,out);
	input in0,in1;
	input sel;
	output out;
	assign out = (sel) ? in1 : in0;
endmodule


module carry_select_adder_4bit_slice(a, b, cin, sum, cout);
	input [3:0] a,b;
	input cin;
	output [3:0] sum;
	output cout;

	wire [3:0] s0,s1;
	wire c0,c1;

	CLA_Adder rca1(
	.a(a[3:0]),
	.b(b[3:0]),
	.cin(1'b0),
	.sum(s0[3:0]),
	.cout(c0));

	CLA_Adder rca2(
	.a(a[3:0]),
	.b(b[3:0]),
	.cin(1'b1),
	.sum(s1[3:0]),
	.cout(c1));

	mux2X14b ms0(
	.in0(s0[3:0]),
	.in1(s1[3:0]),
	.sel(cin),
	.out(sum[3:0]));

	mux2X11b mc0(
	.in0(c0),
	.in1(c1),
	.sel(cin),
	.out(cout));
endmodule

module carry_select_adder_16bit(a, b, cin, sum, cout);
	input [15:0] a,b;
	input cin;
	output [15:0] sum;
	output cout;

	wire [2:0] c;

	CLA_Adder rca1(
	.a(a[3:0]),
	.b(b[3:0]),
	.cin(cin),
	.sum(sum[3:0]),
	.cout(c[0]));

	carry_select_adder_4bit_slice csa_slice1(
	.a(a[7:4]),
	.b(b[7:4]),
	.cin(c[0]),
	.sum(sum[7:4]),
	.cout(c[1]));

	carry_select_adder_4bit_slice csa_slice2(
	.a(a[11:8]),
	.b(b[11:8]),
	.cin(c[1]),
	.sum(sum[11:8]), 
	.cout(c[2]));

	carry_select_adder_4bit_slice csa_slice3(
	.a(a[15:12]),
	.b(b[15:12]),
	.cin(c[2]),
	.sum(sum[15:12]),
	.cout(cout));
	endmodule



module carry_save_adder_pipeline (
    input wire [31:0] A,
    input wire [31:0] B,
    input wire clk,
    input wire reset,
    output wire [31:0] sum
);
    wire stage1_carry;
    wire stage2_carry;

    wire [15:0] stage1_A;
    wire [15:0] stage1_B;
    wire [15:0] stage1_sum;

    wire [15:0] stage2_A;
    wire [15:0] stage2_sum;

    reg [31:0] final_sum;

    assign stage1_A = A[31:16];
    assign stage1_B = B[31:16];
    assign stage2_A = A[15:0];

    carry_select_adder_16bit csa1 (
        .a(stage1_A), .b(stage1_B), .cin(1'b0),
        .sum(stage1_sum), .cout(stage1_carry)
    );

    carry_select_adder_16bit csa2 (	
        .a(stage2_A), .b(B[15:0]), .cin(stage1_carry),
        .sum(stage2_sum), .cout(stage2_carry)
    );

    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            final_sum <= 0;
        end else begin
            final_sum <= {stage1_sum, stage2_sum};
        end
    end

    assign sum = final_sum;
endmodule

