////////////////////////////////////////////////
// KC Posch
// August 2015
//
// S-TOY3 consists of 4 modules: 
//      cpu + memory + stdin + stdout
//
// S-TOY3: 4 new instructions: Push, Pop, Call, Ret
//         and new: indexed addressing mode for LDI and STI
//
// stdin has a data register (mapped to 0xFF) 
// and a control register (mapped to 0xFE); 
//
// the input values for stdin are
// produced in the testbed.
//
// new values at stdin appear only 
// every COUNTER_MAX clock cycles
//
//
/////////////////////////////////////////////////

`define STDIN_FILE  "stdin.txt"
`define STDOUT_FILE "stdout.txt"

`define COUNTER_MAX 200  // don't make too small
                        // otherwise software is
                        // not able to "catch"
                        // data from stdin

// amount of memory locations to be printed:
`define PRINT_MEM_LOCATIONS 'h40  

// for clock
`define HALF_PERIOD 50
`define MAX_DELAY 99

`define NUM_STATE_BITS 6

`define INIT    0
`define FETCH1  1
`define FETCH2  2
`define FETCH3  3
`define DECODE  4

`define HLT     5
`define ADD     6
`define SUB     7
`define AND     8
`define XOR     9
`define SHL     10
`define SHR     11

`define LDA     12

`define LD1     13
`define LD2     14
`define LD3     15

`define ST1     16
`define ST2     17

`define LDI1    18
`define LDI2    19
`define LDI3    20

`define STI1    21
`define STI2    22

`define BZ      23
`define BP      24

`define LDX1    25
`define LDX2    26
`define LDX3    27

`define STX1    28
`define STX2    29

`define PUSH1   30
`define PUSH2   31
`define PUSH3   32

`define POP1    33
`define POP2    34
`define POP3    35

`define CALL1   36
`define CALL2   37
`define CALL3   38

`define RET1    39
`define RET2    40
`define RET3    41

 
////////////////////////////////////////////////////
module cpu(clk, addr, din, dout, write);
  input clk;
  output [7:0]  addr;
  input  [15:0] din;
  output [15:0] dout;
  output write;

  wire clk;
  wire  [7:0]  addr;
  wire  [15:0] din;
  wire  [15:0] dout;
  reg   write;

  reg [7:0]  PC;         // the program counter
  reg [15:0] IR;         // the instruction register
  reg [15:0] R[15:0];    // the 16 registers
  reg halt;              // a 1-bit register

  reg [7:0]  MA;         // address to main memory
  reg [15:0] MDI;        // data from main memory
  reg [15:0] MDO;        // data to main memory

  reg [15:0] temp;       // no hardware

  assign addr = MA;
  assign dout = MDO;

  initial R[0] = 0;      // R[0] is constant 0
  

  // The ISE-model:
  always
    begin
      @(posedge clk) enter_new_state(`INIT);
      #`MAX_DELAY;
      PC   <= @(posedge clk) 8'h10;
      halt <= @(posedge clk) 0;
      while(1)
        begin
          @(posedge clk) enter_new_state(`FETCH1);
          #`MAX_DELAY;
          MA <= @(posedge clk) PC;
          
          @(posedge clk) enter_new_state(`FETCH2);
          #`MAX_DELAY;
          MDI <= @(posedge clk) din;  //MDI <= @(posedge clk) mem[MA];
          
          @(posedge clk) enter_new_state(`FETCH3);
          #`MAX_DELAY;
          IR <= @(posedge clk) MDI;
          
          @(posedge clk) enter_new_state(`DECODE);
          #`MAX_DELAY;
          PC <= @(posedge clk) PC + 1;
          case (IR[15:12])
            0:  begin
                  case (IR[11:8])
                    0:  while(1)
                          begin
                            @(posedge clk) enter_new_state(`HLT);
                            #`MAX_DELAY;
                            halt <= @(posedge clk) 1;
                          end
                    1:  begin
                          @(posedge clk) enter_new_state(`PUSH1);
                          #`MAX_DELAY;
                          R[15] <= @(posedge clk) R[15]-1;
                          
                          @(posedge clk) enter_new_state(`PUSH2);
                          #`MAX_DELAY;
                          MA  <= @(posedge clk) R[15];
                          MDO <= @(posedge clk) R[IR[3:0]];
                          
                          @(posedge clk) enter_new_state(`PUSH3);
                          write = 1; //mem[MA] <= @(posedge clk) MDO;
                          #`MAX_DELAY;
                        end
                        
                    2:  begin
                          @(posedge clk) enter_new_state(`POP1);
                          #`MAX_DELAY;
                          MA <= @(posedge clk) R[15];
                          
                          @(posedge clk) enter_new_state(`POP2);
                          #`MAX_DELAY;
                          R[15] <= @(posedge clk) R[15]+1;
                          MDI <= @(posedge clk) din; //MDI <= @(posedge clk) mem[MA];
                          
                          @(posedge clk) enter_new_state(`POP3);
                          #`MAX_DELAY;
                          R[IR[3:0]] <= @(posedge clk) MDI;
                        end
                    3:  begin
                          @(posedge clk) enter_new_state(`CALL1);
                          #`MAX_DELAY;
                          R[15] <= @(posedge clk) R[15]-1;
                          
                          @(posedge clk) enter_new_state(`CALL2);
                          #`MAX_DELAY;
                          MA  <= @(posedge clk) R[15];
                          MDO <= @(posedge clk) {8'h0, PC};
                          
                          @(posedge clk) enter_new_state(`CALL3);
                          write = 1; //mem[MA] <= @(posedge clk) MDO;
                          #`MAX_DELAY;
                          PC <= @(posedge clk) IR[7:0];
                        end
                    4:  begin
                          @(posedge clk) enter_new_state(`RET1);
                          #`MAX_DELAY;
                          MA <= @(posedge clk) R[15];
                          
                          @(posedge clk) enter_new_state(`RET2);
                          #`MAX_DELAY;
                          R[15] <= @(posedge clk) R[15]+1;
                          MDI <= @(posedge clk) din; //MDI <= @(posedge clk) mem[MA];
                          
                          @(posedge clk) enter_new_state(`RET3);
                          #`MAX_DELAY;
                          PC <= @(posedge clk) MDI;
                        end
                  endcase
                end
            1:  begin // R[d] <- R[s] + R[t]
                  @(posedge clk) enter_new_state(`ADD);
                  #`MAX_DELAY;
                  R[IR[11:8]] <= @(posedge clk) R[IR[7:4]] + R[IR[3:0]];
                end
            2:  begin // R[d] <- R[s] - R[t]
                  @(posedge clk) enter_new_state(`SUB);
                  #`MAX_DELAY;
                  R[IR[11:8]] <= @(posedge clk) R[IR[7:4]] - R[IR[3:0]];
                end
            3:  begin // R[d] <- R[s] & R[t]
                  @(posedge clk) enter_new_state(`AND);
                  #`MAX_DELAY;
                  R[IR[11:8]] <= @(posedge clk) R[IR[7:4]] & R[IR[3:0]];
                end
            4:  begin // R[d] <- R[s] ^ R[t]
                  @(posedge clk) enter_new_state(`XOR);
                  #`MAX_DELAY;
                  R[IR[11:8]] <= @(posedge clk) R[IR[7:4]] ^ R[IR[3:0]];
                end
            5:  begin // R[d] <- R[s] << R[t]
                  @(posedge clk) enter_new_state(`SHL);
                  #`MAX_DELAY;
                  R[IR[11:8]] <= @(posedge clk) R[IR[7:4]] << R[IR[3:0]];
                end
            6:  begin // R[d] <- R[s] >> R[t]
                  @(posedge clk) enter_new_state(`SHR);
                  #`MAX_DELAY;
                  // needs to be sign-extended right shift:
                  R[IR[11:8]] <= @(posedge clk) right_shift(R[IR[7:4]], R[IR[3:0]]);
                end
            7:  begin // R[d] <- IR[7:0]
                  @(posedge clk) enter_new_state(`LDA); // load immediate
                  #`MAX_DELAY;
                  R[IR[11:8]] <= @(posedge clk) IR[7:0];
                end

            8:  begin
                  @(posedge clk) enter_new_state(`LD1); // load direct
                  #`MAX_DELAY;
                  MA <= @(posedge clk) IR[7:0];

                  @(posedge clk) enter_new_state(`LD2);
                  #`MAX_DELAY;
                  MDI <= @(posedge clk) din; //MDI <= @(posedge clk) mem[MA];

                  @(posedge clk) enter_new_state(`LD3);
                  #`MAX_DELAY;                
                  R[IR[11:8]] <= @(posedge clk) MDI;
                end
            9:  begin
                  @(posedge clk) enter_new_state(`ST1); // store direct
                  #`MAX_DELAY;
                  MA  <= @(posedge clk) IR[7:0];
                  MDO <= @(posedge clk) R[IR[11:8]];

                  @(posedge clk) enter_new_state(`ST2);
                  write = 1; //mem[MA] <= @(posedge clk) MDO;
                  #`MAX_DELAY;
                end

           'hA: begin // R[d] <- mem[R[t] + s]
                  @(posedge clk) enter_new_state(`LDI1); // load indirect with offset
                  #`MAX_DELAY;
                  MA <= @(posedge clk) R[IR[3:0]] + IR[7:4];

                  @(posedge clk) enter_new_state(`LDI2); 
                  #`MAX_DELAY;
                  MDI <= @(posedge clk) din; //MDI <= @(posedge clk) mem[MA];

                  @(posedge clk) enter_new_state(`LDI3); 
                  #`MAX_DELAY;
                  R[IR[11:8]] <= @(posedge clk) MDI;
                end

           'hB: begin // mem[R[t] + s] <- R[d]
                  @(posedge clk) enter_new_state(`STI1); // store indirect with offset
                  #`MAX_DELAY;
                  MA  <= @(posedge clk) R[IR[3:0]] + IR[7:4];  
                  MDO <= @(posedge clk) R[IR[11:8]];

                  @(posedge clk) enter_new_state(`STI2); 
                  write = 1;//mem[MA] <= @(posedge clk) MDO;
                  #`MAX_DELAY;
                end

           'hC: begin // if(R[d]==0) PC <- IR[7:0]
                  @(posedge clk) enter_new_state(`BZ); // branch on zero
                  #`MAX_DELAY;
                  if (R[IR[11:8]] == 0)
                    PC <= @(posedge clk) IR[7:0];
                end
                
           'hD: begin // if(R[d]>0) PC <- IR[7:0]
                  @(posedge clk) enter_new_state(`BP); // branch on positive
                  #`MAX_DELAY;
                  if ((R[IR[11:8]] > 0) & (R[IR[11:8]] < 16'h8000)) 
                    PC <= @(posedge clk) IR[7:0];
                end
                
           'hE: begin   //R[d] <- mem[R[s] + R[t]]
                  @(posedge clk) enter_new_state(`LDX1);
                  #`MAX_DELAY;
                  MA <= @(posedge clk) R[IR[7:4]] + R[IR[3:0]];
              
                  @(posedge clk) enter_new_state(`LDX2);
                  MDI <= @(posedge clk) din; 

                  @(posedge clk) enter_new_state(`LDX3);
                  #`MAX_DELAY;
                  R[IR[11:8]] <= @(posedge clk) MDI;
                  
                end  

           'hF: begin // mem[R[t] + R[s]] <- R[d]
                  @(posedge clk) enter_new_state(`STX1);
                  #`MAX_DELAY;
                  MA  <= @(posedge clk) R[IR[3:0]] + R[IR[7:4]];  
                  MDO <= @(posedge clk) R[IR[11:8]];

                  @(posedge clk) enter_new_state(`STX2); 
                  write = 1;//mem[MA] <= @(posedge clk) MDO;
                  #`MAX_DELAY;
                end 
          endcase
        end // while
    end // always

  reg [`NUM_STATE_BITS-1:0] present_state;
  task enter_new_state;
      input [`NUM_STATE_BITS-1:0] this_state;
      begin
         present_state = this_state;
         #1;
         write = 0;
      end
   endtask
   
  /////////////////////////////////////////
  // right-shift sign extension
  /////////////////////////////////////////
  function [15:0] right_shift;
    input [15:0] source_reg;
    input [15:0] shift_amount;
    
    begin: serial_shift_with_duplication_of_top_bit
      reg bit_15;
      
      bit_15 = source_reg[15];
      
      repeat(shift_amount)
        begin
          source_reg = (source_reg >> 1) | (bit_15 << 15);
        end
      
      right_shift = source_reg;
    end
  endfunction
endmodule


////////////////////////////////////////////////////
module mem(clk, addr, din, dout, write);
  input clk;
  input [7:0]  addr;
  input  [15:0] din;
  output [15:0] dout;
  input write;

  wire clk;
  wire [7:0]  addr;
  wire  [15:0] din;
  wire [15:0] dout;
 
  reg [15:0] mem[0:255]; // toy's main memory

  // ------------------------------------
  // output logic of mem:
  assign dout = mem[addr];
  
  // ------------------------------------
  // neighborhood of mem:
  wire write;
  always @(posedge clk)
    if (write)
      mem[addr] <= din;
    //else
      // no change in memory

endmodule 


/////////////////////////////////////////////////////
module  stdin(clk, write_cr, addr, din, dout, ext_din, ext_write);
  input  clk;
  input  write_cr;
  input  addr;
  input  [15:0] din;
  output [15:0] dout;
  input  [15:0] ext_din;
  input  ext_write;

  wire  clk;
  wire  write;
  wire  addr;
  reg  [15:0] dout;
  
  reg   [15:0] DR;  // data register
  reg   CR;         // control register

  initial CR = 0;
  
  // reading DR and CR:
  always @(DR or CR or addr)
    if (addr == 0)
      dout <= {15'b0, CR};
    else if (addr == 1)
      dout <= DR;
  
  // writing CR:  
  always @(posedge clk)
    if (ext_write == 1) // testbed can write new data into stdin-module
        begin
            CR <= 1;
            DR <= ext_din;
        end
    else if (write_cr == 1) // CPU can write to control register
          CR <= din[0];
endmodule

/////////////////////////////////////////////////////
module stdout(clk, write, din);   
  input  clk;
  input  write;
  input  [15:0] din;

  integer std_out_handle; // file handle

  initial std_out_handle = $fopen(`STDOUT_FILE);
  
  always @(posedge clk)
    if (write == 1)
      begin
        // write to file whenever the cpu writes to address 0xFF:
        $fdisplay(std_out_handle, "%h", din);
      end
endmodule


////////////////////////////////////////////////////
module  stoy3(clk, ext_din, ext_write, ext_dout);
  input clk;
  input [15:0] ext_din;
  input ext_write;
  output [15:0] ext_dout;
  
  wire clk;
  wire [15:0] ext_din;
  wire ext_write;
  wire [15:0] ext_dout;
  
  
  wire [7:0]  cpu_addr;
  wire [15:0] cpu_din;
  wire [15:0] cpu_dout;
  wire        cpu_write;
  wire        cpu_read;
  
  wire [15:0] mem_dout;
  wire [15:0] data_from_stdin;

  // decoding cpu_write:
  wire write_mem;
  wire write_out;
  wire write_cr;
  assign write_mem = cpu_write & (cpu_addr != 8'hFF);
  assign write_out = cpu_write & (cpu_addr == 8'hFF);
  
  assign write_cr  = cpu_write & (cpu_addr == 8'hFE);

  // multiplexer for TOY's data input: data input
  // is taken either from input-output or from memory:
  assign cpu_din = (cpu_addr >= 16'hFE) ? data_from_stdin : mem_dout;

  cpu    cpu_i    (clk, cpu_addr, cpu_din, cpu_dout, cpu_write);  
  mem    mem_i    (clk, cpu_addr, cpu_dout, mem_dout, write_mem);
  stdin  stdin_i  (clk, write_cr, cpu_addr[0], cpu_dout, data_from_stdin, ext_din, ext_write);
  stdout stdout_i (clk, write_out, cpu_dout); 
endmodule

////////////////////////////////////////////////////
module testbed();
  // the oscillator:
  reg clk;   
  initial clk = 0;
  always  #`HALF_PERIOD clk = ~clk;

  wire [15:0] ext_din;
  reg ext_write;
  wire [15:0] ext_dout;

  // instance of toy:
  stoy3 toy_i(clk, ext_din, ext_write, ext_dout);  

  initial
    begin
    `include "ulbel22_ATOYcode.toy"
    end

  // printing memory contents to the console
  // before and after simulation:
  initial 
    begin
      #10   
      $write("--------------------------------------------------------\n");
      $write("Memory contents before execution:\n");
      $write("--------------------------------------------------------\n");
      print_memory_contents(`PRINT_MEM_LOCATIONS);
      $write("--------------------------------------------------------\n");
      $write("\n");
      $write("Start simulation...\n\n");
      
      wait(toy_i.cpu_i.halt); // wait until the halt-register gets set to 1
      
      $write("\n");
      $write("--------------------------------------------------------\n");
      $write("Memory contents after execution:\n");
      $write("--------------------------------------------------------\n");
      print_memory_contents(`PRINT_MEM_LOCATIONS);
      $write("--------------------------------------------------------\n");
      $write("Clock cycles: %d\n", $time/(2*`HALF_PERIOD));
      $write("--------------------------------------------------------\n");
      $finish();
    end
       
  // print simulation results for each clock period:
  always @(posedge clk) #1
    begin
      if (toy_i.cpu_i.present_state == `FETCH1)
        $write("--------------------------------------------------------\n");
    end

  always @(posedge clk) #2
    begin
      print_state_name(toy_i.cpu_i.present_state);
      $write("PC:0x%h IR:0x%h R1:%h R2:%h R3:%h R4:%h   ",
             toy_i.cpu_i.PC, toy_i.cpu_i.IR, 
             toy_i.cpu_i.R[1], toy_i.cpu_i.R[2], toy_i.cpu_i.R[3], toy_i.cpu_i.R[4]);
      $write("RE:%h RF:%h \n",
             toy_i.cpu_i.R[14], toy_i.cpu_i.R[15]);
       
    end

  task print_state_name;
    input [`NUM_STATE_BITS-1:0] state_code;
    begin
      case(state_code)
        `INIT:   $write("INIT   ");
        `FETCH1: $write("FETCH1 ");
        `FETCH2: $write("FETCH2 ");
        `FETCH3: $write("FETCH3 ");
        `DECODE: $write("DECODE ");
        `HLT:    $write("HLT    ");
        `ADD:    $write("ADD    ");
        `SUB:    $write("SUB    ");
        `AND:    $write("AND    ");
        `XOR:    $write("XOR    ");
        `SHL:    $write("SHL    ");
        `SHR:    $write("SHR    ");
        `LDA:    $write("LDA    ");
        `LD1:    $write("LD1    ");
        `LD2:    $write("LD2    ");
        `LD3:    $write("LD3    ");
        `ST1:    $write("ST1    ");
        `ST2:    $write("ST2    ");
        `LDI1:   $write("LDI1   ");
        `LDI2:   $write("LDI2   ");
        `LDI3:   $write("LDI3   ");
        `STI1:   $write("STI1   ");
        `STI2:   $write("STI2   ");
        `BZ:     $write("BZ     ");
        `BP:     $write("BP     ");
        `LDX1:   $write("LDX1   ");
        `LDX2:   $write("LDX2   ");
        `LDX3:   $write("LDX3   ");
        `STX1:   $write("STX1   ");
        `STX2:   $write("STX2   ");
        `PUSH1:  $write("PUSH1  ");
        `PUSH2:  $write("PUSH2  ");
        `PUSH3:  $write("PUSH3  ");
        `POP1:   $write("POP1   ");
        `POP2:   $write("POP2   ");
        `POP3:   $write("POP3   ");
        `CALL1:  $write("CALL1  ");
        `CALL2:  $write("CALL2  ");
        `CALL3:  $write("CALL3  ");
        `RET1:   $write("RET1   ");
        `RET2:   $write("RET2   ");
        `RET3:   $write("RET3   ");
      endcase
    end
  endtask

  // printing memory contents: don't forget to define PRINT_MEM_LOCATIONS    
  reg [8:0] i;
  reg [7:0] i_8bit;
  reg [7:0] addr;
  task print_memory_contents;
    input [8:0] amount_to_print; 
    begin
      i = 0;
      addr = 0;
      while(i < amount_to_print) 
        begin
          i_8bit = i[7:0];  
          for (addr=0; addr<8; addr=addr+1)
            $write("%H:%H ", i_8bit+addr, toy_i.mem_i.mem[i_8bit+addr]);
          $write("\n");
          i = i + 8;
        end
    end
  endtask 
  
  // providing data for standard input: 
  
  reg [15:0] stdin_buffer[0:255];  
  reg [7:0]  stdin_pointer;
  reg [15:0] counter; 
  
  initial
    begin
      // load data for stdin:
      $readmemh(`STDIN_FILE, stdin_buffer);
      stdin_pointer = 0;
      counter = 0;

      // for convenience: print the values
      // just read from the input file "std_in.dat"
      $write("--------------------------------------------------------\n");
      $write("Values on stdin (index 0 to 15 only):\n");
      $write("--------------------------------------------------------\n");
      for (i=0; i<8; i = i+1)
          $write("%H:%H ", i, stdin_buffer[i]);
      $write("\n");
      for (i=8; i<16; i = i+1)
          $write("%H:%H ", i, stdin_buffer[i]);
      $write("\n");
      $write("--------------------------------------------------------\n");
    end
    
  assign ext_din = stdin_buffer[stdin_pointer];

  // provide new input data only once very COUNTER_MAX clock cycles:
  always @(posedge clk)
    begin
        counter <= counter + 1;
        if (counter == `COUNTER_MAX)
            begin
                stdin_pointer = stdin_pointer + 1;
                counter <= 0;
            end
    end

  // activate write strobe "ext_write" once ever COUNTER_MAX clcok cycles:
  always @(posedge clk)
    if (counter == `COUNTER_MAX/2)
        ext_write <= 1;
    else
        ext_write <= 0;
endmodule
