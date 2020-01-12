module triggertb();

   localparam integer size = 32;

   reg                sclk;
   reg                arm;
   reg                abort;
   wire               triggered;
   wire               armed;
   reg                ignore;
   reg                reset;
   reg [size-1:0]     sample_data;

   reg [size-1:0]     trigger_levels[0:7];
   reg [size-1:0]     trigger_masks[0:7];
   reg [size-1:0]     trigger_types[0:7];

   initial begin
      $dumpfile("trigger.vcd");
      $dumpvars(0, triggertb);
      sclk <= 0;
      reset <= 1;
      arm <= 0;
      abort <= 0;
      ignore <= 0;
      sample_data <= 0;
      // release reset after 10 cycles
      #10 reset <= 0;
      // finish if stuck
      #1000 $finish;
   end

   // initialize trigger configurations
   genvar i;
   generate
      for (i = 0; i<8; i= i + 1) begin : triggers
         // idiots
         wire [size-1:0] tlevels, tmasks, ttypes;
         assign tlevels = trigger_levels[i];
         assign tmasks = trigger_masks[i];
         assign ttypes = trigger_types[i];
         initial begin
            trigger_levels[i] <= 0;
            trigger_masks[i] <= 0;
            trigger_types[i] <= 0;
         end
      end
   endgenerate

   // generate clock
   always begin
      #1 sclk <= !sclk;
   end

   // perform tests
   initial begin
      #20 trigger_masks[0] <= {{(size-1){1'b0}}, 1'b1};
      trigger_levels[0] <= 32'b1;
      trigger_types[0] <= 32'b1;
      arm <= 1;
      #2 arm <= 0;
      #10 sample_data[0] <= 1;
      #8 arm <= 1;
      #2 arm <= 0;
      #10 sample_data[0] <= 0;
      #4 sample_data[0] <= 1;

   end

   trigger
     #(.dsize (size))
   trig
     (
      .trig_level1_mask (trigger_masks[0]),
      .trig_level1_type (trigger_types[0]),
      .trig_level1_level (trigger_levels[0]),
      .trig_level2_mask (trigger_masks[1]),
      .trig_level2_type (trigger_types[1]),
      .trig_level2_level (trigger_levels[1]),
      .trig_level3_mask (trigger_masks[2]),
      .trig_level3_type (trigger_types[2]),
      .trig_level3_level (trigger_levels[2]),
      .trig_level4_mask (trigger_masks[3]),
      .trig_level4_type (trigger_types[3]),
      .trig_level4_level (trigger_levels[3]),
      .trig_level5_mask (trigger_masks[4]),
      .trig_level5_type (trigger_types[4]),
      .trig_level5_level (trigger_levels[4]),
      .trig_level6_mask (trigger_masks[5]),
      .trig_level6_type (trigger_types[5]),
      .trig_level6_level (trigger_levels[5]),
      .trig_level7_mask (trigger_masks[6]),
      .trig_level7_type (trigger_types[6]),
      .trig_level7_level (trigger_levels[6]),
      .trig_level8_mask (trigger_masks[7]),
      .trig_level8_type (trigger_types[7]),
      .trig_level8_level (trigger_levels[7]),
      .dinput (sample_data),
      .arm (arm),
      .abort (abort),
      .clk (sclk),
      .reset (reset),
      .triggered (triggered_out),
      .armed (armed),
      .ignore (ignore)
      );

endmodule
