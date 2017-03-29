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

   A = 3;
   B = 4;
   C = 5;
   D = 6;

   // ADD  A=A+B
   //memory[0] = 01;
   //memory[1] = 'h70;

   // SUB   C=C-B
   //memory[0] = 'h19;
   //memory[1] = 'h70;

   // LUI and LLI  C=FF
   //memory[0] = 'hEF;
   //memory[1] = 'hAF;
   //memory[2] = 'h70;
   
   // STORE memory[255] = D (which is a 6 from above)
   //memory[0] = 'hEF;
   //memory[1] = 'hAF;
   //memory[2] = 'h3B;
   //memory[3] = 'h70;

   // LOAD D=memory[255] (we'll load 255 with hex DC, which should wind up in D)
   //memory['hFF] = 'hDC;
   //memory[0] = 'hEF;
   //memory[1] = 'hAF;
   //memory[2] = 'h2E;
   //memory[3] = 'h70;

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
            PC <= PC_in;
            instruction <= instruction_in;
            cycle <= `DECODE;
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
            results <= result_in;
            if (opCode4 == 3) begin
               memory[Rrd] <= Rrs;
               cycle <= `FETCH;
               end
            else
               cycle <= `WRITEBACK;
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
            endcase
            cycle <= `FETCH;
         end
   endcase

   $display("A=%h B=%h C=%h D=%h cycle=%h PC=%h instruction=%h, immediate=%h, memory[255]=%h, Rrs_in=%h" ,
       A, B, C, D, cycle, PC, instruction, immediate, memory[255], Rrs_in);

   if (instruction == 'h70) $finish;
end

endmodule
