module capture
  #(
    parameter integer size = 32,
    parameter integer max_div = 32,
    parameter integer saddr_w = 24
    )
   (
    // axi stream master output
    output [size-1:0]           tdata,
    output                      tvalid,
    input                       tready,
    output                      sclk,

    // clock divider for sampling rate
    input [$clog2(max_div)-1:0] ckdiv,

    input [size-1:0]            dinput,

    input                       clk,
    input                       ext_clk,
    input                       reset,

    // flags
    output                      overrun,
    output                      triggered,
    output                      armed,
    input                       arm,
    input                       abort,
    output                      done,
    output                      ready,

    // trigger configuration
    input [size-1:0]            trig_level1_mask,
    input [size-1:0]            trig_level1_type,
    input [size-1:0]            trig_level1_level,

    input [size-1:0]            trig_level2_mask,
    input [size-1:0]            trig_level2_type,
    input [size-1:0]            trig_level2_level,

    input [size-1:0]            trig_level3_mask,
    input [size-1:0]            trig_level3_type,
    input [size-1:0]            trig_level3_level,

    input [size-1:0]            trig_level4_mask,
    input [size-1:0]            trig_level4_type,
    input [size-1:0]            trig_level4_level,

    input [size-1:0]            trig_level5_mask,
    input [size-1:0]            trig_level5_type,
    input [size-1:0]            trig_level5_level,

    input [size-1:0]            trig_level6_mask,
    input [size-1:0]            trig_level6_type,
    input [size-1:0]            trig_level6_level,

    input [size-1:0]            trig_level7_mask,
    input [size-1:0]            trig_level7_type,
    input [size-1:0]            trig_level7_level,

    input [size-1:0]            trig_level8_mask,
    input [size-1:0]            trig_level8_type,
    input [size-1:0]            trig_level8_level,

    // how many samples to write after trigger
    input [saddr_w-1:0]         post_trigger_count,
    input [saddr_w-1:0]         buffer_size,
    output [saddr_w-1:0]        trigger_pos
    );

   // trigger reset
   reg                          trigger_reset;

   // clock divider logic
   reg [$clog2(max_div)-1:0]    old_divider;
   reg                          div_change;
   always @(posedge clk) begin
      if (reset) begin
         div_change <= 0;
         old_divider <= 1;
      end
      else begin
         if (old_divider != ckdiv) begin
            div_change <= 1;
            old_divider <= ckdiv;
         end
         else begin
            div_change <= 0;
         end
      end
   end

   // actual divider
   reg div_clk;
   wire sample_clk;
   assign sample_clk = old_divider == 0 ? ext_clk : div_clk;
   assign sclk = sample_clk;
   reg [$clog2(max_div)-1:0] div_counter;
   reg                       divider_starting;
   assign ready = !divider_starting;
   always @(posedge ext_clk) begin
      if (reset) begin
         div_clk <= 0;
         div_counter <= 0;
         trigger_reset <= 1;
         divider_starting <= 1;
      end
      else begin
         if (div_change) begin
            // restart
            div_counter <= 0;
            div_clk <= 0;
         end
         else begin
            if (old_divider == 0) begin
               trigger_reset <= 0;
               divider_starting <= 0;
            end
            if (div_counter < old_divider - 1) begin
               div_counter <= div_counter + 1;
            end
            else begin
               div_counter <= 0;
               div_clk <= !sample_clk;
               if (divider_starting && div_clk) begin
                  // divider startup is complete, release trigger reset
                  divider_starting <= 0;
                  trigger_reset <= 0;
               end
            end
         end
      end
   end

   // sample / stuff into external FIFO
   reg sample_valid;
   reg overrun_det;
   reg [size-1:0] sample_data;
   reg [saddr_w-1:0] post_trigger_samples;
   reg [saddr_w-1:0] minimum_samples;
   reg [saddr_w-1:0] trigger_pos;
   reg               trigger_wait;
   assign tdata = sample_data;
   always @(posedge sclk) begin
      if (reset) begin
         sample_valid <= 0;
         sample_data <= 0;
         overrun_det <= 0;
         post_trigger_samples <= 0;
         trigger_wait <= 1;
         trigger_pos <= 0;
      end
      else begin
         // store pre-calculated post-trigger sample count
         if (!trigger_armed) begin
            if (arm && !divider_starting) begin
               post_trigger_samples <= post_trigger_count;
               minimum_samples <= buffer_size - post_trigger_count;
               trigger_pos <= 0;
            end
         end
         else begin
            if (minimum_samples > 1) begin
               trigger_wait <= 1;
               minimum_samples <= minimum_samples - 1;
            end
            else begin
               trigger_wait <= 0;
               minimum_samples <= 0;
            end

            // catch trigger position in buffer
            if (trigger_pos < buffer_size) begin
               trigger_pos <= trigger_pos + 1;
            end
            else begin
               trigger_pos <= 0;
            end
         end
         if (triggered_out) begin
            if ((post_trigger_samples > 0) && tready) begin
               post_trigger_samples <= post_trigger_samples - 1;
            end
         end
         // always update
         sample_data <= dinput;
         sample_valid <= tready && (trigger_armed || (triggered_out && post_trigger_samples > 0));
         overrun_det <= !tready && (trigger_armed || (triggered_out && post_trigger_samples > 0));
      end
   end

   // re-synchronize signals
   reg overrun_flag;
   reg triggered_flag;
   wire triggered_out;
   assign overrun = overrun_flag;
   assign triggered = triggered_flag;
   always @(posedge clk) begin
      if (reset) begin
         overrun_flag <= 0;
         triggered_flag <= 0;
      end
      else begin
         overrun_flag <= overrun_det;
         triggered_flag <= triggered_out;
      end
   end

   // trigger logic module
   wire arm_sig;
   wire trigger_armed;
   assign armed = trigger_armed;
   // prevent re-arming before capture completion
   assign arm_sig = arm && (post_trigger_samples == 0);
   assign done = triggered_out && (post_trigger_samples == 0);
   wire trigger_ignore;
   assign trigger_ignore = overrun_det || trigger_wait;
   trigger
     #(.dsize (size))
   trig
     (
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
      .dinput (sample_data),
      .arm (arm_sig),
      .abort (abort),
      .clk (sclk),
      .reset (trigger_reset),
      .triggered (triggered_out),
      .armed (trigger_armed),
      .ignore (trigger_ignore)
      );

endmodule
