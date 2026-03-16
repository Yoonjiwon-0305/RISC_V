`timescale 1ns / 1ps

module tb_RV32I ();

    logic clk, reset;

    RV32I_top dut (
        .clk  (clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;

        @(negedge clk);
        @(negedge clk);
        reset = 0;

        repeat (8) @(negedge clk);
        $stop;
    end

endmodule

// ver1 
/* Type your code here, or load an example. */
//int adder(int a, int b);
//void main(void) {
//    int i = 0;
//    int sum = 0;
//    while(i<11) {
//    sum = adder(i,sum);  
//    i = i + 1;
//}
//    return ;
//}
//int adder(int a, int b){
//    return a+b;
//}



// ver2
//void swap(int *a, int *b);
//void main(void) {
//    int aNUM [6] = {3,1,4,0,2};
//    int size = 5;
//    int i = 0,j =0 ;
//
//    for (i=0; i < size-1; i++){
//        for (j=0; j<(size-1); j++){
//            if(aNUM[j] < aNUM[j+1]){
//                swap(&aNUM[j],&aNUM[j+1]);
//            }
//        }
//    }
//
//    while(1);
//    return ;
//}
//void swap(int *a, int *b){
//    int temp;
//    temp = *b;
//    *b = *a;
//    *a = temp;
//    return;
//}
