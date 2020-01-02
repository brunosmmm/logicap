module logicaptb
  #(
    parameter integer size = 32,
    parameter integer max_div = 32,
    parameter integer fifo_depth = 512,
    parameter integer saddr_w = 24
    )
  ();

   // 128 samples
   localparam [saddr_w-1:0] mem_buffer_size = 128;

   // testbench controlled signals
   wire [$clog2(max_div)-1:0] ckdiv;
   assign ckdiv = 1;
   reg                        capture_arm;
   reg                        capture_abort;
   reg [size-1:0]             dinput;
   reg                        logic_reset;
   reg                        clk;

   // trigger / capture parameters
   wire [saddr_w-1:0]         post_capture_count = 64; // set to 50/50
   wire [saddr_w-1:0]         buffer_size = mem_buffer_size;
   wire [size-1:0]            TRIGM1 = 0;
   wire [size-1:0]            TRIGT1 = 0;
   wire [size-1:0]            TRIGL1 = 0;
   wire [size-1:0]            TRIGM2 = 0;
   wire [size-1:0]            TRIGT2 = 0;
   wire [size-1:0]            TRIGL2 = 0;
   wire [size-1:0]            TRIGM3 = 0;
   wire [size-1:0]            TRIGT3 = 0;
   wire [size-1:0]            TRIGL3 = 0;
   wire [size-1:0]            TRIGM4 = 0;
   wire [size-1:0]            TRIGT4 = 0;
   wire [size-1:0]            TRIGL4 = 0;
   wire [size-1:0]            TRIGM5 = 0;
   wire [size-1:0]            TRIGT5 = 0;
   wire [size-1:0]            TRIGL5 = 0;
   wire [size-1:0]            TRIGM6 = 0;
   wire [size-1:0]            TRIGT6 = 0;
   wire [size-1:0]            TRIGL6 = 0;
   wire [size-1:0]            TRIGM7 = 0;
   wire [size-1:0]            TRIGT7 = 0;
   wire [size-1:0]            TRIGL7 = 0;
   wire [size-1:0]            TRIGM8 = 0;
   wire [size-1:0]            TRIGT8 = 0;
   wire [size-1:0]            TRIGL8 = 0;

   initial begin
      $dumpfile("logicap.vcd");
      $dumpvars(0, logicaptb);
      capture_arm <= 0;
      capture_abort <= 0;
      dinput <= 0;
      logic_reset <= 1;
      clk <= 0;
      #10 logic_reset <= 0;
      #10000 $finish();
   end

   // generate clock
   always begin
      #1 clk <= !clk;
   end

   // glue
   wire [size-1:0]             sample_data;
   wire                        sample_overrun;
   wire                        capture_triggered;
   wire                        capture_done;
   wire                        capture_armed;
   wire                        capture_ready;
   wire [saddr_w-1:0]          trigger_pos;
   wire                        sample_valid;
   wire                        sample_ready;
   wire                        sample_clk;
   wire [size-1:0]             dma_data;
   wire                        dma_valid;
   wire                        dma_last;
   wire                        dma_ready;
   assign dma_ready = 1;

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
      .ext_clk(clk),
      .reset (logic_reset),
      .overrun (sample_overrun),
      .arm (capture_arm),
      .armed (capture_armed),
      .abort (capture_abort),
      .triggered (capture_triggered),
      .done (capture_done),
      .ready (capture_ready),
      .trig_level1_mask (TRIGM1),
      .trig_level1_type (TRIGT1),
      .trig_level1_level (TRIGL1),
      .trig_level2_mask (TRIGM2),
      .trig_level2_type (TRIGT2),
      .trig_level2_level (TRIGL2),
      .trig_level3_mask (TRIGM3),
      .trig_level3_type (TRIGT3),
      .trig_level3_level (TRIGL3),
      .trig_level4_mask (TRIGM4),
      .trig_level4_type (TRIGT4),
      .trig_level4_level (TRIGL4),
      .trig_level5_mask (TRIGM5),
      .trig_level5_type (TRIGT5),
      .trig_level5_level (TRIGL5),
      .trig_level6_mask (TRIGM6),
      .trig_level6_type (TRIGT6),
      .trig_level6_level (TRIGL6),
      .trig_level7_mask (TRIGM7),
      .trig_level7_type (TRIGT7),
      .trig_level7_level (TRIGL7),
      .trig_level8_mask (TRIGM8),
      .trig_level8_type (TRIGT8),
      .trig_level8_level (TRIGL8),
      .post_trigger_count (post_capture_count),
      .buffer_size (buffer_size),
      .trigger_pos (trigger_pos)
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
      .master_tdata (dma_data),
      .master_tvalid (dma_valid),
      .master_tlast (dma_last),
      .master_tready (dma_ready),
      .master_clk (clk),
      .slave_clk (sample_clk),
      .reset (logic_reset)
      );

endmodule
