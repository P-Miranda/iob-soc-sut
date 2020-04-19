`timescale 1ns / 1ps

module sm2ms_interconnect
  #(
    parameter N_SLAVES = 2,
    parameter ADDR_W = 32,
    parameter DATA_W = 32
    )
 
   (
    //master interface
    input                                m_valid,
    output reg                           m_ready,
    input [ADDR_W-1:0]                   m_addr,
    output reg [DATA_W-1:0]              m_rdata,
    input [DATA_W-1:0]                   m_wdata,
    input [DATA_W/8:0]                   m_wstrb,

    //slaves interface
    output reg [N_SLAVES-1:0]            s_valid,
    input [N_SLAVES-1:0]                 s_ready,
    output reg [N_SLAVES*ADDR_W-1:0]     s_addr,
    input [N_SLAVES*DATA_W-1:0]          s_rdata,
    output reg [N_SLAVES*DATA_W-1:0]     s_wdata,
    output reg [N_SLAVES*(DATA_W/8)-1:0] s_wstrb
    );

   integer                               i;
   always @* begin
      s_valid = {N_SLAVES{1'b0}};
      m_ready = 1'b0;
      s_addr = {N_SLAVES*ADDR_W{1'b0}};
      m_rdata = {DATA_W{1'b0}};
      s_wdata = {N_SLAVES*DATA_W{1'b0}};
      s_wstrb = {N_SLAVES*(DATA_W/8){1'b0}};
      
      for (i=0; i<N_SLAVES; i=i+1)
        if(i == m_addr[ADDR_W-1 -: $clog2(N_SLAVES)]) begin
           s_valid[i] = m_valid;           
           m_ready = s_ready[i];
           s_addr[(i+1)*ADDR_W -: ADDR_W] = m_addr;
           m_rdata = s_rdata[(i+1)*DATA_W -: DATA_W];
           s_wdata[(i+1)*DATA_W -: DATA_W] = m_wdata;
           s_wstrb[(i+1)*(DATA_W/8) -: DATA_W/8] = m_wstrb;
        end
   end

endmodule