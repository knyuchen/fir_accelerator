`define FIR_DATA_WIDTH     16
`define FIR_MAX_RATE  16
`define FIR_MAX_TAP        128
`define FIR_DELAY          256
`define FIR_REG_NUM        7

`define FIR_SRAM           1

`define FIR_PE_PER_TILE    4
//`define FIR_PE_PER_TILE    8
`define FIR_TILE_NUM       `FIR_MAX_TAP / `FIR_PE_PER_TILE

typedef logic [$clog2(`FIR_DATA_WIDTH) - 1 : 0]  FIR_SHIFT;
typedef logic [$clog2(`FIR_MAX_RATE) - 1 : 0]  FIR_RATE;
typedef logic [$clog2(`FIR_MAX_TAP)  : 0]   FIR_TAIL;

typedef struct packed {
   logic  [`FIR_DATA_WIDTH - 1 : 0] data_r;
   logic  [`FIR_DATA_WIDTH - 1 : 0] data_i;
} FIR_DATA_SAMPLE;

typedef struct packed {
   logic                        valid;
   FIR_DATA_SAMPLE                  data;
} FIR_DATA_BUS;

typedef struct packed {
   logic                        valid;
   FIR_TAIL   num;
   logic                        flush;
   logic                        mode;
   FIR_SHIFT                    shift;
} FIR_CONT_TO_TILE;

typedef struct packed {
   logic   [1:0]                        flush;
   logic                                mode;
   logic   [$clog2(`FIR_DELAY) - 1 : 0] delay;
   FIR_SHIFT                            shift;
} FIR_CONT_TO_IN;

typedef struct packed {
   logic   [1:0]                        flush;
   FIR_RATE                             rate;
} FIR_CONT_TO_OUT_RATE;

typedef struct packed {
   logic   [1:0]                        flush;
   FIR_RATE                             rate;
   FIR_TAIL                             tail;
} FIR_CONT_TO_IN_RATE;

typedef struct packed {
   logic                        mode;
   logic                        flush;
   logic                        enable;
   FIR_SHIFT                    shift;
} FIR_TILE_TO_PE;

typedef struct packed {
   FIR_DATA_BUS              input_sample;
   FIR_DATA_BUS              psum;
} FIR_TILE_TO_TILE;

typedef struct packed {
   logic                        valid;
   FIR_TAIL                     count;
   FIR_DATA_SAMPLE              data;
   
} FIR_TAP_LOAD;


typedef struct packed {
   logic   [$clog2(`FIR_REG_NUM) - 1 : 0]  config_valid;
   logic   [31:0]                          input_command;
   logic   [31:0]                          config_tap;
   logic   [31:0]                          input_config;
} FIR_LITE_TO_CONT;


typedef struct packed {
   logic   [31:0]                          ready;
} FIR_CONT_TO_LITE;
