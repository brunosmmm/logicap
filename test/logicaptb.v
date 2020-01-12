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

   // hack: stuff all configuration registers into an array
   reg [size-1:0]             trigger_cfg [0:24];
   reg [size+1:0]             input_vector;
   wire [31:0]                output_vector;

   // trigger / capture parameters
   wire [saddr_w-1:0]         post_capture_count = trigger_cfg[24];
   wire [saddr_w-1:0]         buffer_size = mem_buffer_size;
   wire [size-1:0]            TRIGM1 = trigger_cfg[0];
   wire [size-1:0]            TRIGT1 = trigger_cfg[1];
   wire [size-1:0]            TRIGL1 = trigger_cfg[2];
   wire [size-1:0]            TRIGM2 = trigger_cfg[3];
   wire [size-1:0]            TRIGT2 = trigger_cfg[4];
   wire [size-1:0]            TRIGL2 = trigger_cfg[5];
   wire [size-1:0]            TRIGM3 = trigger_cfg[6];
   wire [size-1:0]            TRIGT3 = trigger_cfg[7];
   wire [size-1:0]            TRIGL3 = trigger_cfg[8];
   wire [size-1:0]            TRIGM4 = trigger_cfg[9];
   wire [size-1:0]            TRIGT4 = trigger_cfg[10];
   wire [size-1:0]            TRIGL4 = trigger_cfg[11];
   wire [size-1:0]            TRIGM5 = trigger_cfg[12];
   wire [size-1:0]            TRIGT5 = trigger_cfg[13];
   wire [size-1:0]            TRIGL5 = trigger_cfg[14];
   wire [size-1:0]            TRIGM6 = trigger_cfg[15];
   wire [size-1:0]            TRIGT6 = trigger_cfg[16];
   wire [size-1:0]            TRIGL6 = trigger_cfg[17];
   wire [size-1:0]            TRIGM7 = trigger_cfg[18];
   wire [size-1:0]            TRIGT7 = trigger_cfg[19];
   wire [size-1:0]            TRIGL7 = trigger_cfg[20];
   wire [size-1:0]            TRIGM8 = trigger_cfg[21];
   wire [size-1:0]            TRIGT8 = trigger_cfg[22];
   wire [size-1:0]            TRIGL8 = trigger_cfg[23];

   // load configuration
   integer                    configfile, inputfile, outputfile;
   integer                    configline = 0;
   initial begin
      configfile=$fopen("config.txt", "r");
      if (!configfile) begin
         $display("FATAL: could not open configuration file");
         $finish();
      end
      while (!$feof(configfile)) begin
         if (configline < 25) begin
            $fscanf(configfile, "%h\n", trigger_cfg[configline]);
            configline = configline + 1;
         end
         else begin
            $display("WARNING: too many values in configuration file");
         end
      end
      $display("INFO: loaded configuration");
   end

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

   // read input vector
   initial begin
      #10; //wait for reset to clear
      inputfile=$fopen("input.txt", "r");
      if (!inputfile) begin
         $display("FATAL: could not open input file");
         $finish();
      end
      while(!$feof(inputfile)) begin
         $fscanf(inputfile, "%h\n", input_vector);
         #2; // wait for next clock cycle
      end
      // finish simulation if we get here, as there is no more input
      $display("INFO: no more input available, terminating");
      $finish();
   end

   // write output vector
   initial begin
      outputfile=$fopen("output.txt", "w");
      if (!outputfile) begin
         $display("FATAL: could not open output file for writing");
         $finish();
      end
      while (1) begin
         $fwrite(outputfile, "%h\n", output_vector);
         #2; // wait for next clock cycle
      end
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
   wire                        sample_reset;
   wire [size-1:0]             dma_data;
   wire                        dma_valid;
   wire                        dma_last;
   wire                        dma_ready;
   assign dma_ready = 1;

   assign output_vector = {{(32-saddr_w-5){1'b0}},
                           trigger_pos, capture_triggered, capture_done, capture_armed, capture_ready, logic_reset};

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
      .srst (sample_reset),
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
      .reset (sample_reset)
      );

endmodule
