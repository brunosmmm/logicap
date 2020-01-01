module logicap
  #(
    parameter integer size = 32,
    parameter integer max_div = 32,
    parameter integer fifo_depth = 512,
    parameter integer saddr_w = 24
    )
  (

   // input signals
   input [size-1:0]  dinput,

   // data output
   output [size-1:0] tdata,
   output            tvalid,
   output            tlast,
   input             tready,

   input             clk,
   input             ext_clk,
   input             reset
   );

   // placeholders
   reg [$clog2(max_div)-1:0] ckdiv;
   wire                      sample_overrun;
   wire                      capture_arm;
   wire                      capture_triggered;
   wire                      capture_abort;
   wire [saddr_w-1:0]        post_capture_count;

   // glue
   wire [size-1:0] sample_data;
   wire            sample_valid;
   wire            sample_ready;
   wire            sample_clk;
   wire [size-1:0] trig_level1_mask;
   wire [size-1:0] trig_level1_type;
   wire [size-1:0] trig_level1_level;
   wire [size-1:0] trig_level2_mask;
   wire [size-1:0] trig_level2_type;
   wire [size-1:0] trig_level2_level;
   wire [size-1:0] trig_level3_mask;
   wire [size-1:0] trig_level3_type;
   wire [size-1:0] trig_level3_level;
   wire [size-1:0] trig_level4_mask;
   wire [size-1:0] trig_level4_type;
   wire [size-1:0] trig_level4_level;
   wire [size-1:0] trig_level5_mask;
   wire [size-1:0] trig_level5_type;
   wire [size-1:0] trig_level5_level;
   wire [size-1:0] trig_level6_mask;
   wire [size-1:0] trig_level6_type;
   wire [size-1:0] trig_level6_level;
   wire [size-1:0] trig_level7_mask;
   wire [size-1:0] trig_level7_type;
   wire [size-1:0] trig_level7_level;
   wire [size-1:0] trig_level8_mask;
   wire [size-1:0] trig_level8_type;
   wire [size-1:0] trig_level8_level;

   // capture module
   capture
     #(
       .size (size),
       .max_div (max_div),
       .saddr_w (saddr_w)
       )
   cap
     (
      .tdata (sample_data),
      .tvalid (sample_valid),
      .tready (sample_ready),
      .sclk (sample_clk),
      .ckdiv (ckdiv),
      .dinput (dinput),
      .clk(clk),
      .ext_clk(ext_clk),
      .reset (reset),
      .overrun (sample_overrun),
      .arm (capture_arm),
      .abort (capture_abort),
      .triggered (capture_triggered),
      .trig_level1_mask (trig_level1_mask),
      .trig_level1_type (trig_level1_type),
      .trig_level1_level (trig_level1_level),
      .trig_level2_mask (trig_level2_mask),
      .trig_level2_type (trig_level2_type),
      .trig_level2_level (trig_level2_level),
      .trig_level3_mask (trig_level3_mask),
      .trig_level3_type (trig_level3_type),
      .trig_level3_level (trig_level3_level),
      .trig_level4_mask (trig_level4_mask),
      .trig_level4_type (trig_level4_type),
      .trig_level4_level (trig_level4_level),
      .trig_level5_mask (trig_level5_mask),
      .trig_level5_type (trig_level5_type),
      .trig_level5_level (trig_level5_level),
      .trig_level6_mask (trig_level6_mask),
      .trig_level6_type (trig_level6_type),
      .trig_level6_level (trig_level6_level),
      .trig_level7_mask (trig_level7_mask),
      .trig_level7_type (trig_level7_type),
      .trig_level7_level (trig_level7_level),
      .trig_level8_mask (trig_level8_mask),
      .trig_level8_type (trig_level8_type),
      .trig_level8_level (trig_level8_level),
      .post_capture_count (post_capture_count)
      );

   // FIFO
   axisfifo
     #(
       .dataw (size),
       .depth (fifo_depth)
       )
   fifo
     (
      .slave_tdata (sample_data),
      .slave_tvalid (sample_valid),
      .slave_tready (sample_ready),
      .master_tdata (tdata),
      .master_tvalid (tvalid),
      .master_tlast (tlast),
      .master_tready (tready),
      .master_clk (clk),
      .slave_clk (sample_clk),
      .reset (reset)
      );

   // TODO AXI memory mapped control interface


endmodule
