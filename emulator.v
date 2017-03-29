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
reg clk = 0;

reg[7:0] cycle = 0;

wire[7:0] instruction_in;
assign instruction_in = memory[PC];

wire[1:0] rd;
assign rd=instruction[3:2];

wire[1:0] rs;
assign rs=instruction[1:0];

wire[7:0] Rrd_in;
assign Rrd_in = rd==0 ? A : rd==1 ? B : rd==2 ? C : D;

wire[7:0] Rrs_in;
assign Rrs_in = rs==0 ? A : rs==1 ? B : rs==2 ? C : D;

wire[7:0] PC_in;
assign PC_in = PC+1;

wire[7:0] register_in;
assign register_in = results;

wire[7:0] result_in = Rrd + Rrs;

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

   memory[0] = 01;
   memory[1] = 00;
   memory[2] = 04;
   memory[3] = 00;
   memory[4] = 'h70;
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
            cycle <= `EXECUTE;
         end
      `EXECUTE: 
         begin
            results <= result_in;
            cycle <= `WRITEBACK;
         end
      `WRITEBACK: 
         begin
            case(rd)
                  0: A <= register_in;
                  1: B <= register_in;
                  2: C <= register_in;
                  3: D <= register_in;
               endcase
            cycle <= `FETCH;
         end
   endcase

   $display("A=%h B=%h C=%h D=%h cycle=%h PC=%h instruction=%h",
       A, B, C, D, cycle, PC, instruction);

   if (instruction == 'h70) $finish;
end

endmodule
