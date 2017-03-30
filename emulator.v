module processor();

reg[7:0] PC;
reg[7:0] instruction;
reg[7:0] memory[0:255];
reg[7:0] A;
reg[7:0] B;
reg[7:0] C;
reg[7:0] D;
reg[7:0] results;
reg[7:0] Rrd;
reg[7:0] Rrs;
reg[7:0] Rrt;
reg clk = 0;

reg[7:0] cycle = 0;

wire[7:0] instruction_in;
assign instruction_in = memory[PC];

wire[7:0] dataMemory_in;
assign dataMemory_in = memory[Rrs_in];

wire[1:0] rd;
assign rd=instruction[3:2];

wire[1:0] rs;
assign rs=instruction[1:0];

wire[1:0] rt;
assign rt=instruction[5:4];

wire[3:0] immediate = instruction[3:0];

wire[0:0] doJump = ((Rrs <= 0) || ((Rrs & 'h80) != 0)) ? 1 : 0;

wire[1:0] opCode2;
assign opCode2=instruction[7:6];

wire[3:0] opCode4;
assign opCode4=instruction[7:4];

wire[1:0] wbRdOrRt;
assign wbRdOrRt = (opCode2 == 2 || opCode2 == 3) ? 1 :
                  (opCode4 == 2 || opCode4 == 3) ? 0 :
                  (opCode4 == 4 || opCode4 == 5) ? 2 : 0;

wire[1:0] resultsMux;
assign resultsMux = (opCode4 == 0 || opCode4 == 1) ? 0 :
                     opCode4 == 2 ? 3 :
                     opCode2 == 2 ? 1 :
                     opCode2 == 3 ? 2 : 0;
wire[7:0] Rrt_in;
assign Rrt_in = rt==0 ? A : rt==1 ? B : rt==2 ? C : D;

wire[7:0] Rrd_in;
assign Rrd_in = rd==0 ? A : rd==1 ? B : rd==2 ? C : D;


wire[7:0] Rrs_in;
assign Rrs_in = rs==0 ? A : rs==1 ? B : rs==2 ? C : D;

wire[7:0] PC_in;
assign PC_in = PC+1;

wire[7:0] register_in;
//assign register_in = resultsMux == 0 ? ALU : resultsMux == 1 ? joinerHigh : resultsMux == 2 ? joinerLow : results;
assign register_in = results;

wire[7:0] ALU = opCode4==0 ? Rrd + Rrs : opCode4==1 ? Rrd - Rrs : 0;
wire[7:0] joinerHigh = {immediate[3:0],Rrt_in[3:0]};
wire[7:0] joinerLow = {Rrt_in[7:4],immediate[3:0]};

wire[7:0] result_in;
assign result_in = resultsMux == 0 ? ALU : 
                   resultsMux == 1 ? joinerHigh : 
                   resultsMux == 2 ? joinerLow :
                   resultsMux == 3 ? dataMemory_in :
                   results;

`define START 0
`define FETCH 1
`define DECODE 2
`define EXECUTE 3
`define WRITEBACK 4

initial begin
   PC=0;

   A = 2;
   B = 2;
   C = 2;
   D = 6;

   // ADD  A=A+B
   //memory[0] = 01;
   //memory[1] = 'h70;

   // SUB   C=C-B
   //memory[0] = 'h19;
   //memory[1] = 'h70;

   // LUI and LLI  C=FF
   // A=0; B=0; C=0; D=0;
   // memory[0] = 'hBF;
   // memory[1] = 'h7F;
   // memory[2] = 'h70;
   
   // STORE memory[255] = D (which is a 6)  (store RD RS - from RD into RS)
   // So putting a 6 in D means we'll be storing FROM 11xx into C (10)
   // A=2; B=6; C=0; D='hff;
   // memory[0] = 'h37;  // 0011 0111   RD=01  RS=11
   // memory[1] = 'h70;

   // LOAD D=memory[255] (we'll load 255 with hex DC, which should wind up in D)
   //memory['hFF] = 'hDC;
   //memory[0] = 'hEF;
   //memory[1] = 'hAF;
   //memory[2] = 'h2E;
   //memory[3] = 'h70;

   // JLEZ - load 255 into A (overriding the above settings) while it is <= 0 inc it
   //        it should stop when A is 1
   //A = 'hFE;
   //B = 'h00;
   //C = 'h01;
   //memory[0] = 'h02;
   //memory[1] = 'h44;
   //memory[2] = 'h70;

   // JALR - jump back with return
   // JALR RD, RS  save PC+1 in RS and jump to RD
   //A = 'h02;
   //B = 'h03;
   //C = 'h01;
   //D = 0;
   //memory[0] = 'h5f;
   //memory[1] = 'h74;
   //memory[6] = 'h70;
/*
A=0; B=0; C=0; D=0;
		memory[0]=8'hbf;  memory[1]=8'hfe; memory[2]=8'h23; memory[3]=8'h15; memory[4]=8'ha0; memory[5]=8'he3; memory[6]=8'hb1; memory[7]=8'hf0; memory[8]=8'h4e; 
		memory[9]=8'h04; memory[10]=8'hb0; memory[11]=8'hf1; memory[12]=8'h1b; memory[13]=8'hb0; memory[14]=8'hf6; memory[15]=8'h5f; 
		memory[16]=8'hbf; memory[17]=8'hff; memory[18]=8'h37; memory[19]=8'h70;

		memory[254]=2;	//memory[FE] is 2
		memory[255]=0;	//memory[FF] is 0
*/

        A=0; B=0; C=0; D=0;
        memory[00]='hbf; memory[01]='hf0; memory[02]='h90; memory[03]='hd0; memory[04]='h37; memory[05]='hff; memory[06]='h37;
        memory[07]='hf1; memory[08]='hd1; memory[09]='h37; memory[10]='hf0; memory[11]='h23; memory[12]='hf1; memory[13]='h27;
        memory[14]='h2b; memory[15]='h08; memory[16]='hff; memory[17]='h3b; memory[18]='hf0; memory[19]='h37; memory[20]='h23;
        memory[21]='hff; memory[22]='h27; memory[23]='hf1; memory[24]='h37; memory[25]='ha0; memory[26]='he1; memory[27]='hfe;
        memory[28]='h27; memory[29]='h16; memory[30]='h37; memory[31]='h16; memory[32]='ha2; memory[33]='he6; memory[34]='h49;
        memory[35]='hea; memory[36]='ha0; memory[37]='h5a; memory[38]='h70;

        memory[254]=6;

end

always #1 clk=~clk;

always @(posedge clk) begin
   case(cycle)
      `START: 
         begin
            cycle <= `FETCH;
         end
      `FETCH: 
         begin
            if ((opCode4 == 4 && doJump) || opCode4 == 5) begin
               end
            if (opCode4 == 4 && doJump) begin
               PC <= Rrd_in;
               instruction <= memory[Rrd_in];
               cycle <= `DECODE;
               end
            else begin
               PC <= PC_in;
               instruction <= instruction_in;
               cycle <= `DECODE;
               end
         end
      `DECODE: 
         begin
            Rrd <= Rrd_in;
            Rrs <= Rrs_in;
            Rrt <= Rrt_in;
            cycle <= `EXECUTE;
         end
      `EXECUTE: 
         begin
            if (opCode4 == 3) begin
               memory[Rrs] <= Rrd;
               cycle <= `FETCH;
               end
            else if (opCode4 == 4) begin
               cycle <= `FETCH;
               end
            else if (opCode4 == 5) begin
               results <= Rrd_in;
               cycle <= `WRITEBACK;
               end
            else begin
               cycle <= `WRITEBACK;
               results <= result_in;
               end
         end
      `WRITEBACK: 
         begin
            case(wbRdOrRt)
               0: case(rd)
                     0: A <= register_in;
                     1: B <= register_in;
                     2: C <= register_in;
                     3: D <= register_in;
                  endcase
               1: case(rt)
                     0: A <= register_in;
                     1: B <= register_in;
                     2: C <= register_in;
                     3: D <= register_in;
                  endcase
               2: begin
                  case(rs)
                     0: A <= PC_in;
                     1: B <= PC_in;
                     2: C <= PC_in;
                     3: D <= PC_in;
                  endcase
                  PC <= Rrd_in;
                  end
            endcase
            cycle <= `FETCH;
         end
   endcase

   //if (cycle == 1)
   //    $display("A=%h B=%h C=%h D=%h cycle=%h PC=%h instruction=%h, immediate=%h, memory[254/5]=%h/%h, Rrs_in=%h, Rrd_in=%h, doJump=%h" ,
   //    A, B, C, D, cycle, PC, memory[PC], immediate, memory[254], memory['hFF], Rrs_in, Rrd_in, doJump);

   if (instruction == 'h70) begin
      $display("**** Memory[255] = %h", memory[255]);
      $finish;
      end
end

endmodule
