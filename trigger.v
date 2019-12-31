`define TRIGGER_LVL 0
`define TRIGGER_EDG 1
`define TRIGGER_RISE 1
`define TRIGGER_FALL 0
module trigger
  #(
    parameter integer dsize = 32
    )
  (

   // trigger configuration
   input [dsize-1:0] trig_level1_mask,
   input [dsize-1:0] trig_level1_type,
   input [dsize-1:0] trig_level1_level,

   input [dsize-1:0] trig_level2_mask,
   input [dsize-1:0] trig_level2_type,
   input [dsize-1:0] trig_level2_level,

   input [dsize-1:0] trig_level3_mask,
   input [dsize-1:0] trig_level3_type,
   input [dsize-1:0] trig_level3_level,

   input [dsize-1:0] trig_level4_mask,
   input [dsize-1:0] trig_level4_type,
   input [dsize-1:0] trig_level4_level,

   input [dsize-1:0] trig_level5_mask,
   input [dsize-1:0] trig_level5_type,
   input [dsize-1:0] trig_level5_level,

   input [dsize-1:0] trig_level6_mask,
   input [dsize-1:0] trig_level6_type,
   input [dsize-1:0] trig_level6_level,

   input [dsize-1:0] trig_level7_mask,
   input [dsize-1:0] trig_level7_type,
   input [dsize-1:0] trig_level7_level,

   input [dsize-1:0] trig_level8_mask,
   input [dsize-1:0] trig_level8_type,
   input [dsize-1:0] trig_level8_level,

   input [dsize-1:0] dinput,

   input             arm,
   input             abort,
   input             ignore,
   input             clk,
   input             reset,

   output            triggered,
   output            armed
   );

   // trigger type 0 is level, 1 is edge

   // store configuration
   reg [dsize-1:0]   trig_masks [0:7];
   reg [dsize-1:0]   trig_types [0:7];
   reg [dsize-1:0]   trig_levels [0:7];
   reg               armed;
   reg               done;
   assign triggered = done;

   // trigger state
   reg [2:0]         trigger_level;
   reg [dsize-1:0]   old_inputs;
   wire [dsize-1:0]  current_masked;
   assign current_masked = trig_masks[trigger_level] & dinput;

   reg [dsize-1:0]   trigger_condition;
   wire [dsize-1:0]  level_condition;
   assign level_condition = trig_masks[trigger_level];

   // when trigger_condition == level_condition then trigger level condition is achieved

   genvar            i;
   generate
      for (i=0; i<dsize; i=i+1) begin
         always @(posedge clk) begin
            if (reset) begin
               trigger_condition[i] <= 0;
            end
            else begin
               if (armed && !ignore) begin
                  if (current_masked[i]) begin
                     // this bit is enabled
                     if (trig_types[trigger_level][i] == `TRIGGER_LVL) begin
                        if (trig_levels[trigger_level][i] == dinput[i]) begin
                           // condition achieved
                           trigger_condition[i] <= 1;
                        end
                        else begin
                           trigger_condition[i] <= 0;
                        end
                     end
                     else begin
                        // edge
                        if (trig_levels[trigger_level][i] == `TRIGGER_RISE) begin
                           // rising edge
                           if (old_inputs[i] == 0 && dinput[i] == 1) begin
                              trigger_condition[i] <= 1;
                           end
                           else begin
                              trigger_condition[i] <= 0;
                           end
                        end
                        else begin
                           if (old_inputs[i] == 1 && dinput[i] == 0) begin
                              trigger_condition[i] <= 1;
                           end
                           else begin
                              trigger_condition[i] <= 0;
                           end
                        end // else: !if(trig_levels[trigger_level][i] == `TRIGGER_RISE)
                     end // else: !if(trig_types[trigger_level][i] == `TRIGGER_LVL)
                  end
                  else begin
                     trigger_condition[i] <= 0;
                  end
               end
               else begin
                  trigger_condition[i] <= 0;
               end
            end
         end // always @ (posdege clk)
      end
   endgenerate

   always @(posedge clk) begin
      if (reset) begin
         done <= 0;
         armed <= 0;
         trigger_level <= 0;
         old_inputs <= 0;
      end
      else begin
         if (!ignore) begin
            old_inputs <= dinput;
         end
         if (armed) begin
            if (abort) begin
               // abort trigger
               armed <= 0;
               trigger_level <= 0;
            end
            else begin
               if (trig_masks[trigger_level] == {dsize{1'b0}}) begin
                  // next trigger is not configured, so we're done
                  done <= 1;
                  armed <= 0;
               end
               else begin
                  // trigger logic for this trigger level
                  if (trigger_condition == level_condition) begin
                     if (trigger_level != 7) begin
                        trigger_level <= trigger_level + 1;
                     end
                     else begin
                        done <= 1;
                        armed <= 0;
                        trigger_level <= 0;
                     end
                  end
               end // else: !if(trig_masks[trigger_level] == dsize'b0)
            end // else: !if(abort)
         end // if (armed)
         else begin
            if (arm) begin
               // arm trigger
               armed <= 1;
               trigger_level <= 0;
               done <= 0;
               trig_masks[0] <= trig_level1_mask;
               trig_types[0] <= trig_level1_type;
               trig_levels[0] <= trig_level1_level;
               trig_masks[1] <= trig_level2_mask;
               trig_types[1] <= trig_level2_type;
               trig_levels[1] <= trig_level2_level;
               trig_masks[2] <= trig_level3_mask;
               trig_types[2] <= trig_level3_type;
               trig_levels[2] <= trig_level3_level;
               trig_masks[3] <= trig_level4_mask;
               trig_types[3] <= trig_level4_type;
               trig_levels[3] <= trig_level4_level;
               trig_masks[4] <= trig_level5_mask;
               trig_types[4] <= trig_level5_type;
               trig_levels[4] <= trig_level5_level;
               trig_masks[5] <= trig_level6_mask;
               trig_types[5] <= trig_level6_type;
               trig_levels[5] <= trig_level6_level;
               trig_masks[6] <= trig_level7_mask;
               trig_types[6] <= trig_level7_type;
               trig_levels[6] <= trig_level7_level;
               trig_masks[7] <= trig_level8_mask;
               trig_types[7] <= trig_level8_type;
               trig_levels[7] <= trig_level8_level;
            end
         end
      end
   end

endmodule
