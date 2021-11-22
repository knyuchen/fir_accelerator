/*
   Pure Combinational Complex Adder
   Latency is 0
   Revisions:
     10/13/21:
       First Documentations 
*/


module FIR_cadd(
    input  FIR_DATA_SAMPLE              opa,
    input  FIR_DATA_SAMPLE              opb,
    output FIR_DATA_SAMPLE              out,
    input                               clk,
    input                               rst_n
    );

    fix_c_add_sub #(
       .IN_WIDTH(`FIR_DATA_WIDTH),
       .OUT_WIDTH(`FIR_DATA_WIDTH),
       .ARITH_MODE_R(0),
       .ARITH_MODE_I(0),
       .FLIP(0),
       .SHIFT_CONST(0),
       .SHIFT_MODE(0),
       .SAT_PIPE(0),
       .SHIFT_PIPE(0),
       .ADD_PIPE(0)
    ) fix_cadd (
       .opa_R(opa.data_r),
       .opb_R(opb.data_r),
       .opa_I(opa.data_i),
       .opb_I(opb.data_i),
       .arith_mode_R(1'b0),
       .arith_mode_I(1'b0),
       .flip(1'b0),
       .shift_amount(5'b0),
       .out_R(out.data_r),
       .out_I(out.data_i),
       .*
    );
    

endmodule

