`timescale 1ns / 1ns

module control_test();

     reg [8:0] response [0:127]; 
     reg [3:0] stimulus [0:15]; 
     reg [2:0] opcode; 
     reg clk; 
     reg rst_n; 
     reg zero; 
     integer i,j; 

     reg[(3*8):1] mnemonic; 

     // Instantiate controller 
     control c0( 
          .rd(rd) , 
          .wr(wr) , 
          .ld_ir(ld_ir) , 
          .ld_ac(ld_ac) , 
          .ld_pc(ld_pc) , 
          .inc_pc(inc_pc) , 
          .halt(halt) , 
          .data_e(data_e) ,
          .sel(sel) , 
          .opcode(opcode) , 
          .zero(zero) , 
          .clk(clk) , 
          .rst_n(rst_n) 
     ); 

     // Define clock 
     initial begin 
     clk = 1 ; 
          forever begin 
               #10 clk = 0 ; 
               #10 clk = 1 ; 
          end 
     end 

     always @ ( opcode ) begin 
          case ( opcode ) 
               3'h0 : mnemonic = "HLT" ; 
               3'h1 : mnemonic = "SKZ" ; 
               3'h2 : mnemonic = "ADD" ; 
               3'h3 : mnemonic = "AND" ; 
               3'h4 : mnemonic = "XOR" ; 
               3'h5 : mnemonic = "LDA" ; 
               3'h6 : mnemonic = "STO" ; 
               3'h7 : mnemonic = "JMP" ; 
               default : mnemonic = "???" ; 
          endcase  
     end 

     // Monitor signals 
     initial  begin 
          $timeformat ( -9, 1, " ns", 9 ) ; 
          $display ( " time rd wr ld_ir ld_ac ld_pc inc_pc halt data_e sel opcode zero state" ) ; 
          $display ( "--------- -- -- ----- ----- ----- ------ ---- ------ --- ------ ---- -----" ) ; 
          // $shm_open ( "waves.shm" ) ;
          // $shm_probe ( "A" ) ; 
          // $shm_probe ( c0.state ) ; 
          $dumpvars(0,control_test); 
     end 

     // Apply stimulus 
     //从stimulus内存数组中读取指令并加载到指令寄存器中
     initial begin 
          $readmemb ( "stimulus.pat", stimulus ) ; 
          rst_n=1; 
          @ ( negedge clk ) rst_n = 0 ; 
          @ ( negedge clk ) rst_n = 1 ; 
          for ( i=0; i<=15; i=i+1 ) 
               @ ( posedge ld_ir ) 
               @ ( negedge clk ) 
               { opcode, zero } = stimulus[i] ; 
     end 

     // Check response 
     initial  begin 
     $readmemb ( "response.pat", response ) ; 
     @ ( posedge rst_n ) 
     for ( j=0; j<=127; j=j+1 ) 
     @ ( negedge clk ) begin 
          $display("%t %b %b %b %b %b %b %b %b %b %b %b %b", 
               $time,rd,wr,ld_ir,ld_ac,ld_pc,inc_pc,halt,data_e,sel,opcode,zero,c0.state ) ; 
          if ( {rd,wr,ld_ir,ld_ac,ld_pc,inc_pc,halt,data_e,sel} !== response[j] ) 
          begin : blk 
               reg [8:0] r; 
               r = response[j]; 
               $display ( "ERROR - response should be:" ) ; 
               $display ( "%t %b %b %b %b %b %b %b %b %b", 
                    $time,r[8],r[7],r[6],r[5],r[4],r[3],r[2],r[1],r[0] ) ; 
               $display ( "TEST FAILED" ) ; 
               $stop; 
               $finish ; 
          end 
     end 
     $display ( "TEST PASSED" ) ; 
     $stop; 
     $finish ; 
end 
endmodule
