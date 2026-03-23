`timescale 1ns / 1ps

module tb_multi_rv32i ();

    logic clk, reset;

    RV32I_top dut (
        .clk  (clk),
        .reset(reset)
    );
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;

        @(negedge clk);
        @(negedge clk);
        reset = 0;

        repeat (1250) @(negedge clk);
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
/*
main:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        sw      zero,-20(s0)
        sw      zero,-24(s0)
        j       .L2
.L3:
        lw      a1,-24(s0)
        lw      a0,-20(s0)
        call    adder
        sw      a0,-24(s0)
        lw      a5,-20(s0)
        addi    a5,a5,1
        sw      a5,-20(s0)
.L2:
        lw      a4,-20(s0)
        li      a5,10
        ble     a4,a5,.L3
        nop
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
adder:
        addi    sp,sp,-32
        sw      ra,28(sp)
        sw      s0,24(sp)
        addi    s0,sp,32
        sw      a0,-20(s0)
        sw      a1,-24(s0)
        lw      a4,-20(s0)
        lw      a5,-24(s0)
        add     a5,a4,a5
        mv      a0,a5
        lw      ra,28(sp)
        lw      s0,24(sp)
        addi    sp,sp,32
        jr      ra
*/

/*
0000000000000000 :
   0:	19000113          	li	sp,400

0000000000000004 
:
   4:	fe010113          	addi	sp,sp,-32
   8:	00112e23          	sw	ra,28(sp)
   c:	00812c23          	sw	s0,24(sp)
  10:	02010413          	addi	s0,sp,32
  14:	fe042623          	sw	zero,-20(s0)
  18:	fe042423          	sw	zero,-24(s0)
  1c:	0200006f          	j	3c 
  20:	fe842583          	lw	a1,-24(s0)
  24:	fec42503          	lw	a0,-20(s0)
  28:	034000ef          	jal	ra,5c 
  2c:	fea42423          	sw	a0,-24(s0)
  30:	fec42783          	lw	a5,-20(s0)
  34:	00178793          	addi	a5,a5,1
  38:	fef42623          	sw	a5,-20(s0)
  3c:	fec42703          	lw	a4,-20(s0)
  40:	00a00793          	li	a5,10
  44:	fce7dee3          	ble	a4,a5,20 
  48:	00000013          	nop
  4c:	01c12083          	lw	ra,28(sp)
  50:	01812403          	lw	s0,24(sp)
  54:	02010113          	addi	sp,sp,32
  58:	00008067          	ret

000000000000005c :
  5c:	fe010113          	addi	sp,sp,-32
  60:	00112e23          	sw	ra,28(sp)
  64:	00812c23          	sw	s0,24(sp)
  68:	02010413          	addi	s0,sp,32
  6c:	fea42623          	sw	a0,-20(s0)
  70:	feb42423          	sw	a1,-24(s0)
  74:	fec42703          	lw	a4,-20(s0)
  78:	fe842783          	lw	a5,-24(s0)
  7c:	00f707b3          	add	a5,a4,a5
  80:	00078513          	mv	a0,a5
  84:	01c12083          	lw	ra,28(sp)
  88:	01812403          	lw	s0,24(sp)
  8c:	02010113          	addi	sp,sp,32
  90:	00008067          	ret
*/

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
