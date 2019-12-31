module axisfifo
  #(
    parameter integer dataw = 32,
    parameter integer depth = 512
    )
   (

    // slave interface
    input [dataw-1:0]  slave_tdata,
    input              slave_tvalid,
    output             slave_tready,

    // master interface
    output [dataw-1:0] master_tdata,
    output master_tvalid,
    output master_tlast,
    input master_tready,

    input master_clk,
    input slave_clk,
    input reset

    );

   // RAM
   reg [dataw-1:0] fifo [0:depth-1];

   // read / write pointers
   reg [$clog2(depth-1)-1:0] wrpos;
   reg [$clog2(depth-1)-1:0] rdpos;

   // hack
   localparam [$clog2(depth)-1:0] fifo_depth = depth[$clog2(depth)-1:0];
   // FIFO signals
   // fullness counter
   wire [$clog2(depth)-1:0] fullness;
   assign fullness = (wrpos > rdpos) ? wrpos-rdpos + 1 : rdpos-wrpos + 1;
   // full signal
   wire                    ffull;
   assign ffull = fullness == fifo_depth;
   // empty signal
   wire                    fempty;
   assign fempty = wrpos == rdpos;
   // read enable
   wire                    fread;
   assign fread = master_tready && !fempty;
   // write enable
   wire                    fwrite;
   assign fwrite = slave_tvalid && !ffull;

   // axi master interface
   assign master_tvalid = !fempty;
   assign master_tdata = fifo[rdpos];

   // axi slave interface
   assign slave_tready = !ffull;

   // perform writes
   always @(posedge slave_clk) begin
      if (reset) begin
         wrpos <= 0;
      end
      else begin
         if (fwrite) begin
            fifo[wrpos] <= master_tdata;
            if (wrpos < (fifo_depth-1)) begin
               wrpos <= wrpos + 1;
            end
            else begin
               wrpos <= 0;
            end
         end
      end
   end

   // perform reads
   always @(posedge master_clk) begin
      if (reset) begin
         rdpos <= 0;
      end
      else begin
         if (fread) begin
            if (rdpos < (fifo_depth-1)) begin
               rdpos <= rdpos + 1;
            end
            else begin
               rdpos <= 0;
            end
         end
      end
   end

endmodule
