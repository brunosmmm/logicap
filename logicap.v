module logicap
  #(
    parameter integer size = 32,
    parameter integer max_div = 32,
    parameter integer fifo_depth = 512,
    parameter integer saddr_w = 24,
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 8
    )
  (

   // input signals
   input [size-1:0]                     dinput,
   input                                ext_clk,

   // data output
   output [size-1:0]                    S_AXIS_TDATA,
   output                               S_AXIS_TVALID,
   output                               S_AXIS_TLAST,
   input                                S_AXIS_TREADY,
   input                                S_AXIS_ACLK,
   // AXI MM slave
   input                                S_AXI_ACLK,
   input                                S_AXI_ARESETN,
   input [(C_S_AXI_ADDR_WIDTH-1):0]     S_AXI_AWADDR,
   input [2:0]                          S_AXI_AWPROT,
   input                                S_AXI_AWVALID,
   output                               S_AXI_AWREADY,
   input [(C_S_AXI_DATA_WIDTH-1):0]     S_AXI_WDATA,
   input [((C_S_AXI_DATA_WIDTH/8)-1):0] S_AXI_WSTRB,
   input                                S_AXI_WVALID,
   output                               S_AXI_WREADY,
   output [1:0]                         S_AXI_BRESP,
   output                               S_AXI_BVALID,
   input                                S_AXI_BREADY,
   input [(C_S_AXI_ADDR_WIDTH-1):0]     S_AXI_ARADDR,
   input [2:0]                          S_AXI_ARPROT,
   input                                S_AXI_ARVALID,
   output                               S_AXI_ARREADY,
   output [(C_S_AXI_DATA_WIDTH-1):0]    S_AXI_RDATA,
   output [1:0]                         S_AXI_RRESP,
   output                               S_AXI_RVALID,
   input                                S_AXI_RREADY
   );

   // logic reset
   wire                                 logic_reset;
   wire                                 mm_rst;
   assign logic_reset = !S_AXI_ARESETN || mm_rst;

   // glue
   wire [$clog2(max_div)-1:0] ckdiv;
   wire                      sample_overrun;
   wire                      capture_arm;
   wire                      capture_triggered;
   wire                      capture_abort;
   wire                      capture_armed;
   wire                      capture_done;
   wire [saddr_w-1:0]        post_capture_count;
   wire [saddr_w-1:0]        buffer_size;
   wire [saddr_w-1:0]        trigger_pos;
   wire [size-1:0] sample_data;
   wire            sample_valid;
   wire            sample_ready;
   wire            sample_clk;
   wire [size-1:0] TRIGM1;
   wire [size-1:0] TRIGT1;
   wire [size-1:0] TRIGL1;
   wire [size-1:0] TRIGM2;
   wire [size-1:0] TRIGT2;
   wire [size-1:0] TRIGL2;
   wire [size-1:0] TRIGM3;
   wire [size-1:0] TRIGT3;
   wire [size-1:0] TRIGL3;
   wire [size-1:0] TRIGM4;
   wire [size-1:0] TRIGT4;
   wire [size-1:0] TRIGL4;
   wire [size-1:0] TRIGM5;
   wire [size-1:0] TRIGT5;
   wire [size-1:0] TRIGL5;
   wire [size-1:0] TRIGM6;
   wire [size-1:0] TRIGT6;
   wire [size-1:0] TRIGL6;
   wire [size-1:0] TRIGM7;
   wire [size-1:0] TRIGT7;
   wire [size-1:0] TRIGL7;
   wire [size-1:0] TRIGM8;
   wire [size-1:0] TRIGT8;
   wire [size-1:0] TRIGL8;

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
      .clk(S_AXI_ACLK),
      .ext_clk(ext_clk),
      .reset (logic_reset),
      .overrun (sample_overrun),
      .arm (capture_arm),
      .armed (capture_armed),
      .abort (capture_abort),
      .triggered (capture_triggered),
      .done (capture_done),
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
      .master_tdata (S_AXIS_TDATA),
      .master_tvalid (S_AXIS_TVALID),
      .master_tlast (S_AXIS_TLAST),
      .master_tready (S_AXIS_TREADY),
      .master_clk (S_AXIS_ACLK),
      .slave_clk (sample_clk),
      .reset (logic_reset)
      );

   //AXI memory mapped control interface

   aximm_slave
      #(
        .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH)
        )
   mmslave
     (
      .S_AXI_ACLK (S_AXI_ACLK),
      .S_AXI_ARESETN (S_AXI_ARESETN),
      .S_AXI_AWADDR (S_AXI_AWADDR),
      .S_AXI_AWPROT (S_AXI_AWPROT),
      .S_AXI_AWVALID (S_AXI_AWVALID),
      .S_AXI_AWREADY (S_AXI_AWREADY),
      .S_AXI_WDATA (S_AXI_WDATA),
      .S_AXI_WSTRB (S_AXI_WSTRB),
      .S_AXI_WVALID (S_AXI_WVALID),
      .S_AXI_WREADY (S_AXI_WREADY),
      .S_AXI_BRESP (S_AXI_BRESP),
      .S_AXI_BVALID (S_AXI_BVALID),
      .S_AXI_BREADY (S_AXI_BREADY),
      .S_AXI_ARADDR (S_AXI_ARADDR),
      .S_AXI_ARPROT (S_AXI_ARPROT),
      .S_AXI_ARVALID (S_AXI_ARVALID),
      .S_AXI_ARREADY (S_AXI_ARREADY),
      .S_AXI_RDATA (S_AXI_RDATA),
      .S_AXI_RRESP (S_AXI_RRESP),
      .S_AXI_RVALID (S_AXI_RVALID),
      .S_AXI_RREADY (S_AXI_RREADY),
      .TRIGM0 (TRIGM1),
      .TRIGM1 (TRIGM2),
      .TRIGM2 (TRIGM3),
      .TRIGM3 (TRIGM4),
      .TRIGM4 (TRIGM5),
      .TRIGM5 (TRIGM6),
      .TRIGM6 (TRIGM7),
      .TRIGM7 (TRIGM8),
      .TRIGT0 (TRIGT1),
      .TRIGT1 (TRIGT2),
      .TRIGT2 (TRIGT3),
      .TRIGT3 (TRIGT4),
      .TRIGT4 (TRIGT5),
      .TRIGT5 (TRIGT6),
      .TRIGT6 (TRIGT7),
      .TRIGT7 (TRIGT8),
      .TRIGL0 (TRIGL1),
      .TRIGL1 (TRIGL2),
      .TRIGL2 (TRIGL3),
      .TRIGL3 (TRIGL4),
      .TRIGL4 (TRIGL5),
      .TRIGL5 (TRIGL6),
      .TRIGL6 (TRIGL7),
      .TRIGL7 (TRIGL8),
      .ARM (capture_arm),
      .CKDIV (ckdiv),
      .CSIZE (post_capture_count),
      .ARMED (capture_armed),
      .TRIGGERED (capture_triggered),
      .DONE (capture_done),
      .LRST (mm_rst),
      .TRIGPOS (trigger_pos),
      .BUFSIZE (buffer_size)
      );

endmodule
