module full_adder (
    input logic a, b, cin,
    output logic sum, cout
);
    logic p, g;
    
    
    assign p = a ^ b;        //  p = a XOR b
    assign g = a & b;        //  a AND b
    
    // Sum and carryout
    assign sum = p ^ cin;    //  sum = (a XOR b) XOR cin
    assign cout = g | (p & cin); // Carryout cout = g OR (p AND cin)
endmodule


module ADD_GATE (
    input logic [2:0] a, b,
    output logic [2:0] sum,
    output logic cout, v
);
    logic c1, c2;
    full_adder add1 (a[0], b[0], 0, sum[0], c1);
    full_adder add2 (a[1], b[1], c1, sum[1], c2);
    full_adder add3 (a[2], b[2], c2, sum[2], cout);
    
    // Overflow detection using XOR
    assign v = c2 ^ cout;  // overflow occurs when the carry into the MSB and the carry out differ
endmodule

module INC_GATE (
    input logic [2:0] b,
    output logic [2:0] sum
);
    logic c1, c2, cout;
    full_adder F1 (0, b[0], 1, sum[0], c1);
    full_adder F2 (0, b[1], c1, sum[1], c2);
    full_adder F3 (0, b[2], c2, sum[2], cout);
endmodule

module AND_GATE (
    input logic [2:0] a, b,
    output logic [2:0] c
);
    assign c = a & b;
endmodule

module OR_GATE (
    input logic [2:0] a, b,
    output logic [2:0] c
);
    assign c = a | b;
endmodule

module XOR_GATE (
    input logic [2:0] a, b,
    output logic [2:0] c
);
    assign c = a ^ b;
endmodule

module CMP_GATE (
    input logic [2:0] b,
    output logic [2:0] c
);
    assign c = ~b;
endmodule

module SUB_GATE (
    input logic [2:0] a, b,
    output logic [2:0] diff,
    output logic cout, v
);
    logic c1, c2;
    full_adder sub1 (a[0], ~b[0], 1, diff[0], c1);
    full_adder sub2 (a[1], ~b[1], c1, diff[1], c2);
    full_adder sub3 (a[2], ~b[2], c2, diff[2], cout);
    
    // Overflow detection using XOR
    assign v = c2 ^ cout;  // overflow occurs when the carry into the MSB and the carry out differ
endmodule

module TWOS_COMP_GATE (
    input logic [2:0] a,
    output logic [2:0] y
);
    logic [2:0] not_a;
    logic c1, c2, cout;
    full_adder add1 (~a[0], 0, 1, y[0], c1);
    full_adder add2 (~a[1], 0, c1, y[1], c2);
    full_adder add3 (~a[2], 0, c2, y[2], cout);
endmodule

module AU (
    input logic [2:0] A, B,
    output logic [2:0] sum, subtraction, increm, twos_comp,
    output logic cout, v
);
    ADD_GATE addgate (A, B, sum, cout, v);
    SUB_GATE subgate (A, B, subtraction, cout, v);
    INC_GATE increment (B, increm);
    TWOS_COMP_GATE twos_comp_gate (A, twos_comp);
endmodule

module LU (
    input logic [2:0] A, B,
    output logic [2:0] andop, orop, xorop, cmpop
);
    AND_GATE andgate (A, B, andop);
    OR_GATE orgate (A, B, orop);
    XOR_GATE xorgate (A, B, xorop);
    CMP_GATE cmpgate (B, cmpop);
endmodule

module mux8 (
    input [2:0] in1, in2, in3, in4, in5, in6, in7, in8,
    input [2:0] select,
    output reg [2:0] out
);
    always @* begin
        case (select)
            3'b000: out = in1;
            3'b001: out = in2;
            3'b010: out = in3;
            3'b011: out = in4;
            3'b100: out = in5;
            3'b101: out = in6;
            3'b110: out = in7;
            3'b111: out = in8;
            default: out = 0;
        endcase
    end
endmodule

module ALU (
    input logic [2:0] A, B,
    output logic z, v,
    output logic [2:0] result,
    input logic [2:0] select
);
    logic [2:0] And, Or, X_or, cmpgatee, addd, subb, incc, twos_comp;
    logic cout;

    AU au (A, B, addd, subb, incc, twos_comp, cout, v);
    LU lu (A, B, And, Or, X_or, cmpgatee);
    mux8 mux8_ALU (And, Or, X_or, cmpgatee, addd, subb, incc, twos_comp, select, result);
    assign z = ~result[0] & ~result[1] & ~result[2];  // Zero flag
endmodule

