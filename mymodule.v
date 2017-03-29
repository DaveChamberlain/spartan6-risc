`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:50:10 03/23/2017 
// Design Name: 
// Module Name:    mymodule 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`define ADD	4'd0
`define SUB	4'd1
`define LOAD	4'd2
`define STORE	4'd3
`define JLEZ	4'd4
`define JALR	4'd5
`define HALT	4'd7
`define LUI	2'd2
`define LLI	2'd3

`define START 0
`define FETCH 1
`define DECODE 2
`define EXECUTE 3
`define WRITEBACK 4
`define DONE 6
`define PAUSE 7

`define OPCODE_4	7:4	//opcode
`define OPCODE_2	7:6	//opcode for LLI LUI
`define INST_RS	1:0
`define INST_RD	3:2
`define INST_RT	5:4
`define INST_IMM	3:0	//4-bit immediate

module mymodule(
	 input CLK_12MHz,            // This is the FPGA system clock
    input Switch[0:5],
    output LED[0:7],
	 input DPSwitch[0:7]
    );

/*
	//reg	clk=0;

	reg [7:0] r[0:3];	//4 registers A; m[0]=B; m[0]=C; m[0]=D
	reg [7:0] pc;		//program counter
	reg [7:0] m[0:255];	//memory
	
	reg [20:0] ctr;
	reg [2:0] stage;
	
	reg [7:0] ir;
	reg [3:0] opc4;
	reg [1:0] opc2;
	reg [1:0] rs;
	reg [1:0] rd;
	reg [1:0] rt;
	reg [3:0] imm;
	
	reg [1:0] lock;

	assign LED[0] = m[245][0:0];
	assign LED[1] = m[245][1:1];
	assign LED[2] = m[245][2:2];
	assign LED[3] = m[245][3:3];
	assign LED[4] = m[245][4:4];
	assign LED[5] = m[245][5:5];
	assign LED[6] = m[245][6:6];
	assign LED[7] = m[245][7:7];
	
	wire [7:0] inst;	//quick access to the current instruction
	wire [7:0] pc_in;
	
	assign pc_in = pc + 1;
	
	//the current instruction is set to be the memory contents at pc
	assign inst=m[pc];

	initial begin
		//$display("starting...");

		stage=0;
		pc=0;		//set all the registers to 0
		r[0]=0;
		r[1]=0;
		r[2]=0;
		r[3]=0;
		
		lock =0;
		
		ctr = 0;

		// Finuacci code
   
		m[00]='hbf; m[01]='hf0; m[02]='h90; m[03]='hd0; m[04]='h37; m[05]='hff; m[06]='h37; 
		m[07]='hf1; m[08]='hd1; m[09]='h37; m[10]='hf0; m[11]='h23; m[12]='hf1; m[13]='h27; 
		m[14]='h2b; m[15]='h08; m[16]='hff; m[17]='h3b; m[18]='hf0; m[19]='h37; m[20]='h23; 
		m[21]='hff; m[22]='h27; m[23]='hf1; m[24]='h37; m[25]='ha0; m[26]='he1; m[27]='hfe; 
		m[28]='h27; m[29]='h16; m[30]='h37; m[31]='h16; m[32]='ha2; m[33]='he6; m[34]='h49; 
		m[35]='hea; m[36]='ha0; m[37]='h5a; m[38]='h70; 

		m[254]=6;	//memory[FE] is 6

	end
*/

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

reg [20:0] ctr;
reg [0:0] lock;

wire[7:0] result_in = Rrd + Rrs;

	assign LED[0] = memory[245][0:0];
	assign LED[1] = memory[245][1:1];
	assign LED[2] = memory[245][2:2];
	assign LED[3] = memory[245][3:3];
	assign LED[4] = memory[245][4:4];
	assign LED[5] = memory[245][5:5];
	assign LED[6] = memory[245][6:6];
	assign LED[7] = memory[245][7:7];
	

initial begin
   PC=0;
	lock=0;

   A = 3;
   B = 4;
   C = 5;
   D = 6;

   memory[0] = 01;
   memory[1] = 00;
   memory[2] = 04;
   memory[3] = 00;
   memory[4] = 'h70;
	
	memory[245] = 255;
end

//always #1 clk=~clk;

always @(posedge CLK_12MHz) begin
	   ctr = ctr + 1;
		
		if (!Switch[0] & !lock) begin
		    lock <= 1;
		    cycle <= `FETCH;
			 end
		else if(Switch[0] & lock) begin
		    lock <= 0;
			 end
		else if (!Switch[2] & !lock) begin
		    if (DPSwitch[0])
			     memory[245]<=rd;
		    else
			     memory[245]<=A;
			 end
		else if (!Switch[3] & !lock) begin
		    if (DPSwitch[0])
			     memory[245]<=rs;
		    else
			     memory[245]<=C;
			 end
		else if (!Switch[4] & !lock) begin
		    if (DPSwitch[0])
			     memory[245]<=PC;
		    else
			     memory[245]<=B;
			 end
		else if (!Switch[5] & !lock) begin
		    if (DPSwitch[0])
			     memory[245]<=PC;
		    else
			     memory[245]<=D;
			 end

		if (!Switch[1]) begin
			 A <= 3;
			 B <= 4;
			 C <= 5;
			 D <= 6;
			 
		    cycle <= `START;
			 end
		
		if (ctr == 0 & !lock) begin
		case(cycle)
      `START: 
         begin
			   PC <= 0;
				
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
            cycle <= `PAUSE;
				lock <= 1;
         end
		`PAUSE:
		   begin
			   memory[245] <= PC;
			end
   endcase

   //$display("A=%h B=%h C=%h D=%h cycle=%h PC=%h instruction=%h",
   //    A, B, C, D, cycle, PC, instruction);

   if (instruction == 'h70) cycle <= `PAUSE;
	end
end




/*
	//instructions are executed on the positive clock edge
	always @(posedge CLK_12MHz) begin
	
	   ctr = ctr + 1;
		
		if (!Switch[0] & !lock) begin
		    lock <= 1;
		    stage <= `FETCH;
			 end
		else if(Switch[0] & lock) begin
		    lock <= 0;
			 end
		else if (!Switch[2] & !lock) begin
		    if (DPSwitch[0])
			     m[245]<=rd;
		    else
			     m[245]<=r[0];
			 end
		else if (!Switch[3] & !lock) begin
		    if (DPSwitch[0])
			     m[245]<=rs;
		    else
			     m[245]<=r[1];
			 end
		else if (!Switch[4] & !lock) begin
		    if (DPSwitch[0])
			     m[245]<=rt;
		    else
			     m[245]<=r[2];
			 end
		else if (!Switch[5] & !lock) begin
		    if (DPSwitch[0]) 
			     m[245]<=imm;
		    else
			     m[245]<=r[3];
			 end

		if (!Switch[1]) begin
		    stage <= `START;
			 end
		
		if (ctr == 0 & !lock) begin
		    case (stage)
		        `START: begin
				      m[245]<='hF0;
						m[254]<=6;
						m[255]<=0;
				      stage <= `PAUSE;
						pc <= 0;
				      end
				  `FETCH: begin
				      pc <= pc_in;
						ir <= inst;
						stage <= `DECODE;
				      end
				  `DECODE: begin
						opc4 <= ir[`OPCODE_4];
						opc2 <= ir[`OPCODE_2];
						rs <= ir[`INST_RS];
						rd <= ir[`INST_RD];
						rt <= ir[`INST_RT];
						imm <= ir[`INST_IMM];
				      stage <= `EXECUTE;
						m[245]<=ir;
				      end
				  `EXECUTE: begin 
					   case(opc4)
						    `ADD: begin
							     r[rd]<=r[rd]+r[rs];
								  stage <= `WRITEBACK;
							     end
						    `SUB: begin
							     r[rd]<=r[rd]-r[rs];
								  stage <= `WRITEBACK;
							     end
						    `LOAD: begin
				              r[rd]<=m[r[rs]];
								  stage <= `WRITEBACK;
							     end
						    `STORE: begin
				              m[r[rs]]<=r[rd];
								  stage <= `WRITEBACK;
							     end
						    `JLEZ: begin
                          if (r[rs] <= 0)
				                  pc<=r[rd];
                          else
				                  pc<=pc+1;
								  stage <= `FETCH;
								  end
						    `JALR: begin
                          r[rs]<=pc+1;
				              pc<=r[rd];
								  stage <= `FETCH;
								  end
						    `HALT: begin
                          stage <= `DONE;
								  end
						    endcase 
			         case (opc2)
			             `LUI:	begin
				              r[rt]<={imm,r[rt][3:0]};
					           stage <= `PAUSE;
				              end
			             `LLI:	begin
				               r[rt]<={r[rt][7:4],imm};
					            stage <= `PAUSE;
				               end			 
				          endcase
				      end 
				  `WRITEBACK: begin
				      stage <= `FETCH;
						end
				  `DONE: begin
				      m[245] <= m[255];
				      end
						
			 endcase
		end


	end
*/
endmodule
