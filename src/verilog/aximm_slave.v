`define CAPCTL_ARM_INDEX 0
`define CAPCTL_RESET_INDEX 31
`define CAPSTAT_ARMED_INDEX 0
`define CAPSTAT_TRIG_INDEX 1
`define CAPSTAT_DONE_INDEX 2
`define CAPSTAT_READY_INDEX 3
`define CAPCFG_CKDIV_INDEX 1
`define CAPCFG_CSIZE_INDEX 6
`define CAPBUF_BSIZE_INDEX 0
`define TRIGPOS_TPOS_INDEX 0
module aximm_slave
#(
parameter integer C_S_AXI_DATA_WIDTH = 32,
parameter integer C_S_AXI_ADDR_WIDTH = 8
)
(
input  S_AXI_ACLK,
input  S_AXI_ARESETN,
input [(C_S_AXI_ADDR_WIDTH-1):0] S_AXI_AWADDR,
input [2:0] S_AXI_AWPROT,
input  S_AXI_AWVALID,
output  S_AXI_AWREADY,
input [(C_S_AXI_DATA_WIDTH-1):0] S_AXI_WDATA,
input [((C_S_AXI_DATA_WIDTH/8)-1):0] S_AXI_WSTRB,
input  S_AXI_WVALID,
output  S_AXI_WREADY,
output [1:0] S_AXI_BRESP,
output  S_AXI_BVALID,
input  S_AXI_BREADY,
input [(C_S_AXI_ADDR_WIDTH-1):0] S_AXI_ARADDR,
input [2:0] S_AXI_ARPROT,
input  S_AXI_ARVALID,
output  S_AXI_ARREADY,
output [(C_S_AXI_DATA_WIDTH-1):0] S_AXI_RDATA,
output [1:0] S_AXI_RRESP,
output  S_AXI_RVALID,
input  S_AXI_RREADY,
output [31:0] TRIGM0,
output [31:0] TRIGM1,
output [31:0] TRIGM2,
output [31:0] TRIGM3,
output [31:0] TRIGM4,
output [31:0] TRIGM5,
output [31:0] TRIGM6,
output [31:0] TRIGM7,
output [31:0] TRIGT0,
output [31:0] TRIGT1,
output [31:0] TRIGT2,
output [31:0] TRIGT3,
output [31:0] TRIGT4,
output [31:0] TRIGT5,
output [31:0] TRIGT6,
output [31:0] TRIGT7,
output [31:0] TRIGL0,
output [31:0] TRIGL1,
output [31:0] TRIGL2,
output [31:0] TRIGL3,
output [31:0] TRIGL4,
output [31:0] TRIGL5,
output [31:0] TRIGL6,
output [31:0] TRIGL7,
output  ARM,
output [4:0] CKDIV,
output [23:0] CSIZE,
output  LRST,
output [23:0] BUFSIZE,
input  ARMED,
input  TRIGGERED,
input  DONE,
input [23:0] TRIGPOS,
input  READY
);
    reg [(C_S_AXI_ADDR_WIDTH-1):0] axi_awaddr;
    reg  axi_awready;
    reg  axi_wready;
    reg [1:0] axi_bresp;
    reg  axi_bvalid;
    reg [(C_S_AXI_ADDR_WIDTH-1):0] axi_araddr;
    reg  axi_arready;
    reg [(C_S_AXI_DATA_WIDTH-1):0] axi_rdata;
    reg [1:0] axi_rresp;
    reg  axi_rvalid;
    localparam  ADDR_LSB = ((C_S_AXI_DATA_WIDTH/32)+1);
    localparam  OPT_MEM_ADDR_BITS = 4'b0110;
    //Register Space
    reg [31:0] REG_TRIGL7;
    localparam [31:0] WRMASK_TRIGL7 = 32'h00000000;
    reg [31:0] REG_TRIGL6;
    localparam [31:0] WRMASK_TRIGL6 = 32'h00000000;
    reg [31:0] REG_TRIGL5;
    localparam [31:0] WRMASK_TRIGL5 = 32'h00000000;
    reg [31:0] REG_TRIGL4;
    localparam [31:0] WRMASK_TRIGL4 = 32'h00000000;
    reg [31:0] REG_TRIGL3;
    localparam [31:0] WRMASK_TRIGL3 = 32'h00000000;
    reg [31:0] REG_TRIGL2;
    localparam [31:0] WRMASK_TRIGL2 = 32'h00000000;
    reg [31:0] REG_TRIGL1;
    localparam [31:0] WRMASK_TRIGL1 = 32'h00000000;
    reg [31:0] REG_TRIGL0;
    localparam [31:0] WRMASK_TRIGL0 = 32'h00000000;
    reg [31:0] REG_TRIGT7;
    localparam [31:0] WRMASK_TRIGT7 = 32'h00000000;
    reg [31:0] REG_TRIGT6;
    localparam [31:0] WRMASK_TRIGT6 = 32'h00000000;
    reg [31:0] REG_TRIGT5;
    localparam [31:0] WRMASK_TRIGT5 = 32'h00000000;
    reg [31:0] REG_TRIGT4;
    localparam [31:0] WRMASK_TRIGT4 = 32'h00000000;
    reg [31:0] REG_TRIGT3;
    localparam [31:0] WRMASK_TRIGT3 = 32'h00000000;
    reg [31:0] REG_TRIGT2;
    localparam [31:0] WRMASK_TRIGT2 = 32'h00000000;
    reg [31:0] REG_TRIGT1;
    localparam [31:0] WRMASK_TRIGT1 = 32'h00000000;
    reg [31:0] REG_TRIGT0;
    localparam [31:0] WRMASK_TRIGT0 = 32'h00000000;
    reg [31:0] REG_TRIGM7;
    localparam [31:0] WRMASK_TRIGM7 = 32'h00000000;
    reg [31:0] REG_TRIGM6;
    localparam [31:0] WRMASK_TRIGM6 = 32'h00000000;
    reg [31:0] REG_TRIGM5;
    localparam [31:0] WRMASK_TRIGM5 = 32'h00000000;
    reg [31:0] REG_TRIGM4;
    localparam [31:0] WRMASK_TRIGM4 = 32'h00000000;
    reg [31:0] REG_TRIGM3;
    localparam [31:0] WRMASK_TRIGM3 = 32'h00000000;
    reg [31:0] REG_TRIGM2;
    localparam [31:0] WRMASK_TRIGM2 = 32'h00000000;
    reg [31:0] REG_TRIGM1;
    localparam [31:0] WRMASK_TRIGM1 = 32'h00000000;
    reg [31:0] REG_TRIGM0;
    localparam [31:0] WRMASK_TRIGM0 = 32'h00000000;
    reg [31:0] REG_TRIGPOS;
    localparam [31:0] WRMASK_TRIGPOS = 32'h00000000;
    reg [31:0] REG_CAPBUF;
    localparam [31:0] WRMASK_CAPBUF = 32'h00FFFFFF;
    reg [31:0] REG_CAPCFG;
    localparam [31:0] WRMASK_CAPCFG = 32'h3FFFFFFE;
    reg [31:0] REG_CAPSTAT;
    localparam [31:0] WRMASK_CAPSTAT = 32'h00000000;
    reg [31:0] REG_CAPCTL;
    localparam [31:0] WRMASK_CAPCTL = 32'h80000001;
    wire  slv_reg_rden;
    wire  slv_reg_wren;
    reg [(C_S_AXI_DATA_WIDTH-1):0] reg_data_out;
    integer  byte_index;
    //I/O Connection assignments
    assign S_AXI_AWREADY = axi_awready;
    assign S_AXI_WREADY = axi_wready;
    assign S_AXI_BRESP = axi_bresp;
    assign S_AXI_BVALID = axi_bvalid;
    assign S_AXI_ARREADY = axi_arready;
    assign S_AXI_RDATA = axi_rdata;
    assign S_AXI_RRESP = axi_rresp;
    assign S_AXI_RVALID = axi_rvalid;
    //User logic
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_awready <= 1'h0;
        end
        else begin
            if (((~axi_awready&&S_AXI_AWVALID)&&S_AXI_WVALID)) begin
                axi_awready <= 1'h1;
            end
            else begin
                axi_awready <= 1'h0;
            end
        end
    end
    
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_awaddr <= 1'h0;
        end
        else begin
            if (((~axi_awready&&S_AXI_AWVALID)&&S_AXI_WVALID)) begin
                axi_awaddr <= S_AXI_AWADDR;
            end
        end
    end
    
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_wready <= 1'h0;
        end
        else begin
            if (((~axi_awready&&S_AXI_AWVALID)&&S_AXI_WVALID)) begin
                axi_wready <= 1'h1;
            end
            else begin
                axi_wready <= 1'h0;
            end
        end
    end
    
    //generate slave write enable
    assign slv_reg_wren = (((axi_wready&&S_AXI_WVALID)&&axi_awready)&&S_AXI_AWVALID);
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            //Reset Registers
            REG_TRIGL7 <= 32'h00000000;
            REG_TRIGL6 <= 32'h00000000;
            REG_TRIGL5 <= 32'h00000000;
            REG_TRIGL4 <= 32'h00000000;
            REG_TRIGL3 <= 32'h00000000;
            REG_TRIGL2 <= 32'h00000000;
            REG_TRIGL1 <= 32'h00000000;
            REG_TRIGL0 <= 32'h00000000;
            REG_TRIGT7 <= 32'h00000000;
            REG_TRIGT6 <= 32'h00000000;
            REG_TRIGT5 <= 32'h00000000;
            REG_TRIGT4 <= 32'h00000000;
            REG_TRIGT3 <= 32'h00000000;
            REG_TRIGT2 <= 32'h00000000;
            REG_TRIGT1 <= 32'h00000000;
            REG_TRIGT0 <= 32'h00000000;
            REG_TRIGM7 <= 32'h00000000;
            REG_TRIGM6 <= 32'h00000000;
            REG_TRIGM5 <= 32'h00000000;
            REG_TRIGM4 <= 32'h00000000;
            REG_TRIGM3 <= 32'h00000000;
            REG_TRIGM2 <= 32'h00000000;
            REG_TRIGM1 <= 32'h00000000;
            REG_TRIGM0 <= 32'h00000000;
            REG_TRIGPOS <= 32'h00000000;
            REG_CAPBUF <= 32'h00000000;
            REG_CAPCFG <= 32'h00000000;
            REG_CAPSTAT <= 32'h00000000;
            REG_CAPCTL <= 32'h00000000;
        end
        else begin
            if (slv_reg_wren) begin
                case (axi_awaddr[((ADDR_LSB+OPT_MEM_ADDR_BITS)-1):ADDR_LSB])
                default: begin
                    REG_CAPCTL <= REG_CAPCTL;
                    REG_CAPSTAT <= REG_CAPSTAT;
                    REG_CAPCFG <= REG_CAPCFG;
                    REG_CAPBUF <= REG_CAPBUF;
                    REG_TRIGPOS <= REG_TRIGPOS;
                    REG_TRIGM0 <= REG_TRIGM0;
                    REG_TRIGM1 <= REG_TRIGM1;
                    REG_TRIGM2 <= REG_TRIGM2;
                    REG_TRIGM3 <= REG_TRIGM3;
                    REG_TRIGM4 <= REG_TRIGM4;
                    REG_TRIGM5 <= REG_TRIGM5;
                    REG_TRIGM6 <= REG_TRIGM6;
                    REG_TRIGM7 <= REG_TRIGM7;
                    REG_TRIGT0 <= REG_TRIGT0;
                    REG_TRIGT1 <= REG_TRIGT1;
                    REG_TRIGT2 <= REG_TRIGT2;
                    REG_TRIGT3 <= REG_TRIGT3;
                    REG_TRIGT4 <= REG_TRIGT4;
                    REG_TRIGT5 <= REG_TRIGT5;
                    REG_TRIGT6 <= REG_TRIGT6;
                    REG_TRIGT7 <= REG_TRIGT7;
                    REG_TRIGL0 <= REG_TRIGL0;
                    REG_TRIGL1 <= REG_TRIGL1;
                    REG_TRIGL2 <= REG_TRIGL2;
                    REG_TRIGL3 <= REG_TRIGL3;
                    REG_TRIGL4 <= REG_TRIGL4;
                    REG_TRIGL5 <= REG_TRIGL5;
                    REG_TRIGL6 <= REG_TRIGL6;
                    REG_TRIGL7 <= REG_TRIGL7;
                end
                6'h0: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_CAPCTL[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h1: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_CAPSTAT[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h2: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_CAPCFG[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h3: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_CAPBUF[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h4: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGPOS[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h5: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGM0[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h6: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGM1[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h7: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGM2[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h8: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGM3[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h9: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGM4[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'hA: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGM5[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'hB: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGM6[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'hC: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGM7[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'hD: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGT0[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'hE: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGT1[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'hF: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGT2[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h10: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGT3[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h11: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGT4[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h12: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGT5[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h13: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGT6[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h14: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGT7[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h15: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGL0[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h16: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGL1[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h17: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGL2[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h18: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGL3[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h19: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGL4[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h1A: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGL5[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h1B: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGL6[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                6'h1C: begin
                    for (byte_index = 0; byte_index <= 3; byte_index = (byte_index+1)) begin
                        if (S_AXI_WSTRB[byte_index] == 1) begin
                            REG_TRIGL7[(byte_index*8)+:8] <= S_AXI_WDATA[(byte_index*8)+:8];
                        end
                    end
                    
                end
                
                endcase
                
            end
            if (REG_CAPCTL[0]) begin
                REG_CAPCTL[0] <= 1'h0;
            end
            if (REG_CAPCTL[31]) begin
                REG_CAPCTL[31] <= 1'h0;
            end
        end
    end
    
    //Write response logic
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_bvalid <= 1'h0;
            axi_bresp <= 1'h0;
        end
        else begin
            if (((((axi_awready&&S_AXI_AWVALID)&&~axi_bvalid)&&axi_wready)&&S_AXI_WVALID)) begin
                axi_bvalid <= 1'h1;
                axi_bresp <= 1'h0;
            end
            else begin
                if ((S_AXI_BREADY&&axi_bvalid)) begin
                    axi_bvalid <= 1'h0;
                end
            end
        end
    end
    
    //axi_arready generation
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_arready <= 1'h0;
            axi_araddr <= 1'h0;
        end
        else begin
            if ((~axi_arready&&S_AXI_ARVALID)) begin
                axi_arready <= 1'h1;
                axi_araddr <= S_AXI_ARADDR;
            end
            else begin
                axi_arready <= 1'h0;
            end
        end
    end
    
    //arvalid generation
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_rvalid <= 1'h0;
            axi_rresp <= 1'h0;
        end
        else begin
            if (((axi_arready&&S_AXI_ARVALID)&&~axi_rvalid)) begin
                axi_rvalid <= 1'h1;
                axi_rresp <= 1'h0;
            end
            else begin
                if ((axi_rvalid&&S_AXI_RREADY)) begin
                    axi_rvalid <= 1'h0;
                end
            end
        end
    end
    
    //Register select and read logic
    assign slv_reg_rden = ((axi_arready&S_AXI_ARVALID)&~axi_rvalid);
    always @(*) begin
        if (S_AXI_ARESETN == 0) begin
            reg_data_out <= 1'h0;
        end
        else begin
            case (axi_araddr[((ADDR_LSB+OPT_MEM_ADDR_BITS)-1):ADDR_LSB])
            default: begin
                reg_data_out <= 1'h0;
            end
            6'h0: begin
                reg_data_out <= 0;
            end
            6'h1: begin
                reg_data_out <= {28'b0000000000000000000000000000, READY, DONE, TRIGGERED, ARMED};
            end
            6'h2: begin
                reg_data_out <= {2'b00, REG_CAPCFG[29:6], REG_CAPCFG[5:1], 1'b0};
            end
            6'h3: begin
                reg_data_out <= {8'b00000000, REG_CAPBUF[23:0]};
            end
            6'h4: begin
                reg_data_out <= {8'b00000000, TRIGPOS};
            end
            6'h5: begin
                reg_data_out <= REG_TRIGM0;
            end
            6'h6: begin
                reg_data_out <= REG_TRIGM1;
            end
            6'h7: begin
                reg_data_out <= REG_TRIGM2;
            end
            6'h8: begin
                reg_data_out <= REG_TRIGM3;
            end
            6'h9: begin
                reg_data_out <= REG_TRIGM4;
            end
            6'hA: begin
                reg_data_out <= REG_TRIGM5;
            end
            6'hB: begin
                reg_data_out <= REG_TRIGM6;
            end
            6'hC: begin
                reg_data_out <= REG_TRIGM7;
            end
            6'hD: begin
                reg_data_out <= REG_TRIGT0;
            end
            6'hE: begin
                reg_data_out <= REG_TRIGT1;
            end
            6'hF: begin
                reg_data_out <= REG_TRIGT2;
            end
            6'h10: begin
                reg_data_out <= REG_TRIGT3;
            end
            6'h11: begin
                reg_data_out <= REG_TRIGT4;
            end
            6'h12: begin
                reg_data_out <= REG_TRIGT5;
            end
            6'h13: begin
                reg_data_out <= REG_TRIGT6;
            end
            6'h14: begin
                reg_data_out <= REG_TRIGT7;
            end
            6'h15: begin
                reg_data_out <= REG_TRIGL0;
            end
            6'h16: begin
                reg_data_out <= REG_TRIGL1;
            end
            6'h17: begin
                reg_data_out <= REG_TRIGL2;
            end
            6'h18: begin
                reg_data_out <= REG_TRIGL3;
            end
            6'h19: begin
                reg_data_out <= REG_TRIGL4;
            end
            6'h1A: begin
                reg_data_out <= REG_TRIGL5;
            end
            6'h1B: begin
                reg_data_out <= REG_TRIGL6;
            end
            6'h1C: begin
                reg_data_out <= REG_TRIGL7;
            end
            
            endcase
            
        end
    end
    
    //data output
    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 0) begin
            axi_rdata <= 1'h0;
        end
        else begin
            if (slv_reg_rden) begin
                axi_rdata <= reg_data_out;
            end
        end
    end
    
    //Output assignment
    assign BUFSIZE = REG_CAPBUF[23:0];
    assign LRST = REG_CAPCTL[31];
    assign CSIZE = REG_CAPCFG[29:6];
    assign CKDIV = REG_CAPCFG[5:1];
    assign ARM = REG_CAPCTL[0];
    assign TRIGL7 = REG_TRIGL7;
    assign TRIGL6 = REG_TRIGL6;
    assign TRIGL5 = REG_TRIGL5;
    assign TRIGL4 = REG_TRIGL4;
    assign TRIGL3 = REG_TRIGL3;
    assign TRIGL2 = REG_TRIGL2;
    assign TRIGL1 = REG_TRIGL1;
    assign TRIGL0 = REG_TRIGL0;
    assign TRIGT7 = REG_TRIGT7;
    assign TRIGT6 = REG_TRIGT6;
    assign TRIGT5 = REG_TRIGT5;
    assign TRIGT4 = REG_TRIGT4;
    assign TRIGT3 = REG_TRIGT3;
    assign TRIGT2 = REG_TRIGT2;
    assign TRIGT1 = REG_TRIGT1;
    assign TRIGT0 = REG_TRIGT0;
    assign TRIGM7 = REG_TRIGM7;
    assign TRIGM6 = REG_TRIGM6;
    assign TRIGM5 = REG_TRIGM5;
    assign TRIGM4 = REG_TRIGM4;
    assign TRIGM3 = REG_TRIGM3;
    assign TRIGM2 = REG_TRIGM2;
    assign TRIGM1 = REG_TRIGM1;
    assign TRIGM0 = REG_TRIGM0;
endmodule

