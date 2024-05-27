// `include "ctrl_encode_def.v"


module ctrl(Op, Funct, Zero, 
            RegWrite, MemWrite,
            EXTOp, ALUOp, NPCOp, 
            ALUSrcA, ALUSrcB, GPRSel, WDSel,
            dmOp
            );
            
   input  [5:0] Op;       // opcode
   input  [5:0] Funct;    // funct
   input        Zero;
   
   output       RegWrite; // control signal for register write
   output       MemWrite; // control signal for memory write
   output       EXTOp;    // control signal to signed extension
   output [3:0] ALUOp;    // ALU opertion
   output [1:0] NPCOp;    // next pc operation
   output [2:0] dmOp;     // DM operation
   output       ALUSrcA;   // ALU source for A
   output       ALUSrcB;   // ALU source for B

   output [1:0] GPRSel;   // general purpose register selection
   output [1:0] WDSel;    // (register) write data selection
   
  // r format
   wire rtype  = ~|Op;
   wire i_add  = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&~Funct[1]&~Funct[0]; // add
   wire i_nor  = rtype& Funct[5]&~Funct[4]&~Funct[3]&Funct[2]&Funct[1]&Funct[0]; // nor opcode: 000000 Funct: 100111
   wire i_sub  = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]&~Funct[0]; // sub
   wire i_sll  = rtype& ~Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&~Funct[1]&~Funct[0]; // sll opcode: 000000 Funct: 000000
   wire i_sllv  = rtype& ~Funct[5]&~Funct[4]&~Funct[3]&Funct[2]&~Funct[1]&~Funct[0]; // sllv opcode: 000000 Funct: 000100
   wire i_srl  = rtype& ~Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&Funct[1]&~Funct[0]; // sll opcode: 000000 Funct: 000010
   wire i_srlv  = rtype& ~Funct[5]&~Funct[4]&~Funct[3]&Funct[2]&Funct[1]&~Funct[0]; // srlv opcode: 000000 Funct: 000110
   wire i_xor  = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]& Funct[1]&~Funct[0]; // xor opcode: 000000 Funct:100110
   wire i_sra  = rtype&~Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]& Funct[0];// sra   opcpde:000000 Funct:000011
   wire i_srav = rtype&~Funct[5]&~Funct[4]&~Funct[3]& Funct[2]& Funct[1]& Funct[0];// srav  opcode:000000 Funct:000111
   wire i_and  = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]&~Funct[1]&~Funct[0]; // and
   wire i_or   = rtype& Funct[5]&~Funct[4]&~Funct[3]& Funct[2]&~Funct[1]& Funct[0]; // or
   wire i_slt  = rtype& Funct[5]&~Funct[4]& Funct[3]&~Funct[2]& Funct[1]&~Funct[0]; // slt
   wire i_sltu = rtype& Funct[5]&~Funct[4]& Funct[3]&~Funct[2]& Funct[1]& Funct[0]; // sltu
   wire i_addu = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]&~Funct[1]& Funct[0]; // addu
   wire i_subu = rtype& Funct[5]&~Funct[4]&~Funct[3]&~Funct[2]& Funct[1]& Funct[0]; // subu

  // i format
   wire i_addi = ~Op[5]&~Op[4]& Op[3]&~Op[2]&~Op[1]&~Op[0]; // addi
   wire i_ori  = ~Op[5]&~Op[4]& Op[3]& Op[2]&~Op[1]& Op[0]; // ori
   wire i_lw   =  Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]& Op[0]; // lw
   wire i_sw   =  Op[5]&~Op[4]& Op[3]&~Op[2]& Op[1]& Op[0]; // sw
   wire i_lui  = ~Op[5]&~Op[4]& Op[3]& Op[2]& Op[1]& Op[0]; // lui  opcode: 001111
   wire i_beq  = ~Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]&~Op[0]; // beq
   wire i_bne =  ~Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]&Op[0]; // bne opcode: 000101
   wire i_andi = ~Op[5]&~Op[4]& Op[3]& Op[2]&~Op[1]&~Op[0]; // andi opcode: 001100
   wire i_slti = ~Op[5]&~Op[4]& Op[3]& ~Op[2]&Op[1]&~Op[0]; // slti opcode: 001010
   wire i_lb   =  Op[5]&~Op[4]&~Op[3]&~Op[2]&~Op[1]&~Op[0]; // lb   opcode: 100000
   wire i_lh   =  Op[5]&~Op[4]&~Op[3]&~Op[2]&~Op[1]& Op[0]; // lh   opcode: 100001
   wire i_lbu  =  Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]&~Op[0]; // lbu  opcode: 100100
   wire i_lhu  =  Op[5]&~Op[4]&~Op[3]& Op[2]&~Op[1]& Op[0]; // lhu  opcode: 100101
   wire i_sb   =  Op[5]&~Op[4]& Op[3]&~Op[2]&~Op[1]&~Op[0]; // sb   opcode: 101000
   wire i_sh   =  Op[5]&~Op[4]& Op[3]&~Op[2]&~Op[1]& Op[0]; // sh   opcode: 101001

  // j format
   wire i_j    = ~Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]&~Op[0];  // j
   wire i_jal  = ~Op[5]&~Op[4]&~Op[3]&~Op[2]& Op[1]& Op[0];  // jal
   wire i_jalr  = rtype& ~Funct[5]&~Funct[4]&Funct[3]&~Funct[2]&~Funct[1]&Funct[0];  // jalr opcode:000000 Funct: 001001
   wire i_jr  = rtype& ~Funct[5]&~Funct[4]&Funct[3]&~Funct[2]&~Funct[1]&~Funct[0]; // jr opcode: 000000 Funct: 001000

  // generate control signals
  assign RegWrite   = rtype | i_lw | i_addi | i_ori | i_jal | i_andi | i_slti | i_lui | i_sll | i_sllv | i_srl | i_srlv | i_jalr | i_xor | i_sra | i_srav | i_lb | i_lh | i_lbu | i_lhu; // register write
  
  assign MemWrite   = i_sw | i_sb | i_sh;                           // memory write
  assign ALUSrcB    = i_lw | i_sw | i_addi | i_ori | i_andi | i_slti | i_lui | i_lb | i_lh | i_lbu | i_lhu | i_sh | i_sb;   // ALU B is from instruction immediate
  assign EXTOp      = i_addi | i_lw | i_sw | i_andi | i_slti | i_lb | i_lh | i_lbu | i_lhu | i_sh | i_sb;           // signed extension
  assign ALUSrcA    = i_sll | i_srl | i_sra;    // ALU A is from instruction shamt

  // GPRSel_RD   2'b00
  // GPRSel_RT   2'b01
  // GPRSel_31   2'b10
  assign GPRSel[0] = i_lw | i_addi | i_ori | i_andi | i_slti | i_lui | i_lb | i_lh | i_lbu | i_lhu;
  assign GPRSel[1] = i_jal;
  
  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10 
  assign WDSel[0] = i_lw | i_lb | i_lh | i_lbu | i_lhu;
  assign WDSel[1] = i_jal | i_jalr;

  // dmOp_LW    3'b000
  // dmOp_LH    3'b001
  // dmOp_LHU   3'b010
  // dmOp_LB    3'b011
  // dmOp_LBU   3'b100
  // dmOp_SW    3'b101
  // dmOp_SH    3'b110
  // dmOp_SB    3'b111
  assign dmOp[0]   = i_lh  | i_lb | i_sw | i_sb;
  assign dmOp[1]   = i_lhu | i_lb | i_sh | i_sb;
  assign dmOp[2]   = i_lbu | i_sw | i_sh | i_sb;

  // NPC_PLUS4   2'b00
  // NPC_BRANCH  2'b01
  // NPC_JUMP    2'b10
  // NPC_JR//JALR      2'b11
  assign NPCOp[0] = (i_beq & Zero) | (i_bne & ~Zero) | i_jr | i_jalr;
  assign NPCOp[1] = i_j | i_jal | i_jr | i_jalr;
  
  // ALU_NOP   4'b0000
  // ALU_ADD ADDI LW LH LHU LB LBU SW SB SH  4'b0001
  // ALU_SUB   4'b0010
  // ALU_AND   4'b0011
  // ALU_OR    4'b0100
  // ALU_SLT   4'b0101
  // ALU_SLTU  4'b0110
  // ALU_NOR   4'b0111
  // ALU_LUI   4'b1000
  // ALU_SLL ALU_SLLV   4'b1001
  // ALU_SRL ALU_SRLV   4'b1010
  // ALU_XOR 4'b1011
  // ALU_SRA ALU_SRAV 4'b1100
  assign ALUOp[0] = i_add | i_lw | i_sw | i_addi | i_and | i_slt | i_addu | i_andi | i_nor | i_slti | i_sll | i_sllv | i_xor | i_lb | i_lh | i_lbu | i_lhu | i_sh | i_sb;
  assign ALUOp[1] = i_sub | i_beq | i_and | i_sltu | i_subu | i_andi | i_bne | i_nor | i_srl | i_srlv | i_xor;
  assign ALUOp[2] = i_or | i_ori | i_slt | i_sltu | i_nor | i_slti | i_sra | i_srav;
  assign ALUOp[3] = i_lui | i_sll | i_sllv | i_srl | i_srlv | i_xor | i_sra | i_srav;

endmodule
