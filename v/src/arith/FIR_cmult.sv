/*
  latency is 2
  A*B --> A'*B
  Revisions:
    10/13/21:
      First Documentation
*/
module FIR_cmult(
    input  FIR_DATA_SAMPLE              opa,
    input  FIR_DATA_SAMPLE              opb,
    output FIR_DATA_SAMPLE              out,
    input  FIR_SHIFT                    shift, 
    input                               clk,
    input                               rst_n
    );
    
    fix_c_mult #(
       .IN_WIDTH(`FIR_DATA_WIDTH),
       .OUT_WIDTH(`FIR_DATA_WIDTH),
       .ARITH_MODE_R(0),
       .ARITH_MODE_I(1),
       .FLIP(0),
       .SHIFT_CONST(0),
       .SHIFT_MODE(2),
       .SAT_PIPE(1),
       .SHIFT_PIPE(0),
       .ADD_PIPE(1),
       .MULT_PIPE(0)
    ) fix_cadd (
       .opa_R(opa.data_r),
       .opb_R(opb.data_r),
       .opa_I(opa.data_i),
       .opb_I(opb.data_i),
       .arith_mode_R(1'b0),
       .arith_mode_I(1'b0),
       .flip(1'b0),
       .shift_amount({2'b0,shift}),
       .out_R(out.data_r),
       .out_I(out.data_i),
       .*
    );
endmodule

