
// data memory
`define dm_LW  3'b000
`define dm_LH  3'b001
`define dm_LHU 3'b010
`define dm_LB  3'b011
`define dm_LBU 3'b100
`define dm_SW  3'b101
`define dm_SH  3'b110
`define dm_SB  3'b111
module dm(clk, DMWr, addr, din, dout, dmOp);
   input          clk;
   input          DMWr;
   input  [8:2]   addr;  //地址限制
   input  [31:0]  din;
   input  [2:0]   dmOp;  
   output reg [31:0]  dout;
     
   reg [7:0] dmem[511:0];
   wire [31:0] addrByte;  
   always @(posedge clk) begin
         if (DMWr) begin
           $display("dmem[0x%8X] = 0x%8X,", addr, din); 
         end

         case (dmOp)
           `dm_SW : {dmem[addr+3], dmem[addr+2], dmem[addr+1], dmem[addr]} <= din;
           `dm_SH : {dmem[addr+1], dmem[addr]} <= din[15:0];
           `dm_SB : dmem[addr]  <= din[7:0];
         endcase
       end
    
     always @(*) begin
       case (dmOp)
           `dm_LH : dout <= {{16{dmem[addr+1][7]}}, dmem[addr+1], dmem[addr]};
           `dm_LHU: dout <= {16'b0, dmem[addr+1], dmem[addr]};
           `dm_LB : dout <= {{24{dmem[addr][7]}}, dmem[addr]};
           `dm_LBU: dout <= {24'b0, dmem[addr]};
           default: dout <= {dmem[addr+3], dmem[addr+2], dmem[addr+1], dmem[addr]};
       endcase
     end
    
   endmodule    