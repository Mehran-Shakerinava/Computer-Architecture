// 64-bit Carry Look-ahead Adder Testbench
module CLA64_TB;

// Parameters
parameter NUMBER_OF_TESTS = 10000;
parameter DATA_WIDTH = 64;
parameter SEED = 777;

// Test Unit Inputs
reg [DATA_WIDTH - 1 : 0] lhs, rhs; 
reg cin, inv;

// Test Unit Outputs
wire [DATA_WIDTH - 1 : 0] res;
wire cout, of, p, g;

// Internal Variables
integer i;
reg flag, of0;
reg [DATA_WIDTH - 1 : 0] rhs_neg;

// Testing
initial
begin
  $display("-- TEST STARTED --");
  
  flag = 0;
  $random(SEED);
  
  $display("-- TEST ADD --");
  
  cin = 0;
  inv = 0;
  
  for (i = 0; i < NUMBER_OF_TESTS; i = i + 1)
  begin
    lhs = {$random, $random};
    rhs = {$random, $random};
    
    // 12
    // 9
    // 5
    // 4 
    #11 $display("ADD ; LHS : %d ; RHS : %d ; RESULT : %d ; CARRY : %1b ; OVERFLOW : %1b", $signed(lhs), $signed(rhs), $signed(res), cout, of);
    
    of0 = 0;
    if(lhs[DATA_WIDTH - 1] == rhs[DATA_WIDTH - 1] && lhs[DATA_WIDTH - 1] != res[DATA_WIDTH - 1])
    begin
      of0 = 1;
    end
    
    if ({cout, res} != $signed(lhs) + $signed(rhs) || of != of0)
    begin
      flag = 1;
      $display("FAIL");
    end
  end
  /*
  $display("-- TEST SUB --");
  
  cin = 1;
  inv = 1;
  
  for (i = 0; i < NUMBER_OF_TESTS; i = i + 1)
  begin
    lhs = {$random, $random};
    rhs = {$random, $random};
    
    #12 $display("SUB ; LHS : %d ; RHS : %d ; RESULT : %d ; CARRY : %b ; OVERFLOW : %b", $signed(lhs), $signed(rhs), $signed(res), cout, of);
    
    of0 = 0;
    rhs_neg = $signed(~rhs) + 1;
    if(lhs[DATA_WIDTH - 1] == rhs_neg[DATA_WIDTH - 1] && lhs[DATA_WIDTH - 1] != res[DATA_WIDTH - 1])
    begin
      of0 = 1;
    end
    
    if ({cout, res} != $signed(lhs) + $signed(~rhs) + 1 || of != of0)
    begin
      flag = 1;
      $display("FAIL");
    end
  end
  */
  $display("-- RESULT --");
  
  if(flag == 0)
  begin
    $display("ALL TESTS OK");
  end
  else
  begin
    $display("SOME TEST(S) FAILED");
  end
  
  $display("-- TEST FINISHED --");
  $break;
end

// Test Unit
CLA64 U0(
  .lhs  (lhs),
  .rhs  (rhs),
  .cin  (cin),
  .inv  (inv),
    
  .res  (res),
  .cout (cout),
  .of   (of),
  .p    (p),
  .g    (g)
);

endmodule