module csa (
    input signed [3:0] A, B,
    input c_in,
    output signed [3:0] S,
    output c_out
);

wire c1_0 , c2_0 , c3_0 , c4_0;
wire s0_0 , s1_0 , s2_0 , s3_0;
wire c1_1 , c2_1 , c3_1 , c4_1;
wire s0_1 , s1_1 , s2_1 , s3_1;

xor(s0_0 , A[0] , B[0] , 1'b0);
and(c1_0 , A[0] , B[0]);

xor(s1_0 , A[1] , B[1] , c1_0);
wire and00 , and01 , and02;
and(and00 , A[1] , c1_0);
and(and01 , B[1] , c1_0);
and(and02 , A[1] , B[1]);
or(c2_0 , and00 , and01 , and02);

xor(s2_0 , A[2] , B[2] , c2_0);
wire and10 , and11 , and12;
and(and10 , A[2] , c2_0);
and(and11 , B[2] , c2_0);
and(and12 , A[2] , B[2]);
or(c3_0 , and10 , and11 , and12);

xor(s3_0 , A[3] , B[3] , c3_0);
wire and20 , and21 , and22;
and(and20 , A[3] , c3_0);
and(and21 , B[3] , c3_0);
and(and22 , A[3] , B[3]);
or(c4_0 , and20 , and21 , and22);

wire and_out;
xor(s0_1 , A[0] , B[0] , 1'b1);
and(and_out , A[0] , B[0]);
or(c1_1 , and_out , A[0] , B[0]);

xor(s1_1 , A[1] , B[1] , c1_1);
wire and00_1 , and01_1 , and02_1;
and(and00_1 , A[1] , c1_1);
and(and01_1 , B[1] , c1_1);
and(and02_1 , A[1] , B[1]);
or(c2_1 , and00_1 , and01_1 , and02_1);

xor(s2_1 , A[2] , B[2] , c2_1);
wire and10_1 , and11_1 , and12_1;
and(and10_1 , A[2] , c2_1);
and(and11_1 , B[2] , c2_1);
and(and12_1 , A[2] , B[2]);
or(c3_1 , and10_1 , and11_1 , and12_1);

xor(s3_1 , A[3] , B[3] , c3_1);
wire and20_1 , and21_1 , and22_1;
and(and20_1 , A[3] , c3_1);
and(and21_1 , B[3] , c3_1);
and(and22_1 , A[3] , B[3]);
or(c4_1 , and20_1 , and21_1 , and22_1);


//mux part

mux mux_0(s0_0 , s0_1 , c_in , S[0]);
mux mux_1(s1_0 , s1_1 , c_in , S[1]);
mux mux_2(s2_0 , s2_1 , c_in , S[2]);
mux mux_3(s3_0 , s3_1 , c_in , S[3]);
mux mux_4(c4_0 , c4_1 , c_in , c_out);

endmodule

module mux (input I0 , I1 , sel , output out);
wire sel_not , and1 , and2;
not(sel_not , sel);
and(and1 , I0 , sel_not);
and(and2 , I1 , sel);
or(out , and1 , and2);
endmodule


module csa_16bit (
    input  signed [15:0] A,
    input  signed [15:0] B,
    input  c_in,
    output signed [15:0] S,
    output c_out
);
    wire c1 , c2 , c3;
    csa csa_1(A[3:0] , B[3:0] , c_in , S[3:0] , c1);
    csa csa_2(A[7:4] , B[7:4] , c1 , S[7:4] , c2);
    csa csa_3(A[11:8] , B[11:8] , c2 , S[11:8] , c3);
    csa csa_4(A[15:12] , B[15:12] , c3 , S[15:12] , c_out);
endmodule