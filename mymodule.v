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

`define LED_MAP 255

module mymodule(input  CLK_12MHz,            // This is the FPGA system clock
			   input  Switch[0:5],
			   output LED[0:7],
			   input  DPSwitch[0:7]
			   );

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

	reg[7:0] cycle = 0;

	wire[7:0] instruction_in;
	assign instruction_in = memory[PC];

	wire[7:0] dataMemory_in;
	assign dataMemory_in = memory[Rrs_in];

	wire[1:0] rd;
	assign rd=instruction[`INST_RD];

	wire[1:0] rs;
	assign rs=instruction[`INST_RS];

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
	assign register_in = results;

	reg [10:0] ctr;
	reg [0:0] lock;

	wire[7:0] ALU = opCode4==0 ? Rrd + Rrs : opCode4==1 ? Rrd - Rrs : 0;
	wire[7:0] joinerHigh = {immediate[3:0],Rrt_in[3:0]};
	wire[7:0] joinerLow = {Rrt_in[7:4],immediate[3:0]};

	wire[7:0] result_in;
	assign result_in = resultsMux == 0 ? ALU : 
	                   resultsMux == 1 ? joinerHigh : 
	                   resultsMux == 2 ? joinerLow :
	                   resultsMux == 3 ? dataMemory_in :
	                   results;

	assign LED[0] = memory[`LED_MAP][0:0];
	assign LED[1] = memory[`LED_MAP][1:1];
	assign LED[2] = memory[`LED_MAP][2:2];
	assign LED[3] = memory[`LED_MAP][3:3];
	assign LED[4] = memory[`LED_MAP][4:4];
	assign LED[5] = memory[`LED_MAP][5:5];
	assign LED[6] = memory[`LED_MAP][6:6];
	assign LED[7] = memory[`LED_MAP][7:7];
	

	initial begin
		PC=0;
		lock=0;

		A = 3;
		B = 4;
		C = 5;
		D = 6;

		A=0; B=0; C=0; D=0;
		memory[00]='hbf; memory[01]='hf0; memory[02]='h90; memory[03]='hd0; memory[04]='h37; memory[05]='hff; memory[06]='h37;
		memory[07]='hf1; memory[08]='hd1; memory[09]='h37; memory[10]='hf0; memory[11]='h23; memory[12]='hf1; memory[13]='h27;
		memory[14]='h2b; memory[15]='h08; memory[16]='hff; memory[17]='h3b; memory[18]='hf0; memory[19]='h37; memory[20]='h23;
		memory[21]='hff; memory[22]='h27; memory[23]='hf1; memory[24]='h37; memory[25]='ha0; memory[26]='he1; memory[27]='hfe;
		memory[28]='h27; memory[29]='h16; memory[30]='h37; memory[31]='h16; memory[32]='ha2; memory[33]='he6; memory[34]='h49;
		memory[35]='hea; memory[36]='ha0; memory[37]='h5a; memory[38]='h70;

		memory[254]=6;
	end

	always @(posedge CLK_12MHz) begin
       // We can slow this down by inc a counter then only entering the case if counter is 0
	   ctr = ctr + 1;
		
/*		if (!Switch[0] & !lock) begin
		    lock <= 0;
		    cycle <= `FETCH;
			 end
		else if(Switch[0] & lock) begin
		    lock <= 0;
			 end
		else if (!Switch[2] & !lock) begin
		    if (DPSwitch[0])
			     memory[`LED_MAP]<=rd;
		    else
			     memory[`LED_MAP]<=A;
			 end
		else if (!Switch[3] & !lock) begin
		    if (DPSwitch[0])
			     memory[`LED_MAP]<=rs;
		    else
			     memory[`LED_MAP]<=C;
			 end
		else if (!Switch[4] & !lock) begin
		    if (DPSwitch[0])
			     memory[`LED_MAP]<=PC;
		    else
			     memory[`LED_MAP]<=B;
			 end
		else if (!Switch[5] & !lock) begin
		    if (DPSwitch[0])
			     memory[`LED_MAP]<=PC;
		    else
			     memory[`LED_MAP]<=D;
			 end

		if (!Switch[1]) begin
			 A <= 0;
			 B <= 0;
			 C <= 0;
			 D <= 0;
			 
			 memory[255] <= 0;
			 memory[254] <= 6;
			 
		    cycle <= `START;
			 end
	*/	
		//if (ctr == 0 & !lock) begin
		case(cycle)
			`START: 
				begin
					PC <= 0;
				
		            cycle <= `FETCH;
		        end
			`FETCH: 
		        begin
		            if ((opCode4 == `JLEZ && doJump) || opCode4 == `JALR) begin
					   // We're jumping so we want to skip this because we're changing PC
		               end
		            if (opCode4 == `JLEZ && doJump) begin
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
					// Shortcut the execution of a HALT instruction
		   		    if (opCode4 == `HALT) begin
		               cycle <= `PAUSE;
					else begin
		               cycle <= `EXECUTE;
					end
		        end
			`EXECUTE: 
		        begin
		            if (opCode4 == `STORE) begin
		               memory[Rrs] <= Rrd;
		               cycle <= `FETCH;
		               end
		            else if (opCode4 == `JLEZ) begin
		               cycle <= `FETCH;
		               end
		            else if (opCode4 == `JALR) begin
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
			`PAUSE:
				begin
				    //memory[`LED_MAP] <= 'hFF; 
			    end
		endcase

   //$display("A=%h B=%h C=%h D=%h cycle=%h PC=%h instruction=%h",
   //    A, B, C, D, cycle, PC, instruction);

	/*
	   if (instruction == 'h70) begin
	      cycle <= `PAUSE;
		  end
	*/
	//end
	end

endmodule
