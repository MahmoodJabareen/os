
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8b013103          	ld	sp,-1872(sp) # 800088b0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8be70713          	addi	a4,a4,-1858 # 80008910 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	b3c78793          	addi	a5,a5,-1220 # 80005ba0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc917>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	38e080e7          	jalr	910(ra) # 800024ba <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8c650513          	addi	a0,a0,-1850 # 80010a50 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8b648493          	addi	s1,s1,-1866 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	94690913          	addi	s2,s2,-1722 # 80010ae8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7f4080e7          	jalr	2036(ra) # 800019b4 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	13c080e7          	jalr	316(ra) # 80002304 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	e86080e7          	jalr	-378(ra) # 8000205c <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	252080e7          	jalr	594(ra) # 80002464 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	82a50513          	addi	a0,a0,-2006 # 80010a50 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	81450513          	addi	a0,a0,-2028 # 80010a50 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	86f72b23          	sw	a5,-1930(a4) # 80010ae8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	78450513          	addi	a0,a0,1924 # 80010a50 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	21e080e7          	jalr	542(ra) # 80002510 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	75650513          	addi	a0,a0,1878 # 80010a50 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	73270713          	addi	a4,a4,1842 # 80010a50 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	70878793          	addi	a5,a5,1800 # 80010a50 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7727a783          	lw	a5,1906(a5) # 80010ae8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6c670713          	addi	a4,a4,1734 # 80010a50 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6b648493          	addi	s1,s1,1718 # 80010a50 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	67a70713          	addi	a4,a4,1658 # 80010a50 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72223          	sw	a5,1796(a4) # 80010af0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	63e78793          	addi	a5,a5,1598 # 80010a50 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ac7ab23          	sw	a2,1718(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6aa50513          	addi	a0,a0,1706 # 80010ae8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	c7a080e7          	jalr	-902(ra) # 800020c0 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	5f050513          	addi	a0,a0,1520 # 80010a50 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00020797          	auipc	a5,0x20
    8000047c:	77078793          	addi	a5,a5,1904 # 80020be8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	5c07a323          	sw	zero,1478(a5) # 80010b10 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	34f72923          	sw	a5,850(a4) # 800088d0 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	556dad83          	lw	s11,1366(s11) # 80010b10 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	50050513          	addi	a0,a0,1280 # 80010af8 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	3a250513          	addi	a0,a0,930 # 80010af8 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	38648493          	addi	s1,s1,902 # 80010af8 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	34650513          	addi	a0,a0,838 # 80010b18 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0d27a783          	lw	a5,210(a5) # 800088d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0a27b783          	ld	a5,162(a5) # 800088d8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0a273703          	ld	a4,162(a4) # 800088e0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	2b8a0a13          	addi	s4,s4,696 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	07048493          	addi	s1,s1,112 # 800088d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	07098993          	addi	s3,s3,112 # 800088e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	82e080e7          	jalr	-2002(ra) # 800020c0 <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	24a50513          	addi	a0,a0,586 # 80010b18 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	ff27a783          	lw	a5,-14(a5) # 800088d0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	ff873703          	ld	a4,-8(a4) # 800088e0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fe87b783          	ld	a5,-24(a5) # 800088d8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	21c98993          	addi	s3,s3,540 # 80010b18 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fd448493          	addi	s1,s1,-44 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fd490913          	addi	s2,s2,-44 # 800088e0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	740080e7          	jalr	1856(ra) # 8000205c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1e648493          	addi	s1,s1,486 # 80010b18 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f8e7bd23          	sd	a4,-102(a5) # 800088e0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	15c48493          	addi	s1,s1,348 # 80010b18 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00021797          	auipc	a5,0x21
    80000a02:	4ea78793          	addi	a5,a5,1258 # 80021ee8 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	13290913          	addi	s2,s2,306 # 80010b50 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	09650513          	addi	a0,a0,150 # 80010b50 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	41a50513          	addi	a0,a0,1050 # 80021ee8 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	06048493          	addi	s1,s1,96 # 80010b50 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	04850513          	addi	a0,a0,72 # 80010b50 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	01c50513          	addi	a0,a0,28 # 80010b50 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e28080e7          	jalr	-472(ra) # 80001998 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	df6080e7          	jalr	-522(ra) # 80001998 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	dea080e7          	jalr	-534(ra) # 80001998 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dd2080e7          	jalr	-558(ra) # 80001998 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d92080e7          	jalr	-622(ra) # 80001998 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d66080e7          	jalr	-666(ra) # 80001998 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b08080e7          	jalr	-1272(ra) # 80001988 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a6070713          	addi	a4,a4,-1440 # 800088e8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	aec080e7          	jalr	-1300(ra) # 80001988 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0e0080e7          	jalr	224(ra) # 80000f96 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00001097          	auipc	ra,0x1
    80000ec2:	792080e7          	jalr	1938(ra) # 80002650 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	d1a080e7          	jalr	-742(ra) # 80005be0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fdc080e7          	jalr	-36(ra) # 80001eaa <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	32e080e7          	jalr	814(ra) # 8000124c <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	070080e7          	jalr	112(ra) # 80000f96 <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	9a6080e7          	jalr	-1626(ra) # 800018d4 <procinit>
    petersoninit();  // 15 peterson locks
    80000f36:	00005097          	auipc	ra,0x5
    80000f3a:	286080e7          	jalr	646(ra) # 800061bc <petersoninit>
    trapinit();      // trap vectors
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	6ea080e7          	jalr	1770(ra) # 80002628 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f46:	00001097          	auipc	ra,0x1
    80000f4a:	70a080e7          	jalr	1802(ra) # 80002650 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	c7c080e7          	jalr	-900(ra) # 80005bca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f56:	00005097          	auipc	ra,0x5
    80000f5a:	c8a080e7          	jalr	-886(ra) # 80005be0 <plicinithart>
    binit();         // buffer cache
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	e2e080e7          	jalr	-466(ra) # 80002d8c <binit>
    iinit();         // inode table
    80000f66:	00002097          	auipc	ra,0x2
    80000f6a:	4d2080e7          	jalr	1234(ra) # 80003438 <iinit>
    fileinit();      // file table
    80000f6e:	00003097          	auipc	ra,0x3
    80000f72:	470080e7          	jalr	1136(ra) # 800043de <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f76:	00005097          	auipc	ra,0x5
    80000f7a:	d72080e7          	jalr	-654(ra) # 80005ce8 <virtio_disk_init>
    userinit();      // first user process
    80000f7e:	00001097          	auipc	ra,0x1
    80000f82:	d0e080e7          	jalr	-754(ra) # 80001c8c <userinit>
    __sync_synchronize();
    80000f86:	0ff0000f          	fence
    started = 1;
    80000f8a:	4785                	li	a5,1
    80000f8c:	00008717          	auipc	a4,0x8
    80000f90:	94f72e23          	sw	a5,-1700(a4) # 800088e8 <started>
    80000f94:	bf2d                	j	80000ece <main+0x56>

0000000080000f96 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f96:	1141                	addi	sp,sp,-16
    80000f98:	e422                	sd	s0,8(sp)
    80000f9a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa0:	00008797          	auipc	a5,0x8
    80000fa4:	9507b783          	ld	a5,-1712(a5) # 800088f0 <kernel_pagetable>
    80000fa8:	83b1                	srli	a5,a5,0xc
    80000faa:	577d                	li	a4,-1
    80000fac:	177e                	slli	a4,a4,0x3f
    80000fae:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb0:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fb4:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb8:	6422                	ld	s0,8(sp)
    80000fba:	0141                	addi	sp,sp,16
    80000fbc:	8082                	ret

0000000080000fbe <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fbe:	7139                	addi	sp,sp,-64
    80000fc0:	fc06                	sd	ra,56(sp)
    80000fc2:	f822                	sd	s0,48(sp)
    80000fc4:	f426                	sd	s1,40(sp)
    80000fc6:	f04a                	sd	s2,32(sp)
    80000fc8:	ec4e                	sd	s3,24(sp)
    80000fca:	e852                	sd	s4,16(sp)
    80000fcc:	e456                	sd	s5,8(sp)
    80000fce:	e05a                	sd	s6,0(sp)
    80000fd0:	0080                	addi	s0,sp,64
    80000fd2:	84aa                	mv	s1,a0
    80000fd4:	89ae                	mv	s3,a1
    80000fd6:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd8:	57fd                	li	a5,-1
    80000fda:	83e9                	srli	a5,a5,0x1a
    80000fdc:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fde:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fe0:	04b7f263          	bgeu	a5,a1,80001024 <walk+0x66>
    panic("walk");
    80000fe4:	00007517          	auipc	a0,0x7
    80000fe8:	0ec50513          	addi	a0,a0,236 # 800080d0 <digits+0x90>
    80000fec:	fffff097          	auipc	ra,0xfffff
    80000ff0:	552080e7          	jalr	1362(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ff4:	060a8663          	beqz	s5,80001060 <walk+0xa2>
    80000ff8:	00000097          	auipc	ra,0x0
    80000ffc:	aee080e7          	jalr	-1298(ra) # 80000ae6 <kalloc>
    80001000:	84aa                	mv	s1,a0
    80001002:	c529                	beqz	a0,8000104c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001004:	6605                	lui	a2,0x1
    80001006:	4581                	li	a1,0
    80001008:	00000097          	auipc	ra,0x0
    8000100c:	cca080e7          	jalr	-822(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001010:	00c4d793          	srli	a5,s1,0xc
    80001014:	07aa                	slli	a5,a5,0xa
    80001016:	0017e793          	ori	a5,a5,1
    8000101a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000101e:	3a5d                	addiw	s4,s4,-9
    80001020:	036a0063          	beq	s4,s6,80001040 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001024:	0149d933          	srl	s2,s3,s4
    80001028:	1ff97913          	andi	s2,s2,511
    8000102c:	090e                	slli	s2,s2,0x3
    8000102e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001030:	00093483          	ld	s1,0(s2)
    80001034:	0014f793          	andi	a5,s1,1
    80001038:	dfd5                	beqz	a5,80000ff4 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000103a:	80a9                	srli	s1,s1,0xa
    8000103c:	04b2                	slli	s1,s1,0xc
    8000103e:	b7c5                	j	8000101e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001040:	00c9d513          	srli	a0,s3,0xc
    80001044:	1ff57513          	andi	a0,a0,511
    80001048:	050e                	slli	a0,a0,0x3
    8000104a:	9526                	add	a0,a0,s1
}
    8000104c:	70e2                	ld	ra,56(sp)
    8000104e:	7442                	ld	s0,48(sp)
    80001050:	74a2                	ld	s1,40(sp)
    80001052:	7902                	ld	s2,32(sp)
    80001054:	69e2                	ld	s3,24(sp)
    80001056:	6a42                	ld	s4,16(sp)
    80001058:	6aa2                	ld	s5,8(sp)
    8000105a:	6b02                	ld	s6,0(sp)
    8000105c:	6121                	addi	sp,sp,64
    8000105e:	8082                	ret
        return 0;
    80001060:	4501                	li	a0,0
    80001062:	b7ed                	j	8000104c <walk+0x8e>

0000000080001064 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001064:	57fd                	li	a5,-1
    80001066:	83e9                	srli	a5,a5,0x1a
    80001068:	00b7f463          	bgeu	a5,a1,80001070 <walkaddr+0xc>
    return 0;
    8000106c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000106e:	8082                	ret
{
    80001070:	1141                	addi	sp,sp,-16
    80001072:	e406                	sd	ra,8(sp)
    80001074:	e022                	sd	s0,0(sp)
    80001076:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001078:	4601                	li	a2,0
    8000107a:	00000097          	auipc	ra,0x0
    8000107e:	f44080e7          	jalr	-188(ra) # 80000fbe <walk>
  if(pte == 0)
    80001082:	c105                	beqz	a0,800010a2 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001084:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001086:	0117f693          	andi	a3,a5,17
    8000108a:	4745                	li	a4,17
    return 0;
    8000108c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000108e:	00e68663          	beq	a3,a4,8000109a <walkaddr+0x36>
}
    80001092:	60a2                	ld	ra,8(sp)
    80001094:	6402                	ld	s0,0(sp)
    80001096:	0141                	addi	sp,sp,16
    80001098:	8082                	ret
  pa = PTE2PA(*pte);
    8000109a:	00a7d513          	srli	a0,a5,0xa
    8000109e:	0532                	slli	a0,a0,0xc
  return pa;
    800010a0:	bfcd                	j	80001092 <walkaddr+0x2e>
    return 0;
    800010a2:	4501                	li	a0,0
    800010a4:	b7fd                	j	80001092 <walkaddr+0x2e>

00000000800010a6 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a6:	715d                	addi	sp,sp,-80
    800010a8:	e486                	sd	ra,72(sp)
    800010aa:	e0a2                	sd	s0,64(sp)
    800010ac:	fc26                	sd	s1,56(sp)
    800010ae:	f84a                	sd	s2,48(sp)
    800010b0:	f44e                	sd	s3,40(sp)
    800010b2:	f052                	sd	s4,32(sp)
    800010b4:	ec56                	sd	s5,24(sp)
    800010b6:	e85a                	sd	s6,16(sp)
    800010b8:	e45e                	sd	s7,8(sp)
    800010ba:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010bc:	c639                	beqz	a2,8000110a <mappages+0x64>
    800010be:	8aaa                	mv	s5,a0
    800010c0:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010c2:	77fd                	lui	a5,0xfffff
    800010c4:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c8:	15fd                	addi	a1,a1,-1
    800010ca:	00c589b3          	add	s3,a1,a2
    800010ce:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010d2:	8952                	mv	s2,s4
    800010d4:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d8:	6b85                	lui	s7,0x1
    800010da:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010de:	4605                	li	a2,1
    800010e0:	85ca                	mv	a1,s2
    800010e2:	8556                	mv	a0,s5
    800010e4:	00000097          	auipc	ra,0x0
    800010e8:	eda080e7          	jalr	-294(ra) # 80000fbe <walk>
    800010ec:	cd1d                	beqz	a0,8000112a <mappages+0x84>
    if(*pte & PTE_V)
    800010ee:	611c                	ld	a5,0(a0)
    800010f0:	8b85                	andi	a5,a5,1
    800010f2:	e785                	bnez	a5,8000111a <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f4:	80b1                	srli	s1,s1,0xc
    800010f6:	04aa                	slli	s1,s1,0xa
    800010f8:	0164e4b3          	or	s1,s1,s6
    800010fc:	0014e493          	ori	s1,s1,1
    80001100:	e104                	sd	s1,0(a0)
    if(a == last)
    80001102:	05390063          	beq	s2,s3,80001142 <mappages+0x9c>
    a += PGSIZE;
    80001106:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001108:	bfc9                	j	800010da <mappages+0x34>
    panic("mappages: size");
    8000110a:	00007517          	auipc	a0,0x7
    8000110e:	fce50513          	addi	a0,a0,-50 # 800080d8 <digits+0x98>
    80001112:	fffff097          	auipc	ra,0xfffff
    80001116:	42c080e7          	jalr	1068(ra) # 8000053e <panic>
      panic("mappages: remap");
    8000111a:	00007517          	auipc	a0,0x7
    8000111e:	fce50513          	addi	a0,a0,-50 # 800080e8 <digits+0xa8>
    80001122:	fffff097          	auipc	ra,0xfffff
    80001126:	41c080e7          	jalr	1052(ra) # 8000053e <panic>
      return -1;
    8000112a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000112c:	60a6                	ld	ra,72(sp)
    8000112e:	6406                	ld	s0,64(sp)
    80001130:	74e2                	ld	s1,56(sp)
    80001132:	7942                	ld	s2,48(sp)
    80001134:	79a2                	ld	s3,40(sp)
    80001136:	7a02                	ld	s4,32(sp)
    80001138:	6ae2                	ld	s5,24(sp)
    8000113a:	6b42                	ld	s6,16(sp)
    8000113c:	6ba2                	ld	s7,8(sp)
    8000113e:	6161                	addi	sp,sp,80
    80001140:	8082                	ret
  return 0;
    80001142:	4501                	li	a0,0
    80001144:	b7e5                	j	8000112c <mappages+0x86>

0000000080001146 <kvmmap>:
{
    80001146:	1141                	addi	sp,sp,-16
    80001148:	e406                	sd	ra,8(sp)
    8000114a:	e022                	sd	s0,0(sp)
    8000114c:	0800                	addi	s0,sp,16
    8000114e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001150:	86b2                	mv	a3,a2
    80001152:	863e                	mv	a2,a5
    80001154:	00000097          	auipc	ra,0x0
    80001158:	f52080e7          	jalr	-174(ra) # 800010a6 <mappages>
    8000115c:	e509                	bnez	a0,80001166 <kvmmap+0x20>
}
    8000115e:	60a2                	ld	ra,8(sp)
    80001160:	6402                	ld	s0,0(sp)
    80001162:	0141                	addi	sp,sp,16
    80001164:	8082                	ret
    panic("kvmmap");
    80001166:	00007517          	auipc	a0,0x7
    8000116a:	f9250513          	addi	a0,a0,-110 # 800080f8 <digits+0xb8>
    8000116e:	fffff097          	auipc	ra,0xfffff
    80001172:	3d0080e7          	jalr	976(ra) # 8000053e <panic>

0000000080001176 <kvmmake>:
{
    80001176:	1101                	addi	sp,sp,-32
    80001178:	ec06                	sd	ra,24(sp)
    8000117a:	e822                	sd	s0,16(sp)
    8000117c:	e426                	sd	s1,8(sp)
    8000117e:	e04a                	sd	s2,0(sp)
    80001180:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001182:	00000097          	auipc	ra,0x0
    80001186:	964080e7          	jalr	-1692(ra) # 80000ae6 <kalloc>
    8000118a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000118c:	6605                	lui	a2,0x1
    8000118e:	4581                	li	a1,0
    80001190:	00000097          	auipc	ra,0x0
    80001194:	b42080e7          	jalr	-1214(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001198:	4719                	li	a4,6
    8000119a:	6685                	lui	a3,0x1
    8000119c:	10000637          	lui	a2,0x10000
    800011a0:	100005b7          	lui	a1,0x10000
    800011a4:	8526                	mv	a0,s1
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	fa0080e7          	jalr	-96(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011ae:	4719                	li	a4,6
    800011b0:	6685                	lui	a3,0x1
    800011b2:	10001637          	lui	a2,0x10001
    800011b6:	100015b7          	lui	a1,0x10001
    800011ba:	8526                	mv	a0,s1
    800011bc:	00000097          	auipc	ra,0x0
    800011c0:	f8a080e7          	jalr	-118(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011c4:	4719                	li	a4,6
    800011c6:	004006b7          	lui	a3,0x400
    800011ca:	0c000637          	lui	a2,0xc000
    800011ce:	0c0005b7          	lui	a1,0xc000
    800011d2:	8526                	mv	a0,s1
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	f72080e7          	jalr	-142(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011dc:	00007917          	auipc	s2,0x7
    800011e0:	e2490913          	addi	s2,s2,-476 # 80008000 <etext>
    800011e4:	4729                	li	a4,10
    800011e6:	80007697          	auipc	a3,0x80007
    800011ea:	e1a68693          	addi	a3,a3,-486 # 8000 <_entry-0x7fff8000>
    800011ee:	4605                	li	a2,1
    800011f0:	067e                	slli	a2,a2,0x1f
    800011f2:	85b2                	mv	a1,a2
    800011f4:	8526                	mv	a0,s1
    800011f6:	00000097          	auipc	ra,0x0
    800011fa:	f50080e7          	jalr	-176(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011fe:	4719                	li	a4,6
    80001200:	46c5                	li	a3,17
    80001202:	06ee                	slli	a3,a3,0x1b
    80001204:	412686b3          	sub	a3,a3,s2
    80001208:	864a                	mv	a2,s2
    8000120a:	85ca                	mv	a1,s2
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f38080e7          	jalr	-200(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001216:	4729                	li	a4,10
    80001218:	6685                	lui	a3,0x1
    8000121a:	00006617          	auipc	a2,0x6
    8000121e:	de660613          	addi	a2,a2,-538 # 80007000 <_trampoline>
    80001222:	040005b7          	lui	a1,0x4000
    80001226:	15fd                	addi	a1,a1,-1
    80001228:	05b2                	slli	a1,a1,0xc
    8000122a:	8526                	mv	a0,s1
    8000122c:	00000097          	auipc	ra,0x0
    80001230:	f1a080e7          	jalr	-230(ra) # 80001146 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001234:	8526                	mv	a0,s1
    80001236:	00000097          	auipc	ra,0x0
    8000123a:	608080e7          	jalr	1544(ra) # 8000183e <proc_mapstacks>
}
    8000123e:	8526                	mv	a0,s1
    80001240:	60e2                	ld	ra,24(sp)
    80001242:	6442                	ld	s0,16(sp)
    80001244:	64a2                	ld	s1,8(sp)
    80001246:	6902                	ld	s2,0(sp)
    80001248:	6105                	addi	sp,sp,32
    8000124a:	8082                	ret

000000008000124c <kvminit>:
{
    8000124c:	1141                	addi	sp,sp,-16
    8000124e:	e406                	sd	ra,8(sp)
    80001250:	e022                	sd	s0,0(sp)
    80001252:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001254:	00000097          	auipc	ra,0x0
    80001258:	f22080e7          	jalr	-222(ra) # 80001176 <kvmmake>
    8000125c:	00007797          	auipc	a5,0x7
    80001260:	68a7ba23          	sd	a0,1684(a5) # 800088f0 <kernel_pagetable>
}
    80001264:	60a2                	ld	ra,8(sp)
    80001266:	6402                	ld	s0,0(sp)
    80001268:	0141                	addi	sp,sp,16
    8000126a:	8082                	ret

000000008000126c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000126c:	715d                	addi	sp,sp,-80
    8000126e:	e486                	sd	ra,72(sp)
    80001270:	e0a2                	sd	s0,64(sp)
    80001272:	fc26                	sd	s1,56(sp)
    80001274:	f84a                	sd	s2,48(sp)
    80001276:	f44e                	sd	s3,40(sp)
    80001278:	f052                	sd	s4,32(sp)
    8000127a:	ec56                	sd	s5,24(sp)
    8000127c:	e85a                	sd	s6,16(sp)
    8000127e:	e45e                	sd	s7,8(sp)
    80001280:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001282:	03459793          	slli	a5,a1,0x34
    80001286:	e795                	bnez	a5,800012b2 <uvmunmap+0x46>
    80001288:	8a2a                	mv	s4,a0
    8000128a:	892e                	mv	s2,a1
    8000128c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	0632                	slli	a2,a2,0xc
    80001290:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001294:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001296:	6b05                	lui	s6,0x1
    80001298:	0735e263          	bltu	a1,s3,800012fc <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000129c:	60a6                	ld	ra,72(sp)
    8000129e:	6406                	ld	s0,64(sp)
    800012a0:	74e2                	ld	s1,56(sp)
    800012a2:	7942                	ld	s2,48(sp)
    800012a4:	79a2                	ld	s3,40(sp)
    800012a6:	7a02                	ld	s4,32(sp)
    800012a8:	6ae2                	ld	s5,24(sp)
    800012aa:	6b42                	ld	s6,16(sp)
    800012ac:	6ba2                	ld	s7,8(sp)
    800012ae:	6161                	addi	sp,sp,80
    800012b0:	8082                	ret
    panic("uvmunmap: not aligned");
    800012b2:	00007517          	auipc	a0,0x7
    800012b6:	e4e50513          	addi	a0,a0,-434 # 80008100 <digits+0xc0>
    800012ba:	fffff097          	auipc	ra,0xfffff
    800012be:	284080e7          	jalr	644(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012c2:	00007517          	auipc	a0,0x7
    800012c6:	e5650513          	addi	a0,a0,-426 # 80008118 <digits+0xd8>
    800012ca:	fffff097          	auipc	ra,0xfffff
    800012ce:	274080e7          	jalr	628(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012d2:	00007517          	auipc	a0,0x7
    800012d6:	e5650513          	addi	a0,a0,-426 # 80008128 <digits+0xe8>
    800012da:	fffff097          	auipc	ra,0xfffff
    800012de:	264080e7          	jalr	612(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012e2:	00007517          	auipc	a0,0x7
    800012e6:	e5e50513          	addi	a0,a0,-418 # 80008140 <digits+0x100>
    800012ea:	fffff097          	auipc	ra,0xfffff
    800012ee:	254080e7          	jalr	596(ra) # 8000053e <panic>
    *pte = 0;
    800012f2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f6:	995a                	add	s2,s2,s6
    800012f8:	fb3972e3          	bgeu	s2,s3,8000129c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012fc:	4601                	li	a2,0
    800012fe:	85ca                	mv	a1,s2
    80001300:	8552                	mv	a0,s4
    80001302:	00000097          	auipc	ra,0x0
    80001306:	cbc080e7          	jalr	-836(ra) # 80000fbe <walk>
    8000130a:	84aa                	mv	s1,a0
    8000130c:	d95d                	beqz	a0,800012c2 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000130e:	6108                	ld	a0,0(a0)
    80001310:	00157793          	andi	a5,a0,1
    80001314:	dfdd                	beqz	a5,800012d2 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001316:	3ff57793          	andi	a5,a0,1023
    8000131a:	fd7784e3          	beq	a5,s7,800012e2 <uvmunmap+0x76>
    if(do_free){
    8000131e:	fc0a8ae3          	beqz	s5,800012f2 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001322:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001324:	0532                	slli	a0,a0,0xc
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	6c4080e7          	jalr	1732(ra) # 800009ea <kfree>
    8000132e:	b7d1                	j	800012f2 <uvmunmap+0x86>

0000000080001330 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001330:	1101                	addi	sp,sp,-32
    80001332:	ec06                	sd	ra,24(sp)
    80001334:	e822                	sd	s0,16(sp)
    80001336:	e426                	sd	s1,8(sp)
    80001338:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000133a:	fffff097          	auipc	ra,0xfffff
    8000133e:	7ac080e7          	jalr	1964(ra) # 80000ae6 <kalloc>
    80001342:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001344:	c519                	beqz	a0,80001352 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001346:	6605                	lui	a2,0x1
    80001348:	4581                	li	a1,0
    8000134a:	00000097          	auipc	ra,0x0
    8000134e:	988080e7          	jalr	-1656(ra) # 80000cd2 <memset>
  return pagetable;
}
    80001352:	8526                	mv	a0,s1
    80001354:	60e2                	ld	ra,24(sp)
    80001356:	6442                	ld	s0,16(sp)
    80001358:	64a2                	ld	s1,8(sp)
    8000135a:	6105                	addi	sp,sp,32
    8000135c:	8082                	ret

000000008000135e <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000135e:	7179                	addi	sp,sp,-48
    80001360:	f406                	sd	ra,40(sp)
    80001362:	f022                	sd	s0,32(sp)
    80001364:	ec26                	sd	s1,24(sp)
    80001366:	e84a                	sd	s2,16(sp)
    80001368:	e44e                	sd	s3,8(sp)
    8000136a:	e052                	sd	s4,0(sp)
    8000136c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000136e:	6785                	lui	a5,0x1
    80001370:	04f67863          	bgeu	a2,a5,800013c0 <uvmfirst+0x62>
    80001374:	8a2a                	mv	s4,a0
    80001376:	89ae                	mv	s3,a1
    80001378:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	76c080e7          	jalr	1900(ra) # 80000ae6 <kalloc>
    80001382:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001384:	6605                	lui	a2,0x1
    80001386:	4581                	li	a1,0
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	94a080e7          	jalr	-1718(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001390:	4779                	li	a4,30
    80001392:	86ca                	mv	a3,s2
    80001394:	6605                	lui	a2,0x1
    80001396:	4581                	li	a1,0
    80001398:	8552                	mv	a0,s4
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	d0c080e7          	jalr	-756(ra) # 800010a6 <mappages>
  memmove(mem, src, sz);
    800013a2:	8626                	mv	a2,s1
    800013a4:	85ce                	mv	a1,s3
    800013a6:	854a                	mv	a0,s2
    800013a8:	00000097          	auipc	ra,0x0
    800013ac:	986080e7          	jalr	-1658(ra) # 80000d2e <memmove>
}
    800013b0:	70a2                	ld	ra,40(sp)
    800013b2:	7402                	ld	s0,32(sp)
    800013b4:	64e2                	ld	s1,24(sp)
    800013b6:	6942                	ld	s2,16(sp)
    800013b8:	69a2                	ld	s3,8(sp)
    800013ba:	6a02                	ld	s4,0(sp)
    800013bc:	6145                	addi	sp,sp,48
    800013be:	8082                	ret
    panic("uvmfirst: more than a page");
    800013c0:	00007517          	auipc	a0,0x7
    800013c4:	d9850513          	addi	a0,a0,-616 # 80008158 <digits+0x118>
    800013c8:	fffff097          	auipc	ra,0xfffff
    800013cc:	176080e7          	jalr	374(ra) # 8000053e <panic>

00000000800013d0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013d0:	1101                	addi	sp,sp,-32
    800013d2:	ec06                	sd	ra,24(sp)
    800013d4:	e822                	sd	s0,16(sp)
    800013d6:	e426                	sd	s1,8(sp)
    800013d8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013da:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013dc:	00b67d63          	bgeu	a2,a1,800013f6 <uvmdealloc+0x26>
    800013e0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013e2:	6785                	lui	a5,0x1
    800013e4:	17fd                	addi	a5,a5,-1
    800013e6:	00f60733          	add	a4,a2,a5
    800013ea:	767d                	lui	a2,0xfffff
    800013ec:	8f71                	and	a4,a4,a2
    800013ee:	97ae                	add	a5,a5,a1
    800013f0:	8ff1                	and	a5,a5,a2
    800013f2:	00f76863          	bltu	a4,a5,80001402 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013f6:	8526                	mv	a0,s1
    800013f8:	60e2                	ld	ra,24(sp)
    800013fa:	6442                	ld	s0,16(sp)
    800013fc:	64a2                	ld	s1,8(sp)
    800013fe:	6105                	addi	sp,sp,32
    80001400:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001402:	8f99                	sub	a5,a5,a4
    80001404:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001406:	4685                	li	a3,1
    80001408:	0007861b          	sext.w	a2,a5
    8000140c:	85ba                	mv	a1,a4
    8000140e:	00000097          	auipc	ra,0x0
    80001412:	e5e080e7          	jalr	-418(ra) # 8000126c <uvmunmap>
    80001416:	b7c5                	j	800013f6 <uvmdealloc+0x26>

0000000080001418 <uvmalloc>:
  if(newsz < oldsz)
    80001418:	0ab66563          	bltu	a2,a1,800014c2 <uvmalloc+0xaa>
{
    8000141c:	7139                	addi	sp,sp,-64
    8000141e:	fc06                	sd	ra,56(sp)
    80001420:	f822                	sd	s0,48(sp)
    80001422:	f426                	sd	s1,40(sp)
    80001424:	f04a                	sd	s2,32(sp)
    80001426:	ec4e                	sd	s3,24(sp)
    80001428:	e852                	sd	s4,16(sp)
    8000142a:	e456                	sd	s5,8(sp)
    8000142c:	e05a                	sd	s6,0(sp)
    8000142e:	0080                	addi	s0,sp,64
    80001430:	8aaa                	mv	s5,a0
    80001432:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001434:	6985                	lui	s3,0x1
    80001436:	19fd                	addi	s3,s3,-1
    80001438:	95ce                	add	a1,a1,s3
    8000143a:	79fd                	lui	s3,0xfffff
    8000143c:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001440:	08c9f363          	bgeu	s3,a2,800014c6 <uvmalloc+0xae>
    80001444:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001446:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000144a:	fffff097          	auipc	ra,0xfffff
    8000144e:	69c080e7          	jalr	1692(ra) # 80000ae6 <kalloc>
    80001452:	84aa                	mv	s1,a0
    if(mem == 0){
    80001454:	c51d                	beqz	a0,80001482 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001456:	6605                	lui	a2,0x1
    80001458:	4581                	li	a1,0
    8000145a:	00000097          	auipc	ra,0x0
    8000145e:	878080e7          	jalr	-1928(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001462:	875a                	mv	a4,s6
    80001464:	86a6                	mv	a3,s1
    80001466:	6605                	lui	a2,0x1
    80001468:	85ca                	mv	a1,s2
    8000146a:	8556                	mv	a0,s5
    8000146c:	00000097          	auipc	ra,0x0
    80001470:	c3a080e7          	jalr	-966(ra) # 800010a6 <mappages>
    80001474:	e90d                	bnez	a0,800014a6 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001476:	6785                	lui	a5,0x1
    80001478:	993e                	add	s2,s2,a5
    8000147a:	fd4968e3          	bltu	s2,s4,8000144a <uvmalloc+0x32>
  return newsz;
    8000147e:	8552                	mv	a0,s4
    80001480:	a809                	j	80001492 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001482:	864e                	mv	a2,s3
    80001484:	85ca                	mv	a1,s2
    80001486:	8556                	mv	a0,s5
    80001488:	00000097          	auipc	ra,0x0
    8000148c:	f48080e7          	jalr	-184(ra) # 800013d0 <uvmdealloc>
      return 0;
    80001490:	4501                	li	a0,0
}
    80001492:	70e2                	ld	ra,56(sp)
    80001494:	7442                	ld	s0,48(sp)
    80001496:	74a2                	ld	s1,40(sp)
    80001498:	7902                	ld	s2,32(sp)
    8000149a:	69e2                	ld	s3,24(sp)
    8000149c:	6a42                	ld	s4,16(sp)
    8000149e:	6aa2                	ld	s5,8(sp)
    800014a0:	6b02                	ld	s6,0(sp)
    800014a2:	6121                	addi	sp,sp,64
    800014a4:	8082                	ret
      kfree(mem);
    800014a6:	8526                	mv	a0,s1
    800014a8:	fffff097          	auipc	ra,0xfffff
    800014ac:	542080e7          	jalr	1346(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014b0:	864e                	mv	a2,s3
    800014b2:	85ca                	mv	a1,s2
    800014b4:	8556                	mv	a0,s5
    800014b6:	00000097          	auipc	ra,0x0
    800014ba:	f1a080e7          	jalr	-230(ra) # 800013d0 <uvmdealloc>
      return 0;
    800014be:	4501                	li	a0,0
    800014c0:	bfc9                	j	80001492 <uvmalloc+0x7a>
    return oldsz;
    800014c2:	852e                	mv	a0,a1
}
    800014c4:	8082                	ret
  return newsz;
    800014c6:	8532                	mv	a0,a2
    800014c8:	b7e9                	j	80001492 <uvmalloc+0x7a>

00000000800014ca <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014ca:	7179                	addi	sp,sp,-48
    800014cc:	f406                	sd	ra,40(sp)
    800014ce:	f022                	sd	s0,32(sp)
    800014d0:	ec26                	sd	s1,24(sp)
    800014d2:	e84a                	sd	s2,16(sp)
    800014d4:	e44e                	sd	s3,8(sp)
    800014d6:	e052                	sd	s4,0(sp)
    800014d8:	1800                	addi	s0,sp,48
    800014da:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014dc:	84aa                	mv	s1,a0
    800014de:	6905                	lui	s2,0x1
    800014e0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e2:	4985                	li	s3,1
    800014e4:	a821                	j	800014fc <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014e6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e8:	0532                	slli	a0,a0,0xc
    800014ea:	00000097          	auipc	ra,0x0
    800014ee:	fe0080e7          	jalr	-32(ra) # 800014ca <freewalk>
      pagetable[i] = 0;
    800014f2:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f6:	04a1                	addi	s1,s1,8
    800014f8:	03248163          	beq	s1,s2,8000151a <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014fc:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014fe:	00f57793          	andi	a5,a0,15
    80001502:	ff3782e3          	beq	a5,s3,800014e6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001506:	8905                	andi	a0,a0,1
    80001508:	d57d                	beqz	a0,800014f6 <freewalk+0x2c>
      panic("freewalk: leaf");
    8000150a:	00007517          	auipc	a0,0x7
    8000150e:	c6e50513          	addi	a0,a0,-914 # 80008178 <digits+0x138>
    80001512:	fffff097          	auipc	ra,0xfffff
    80001516:	02c080e7          	jalr	44(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    8000151a:	8552                	mv	a0,s4
    8000151c:	fffff097          	auipc	ra,0xfffff
    80001520:	4ce080e7          	jalr	1230(ra) # 800009ea <kfree>
}
    80001524:	70a2                	ld	ra,40(sp)
    80001526:	7402                	ld	s0,32(sp)
    80001528:	64e2                	ld	s1,24(sp)
    8000152a:	6942                	ld	s2,16(sp)
    8000152c:	69a2                	ld	s3,8(sp)
    8000152e:	6a02                	ld	s4,0(sp)
    80001530:	6145                	addi	sp,sp,48
    80001532:	8082                	ret

0000000080001534 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001534:	1101                	addi	sp,sp,-32
    80001536:	ec06                	sd	ra,24(sp)
    80001538:	e822                	sd	s0,16(sp)
    8000153a:	e426                	sd	s1,8(sp)
    8000153c:	1000                	addi	s0,sp,32
    8000153e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001540:	e999                	bnez	a1,80001556 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001542:	8526                	mv	a0,s1
    80001544:	00000097          	auipc	ra,0x0
    80001548:	f86080e7          	jalr	-122(ra) # 800014ca <freewalk>
}
    8000154c:	60e2                	ld	ra,24(sp)
    8000154e:	6442                	ld	s0,16(sp)
    80001550:	64a2                	ld	s1,8(sp)
    80001552:	6105                	addi	sp,sp,32
    80001554:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001556:	6605                	lui	a2,0x1
    80001558:	167d                	addi	a2,a2,-1
    8000155a:	962e                	add	a2,a2,a1
    8000155c:	4685                	li	a3,1
    8000155e:	8231                	srli	a2,a2,0xc
    80001560:	4581                	li	a1,0
    80001562:	00000097          	auipc	ra,0x0
    80001566:	d0a080e7          	jalr	-758(ra) # 8000126c <uvmunmap>
    8000156a:	bfe1                	j	80001542 <uvmfree+0xe>

000000008000156c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000156c:	c679                	beqz	a2,8000163a <uvmcopy+0xce>
{
    8000156e:	715d                	addi	sp,sp,-80
    80001570:	e486                	sd	ra,72(sp)
    80001572:	e0a2                	sd	s0,64(sp)
    80001574:	fc26                	sd	s1,56(sp)
    80001576:	f84a                	sd	s2,48(sp)
    80001578:	f44e                	sd	s3,40(sp)
    8000157a:	f052                	sd	s4,32(sp)
    8000157c:	ec56                	sd	s5,24(sp)
    8000157e:	e85a                	sd	s6,16(sp)
    80001580:	e45e                	sd	s7,8(sp)
    80001582:	0880                	addi	s0,sp,80
    80001584:	8b2a                	mv	s6,a0
    80001586:	8aae                	mv	s5,a1
    80001588:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000158a:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000158c:	4601                	li	a2,0
    8000158e:	85ce                	mv	a1,s3
    80001590:	855a                	mv	a0,s6
    80001592:	00000097          	auipc	ra,0x0
    80001596:	a2c080e7          	jalr	-1492(ra) # 80000fbe <walk>
    8000159a:	c531                	beqz	a0,800015e6 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000159c:	6118                	ld	a4,0(a0)
    8000159e:	00177793          	andi	a5,a4,1
    800015a2:	cbb1                	beqz	a5,800015f6 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a4:	00a75593          	srli	a1,a4,0xa
    800015a8:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015ac:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b0:	fffff097          	auipc	ra,0xfffff
    800015b4:	536080e7          	jalr	1334(ra) # 80000ae6 <kalloc>
    800015b8:	892a                	mv	s2,a0
    800015ba:	c939                	beqz	a0,80001610 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015bc:	6605                	lui	a2,0x1
    800015be:	85de                	mv	a1,s7
    800015c0:	fffff097          	auipc	ra,0xfffff
    800015c4:	76e080e7          	jalr	1902(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c8:	8726                	mv	a4,s1
    800015ca:	86ca                	mv	a3,s2
    800015cc:	6605                	lui	a2,0x1
    800015ce:	85ce                	mv	a1,s3
    800015d0:	8556                	mv	a0,s5
    800015d2:	00000097          	auipc	ra,0x0
    800015d6:	ad4080e7          	jalr	-1324(ra) # 800010a6 <mappages>
    800015da:	e515                	bnez	a0,80001606 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015dc:	6785                	lui	a5,0x1
    800015de:	99be                	add	s3,s3,a5
    800015e0:	fb49e6e3          	bltu	s3,s4,8000158c <uvmcopy+0x20>
    800015e4:	a081                	j	80001624 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e6:	00007517          	auipc	a0,0x7
    800015ea:	ba250513          	addi	a0,a0,-1118 # 80008188 <digits+0x148>
    800015ee:	fffff097          	auipc	ra,0xfffff
    800015f2:	f50080e7          	jalr	-176(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015f6:	00007517          	auipc	a0,0x7
    800015fa:	bb250513          	addi	a0,a0,-1102 # 800081a8 <digits+0x168>
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	f40080e7          	jalr	-192(ra) # 8000053e <panic>
      kfree(mem);
    80001606:	854a                	mv	a0,s2
    80001608:	fffff097          	auipc	ra,0xfffff
    8000160c:	3e2080e7          	jalr	994(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001610:	4685                	li	a3,1
    80001612:	00c9d613          	srli	a2,s3,0xc
    80001616:	4581                	li	a1,0
    80001618:	8556                	mv	a0,s5
    8000161a:	00000097          	auipc	ra,0x0
    8000161e:	c52080e7          	jalr	-942(ra) # 8000126c <uvmunmap>
  return -1;
    80001622:	557d                	li	a0,-1
}
    80001624:	60a6                	ld	ra,72(sp)
    80001626:	6406                	ld	s0,64(sp)
    80001628:	74e2                	ld	s1,56(sp)
    8000162a:	7942                	ld	s2,48(sp)
    8000162c:	79a2                	ld	s3,40(sp)
    8000162e:	7a02                	ld	s4,32(sp)
    80001630:	6ae2                	ld	s5,24(sp)
    80001632:	6b42                	ld	s6,16(sp)
    80001634:	6ba2                	ld	s7,8(sp)
    80001636:	6161                	addi	sp,sp,80
    80001638:	8082                	ret
  return 0;
    8000163a:	4501                	li	a0,0
}
    8000163c:	8082                	ret

000000008000163e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163e:	1141                	addi	sp,sp,-16
    80001640:	e406                	sd	ra,8(sp)
    80001642:	e022                	sd	s0,0(sp)
    80001644:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001646:	4601                	li	a2,0
    80001648:	00000097          	auipc	ra,0x0
    8000164c:	976080e7          	jalr	-1674(ra) # 80000fbe <walk>
  if(pte == 0)
    80001650:	c901                	beqz	a0,80001660 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001652:	611c                	ld	a5,0(a0)
    80001654:	9bbd                	andi	a5,a5,-17
    80001656:	e11c                	sd	a5,0(a0)
}
    80001658:	60a2                	ld	ra,8(sp)
    8000165a:	6402                	ld	s0,0(sp)
    8000165c:	0141                	addi	sp,sp,16
    8000165e:	8082                	ret
    panic("uvmclear");
    80001660:	00007517          	auipc	a0,0x7
    80001664:	b6850513          	addi	a0,a0,-1176 # 800081c8 <digits+0x188>
    80001668:	fffff097          	auipc	ra,0xfffff
    8000166c:	ed6080e7          	jalr	-298(ra) # 8000053e <panic>

0000000080001670 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001670:	c6bd                	beqz	a3,800016de <copyout+0x6e>
{
    80001672:	715d                	addi	sp,sp,-80
    80001674:	e486                	sd	ra,72(sp)
    80001676:	e0a2                	sd	s0,64(sp)
    80001678:	fc26                	sd	s1,56(sp)
    8000167a:	f84a                	sd	s2,48(sp)
    8000167c:	f44e                	sd	s3,40(sp)
    8000167e:	f052                	sd	s4,32(sp)
    80001680:	ec56                	sd	s5,24(sp)
    80001682:	e85a                	sd	s6,16(sp)
    80001684:	e45e                	sd	s7,8(sp)
    80001686:	e062                	sd	s8,0(sp)
    80001688:	0880                	addi	s0,sp,80
    8000168a:	8b2a                	mv	s6,a0
    8000168c:	8c2e                	mv	s8,a1
    8000168e:	8a32                	mv	s4,a2
    80001690:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001692:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001694:	6a85                	lui	s5,0x1
    80001696:	a015                	j	800016ba <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001698:	9562                	add	a0,a0,s8
    8000169a:	0004861b          	sext.w	a2,s1
    8000169e:	85d2                	mv	a1,s4
    800016a0:	41250533          	sub	a0,a0,s2
    800016a4:	fffff097          	auipc	ra,0xfffff
    800016a8:	68a080e7          	jalr	1674(ra) # 80000d2e <memmove>

    len -= n;
    800016ac:	409989b3          	sub	s3,s3,s1
    src += n;
    800016b0:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016b2:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b6:	02098263          	beqz	s3,800016da <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ba:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016be:	85ca                	mv	a1,s2
    800016c0:	855a                	mv	a0,s6
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	9a2080e7          	jalr	-1630(ra) # 80001064 <walkaddr>
    if(pa0 == 0)
    800016ca:	cd01                	beqz	a0,800016e2 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016cc:	418904b3          	sub	s1,s2,s8
    800016d0:	94d6                	add	s1,s1,s5
    if(n > len)
    800016d2:	fc99f3e3          	bgeu	s3,s1,80001698 <copyout+0x28>
    800016d6:	84ce                	mv	s1,s3
    800016d8:	b7c1                	j	80001698 <copyout+0x28>
  }
  return 0;
    800016da:	4501                	li	a0,0
    800016dc:	a021                	j	800016e4 <copyout+0x74>
    800016de:	4501                	li	a0,0
}
    800016e0:	8082                	ret
      return -1;
    800016e2:	557d                	li	a0,-1
}
    800016e4:	60a6                	ld	ra,72(sp)
    800016e6:	6406                	ld	s0,64(sp)
    800016e8:	74e2                	ld	s1,56(sp)
    800016ea:	7942                	ld	s2,48(sp)
    800016ec:	79a2                	ld	s3,40(sp)
    800016ee:	7a02                	ld	s4,32(sp)
    800016f0:	6ae2                	ld	s5,24(sp)
    800016f2:	6b42                	ld	s6,16(sp)
    800016f4:	6ba2                	ld	s7,8(sp)
    800016f6:	6c02                	ld	s8,0(sp)
    800016f8:	6161                	addi	sp,sp,80
    800016fa:	8082                	ret

00000000800016fc <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016fc:	caa5                	beqz	a3,8000176c <copyin+0x70>
{
    800016fe:	715d                	addi	sp,sp,-80
    80001700:	e486                	sd	ra,72(sp)
    80001702:	e0a2                	sd	s0,64(sp)
    80001704:	fc26                	sd	s1,56(sp)
    80001706:	f84a                	sd	s2,48(sp)
    80001708:	f44e                	sd	s3,40(sp)
    8000170a:	f052                	sd	s4,32(sp)
    8000170c:	ec56                	sd	s5,24(sp)
    8000170e:	e85a                	sd	s6,16(sp)
    80001710:	e45e                	sd	s7,8(sp)
    80001712:	e062                	sd	s8,0(sp)
    80001714:	0880                	addi	s0,sp,80
    80001716:	8b2a                	mv	s6,a0
    80001718:	8a2e                	mv	s4,a1
    8000171a:	8c32                	mv	s8,a2
    8000171c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001720:	6a85                	lui	s5,0x1
    80001722:	a01d                	j	80001748 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001724:	018505b3          	add	a1,a0,s8
    80001728:	0004861b          	sext.w	a2,s1
    8000172c:	412585b3          	sub	a1,a1,s2
    80001730:	8552                	mv	a0,s4
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	5fc080e7          	jalr	1532(ra) # 80000d2e <memmove>

    len -= n;
    8000173a:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001740:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001744:	02098263          	beqz	s3,80001768 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001748:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000174c:	85ca                	mv	a1,s2
    8000174e:	855a                	mv	a0,s6
    80001750:	00000097          	auipc	ra,0x0
    80001754:	914080e7          	jalr	-1772(ra) # 80001064 <walkaddr>
    if(pa0 == 0)
    80001758:	cd01                	beqz	a0,80001770 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000175a:	418904b3          	sub	s1,s2,s8
    8000175e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001760:	fc99f2e3          	bgeu	s3,s1,80001724 <copyin+0x28>
    80001764:	84ce                	mv	s1,s3
    80001766:	bf7d                	j	80001724 <copyin+0x28>
  }
  return 0;
    80001768:	4501                	li	a0,0
    8000176a:	a021                	j	80001772 <copyin+0x76>
    8000176c:	4501                	li	a0,0
}
    8000176e:	8082                	ret
      return -1;
    80001770:	557d                	li	a0,-1
}
    80001772:	60a6                	ld	ra,72(sp)
    80001774:	6406                	ld	s0,64(sp)
    80001776:	74e2                	ld	s1,56(sp)
    80001778:	7942                	ld	s2,48(sp)
    8000177a:	79a2                	ld	s3,40(sp)
    8000177c:	7a02                	ld	s4,32(sp)
    8000177e:	6ae2                	ld	s5,24(sp)
    80001780:	6b42                	ld	s6,16(sp)
    80001782:	6ba2                	ld	s7,8(sp)
    80001784:	6c02                	ld	s8,0(sp)
    80001786:	6161                	addi	sp,sp,80
    80001788:	8082                	ret

000000008000178a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000178a:	c6c5                	beqz	a3,80001832 <copyinstr+0xa8>
{
    8000178c:	715d                	addi	sp,sp,-80
    8000178e:	e486                	sd	ra,72(sp)
    80001790:	e0a2                	sd	s0,64(sp)
    80001792:	fc26                	sd	s1,56(sp)
    80001794:	f84a                	sd	s2,48(sp)
    80001796:	f44e                	sd	s3,40(sp)
    80001798:	f052                	sd	s4,32(sp)
    8000179a:	ec56                	sd	s5,24(sp)
    8000179c:	e85a                	sd	s6,16(sp)
    8000179e:	e45e                	sd	s7,8(sp)
    800017a0:	0880                	addi	s0,sp,80
    800017a2:	8a2a                	mv	s4,a0
    800017a4:	8b2e                	mv	s6,a1
    800017a6:	8bb2                	mv	s7,a2
    800017a8:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017aa:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ac:	6985                	lui	s3,0x1
    800017ae:	a035                	j	800017da <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b0:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b4:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b6:	0017b793          	seqz	a5,a5
    800017ba:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017be:	60a6                	ld	ra,72(sp)
    800017c0:	6406                	ld	s0,64(sp)
    800017c2:	74e2                	ld	s1,56(sp)
    800017c4:	7942                	ld	s2,48(sp)
    800017c6:	79a2                	ld	s3,40(sp)
    800017c8:	7a02                	ld	s4,32(sp)
    800017ca:	6ae2                	ld	s5,24(sp)
    800017cc:	6b42                	ld	s6,16(sp)
    800017ce:	6ba2                	ld	s7,8(sp)
    800017d0:	6161                	addi	sp,sp,80
    800017d2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017d4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d8:	c8a9                	beqz	s1,8000182a <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017da:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017de:	85ca                	mv	a1,s2
    800017e0:	8552                	mv	a0,s4
    800017e2:	00000097          	auipc	ra,0x0
    800017e6:	882080e7          	jalr	-1918(ra) # 80001064 <walkaddr>
    if(pa0 == 0)
    800017ea:	c131                	beqz	a0,8000182e <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ec:	41790833          	sub	a6,s2,s7
    800017f0:	984e                	add	a6,a6,s3
    if(n > max)
    800017f2:	0104f363          	bgeu	s1,a6,800017f8 <copyinstr+0x6e>
    800017f6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f8:	955e                	add	a0,a0,s7
    800017fa:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017fe:	fc080be3          	beqz	a6,800017d4 <copyinstr+0x4a>
    80001802:	985a                	add	a6,a6,s6
    80001804:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001806:	41650633          	sub	a2,a0,s6
    8000180a:	14fd                	addi	s1,s1,-1
    8000180c:	9b26                	add	s6,s6,s1
    8000180e:	00f60733          	add	a4,a2,a5
    80001812:	00074703          	lbu	a4,0(a4)
    80001816:	df49                	beqz	a4,800017b0 <copyinstr+0x26>
        *dst = *p;
    80001818:	00e78023          	sb	a4,0(a5)
      --max;
    8000181c:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001820:	0785                	addi	a5,a5,1
    while(n > 0){
    80001822:	ff0796e3          	bne	a5,a6,8000180e <copyinstr+0x84>
      dst++;
    80001826:	8b42                	mv	s6,a6
    80001828:	b775                	j	800017d4 <copyinstr+0x4a>
    8000182a:	4781                	li	a5,0
    8000182c:	b769                	j	800017b6 <copyinstr+0x2c>
      return -1;
    8000182e:	557d                	li	a0,-1
    80001830:	b779                	j	800017be <copyinstr+0x34>
  int got_null = 0;
    80001832:	4781                	li	a5,0
  if(got_null){
    80001834:	0017b793          	seqz	a5,a5
    80001838:	40f00533          	neg	a0,a5
}
    8000183c:	8082                	ret

000000008000183e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000183e:	7139                	addi	sp,sp,-64
    80001840:	fc06                	sd	ra,56(sp)
    80001842:	f822                	sd	s0,48(sp)
    80001844:	f426                	sd	s1,40(sp)
    80001846:	f04a                	sd	s2,32(sp)
    80001848:	ec4e                	sd	s3,24(sp)
    8000184a:	e852                	sd	s4,16(sp)
    8000184c:	e456                	sd	s5,8(sp)
    8000184e:	e05a                	sd	s6,0(sp)
    80001850:	0080                	addi	s0,sp,64
    80001852:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001854:	0000f497          	auipc	s1,0xf
    80001858:	74c48493          	addi	s1,s1,1868 # 80010fa0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000185c:	8b26                	mv	s6,s1
    8000185e:	00006a97          	auipc	s5,0x6
    80001862:	7a2a8a93          	addi	s5,s5,1954 # 80008000 <etext>
    80001866:	04000937          	lui	s2,0x4000
    8000186a:	197d                	addi	s2,s2,-1
    8000186c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00015a17          	auipc	s4,0x15
    80001872:	132a0a13          	addi	s4,s4,306 # 800169a0 <tickslock>
    char *pa = kalloc();
    80001876:	fffff097          	auipc	ra,0xfffff
    8000187a:	270080e7          	jalr	624(ra) # 80000ae6 <kalloc>
    8000187e:	862a                	mv	a2,a0
    if(pa == 0)
    80001880:	c131                	beqz	a0,800018c4 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001882:	416485b3          	sub	a1,s1,s6
    80001886:	858d                	srai	a1,a1,0x3
    80001888:	000ab783          	ld	a5,0(s5)
    8000188c:	02f585b3          	mul	a1,a1,a5
    80001890:	2585                	addiw	a1,a1,1
    80001892:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001896:	4719                	li	a4,6
    80001898:	6685                	lui	a3,0x1
    8000189a:	40b905b3          	sub	a1,s2,a1
    8000189e:	854e                	mv	a0,s3
    800018a0:	00000097          	auipc	ra,0x0
    800018a4:	8a6080e7          	jalr	-1882(ra) # 80001146 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a8:	16848493          	addi	s1,s1,360
    800018ac:	fd4495e3          	bne	s1,s4,80001876 <proc_mapstacks+0x38>
  }
}
    800018b0:	70e2                	ld	ra,56(sp)
    800018b2:	7442                	ld	s0,48(sp)
    800018b4:	74a2                	ld	s1,40(sp)
    800018b6:	7902                	ld	s2,32(sp)
    800018b8:	69e2                	ld	s3,24(sp)
    800018ba:	6a42                	ld	s4,16(sp)
    800018bc:	6aa2                	ld	s5,8(sp)
    800018be:	6b02                	ld	s6,0(sp)
    800018c0:	6121                	addi	sp,sp,64
    800018c2:	8082                	ret
      panic("kalloc");
    800018c4:	00007517          	auipc	a0,0x7
    800018c8:	91450513          	addi	a0,a0,-1772 # 800081d8 <digits+0x198>
    800018cc:	fffff097          	auipc	ra,0xfffff
    800018d0:	c72080e7          	jalr	-910(ra) # 8000053e <panic>

00000000800018d4 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018d4:	7139                	addi	sp,sp,-64
    800018d6:	fc06                	sd	ra,56(sp)
    800018d8:	f822                	sd	s0,48(sp)
    800018da:	f426                	sd	s1,40(sp)
    800018dc:	f04a                	sd	s2,32(sp)
    800018de:	ec4e                	sd	s3,24(sp)
    800018e0:	e852                	sd	s4,16(sp)
    800018e2:	e456                	sd	s5,8(sp)
    800018e4:	e05a                	sd	s6,0(sp)
    800018e6:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e8:	00007597          	auipc	a1,0x7
    800018ec:	8f858593          	addi	a1,a1,-1800 # 800081e0 <digits+0x1a0>
    800018f0:	0000f517          	auipc	a0,0xf
    800018f4:	28050513          	addi	a0,a0,640 # 80010b70 <pid_lock>
    800018f8:	fffff097          	auipc	ra,0xfffff
    800018fc:	24e080e7          	jalr	590(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001900:	00007597          	auipc	a1,0x7
    80001904:	8e858593          	addi	a1,a1,-1816 # 800081e8 <digits+0x1a8>
    80001908:	0000f517          	auipc	a0,0xf
    8000190c:	28050513          	addi	a0,a0,640 # 80010b88 <wait_lock>
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	236080e7          	jalr	566(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001918:	0000f497          	auipc	s1,0xf
    8000191c:	68848493          	addi	s1,s1,1672 # 80010fa0 <proc>
      initlock(&p->lock, "proc");
    80001920:	00007b17          	auipc	s6,0x7
    80001924:	8d8b0b13          	addi	s6,s6,-1832 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001928:	8aa6                	mv	s5,s1
    8000192a:	00006a17          	auipc	s4,0x6
    8000192e:	6d6a0a13          	addi	s4,s4,1750 # 80008000 <etext>
    80001932:	04000937          	lui	s2,0x4000
    80001936:	197d                	addi	s2,s2,-1
    80001938:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000193a:	00015997          	auipc	s3,0x15
    8000193e:	06698993          	addi	s3,s3,102 # 800169a0 <tickslock>
      initlock(&p->lock, "proc");
    80001942:	85da                	mv	a1,s6
    80001944:	8526                	mv	a0,s1
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	200080e7          	jalr	512(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    8000194e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001952:	415487b3          	sub	a5,s1,s5
    80001956:	878d                	srai	a5,a5,0x3
    80001958:	000a3703          	ld	a4,0(s4)
    8000195c:	02e787b3          	mul	a5,a5,a4
    80001960:	2785                	addiw	a5,a5,1
    80001962:	00d7979b          	slliw	a5,a5,0xd
    80001966:	40f907b3          	sub	a5,s2,a5
    8000196a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000196c:	16848493          	addi	s1,s1,360
    80001970:	fd3499e3          	bne	s1,s3,80001942 <procinit+0x6e>
  }
}
    80001974:	70e2                	ld	ra,56(sp)
    80001976:	7442                	ld	s0,48(sp)
    80001978:	74a2                	ld	s1,40(sp)
    8000197a:	7902                	ld	s2,32(sp)
    8000197c:	69e2                	ld	s3,24(sp)
    8000197e:	6a42                	ld	s4,16(sp)
    80001980:	6aa2                	ld	s5,8(sp)
    80001982:	6b02                	ld	s6,0(sp)
    80001984:	6121                	addi	sp,sp,64
    80001986:	8082                	ret

0000000080001988 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001988:	1141                	addi	sp,sp,-16
    8000198a:	e422                	sd	s0,8(sp)
    8000198c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000198e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001990:	2501                	sext.w	a0,a0
    80001992:	6422                	ld	s0,8(sp)
    80001994:	0141                	addi	sp,sp,16
    80001996:	8082                	ret

0000000080001998 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001998:	1141                	addi	sp,sp,-16
    8000199a:	e422                	sd	s0,8(sp)
    8000199c:	0800                	addi	s0,sp,16
    8000199e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019a0:	2781                	sext.w	a5,a5
    800019a2:	079e                	slli	a5,a5,0x7
  return c;
}
    800019a4:	0000f517          	auipc	a0,0xf
    800019a8:	1fc50513          	addi	a0,a0,508 # 80010ba0 <cpus>
    800019ac:	953e                	add	a0,a0,a5
    800019ae:	6422                	ld	s0,8(sp)
    800019b0:	0141                	addi	sp,sp,16
    800019b2:	8082                	ret

00000000800019b4 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019b4:	1101                	addi	sp,sp,-32
    800019b6:	ec06                	sd	ra,24(sp)
    800019b8:	e822                	sd	s0,16(sp)
    800019ba:	e426                	sd	s1,8(sp)
    800019bc:	1000                	addi	s0,sp,32
  push_off();
    800019be:	fffff097          	auipc	ra,0xfffff
    800019c2:	1cc080e7          	jalr	460(ra) # 80000b8a <push_off>
    800019c6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c8:	2781                	sext.w	a5,a5
    800019ca:	079e                	slli	a5,a5,0x7
    800019cc:	0000f717          	auipc	a4,0xf
    800019d0:	1a470713          	addi	a4,a4,420 # 80010b70 <pid_lock>
    800019d4:	97ba                	add	a5,a5,a4
    800019d6:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d8:	fffff097          	auipc	ra,0xfffff
    800019dc:	252080e7          	jalr	594(ra) # 80000c2a <pop_off>
  return p;
}
    800019e0:	8526                	mv	a0,s1
    800019e2:	60e2                	ld	ra,24(sp)
    800019e4:	6442                	ld	s0,16(sp)
    800019e6:	64a2                	ld	s1,8(sp)
    800019e8:	6105                	addi	sp,sp,32
    800019ea:	8082                	ret

00000000800019ec <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019ec:	1141                	addi	sp,sp,-16
    800019ee:	e406                	sd	ra,8(sp)
    800019f0:	e022                	sd	s0,0(sp)
    800019f2:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019f4:	00000097          	auipc	ra,0x0
    800019f8:	fc0080e7          	jalr	-64(ra) # 800019b4 <myproc>
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	28e080e7          	jalr	654(ra) # 80000c8a <release>

  if (first) {
    80001a04:	00007797          	auipc	a5,0x7
    80001a08:	e5c7a783          	lw	a5,-420(a5) # 80008860 <first.1>
    80001a0c:	eb89                	bnez	a5,80001a1e <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a0e:	00001097          	auipc	ra,0x1
    80001a12:	c5a080e7          	jalr	-934(ra) # 80002668 <usertrapret>
}
    80001a16:	60a2                	ld	ra,8(sp)
    80001a18:	6402                	ld	s0,0(sp)
    80001a1a:	0141                	addi	sp,sp,16
    80001a1c:	8082                	ret
    first = 0;
    80001a1e:	00007797          	auipc	a5,0x7
    80001a22:	e407a123          	sw	zero,-446(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001a26:	4505                	li	a0,1
    80001a28:	00002097          	auipc	ra,0x2
    80001a2c:	990080e7          	jalr	-1648(ra) # 800033b8 <fsinit>
    80001a30:	bff9                	j	80001a0e <forkret+0x22>

0000000080001a32 <allocpid>:
{
    80001a32:	1101                	addi	sp,sp,-32
    80001a34:	ec06                	sd	ra,24(sp)
    80001a36:	e822                	sd	s0,16(sp)
    80001a38:	e426                	sd	s1,8(sp)
    80001a3a:	e04a                	sd	s2,0(sp)
    80001a3c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a3e:	0000f917          	auipc	s2,0xf
    80001a42:	13290913          	addi	s2,s2,306 # 80010b70 <pid_lock>
    80001a46:	854a                	mv	a0,s2
    80001a48:	fffff097          	auipc	ra,0xfffff
    80001a4c:	18e080e7          	jalr	398(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a50:	00007797          	auipc	a5,0x7
    80001a54:	e1478793          	addi	a5,a5,-492 # 80008864 <nextpid>
    80001a58:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a5a:	0014871b          	addiw	a4,s1,1
    80001a5e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a60:	854a                	mv	a0,s2
    80001a62:	fffff097          	auipc	ra,0xfffff
    80001a66:	228080e7          	jalr	552(ra) # 80000c8a <release>
}
    80001a6a:	8526                	mv	a0,s1
    80001a6c:	60e2                	ld	ra,24(sp)
    80001a6e:	6442                	ld	s0,16(sp)
    80001a70:	64a2                	ld	s1,8(sp)
    80001a72:	6902                	ld	s2,0(sp)
    80001a74:	6105                	addi	sp,sp,32
    80001a76:	8082                	ret

0000000080001a78 <proc_pagetable>:
{
    80001a78:	1101                	addi	sp,sp,-32
    80001a7a:	ec06                	sd	ra,24(sp)
    80001a7c:	e822                	sd	s0,16(sp)
    80001a7e:	e426                	sd	s1,8(sp)
    80001a80:	e04a                	sd	s2,0(sp)
    80001a82:	1000                	addi	s0,sp,32
    80001a84:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a86:	00000097          	auipc	ra,0x0
    80001a8a:	8aa080e7          	jalr	-1878(ra) # 80001330 <uvmcreate>
    80001a8e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a90:	c121                	beqz	a0,80001ad0 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a92:	4729                	li	a4,10
    80001a94:	00005697          	auipc	a3,0x5
    80001a98:	56c68693          	addi	a3,a3,1388 # 80007000 <_trampoline>
    80001a9c:	6605                	lui	a2,0x1
    80001a9e:	040005b7          	lui	a1,0x4000
    80001aa2:	15fd                	addi	a1,a1,-1
    80001aa4:	05b2                	slli	a1,a1,0xc
    80001aa6:	fffff097          	auipc	ra,0xfffff
    80001aaa:	600080e7          	jalr	1536(ra) # 800010a6 <mappages>
    80001aae:	02054863          	bltz	a0,80001ade <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ab2:	4719                	li	a4,6
    80001ab4:	05893683          	ld	a3,88(s2)
    80001ab8:	6605                	lui	a2,0x1
    80001aba:	020005b7          	lui	a1,0x2000
    80001abe:	15fd                	addi	a1,a1,-1
    80001ac0:	05b6                	slli	a1,a1,0xd
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	5e2080e7          	jalr	1506(ra) # 800010a6 <mappages>
    80001acc:	02054163          	bltz	a0,80001aee <proc_pagetable+0x76>
}
    80001ad0:	8526                	mv	a0,s1
    80001ad2:	60e2                	ld	ra,24(sp)
    80001ad4:	6442                	ld	s0,16(sp)
    80001ad6:	64a2                	ld	s1,8(sp)
    80001ad8:	6902                	ld	s2,0(sp)
    80001ada:	6105                	addi	sp,sp,32
    80001adc:	8082                	ret
    uvmfree(pagetable, 0);
    80001ade:	4581                	li	a1,0
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	00000097          	auipc	ra,0x0
    80001ae6:	a52080e7          	jalr	-1454(ra) # 80001534 <uvmfree>
    return 0;
    80001aea:	4481                	li	s1,0
    80001aec:	b7d5                	j	80001ad0 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aee:	4681                	li	a3,0
    80001af0:	4605                	li	a2,1
    80001af2:	040005b7          	lui	a1,0x4000
    80001af6:	15fd                	addi	a1,a1,-1
    80001af8:	05b2                	slli	a1,a1,0xc
    80001afa:	8526                	mv	a0,s1
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	770080e7          	jalr	1904(ra) # 8000126c <uvmunmap>
    uvmfree(pagetable, 0);
    80001b04:	4581                	li	a1,0
    80001b06:	8526                	mv	a0,s1
    80001b08:	00000097          	auipc	ra,0x0
    80001b0c:	a2c080e7          	jalr	-1492(ra) # 80001534 <uvmfree>
    return 0;
    80001b10:	4481                	li	s1,0
    80001b12:	bf7d                	j	80001ad0 <proc_pagetable+0x58>

0000000080001b14 <proc_freepagetable>:
{
    80001b14:	1101                	addi	sp,sp,-32
    80001b16:	ec06                	sd	ra,24(sp)
    80001b18:	e822                	sd	s0,16(sp)
    80001b1a:	e426                	sd	s1,8(sp)
    80001b1c:	e04a                	sd	s2,0(sp)
    80001b1e:	1000                	addi	s0,sp,32
    80001b20:	84aa                	mv	s1,a0
    80001b22:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b24:	4681                	li	a3,0
    80001b26:	4605                	li	a2,1
    80001b28:	040005b7          	lui	a1,0x4000
    80001b2c:	15fd                	addi	a1,a1,-1
    80001b2e:	05b2                	slli	a1,a1,0xc
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	73c080e7          	jalr	1852(ra) # 8000126c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b38:	4681                	li	a3,0
    80001b3a:	4605                	li	a2,1
    80001b3c:	020005b7          	lui	a1,0x2000
    80001b40:	15fd                	addi	a1,a1,-1
    80001b42:	05b6                	slli	a1,a1,0xd
    80001b44:	8526                	mv	a0,s1
    80001b46:	fffff097          	auipc	ra,0xfffff
    80001b4a:	726080e7          	jalr	1830(ra) # 8000126c <uvmunmap>
  uvmfree(pagetable, sz);
    80001b4e:	85ca                	mv	a1,s2
    80001b50:	8526                	mv	a0,s1
    80001b52:	00000097          	auipc	ra,0x0
    80001b56:	9e2080e7          	jalr	-1566(ra) # 80001534 <uvmfree>
}
    80001b5a:	60e2                	ld	ra,24(sp)
    80001b5c:	6442                	ld	s0,16(sp)
    80001b5e:	64a2                	ld	s1,8(sp)
    80001b60:	6902                	ld	s2,0(sp)
    80001b62:	6105                	addi	sp,sp,32
    80001b64:	8082                	ret

0000000080001b66 <freeproc>:
{
    80001b66:	1101                	addi	sp,sp,-32
    80001b68:	ec06                	sd	ra,24(sp)
    80001b6a:	e822                	sd	s0,16(sp)
    80001b6c:	e426                	sd	s1,8(sp)
    80001b6e:	1000                	addi	s0,sp,32
    80001b70:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b72:	6d28                	ld	a0,88(a0)
    80001b74:	c509                	beqz	a0,80001b7e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b76:	fffff097          	auipc	ra,0xfffff
    80001b7a:	e74080e7          	jalr	-396(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b7e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b82:	68a8                	ld	a0,80(s1)
    80001b84:	c511                	beqz	a0,80001b90 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b86:	64ac                	ld	a1,72(s1)
    80001b88:	00000097          	auipc	ra,0x0
    80001b8c:	f8c080e7          	jalr	-116(ra) # 80001b14 <proc_freepagetable>
  p->pagetable = 0;
    80001b90:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b94:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b98:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b9c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ba0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ba4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bac:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bb0:	0004ac23          	sw	zero,24(s1)
}
    80001bb4:	60e2                	ld	ra,24(sp)
    80001bb6:	6442                	ld	s0,16(sp)
    80001bb8:	64a2                	ld	s1,8(sp)
    80001bba:	6105                	addi	sp,sp,32
    80001bbc:	8082                	ret

0000000080001bbe <allocproc>:
{
    80001bbe:	1101                	addi	sp,sp,-32
    80001bc0:	ec06                	sd	ra,24(sp)
    80001bc2:	e822                	sd	s0,16(sp)
    80001bc4:	e426                	sd	s1,8(sp)
    80001bc6:	e04a                	sd	s2,0(sp)
    80001bc8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bca:	0000f497          	auipc	s1,0xf
    80001bce:	3d648493          	addi	s1,s1,982 # 80010fa0 <proc>
    80001bd2:	00015917          	auipc	s2,0x15
    80001bd6:	dce90913          	addi	s2,s2,-562 # 800169a0 <tickslock>
    acquire(&p->lock);
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	ffa080e7          	jalr	-6(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001be4:	4c9c                	lw	a5,24(s1)
    80001be6:	cf81                	beqz	a5,80001bfe <allocproc+0x40>
      release(&p->lock);
    80001be8:	8526                	mv	a0,s1
    80001bea:	fffff097          	auipc	ra,0xfffff
    80001bee:	0a0080e7          	jalr	160(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf2:	16848493          	addi	s1,s1,360
    80001bf6:	ff2492e3          	bne	s1,s2,80001bda <allocproc+0x1c>
  return 0;
    80001bfa:	4481                	li	s1,0
    80001bfc:	a889                	j	80001c4e <allocproc+0x90>
  p->pid = allocpid();
    80001bfe:	00000097          	auipc	ra,0x0
    80001c02:	e34080e7          	jalr	-460(ra) # 80001a32 <allocpid>
    80001c06:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c08:	4785                	li	a5,1
    80001c0a:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	eda080e7          	jalr	-294(ra) # 80000ae6 <kalloc>
    80001c14:	892a                	mv	s2,a0
    80001c16:	eca8                	sd	a0,88(s1)
    80001c18:	c131                	beqz	a0,80001c5c <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	00000097          	auipc	ra,0x0
    80001c20:	e5c080e7          	jalr	-420(ra) # 80001a78 <proc_pagetable>
    80001c24:	892a                	mv	s2,a0
    80001c26:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c28:	c531                	beqz	a0,80001c74 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c2a:	07000613          	li	a2,112
    80001c2e:	4581                	li	a1,0
    80001c30:	06048513          	addi	a0,s1,96
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	09e080e7          	jalr	158(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c3c:	00000797          	auipc	a5,0x0
    80001c40:	db078793          	addi	a5,a5,-592 # 800019ec <forkret>
    80001c44:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c46:	60bc                	ld	a5,64(s1)
    80001c48:	6705                	lui	a4,0x1
    80001c4a:	97ba                	add	a5,a5,a4
    80001c4c:	f4bc                	sd	a5,104(s1)
}
    80001c4e:	8526                	mv	a0,s1
    80001c50:	60e2                	ld	ra,24(sp)
    80001c52:	6442                	ld	s0,16(sp)
    80001c54:	64a2                	ld	s1,8(sp)
    80001c56:	6902                	ld	s2,0(sp)
    80001c58:	6105                	addi	sp,sp,32
    80001c5a:	8082                	ret
    freeproc(p);
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	00000097          	auipc	ra,0x0
    80001c62:	f08080e7          	jalr	-248(ra) # 80001b66 <freeproc>
    release(&p->lock);
    80001c66:	8526                	mv	a0,s1
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	022080e7          	jalr	34(ra) # 80000c8a <release>
    return 0;
    80001c70:	84ca                	mv	s1,s2
    80001c72:	bff1                	j	80001c4e <allocproc+0x90>
    freeproc(p);
    80001c74:	8526                	mv	a0,s1
    80001c76:	00000097          	auipc	ra,0x0
    80001c7a:	ef0080e7          	jalr	-272(ra) # 80001b66 <freeproc>
    release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	00a080e7          	jalr	10(ra) # 80000c8a <release>
    return 0;
    80001c88:	84ca                	mv	s1,s2
    80001c8a:	b7d1                	j	80001c4e <allocproc+0x90>

0000000080001c8c <userinit>:
{
    80001c8c:	1101                	addi	sp,sp,-32
    80001c8e:	ec06                	sd	ra,24(sp)
    80001c90:	e822                	sd	s0,16(sp)
    80001c92:	e426                	sd	s1,8(sp)
    80001c94:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c96:	00000097          	auipc	ra,0x0
    80001c9a:	f28080e7          	jalr	-216(ra) # 80001bbe <allocproc>
    80001c9e:	84aa                	mv	s1,a0
  initproc = p;
    80001ca0:	00007797          	auipc	a5,0x7
    80001ca4:	c4a7bc23          	sd	a0,-936(a5) # 800088f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ca8:	03400613          	li	a2,52
    80001cac:	00007597          	auipc	a1,0x7
    80001cb0:	bc458593          	addi	a1,a1,-1084 # 80008870 <initcode>
    80001cb4:	6928                	ld	a0,80(a0)
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	6a8080e7          	jalr	1704(ra) # 8000135e <uvmfirst>
  p->sz = PGSIZE;
    80001cbe:	6785                	lui	a5,0x1
    80001cc0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cc2:	6cb8                	ld	a4,88(s1)
    80001cc4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cc8:	6cb8                	ld	a4,88(s1)
    80001cca:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ccc:	4641                	li	a2,16
    80001cce:	00006597          	auipc	a1,0x6
    80001cd2:	53258593          	addi	a1,a1,1330 # 80008200 <digits+0x1c0>
    80001cd6:	15848513          	addi	a0,s1,344
    80001cda:	fffff097          	auipc	ra,0xfffff
    80001cde:	142080e7          	jalr	322(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001ce2:	00006517          	auipc	a0,0x6
    80001ce6:	52e50513          	addi	a0,a0,1326 # 80008210 <digits+0x1d0>
    80001cea:	00002097          	auipc	ra,0x2
    80001cee:	0f0080e7          	jalr	240(ra) # 80003dda <namei>
    80001cf2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cf6:	478d                	li	a5,3
    80001cf8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	f8e080e7          	jalr	-114(ra) # 80000c8a <release>
}
    80001d04:	60e2                	ld	ra,24(sp)
    80001d06:	6442                	ld	s0,16(sp)
    80001d08:	64a2                	ld	s1,8(sp)
    80001d0a:	6105                	addi	sp,sp,32
    80001d0c:	8082                	ret

0000000080001d0e <growproc>:
{
    80001d0e:	1101                	addi	sp,sp,-32
    80001d10:	ec06                	sd	ra,24(sp)
    80001d12:	e822                	sd	s0,16(sp)
    80001d14:	e426                	sd	s1,8(sp)
    80001d16:	e04a                	sd	s2,0(sp)
    80001d18:	1000                	addi	s0,sp,32
    80001d1a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d1c:	00000097          	auipc	ra,0x0
    80001d20:	c98080e7          	jalr	-872(ra) # 800019b4 <myproc>
    80001d24:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d26:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d28:	01204c63          	bgtz	s2,80001d40 <growproc+0x32>
  } else if(n < 0){
    80001d2c:	02094663          	bltz	s2,80001d58 <growproc+0x4a>
  p->sz = sz;
    80001d30:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d32:	4501                	li	a0,0
}
    80001d34:	60e2                	ld	ra,24(sp)
    80001d36:	6442                	ld	s0,16(sp)
    80001d38:	64a2                	ld	s1,8(sp)
    80001d3a:	6902                	ld	s2,0(sp)
    80001d3c:	6105                	addi	sp,sp,32
    80001d3e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d40:	4691                	li	a3,4
    80001d42:	00b90633          	add	a2,s2,a1
    80001d46:	6928                	ld	a0,80(a0)
    80001d48:	fffff097          	auipc	ra,0xfffff
    80001d4c:	6d0080e7          	jalr	1744(ra) # 80001418 <uvmalloc>
    80001d50:	85aa                	mv	a1,a0
    80001d52:	fd79                	bnez	a0,80001d30 <growproc+0x22>
      return -1;
    80001d54:	557d                	li	a0,-1
    80001d56:	bff9                	j	80001d34 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d58:	00b90633          	add	a2,s2,a1
    80001d5c:	6928                	ld	a0,80(a0)
    80001d5e:	fffff097          	auipc	ra,0xfffff
    80001d62:	672080e7          	jalr	1650(ra) # 800013d0 <uvmdealloc>
    80001d66:	85aa                	mv	a1,a0
    80001d68:	b7e1                	j	80001d30 <growproc+0x22>

0000000080001d6a <fork>:
{
    80001d6a:	7139                	addi	sp,sp,-64
    80001d6c:	fc06                	sd	ra,56(sp)
    80001d6e:	f822                	sd	s0,48(sp)
    80001d70:	f426                	sd	s1,40(sp)
    80001d72:	f04a                	sd	s2,32(sp)
    80001d74:	ec4e                	sd	s3,24(sp)
    80001d76:	e852                	sd	s4,16(sp)
    80001d78:	e456                	sd	s5,8(sp)
    80001d7a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d7c:	00000097          	auipc	ra,0x0
    80001d80:	c38080e7          	jalr	-968(ra) # 800019b4 <myproc>
    80001d84:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d86:	00000097          	auipc	ra,0x0
    80001d8a:	e38080e7          	jalr	-456(ra) # 80001bbe <allocproc>
    80001d8e:	10050c63          	beqz	a0,80001ea6 <fork+0x13c>
    80001d92:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d94:	048ab603          	ld	a2,72(s5)
    80001d98:	692c                	ld	a1,80(a0)
    80001d9a:	050ab503          	ld	a0,80(s5)
    80001d9e:	fffff097          	auipc	ra,0xfffff
    80001da2:	7ce080e7          	jalr	1998(ra) # 8000156c <uvmcopy>
    80001da6:	04054863          	bltz	a0,80001df6 <fork+0x8c>
  np->sz = p->sz;
    80001daa:	048ab783          	ld	a5,72(s5)
    80001dae:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001db2:	058ab683          	ld	a3,88(s5)
    80001db6:	87b6                	mv	a5,a3
    80001db8:	058a3703          	ld	a4,88(s4)
    80001dbc:	12068693          	addi	a3,a3,288
    80001dc0:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dc4:	6788                	ld	a0,8(a5)
    80001dc6:	6b8c                	ld	a1,16(a5)
    80001dc8:	6f90                	ld	a2,24(a5)
    80001dca:	01073023          	sd	a6,0(a4)
    80001dce:	e708                	sd	a0,8(a4)
    80001dd0:	eb0c                	sd	a1,16(a4)
    80001dd2:	ef10                	sd	a2,24(a4)
    80001dd4:	02078793          	addi	a5,a5,32
    80001dd8:	02070713          	addi	a4,a4,32
    80001ddc:	fed792e3          	bne	a5,a3,80001dc0 <fork+0x56>
  np->trapframe->a0 = 0;
    80001de0:	058a3783          	ld	a5,88(s4)
    80001de4:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001de8:	0d0a8493          	addi	s1,s5,208
    80001dec:	0d0a0913          	addi	s2,s4,208
    80001df0:	150a8993          	addi	s3,s5,336
    80001df4:	a00d                	j	80001e16 <fork+0xac>
    freeproc(np);
    80001df6:	8552                	mv	a0,s4
    80001df8:	00000097          	auipc	ra,0x0
    80001dfc:	d6e080e7          	jalr	-658(ra) # 80001b66 <freeproc>
    release(&np->lock);
    80001e00:	8552                	mv	a0,s4
    80001e02:	fffff097          	auipc	ra,0xfffff
    80001e06:	e88080e7          	jalr	-376(ra) # 80000c8a <release>
    return -1;
    80001e0a:	597d                	li	s2,-1
    80001e0c:	a059                	j	80001e92 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e0e:	04a1                	addi	s1,s1,8
    80001e10:	0921                	addi	s2,s2,8
    80001e12:	01348b63          	beq	s1,s3,80001e28 <fork+0xbe>
    if(p->ofile[i])
    80001e16:	6088                	ld	a0,0(s1)
    80001e18:	d97d                	beqz	a0,80001e0e <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e1a:	00002097          	auipc	ra,0x2
    80001e1e:	656080e7          	jalr	1622(ra) # 80004470 <filedup>
    80001e22:	00a93023          	sd	a0,0(s2)
    80001e26:	b7e5                	j	80001e0e <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e28:	150ab503          	ld	a0,336(s5)
    80001e2c:	00001097          	auipc	ra,0x1
    80001e30:	7ca080e7          	jalr	1994(ra) # 800035f6 <idup>
    80001e34:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e38:	4641                	li	a2,16
    80001e3a:	158a8593          	addi	a1,s5,344
    80001e3e:	158a0513          	addi	a0,s4,344
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	fda080e7          	jalr	-38(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e4a:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e4e:	8552                	mv	a0,s4
    80001e50:	fffff097          	auipc	ra,0xfffff
    80001e54:	e3a080e7          	jalr	-454(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e58:	0000f497          	auipc	s1,0xf
    80001e5c:	d3048493          	addi	s1,s1,-720 # 80010b88 <wait_lock>
    80001e60:	8526                	mv	a0,s1
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	d74080e7          	jalr	-652(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e6a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e6e:	8526                	mv	a0,s1
    80001e70:	fffff097          	auipc	ra,0xfffff
    80001e74:	e1a080e7          	jalr	-486(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e78:	8552                	mv	a0,s4
    80001e7a:	fffff097          	auipc	ra,0xfffff
    80001e7e:	d5c080e7          	jalr	-676(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e82:	478d                	li	a5,3
    80001e84:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e88:	8552                	mv	a0,s4
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	e00080e7          	jalr	-512(ra) # 80000c8a <release>
}
    80001e92:	854a                	mv	a0,s2
    80001e94:	70e2                	ld	ra,56(sp)
    80001e96:	7442                	ld	s0,48(sp)
    80001e98:	74a2                	ld	s1,40(sp)
    80001e9a:	7902                	ld	s2,32(sp)
    80001e9c:	69e2                	ld	s3,24(sp)
    80001e9e:	6a42                	ld	s4,16(sp)
    80001ea0:	6aa2                	ld	s5,8(sp)
    80001ea2:	6121                	addi	sp,sp,64
    80001ea4:	8082                	ret
    return -1;
    80001ea6:	597d                	li	s2,-1
    80001ea8:	b7ed                	j	80001e92 <fork+0x128>

0000000080001eaa <scheduler>:
{
    80001eaa:	7139                	addi	sp,sp,-64
    80001eac:	fc06                	sd	ra,56(sp)
    80001eae:	f822                	sd	s0,48(sp)
    80001eb0:	f426                	sd	s1,40(sp)
    80001eb2:	f04a                	sd	s2,32(sp)
    80001eb4:	ec4e                	sd	s3,24(sp)
    80001eb6:	e852                	sd	s4,16(sp)
    80001eb8:	e456                	sd	s5,8(sp)
    80001eba:	e05a                	sd	s6,0(sp)
    80001ebc:	0080                	addi	s0,sp,64
    80001ebe:	8792                	mv	a5,tp
  int id = r_tp();
    80001ec0:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001ec2:	00779a93          	slli	s5,a5,0x7
    80001ec6:	0000f717          	auipc	a4,0xf
    80001eca:	caa70713          	addi	a4,a4,-854 # 80010b70 <pid_lock>
    80001ece:	9756                	add	a4,a4,s5
    80001ed0:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ed4:	0000f717          	auipc	a4,0xf
    80001ed8:	cd470713          	addi	a4,a4,-812 # 80010ba8 <cpus+0x8>
    80001edc:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ede:	498d                	li	s3,3
        p->state = RUNNING;
    80001ee0:	4b11                	li	s6,4
        c->proc = p;
    80001ee2:	079e                	slli	a5,a5,0x7
    80001ee4:	0000fa17          	auipc	s4,0xf
    80001ee8:	c8ca0a13          	addi	s4,s4,-884 # 80010b70 <pid_lock>
    80001eec:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001eee:	00015917          	auipc	s2,0x15
    80001ef2:	ab290913          	addi	s2,s2,-1358 # 800169a0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001efa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001efe:	10079073          	csrw	sstatus,a5
    80001f02:	0000f497          	auipc	s1,0xf
    80001f06:	09e48493          	addi	s1,s1,158 # 80010fa0 <proc>
    80001f0a:	a811                	j	80001f1e <scheduler+0x74>
      release(&p->lock);
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	d7c080e7          	jalr	-644(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f16:	16848493          	addi	s1,s1,360
    80001f1a:	fd248ee3          	beq	s1,s2,80001ef6 <scheduler+0x4c>
      acquire(&p->lock);
    80001f1e:	8526                	mv	a0,s1
    80001f20:	fffff097          	auipc	ra,0xfffff
    80001f24:	cb6080e7          	jalr	-842(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f28:	4c9c                	lw	a5,24(s1)
    80001f2a:	ff3791e3          	bne	a5,s3,80001f0c <scheduler+0x62>
        p->state = RUNNING;
    80001f2e:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f32:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f36:	06048593          	addi	a1,s1,96
    80001f3a:	8556                	mv	a0,s5
    80001f3c:	00000097          	auipc	ra,0x0
    80001f40:	682080e7          	jalr	1666(ra) # 800025be <swtch>
        c->proc = 0;
    80001f44:	020a3823          	sd	zero,48(s4)
    80001f48:	b7d1                	j	80001f0c <scheduler+0x62>

0000000080001f4a <sched>:
{
    80001f4a:	7179                	addi	sp,sp,-48
    80001f4c:	f406                	sd	ra,40(sp)
    80001f4e:	f022                	sd	s0,32(sp)
    80001f50:	ec26                	sd	s1,24(sp)
    80001f52:	e84a                	sd	s2,16(sp)
    80001f54:	e44e                	sd	s3,8(sp)
    80001f56:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f58:	00000097          	auipc	ra,0x0
    80001f5c:	a5c080e7          	jalr	-1444(ra) # 800019b4 <myproc>
    80001f60:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f62:	fffff097          	auipc	ra,0xfffff
    80001f66:	bfa080e7          	jalr	-1030(ra) # 80000b5c <holding>
    80001f6a:	c93d                	beqz	a0,80001fe0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f6c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f6e:	2781                	sext.w	a5,a5
    80001f70:	079e                	slli	a5,a5,0x7
    80001f72:	0000f717          	auipc	a4,0xf
    80001f76:	bfe70713          	addi	a4,a4,-1026 # 80010b70 <pid_lock>
    80001f7a:	97ba                	add	a5,a5,a4
    80001f7c:	0a87a703          	lw	a4,168(a5)
    80001f80:	4785                	li	a5,1
    80001f82:	06f71763          	bne	a4,a5,80001ff0 <sched+0xa6>
  if(p->state == RUNNING)
    80001f86:	4c98                	lw	a4,24(s1)
    80001f88:	4791                	li	a5,4
    80001f8a:	06f70b63          	beq	a4,a5,80002000 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f8e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f92:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f94:	efb5                	bnez	a5,80002010 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f96:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f98:	0000f917          	auipc	s2,0xf
    80001f9c:	bd890913          	addi	s2,s2,-1064 # 80010b70 <pid_lock>
    80001fa0:	2781                	sext.w	a5,a5
    80001fa2:	079e                	slli	a5,a5,0x7
    80001fa4:	97ca                	add	a5,a5,s2
    80001fa6:	0ac7a983          	lw	s3,172(a5)
    80001faa:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fac:	2781                	sext.w	a5,a5
    80001fae:	079e                	slli	a5,a5,0x7
    80001fb0:	0000f597          	auipc	a1,0xf
    80001fb4:	bf858593          	addi	a1,a1,-1032 # 80010ba8 <cpus+0x8>
    80001fb8:	95be                	add	a1,a1,a5
    80001fba:	06048513          	addi	a0,s1,96
    80001fbe:	00000097          	auipc	ra,0x0
    80001fc2:	600080e7          	jalr	1536(ra) # 800025be <swtch>
    80001fc6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fc8:	2781                	sext.w	a5,a5
    80001fca:	079e                	slli	a5,a5,0x7
    80001fcc:	97ca                	add	a5,a5,s2
    80001fce:	0b37a623          	sw	s3,172(a5)
}
    80001fd2:	70a2                	ld	ra,40(sp)
    80001fd4:	7402                	ld	s0,32(sp)
    80001fd6:	64e2                	ld	s1,24(sp)
    80001fd8:	6942                	ld	s2,16(sp)
    80001fda:	69a2                	ld	s3,8(sp)
    80001fdc:	6145                	addi	sp,sp,48
    80001fde:	8082                	ret
    panic("sched p->lock");
    80001fe0:	00006517          	auipc	a0,0x6
    80001fe4:	23850513          	addi	a0,a0,568 # 80008218 <digits+0x1d8>
    80001fe8:	ffffe097          	auipc	ra,0xffffe
    80001fec:	556080e7          	jalr	1366(ra) # 8000053e <panic>
    panic("sched locks");
    80001ff0:	00006517          	auipc	a0,0x6
    80001ff4:	23850513          	addi	a0,a0,568 # 80008228 <digits+0x1e8>
    80001ff8:	ffffe097          	auipc	ra,0xffffe
    80001ffc:	546080e7          	jalr	1350(ra) # 8000053e <panic>
    panic("sched running");
    80002000:	00006517          	auipc	a0,0x6
    80002004:	23850513          	addi	a0,a0,568 # 80008238 <digits+0x1f8>
    80002008:	ffffe097          	auipc	ra,0xffffe
    8000200c:	536080e7          	jalr	1334(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002010:	00006517          	auipc	a0,0x6
    80002014:	23850513          	addi	a0,a0,568 # 80008248 <digits+0x208>
    80002018:	ffffe097          	auipc	ra,0xffffe
    8000201c:	526080e7          	jalr	1318(ra) # 8000053e <panic>

0000000080002020 <yield>:
{
    80002020:	1101                	addi	sp,sp,-32
    80002022:	ec06                	sd	ra,24(sp)
    80002024:	e822                	sd	s0,16(sp)
    80002026:	e426                	sd	s1,8(sp)
    80002028:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000202a:	00000097          	auipc	ra,0x0
    8000202e:	98a080e7          	jalr	-1654(ra) # 800019b4 <myproc>
    80002032:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	ba2080e7          	jalr	-1118(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    8000203c:	478d                	li	a5,3
    8000203e:	cc9c                	sw	a5,24(s1)
  sched();
    80002040:	00000097          	auipc	ra,0x0
    80002044:	f0a080e7          	jalr	-246(ra) # 80001f4a <sched>
  release(&p->lock);
    80002048:	8526                	mv	a0,s1
    8000204a:	fffff097          	auipc	ra,0xfffff
    8000204e:	c40080e7          	jalr	-960(ra) # 80000c8a <release>
}
    80002052:	60e2                	ld	ra,24(sp)
    80002054:	6442                	ld	s0,16(sp)
    80002056:	64a2                	ld	s1,8(sp)
    80002058:	6105                	addi	sp,sp,32
    8000205a:	8082                	ret

000000008000205c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000205c:	7179                	addi	sp,sp,-48
    8000205e:	f406                	sd	ra,40(sp)
    80002060:	f022                	sd	s0,32(sp)
    80002062:	ec26                	sd	s1,24(sp)
    80002064:	e84a                	sd	s2,16(sp)
    80002066:	e44e                	sd	s3,8(sp)
    80002068:	1800                	addi	s0,sp,48
    8000206a:	89aa                	mv	s3,a0
    8000206c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000206e:	00000097          	auipc	ra,0x0
    80002072:	946080e7          	jalr	-1722(ra) # 800019b4 <myproc>
    80002076:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002078:	fffff097          	auipc	ra,0xfffff
    8000207c:	b5e080e7          	jalr	-1186(ra) # 80000bd6 <acquire>
  release(lk);
    80002080:	854a                	mv	a0,s2
    80002082:	fffff097          	auipc	ra,0xfffff
    80002086:	c08080e7          	jalr	-1016(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    8000208a:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000208e:	4789                	li	a5,2
    80002090:	cc9c                	sw	a5,24(s1)

  sched();
    80002092:	00000097          	auipc	ra,0x0
    80002096:	eb8080e7          	jalr	-328(ra) # 80001f4a <sched>

  // Tidy up.
  p->chan = 0;
    8000209a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000209e:	8526                	mv	a0,s1
    800020a0:	fffff097          	auipc	ra,0xfffff
    800020a4:	bea080e7          	jalr	-1046(ra) # 80000c8a <release>
  acquire(lk);
    800020a8:	854a                	mv	a0,s2
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	b2c080e7          	jalr	-1236(ra) # 80000bd6 <acquire>
}
    800020b2:	70a2                	ld	ra,40(sp)
    800020b4:	7402                	ld	s0,32(sp)
    800020b6:	64e2                	ld	s1,24(sp)
    800020b8:	6942                	ld	s2,16(sp)
    800020ba:	69a2                	ld	s3,8(sp)
    800020bc:	6145                	addi	sp,sp,48
    800020be:	8082                	ret

00000000800020c0 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020c0:	7139                	addi	sp,sp,-64
    800020c2:	fc06                	sd	ra,56(sp)
    800020c4:	f822                	sd	s0,48(sp)
    800020c6:	f426                	sd	s1,40(sp)
    800020c8:	f04a                	sd	s2,32(sp)
    800020ca:	ec4e                	sd	s3,24(sp)
    800020cc:	e852                	sd	s4,16(sp)
    800020ce:	e456                	sd	s5,8(sp)
    800020d0:	0080                	addi	s0,sp,64
    800020d2:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020d4:	0000f497          	auipc	s1,0xf
    800020d8:	ecc48493          	addi	s1,s1,-308 # 80010fa0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020dc:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020de:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020e0:	00015917          	auipc	s2,0x15
    800020e4:	8c090913          	addi	s2,s2,-1856 # 800169a0 <tickslock>
    800020e8:	a811                	j	800020fc <wakeup+0x3c>
      }
      release(&p->lock);
    800020ea:	8526                	mv	a0,s1
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	b9e080e7          	jalr	-1122(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020f4:	16848493          	addi	s1,s1,360
    800020f8:	03248663          	beq	s1,s2,80002124 <wakeup+0x64>
    if(p != myproc()){
    800020fc:	00000097          	auipc	ra,0x0
    80002100:	8b8080e7          	jalr	-1864(ra) # 800019b4 <myproc>
    80002104:	fea488e3          	beq	s1,a0,800020f4 <wakeup+0x34>
      acquire(&p->lock);
    80002108:	8526                	mv	a0,s1
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	acc080e7          	jalr	-1332(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002112:	4c9c                	lw	a5,24(s1)
    80002114:	fd379be3          	bne	a5,s3,800020ea <wakeup+0x2a>
    80002118:	709c                	ld	a5,32(s1)
    8000211a:	fd4798e3          	bne	a5,s4,800020ea <wakeup+0x2a>
        p->state = RUNNABLE;
    8000211e:	0154ac23          	sw	s5,24(s1)
    80002122:	b7e1                	j	800020ea <wakeup+0x2a>
    }
  }
}
    80002124:	70e2                	ld	ra,56(sp)
    80002126:	7442                	ld	s0,48(sp)
    80002128:	74a2                	ld	s1,40(sp)
    8000212a:	7902                	ld	s2,32(sp)
    8000212c:	69e2                	ld	s3,24(sp)
    8000212e:	6a42                	ld	s4,16(sp)
    80002130:	6aa2                	ld	s5,8(sp)
    80002132:	6121                	addi	sp,sp,64
    80002134:	8082                	ret

0000000080002136 <reparent>:
{
    80002136:	7179                	addi	sp,sp,-48
    80002138:	f406                	sd	ra,40(sp)
    8000213a:	f022                	sd	s0,32(sp)
    8000213c:	ec26                	sd	s1,24(sp)
    8000213e:	e84a                	sd	s2,16(sp)
    80002140:	e44e                	sd	s3,8(sp)
    80002142:	e052                	sd	s4,0(sp)
    80002144:	1800                	addi	s0,sp,48
    80002146:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002148:	0000f497          	auipc	s1,0xf
    8000214c:	e5848493          	addi	s1,s1,-424 # 80010fa0 <proc>
      pp->parent = initproc;
    80002150:	00006a17          	auipc	s4,0x6
    80002154:	7a8a0a13          	addi	s4,s4,1960 # 800088f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002158:	00015997          	auipc	s3,0x15
    8000215c:	84898993          	addi	s3,s3,-1976 # 800169a0 <tickslock>
    80002160:	a029                	j	8000216a <reparent+0x34>
    80002162:	16848493          	addi	s1,s1,360
    80002166:	01348d63          	beq	s1,s3,80002180 <reparent+0x4a>
    if(pp->parent == p){
    8000216a:	7c9c                	ld	a5,56(s1)
    8000216c:	ff279be3          	bne	a5,s2,80002162 <reparent+0x2c>
      pp->parent = initproc;
    80002170:	000a3503          	ld	a0,0(s4)
    80002174:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002176:	00000097          	auipc	ra,0x0
    8000217a:	f4a080e7          	jalr	-182(ra) # 800020c0 <wakeup>
    8000217e:	b7d5                	j	80002162 <reparent+0x2c>
}
    80002180:	70a2                	ld	ra,40(sp)
    80002182:	7402                	ld	s0,32(sp)
    80002184:	64e2                	ld	s1,24(sp)
    80002186:	6942                	ld	s2,16(sp)
    80002188:	69a2                	ld	s3,8(sp)
    8000218a:	6a02                	ld	s4,0(sp)
    8000218c:	6145                	addi	sp,sp,48
    8000218e:	8082                	ret

0000000080002190 <exit>:
{
    80002190:	7179                	addi	sp,sp,-48
    80002192:	f406                	sd	ra,40(sp)
    80002194:	f022                	sd	s0,32(sp)
    80002196:	ec26                	sd	s1,24(sp)
    80002198:	e84a                	sd	s2,16(sp)
    8000219a:	e44e                	sd	s3,8(sp)
    8000219c:	e052                	sd	s4,0(sp)
    8000219e:	1800                	addi	s0,sp,48
    800021a0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021a2:	00000097          	auipc	ra,0x0
    800021a6:	812080e7          	jalr	-2030(ra) # 800019b4 <myproc>
    800021aa:	89aa                	mv	s3,a0
  if(p == initproc)
    800021ac:	00006797          	auipc	a5,0x6
    800021b0:	74c7b783          	ld	a5,1868(a5) # 800088f8 <initproc>
    800021b4:	0d050493          	addi	s1,a0,208
    800021b8:	15050913          	addi	s2,a0,336
    800021bc:	02a79363          	bne	a5,a0,800021e2 <exit+0x52>
    panic("init exiting");
    800021c0:	00006517          	auipc	a0,0x6
    800021c4:	0a050513          	addi	a0,a0,160 # 80008260 <digits+0x220>
    800021c8:	ffffe097          	auipc	ra,0xffffe
    800021cc:	376080e7          	jalr	886(ra) # 8000053e <panic>
      fileclose(f);
    800021d0:	00002097          	auipc	ra,0x2
    800021d4:	2f2080e7          	jalr	754(ra) # 800044c2 <fileclose>
      p->ofile[fd] = 0;
    800021d8:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021dc:	04a1                	addi	s1,s1,8
    800021de:	01248563          	beq	s1,s2,800021e8 <exit+0x58>
    if(p->ofile[fd]){
    800021e2:	6088                	ld	a0,0(s1)
    800021e4:	f575                	bnez	a0,800021d0 <exit+0x40>
    800021e6:	bfdd                	j	800021dc <exit+0x4c>
  begin_op();
    800021e8:	00002097          	auipc	ra,0x2
    800021ec:	e0e080e7          	jalr	-498(ra) # 80003ff6 <begin_op>
  iput(p->cwd);
    800021f0:	1509b503          	ld	a0,336(s3)
    800021f4:	00001097          	auipc	ra,0x1
    800021f8:	5fa080e7          	jalr	1530(ra) # 800037ee <iput>
  end_op();
    800021fc:	00002097          	auipc	ra,0x2
    80002200:	e7a080e7          	jalr	-390(ra) # 80004076 <end_op>
  p->cwd = 0;
    80002204:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002208:	0000f497          	auipc	s1,0xf
    8000220c:	98048493          	addi	s1,s1,-1664 # 80010b88 <wait_lock>
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	9c4080e7          	jalr	-1596(ra) # 80000bd6 <acquire>
  reparent(p);
    8000221a:	854e                	mv	a0,s3
    8000221c:	00000097          	auipc	ra,0x0
    80002220:	f1a080e7          	jalr	-230(ra) # 80002136 <reparent>
  wakeup(p->parent);
    80002224:	0389b503          	ld	a0,56(s3)
    80002228:	00000097          	auipc	ra,0x0
    8000222c:	e98080e7          	jalr	-360(ra) # 800020c0 <wakeup>
  acquire(&p->lock);
    80002230:	854e                	mv	a0,s3
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	9a4080e7          	jalr	-1628(ra) # 80000bd6 <acquire>
  p->xstate = status;
    8000223a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000223e:	4795                	li	a5,5
    80002240:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002244:	8526                	mv	a0,s1
    80002246:	fffff097          	auipc	ra,0xfffff
    8000224a:	a44080e7          	jalr	-1468(ra) # 80000c8a <release>
  sched();
    8000224e:	00000097          	auipc	ra,0x0
    80002252:	cfc080e7          	jalr	-772(ra) # 80001f4a <sched>
  panic("zombie exit");
    80002256:	00006517          	auipc	a0,0x6
    8000225a:	01a50513          	addi	a0,a0,26 # 80008270 <digits+0x230>
    8000225e:	ffffe097          	auipc	ra,0xffffe
    80002262:	2e0080e7          	jalr	736(ra) # 8000053e <panic>

0000000080002266 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002266:	7179                	addi	sp,sp,-48
    80002268:	f406                	sd	ra,40(sp)
    8000226a:	f022                	sd	s0,32(sp)
    8000226c:	ec26                	sd	s1,24(sp)
    8000226e:	e84a                	sd	s2,16(sp)
    80002270:	e44e                	sd	s3,8(sp)
    80002272:	1800                	addi	s0,sp,48
    80002274:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002276:	0000f497          	auipc	s1,0xf
    8000227a:	d2a48493          	addi	s1,s1,-726 # 80010fa0 <proc>
    8000227e:	00014997          	auipc	s3,0x14
    80002282:	72298993          	addi	s3,s3,1826 # 800169a0 <tickslock>
    acquire(&p->lock);
    80002286:	8526                	mv	a0,s1
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	94e080e7          	jalr	-1714(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002290:	589c                	lw	a5,48(s1)
    80002292:	01278d63          	beq	a5,s2,800022ac <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002296:	8526                	mv	a0,s1
    80002298:	fffff097          	auipc	ra,0xfffff
    8000229c:	9f2080e7          	jalr	-1550(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022a0:	16848493          	addi	s1,s1,360
    800022a4:	ff3491e3          	bne	s1,s3,80002286 <kill+0x20>
  }
  return -1;
    800022a8:	557d                	li	a0,-1
    800022aa:	a829                	j	800022c4 <kill+0x5e>
      p->killed = 1;
    800022ac:	4785                	li	a5,1
    800022ae:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022b0:	4c98                	lw	a4,24(s1)
    800022b2:	4789                	li	a5,2
    800022b4:	00f70f63          	beq	a4,a5,800022d2 <kill+0x6c>
      release(&p->lock);
    800022b8:	8526                	mv	a0,s1
    800022ba:	fffff097          	auipc	ra,0xfffff
    800022be:	9d0080e7          	jalr	-1584(ra) # 80000c8a <release>
      return 0;
    800022c2:	4501                	li	a0,0
}
    800022c4:	70a2                	ld	ra,40(sp)
    800022c6:	7402                	ld	s0,32(sp)
    800022c8:	64e2                	ld	s1,24(sp)
    800022ca:	6942                	ld	s2,16(sp)
    800022cc:	69a2                	ld	s3,8(sp)
    800022ce:	6145                	addi	sp,sp,48
    800022d0:	8082                	ret
        p->state = RUNNABLE;
    800022d2:	478d                	li	a5,3
    800022d4:	cc9c                	sw	a5,24(s1)
    800022d6:	b7cd                	j	800022b8 <kill+0x52>

00000000800022d8 <setkilled>:

void
setkilled(struct proc *p)
{
    800022d8:	1101                	addi	sp,sp,-32
    800022da:	ec06                	sd	ra,24(sp)
    800022dc:	e822                	sd	s0,16(sp)
    800022de:	e426                	sd	s1,8(sp)
    800022e0:	1000                	addi	s0,sp,32
    800022e2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	8f2080e7          	jalr	-1806(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800022ec:	4785                	li	a5,1
    800022ee:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022f0:	8526                	mv	a0,s1
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	998080e7          	jalr	-1640(ra) # 80000c8a <release>
}
    800022fa:	60e2                	ld	ra,24(sp)
    800022fc:	6442                	ld	s0,16(sp)
    800022fe:	64a2                	ld	s1,8(sp)
    80002300:	6105                	addi	sp,sp,32
    80002302:	8082                	ret

0000000080002304 <killed>:

int
killed(struct proc *p)
{
    80002304:	1101                	addi	sp,sp,-32
    80002306:	ec06                	sd	ra,24(sp)
    80002308:	e822                	sd	s0,16(sp)
    8000230a:	e426                	sd	s1,8(sp)
    8000230c:	e04a                	sd	s2,0(sp)
    8000230e:	1000                	addi	s0,sp,32
    80002310:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	8c4080e7          	jalr	-1852(ra) # 80000bd6 <acquire>
  k = p->killed;
    8000231a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	96a080e7          	jalr	-1686(ra) # 80000c8a <release>
  return k;
}
    80002328:	854a                	mv	a0,s2
    8000232a:	60e2                	ld	ra,24(sp)
    8000232c:	6442                	ld	s0,16(sp)
    8000232e:	64a2                	ld	s1,8(sp)
    80002330:	6902                	ld	s2,0(sp)
    80002332:	6105                	addi	sp,sp,32
    80002334:	8082                	ret

0000000080002336 <wait>:
{
    80002336:	715d                	addi	sp,sp,-80
    80002338:	e486                	sd	ra,72(sp)
    8000233a:	e0a2                	sd	s0,64(sp)
    8000233c:	fc26                	sd	s1,56(sp)
    8000233e:	f84a                	sd	s2,48(sp)
    80002340:	f44e                	sd	s3,40(sp)
    80002342:	f052                	sd	s4,32(sp)
    80002344:	ec56                	sd	s5,24(sp)
    80002346:	e85a                	sd	s6,16(sp)
    80002348:	e45e                	sd	s7,8(sp)
    8000234a:	e062                	sd	s8,0(sp)
    8000234c:	0880                	addi	s0,sp,80
    8000234e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	664080e7          	jalr	1636(ra) # 800019b4 <myproc>
    80002358:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000235a:	0000f517          	auipc	a0,0xf
    8000235e:	82e50513          	addi	a0,a0,-2002 # 80010b88 <wait_lock>
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	874080e7          	jalr	-1932(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000236a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000236c:	4a15                	li	s4,5
        havekids = 1;
    8000236e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002370:	00014997          	auipc	s3,0x14
    80002374:	63098993          	addi	s3,s3,1584 # 800169a0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002378:	0000fc17          	auipc	s8,0xf
    8000237c:	810c0c13          	addi	s8,s8,-2032 # 80010b88 <wait_lock>
    havekids = 0;
    80002380:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002382:	0000f497          	auipc	s1,0xf
    80002386:	c1e48493          	addi	s1,s1,-994 # 80010fa0 <proc>
    8000238a:	a0bd                	j	800023f8 <wait+0xc2>
          pid = pp->pid;
    8000238c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002390:	000b0e63          	beqz	s6,800023ac <wait+0x76>
    80002394:	4691                	li	a3,4
    80002396:	02c48613          	addi	a2,s1,44
    8000239a:	85da                	mv	a1,s6
    8000239c:	05093503          	ld	a0,80(s2)
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	2d0080e7          	jalr	720(ra) # 80001670 <copyout>
    800023a8:	02054563          	bltz	a0,800023d2 <wait+0x9c>
          freeproc(pp);
    800023ac:	8526                	mv	a0,s1
    800023ae:	fffff097          	auipc	ra,0xfffff
    800023b2:	7b8080e7          	jalr	1976(ra) # 80001b66 <freeproc>
          release(&pp->lock);
    800023b6:	8526                	mv	a0,s1
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	8d2080e7          	jalr	-1838(ra) # 80000c8a <release>
          release(&wait_lock);
    800023c0:	0000e517          	auipc	a0,0xe
    800023c4:	7c850513          	addi	a0,a0,1992 # 80010b88 <wait_lock>
    800023c8:	fffff097          	auipc	ra,0xfffff
    800023cc:	8c2080e7          	jalr	-1854(ra) # 80000c8a <release>
          return pid;
    800023d0:	a0b5                	j	8000243c <wait+0x106>
            release(&pp->lock);
    800023d2:	8526                	mv	a0,s1
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	8b6080e7          	jalr	-1866(ra) # 80000c8a <release>
            release(&wait_lock);
    800023dc:	0000e517          	auipc	a0,0xe
    800023e0:	7ac50513          	addi	a0,a0,1964 # 80010b88 <wait_lock>
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	8a6080e7          	jalr	-1882(ra) # 80000c8a <release>
            return -1;
    800023ec:	59fd                	li	s3,-1
    800023ee:	a0b9                	j	8000243c <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f0:	16848493          	addi	s1,s1,360
    800023f4:	03348463          	beq	s1,s3,8000241c <wait+0xe6>
      if(pp->parent == p){
    800023f8:	7c9c                	ld	a5,56(s1)
    800023fa:	ff279be3          	bne	a5,s2,800023f0 <wait+0xba>
        acquire(&pp->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	7d6080e7          	jalr	2006(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002408:	4c9c                	lw	a5,24(s1)
    8000240a:	f94781e3          	beq	a5,s4,8000238c <wait+0x56>
        release(&pp->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	87a080e7          	jalr	-1926(ra) # 80000c8a <release>
        havekids = 1;
    80002418:	8756                	mv	a4,s5
    8000241a:	bfd9                	j	800023f0 <wait+0xba>
    if(!havekids || killed(p)){
    8000241c:	c719                	beqz	a4,8000242a <wait+0xf4>
    8000241e:	854a                	mv	a0,s2
    80002420:	00000097          	auipc	ra,0x0
    80002424:	ee4080e7          	jalr	-284(ra) # 80002304 <killed>
    80002428:	c51d                	beqz	a0,80002456 <wait+0x120>
      release(&wait_lock);
    8000242a:	0000e517          	auipc	a0,0xe
    8000242e:	75e50513          	addi	a0,a0,1886 # 80010b88 <wait_lock>
    80002432:	fffff097          	auipc	ra,0xfffff
    80002436:	858080e7          	jalr	-1960(ra) # 80000c8a <release>
      return -1;
    8000243a:	59fd                	li	s3,-1
}
    8000243c:	854e                	mv	a0,s3
    8000243e:	60a6                	ld	ra,72(sp)
    80002440:	6406                	ld	s0,64(sp)
    80002442:	74e2                	ld	s1,56(sp)
    80002444:	7942                	ld	s2,48(sp)
    80002446:	79a2                	ld	s3,40(sp)
    80002448:	7a02                	ld	s4,32(sp)
    8000244a:	6ae2                	ld	s5,24(sp)
    8000244c:	6b42                	ld	s6,16(sp)
    8000244e:	6ba2                	ld	s7,8(sp)
    80002450:	6c02                	ld	s8,0(sp)
    80002452:	6161                	addi	sp,sp,80
    80002454:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002456:	85e2                	mv	a1,s8
    80002458:	854a                	mv	a0,s2
    8000245a:	00000097          	auipc	ra,0x0
    8000245e:	c02080e7          	jalr	-1022(ra) # 8000205c <sleep>
    havekids = 0;
    80002462:	bf39                	j	80002380 <wait+0x4a>

0000000080002464 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002464:	7179                	addi	sp,sp,-48
    80002466:	f406                	sd	ra,40(sp)
    80002468:	f022                	sd	s0,32(sp)
    8000246a:	ec26                	sd	s1,24(sp)
    8000246c:	e84a                	sd	s2,16(sp)
    8000246e:	e44e                	sd	s3,8(sp)
    80002470:	e052                	sd	s4,0(sp)
    80002472:	1800                	addi	s0,sp,48
    80002474:	84aa                	mv	s1,a0
    80002476:	892e                	mv	s2,a1
    80002478:	89b2                	mv	s3,a2
    8000247a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000247c:	fffff097          	auipc	ra,0xfffff
    80002480:	538080e7          	jalr	1336(ra) # 800019b4 <myproc>
  if(user_dst){
    80002484:	c08d                	beqz	s1,800024a6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002486:	86d2                	mv	a3,s4
    80002488:	864e                	mv	a2,s3
    8000248a:	85ca                	mv	a1,s2
    8000248c:	6928                	ld	a0,80(a0)
    8000248e:	fffff097          	auipc	ra,0xfffff
    80002492:	1e2080e7          	jalr	482(ra) # 80001670 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002496:	70a2                	ld	ra,40(sp)
    80002498:	7402                	ld	s0,32(sp)
    8000249a:	64e2                	ld	s1,24(sp)
    8000249c:	6942                	ld	s2,16(sp)
    8000249e:	69a2                	ld	s3,8(sp)
    800024a0:	6a02                	ld	s4,0(sp)
    800024a2:	6145                	addi	sp,sp,48
    800024a4:	8082                	ret
    memmove((char *)dst, src, len);
    800024a6:	000a061b          	sext.w	a2,s4
    800024aa:	85ce                	mv	a1,s3
    800024ac:	854a                	mv	a0,s2
    800024ae:	fffff097          	auipc	ra,0xfffff
    800024b2:	880080e7          	jalr	-1920(ra) # 80000d2e <memmove>
    return 0;
    800024b6:	8526                	mv	a0,s1
    800024b8:	bff9                	j	80002496 <either_copyout+0x32>

00000000800024ba <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024ba:	7179                	addi	sp,sp,-48
    800024bc:	f406                	sd	ra,40(sp)
    800024be:	f022                	sd	s0,32(sp)
    800024c0:	ec26                	sd	s1,24(sp)
    800024c2:	e84a                	sd	s2,16(sp)
    800024c4:	e44e                	sd	s3,8(sp)
    800024c6:	e052                	sd	s4,0(sp)
    800024c8:	1800                	addi	s0,sp,48
    800024ca:	892a                	mv	s2,a0
    800024cc:	84ae                	mv	s1,a1
    800024ce:	89b2                	mv	s3,a2
    800024d0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024d2:	fffff097          	auipc	ra,0xfffff
    800024d6:	4e2080e7          	jalr	1250(ra) # 800019b4 <myproc>
  if(user_src){
    800024da:	c08d                	beqz	s1,800024fc <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024dc:	86d2                	mv	a3,s4
    800024de:	864e                	mv	a2,s3
    800024e0:	85ca                	mv	a1,s2
    800024e2:	6928                	ld	a0,80(a0)
    800024e4:	fffff097          	auipc	ra,0xfffff
    800024e8:	218080e7          	jalr	536(ra) # 800016fc <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024ec:	70a2                	ld	ra,40(sp)
    800024ee:	7402                	ld	s0,32(sp)
    800024f0:	64e2                	ld	s1,24(sp)
    800024f2:	6942                	ld	s2,16(sp)
    800024f4:	69a2                	ld	s3,8(sp)
    800024f6:	6a02                	ld	s4,0(sp)
    800024f8:	6145                	addi	sp,sp,48
    800024fa:	8082                	ret
    memmove(dst, (char*)src, len);
    800024fc:	000a061b          	sext.w	a2,s4
    80002500:	85ce                	mv	a1,s3
    80002502:	854a                	mv	a0,s2
    80002504:	fffff097          	auipc	ra,0xfffff
    80002508:	82a080e7          	jalr	-2006(ra) # 80000d2e <memmove>
    return 0;
    8000250c:	8526                	mv	a0,s1
    8000250e:	bff9                	j	800024ec <either_copyin+0x32>

0000000080002510 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002510:	715d                	addi	sp,sp,-80
    80002512:	e486                	sd	ra,72(sp)
    80002514:	e0a2                	sd	s0,64(sp)
    80002516:	fc26                	sd	s1,56(sp)
    80002518:	f84a                	sd	s2,48(sp)
    8000251a:	f44e                	sd	s3,40(sp)
    8000251c:	f052                	sd	s4,32(sp)
    8000251e:	ec56                	sd	s5,24(sp)
    80002520:	e85a                	sd	s6,16(sp)
    80002522:	e45e                	sd	s7,8(sp)
    80002524:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002526:	00006517          	auipc	a0,0x6
    8000252a:	ba250513          	addi	a0,a0,-1118 # 800080c8 <digits+0x88>
    8000252e:	ffffe097          	auipc	ra,0xffffe
    80002532:	05a080e7          	jalr	90(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002536:	0000f497          	auipc	s1,0xf
    8000253a:	bc248493          	addi	s1,s1,-1086 # 800110f8 <proc+0x158>
    8000253e:	00014917          	auipc	s2,0x14
    80002542:	5ba90913          	addi	s2,s2,1466 # 80016af8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002546:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002548:	00006997          	auipc	s3,0x6
    8000254c:	d3898993          	addi	s3,s3,-712 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002550:	00006a97          	auipc	s5,0x6
    80002554:	d38a8a93          	addi	s5,s5,-712 # 80008288 <digits+0x248>
    printf("\n");
    80002558:	00006a17          	auipc	s4,0x6
    8000255c:	b70a0a13          	addi	s4,s4,-1168 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002560:	00006b97          	auipc	s7,0x6
    80002564:	d68b8b93          	addi	s7,s7,-664 # 800082c8 <states.0>
    80002568:	a00d                	j	8000258a <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000256a:	ed86a583          	lw	a1,-296(a3)
    8000256e:	8556                	mv	a0,s5
    80002570:	ffffe097          	auipc	ra,0xffffe
    80002574:	018080e7          	jalr	24(ra) # 80000588 <printf>
    printf("\n");
    80002578:	8552                	mv	a0,s4
    8000257a:	ffffe097          	auipc	ra,0xffffe
    8000257e:	00e080e7          	jalr	14(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002582:	16848493          	addi	s1,s1,360
    80002586:	03248163          	beq	s1,s2,800025a8 <procdump+0x98>
    if(p->state == UNUSED)
    8000258a:	86a6                	mv	a3,s1
    8000258c:	ec04a783          	lw	a5,-320(s1)
    80002590:	dbed                	beqz	a5,80002582 <procdump+0x72>
      state = "???";
    80002592:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002594:	fcfb6be3          	bltu	s6,a5,8000256a <procdump+0x5a>
    80002598:	1782                	slli	a5,a5,0x20
    8000259a:	9381                	srli	a5,a5,0x20
    8000259c:	078e                	slli	a5,a5,0x3
    8000259e:	97de                	add	a5,a5,s7
    800025a0:	6390                	ld	a2,0(a5)
    800025a2:	f661                	bnez	a2,8000256a <procdump+0x5a>
      state = "???";
    800025a4:	864e                	mv	a2,s3
    800025a6:	b7d1                	j	8000256a <procdump+0x5a>
  }
}
    800025a8:	60a6                	ld	ra,72(sp)
    800025aa:	6406                	ld	s0,64(sp)
    800025ac:	74e2                	ld	s1,56(sp)
    800025ae:	7942                	ld	s2,48(sp)
    800025b0:	79a2                	ld	s3,40(sp)
    800025b2:	7a02                	ld	s4,32(sp)
    800025b4:	6ae2                	ld	s5,24(sp)
    800025b6:	6b42                	ld	s6,16(sp)
    800025b8:	6ba2                	ld	s7,8(sp)
    800025ba:	6161                	addi	sp,sp,80
    800025bc:	8082                	ret

00000000800025be <swtch>:
    800025be:	00153023          	sd	ra,0(a0)
    800025c2:	00253423          	sd	sp,8(a0)
    800025c6:	e900                	sd	s0,16(a0)
    800025c8:	ed04                	sd	s1,24(a0)
    800025ca:	03253023          	sd	s2,32(a0)
    800025ce:	03353423          	sd	s3,40(a0)
    800025d2:	03453823          	sd	s4,48(a0)
    800025d6:	03553c23          	sd	s5,56(a0)
    800025da:	05653023          	sd	s6,64(a0)
    800025de:	05753423          	sd	s7,72(a0)
    800025e2:	05853823          	sd	s8,80(a0)
    800025e6:	05953c23          	sd	s9,88(a0)
    800025ea:	07a53023          	sd	s10,96(a0)
    800025ee:	07b53423          	sd	s11,104(a0)
    800025f2:	0005b083          	ld	ra,0(a1)
    800025f6:	0085b103          	ld	sp,8(a1)
    800025fa:	6980                	ld	s0,16(a1)
    800025fc:	6d84                	ld	s1,24(a1)
    800025fe:	0205b903          	ld	s2,32(a1)
    80002602:	0285b983          	ld	s3,40(a1)
    80002606:	0305ba03          	ld	s4,48(a1)
    8000260a:	0385ba83          	ld	s5,56(a1)
    8000260e:	0405bb03          	ld	s6,64(a1)
    80002612:	0485bb83          	ld	s7,72(a1)
    80002616:	0505bc03          	ld	s8,80(a1)
    8000261a:	0585bc83          	ld	s9,88(a1)
    8000261e:	0605bd03          	ld	s10,96(a1)
    80002622:	0685bd83          	ld	s11,104(a1)
    80002626:	8082                	ret

0000000080002628 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002628:	1141                	addi	sp,sp,-16
    8000262a:	e406                	sd	ra,8(sp)
    8000262c:	e022                	sd	s0,0(sp)
    8000262e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002630:	00006597          	auipc	a1,0x6
    80002634:	cc858593          	addi	a1,a1,-824 # 800082f8 <states.0+0x30>
    80002638:	00014517          	auipc	a0,0x14
    8000263c:	36850513          	addi	a0,a0,872 # 800169a0 <tickslock>
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	506080e7          	jalr	1286(ra) # 80000b46 <initlock>
}
    80002648:	60a2                	ld	ra,8(sp)
    8000264a:	6402                	ld	s0,0(sp)
    8000264c:	0141                	addi	sp,sp,16
    8000264e:	8082                	ret

0000000080002650 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002650:	1141                	addi	sp,sp,-16
    80002652:	e422                	sd	s0,8(sp)
    80002654:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002656:	00003797          	auipc	a5,0x3
    8000265a:	4ba78793          	addi	a5,a5,1210 # 80005b10 <kernelvec>
    8000265e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002662:	6422                	ld	s0,8(sp)
    80002664:	0141                	addi	sp,sp,16
    80002666:	8082                	ret

0000000080002668 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002668:	1141                	addi	sp,sp,-16
    8000266a:	e406                	sd	ra,8(sp)
    8000266c:	e022                	sd	s0,0(sp)
    8000266e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002670:	fffff097          	auipc	ra,0xfffff
    80002674:	344080e7          	jalr	836(ra) # 800019b4 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002678:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000267c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000267e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002682:	00005617          	auipc	a2,0x5
    80002686:	97e60613          	addi	a2,a2,-1666 # 80007000 <_trampoline>
    8000268a:	00005697          	auipc	a3,0x5
    8000268e:	97668693          	addi	a3,a3,-1674 # 80007000 <_trampoline>
    80002692:	8e91                	sub	a3,a3,a2
    80002694:	040007b7          	lui	a5,0x4000
    80002698:	17fd                	addi	a5,a5,-1
    8000269a:	07b2                	slli	a5,a5,0xc
    8000269c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000269e:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026a2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026a4:	180026f3          	csrr	a3,satp
    800026a8:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026aa:	6d38                	ld	a4,88(a0)
    800026ac:	6134                	ld	a3,64(a0)
    800026ae:	6585                	lui	a1,0x1
    800026b0:	96ae                	add	a3,a3,a1
    800026b2:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026b4:	6d38                	ld	a4,88(a0)
    800026b6:	00000697          	auipc	a3,0x0
    800026ba:	13068693          	addi	a3,a3,304 # 800027e6 <usertrap>
    800026be:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026c0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026c2:	8692                	mv	a3,tp
    800026c4:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026c6:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026ca:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026ce:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026d2:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026d6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026d8:	6f18                	ld	a4,24(a4)
    800026da:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026de:	6928                	ld	a0,80(a0)
    800026e0:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026e2:	00005717          	auipc	a4,0x5
    800026e6:	9ba70713          	addi	a4,a4,-1606 # 8000709c <userret>
    800026ea:	8f11                	sub	a4,a4,a2
    800026ec:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026ee:	577d                	li	a4,-1
    800026f0:	177e                	slli	a4,a4,0x3f
    800026f2:	8d59                	or	a0,a0,a4
    800026f4:	9782                	jalr	a5
}
    800026f6:	60a2                	ld	ra,8(sp)
    800026f8:	6402                	ld	s0,0(sp)
    800026fa:	0141                	addi	sp,sp,16
    800026fc:	8082                	ret

00000000800026fe <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026fe:	1101                	addi	sp,sp,-32
    80002700:	ec06                	sd	ra,24(sp)
    80002702:	e822                	sd	s0,16(sp)
    80002704:	e426                	sd	s1,8(sp)
    80002706:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002708:	00014497          	auipc	s1,0x14
    8000270c:	29848493          	addi	s1,s1,664 # 800169a0 <tickslock>
    80002710:	8526                	mv	a0,s1
    80002712:	ffffe097          	auipc	ra,0xffffe
    80002716:	4c4080e7          	jalr	1220(ra) # 80000bd6 <acquire>
  ticks++;
    8000271a:	00006517          	auipc	a0,0x6
    8000271e:	1e650513          	addi	a0,a0,486 # 80008900 <ticks>
    80002722:	411c                	lw	a5,0(a0)
    80002724:	2785                	addiw	a5,a5,1
    80002726:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002728:	00000097          	auipc	ra,0x0
    8000272c:	998080e7          	jalr	-1640(ra) # 800020c0 <wakeup>
  release(&tickslock);
    80002730:	8526                	mv	a0,s1
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	558080e7          	jalr	1368(ra) # 80000c8a <release>
}
    8000273a:	60e2                	ld	ra,24(sp)
    8000273c:	6442                	ld	s0,16(sp)
    8000273e:	64a2                	ld	s1,8(sp)
    80002740:	6105                	addi	sp,sp,32
    80002742:	8082                	ret

0000000080002744 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002744:	1101                	addi	sp,sp,-32
    80002746:	ec06                	sd	ra,24(sp)
    80002748:	e822                	sd	s0,16(sp)
    8000274a:	e426                	sd	s1,8(sp)
    8000274c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000274e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002752:	00074d63          	bltz	a4,8000276c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002756:	57fd                	li	a5,-1
    80002758:	17fe                	slli	a5,a5,0x3f
    8000275a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000275c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000275e:	06f70363          	beq	a4,a5,800027c4 <devintr+0x80>
  }
}
    80002762:	60e2                	ld	ra,24(sp)
    80002764:	6442                	ld	s0,16(sp)
    80002766:	64a2                	ld	s1,8(sp)
    80002768:	6105                	addi	sp,sp,32
    8000276a:	8082                	ret
     (scause & 0xff) == 9){
    8000276c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002770:	46a5                	li	a3,9
    80002772:	fed792e3          	bne	a5,a3,80002756 <devintr+0x12>
    int irq = plic_claim();
    80002776:	00003097          	auipc	ra,0x3
    8000277a:	4a2080e7          	jalr	1186(ra) # 80005c18 <plic_claim>
    8000277e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002780:	47a9                	li	a5,10
    80002782:	02f50763          	beq	a0,a5,800027b0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002786:	4785                	li	a5,1
    80002788:	02f50963          	beq	a0,a5,800027ba <devintr+0x76>
    return 1;
    8000278c:	4505                	li	a0,1
    } else if(irq){
    8000278e:	d8f1                	beqz	s1,80002762 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002790:	85a6                	mv	a1,s1
    80002792:	00006517          	auipc	a0,0x6
    80002796:	b6e50513          	addi	a0,a0,-1170 # 80008300 <states.0+0x38>
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	dee080e7          	jalr	-530(ra) # 80000588 <printf>
      plic_complete(irq);
    800027a2:	8526                	mv	a0,s1
    800027a4:	00003097          	auipc	ra,0x3
    800027a8:	498080e7          	jalr	1176(ra) # 80005c3c <plic_complete>
    return 1;
    800027ac:	4505                	li	a0,1
    800027ae:	bf55                	j	80002762 <devintr+0x1e>
      uartintr();
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	1ea080e7          	jalr	490(ra) # 8000099a <uartintr>
    800027b8:	b7ed                	j	800027a2 <devintr+0x5e>
      virtio_disk_intr();
    800027ba:	00004097          	auipc	ra,0x4
    800027be:	94e080e7          	jalr	-1714(ra) # 80006108 <virtio_disk_intr>
    800027c2:	b7c5                	j	800027a2 <devintr+0x5e>
    if(cpuid() == 0){
    800027c4:	fffff097          	auipc	ra,0xfffff
    800027c8:	1c4080e7          	jalr	452(ra) # 80001988 <cpuid>
    800027cc:	c901                	beqz	a0,800027dc <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027ce:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027d2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027d4:	14479073          	csrw	sip,a5
    return 2;
    800027d8:	4509                	li	a0,2
    800027da:	b761                	j	80002762 <devintr+0x1e>
      clockintr();
    800027dc:	00000097          	auipc	ra,0x0
    800027e0:	f22080e7          	jalr	-222(ra) # 800026fe <clockintr>
    800027e4:	b7ed                	j	800027ce <devintr+0x8a>

00000000800027e6 <usertrap>:
{
    800027e6:	1101                	addi	sp,sp,-32
    800027e8:	ec06                	sd	ra,24(sp)
    800027ea:	e822                	sd	s0,16(sp)
    800027ec:	e426                	sd	s1,8(sp)
    800027ee:	e04a                	sd	s2,0(sp)
    800027f0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027f6:	1007f793          	andi	a5,a5,256
    800027fa:	e3b1                	bnez	a5,8000283e <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027fc:	00003797          	auipc	a5,0x3
    80002800:	31478793          	addi	a5,a5,788 # 80005b10 <kernelvec>
    80002804:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002808:	fffff097          	auipc	ra,0xfffff
    8000280c:	1ac080e7          	jalr	428(ra) # 800019b4 <myproc>
    80002810:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002812:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002814:	14102773          	csrr	a4,sepc
    80002818:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000281a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000281e:	47a1                	li	a5,8
    80002820:	02f70763          	beq	a4,a5,8000284e <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002824:	00000097          	auipc	ra,0x0
    80002828:	f20080e7          	jalr	-224(ra) # 80002744 <devintr>
    8000282c:	892a                	mv	s2,a0
    8000282e:	c151                	beqz	a0,800028b2 <usertrap+0xcc>
  if(killed(p))
    80002830:	8526                	mv	a0,s1
    80002832:	00000097          	auipc	ra,0x0
    80002836:	ad2080e7          	jalr	-1326(ra) # 80002304 <killed>
    8000283a:	c929                	beqz	a0,8000288c <usertrap+0xa6>
    8000283c:	a099                	j	80002882 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    8000283e:	00006517          	auipc	a0,0x6
    80002842:	ae250513          	addi	a0,a0,-1310 # 80008320 <states.0+0x58>
    80002846:	ffffe097          	auipc	ra,0xffffe
    8000284a:	cf8080e7          	jalr	-776(ra) # 8000053e <panic>
    if(killed(p))
    8000284e:	00000097          	auipc	ra,0x0
    80002852:	ab6080e7          	jalr	-1354(ra) # 80002304 <killed>
    80002856:	e921                	bnez	a0,800028a6 <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002858:	6cb8                	ld	a4,88(s1)
    8000285a:	6f1c                	ld	a5,24(a4)
    8000285c:	0791                	addi	a5,a5,4
    8000285e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002860:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002864:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002868:	10079073          	csrw	sstatus,a5
    syscall();
    8000286c:	00000097          	auipc	ra,0x0
    80002870:	2d4080e7          	jalr	724(ra) # 80002b40 <syscall>
  if(killed(p))
    80002874:	8526                	mv	a0,s1
    80002876:	00000097          	auipc	ra,0x0
    8000287a:	a8e080e7          	jalr	-1394(ra) # 80002304 <killed>
    8000287e:	c911                	beqz	a0,80002892 <usertrap+0xac>
    80002880:	4901                	li	s2,0
    exit(-1);
    80002882:	557d                	li	a0,-1
    80002884:	00000097          	auipc	ra,0x0
    80002888:	90c080e7          	jalr	-1780(ra) # 80002190 <exit>
  if(which_dev == 2)
    8000288c:	4789                	li	a5,2
    8000288e:	04f90f63          	beq	s2,a5,800028ec <usertrap+0x106>
  usertrapret();
    80002892:	00000097          	auipc	ra,0x0
    80002896:	dd6080e7          	jalr	-554(ra) # 80002668 <usertrapret>
}
    8000289a:	60e2                	ld	ra,24(sp)
    8000289c:	6442                	ld	s0,16(sp)
    8000289e:	64a2                	ld	s1,8(sp)
    800028a0:	6902                	ld	s2,0(sp)
    800028a2:	6105                	addi	sp,sp,32
    800028a4:	8082                	ret
      exit(-1);
    800028a6:	557d                	li	a0,-1
    800028a8:	00000097          	auipc	ra,0x0
    800028ac:	8e8080e7          	jalr	-1816(ra) # 80002190 <exit>
    800028b0:	b765                	j	80002858 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028b6:	5890                	lw	a2,48(s1)
    800028b8:	00006517          	auipc	a0,0x6
    800028bc:	a8850513          	addi	a0,a0,-1400 # 80008340 <states.0+0x78>
    800028c0:	ffffe097          	auipc	ra,0xffffe
    800028c4:	cc8080e7          	jalr	-824(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028c8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028cc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028d0:	00006517          	auipc	a0,0x6
    800028d4:	aa050513          	addi	a0,a0,-1376 # 80008370 <states.0+0xa8>
    800028d8:	ffffe097          	auipc	ra,0xffffe
    800028dc:	cb0080e7          	jalr	-848(ra) # 80000588 <printf>
    setkilled(p);
    800028e0:	8526                	mv	a0,s1
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	9f6080e7          	jalr	-1546(ra) # 800022d8 <setkilled>
    800028ea:	b769                	j	80002874 <usertrap+0x8e>
    yield();
    800028ec:	fffff097          	auipc	ra,0xfffff
    800028f0:	734080e7          	jalr	1844(ra) # 80002020 <yield>
    800028f4:	bf79                	j	80002892 <usertrap+0xac>

00000000800028f6 <kerneltrap>:
{
    800028f6:	7179                	addi	sp,sp,-48
    800028f8:	f406                	sd	ra,40(sp)
    800028fa:	f022                	sd	s0,32(sp)
    800028fc:	ec26                	sd	s1,24(sp)
    800028fe:	e84a                	sd	s2,16(sp)
    80002900:	e44e                	sd	s3,8(sp)
    80002902:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002904:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002908:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000290c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002910:	1004f793          	andi	a5,s1,256
    80002914:	cb85                	beqz	a5,80002944 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002916:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000291a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000291c:	ef85                	bnez	a5,80002954 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000291e:	00000097          	auipc	ra,0x0
    80002922:	e26080e7          	jalr	-474(ra) # 80002744 <devintr>
    80002926:	cd1d                	beqz	a0,80002964 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002928:	4789                	li	a5,2
    8000292a:	06f50a63          	beq	a0,a5,8000299e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000292e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002932:	10049073          	csrw	sstatus,s1
}
    80002936:	70a2                	ld	ra,40(sp)
    80002938:	7402                	ld	s0,32(sp)
    8000293a:	64e2                	ld	s1,24(sp)
    8000293c:	6942                	ld	s2,16(sp)
    8000293e:	69a2                	ld	s3,8(sp)
    80002940:	6145                	addi	sp,sp,48
    80002942:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002944:	00006517          	auipc	a0,0x6
    80002948:	a4c50513          	addi	a0,a0,-1460 # 80008390 <states.0+0xc8>
    8000294c:	ffffe097          	auipc	ra,0xffffe
    80002950:	bf2080e7          	jalr	-1038(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002954:	00006517          	auipc	a0,0x6
    80002958:	a6450513          	addi	a0,a0,-1436 # 800083b8 <states.0+0xf0>
    8000295c:	ffffe097          	auipc	ra,0xffffe
    80002960:	be2080e7          	jalr	-1054(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002964:	85ce                	mv	a1,s3
    80002966:	00006517          	auipc	a0,0x6
    8000296a:	a7250513          	addi	a0,a0,-1422 # 800083d8 <states.0+0x110>
    8000296e:	ffffe097          	auipc	ra,0xffffe
    80002972:	c1a080e7          	jalr	-998(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002976:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000297a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000297e:	00006517          	auipc	a0,0x6
    80002982:	a6a50513          	addi	a0,a0,-1430 # 800083e8 <states.0+0x120>
    80002986:	ffffe097          	auipc	ra,0xffffe
    8000298a:	c02080e7          	jalr	-1022(ra) # 80000588 <printf>
    panic("kerneltrap");
    8000298e:	00006517          	auipc	a0,0x6
    80002992:	a7250513          	addi	a0,a0,-1422 # 80008400 <states.0+0x138>
    80002996:	ffffe097          	auipc	ra,0xffffe
    8000299a:	ba8080e7          	jalr	-1112(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000299e:	fffff097          	auipc	ra,0xfffff
    800029a2:	016080e7          	jalr	22(ra) # 800019b4 <myproc>
    800029a6:	d541                	beqz	a0,8000292e <kerneltrap+0x38>
    800029a8:	fffff097          	auipc	ra,0xfffff
    800029ac:	00c080e7          	jalr	12(ra) # 800019b4 <myproc>
    800029b0:	4d18                	lw	a4,24(a0)
    800029b2:	4791                	li	a5,4
    800029b4:	f6f71de3          	bne	a4,a5,8000292e <kerneltrap+0x38>
    yield();
    800029b8:	fffff097          	auipc	ra,0xfffff
    800029bc:	668080e7          	jalr	1640(ra) # 80002020 <yield>
    800029c0:	b7bd                	j	8000292e <kerneltrap+0x38>

00000000800029c2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029c2:	1101                	addi	sp,sp,-32
    800029c4:	ec06                	sd	ra,24(sp)
    800029c6:	e822                	sd	s0,16(sp)
    800029c8:	e426                	sd	s1,8(sp)
    800029ca:	1000                	addi	s0,sp,32
    800029cc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029ce:	fffff097          	auipc	ra,0xfffff
    800029d2:	fe6080e7          	jalr	-26(ra) # 800019b4 <myproc>
  switch (n) {
    800029d6:	4795                	li	a5,5
    800029d8:	0497e163          	bltu	a5,s1,80002a1a <argraw+0x58>
    800029dc:	048a                	slli	s1,s1,0x2
    800029de:	00006717          	auipc	a4,0x6
    800029e2:	a5a70713          	addi	a4,a4,-1446 # 80008438 <states.0+0x170>
    800029e6:	94ba                	add	s1,s1,a4
    800029e8:	409c                	lw	a5,0(s1)
    800029ea:	97ba                	add	a5,a5,a4
    800029ec:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029ee:	6d3c                	ld	a5,88(a0)
    800029f0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029f2:	60e2                	ld	ra,24(sp)
    800029f4:	6442                	ld	s0,16(sp)
    800029f6:	64a2                	ld	s1,8(sp)
    800029f8:	6105                	addi	sp,sp,32
    800029fa:	8082                	ret
    return p->trapframe->a1;
    800029fc:	6d3c                	ld	a5,88(a0)
    800029fe:	7fa8                	ld	a0,120(a5)
    80002a00:	bfcd                	j	800029f2 <argraw+0x30>
    return p->trapframe->a2;
    80002a02:	6d3c                	ld	a5,88(a0)
    80002a04:	63c8                	ld	a0,128(a5)
    80002a06:	b7f5                	j	800029f2 <argraw+0x30>
    return p->trapframe->a3;
    80002a08:	6d3c                	ld	a5,88(a0)
    80002a0a:	67c8                	ld	a0,136(a5)
    80002a0c:	b7dd                	j	800029f2 <argraw+0x30>
    return p->trapframe->a4;
    80002a0e:	6d3c                	ld	a5,88(a0)
    80002a10:	6bc8                	ld	a0,144(a5)
    80002a12:	b7c5                	j	800029f2 <argraw+0x30>
    return p->trapframe->a5;
    80002a14:	6d3c                	ld	a5,88(a0)
    80002a16:	6fc8                	ld	a0,152(a5)
    80002a18:	bfe9                	j	800029f2 <argraw+0x30>
  panic("argraw");
    80002a1a:	00006517          	auipc	a0,0x6
    80002a1e:	9f650513          	addi	a0,a0,-1546 # 80008410 <states.0+0x148>
    80002a22:	ffffe097          	auipc	ra,0xffffe
    80002a26:	b1c080e7          	jalr	-1252(ra) # 8000053e <panic>

0000000080002a2a <fetchaddr>:
{
    80002a2a:	1101                	addi	sp,sp,-32
    80002a2c:	ec06                	sd	ra,24(sp)
    80002a2e:	e822                	sd	s0,16(sp)
    80002a30:	e426                	sd	s1,8(sp)
    80002a32:	e04a                	sd	s2,0(sp)
    80002a34:	1000                	addi	s0,sp,32
    80002a36:	84aa                	mv	s1,a0
    80002a38:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a3a:	fffff097          	auipc	ra,0xfffff
    80002a3e:	f7a080e7          	jalr	-134(ra) # 800019b4 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a42:	653c                	ld	a5,72(a0)
    80002a44:	02f4f863          	bgeu	s1,a5,80002a74 <fetchaddr+0x4a>
    80002a48:	00848713          	addi	a4,s1,8
    80002a4c:	02e7e663          	bltu	a5,a4,80002a78 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a50:	46a1                	li	a3,8
    80002a52:	8626                	mv	a2,s1
    80002a54:	85ca                	mv	a1,s2
    80002a56:	6928                	ld	a0,80(a0)
    80002a58:	fffff097          	auipc	ra,0xfffff
    80002a5c:	ca4080e7          	jalr	-860(ra) # 800016fc <copyin>
    80002a60:	00a03533          	snez	a0,a0
    80002a64:	40a00533          	neg	a0,a0
}
    80002a68:	60e2                	ld	ra,24(sp)
    80002a6a:	6442                	ld	s0,16(sp)
    80002a6c:	64a2                	ld	s1,8(sp)
    80002a6e:	6902                	ld	s2,0(sp)
    80002a70:	6105                	addi	sp,sp,32
    80002a72:	8082                	ret
    return -1;
    80002a74:	557d                	li	a0,-1
    80002a76:	bfcd                	j	80002a68 <fetchaddr+0x3e>
    80002a78:	557d                	li	a0,-1
    80002a7a:	b7fd                	j	80002a68 <fetchaddr+0x3e>

0000000080002a7c <fetchstr>:
{
    80002a7c:	7179                	addi	sp,sp,-48
    80002a7e:	f406                	sd	ra,40(sp)
    80002a80:	f022                	sd	s0,32(sp)
    80002a82:	ec26                	sd	s1,24(sp)
    80002a84:	e84a                	sd	s2,16(sp)
    80002a86:	e44e                	sd	s3,8(sp)
    80002a88:	1800                	addi	s0,sp,48
    80002a8a:	892a                	mv	s2,a0
    80002a8c:	84ae                	mv	s1,a1
    80002a8e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a90:	fffff097          	auipc	ra,0xfffff
    80002a94:	f24080e7          	jalr	-220(ra) # 800019b4 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a98:	86ce                	mv	a3,s3
    80002a9a:	864a                	mv	a2,s2
    80002a9c:	85a6                	mv	a1,s1
    80002a9e:	6928                	ld	a0,80(a0)
    80002aa0:	fffff097          	auipc	ra,0xfffff
    80002aa4:	cea080e7          	jalr	-790(ra) # 8000178a <copyinstr>
    80002aa8:	00054e63          	bltz	a0,80002ac4 <fetchstr+0x48>
  return strlen(buf);
    80002aac:	8526                	mv	a0,s1
    80002aae:	ffffe097          	auipc	ra,0xffffe
    80002ab2:	3a0080e7          	jalr	928(ra) # 80000e4e <strlen>
}
    80002ab6:	70a2                	ld	ra,40(sp)
    80002ab8:	7402                	ld	s0,32(sp)
    80002aba:	64e2                	ld	s1,24(sp)
    80002abc:	6942                	ld	s2,16(sp)
    80002abe:	69a2                	ld	s3,8(sp)
    80002ac0:	6145                	addi	sp,sp,48
    80002ac2:	8082                	ret
    return -1;
    80002ac4:	557d                	li	a0,-1
    80002ac6:	bfc5                	j	80002ab6 <fetchstr+0x3a>

0000000080002ac8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ac8:	1101                	addi	sp,sp,-32
    80002aca:	ec06                	sd	ra,24(sp)
    80002acc:	e822                	sd	s0,16(sp)
    80002ace:	e426                	sd	s1,8(sp)
    80002ad0:	1000                	addi	s0,sp,32
    80002ad2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ad4:	00000097          	auipc	ra,0x0
    80002ad8:	eee080e7          	jalr	-274(ra) # 800029c2 <argraw>
    80002adc:	c088                	sw	a0,0(s1)
}
    80002ade:	60e2                	ld	ra,24(sp)
    80002ae0:	6442                	ld	s0,16(sp)
    80002ae2:	64a2                	ld	s1,8(sp)
    80002ae4:	6105                	addi	sp,sp,32
    80002ae6:	8082                	ret

0000000080002ae8 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ae8:	1101                	addi	sp,sp,-32
    80002aea:	ec06                	sd	ra,24(sp)
    80002aec:	e822                	sd	s0,16(sp)
    80002aee:	e426                	sd	s1,8(sp)
    80002af0:	1000                	addi	s0,sp,32
    80002af2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002af4:	00000097          	auipc	ra,0x0
    80002af8:	ece080e7          	jalr	-306(ra) # 800029c2 <argraw>
    80002afc:	e088                	sd	a0,0(s1)
}
    80002afe:	60e2                	ld	ra,24(sp)
    80002b00:	6442                	ld	s0,16(sp)
    80002b02:	64a2                	ld	s1,8(sp)
    80002b04:	6105                	addi	sp,sp,32
    80002b06:	8082                	ret

0000000080002b08 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b08:	7179                	addi	sp,sp,-48
    80002b0a:	f406                	sd	ra,40(sp)
    80002b0c:	f022                	sd	s0,32(sp)
    80002b0e:	ec26                	sd	s1,24(sp)
    80002b10:	e84a                	sd	s2,16(sp)
    80002b12:	1800                	addi	s0,sp,48
    80002b14:	84ae                	mv	s1,a1
    80002b16:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b18:	fd840593          	addi	a1,s0,-40
    80002b1c:	00000097          	auipc	ra,0x0
    80002b20:	fcc080e7          	jalr	-52(ra) # 80002ae8 <argaddr>
  return fetchstr(addr, buf, max);
    80002b24:	864a                	mv	a2,s2
    80002b26:	85a6                	mv	a1,s1
    80002b28:	fd843503          	ld	a0,-40(s0)
    80002b2c:	00000097          	auipc	ra,0x0
    80002b30:	f50080e7          	jalr	-176(ra) # 80002a7c <fetchstr>
}
    80002b34:	70a2                	ld	ra,40(sp)
    80002b36:	7402                	ld	s0,32(sp)
    80002b38:	64e2                	ld	s1,24(sp)
    80002b3a:	6942                	ld	s2,16(sp)
    80002b3c:	6145                	addi	sp,sp,48
    80002b3e:	8082                	ret

0000000080002b40 <syscall>:
[SYS_peterson_destroy] sys_peterson_destroy
};

void
syscall(void)
{
    80002b40:	1101                	addi	sp,sp,-32
    80002b42:	ec06                	sd	ra,24(sp)
    80002b44:	e822                	sd	s0,16(sp)
    80002b46:	e426                	sd	s1,8(sp)
    80002b48:	e04a                	sd	s2,0(sp)
    80002b4a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	e68080e7          	jalr	-408(ra) # 800019b4 <myproc>
    80002b54:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b56:	05853903          	ld	s2,88(a0)
    80002b5a:	0a893783          	ld	a5,168(s2)
    80002b5e:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b62:	37fd                	addiw	a5,a5,-1
    80002b64:	4761                	li	a4,24
    80002b66:	00f76f63          	bltu	a4,a5,80002b84 <syscall+0x44>
    80002b6a:	00369713          	slli	a4,a3,0x3
    80002b6e:	00006797          	auipc	a5,0x6
    80002b72:	8e278793          	addi	a5,a5,-1822 # 80008450 <syscalls>
    80002b76:	97ba                	add	a5,a5,a4
    80002b78:	639c                	ld	a5,0(a5)
    80002b7a:	c789                	beqz	a5,80002b84 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b7c:	9782                	jalr	a5
    80002b7e:	06a93823          	sd	a0,112(s2)
    80002b82:	a839                	j	80002ba0 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b84:	15848613          	addi	a2,s1,344
    80002b88:	588c                	lw	a1,48(s1)
    80002b8a:	00006517          	auipc	a0,0x6
    80002b8e:	88e50513          	addi	a0,a0,-1906 # 80008418 <states.0+0x150>
    80002b92:	ffffe097          	auipc	ra,0xffffe
    80002b96:	9f6080e7          	jalr	-1546(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b9a:	6cbc                	ld	a5,88(s1)
    80002b9c:	577d                	li	a4,-1
    80002b9e:	fbb8                	sd	a4,112(a5)
  }
}
    80002ba0:	60e2                	ld	ra,24(sp)
    80002ba2:	6442                	ld	s0,16(sp)
    80002ba4:	64a2                	ld	s1,8(sp)
    80002ba6:	6902                	ld	s2,0(sp)
    80002ba8:	6105                	addi	sp,sp,32
    80002baa:	8082                	ret

0000000080002bac <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bac:	1101                	addi	sp,sp,-32
    80002bae:	ec06                	sd	ra,24(sp)
    80002bb0:	e822                	sd	s0,16(sp)
    80002bb2:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bb4:	fec40593          	addi	a1,s0,-20
    80002bb8:	4501                	li	a0,0
    80002bba:	00000097          	auipc	ra,0x0
    80002bbe:	f0e080e7          	jalr	-242(ra) # 80002ac8 <argint>
  exit(n);
    80002bc2:	fec42503          	lw	a0,-20(s0)
    80002bc6:	fffff097          	auipc	ra,0xfffff
    80002bca:	5ca080e7          	jalr	1482(ra) # 80002190 <exit>
  return 0;  // not reached
}
    80002bce:	4501                	li	a0,0
    80002bd0:	60e2                	ld	ra,24(sp)
    80002bd2:	6442                	ld	s0,16(sp)
    80002bd4:	6105                	addi	sp,sp,32
    80002bd6:	8082                	ret

0000000080002bd8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bd8:	1141                	addi	sp,sp,-16
    80002bda:	e406                	sd	ra,8(sp)
    80002bdc:	e022                	sd	s0,0(sp)
    80002bde:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002be0:	fffff097          	auipc	ra,0xfffff
    80002be4:	dd4080e7          	jalr	-556(ra) # 800019b4 <myproc>
}
    80002be8:	5908                	lw	a0,48(a0)
    80002bea:	60a2                	ld	ra,8(sp)
    80002bec:	6402                	ld	s0,0(sp)
    80002bee:	0141                	addi	sp,sp,16
    80002bf0:	8082                	ret

0000000080002bf2 <sys_fork>:

uint64
sys_fork(void)
{
    80002bf2:	1141                	addi	sp,sp,-16
    80002bf4:	e406                	sd	ra,8(sp)
    80002bf6:	e022                	sd	s0,0(sp)
    80002bf8:	0800                	addi	s0,sp,16
  return fork();
    80002bfa:	fffff097          	auipc	ra,0xfffff
    80002bfe:	170080e7          	jalr	368(ra) # 80001d6a <fork>
}
    80002c02:	60a2                	ld	ra,8(sp)
    80002c04:	6402                	ld	s0,0(sp)
    80002c06:	0141                	addi	sp,sp,16
    80002c08:	8082                	ret

0000000080002c0a <sys_wait>:

uint64
sys_wait(void)
{
    80002c0a:	1101                	addi	sp,sp,-32
    80002c0c:	ec06                	sd	ra,24(sp)
    80002c0e:	e822                	sd	s0,16(sp)
    80002c10:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c12:	fe840593          	addi	a1,s0,-24
    80002c16:	4501                	li	a0,0
    80002c18:	00000097          	auipc	ra,0x0
    80002c1c:	ed0080e7          	jalr	-304(ra) # 80002ae8 <argaddr>
  return wait(p);
    80002c20:	fe843503          	ld	a0,-24(s0)
    80002c24:	fffff097          	auipc	ra,0xfffff
    80002c28:	712080e7          	jalr	1810(ra) # 80002336 <wait>
}
    80002c2c:	60e2                	ld	ra,24(sp)
    80002c2e:	6442                	ld	s0,16(sp)
    80002c30:	6105                	addi	sp,sp,32
    80002c32:	8082                	ret

0000000080002c34 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c34:	7179                	addi	sp,sp,-48
    80002c36:	f406                	sd	ra,40(sp)
    80002c38:	f022                	sd	s0,32(sp)
    80002c3a:	ec26                	sd	s1,24(sp)
    80002c3c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c3e:	fdc40593          	addi	a1,s0,-36
    80002c42:	4501                	li	a0,0
    80002c44:	00000097          	auipc	ra,0x0
    80002c48:	e84080e7          	jalr	-380(ra) # 80002ac8 <argint>
  addr = myproc()->sz;
    80002c4c:	fffff097          	auipc	ra,0xfffff
    80002c50:	d68080e7          	jalr	-664(ra) # 800019b4 <myproc>
    80002c54:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c56:	fdc42503          	lw	a0,-36(s0)
    80002c5a:	fffff097          	auipc	ra,0xfffff
    80002c5e:	0b4080e7          	jalr	180(ra) # 80001d0e <growproc>
    80002c62:	00054863          	bltz	a0,80002c72 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002c66:	8526                	mv	a0,s1
    80002c68:	70a2                	ld	ra,40(sp)
    80002c6a:	7402                	ld	s0,32(sp)
    80002c6c:	64e2                	ld	s1,24(sp)
    80002c6e:	6145                	addi	sp,sp,48
    80002c70:	8082                	ret
    return -1;
    80002c72:	54fd                	li	s1,-1
    80002c74:	bfcd                	j	80002c66 <sys_sbrk+0x32>

0000000080002c76 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c76:	7139                	addi	sp,sp,-64
    80002c78:	fc06                	sd	ra,56(sp)
    80002c7a:	f822                	sd	s0,48(sp)
    80002c7c:	f426                	sd	s1,40(sp)
    80002c7e:	f04a                	sd	s2,32(sp)
    80002c80:	ec4e                	sd	s3,24(sp)
    80002c82:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c84:	fcc40593          	addi	a1,s0,-52
    80002c88:	4501                	li	a0,0
    80002c8a:	00000097          	auipc	ra,0x0
    80002c8e:	e3e080e7          	jalr	-450(ra) # 80002ac8 <argint>
  acquire(&tickslock);
    80002c92:	00014517          	auipc	a0,0x14
    80002c96:	d0e50513          	addi	a0,a0,-754 # 800169a0 <tickslock>
    80002c9a:	ffffe097          	auipc	ra,0xffffe
    80002c9e:	f3c080e7          	jalr	-196(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002ca2:	00006917          	auipc	s2,0x6
    80002ca6:	c5e92903          	lw	s2,-930(s2) # 80008900 <ticks>
  while(ticks - ticks0 < n){
    80002caa:	fcc42783          	lw	a5,-52(s0)
    80002cae:	cf9d                	beqz	a5,80002cec <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cb0:	00014997          	auipc	s3,0x14
    80002cb4:	cf098993          	addi	s3,s3,-784 # 800169a0 <tickslock>
    80002cb8:	00006497          	auipc	s1,0x6
    80002cbc:	c4848493          	addi	s1,s1,-952 # 80008900 <ticks>
    if(killed(myproc())){
    80002cc0:	fffff097          	auipc	ra,0xfffff
    80002cc4:	cf4080e7          	jalr	-780(ra) # 800019b4 <myproc>
    80002cc8:	fffff097          	auipc	ra,0xfffff
    80002ccc:	63c080e7          	jalr	1596(ra) # 80002304 <killed>
    80002cd0:	ed15                	bnez	a0,80002d0c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002cd2:	85ce                	mv	a1,s3
    80002cd4:	8526                	mv	a0,s1
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	386080e7          	jalr	902(ra) # 8000205c <sleep>
  while(ticks - ticks0 < n){
    80002cde:	409c                	lw	a5,0(s1)
    80002ce0:	412787bb          	subw	a5,a5,s2
    80002ce4:	fcc42703          	lw	a4,-52(s0)
    80002ce8:	fce7ece3          	bltu	a5,a4,80002cc0 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002cec:	00014517          	auipc	a0,0x14
    80002cf0:	cb450513          	addi	a0,a0,-844 # 800169a0 <tickslock>
    80002cf4:	ffffe097          	auipc	ra,0xffffe
    80002cf8:	f96080e7          	jalr	-106(ra) # 80000c8a <release>
  return 0;
    80002cfc:	4501                	li	a0,0
}
    80002cfe:	70e2                	ld	ra,56(sp)
    80002d00:	7442                	ld	s0,48(sp)
    80002d02:	74a2                	ld	s1,40(sp)
    80002d04:	7902                	ld	s2,32(sp)
    80002d06:	69e2                	ld	s3,24(sp)
    80002d08:	6121                	addi	sp,sp,64
    80002d0a:	8082                	ret
      release(&tickslock);
    80002d0c:	00014517          	auipc	a0,0x14
    80002d10:	c9450513          	addi	a0,a0,-876 # 800169a0 <tickslock>
    80002d14:	ffffe097          	auipc	ra,0xffffe
    80002d18:	f76080e7          	jalr	-138(ra) # 80000c8a <release>
      return -1;
    80002d1c:	557d                	li	a0,-1
    80002d1e:	b7c5                	j	80002cfe <sys_sleep+0x88>

0000000080002d20 <sys_kill>:

uint64
sys_kill(void)
{
    80002d20:	1101                	addi	sp,sp,-32
    80002d22:	ec06                	sd	ra,24(sp)
    80002d24:	e822                	sd	s0,16(sp)
    80002d26:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d28:	fec40593          	addi	a1,s0,-20
    80002d2c:	4501                	li	a0,0
    80002d2e:	00000097          	auipc	ra,0x0
    80002d32:	d9a080e7          	jalr	-614(ra) # 80002ac8 <argint>
  return kill(pid);
    80002d36:	fec42503          	lw	a0,-20(s0)
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	52c080e7          	jalr	1324(ra) # 80002266 <kill>
}
    80002d42:	60e2                	ld	ra,24(sp)
    80002d44:	6442                	ld	s0,16(sp)
    80002d46:	6105                	addi	sp,sp,32
    80002d48:	8082                	ret

0000000080002d4a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d4a:	1101                	addi	sp,sp,-32
    80002d4c:	ec06                	sd	ra,24(sp)
    80002d4e:	e822                	sd	s0,16(sp)
    80002d50:	e426                	sd	s1,8(sp)
    80002d52:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d54:	00014517          	auipc	a0,0x14
    80002d58:	c4c50513          	addi	a0,a0,-948 # 800169a0 <tickslock>
    80002d5c:	ffffe097          	auipc	ra,0xffffe
    80002d60:	e7a080e7          	jalr	-390(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002d64:	00006497          	auipc	s1,0x6
    80002d68:	b9c4a483          	lw	s1,-1124(s1) # 80008900 <ticks>
  release(&tickslock);
    80002d6c:	00014517          	auipc	a0,0x14
    80002d70:	c3450513          	addi	a0,a0,-972 # 800169a0 <tickslock>
    80002d74:	ffffe097          	auipc	ra,0xffffe
    80002d78:	f16080e7          	jalr	-234(ra) # 80000c8a <release>
  return xticks;
}
    80002d7c:	02049513          	slli	a0,s1,0x20
    80002d80:	9101                	srli	a0,a0,0x20
    80002d82:	60e2                	ld	ra,24(sp)
    80002d84:	6442                	ld	s0,16(sp)
    80002d86:	64a2                	ld	s1,8(sp)
    80002d88:	6105                	addi	sp,sp,32
    80002d8a:	8082                	ret

0000000080002d8c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d8c:	7179                	addi	sp,sp,-48
    80002d8e:	f406                	sd	ra,40(sp)
    80002d90:	f022                	sd	s0,32(sp)
    80002d92:	ec26                	sd	s1,24(sp)
    80002d94:	e84a                	sd	s2,16(sp)
    80002d96:	e44e                	sd	s3,8(sp)
    80002d98:	e052                	sd	s4,0(sp)
    80002d9a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d9c:	00005597          	auipc	a1,0x5
    80002da0:	78458593          	addi	a1,a1,1924 # 80008520 <syscalls+0xd0>
    80002da4:	00014517          	auipc	a0,0x14
    80002da8:	c1450513          	addi	a0,a0,-1004 # 800169b8 <bcache>
    80002dac:	ffffe097          	auipc	ra,0xffffe
    80002db0:	d9a080e7          	jalr	-614(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002db4:	0001c797          	auipc	a5,0x1c
    80002db8:	c0478793          	addi	a5,a5,-1020 # 8001e9b8 <bcache+0x8000>
    80002dbc:	0001c717          	auipc	a4,0x1c
    80002dc0:	e6470713          	addi	a4,a4,-412 # 8001ec20 <bcache+0x8268>
    80002dc4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002dc8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dcc:	00014497          	auipc	s1,0x14
    80002dd0:	c0448493          	addi	s1,s1,-1020 # 800169d0 <bcache+0x18>
    b->next = bcache.head.next;
    80002dd4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002dd6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002dd8:	00005a17          	auipc	s4,0x5
    80002ddc:	750a0a13          	addi	s4,s4,1872 # 80008528 <syscalls+0xd8>
    b->next = bcache.head.next;
    80002de0:	2b893783          	ld	a5,696(s2)
    80002de4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002de6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002dea:	85d2                	mv	a1,s4
    80002dec:	01048513          	addi	a0,s1,16
    80002df0:	00001097          	auipc	ra,0x1
    80002df4:	4c4080e7          	jalr	1220(ra) # 800042b4 <initsleeplock>
    bcache.head.next->prev = b;
    80002df8:	2b893783          	ld	a5,696(s2)
    80002dfc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002dfe:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e02:	45848493          	addi	s1,s1,1112
    80002e06:	fd349de3          	bne	s1,s3,80002de0 <binit+0x54>
  }
}
    80002e0a:	70a2                	ld	ra,40(sp)
    80002e0c:	7402                	ld	s0,32(sp)
    80002e0e:	64e2                	ld	s1,24(sp)
    80002e10:	6942                	ld	s2,16(sp)
    80002e12:	69a2                	ld	s3,8(sp)
    80002e14:	6a02                	ld	s4,0(sp)
    80002e16:	6145                	addi	sp,sp,48
    80002e18:	8082                	ret

0000000080002e1a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e1a:	7179                	addi	sp,sp,-48
    80002e1c:	f406                	sd	ra,40(sp)
    80002e1e:	f022                	sd	s0,32(sp)
    80002e20:	ec26                	sd	s1,24(sp)
    80002e22:	e84a                	sd	s2,16(sp)
    80002e24:	e44e                	sd	s3,8(sp)
    80002e26:	1800                	addi	s0,sp,48
    80002e28:	892a                	mv	s2,a0
    80002e2a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e2c:	00014517          	auipc	a0,0x14
    80002e30:	b8c50513          	addi	a0,a0,-1140 # 800169b8 <bcache>
    80002e34:	ffffe097          	auipc	ra,0xffffe
    80002e38:	da2080e7          	jalr	-606(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e3c:	0001c497          	auipc	s1,0x1c
    80002e40:	e344b483          	ld	s1,-460(s1) # 8001ec70 <bcache+0x82b8>
    80002e44:	0001c797          	auipc	a5,0x1c
    80002e48:	ddc78793          	addi	a5,a5,-548 # 8001ec20 <bcache+0x8268>
    80002e4c:	02f48f63          	beq	s1,a5,80002e8a <bread+0x70>
    80002e50:	873e                	mv	a4,a5
    80002e52:	a021                	j	80002e5a <bread+0x40>
    80002e54:	68a4                	ld	s1,80(s1)
    80002e56:	02e48a63          	beq	s1,a4,80002e8a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002e5a:	449c                	lw	a5,8(s1)
    80002e5c:	ff279ce3          	bne	a5,s2,80002e54 <bread+0x3a>
    80002e60:	44dc                	lw	a5,12(s1)
    80002e62:	ff3799e3          	bne	a5,s3,80002e54 <bread+0x3a>
      b->refcnt++;
    80002e66:	40bc                	lw	a5,64(s1)
    80002e68:	2785                	addiw	a5,a5,1
    80002e6a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e6c:	00014517          	auipc	a0,0x14
    80002e70:	b4c50513          	addi	a0,a0,-1204 # 800169b8 <bcache>
    80002e74:	ffffe097          	auipc	ra,0xffffe
    80002e78:	e16080e7          	jalr	-490(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002e7c:	01048513          	addi	a0,s1,16
    80002e80:	00001097          	auipc	ra,0x1
    80002e84:	46e080e7          	jalr	1134(ra) # 800042ee <acquiresleep>
      return b;
    80002e88:	a8b9                	j	80002ee6 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e8a:	0001c497          	auipc	s1,0x1c
    80002e8e:	dde4b483          	ld	s1,-546(s1) # 8001ec68 <bcache+0x82b0>
    80002e92:	0001c797          	auipc	a5,0x1c
    80002e96:	d8e78793          	addi	a5,a5,-626 # 8001ec20 <bcache+0x8268>
    80002e9a:	00f48863          	beq	s1,a5,80002eaa <bread+0x90>
    80002e9e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002ea0:	40bc                	lw	a5,64(s1)
    80002ea2:	cf81                	beqz	a5,80002eba <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ea4:	64a4                	ld	s1,72(s1)
    80002ea6:	fee49de3          	bne	s1,a4,80002ea0 <bread+0x86>
  panic("bget: no buffers");
    80002eaa:	00005517          	auipc	a0,0x5
    80002eae:	68650513          	addi	a0,a0,1670 # 80008530 <syscalls+0xe0>
    80002eb2:	ffffd097          	auipc	ra,0xffffd
    80002eb6:	68c080e7          	jalr	1676(ra) # 8000053e <panic>
      b->dev = dev;
    80002eba:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ebe:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ec2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ec6:	4785                	li	a5,1
    80002ec8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002eca:	00014517          	auipc	a0,0x14
    80002ece:	aee50513          	addi	a0,a0,-1298 # 800169b8 <bcache>
    80002ed2:	ffffe097          	auipc	ra,0xffffe
    80002ed6:	db8080e7          	jalr	-584(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002eda:	01048513          	addi	a0,s1,16
    80002ede:	00001097          	auipc	ra,0x1
    80002ee2:	410080e7          	jalr	1040(ra) # 800042ee <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ee6:	409c                	lw	a5,0(s1)
    80002ee8:	cb89                	beqz	a5,80002efa <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002eea:	8526                	mv	a0,s1
    80002eec:	70a2                	ld	ra,40(sp)
    80002eee:	7402                	ld	s0,32(sp)
    80002ef0:	64e2                	ld	s1,24(sp)
    80002ef2:	6942                	ld	s2,16(sp)
    80002ef4:	69a2                	ld	s3,8(sp)
    80002ef6:	6145                	addi	sp,sp,48
    80002ef8:	8082                	ret
    virtio_disk_rw(b, 0);
    80002efa:	4581                	li	a1,0
    80002efc:	8526                	mv	a0,s1
    80002efe:	00003097          	auipc	ra,0x3
    80002f02:	fd6080e7          	jalr	-42(ra) # 80005ed4 <virtio_disk_rw>
    b->valid = 1;
    80002f06:	4785                	li	a5,1
    80002f08:	c09c                	sw	a5,0(s1)
  return b;
    80002f0a:	b7c5                	j	80002eea <bread+0xd0>

0000000080002f0c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f0c:	1101                	addi	sp,sp,-32
    80002f0e:	ec06                	sd	ra,24(sp)
    80002f10:	e822                	sd	s0,16(sp)
    80002f12:	e426                	sd	s1,8(sp)
    80002f14:	1000                	addi	s0,sp,32
    80002f16:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f18:	0541                	addi	a0,a0,16
    80002f1a:	00001097          	auipc	ra,0x1
    80002f1e:	46e080e7          	jalr	1134(ra) # 80004388 <holdingsleep>
    80002f22:	cd01                	beqz	a0,80002f3a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f24:	4585                	li	a1,1
    80002f26:	8526                	mv	a0,s1
    80002f28:	00003097          	auipc	ra,0x3
    80002f2c:	fac080e7          	jalr	-84(ra) # 80005ed4 <virtio_disk_rw>
}
    80002f30:	60e2                	ld	ra,24(sp)
    80002f32:	6442                	ld	s0,16(sp)
    80002f34:	64a2                	ld	s1,8(sp)
    80002f36:	6105                	addi	sp,sp,32
    80002f38:	8082                	ret
    panic("bwrite");
    80002f3a:	00005517          	auipc	a0,0x5
    80002f3e:	60e50513          	addi	a0,a0,1550 # 80008548 <syscalls+0xf8>
    80002f42:	ffffd097          	auipc	ra,0xffffd
    80002f46:	5fc080e7          	jalr	1532(ra) # 8000053e <panic>

0000000080002f4a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f4a:	1101                	addi	sp,sp,-32
    80002f4c:	ec06                	sd	ra,24(sp)
    80002f4e:	e822                	sd	s0,16(sp)
    80002f50:	e426                	sd	s1,8(sp)
    80002f52:	e04a                	sd	s2,0(sp)
    80002f54:	1000                	addi	s0,sp,32
    80002f56:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f58:	01050913          	addi	s2,a0,16
    80002f5c:	854a                	mv	a0,s2
    80002f5e:	00001097          	auipc	ra,0x1
    80002f62:	42a080e7          	jalr	1066(ra) # 80004388 <holdingsleep>
    80002f66:	c92d                	beqz	a0,80002fd8 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002f68:	854a                	mv	a0,s2
    80002f6a:	00001097          	auipc	ra,0x1
    80002f6e:	3da080e7          	jalr	986(ra) # 80004344 <releasesleep>

  acquire(&bcache.lock);
    80002f72:	00014517          	auipc	a0,0x14
    80002f76:	a4650513          	addi	a0,a0,-1466 # 800169b8 <bcache>
    80002f7a:	ffffe097          	auipc	ra,0xffffe
    80002f7e:	c5c080e7          	jalr	-932(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80002f82:	40bc                	lw	a5,64(s1)
    80002f84:	37fd                	addiw	a5,a5,-1
    80002f86:	0007871b          	sext.w	a4,a5
    80002f8a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f8c:	eb05                	bnez	a4,80002fbc <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f8e:	68bc                	ld	a5,80(s1)
    80002f90:	64b8                	ld	a4,72(s1)
    80002f92:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002f94:	64bc                	ld	a5,72(s1)
    80002f96:	68b8                	ld	a4,80(s1)
    80002f98:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f9a:	0001c797          	auipc	a5,0x1c
    80002f9e:	a1e78793          	addi	a5,a5,-1506 # 8001e9b8 <bcache+0x8000>
    80002fa2:	2b87b703          	ld	a4,696(a5)
    80002fa6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002fa8:	0001c717          	auipc	a4,0x1c
    80002fac:	c7870713          	addi	a4,a4,-904 # 8001ec20 <bcache+0x8268>
    80002fb0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002fb2:	2b87b703          	ld	a4,696(a5)
    80002fb6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002fb8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002fbc:	00014517          	auipc	a0,0x14
    80002fc0:	9fc50513          	addi	a0,a0,-1540 # 800169b8 <bcache>
    80002fc4:	ffffe097          	auipc	ra,0xffffe
    80002fc8:	cc6080e7          	jalr	-826(ra) # 80000c8a <release>
}
    80002fcc:	60e2                	ld	ra,24(sp)
    80002fce:	6442                	ld	s0,16(sp)
    80002fd0:	64a2                	ld	s1,8(sp)
    80002fd2:	6902                	ld	s2,0(sp)
    80002fd4:	6105                	addi	sp,sp,32
    80002fd6:	8082                	ret
    panic("brelse");
    80002fd8:	00005517          	auipc	a0,0x5
    80002fdc:	57850513          	addi	a0,a0,1400 # 80008550 <syscalls+0x100>
    80002fe0:	ffffd097          	auipc	ra,0xffffd
    80002fe4:	55e080e7          	jalr	1374(ra) # 8000053e <panic>

0000000080002fe8 <bpin>:

void
bpin(struct buf *b) {
    80002fe8:	1101                	addi	sp,sp,-32
    80002fea:	ec06                	sd	ra,24(sp)
    80002fec:	e822                	sd	s0,16(sp)
    80002fee:	e426                	sd	s1,8(sp)
    80002ff0:	1000                	addi	s0,sp,32
    80002ff2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ff4:	00014517          	auipc	a0,0x14
    80002ff8:	9c450513          	addi	a0,a0,-1596 # 800169b8 <bcache>
    80002ffc:	ffffe097          	auipc	ra,0xffffe
    80003000:	bda080e7          	jalr	-1062(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003004:	40bc                	lw	a5,64(s1)
    80003006:	2785                	addiw	a5,a5,1
    80003008:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000300a:	00014517          	auipc	a0,0x14
    8000300e:	9ae50513          	addi	a0,a0,-1618 # 800169b8 <bcache>
    80003012:	ffffe097          	auipc	ra,0xffffe
    80003016:	c78080e7          	jalr	-904(ra) # 80000c8a <release>
}
    8000301a:	60e2                	ld	ra,24(sp)
    8000301c:	6442                	ld	s0,16(sp)
    8000301e:	64a2                	ld	s1,8(sp)
    80003020:	6105                	addi	sp,sp,32
    80003022:	8082                	ret

0000000080003024 <bunpin>:

void
bunpin(struct buf *b) {
    80003024:	1101                	addi	sp,sp,-32
    80003026:	ec06                	sd	ra,24(sp)
    80003028:	e822                	sd	s0,16(sp)
    8000302a:	e426                	sd	s1,8(sp)
    8000302c:	1000                	addi	s0,sp,32
    8000302e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003030:	00014517          	auipc	a0,0x14
    80003034:	98850513          	addi	a0,a0,-1656 # 800169b8 <bcache>
    80003038:	ffffe097          	auipc	ra,0xffffe
    8000303c:	b9e080e7          	jalr	-1122(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003040:	40bc                	lw	a5,64(s1)
    80003042:	37fd                	addiw	a5,a5,-1
    80003044:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003046:	00014517          	auipc	a0,0x14
    8000304a:	97250513          	addi	a0,a0,-1678 # 800169b8 <bcache>
    8000304e:	ffffe097          	auipc	ra,0xffffe
    80003052:	c3c080e7          	jalr	-964(ra) # 80000c8a <release>
}
    80003056:	60e2                	ld	ra,24(sp)
    80003058:	6442                	ld	s0,16(sp)
    8000305a:	64a2                	ld	s1,8(sp)
    8000305c:	6105                	addi	sp,sp,32
    8000305e:	8082                	ret

0000000080003060 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003060:	1101                	addi	sp,sp,-32
    80003062:	ec06                	sd	ra,24(sp)
    80003064:	e822                	sd	s0,16(sp)
    80003066:	e426                	sd	s1,8(sp)
    80003068:	e04a                	sd	s2,0(sp)
    8000306a:	1000                	addi	s0,sp,32
    8000306c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000306e:	00d5d59b          	srliw	a1,a1,0xd
    80003072:	0001c797          	auipc	a5,0x1c
    80003076:	0227a783          	lw	a5,34(a5) # 8001f094 <sb+0x1c>
    8000307a:	9dbd                	addw	a1,a1,a5
    8000307c:	00000097          	auipc	ra,0x0
    80003080:	d9e080e7          	jalr	-610(ra) # 80002e1a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003084:	0074f713          	andi	a4,s1,7
    80003088:	4785                	li	a5,1
    8000308a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000308e:	14ce                	slli	s1,s1,0x33
    80003090:	90d9                	srli	s1,s1,0x36
    80003092:	00950733          	add	a4,a0,s1
    80003096:	05874703          	lbu	a4,88(a4)
    8000309a:	00e7f6b3          	and	a3,a5,a4
    8000309e:	c69d                	beqz	a3,800030cc <bfree+0x6c>
    800030a0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030a2:	94aa                	add	s1,s1,a0
    800030a4:	fff7c793          	not	a5,a5
    800030a8:	8ff9                	and	a5,a5,a4
    800030aa:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800030ae:	00001097          	auipc	ra,0x1
    800030b2:	120080e7          	jalr	288(ra) # 800041ce <log_write>
  brelse(bp);
    800030b6:	854a                	mv	a0,s2
    800030b8:	00000097          	auipc	ra,0x0
    800030bc:	e92080e7          	jalr	-366(ra) # 80002f4a <brelse>
}
    800030c0:	60e2                	ld	ra,24(sp)
    800030c2:	6442                	ld	s0,16(sp)
    800030c4:	64a2                	ld	s1,8(sp)
    800030c6:	6902                	ld	s2,0(sp)
    800030c8:	6105                	addi	sp,sp,32
    800030ca:	8082                	ret
    panic("freeing free block");
    800030cc:	00005517          	auipc	a0,0x5
    800030d0:	48c50513          	addi	a0,a0,1164 # 80008558 <syscalls+0x108>
    800030d4:	ffffd097          	auipc	ra,0xffffd
    800030d8:	46a080e7          	jalr	1130(ra) # 8000053e <panic>

00000000800030dc <balloc>:
{
    800030dc:	711d                	addi	sp,sp,-96
    800030de:	ec86                	sd	ra,88(sp)
    800030e0:	e8a2                	sd	s0,80(sp)
    800030e2:	e4a6                	sd	s1,72(sp)
    800030e4:	e0ca                	sd	s2,64(sp)
    800030e6:	fc4e                	sd	s3,56(sp)
    800030e8:	f852                	sd	s4,48(sp)
    800030ea:	f456                	sd	s5,40(sp)
    800030ec:	f05a                	sd	s6,32(sp)
    800030ee:	ec5e                	sd	s7,24(sp)
    800030f0:	e862                	sd	s8,16(sp)
    800030f2:	e466                	sd	s9,8(sp)
    800030f4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800030f6:	0001c797          	auipc	a5,0x1c
    800030fa:	f867a783          	lw	a5,-122(a5) # 8001f07c <sb+0x4>
    800030fe:	10078163          	beqz	a5,80003200 <balloc+0x124>
    80003102:	8baa                	mv	s7,a0
    80003104:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003106:	0001cb17          	auipc	s6,0x1c
    8000310a:	f72b0b13          	addi	s6,s6,-142 # 8001f078 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000310e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003110:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003112:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003114:	6c89                	lui	s9,0x2
    80003116:	a061                	j	8000319e <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003118:	974a                	add	a4,a4,s2
    8000311a:	8fd5                	or	a5,a5,a3
    8000311c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003120:	854a                	mv	a0,s2
    80003122:	00001097          	auipc	ra,0x1
    80003126:	0ac080e7          	jalr	172(ra) # 800041ce <log_write>
        brelse(bp);
    8000312a:	854a                	mv	a0,s2
    8000312c:	00000097          	auipc	ra,0x0
    80003130:	e1e080e7          	jalr	-482(ra) # 80002f4a <brelse>
  bp = bread(dev, bno);
    80003134:	85a6                	mv	a1,s1
    80003136:	855e                	mv	a0,s7
    80003138:	00000097          	auipc	ra,0x0
    8000313c:	ce2080e7          	jalr	-798(ra) # 80002e1a <bread>
    80003140:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003142:	40000613          	li	a2,1024
    80003146:	4581                	li	a1,0
    80003148:	05850513          	addi	a0,a0,88
    8000314c:	ffffe097          	auipc	ra,0xffffe
    80003150:	b86080e7          	jalr	-1146(ra) # 80000cd2 <memset>
  log_write(bp);
    80003154:	854a                	mv	a0,s2
    80003156:	00001097          	auipc	ra,0x1
    8000315a:	078080e7          	jalr	120(ra) # 800041ce <log_write>
  brelse(bp);
    8000315e:	854a                	mv	a0,s2
    80003160:	00000097          	auipc	ra,0x0
    80003164:	dea080e7          	jalr	-534(ra) # 80002f4a <brelse>
}
    80003168:	8526                	mv	a0,s1
    8000316a:	60e6                	ld	ra,88(sp)
    8000316c:	6446                	ld	s0,80(sp)
    8000316e:	64a6                	ld	s1,72(sp)
    80003170:	6906                	ld	s2,64(sp)
    80003172:	79e2                	ld	s3,56(sp)
    80003174:	7a42                	ld	s4,48(sp)
    80003176:	7aa2                	ld	s5,40(sp)
    80003178:	7b02                	ld	s6,32(sp)
    8000317a:	6be2                	ld	s7,24(sp)
    8000317c:	6c42                	ld	s8,16(sp)
    8000317e:	6ca2                	ld	s9,8(sp)
    80003180:	6125                	addi	sp,sp,96
    80003182:	8082                	ret
    brelse(bp);
    80003184:	854a                	mv	a0,s2
    80003186:	00000097          	auipc	ra,0x0
    8000318a:	dc4080e7          	jalr	-572(ra) # 80002f4a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000318e:	015c87bb          	addw	a5,s9,s5
    80003192:	00078a9b          	sext.w	s5,a5
    80003196:	004b2703          	lw	a4,4(s6)
    8000319a:	06eaf363          	bgeu	s5,a4,80003200 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000319e:	41fad79b          	sraiw	a5,s5,0x1f
    800031a2:	0137d79b          	srliw	a5,a5,0x13
    800031a6:	015787bb          	addw	a5,a5,s5
    800031aa:	40d7d79b          	sraiw	a5,a5,0xd
    800031ae:	01cb2583          	lw	a1,28(s6)
    800031b2:	9dbd                	addw	a1,a1,a5
    800031b4:	855e                	mv	a0,s7
    800031b6:	00000097          	auipc	ra,0x0
    800031ba:	c64080e7          	jalr	-924(ra) # 80002e1a <bread>
    800031be:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031c0:	004b2503          	lw	a0,4(s6)
    800031c4:	000a849b          	sext.w	s1,s5
    800031c8:	8662                	mv	a2,s8
    800031ca:	faa4fde3          	bgeu	s1,a0,80003184 <balloc+0xa8>
      m = 1 << (bi % 8);
    800031ce:	41f6579b          	sraiw	a5,a2,0x1f
    800031d2:	01d7d69b          	srliw	a3,a5,0x1d
    800031d6:	00c6873b          	addw	a4,a3,a2
    800031da:	00777793          	andi	a5,a4,7
    800031de:	9f95                	subw	a5,a5,a3
    800031e0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031e4:	4037571b          	sraiw	a4,a4,0x3
    800031e8:	00e906b3          	add	a3,s2,a4
    800031ec:	0586c683          	lbu	a3,88(a3)
    800031f0:	00d7f5b3          	and	a1,a5,a3
    800031f4:	d195                	beqz	a1,80003118 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031f6:	2605                	addiw	a2,a2,1
    800031f8:	2485                	addiw	s1,s1,1
    800031fa:	fd4618e3          	bne	a2,s4,800031ca <balloc+0xee>
    800031fe:	b759                	j	80003184 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003200:	00005517          	auipc	a0,0x5
    80003204:	37050513          	addi	a0,a0,880 # 80008570 <syscalls+0x120>
    80003208:	ffffd097          	auipc	ra,0xffffd
    8000320c:	380080e7          	jalr	896(ra) # 80000588 <printf>
  return 0;
    80003210:	4481                	li	s1,0
    80003212:	bf99                	j	80003168 <balloc+0x8c>

0000000080003214 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003214:	7179                	addi	sp,sp,-48
    80003216:	f406                	sd	ra,40(sp)
    80003218:	f022                	sd	s0,32(sp)
    8000321a:	ec26                	sd	s1,24(sp)
    8000321c:	e84a                	sd	s2,16(sp)
    8000321e:	e44e                	sd	s3,8(sp)
    80003220:	e052                	sd	s4,0(sp)
    80003222:	1800                	addi	s0,sp,48
    80003224:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003226:	47ad                	li	a5,11
    80003228:	02b7e763          	bltu	a5,a1,80003256 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000322c:	02059493          	slli	s1,a1,0x20
    80003230:	9081                	srli	s1,s1,0x20
    80003232:	048a                	slli	s1,s1,0x2
    80003234:	94aa                	add	s1,s1,a0
    80003236:	0504a903          	lw	s2,80(s1)
    8000323a:	06091e63          	bnez	s2,800032b6 <bmap+0xa2>
      addr = balloc(ip->dev);
    8000323e:	4108                	lw	a0,0(a0)
    80003240:	00000097          	auipc	ra,0x0
    80003244:	e9c080e7          	jalr	-356(ra) # 800030dc <balloc>
    80003248:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000324c:	06090563          	beqz	s2,800032b6 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003250:	0524a823          	sw	s2,80(s1)
    80003254:	a08d                	j	800032b6 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003256:	ff45849b          	addiw	s1,a1,-12
    8000325a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000325e:	0ff00793          	li	a5,255
    80003262:	08e7e563          	bltu	a5,a4,800032ec <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003266:	08052903          	lw	s2,128(a0)
    8000326a:	00091d63          	bnez	s2,80003284 <bmap+0x70>
      addr = balloc(ip->dev);
    8000326e:	4108                	lw	a0,0(a0)
    80003270:	00000097          	auipc	ra,0x0
    80003274:	e6c080e7          	jalr	-404(ra) # 800030dc <balloc>
    80003278:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000327c:	02090d63          	beqz	s2,800032b6 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003280:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003284:	85ca                	mv	a1,s2
    80003286:	0009a503          	lw	a0,0(s3)
    8000328a:	00000097          	auipc	ra,0x0
    8000328e:	b90080e7          	jalr	-1136(ra) # 80002e1a <bread>
    80003292:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003294:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003298:	02049593          	slli	a1,s1,0x20
    8000329c:	9181                	srli	a1,a1,0x20
    8000329e:	058a                	slli	a1,a1,0x2
    800032a0:	00b784b3          	add	s1,a5,a1
    800032a4:	0004a903          	lw	s2,0(s1)
    800032a8:	02090063          	beqz	s2,800032c8 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800032ac:	8552                	mv	a0,s4
    800032ae:	00000097          	auipc	ra,0x0
    800032b2:	c9c080e7          	jalr	-868(ra) # 80002f4a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032b6:	854a                	mv	a0,s2
    800032b8:	70a2                	ld	ra,40(sp)
    800032ba:	7402                	ld	s0,32(sp)
    800032bc:	64e2                	ld	s1,24(sp)
    800032be:	6942                	ld	s2,16(sp)
    800032c0:	69a2                	ld	s3,8(sp)
    800032c2:	6a02                	ld	s4,0(sp)
    800032c4:	6145                	addi	sp,sp,48
    800032c6:	8082                	ret
      addr = balloc(ip->dev);
    800032c8:	0009a503          	lw	a0,0(s3)
    800032cc:	00000097          	auipc	ra,0x0
    800032d0:	e10080e7          	jalr	-496(ra) # 800030dc <balloc>
    800032d4:	0005091b          	sext.w	s2,a0
      if(addr){
    800032d8:	fc090ae3          	beqz	s2,800032ac <bmap+0x98>
        a[bn] = addr;
    800032dc:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800032e0:	8552                	mv	a0,s4
    800032e2:	00001097          	auipc	ra,0x1
    800032e6:	eec080e7          	jalr	-276(ra) # 800041ce <log_write>
    800032ea:	b7c9                	j	800032ac <bmap+0x98>
  panic("bmap: out of range");
    800032ec:	00005517          	auipc	a0,0x5
    800032f0:	29c50513          	addi	a0,a0,668 # 80008588 <syscalls+0x138>
    800032f4:	ffffd097          	auipc	ra,0xffffd
    800032f8:	24a080e7          	jalr	586(ra) # 8000053e <panic>

00000000800032fc <iget>:
{
    800032fc:	7179                	addi	sp,sp,-48
    800032fe:	f406                	sd	ra,40(sp)
    80003300:	f022                	sd	s0,32(sp)
    80003302:	ec26                	sd	s1,24(sp)
    80003304:	e84a                	sd	s2,16(sp)
    80003306:	e44e                	sd	s3,8(sp)
    80003308:	e052                	sd	s4,0(sp)
    8000330a:	1800                	addi	s0,sp,48
    8000330c:	89aa                	mv	s3,a0
    8000330e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003310:	0001c517          	auipc	a0,0x1c
    80003314:	d8850513          	addi	a0,a0,-632 # 8001f098 <itable>
    80003318:	ffffe097          	auipc	ra,0xffffe
    8000331c:	8be080e7          	jalr	-1858(ra) # 80000bd6 <acquire>
  empty = 0;
    80003320:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003322:	0001c497          	auipc	s1,0x1c
    80003326:	d8e48493          	addi	s1,s1,-626 # 8001f0b0 <itable+0x18>
    8000332a:	0001e697          	auipc	a3,0x1e
    8000332e:	81668693          	addi	a3,a3,-2026 # 80020b40 <log>
    80003332:	a039                	j	80003340 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003334:	02090b63          	beqz	s2,8000336a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003338:	08848493          	addi	s1,s1,136
    8000333c:	02d48a63          	beq	s1,a3,80003370 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003340:	449c                	lw	a5,8(s1)
    80003342:	fef059e3          	blez	a5,80003334 <iget+0x38>
    80003346:	4098                	lw	a4,0(s1)
    80003348:	ff3716e3          	bne	a4,s3,80003334 <iget+0x38>
    8000334c:	40d8                	lw	a4,4(s1)
    8000334e:	ff4713e3          	bne	a4,s4,80003334 <iget+0x38>
      ip->ref++;
    80003352:	2785                	addiw	a5,a5,1
    80003354:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003356:	0001c517          	auipc	a0,0x1c
    8000335a:	d4250513          	addi	a0,a0,-702 # 8001f098 <itable>
    8000335e:	ffffe097          	auipc	ra,0xffffe
    80003362:	92c080e7          	jalr	-1748(ra) # 80000c8a <release>
      return ip;
    80003366:	8926                	mv	s2,s1
    80003368:	a03d                	j	80003396 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000336a:	f7f9                	bnez	a5,80003338 <iget+0x3c>
    8000336c:	8926                	mv	s2,s1
    8000336e:	b7e9                	j	80003338 <iget+0x3c>
  if(empty == 0)
    80003370:	02090c63          	beqz	s2,800033a8 <iget+0xac>
  ip->dev = dev;
    80003374:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003378:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000337c:	4785                	li	a5,1
    8000337e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003382:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003386:	0001c517          	auipc	a0,0x1c
    8000338a:	d1250513          	addi	a0,a0,-750 # 8001f098 <itable>
    8000338e:	ffffe097          	auipc	ra,0xffffe
    80003392:	8fc080e7          	jalr	-1796(ra) # 80000c8a <release>
}
    80003396:	854a                	mv	a0,s2
    80003398:	70a2                	ld	ra,40(sp)
    8000339a:	7402                	ld	s0,32(sp)
    8000339c:	64e2                	ld	s1,24(sp)
    8000339e:	6942                	ld	s2,16(sp)
    800033a0:	69a2                	ld	s3,8(sp)
    800033a2:	6a02                	ld	s4,0(sp)
    800033a4:	6145                	addi	sp,sp,48
    800033a6:	8082                	ret
    panic("iget: no inodes");
    800033a8:	00005517          	auipc	a0,0x5
    800033ac:	1f850513          	addi	a0,a0,504 # 800085a0 <syscalls+0x150>
    800033b0:	ffffd097          	auipc	ra,0xffffd
    800033b4:	18e080e7          	jalr	398(ra) # 8000053e <panic>

00000000800033b8 <fsinit>:
fsinit(int dev) {
    800033b8:	7179                	addi	sp,sp,-48
    800033ba:	f406                	sd	ra,40(sp)
    800033bc:	f022                	sd	s0,32(sp)
    800033be:	ec26                	sd	s1,24(sp)
    800033c0:	e84a                	sd	s2,16(sp)
    800033c2:	e44e                	sd	s3,8(sp)
    800033c4:	1800                	addi	s0,sp,48
    800033c6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800033c8:	4585                	li	a1,1
    800033ca:	00000097          	auipc	ra,0x0
    800033ce:	a50080e7          	jalr	-1456(ra) # 80002e1a <bread>
    800033d2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800033d4:	0001c997          	auipc	s3,0x1c
    800033d8:	ca498993          	addi	s3,s3,-860 # 8001f078 <sb>
    800033dc:	02000613          	li	a2,32
    800033e0:	05850593          	addi	a1,a0,88
    800033e4:	854e                	mv	a0,s3
    800033e6:	ffffe097          	auipc	ra,0xffffe
    800033ea:	948080e7          	jalr	-1720(ra) # 80000d2e <memmove>
  brelse(bp);
    800033ee:	8526                	mv	a0,s1
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	b5a080e7          	jalr	-1190(ra) # 80002f4a <brelse>
  if(sb.magic != FSMAGIC)
    800033f8:	0009a703          	lw	a4,0(s3)
    800033fc:	102037b7          	lui	a5,0x10203
    80003400:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003404:	02f71263          	bne	a4,a5,80003428 <fsinit+0x70>
  initlog(dev, &sb);
    80003408:	0001c597          	auipc	a1,0x1c
    8000340c:	c7058593          	addi	a1,a1,-912 # 8001f078 <sb>
    80003410:	854a                	mv	a0,s2
    80003412:	00001097          	auipc	ra,0x1
    80003416:	b40080e7          	jalr	-1216(ra) # 80003f52 <initlog>
}
    8000341a:	70a2                	ld	ra,40(sp)
    8000341c:	7402                	ld	s0,32(sp)
    8000341e:	64e2                	ld	s1,24(sp)
    80003420:	6942                	ld	s2,16(sp)
    80003422:	69a2                	ld	s3,8(sp)
    80003424:	6145                	addi	sp,sp,48
    80003426:	8082                	ret
    panic("invalid file system");
    80003428:	00005517          	auipc	a0,0x5
    8000342c:	18850513          	addi	a0,a0,392 # 800085b0 <syscalls+0x160>
    80003430:	ffffd097          	auipc	ra,0xffffd
    80003434:	10e080e7          	jalr	270(ra) # 8000053e <panic>

0000000080003438 <iinit>:
{
    80003438:	7179                	addi	sp,sp,-48
    8000343a:	f406                	sd	ra,40(sp)
    8000343c:	f022                	sd	s0,32(sp)
    8000343e:	ec26                	sd	s1,24(sp)
    80003440:	e84a                	sd	s2,16(sp)
    80003442:	e44e                	sd	s3,8(sp)
    80003444:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003446:	00005597          	auipc	a1,0x5
    8000344a:	18258593          	addi	a1,a1,386 # 800085c8 <syscalls+0x178>
    8000344e:	0001c517          	auipc	a0,0x1c
    80003452:	c4a50513          	addi	a0,a0,-950 # 8001f098 <itable>
    80003456:	ffffd097          	auipc	ra,0xffffd
    8000345a:	6f0080e7          	jalr	1776(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000345e:	0001c497          	auipc	s1,0x1c
    80003462:	c6248493          	addi	s1,s1,-926 # 8001f0c0 <itable+0x28>
    80003466:	0001d997          	auipc	s3,0x1d
    8000346a:	6ea98993          	addi	s3,s3,1770 # 80020b50 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000346e:	00005917          	auipc	s2,0x5
    80003472:	16290913          	addi	s2,s2,354 # 800085d0 <syscalls+0x180>
    80003476:	85ca                	mv	a1,s2
    80003478:	8526                	mv	a0,s1
    8000347a:	00001097          	auipc	ra,0x1
    8000347e:	e3a080e7          	jalr	-454(ra) # 800042b4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003482:	08848493          	addi	s1,s1,136
    80003486:	ff3498e3          	bne	s1,s3,80003476 <iinit+0x3e>
}
    8000348a:	70a2                	ld	ra,40(sp)
    8000348c:	7402                	ld	s0,32(sp)
    8000348e:	64e2                	ld	s1,24(sp)
    80003490:	6942                	ld	s2,16(sp)
    80003492:	69a2                	ld	s3,8(sp)
    80003494:	6145                	addi	sp,sp,48
    80003496:	8082                	ret

0000000080003498 <ialloc>:
{
    80003498:	715d                	addi	sp,sp,-80
    8000349a:	e486                	sd	ra,72(sp)
    8000349c:	e0a2                	sd	s0,64(sp)
    8000349e:	fc26                	sd	s1,56(sp)
    800034a0:	f84a                	sd	s2,48(sp)
    800034a2:	f44e                	sd	s3,40(sp)
    800034a4:	f052                	sd	s4,32(sp)
    800034a6:	ec56                	sd	s5,24(sp)
    800034a8:	e85a                	sd	s6,16(sp)
    800034aa:	e45e                	sd	s7,8(sp)
    800034ac:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800034ae:	0001c717          	auipc	a4,0x1c
    800034b2:	bd672703          	lw	a4,-1066(a4) # 8001f084 <sb+0xc>
    800034b6:	4785                	li	a5,1
    800034b8:	04e7fa63          	bgeu	a5,a4,8000350c <ialloc+0x74>
    800034bc:	8aaa                	mv	s5,a0
    800034be:	8bae                	mv	s7,a1
    800034c0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800034c2:	0001ca17          	auipc	s4,0x1c
    800034c6:	bb6a0a13          	addi	s4,s4,-1098 # 8001f078 <sb>
    800034ca:	00048b1b          	sext.w	s6,s1
    800034ce:	0044d793          	srli	a5,s1,0x4
    800034d2:	018a2583          	lw	a1,24(s4)
    800034d6:	9dbd                	addw	a1,a1,a5
    800034d8:	8556                	mv	a0,s5
    800034da:	00000097          	auipc	ra,0x0
    800034de:	940080e7          	jalr	-1728(ra) # 80002e1a <bread>
    800034e2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800034e4:	05850993          	addi	s3,a0,88
    800034e8:	00f4f793          	andi	a5,s1,15
    800034ec:	079a                	slli	a5,a5,0x6
    800034ee:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800034f0:	00099783          	lh	a5,0(s3)
    800034f4:	c3a1                	beqz	a5,80003534 <ialloc+0x9c>
    brelse(bp);
    800034f6:	00000097          	auipc	ra,0x0
    800034fa:	a54080e7          	jalr	-1452(ra) # 80002f4a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800034fe:	0485                	addi	s1,s1,1
    80003500:	00ca2703          	lw	a4,12(s4)
    80003504:	0004879b          	sext.w	a5,s1
    80003508:	fce7e1e3          	bltu	a5,a4,800034ca <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000350c:	00005517          	auipc	a0,0x5
    80003510:	0cc50513          	addi	a0,a0,204 # 800085d8 <syscalls+0x188>
    80003514:	ffffd097          	auipc	ra,0xffffd
    80003518:	074080e7          	jalr	116(ra) # 80000588 <printf>
  return 0;
    8000351c:	4501                	li	a0,0
}
    8000351e:	60a6                	ld	ra,72(sp)
    80003520:	6406                	ld	s0,64(sp)
    80003522:	74e2                	ld	s1,56(sp)
    80003524:	7942                	ld	s2,48(sp)
    80003526:	79a2                	ld	s3,40(sp)
    80003528:	7a02                	ld	s4,32(sp)
    8000352a:	6ae2                	ld	s5,24(sp)
    8000352c:	6b42                	ld	s6,16(sp)
    8000352e:	6ba2                	ld	s7,8(sp)
    80003530:	6161                	addi	sp,sp,80
    80003532:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003534:	04000613          	li	a2,64
    80003538:	4581                	li	a1,0
    8000353a:	854e                	mv	a0,s3
    8000353c:	ffffd097          	auipc	ra,0xffffd
    80003540:	796080e7          	jalr	1942(ra) # 80000cd2 <memset>
      dip->type = type;
    80003544:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003548:	854a                	mv	a0,s2
    8000354a:	00001097          	auipc	ra,0x1
    8000354e:	c84080e7          	jalr	-892(ra) # 800041ce <log_write>
      brelse(bp);
    80003552:	854a                	mv	a0,s2
    80003554:	00000097          	auipc	ra,0x0
    80003558:	9f6080e7          	jalr	-1546(ra) # 80002f4a <brelse>
      return iget(dev, inum);
    8000355c:	85da                	mv	a1,s6
    8000355e:	8556                	mv	a0,s5
    80003560:	00000097          	auipc	ra,0x0
    80003564:	d9c080e7          	jalr	-612(ra) # 800032fc <iget>
    80003568:	bf5d                	j	8000351e <ialloc+0x86>

000000008000356a <iupdate>:
{
    8000356a:	1101                	addi	sp,sp,-32
    8000356c:	ec06                	sd	ra,24(sp)
    8000356e:	e822                	sd	s0,16(sp)
    80003570:	e426                	sd	s1,8(sp)
    80003572:	e04a                	sd	s2,0(sp)
    80003574:	1000                	addi	s0,sp,32
    80003576:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003578:	415c                	lw	a5,4(a0)
    8000357a:	0047d79b          	srliw	a5,a5,0x4
    8000357e:	0001c597          	auipc	a1,0x1c
    80003582:	b125a583          	lw	a1,-1262(a1) # 8001f090 <sb+0x18>
    80003586:	9dbd                	addw	a1,a1,a5
    80003588:	4108                	lw	a0,0(a0)
    8000358a:	00000097          	auipc	ra,0x0
    8000358e:	890080e7          	jalr	-1904(ra) # 80002e1a <bread>
    80003592:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003594:	05850793          	addi	a5,a0,88
    80003598:	40c8                	lw	a0,4(s1)
    8000359a:	893d                	andi	a0,a0,15
    8000359c:	051a                	slli	a0,a0,0x6
    8000359e:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800035a0:	04449703          	lh	a4,68(s1)
    800035a4:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800035a8:	04649703          	lh	a4,70(s1)
    800035ac:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800035b0:	04849703          	lh	a4,72(s1)
    800035b4:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800035b8:	04a49703          	lh	a4,74(s1)
    800035bc:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800035c0:	44f8                	lw	a4,76(s1)
    800035c2:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800035c4:	03400613          	li	a2,52
    800035c8:	05048593          	addi	a1,s1,80
    800035cc:	0531                	addi	a0,a0,12
    800035ce:	ffffd097          	auipc	ra,0xffffd
    800035d2:	760080e7          	jalr	1888(ra) # 80000d2e <memmove>
  log_write(bp);
    800035d6:	854a                	mv	a0,s2
    800035d8:	00001097          	auipc	ra,0x1
    800035dc:	bf6080e7          	jalr	-1034(ra) # 800041ce <log_write>
  brelse(bp);
    800035e0:	854a                	mv	a0,s2
    800035e2:	00000097          	auipc	ra,0x0
    800035e6:	968080e7          	jalr	-1688(ra) # 80002f4a <brelse>
}
    800035ea:	60e2                	ld	ra,24(sp)
    800035ec:	6442                	ld	s0,16(sp)
    800035ee:	64a2                	ld	s1,8(sp)
    800035f0:	6902                	ld	s2,0(sp)
    800035f2:	6105                	addi	sp,sp,32
    800035f4:	8082                	ret

00000000800035f6 <idup>:
{
    800035f6:	1101                	addi	sp,sp,-32
    800035f8:	ec06                	sd	ra,24(sp)
    800035fa:	e822                	sd	s0,16(sp)
    800035fc:	e426                	sd	s1,8(sp)
    800035fe:	1000                	addi	s0,sp,32
    80003600:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003602:	0001c517          	auipc	a0,0x1c
    80003606:	a9650513          	addi	a0,a0,-1386 # 8001f098 <itable>
    8000360a:	ffffd097          	auipc	ra,0xffffd
    8000360e:	5cc080e7          	jalr	1484(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003612:	449c                	lw	a5,8(s1)
    80003614:	2785                	addiw	a5,a5,1
    80003616:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003618:	0001c517          	auipc	a0,0x1c
    8000361c:	a8050513          	addi	a0,a0,-1408 # 8001f098 <itable>
    80003620:	ffffd097          	auipc	ra,0xffffd
    80003624:	66a080e7          	jalr	1642(ra) # 80000c8a <release>
}
    80003628:	8526                	mv	a0,s1
    8000362a:	60e2                	ld	ra,24(sp)
    8000362c:	6442                	ld	s0,16(sp)
    8000362e:	64a2                	ld	s1,8(sp)
    80003630:	6105                	addi	sp,sp,32
    80003632:	8082                	ret

0000000080003634 <ilock>:
{
    80003634:	1101                	addi	sp,sp,-32
    80003636:	ec06                	sd	ra,24(sp)
    80003638:	e822                	sd	s0,16(sp)
    8000363a:	e426                	sd	s1,8(sp)
    8000363c:	e04a                	sd	s2,0(sp)
    8000363e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003640:	c115                	beqz	a0,80003664 <ilock+0x30>
    80003642:	84aa                	mv	s1,a0
    80003644:	451c                	lw	a5,8(a0)
    80003646:	00f05f63          	blez	a5,80003664 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000364a:	0541                	addi	a0,a0,16
    8000364c:	00001097          	auipc	ra,0x1
    80003650:	ca2080e7          	jalr	-862(ra) # 800042ee <acquiresleep>
  if(ip->valid == 0){
    80003654:	40bc                	lw	a5,64(s1)
    80003656:	cf99                	beqz	a5,80003674 <ilock+0x40>
}
    80003658:	60e2                	ld	ra,24(sp)
    8000365a:	6442                	ld	s0,16(sp)
    8000365c:	64a2                	ld	s1,8(sp)
    8000365e:	6902                	ld	s2,0(sp)
    80003660:	6105                	addi	sp,sp,32
    80003662:	8082                	ret
    panic("ilock");
    80003664:	00005517          	auipc	a0,0x5
    80003668:	f8c50513          	addi	a0,a0,-116 # 800085f0 <syscalls+0x1a0>
    8000366c:	ffffd097          	auipc	ra,0xffffd
    80003670:	ed2080e7          	jalr	-302(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003674:	40dc                	lw	a5,4(s1)
    80003676:	0047d79b          	srliw	a5,a5,0x4
    8000367a:	0001c597          	auipc	a1,0x1c
    8000367e:	a165a583          	lw	a1,-1514(a1) # 8001f090 <sb+0x18>
    80003682:	9dbd                	addw	a1,a1,a5
    80003684:	4088                	lw	a0,0(s1)
    80003686:	fffff097          	auipc	ra,0xfffff
    8000368a:	794080e7          	jalr	1940(ra) # 80002e1a <bread>
    8000368e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003690:	05850593          	addi	a1,a0,88
    80003694:	40dc                	lw	a5,4(s1)
    80003696:	8bbd                	andi	a5,a5,15
    80003698:	079a                	slli	a5,a5,0x6
    8000369a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000369c:	00059783          	lh	a5,0(a1)
    800036a0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036a4:	00259783          	lh	a5,2(a1)
    800036a8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036ac:	00459783          	lh	a5,4(a1)
    800036b0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036b4:	00659783          	lh	a5,6(a1)
    800036b8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800036bc:	459c                	lw	a5,8(a1)
    800036be:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800036c0:	03400613          	li	a2,52
    800036c4:	05b1                	addi	a1,a1,12
    800036c6:	05048513          	addi	a0,s1,80
    800036ca:	ffffd097          	auipc	ra,0xffffd
    800036ce:	664080e7          	jalr	1636(ra) # 80000d2e <memmove>
    brelse(bp);
    800036d2:	854a                	mv	a0,s2
    800036d4:	00000097          	auipc	ra,0x0
    800036d8:	876080e7          	jalr	-1930(ra) # 80002f4a <brelse>
    ip->valid = 1;
    800036dc:	4785                	li	a5,1
    800036de:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800036e0:	04449783          	lh	a5,68(s1)
    800036e4:	fbb5                	bnez	a5,80003658 <ilock+0x24>
      panic("ilock: no type");
    800036e6:	00005517          	auipc	a0,0x5
    800036ea:	f1250513          	addi	a0,a0,-238 # 800085f8 <syscalls+0x1a8>
    800036ee:	ffffd097          	auipc	ra,0xffffd
    800036f2:	e50080e7          	jalr	-432(ra) # 8000053e <panic>

00000000800036f6 <iunlock>:
{
    800036f6:	1101                	addi	sp,sp,-32
    800036f8:	ec06                	sd	ra,24(sp)
    800036fa:	e822                	sd	s0,16(sp)
    800036fc:	e426                	sd	s1,8(sp)
    800036fe:	e04a                	sd	s2,0(sp)
    80003700:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003702:	c905                	beqz	a0,80003732 <iunlock+0x3c>
    80003704:	84aa                	mv	s1,a0
    80003706:	01050913          	addi	s2,a0,16
    8000370a:	854a                	mv	a0,s2
    8000370c:	00001097          	auipc	ra,0x1
    80003710:	c7c080e7          	jalr	-900(ra) # 80004388 <holdingsleep>
    80003714:	cd19                	beqz	a0,80003732 <iunlock+0x3c>
    80003716:	449c                	lw	a5,8(s1)
    80003718:	00f05d63          	blez	a5,80003732 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000371c:	854a                	mv	a0,s2
    8000371e:	00001097          	auipc	ra,0x1
    80003722:	c26080e7          	jalr	-986(ra) # 80004344 <releasesleep>
}
    80003726:	60e2                	ld	ra,24(sp)
    80003728:	6442                	ld	s0,16(sp)
    8000372a:	64a2                	ld	s1,8(sp)
    8000372c:	6902                	ld	s2,0(sp)
    8000372e:	6105                	addi	sp,sp,32
    80003730:	8082                	ret
    panic("iunlock");
    80003732:	00005517          	auipc	a0,0x5
    80003736:	ed650513          	addi	a0,a0,-298 # 80008608 <syscalls+0x1b8>
    8000373a:	ffffd097          	auipc	ra,0xffffd
    8000373e:	e04080e7          	jalr	-508(ra) # 8000053e <panic>

0000000080003742 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003742:	7179                	addi	sp,sp,-48
    80003744:	f406                	sd	ra,40(sp)
    80003746:	f022                	sd	s0,32(sp)
    80003748:	ec26                	sd	s1,24(sp)
    8000374a:	e84a                	sd	s2,16(sp)
    8000374c:	e44e                	sd	s3,8(sp)
    8000374e:	e052                	sd	s4,0(sp)
    80003750:	1800                	addi	s0,sp,48
    80003752:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003754:	05050493          	addi	s1,a0,80
    80003758:	08050913          	addi	s2,a0,128
    8000375c:	a021                	j	80003764 <itrunc+0x22>
    8000375e:	0491                	addi	s1,s1,4
    80003760:	01248d63          	beq	s1,s2,8000377a <itrunc+0x38>
    if(ip->addrs[i]){
    80003764:	408c                	lw	a1,0(s1)
    80003766:	dde5                	beqz	a1,8000375e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003768:	0009a503          	lw	a0,0(s3)
    8000376c:	00000097          	auipc	ra,0x0
    80003770:	8f4080e7          	jalr	-1804(ra) # 80003060 <bfree>
      ip->addrs[i] = 0;
    80003774:	0004a023          	sw	zero,0(s1)
    80003778:	b7dd                	j	8000375e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000377a:	0809a583          	lw	a1,128(s3)
    8000377e:	e185                	bnez	a1,8000379e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003780:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003784:	854e                	mv	a0,s3
    80003786:	00000097          	auipc	ra,0x0
    8000378a:	de4080e7          	jalr	-540(ra) # 8000356a <iupdate>
}
    8000378e:	70a2                	ld	ra,40(sp)
    80003790:	7402                	ld	s0,32(sp)
    80003792:	64e2                	ld	s1,24(sp)
    80003794:	6942                	ld	s2,16(sp)
    80003796:	69a2                	ld	s3,8(sp)
    80003798:	6a02                	ld	s4,0(sp)
    8000379a:	6145                	addi	sp,sp,48
    8000379c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000379e:	0009a503          	lw	a0,0(s3)
    800037a2:	fffff097          	auipc	ra,0xfffff
    800037a6:	678080e7          	jalr	1656(ra) # 80002e1a <bread>
    800037aa:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800037ac:	05850493          	addi	s1,a0,88
    800037b0:	45850913          	addi	s2,a0,1112
    800037b4:	a021                	j	800037bc <itrunc+0x7a>
    800037b6:	0491                	addi	s1,s1,4
    800037b8:	01248b63          	beq	s1,s2,800037ce <itrunc+0x8c>
      if(a[j])
    800037bc:	408c                	lw	a1,0(s1)
    800037be:	dde5                	beqz	a1,800037b6 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800037c0:	0009a503          	lw	a0,0(s3)
    800037c4:	00000097          	auipc	ra,0x0
    800037c8:	89c080e7          	jalr	-1892(ra) # 80003060 <bfree>
    800037cc:	b7ed                	j	800037b6 <itrunc+0x74>
    brelse(bp);
    800037ce:	8552                	mv	a0,s4
    800037d0:	fffff097          	auipc	ra,0xfffff
    800037d4:	77a080e7          	jalr	1914(ra) # 80002f4a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800037d8:	0809a583          	lw	a1,128(s3)
    800037dc:	0009a503          	lw	a0,0(s3)
    800037e0:	00000097          	auipc	ra,0x0
    800037e4:	880080e7          	jalr	-1920(ra) # 80003060 <bfree>
    ip->addrs[NDIRECT] = 0;
    800037e8:	0809a023          	sw	zero,128(s3)
    800037ec:	bf51                	j	80003780 <itrunc+0x3e>

00000000800037ee <iput>:
{
    800037ee:	1101                	addi	sp,sp,-32
    800037f0:	ec06                	sd	ra,24(sp)
    800037f2:	e822                	sd	s0,16(sp)
    800037f4:	e426                	sd	s1,8(sp)
    800037f6:	e04a                	sd	s2,0(sp)
    800037f8:	1000                	addi	s0,sp,32
    800037fa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037fc:	0001c517          	auipc	a0,0x1c
    80003800:	89c50513          	addi	a0,a0,-1892 # 8001f098 <itable>
    80003804:	ffffd097          	auipc	ra,0xffffd
    80003808:	3d2080e7          	jalr	978(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000380c:	4498                	lw	a4,8(s1)
    8000380e:	4785                	li	a5,1
    80003810:	02f70363          	beq	a4,a5,80003836 <iput+0x48>
  ip->ref--;
    80003814:	449c                	lw	a5,8(s1)
    80003816:	37fd                	addiw	a5,a5,-1
    80003818:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000381a:	0001c517          	auipc	a0,0x1c
    8000381e:	87e50513          	addi	a0,a0,-1922 # 8001f098 <itable>
    80003822:	ffffd097          	auipc	ra,0xffffd
    80003826:	468080e7          	jalr	1128(ra) # 80000c8a <release>
}
    8000382a:	60e2                	ld	ra,24(sp)
    8000382c:	6442                	ld	s0,16(sp)
    8000382e:	64a2                	ld	s1,8(sp)
    80003830:	6902                	ld	s2,0(sp)
    80003832:	6105                	addi	sp,sp,32
    80003834:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003836:	40bc                	lw	a5,64(s1)
    80003838:	dff1                	beqz	a5,80003814 <iput+0x26>
    8000383a:	04a49783          	lh	a5,74(s1)
    8000383e:	fbf9                	bnez	a5,80003814 <iput+0x26>
    acquiresleep(&ip->lock);
    80003840:	01048913          	addi	s2,s1,16
    80003844:	854a                	mv	a0,s2
    80003846:	00001097          	auipc	ra,0x1
    8000384a:	aa8080e7          	jalr	-1368(ra) # 800042ee <acquiresleep>
    release(&itable.lock);
    8000384e:	0001c517          	auipc	a0,0x1c
    80003852:	84a50513          	addi	a0,a0,-1974 # 8001f098 <itable>
    80003856:	ffffd097          	auipc	ra,0xffffd
    8000385a:	434080e7          	jalr	1076(ra) # 80000c8a <release>
    itrunc(ip);
    8000385e:	8526                	mv	a0,s1
    80003860:	00000097          	auipc	ra,0x0
    80003864:	ee2080e7          	jalr	-286(ra) # 80003742 <itrunc>
    ip->type = 0;
    80003868:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000386c:	8526                	mv	a0,s1
    8000386e:	00000097          	auipc	ra,0x0
    80003872:	cfc080e7          	jalr	-772(ra) # 8000356a <iupdate>
    ip->valid = 0;
    80003876:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000387a:	854a                	mv	a0,s2
    8000387c:	00001097          	auipc	ra,0x1
    80003880:	ac8080e7          	jalr	-1336(ra) # 80004344 <releasesleep>
    acquire(&itable.lock);
    80003884:	0001c517          	auipc	a0,0x1c
    80003888:	81450513          	addi	a0,a0,-2028 # 8001f098 <itable>
    8000388c:	ffffd097          	auipc	ra,0xffffd
    80003890:	34a080e7          	jalr	842(ra) # 80000bd6 <acquire>
    80003894:	b741                	j	80003814 <iput+0x26>

0000000080003896 <iunlockput>:
{
    80003896:	1101                	addi	sp,sp,-32
    80003898:	ec06                	sd	ra,24(sp)
    8000389a:	e822                	sd	s0,16(sp)
    8000389c:	e426                	sd	s1,8(sp)
    8000389e:	1000                	addi	s0,sp,32
    800038a0:	84aa                	mv	s1,a0
  iunlock(ip);
    800038a2:	00000097          	auipc	ra,0x0
    800038a6:	e54080e7          	jalr	-428(ra) # 800036f6 <iunlock>
  iput(ip);
    800038aa:	8526                	mv	a0,s1
    800038ac:	00000097          	auipc	ra,0x0
    800038b0:	f42080e7          	jalr	-190(ra) # 800037ee <iput>
}
    800038b4:	60e2                	ld	ra,24(sp)
    800038b6:	6442                	ld	s0,16(sp)
    800038b8:	64a2                	ld	s1,8(sp)
    800038ba:	6105                	addi	sp,sp,32
    800038bc:	8082                	ret

00000000800038be <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038be:	1141                	addi	sp,sp,-16
    800038c0:	e422                	sd	s0,8(sp)
    800038c2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038c4:	411c                	lw	a5,0(a0)
    800038c6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038c8:	415c                	lw	a5,4(a0)
    800038ca:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038cc:	04451783          	lh	a5,68(a0)
    800038d0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800038d4:	04a51783          	lh	a5,74(a0)
    800038d8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800038dc:	04c56783          	lwu	a5,76(a0)
    800038e0:	e99c                	sd	a5,16(a1)
}
    800038e2:	6422                	ld	s0,8(sp)
    800038e4:	0141                	addi	sp,sp,16
    800038e6:	8082                	ret

00000000800038e8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038e8:	457c                	lw	a5,76(a0)
    800038ea:	0ed7e963          	bltu	a5,a3,800039dc <readi+0xf4>
{
    800038ee:	7159                	addi	sp,sp,-112
    800038f0:	f486                	sd	ra,104(sp)
    800038f2:	f0a2                	sd	s0,96(sp)
    800038f4:	eca6                	sd	s1,88(sp)
    800038f6:	e8ca                	sd	s2,80(sp)
    800038f8:	e4ce                	sd	s3,72(sp)
    800038fa:	e0d2                	sd	s4,64(sp)
    800038fc:	fc56                	sd	s5,56(sp)
    800038fe:	f85a                	sd	s6,48(sp)
    80003900:	f45e                	sd	s7,40(sp)
    80003902:	f062                	sd	s8,32(sp)
    80003904:	ec66                	sd	s9,24(sp)
    80003906:	e86a                	sd	s10,16(sp)
    80003908:	e46e                	sd	s11,8(sp)
    8000390a:	1880                	addi	s0,sp,112
    8000390c:	8b2a                	mv	s6,a0
    8000390e:	8bae                	mv	s7,a1
    80003910:	8a32                	mv	s4,a2
    80003912:	84b6                	mv	s1,a3
    80003914:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003916:	9f35                	addw	a4,a4,a3
    return 0;
    80003918:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000391a:	0ad76063          	bltu	a4,a3,800039ba <readi+0xd2>
  if(off + n > ip->size)
    8000391e:	00e7f463          	bgeu	a5,a4,80003926 <readi+0x3e>
    n = ip->size - off;
    80003922:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003926:	0a0a8963          	beqz	s5,800039d8 <readi+0xf0>
    8000392a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000392c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003930:	5c7d                	li	s8,-1
    80003932:	a82d                	j	8000396c <readi+0x84>
    80003934:	020d1d93          	slli	s11,s10,0x20
    80003938:	020ddd93          	srli	s11,s11,0x20
    8000393c:	05890793          	addi	a5,s2,88
    80003940:	86ee                	mv	a3,s11
    80003942:	963e                	add	a2,a2,a5
    80003944:	85d2                	mv	a1,s4
    80003946:	855e                	mv	a0,s7
    80003948:	fffff097          	auipc	ra,0xfffff
    8000394c:	b1c080e7          	jalr	-1252(ra) # 80002464 <either_copyout>
    80003950:	05850d63          	beq	a0,s8,800039aa <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003954:	854a                	mv	a0,s2
    80003956:	fffff097          	auipc	ra,0xfffff
    8000395a:	5f4080e7          	jalr	1524(ra) # 80002f4a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000395e:	013d09bb          	addw	s3,s10,s3
    80003962:	009d04bb          	addw	s1,s10,s1
    80003966:	9a6e                	add	s4,s4,s11
    80003968:	0559f763          	bgeu	s3,s5,800039b6 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000396c:	00a4d59b          	srliw	a1,s1,0xa
    80003970:	855a                	mv	a0,s6
    80003972:	00000097          	auipc	ra,0x0
    80003976:	8a2080e7          	jalr	-1886(ra) # 80003214 <bmap>
    8000397a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000397e:	cd85                	beqz	a1,800039b6 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003980:	000b2503          	lw	a0,0(s6)
    80003984:	fffff097          	auipc	ra,0xfffff
    80003988:	496080e7          	jalr	1174(ra) # 80002e1a <bread>
    8000398c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000398e:	3ff4f613          	andi	a2,s1,1023
    80003992:	40cc87bb          	subw	a5,s9,a2
    80003996:	413a873b          	subw	a4,s5,s3
    8000399a:	8d3e                	mv	s10,a5
    8000399c:	2781                	sext.w	a5,a5
    8000399e:	0007069b          	sext.w	a3,a4
    800039a2:	f8f6f9e3          	bgeu	a3,a5,80003934 <readi+0x4c>
    800039a6:	8d3a                	mv	s10,a4
    800039a8:	b771                	j	80003934 <readi+0x4c>
      brelse(bp);
    800039aa:	854a                	mv	a0,s2
    800039ac:	fffff097          	auipc	ra,0xfffff
    800039b0:	59e080e7          	jalr	1438(ra) # 80002f4a <brelse>
      tot = -1;
    800039b4:	59fd                	li	s3,-1
  }
  return tot;
    800039b6:	0009851b          	sext.w	a0,s3
}
    800039ba:	70a6                	ld	ra,104(sp)
    800039bc:	7406                	ld	s0,96(sp)
    800039be:	64e6                	ld	s1,88(sp)
    800039c0:	6946                	ld	s2,80(sp)
    800039c2:	69a6                	ld	s3,72(sp)
    800039c4:	6a06                	ld	s4,64(sp)
    800039c6:	7ae2                	ld	s5,56(sp)
    800039c8:	7b42                	ld	s6,48(sp)
    800039ca:	7ba2                	ld	s7,40(sp)
    800039cc:	7c02                	ld	s8,32(sp)
    800039ce:	6ce2                	ld	s9,24(sp)
    800039d0:	6d42                	ld	s10,16(sp)
    800039d2:	6da2                	ld	s11,8(sp)
    800039d4:	6165                	addi	sp,sp,112
    800039d6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039d8:	89d6                	mv	s3,s5
    800039da:	bff1                	j	800039b6 <readi+0xce>
    return 0;
    800039dc:	4501                	li	a0,0
}
    800039de:	8082                	ret

00000000800039e0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039e0:	457c                	lw	a5,76(a0)
    800039e2:	10d7e863          	bltu	a5,a3,80003af2 <writei+0x112>
{
    800039e6:	7159                	addi	sp,sp,-112
    800039e8:	f486                	sd	ra,104(sp)
    800039ea:	f0a2                	sd	s0,96(sp)
    800039ec:	eca6                	sd	s1,88(sp)
    800039ee:	e8ca                	sd	s2,80(sp)
    800039f0:	e4ce                	sd	s3,72(sp)
    800039f2:	e0d2                	sd	s4,64(sp)
    800039f4:	fc56                	sd	s5,56(sp)
    800039f6:	f85a                	sd	s6,48(sp)
    800039f8:	f45e                	sd	s7,40(sp)
    800039fa:	f062                	sd	s8,32(sp)
    800039fc:	ec66                	sd	s9,24(sp)
    800039fe:	e86a                	sd	s10,16(sp)
    80003a00:	e46e                	sd	s11,8(sp)
    80003a02:	1880                	addi	s0,sp,112
    80003a04:	8aaa                	mv	s5,a0
    80003a06:	8bae                	mv	s7,a1
    80003a08:	8a32                	mv	s4,a2
    80003a0a:	8936                	mv	s2,a3
    80003a0c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a0e:	00e687bb          	addw	a5,a3,a4
    80003a12:	0ed7e263          	bltu	a5,a3,80003af6 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a16:	00043737          	lui	a4,0x43
    80003a1a:	0ef76063          	bltu	a4,a5,80003afa <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a1e:	0c0b0863          	beqz	s6,80003aee <writei+0x10e>
    80003a22:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a24:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a28:	5c7d                	li	s8,-1
    80003a2a:	a091                	j	80003a6e <writei+0x8e>
    80003a2c:	020d1d93          	slli	s11,s10,0x20
    80003a30:	020ddd93          	srli	s11,s11,0x20
    80003a34:	05848793          	addi	a5,s1,88
    80003a38:	86ee                	mv	a3,s11
    80003a3a:	8652                	mv	a2,s4
    80003a3c:	85de                	mv	a1,s7
    80003a3e:	953e                	add	a0,a0,a5
    80003a40:	fffff097          	auipc	ra,0xfffff
    80003a44:	a7a080e7          	jalr	-1414(ra) # 800024ba <either_copyin>
    80003a48:	07850263          	beq	a0,s8,80003aac <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a4c:	8526                	mv	a0,s1
    80003a4e:	00000097          	auipc	ra,0x0
    80003a52:	780080e7          	jalr	1920(ra) # 800041ce <log_write>
    brelse(bp);
    80003a56:	8526                	mv	a0,s1
    80003a58:	fffff097          	auipc	ra,0xfffff
    80003a5c:	4f2080e7          	jalr	1266(ra) # 80002f4a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a60:	013d09bb          	addw	s3,s10,s3
    80003a64:	012d093b          	addw	s2,s10,s2
    80003a68:	9a6e                	add	s4,s4,s11
    80003a6a:	0569f663          	bgeu	s3,s6,80003ab6 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003a6e:	00a9559b          	srliw	a1,s2,0xa
    80003a72:	8556                	mv	a0,s5
    80003a74:	fffff097          	auipc	ra,0xfffff
    80003a78:	7a0080e7          	jalr	1952(ra) # 80003214 <bmap>
    80003a7c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a80:	c99d                	beqz	a1,80003ab6 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003a82:	000aa503          	lw	a0,0(s5)
    80003a86:	fffff097          	auipc	ra,0xfffff
    80003a8a:	394080e7          	jalr	916(ra) # 80002e1a <bread>
    80003a8e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a90:	3ff97513          	andi	a0,s2,1023
    80003a94:	40ac87bb          	subw	a5,s9,a0
    80003a98:	413b073b          	subw	a4,s6,s3
    80003a9c:	8d3e                	mv	s10,a5
    80003a9e:	2781                	sext.w	a5,a5
    80003aa0:	0007069b          	sext.w	a3,a4
    80003aa4:	f8f6f4e3          	bgeu	a3,a5,80003a2c <writei+0x4c>
    80003aa8:	8d3a                	mv	s10,a4
    80003aaa:	b749                	j	80003a2c <writei+0x4c>
      brelse(bp);
    80003aac:	8526                	mv	a0,s1
    80003aae:	fffff097          	auipc	ra,0xfffff
    80003ab2:	49c080e7          	jalr	1180(ra) # 80002f4a <brelse>
  }

  if(off > ip->size)
    80003ab6:	04caa783          	lw	a5,76(s5)
    80003aba:	0127f463          	bgeu	a5,s2,80003ac2 <writei+0xe2>
    ip->size = off;
    80003abe:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ac2:	8556                	mv	a0,s5
    80003ac4:	00000097          	auipc	ra,0x0
    80003ac8:	aa6080e7          	jalr	-1370(ra) # 8000356a <iupdate>

  return tot;
    80003acc:	0009851b          	sext.w	a0,s3
}
    80003ad0:	70a6                	ld	ra,104(sp)
    80003ad2:	7406                	ld	s0,96(sp)
    80003ad4:	64e6                	ld	s1,88(sp)
    80003ad6:	6946                	ld	s2,80(sp)
    80003ad8:	69a6                	ld	s3,72(sp)
    80003ada:	6a06                	ld	s4,64(sp)
    80003adc:	7ae2                	ld	s5,56(sp)
    80003ade:	7b42                	ld	s6,48(sp)
    80003ae0:	7ba2                	ld	s7,40(sp)
    80003ae2:	7c02                	ld	s8,32(sp)
    80003ae4:	6ce2                	ld	s9,24(sp)
    80003ae6:	6d42                	ld	s10,16(sp)
    80003ae8:	6da2                	ld	s11,8(sp)
    80003aea:	6165                	addi	sp,sp,112
    80003aec:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aee:	89da                	mv	s3,s6
    80003af0:	bfc9                	j	80003ac2 <writei+0xe2>
    return -1;
    80003af2:	557d                	li	a0,-1
}
    80003af4:	8082                	ret
    return -1;
    80003af6:	557d                	li	a0,-1
    80003af8:	bfe1                	j	80003ad0 <writei+0xf0>
    return -1;
    80003afa:	557d                	li	a0,-1
    80003afc:	bfd1                	j	80003ad0 <writei+0xf0>

0000000080003afe <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003afe:	1141                	addi	sp,sp,-16
    80003b00:	e406                	sd	ra,8(sp)
    80003b02:	e022                	sd	s0,0(sp)
    80003b04:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b06:	4639                	li	a2,14
    80003b08:	ffffd097          	auipc	ra,0xffffd
    80003b0c:	29a080e7          	jalr	666(ra) # 80000da2 <strncmp>
}
    80003b10:	60a2                	ld	ra,8(sp)
    80003b12:	6402                	ld	s0,0(sp)
    80003b14:	0141                	addi	sp,sp,16
    80003b16:	8082                	ret

0000000080003b18 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b18:	7139                	addi	sp,sp,-64
    80003b1a:	fc06                	sd	ra,56(sp)
    80003b1c:	f822                	sd	s0,48(sp)
    80003b1e:	f426                	sd	s1,40(sp)
    80003b20:	f04a                	sd	s2,32(sp)
    80003b22:	ec4e                	sd	s3,24(sp)
    80003b24:	e852                	sd	s4,16(sp)
    80003b26:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b28:	04451703          	lh	a4,68(a0)
    80003b2c:	4785                	li	a5,1
    80003b2e:	00f71a63          	bne	a4,a5,80003b42 <dirlookup+0x2a>
    80003b32:	892a                	mv	s2,a0
    80003b34:	89ae                	mv	s3,a1
    80003b36:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b38:	457c                	lw	a5,76(a0)
    80003b3a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b3c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b3e:	e79d                	bnez	a5,80003b6c <dirlookup+0x54>
    80003b40:	a8a5                	j	80003bb8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b42:	00005517          	auipc	a0,0x5
    80003b46:	ace50513          	addi	a0,a0,-1330 # 80008610 <syscalls+0x1c0>
    80003b4a:	ffffd097          	auipc	ra,0xffffd
    80003b4e:	9f4080e7          	jalr	-1548(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003b52:	00005517          	auipc	a0,0x5
    80003b56:	ad650513          	addi	a0,a0,-1322 # 80008628 <syscalls+0x1d8>
    80003b5a:	ffffd097          	auipc	ra,0xffffd
    80003b5e:	9e4080e7          	jalr	-1564(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b62:	24c1                	addiw	s1,s1,16
    80003b64:	04c92783          	lw	a5,76(s2)
    80003b68:	04f4f763          	bgeu	s1,a5,80003bb6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b6c:	4741                	li	a4,16
    80003b6e:	86a6                	mv	a3,s1
    80003b70:	fc040613          	addi	a2,s0,-64
    80003b74:	4581                	li	a1,0
    80003b76:	854a                	mv	a0,s2
    80003b78:	00000097          	auipc	ra,0x0
    80003b7c:	d70080e7          	jalr	-656(ra) # 800038e8 <readi>
    80003b80:	47c1                	li	a5,16
    80003b82:	fcf518e3          	bne	a0,a5,80003b52 <dirlookup+0x3a>
    if(de.inum == 0)
    80003b86:	fc045783          	lhu	a5,-64(s0)
    80003b8a:	dfe1                	beqz	a5,80003b62 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003b8c:	fc240593          	addi	a1,s0,-62
    80003b90:	854e                	mv	a0,s3
    80003b92:	00000097          	auipc	ra,0x0
    80003b96:	f6c080e7          	jalr	-148(ra) # 80003afe <namecmp>
    80003b9a:	f561                	bnez	a0,80003b62 <dirlookup+0x4a>
      if(poff)
    80003b9c:	000a0463          	beqz	s4,80003ba4 <dirlookup+0x8c>
        *poff = off;
    80003ba0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ba4:	fc045583          	lhu	a1,-64(s0)
    80003ba8:	00092503          	lw	a0,0(s2)
    80003bac:	fffff097          	auipc	ra,0xfffff
    80003bb0:	750080e7          	jalr	1872(ra) # 800032fc <iget>
    80003bb4:	a011                	j	80003bb8 <dirlookup+0xa0>
  return 0;
    80003bb6:	4501                	li	a0,0
}
    80003bb8:	70e2                	ld	ra,56(sp)
    80003bba:	7442                	ld	s0,48(sp)
    80003bbc:	74a2                	ld	s1,40(sp)
    80003bbe:	7902                	ld	s2,32(sp)
    80003bc0:	69e2                	ld	s3,24(sp)
    80003bc2:	6a42                	ld	s4,16(sp)
    80003bc4:	6121                	addi	sp,sp,64
    80003bc6:	8082                	ret

0000000080003bc8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003bc8:	711d                	addi	sp,sp,-96
    80003bca:	ec86                	sd	ra,88(sp)
    80003bcc:	e8a2                	sd	s0,80(sp)
    80003bce:	e4a6                	sd	s1,72(sp)
    80003bd0:	e0ca                	sd	s2,64(sp)
    80003bd2:	fc4e                	sd	s3,56(sp)
    80003bd4:	f852                	sd	s4,48(sp)
    80003bd6:	f456                	sd	s5,40(sp)
    80003bd8:	f05a                	sd	s6,32(sp)
    80003bda:	ec5e                	sd	s7,24(sp)
    80003bdc:	e862                	sd	s8,16(sp)
    80003bde:	e466                	sd	s9,8(sp)
    80003be0:	1080                	addi	s0,sp,96
    80003be2:	84aa                	mv	s1,a0
    80003be4:	8aae                	mv	s5,a1
    80003be6:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003be8:	00054703          	lbu	a4,0(a0)
    80003bec:	02f00793          	li	a5,47
    80003bf0:	02f70363          	beq	a4,a5,80003c16 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003bf4:	ffffe097          	auipc	ra,0xffffe
    80003bf8:	dc0080e7          	jalr	-576(ra) # 800019b4 <myproc>
    80003bfc:	15053503          	ld	a0,336(a0)
    80003c00:	00000097          	auipc	ra,0x0
    80003c04:	9f6080e7          	jalr	-1546(ra) # 800035f6 <idup>
    80003c08:	89aa                	mv	s3,a0
  while(*path == '/')
    80003c0a:	02f00913          	li	s2,47
  len = path - s;
    80003c0e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003c10:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c12:	4b85                	li	s7,1
    80003c14:	a865                	j	80003ccc <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003c16:	4585                	li	a1,1
    80003c18:	4505                	li	a0,1
    80003c1a:	fffff097          	auipc	ra,0xfffff
    80003c1e:	6e2080e7          	jalr	1762(ra) # 800032fc <iget>
    80003c22:	89aa                	mv	s3,a0
    80003c24:	b7dd                	j	80003c0a <namex+0x42>
      iunlockput(ip);
    80003c26:	854e                	mv	a0,s3
    80003c28:	00000097          	auipc	ra,0x0
    80003c2c:	c6e080e7          	jalr	-914(ra) # 80003896 <iunlockput>
      return 0;
    80003c30:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c32:	854e                	mv	a0,s3
    80003c34:	60e6                	ld	ra,88(sp)
    80003c36:	6446                	ld	s0,80(sp)
    80003c38:	64a6                	ld	s1,72(sp)
    80003c3a:	6906                	ld	s2,64(sp)
    80003c3c:	79e2                	ld	s3,56(sp)
    80003c3e:	7a42                	ld	s4,48(sp)
    80003c40:	7aa2                	ld	s5,40(sp)
    80003c42:	7b02                	ld	s6,32(sp)
    80003c44:	6be2                	ld	s7,24(sp)
    80003c46:	6c42                	ld	s8,16(sp)
    80003c48:	6ca2                	ld	s9,8(sp)
    80003c4a:	6125                	addi	sp,sp,96
    80003c4c:	8082                	ret
      iunlock(ip);
    80003c4e:	854e                	mv	a0,s3
    80003c50:	00000097          	auipc	ra,0x0
    80003c54:	aa6080e7          	jalr	-1370(ra) # 800036f6 <iunlock>
      return ip;
    80003c58:	bfe9                	j	80003c32 <namex+0x6a>
      iunlockput(ip);
    80003c5a:	854e                	mv	a0,s3
    80003c5c:	00000097          	auipc	ra,0x0
    80003c60:	c3a080e7          	jalr	-966(ra) # 80003896 <iunlockput>
      return 0;
    80003c64:	89e6                	mv	s3,s9
    80003c66:	b7f1                	j	80003c32 <namex+0x6a>
  len = path - s;
    80003c68:	40b48633          	sub	a2,s1,a1
    80003c6c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003c70:	099c5463          	bge	s8,s9,80003cf8 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003c74:	4639                	li	a2,14
    80003c76:	8552                	mv	a0,s4
    80003c78:	ffffd097          	auipc	ra,0xffffd
    80003c7c:	0b6080e7          	jalr	182(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003c80:	0004c783          	lbu	a5,0(s1)
    80003c84:	01279763          	bne	a5,s2,80003c92 <namex+0xca>
    path++;
    80003c88:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c8a:	0004c783          	lbu	a5,0(s1)
    80003c8e:	ff278de3          	beq	a5,s2,80003c88 <namex+0xc0>
    ilock(ip);
    80003c92:	854e                	mv	a0,s3
    80003c94:	00000097          	auipc	ra,0x0
    80003c98:	9a0080e7          	jalr	-1632(ra) # 80003634 <ilock>
    if(ip->type != T_DIR){
    80003c9c:	04499783          	lh	a5,68(s3)
    80003ca0:	f97793e3          	bne	a5,s7,80003c26 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003ca4:	000a8563          	beqz	s5,80003cae <namex+0xe6>
    80003ca8:	0004c783          	lbu	a5,0(s1)
    80003cac:	d3cd                	beqz	a5,80003c4e <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003cae:	865a                	mv	a2,s6
    80003cb0:	85d2                	mv	a1,s4
    80003cb2:	854e                	mv	a0,s3
    80003cb4:	00000097          	auipc	ra,0x0
    80003cb8:	e64080e7          	jalr	-412(ra) # 80003b18 <dirlookup>
    80003cbc:	8caa                	mv	s9,a0
    80003cbe:	dd51                	beqz	a0,80003c5a <namex+0x92>
    iunlockput(ip);
    80003cc0:	854e                	mv	a0,s3
    80003cc2:	00000097          	auipc	ra,0x0
    80003cc6:	bd4080e7          	jalr	-1068(ra) # 80003896 <iunlockput>
    ip = next;
    80003cca:	89e6                	mv	s3,s9
  while(*path == '/')
    80003ccc:	0004c783          	lbu	a5,0(s1)
    80003cd0:	05279763          	bne	a5,s2,80003d1e <namex+0x156>
    path++;
    80003cd4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cd6:	0004c783          	lbu	a5,0(s1)
    80003cda:	ff278de3          	beq	a5,s2,80003cd4 <namex+0x10c>
  if(*path == 0)
    80003cde:	c79d                	beqz	a5,80003d0c <namex+0x144>
    path++;
    80003ce0:	85a6                	mv	a1,s1
  len = path - s;
    80003ce2:	8cda                	mv	s9,s6
    80003ce4:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003ce6:	01278963          	beq	a5,s2,80003cf8 <namex+0x130>
    80003cea:	dfbd                	beqz	a5,80003c68 <namex+0xa0>
    path++;
    80003cec:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003cee:	0004c783          	lbu	a5,0(s1)
    80003cf2:	ff279ce3          	bne	a5,s2,80003cea <namex+0x122>
    80003cf6:	bf8d                	j	80003c68 <namex+0xa0>
    memmove(name, s, len);
    80003cf8:	2601                	sext.w	a2,a2
    80003cfa:	8552                	mv	a0,s4
    80003cfc:	ffffd097          	auipc	ra,0xffffd
    80003d00:	032080e7          	jalr	50(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003d04:	9cd2                	add	s9,s9,s4
    80003d06:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d0a:	bf9d                	j	80003c80 <namex+0xb8>
  if(nameiparent){
    80003d0c:	f20a83e3          	beqz	s5,80003c32 <namex+0x6a>
    iput(ip);
    80003d10:	854e                	mv	a0,s3
    80003d12:	00000097          	auipc	ra,0x0
    80003d16:	adc080e7          	jalr	-1316(ra) # 800037ee <iput>
    return 0;
    80003d1a:	4981                	li	s3,0
    80003d1c:	bf19                	j	80003c32 <namex+0x6a>
  if(*path == 0)
    80003d1e:	d7fd                	beqz	a5,80003d0c <namex+0x144>
  while(*path != '/' && *path != 0)
    80003d20:	0004c783          	lbu	a5,0(s1)
    80003d24:	85a6                	mv	a1,s1
    80003d26:	b7d1                	j	80003cea <namex+0x122>

0000000080003d28 <dirlink>:
{
    80003d28:	7139                	addi	sp,sp,-64
    80003d2a:	fc06                	sd	ra,56(sp)
    80003d2c:	f822                	sd	s0,48(sp)
    80003d2e:	f426                	sd	s1,40(sp)
    80003d30:	f04a                	sd	s2,32(sp)
    80003d32:	ec4e                	sd	s3,24(sp)
    80003d34:	e852                	sd	s4,16(sp)
    80003d36:	0080                	addi	s0,sp,64
    80003d38:	892a                	mv	s2,a0
    80003d3a:	8a2e                	mv	s4,a1
    80003d3c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d3e:	4601                	li	a2,0
    80003d40:	00000097          	auipc	ra,0x0
    80003d44:	dd8080e7          	jalr	-552(ra) # 80003b18 <dirlookup>
    80003d48:	e93d                	bnez	a0,80003dbe <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d4a:	04c92483          	lw	s1,76(s2)
    80003d4e:	c49d                	beqz	s1,80003d7c <dirlink+0x54>
    80003d50:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d52:	4741                	li	a4,16
    80003d54:	86a6                	mv	a3,s1
    80003d56:	fc040613          	addi	a2,s0,-64
    80003d5a:	4581                	li	a1,0
    80003d5c:	854a                	mv	a0,s2
    80003d5e:	00000097          	auipc	ra,0x0
    80003d62:	b8a080e7          	jalr	-1142(ra) # 800038e8 <readi>
    80003d66:	47c1                	li	a5,16
    80003d68:	06f51163          	bne	a0,a5,80003dca <dirlink+0xa2>
    if(de.inum == 0)
    80003d6c:	fc045783          	lhu	a5,-64(s0)
    80003d70:	c791                	beqz	a5,80003d7c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d72:	24c1                	addiw	s1,s1,16
    80003d74:	04c92783          	lw	a5,76(s2)
    80003d78:	fcf4ede3          	bltu	s1,a5,80003d52 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003d7c:	4639                	li	a2,14
    80003d7e:	85d2                	mv	a1,s4
    80003d80:	fc240513          	addi	a0,s0,-62
    80003d84:	ffffd097          	auipc	ra,0xffffd
    80003d88:	05a080e7          	jalr	90(ra) # 80000dde <strncpy>
  de.inum = inum;
    80003d8c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d90:	4741                	li	a4,16
    80003d92:	86a6                	mv	a3,s1
    80003d94:	fc040613          	addi	a2,s0,-64
    80003d98:	4581                	li	a1,0
    80003d9a:	854a                	mv	a0,s2
    80003d9c:	00000097          	auipc	ra,0x0
    80003da0:	c44080e7          	jalr	-956(ra) # 800039e0 <writei>
    80003da4:	1541                	addi	a0,a0,-16
    80003da6:	00a03533          	snez	a0,a0
    80003daa:	40a00533          	neg	a0,a0
}
    80003dae:	70e2                	ld	ra,56(sp)
    80003db0:	7442                	ld	s0,48(sp)
    80003db2:	74a2                	ld	s1,40(sp)
    80003db4:	7902                	ld	s2,32(sp)
    80003db6:	69e2                	ld	s3,24(sp)
    80003db8:	6a42                	ld	s4,16(sp)
    80003dba:	6121                	addi	sp,sp,64
    80003dbc:	8082                	ret
    iput(ip);
    80003dbe:	00000097          	auipc	ra,0x0
    80003dc2:	a30080e7          	jalr	-1488(ra) # 800037ee <iput>
    return -1;
    80003dc6:	557d                	li	a0,-1
    80003dc8:	b7dd                	j	80003dae <dirlink+0x86>
      panic("dirlink read");
    80003dca:	00005517          	auipc	a0,0x5
    80003dce:	86e50513          	addi	a0,a0,-1938 # 80008638 <syscalls+0x1e8>
    80003dd2:	ffffc097          	auipc	ra,0xffffc
    80003dd6:	76c080e7          	jalr	1900(ra) # 8000053e <panic>

0000000080003dda <namei>:

struct inode*
namei(char *path)
{
    80003dda:	1101                	addi	sp,sp,-32
    80003ddc:	ec06                	sd	ra,24(sp)
    80003dde:	e822                	sd	s0,16(sp)
    80003de0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003de2:	fe040613          	addi	a2,s0,-32
    80003de6:	4581                	li	a1,0
    80003de8:	00000097          	auipc	ra,0x0
    80003dec:	de0080e7          	jalr	-544(ra) # 80003bc8 <namex>
}
    80003df0:	60e2                	ld	ra,24(sp)
    80003df2:	6442                	ld	s0,16(sp)
    80003df4:	6105                	addi	sp,sp,32
    80003df6:	8082                	ret

0000000080003df8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003df8:	1141                	addi	sp,sp,-16
    80003dfa:	e406                	sd	ra,8(sp)
    80003dfc:	e022                	sd	s0,0(sp)
    80003dfe:	0800                	addi	s0,sp,16
    80003e00:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e02:	4585                	li	a1,1
    80003e04:	00000097          	auipc	ra,0x0
    80003e08:	dc4080e7          	jalr	-572(ra) # 80003bc8 <namex>
}
    80003e0c:	60a2                	ld	ra,8(sp)
    80003e0e:	6402                	ld	s0,0(sp)
    80003e10:	0141                	addi	sp,sp,16
    80003e12:	8082                	ret

0000000080003e14 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e14:	1101                	addi	sp,sp,-32
    80003e16:	ec06                	sd	ra,24(sp)
    80003e18:	e822                	sd	s0,16(sp)
    80003e1a:	e426                	sd	s1,8(sp)
    80003e1c:	e04a                	sd	s2,0(sp)
    80003e1e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e20:	0001d917          	auipc	s2,0x1d
    80003e24:	d2090913          	addi	s2,s2,-736 # 80020b40 <log>
    80003e28:	01892583          	lw	a1,24(s2)
    80003e2c:	02892503          	lw	a0,40(s2)
    80003e30:	fffff097          	auipc	ra,0xfffff
    80003e34:	fea080e7          	jalr	-22(ra) # 80002e1a <bread>
    80003e38:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e3a:	02c92683          	lw	a3,44(s2)
    80003e3e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e40:	02d05763          	blez	a3,80003e6e <write_head+0x5a>
    80003e44:	0001d797          	auipc	a5,0x1d
    80003e48:	d2c78793          	addi	a5,a5,-724 # 80020b70 <log+0x30>
    80003e4c:	05c50713          	addi	a4,a0,92
    80003e50:	36fd                	addiw	a3,a3,-1
    80003e52:	1682                	slli	a3,a3,0x20
    80003e54:	9281                	srli	a3,a3,0x20
    80003e56:	068a                	slli	a3,a3,0x2
    80003e58:	0001d617          	auipc	a2,0x1d
    80003e5c:	d1c60613          	addi	a2,a2,-740 # 80020b74 <log+0x34>
    80003e60:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003e62:	4390                	lw	a2,0(a5)
    80003e64:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e66:	0791                	addi	a5,a5,4
    80003e68:	0711                	addi	a4,a4,4
    80003e6a:	fed79ce3          	bne	a5,a3,80003e62 <write_head+0x4e>
  }
  bwrite(buf);
    80003e6e:	8526                	mv	a0,s1
    80003e70:	fffff097          	auipc	ra,0xfffff
    80003e74:	09c080e7          	jalr	156(ra) # 80002f0c <bwrite>
  brelse(buf);
    80003e78:	8526                	mv	a0,s1
    80003e7a:	fffff097          	auipc	ra,0xfffff
    80003e7e:	0d0080e7          	jalr	208(ra) # 80002f4a <brelse>
}
    80003e82:	60e2                	ld	ra,24(sp)
    80003e84:	6442                	ld	s0,16(sp)
    80003e86:	64a2                	ld	s1,8(sp)
    80003e88:	6902                	ld	s2,0(sp)
    80003e8a:	6105                	addi	sp,sp,32
    80003e8c:	8082                	ret

0000000080003e8e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e8e:	0001d797          	auipc	a5,0x1d
    80003e92:	cde7a783          	lw	a5,-802(a5) # 80020b6c <log+0x2c>
    80003e96:	0af05d63          	blez	a5,80003f50 <install_trans+0xc2>
{
    80003e9a:	7139                	addi	sp,sp,-64
    80003e9c:	fc06                	sd	ra,56(sp)
    80003e9e:	f822                	sd	s0,48(sp)
    80003ea0:	f426                	sd	s1,40(sp)
    80003ea2:	f04a                	sd	s2,32(sp)
    80003ea4:	ec4e                	sd	s3,24(sp)
    80003ea6:	e852                	sd	s4,16(sp)
    80003ea8:	e456                	sd	s5,8(sp)
    80003eaa:	e05a                	sd	s6,0(sp)
    80003eac:	0080                	addi	s0,sp,64
    80003eae:	8b2a                	mv	s6,a0
    80003eb0:	0001da97          	auipc	s5,0x1d
    80003eb4:	cc0a8a93          	addi	s5,s5,-832 # 80020b70 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eb8:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003eba:	0001d997          	auipc	s3,0x1d
    80003ebe:	c8698993          	addi	s3,s3,-890 # 80020b40 <log>
    80003ec2:	a00d                	j	80003ee4 <install_trans+0x56>
    brelse(lbuf);
    80003ec4:	854a                	mv	a0,s2
    80003ec6:	fffff097          	auipc	ra,0xfffff
    80003eca:	084080e7          	jalr	132(ra) # 80002f4a <brelse>
    brelse(dbuf);
    80003ece:	8526                	mv	a0,s1
    80003ed0:	fffff097          	auipc	ra,0xfffff
    80003ed4:	07a080e7          	jalr	122(ra) # 80002f4a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ed8:	2a05                	addiw	s4,s4,1
    80003eda:	0a91                	addi	s5,s5,4
    80003edc:	02c9a783          	lw	a5,44(s3)
    80003ee0:	04fa5e63          	bge	s4,a5,80003f3c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ee4:	0189a583          	lw	a1,24(s3)
    80003ee8:	014585bb          	addw	a1,a1,s4
    80003eec:	2585                	addiw	a1,a1,1
    80003eee:	0289a503          	lw	a0,40(s3)
    80003ef2:	fffff097          	auipc	ra,0xfffff
    80003ef6:	f28080e7          	jalr	-216(ra) # 80002e1a <bread>
    80003efa:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003efc:	000aa583          	lw	a1,0(s5)
    80003f00:	0289a503          	lw	a0,40(s3)
    80003f04:	fffff097          	auipc	ra,0xfffff
    80003f08:	f16080e7          	jalr	-234(ra) # 80002e1a <bread>
    80003f0c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f0e:	40000613          	li	a2,1024
    80003f12:	05890593          	addi	a1,s2,88
    80003f16:	05850513          	addi	a0,a0,88
    80003f1a:	ffffd097          	auipc	ra,0xffffd
    80003f1e:	e14080e7          	jalr	-492(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f22:	8526                	mv	a0,s1
    80003f24:	fffff097          	auipc	ra,0xfffff
    80003f28:	fe8080e7          	jalr	-24(ra) # 80002f0c <bwrite>
    if(recovering == 0)
    80003f2c:	f80b1ce3          	bnez	s6,80003ec4 <install_trans+0x36>
      bunpin(dbuf);
    80003f30:	8526                	mv	a0,s1
    80003f32:	fffff097          	auipc	ra,0xfffff
    80003f36:	0f2080e7          	jalr	242(ra) # 80003024 <bunpin>
    80003f3a:	b769                	j	80003ec4 <install_trans+0x36>
}
    80003f3c:	70e2                	ld	ra,56(sp)
    80003f3e:	7442                	ld	s0,48(sp)
    80003f40:	74a2                	ld	s1,40(sp)
    80003f42:	7902                	ld	s2,32(sp)
    80003f44:	69e2                	ld	s3,24(sp)
    80003f46:	6a42                	ld	s4,16(sp)
    80003f48:	6aa2                	ld	s5,8(sp)
    80003f4a:	6b02                	ld	s6,0(sp)
    80003f4c:	6121                	addi	sp,sp,64
    80003f4e:	8082                	ret
    80003f50:	8082                	ret

0000000080003f52 <initlog>:
{
    80003f52:	7179                	addi	sp,sp,-48
    80003f54:	f406                	sd	ra,40(sp)
    80003f56:	f022                	sd	s0,32(sp)
    80003f58:	ec26                	sd	s1,24(sp)
    80003f5a:	e84a                	sd	s2,16(sp)
    80003f5c:	e44e                	sd	s3,8(sp)
    80003f5e:	1800                	addi	s0,sp,48
    80003f60:	892a                	mv	s2,a0
    80003f62:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f64:	0001d497          	auipc	s1,0x1d
    80003f68:	bdc48493          	addi	s1,s1,-1060 # 80020b40 <log>
    80003f6c:	00004597          	auipc	a1,0x4
    80003f70:	6dc58593          	addi	a1,a1,1756 # 80008648 <syscalls+0x1f8>
    80003f74:	8526                	mv	a0,s1
    80003f76:	ffffd097          	auipc	ra,0xffffd
    80003f7a:	bd0080e7          	jalr	-1072(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80003f7e:	0149a583          	lw	a1,20(s3)
    80003f82:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f84:	0109a783          	lw	a5,16(s3)
    80003f88:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f8a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f8e:	854a                	mv	a0,s2
    80003f90:	fffff097          	auipc	ra,0xfffff
    80003f94:	e8a080e7          	jalr	-374(ra) # 80002e1a <bread>
  log.lh.n = lh->n;
    80003f98:	4d34                	lw	a3,88(a0)
    80003f9a:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003f9c:	02d05563          	blez	a3,80003fc6 <initlog+0x74>
    80003fa0:	05c50793          	addi	a5,a0,92
    80003fa4:	0001d717          	auipc	a4,0x1d
    80003fa8:	bcc70713          	addi	a4,a4,-1076 # 80020b70 <log+0x30>
    80003fac:	36fd                	addiw	a3,a3,-1
    80003fae:	1682                	slli	a3,a3,0x20
    80003fb0:	9281                	srli	a3,a3,0x20
    80003fb2:	068a                	slli	a3,a3,0x2
    80003fb4:	06050613          	addi	a2,a0,96
    80003fb8:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003fba:	4390                	lw	a2,0(a5)
    80003fbc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fbe:	0791                	addi	a5,a5,4
    80003fc0:	0711                	addi	a4,a4,4
    80003fc2:	fed79ce3          	bne	a5,a3,80003fba <initlog+0x68>
  brelse(buf);
    80003fc6:	fffff097          	auipc	ra,0xfffff
    80003fca:	f84080e7          	jalr	-124(ra) # 80002f4a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003fce:	4505                	li	a0,1
    80003fd0:	00000097          	auipc	ra,0x0
    80003fd4:	ebe080e7          	jalr	-322(ra) # 80003e8e <install_trans>
  log.lh.n = 0;
    80003fd8:	0001d797          	auipc	a5,0x1d
    80003fdc:	b807aa23          	sw	zero,-1132(a5) # 80020b6c <log+0x2c>
  write_head(); // clear the log
    80003fe0:	00000097          	auipc	ra,0x0
    80003fe4:	e34080e7          	jalr	-460(ra) # 80003e14 <write_head>
}
    80003fe8:	70a2                	ld	ra,40(sp)
    80003fea:	7402                	ld	s0,32(sp)
    80003fec:	64e2                	ld	s1,24(sp)
    80003fee:	6942                	ld	s2,16(sp)
    80003ff0:	69a2                	ld	s3,8(sp)
    80003ff2:	6145                	addi	sp,sp,48
    80003ff4:	8082                	ret

0000000080003ff6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ff6:	1101                	addi	sp,sp,-32
    80003ff8:	ec06                	sd	ra,24(sp)
    80003ffa:	e822                	sd	s0,16(sp)
    80003ffc:	e426                	sd	s1,8(sp)
    80003ffe:	e04a                	sd	s2,0(sp)
    80004000:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004002:	0001d517          	auipc	a0,0x1d
    80004006:	b3e50513          	addi	a0,a0,-1218 # 80020b40 <log>
    8000400a:	ffffd097          	auipc	ra,0xffffd
    8000400e:	bcc080e7          	jalr	-1076(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004012:	0001d497          	auipc	s1,0x1d
    80004016:	b2e48493          	addi	s1,s1,-1234 # 80020b40 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000401a:	4979                	li	s2,30
    8000401c:	a039                	j	8000402a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000401e:	85a6                	mv	a1,s1
    80004020:	8526                	mv	a0,s1
    80004022:	ffffe097          	auipc	ra,0xffffe
    80004026:	03a080e7          	jalr	58(ra) # 8000205c <sleep>
    if(log.committing){
    8000402a:	50dc                	lw	a5,36(s1)
    8000402c:	fbed                	bnez	a5,8000401e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000402e:	509c                	lw	a5,32(s1)
    80004030:	0017871b          	addiw	a4,a5,1
    80004034:	0007069b          	sext.w	a3,a4
    80004038:	0027179b          	slliw	a5,a4,0x2
    8000403c:	9fb9                	addw	a5,a5,a4
    8000403e:	0017979b          	slliw	a5,a5,0x1
    80004042:	54d8                	lw	a4,44(s1)
    80004044:	9fb9                	addw	a5,a5,a4
    80004046:	00f95963          	bge	s2,a5,80004058 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000404a:	85a6                	mv	a1,s1
    8000404c:	8526                	mv	a0,s1
    8000404e:	ffffe097          	auipc	ra,0xffffe
    80004052:	00e080e7          	jalr	14(ra) # 8000205c <sleep>
    80004056:	bfd1                	j	8000402a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004058:	0001d517          	auipc	a0,0x1d
    8000405c:	ae850513          	addi	a0,a0,-1304 # 80020b40 <log>
    80004060:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004062:	ffffd097          	auipc	ra,0xffffd
    80004066:	c28080e7          	jalr	-984(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000406a:	60e2                	ld	ra,24(sp)
    8000406c:	6442                	ld	s0,16(sp)
    8000406e:	64a2                	ld	s1,8(sp)
    80004070:	6902                	ld	s2,0(sp)
    80004072:	6105                	addi	sp,sp,32
    80004074:	8082                	ret

0000000080004076 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004076:	7139                	addi	sp,sp,-64
    80004078:	fc06                	sd	ra,56(sp)
    8000407a:	f822                	sd	s0,48(sp)
    8000407c:	f426                	sd	s1,40(sp)
    8000407e:	f04a                	sd	s2,32(sp)
    80004080:	ec4e                	sd	s3,24(sp)
    80004082:	e852                	sd	s4,16(sp)
    80004084:	e456                	sd	s5,8(sp)
    80004086:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004088:	0001d497          	auipc	s1,0x1d
    8000408c:	ab848493          	addi	s1,s1,-1352 # 80020b40 <log>
    80004090:	8526                	mv	a0,s1
    80004092:	ffffd097          	auipc	ra,0xffffd
    80004096:	b44080e7          	jalr	-1212(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000409a:	509c                	lw	a5,32(s1)
    8000409c:	37fd                	addiw	a5,a5,-1
    8000409e:	0007891b          	sext.w	s2,a5
    800040a2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800040a4:	50dc                	lw	a5,36(s1)
    800040a6:	e7b9                	bnez	a5,800040f4 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800040a8:	04091e63          	bnez	s2,80004104 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800040ac:	0001d497          	auipc	s1,0x1d
    800040b0:	a9448493          	addi	s1,s1,-1388 # 80020b40 <log>
    800040b4:	4785                	li	a5,1
    800040b6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040b8:	8526                	mv	a0,s1
    800040ba:	ffffd097          	auipc	ra,0xffffd
    800040be:	bd0080e7          	jalr	-1072(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040c2:	54dc                	lw	a5,44(s1)
    800040c4:	06f04763          	bgtz	a5,80004132 <end_op+0xbc>
    acquire(&log.lock);
    800040c8:	0001d497          	auipc	s1,0x1d
    800040cc:	a7848493          	addi	s1,s1,-1416 # 80020b40 <log>
    800040d0:	8526                	mv	a0,s1
    800040d2:	ffffd097          	auipc	ra,0xffffd
    800040d6:	b04080e7          	jalr	-1276(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800040da:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800040de:	8526                	mv	a0,s1
    800040e0:	ffffe097          	auipc	ra,0xffffe
    800040e4:	fe0080e7          	jalr	-32(ra) # 800020c0 <wakeup>
    release(&log.lock);
    800040e8:	8526                	mv	a0,s1
    800040ea:	ffffd097          	auipc	ra,0xffffd
    800040ee:	ba0080e7          	jalr	-1120(ra) # 80000c8a <release>
}
    800040f2:	a03d                	j	80004120 <end_op+0xaa>
    panic("log.committing");
    800040f4:	00004517          	auipc	a0,0x4
    800040f8:	55c50513          	addi	a0,a0,1372 # 80008650 <syscalls+0x200>
    800040fc:	ffffc097          	auipc	ra,0xffffc
    80004100:	442080e7          	jalr	1090(ra) # 8000053e <panic>
    wakeup(&log);
    80004104:	0001d497          	auipc	s1,0x1d
    80004108:	a3c48493          	addi	s1,s1,-1476 # 80020b40 <log>
    8000410c:	8526                	mv	a0,s1
    8000410e:	ffffe097          	auipc	ra,0xffffe
    80004112:	fb2080e7          	jalr	-78(ra) # 800020c0 <wakeup>
  release(&log.lock);
    80004116:	8526                	mv	a0,s1
    80004118:	ffffd097          	auipc	ra,0xffffd
    8000411c:	b72080e7          	jalr	-1166(ra) # 80000c8a <release>
}
    80004120:	70e2                	ld	ra,56(sp)
    80004122:	7442                	ld	s0,48(sp)
    80004124:	74a2                	ld	s1,40(sp)
    80004126:	7902                	ld	s2,32(sp)
    80004128:	69e2                	ld	s3,24(sp)
    8000412a:	6a42                	ld	s4,16(sp)
    8000412c:	6aa2                	ld	s5,8(sp)
    8000412e:	6121                	addi	sp,sp,64
    80004130:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004132:	0001da97          	auipc	s5,0x1d
    80004136:	a3ea8a93          	addi	s5,s5,-1474 # 80020b70 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000413a:	0001da17          	auipc	s4,0x1d
    8000413e:	a06a0a13          	addi	s4,s4,-1530 # 80020b40 <log>
    80004142:	018a2583          	lw	a1,24(s4)
    80004146:	012585bb          	addw	a1,a1,s2
    8000414a:	2585                	addiw	a1,a1,1
    8000414c:	028a2503          	lw	a0,40(s4)
    80004150:	fffff097          	auipc	ra,0xfffff
    80004154:	cca080e7          	jalr	-822(ra) # 80002e1a <bread>
    80004158:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000415a:	000aa583          	lw	a1,0(s5)
    8000415e:	028a2503          	lw	a0,40(s4)
    80004162:	fffff097          	auipc	ra,0xfffff
    80004166:	cb8080e7          	jalr	-840(ra) # 80002e1a <bread>
    8000416a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000416c:	40000613          	li	a2,1024
    80004170:	05850593          	addi	a1,a0,88
    80004174:	05848513          	addi	a0,s1,88
    80004178:	ffffd097          	auipc	ra,0xffffd
    8000417c:	bb6080e7          	jalr	-1098(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004180:	8526                	mv	a0,s1
    80004182:	fffff097          	auipc	ra,0xfffff
    80004186:	d8a080e7          	jalr	-630(ra) # 80002f0c <bwrite>
    brelse(from);
    8000418a:	854e                	mv	a0,s3
    8000418c:	fffff097          	auipc	ra,0xfffff
    80004190:	dbe080e7          	jalr	-578(ra) # 80002f4a <brelse>
    brelse(to);
    80004194:	8526                	mv	a0,s1
    80004196:	fffff097          	auipc	ra,0xfffff
    8000419a:	db4080e7          	jalr	-588(ra) # 80002f4a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000419e:	2905                	addiw	s2,s2,1
    800041a0:	0a91                	addi	s5,s5,4
    800041a2:	02ca2783          	lw	a5,44(s4)
    800041a6:	f8f94ee3          	blt	s2,a5,80004142 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800041aa:	00000097          	auipc	ra,0x0
    800041ae:	c6a080e7          	jalr	-918(ra) # 80003e14 <write_head>
    install_trans(0); // Now install writes to home locations
    800041b2:	4501                	li	a0,0
    800041b4:	00000097          	auipc	ra,0x0
    800041b8:	cda080e7          	jalr	-806(ra) # 80003e8e <install_trans>
    log.lh.n = 0;
    800041bc:	0001d797          	auipc	a5,0x1d
    800041c0:	9a07a823          	sw	zero,-1616(a5) # 80020b6c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800041c4:	00000097          	auipc	ra,0x0
    800041c8:	c50080e7          	jalr	-944(ra) # 80003e14 <write_head>
    800041cc:	bdf5                	j	800040c8 <end_op+0x52>

00000000800041ce <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041ce:	1101                	addi	sp,sp,-32
    800041d0:	ec06                	sd	ra,24(sp)
    800041d2:	e822                	sd	s0,16(sp)
    800041d4:	e426                	sd	s1,8(sp)
    800041d6:	e04a                	sd	s2,0(sp)
    800041d8:	1000                	addi	s0,sp,32
    800041da:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041dc:	0001d917          	auipc	s2,0x1d
    800041e0:	96490913          	addi	s2,s2,-1692 # 80020b40 <log>
    800041e4:	854a                	mv	a0,s2
    800041e6:	ffffd097          	auipc	ra,0xffffd
    800041ea:	9f0080e7          	jalr	-1552(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800041ee:	02c92603          	lw	a2,44(s2)
    800041f2:	47f5                	li	a5,29
    800041f4:	06c7c563          	blt	a5,a2,8000425e <log_write+0x90>
    800041f8:	0001d797          	auipc	a5,0x1d
    800041fc:	9647a783          	lw	a5,-1692(a5) # 80020b5c <log+0x1c>
    80004200:	37fd                	addiw	a5,a5,-1
    80004202:	04f65e63          	bge	a2,a5,8000425e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004206:	0001d797          	auipc	a5,0x1d
    8000420a:	95a7a783          	lw	a5,-1702(a5) # 80020b60 <log+0x20>
    8000420e:	06f05063          	blez	a5,8000426e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004212:	4781                	li	a5,0
    80004214:	06c05563          	blez	a2,8000427e <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004218:	44cc                	lw	a1,12(s1)
    8000421a:	0001d717          	auipc	a4,0x1d
    8000421e:	95670713          	addi	a4,a4,-1706 # 80020b70 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004222:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004224:	4314                	lw	a3,0(a4)
    80004226:	04b68c63          	beq	a3,a1,8000427e <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000422a:	2785                	addiw	a5,a5,1
    8000422c:	0711                	addi	a4,a4,4
    8000422e:	fef61be3          	bne	a2,a5,80004224 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004232:	0621                	addi	a2,a2,8
    80004234:	060a                	slli	a2,a2,0x2
    80004236:	0001d797          	auipc	a5,0x1d
    8000423a:	90a78793          	addi	a5,a5,-1782 # 80020b40 <log>
    8000423e:	963e                	add	a2,a2,a5
    80004240:	44dc                	lw	a5,12(s1)
    80004242:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004244:	8526                	mv	a0,s1
    80004246:	fffff097          	auipc	ra,0xfffff
    8000424a:	da2080e7          	jalr	-606(ra) # 80002fe8 <bpin>
    log.lh.n++;
    8000424e:	0001d717          	auipc	a4,0x1d
    80004252:	8f270713          	addi	a4,a4,-1806 # 80020b40 <log>
    80004256:	575c                	lw	a5,44(a4)
    80004258:	2785                	addiw	a5,a5,1
    8000425a:	d75c                	sw	a5,44(a4)
    8000425c:	a835                	j	80004298 <log_write+0xca>
    panic("too big a transaction");
    8000425e:	00004517          	auipc	a0,0x4
    80004262:	40250513          	addi	a0,a0,1026 # 80008660 <syscalls+0x210>
    80004266:	ffffc097          	auipc	ra,0xffffc
    8000426a:	2d8080e7          	jalr	728(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    8000426e:	00004517          	auipc	a0,0x4
    80004272:	40a50513          	addi	a0,a0,1034 # 80008678 <syscalls+0x228>
    80004276:	ffffc097          	auipc	ra,0xffffc
    8000427a:	2c8080e7          	jalr	712(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    8000427e:	00878713          	addi	a4,a5,8
    80004282:	00271693          	slli	a3,a4,0x2
    80004286:	0001d717          	auipc	a4,0x1d
    8000428a:	8ba70713          	addi	a4,a4,-1862 # 80020b40 <log>
    8000428e:	9736                	add	a4,a4,a3
    80004290:	44d4                	lw	a3,12(s1)
    80004292:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004294:	faf608e3          	beq	a2,a5,80004244 <log_write+0x76>
  }
  release(&log.lock);
    80004298:	0001d517          	auipc	a0,0x1d
    8000429c:	8a850513          	addi	a0,a0,-1880 # 80020b40 <log>
    800042a0:	ffffd097          	auipc	ra,0xffffd
    800042a4:	9ea080e7          	jalr	-1558(ra) # 80000c8a <release>
}
    800042a8:	60e2                	ld	ra,24(sp)
    800042aa:	6442                	ld	s0,16(sp)
    800042ac:	64a2                	ld	s1,8(sp)
    800042ae:	6902                	ld	s2,0(sp)
    800042b0:	6105                	addi	sp,sp,32
    800042b2:	8082                	ret

00000000800042b4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042b4:	1101                	addi	sp,sp,-32
    800042b6:	ec06                	sd	ra,24(sp)
    800042b8:	e822                	sd	s0,16(sp)
    800042ba:	e426                	sd	s1,8(sp)
    800042bc:	e04a                	sd	s2,0(sp)
    800042be:	1000                	addi	s0,sp,32
    800042c0:	84aa                	mv	s1,a0
    800042c2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800042c4:	00004597          	auipc	a1,0x4
    800042c8:	3d458593          	addi	a1,a1,980 # 80008698 <syscalls+0x248>
    800042cc:	0521                	addi	a0,a0,8
    800042ce:	ffffd097          	auipc	ra,0xffffd
    800042d2:	878080e7          	jalr	-1928(ra) # 80000b46 <initlock>
  lk->name = name;
    800042d6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042da:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042de:	0204a423          	sw	zero,40(s1)
}
    800042e2:	60e2                	ld	ra,24(sp)
    800042e4:	6442                	ld	s0,16(sp)
    800042e6:	64a2                	ld	s1,8(sp)
    800042e8:	6902                	ld	s2,0(sp)
    800042ea:	6105                	addi	sp,sp,32
    800042ec:	8082                	ret

00000000800042ee <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800042ee:	1101                	addi	sp,sp,-32
    800042f0:	ec06                	sd	ra,24(sp)
    800042f2:	e822                	sd	s0,16(sp)
    800042f4:	e426                	sd	s1,8(sp)
    800042f6:	e04a                	sd	s2,0(sp)
    800042f8:	1000                	addi	s0,sp,32
    800042fa:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042fc:	00850913          	addi	s2,a0,8
    80004300:	854a                	mv	a0,s2
    80004302:	ffffd097          	auipc	ra,0xffffd
    80004306:	8d4080e7          	jalr	-1836(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000430a:	409c                	lw	a5,0(s1)
    8000430c:	cb89                	beqz	a5,8000431e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000430e:	85ca                	mv	a1,s2
    80004310:	8526                	mv	a0,s1
    80004312:	ffffe097          	auipc	ra,0xffffe
    80004316:	d4a080e7          	jalr	-694(ra) # 8000205c <sleep>
  while (lk->locked) {
    8000431a:	409c                	lw	a5,0(s1)
    8000431c:	fbed                	bnez	a5,8000430e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000431e:	4785                	li	a5,1
    80004320:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004322:	ffffd097          	auipc	ra,0xffffd
    80004326:	692080e7          	jalr	1682(ra) # 800019b4 <myproc>
    8000432a:	591c                	lw	a5,48(a0)
    8000432c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000432e:	854a                	mv	a0,s2
    80004330:	ffffd097          	auipc	ra,0xffffd
    80004334:	95a080e7          	jalr	-1702(ra) # 80000c8a <release>
}
    80004338:	60e2                	ld	ra,24(sp)
    8000433a:	6442                	ld	s0,16(sp)
    8000433c:	64a2                	ld	s1,8(sp)
    8000433e:	6902                	ld	s2,0(sp)
    80004340:	6105                	addi	sp,sp,32
    80004342:	8082                	ret

0000000080004344 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004344:	1101                	addi	sp,sp,-32
    80004346:	ec06                	sd	ra,24(sp)
    80004348:	e822                	sd	s0,16(sp)
    8000434a:	e426                	sd	s1,8(sp)
    8000434c:	e04a                	sd	s2,0(sp)
    8000434e:	1000                	addi	s0,sp,32
    80004350:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004352:	00850913          	addi	s2,a0,8
    80004356:	854a                	mv	a0,s2
    80004358:	ffffd097          	auipc	ra,0xffffd
    8000435c:	87e080e7          	jalr	-1922(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004360:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004364:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004368:	8526                	mv	a0,s1
    8000436a:	ffffe097          	auipc	ra,0xffffe
    8000436e:	d56080e7          	jalr	-682(ra) # 800020c0 <wakeup>
  release(&lk->lk);
    80004372:	854a                	mv	a0,s2
    80004374:	ffffd097          	auipc	ra,0xffffd
    80004378:	916080e7          	jalr	-1770(ra) # 80000c8a <release>
}
    8000437c:	60e2                	ld	ra,24(sp)
    8000437e:	6442                	ld	s0,16(sp)
    80004380:	64a2                	ld	s1,8(sp)
    80004382:	6902                	ld	s2,0(sp)
    80004384:	6105                	addi	sp,sp,32
    80004386:	8082                	ret

0000000080004388 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004388:	7179                	addi	sp,sp,-48
    8000438a:	f406                	sd	ra,40(sp)
    8000438c:	f022                	sd	s0,32(sp)
    8000438e:	ec26                	sd	s1,24(sp)
    80004390:	e84a                	sd	s2,16(sp)
    80004392:	e44e                	sd	s3,8(sp)
    80004394:	1800                	addi	s0,sp,48
    80004396:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004398:	00850913          	addi	s2,a0,8
    8000439c:	854a                	mv	a0,s2
    8000439e:	ffffd097          	auipc	ra,0xffffd
    800043a2:	838080e7          	jalr	-1992(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043a6:	409c                	lw	a5,0(s1)
    800043a8:	ef99                	bnez	a5,800043c6 <holdingsleep+0x3e>
    800043aa:	4481                	li	s1,0
  release(&lk->lk);
    800043ac:	854a                	mv	a0,s2
    800043ae:	ffffd097          	auipc	ra,0xffffd
    800043b2:	8dc080e7          	jalr	-1828(ra) # 80000c8a <release>
  return r;
}
    800043b6:	8526                	mv	a0,s1
    800043b8:	70a2                	ld	ra,40(sp)
    800043ba:	7402                	ld	s0,32(sp)
    800043bc:	64e2                	ld	s1,24(sp)
    800043be:	6942                	ld	s2,16(sp)
    800043c0:	69a2                	ld	s3,8(sp)
    800043c2:	6145                	addi	sp,sp,48
    800043c4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800043c6:	0284a983          	lw	s3,40(s1)
    800043ca:	ffffd097          	auipc	ra,0xffffd
    800043ce:	5ea080e7          	jalr	1514(ra) # 800019b4 <myproc>
    800043d2:	5904                	lw	s1,48(a0)
    800043d4:	413484b3          	sub	s1,s1,s3
    800043d8:	0014b493          	seqz	s1,s1
    800043dc:	bfc1                	j	800043ac <holdingsleep+0x24>

00000000800043de <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043de:	1141                	addi	sp,sp,-16
    800043e0:	e406                	sd	ra,8(sp)
    800043e2:	e022                	sd	s0,0(sp)
    800043e4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043e6:	00004597          	auipc	a1,0x4
    800043ea:	2c258593          	addi	a1,a1,706 # 800086a8 <syscalls+0x258>
    800043ee:	0001d517          	auipc	a0,0x1d
    800043f2:	89a50513          	addi	a0,a0,-1894 # 80020c88 <ftable>
    800043f6:	ffffc097          	auipc	ra,0xffffc
    800043fa:	750080e7          	jalr	1872(ra) # 80000b46 <initlock>
}
    800043fe:	60a2                	ld	ra,8(sp)
    80004400:	6402                	ld	s0,0(sp)
    80004402:	0141                	addi	sp,sp,16
    80004404:	8082                	ret

0000000080004406 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004406:	1101                	addi	sp,sp,-32
    80004408:	ec06                	sd	ra,24(sp)
    8000440a:	e822                	sd	s0,16(sp)
    8000440c:	e426                	sd	s1,8(sp)
    8000440e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004410:	0001d517          	auipc	a0,0x1d
    80004414:	87850513          	addi	a0,a0,-1928 # 80020c88 <ftable>
    80004418:	ffffc097          	auipc	ra,0xffffc
    8000441c:	7be080e7          	jalr	1982(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004420:	0001d497          	auipc	s1,0x1d
    80004424:	88048493          	addi	s1,s1,-1920 # 80020ca0 <ftable+0x18>
    80004428:	0001e717          	auipc	a4,0x1e
    8000442c:	81870713          	addi	a4,a4,-2024 # 80021c40 <disk>
    if(f->ref == 0){
    80004430:	40dc                	lw	a5,4(s1)
    80004432:	cf99                	beqz	a5,80004450 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004434:	02848493          	addi	s1,s1,40
    80004438:	fee49ce3          	bne	s1,a4,80004430 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000443c:	0001d517          	auipc	a0,0x1d
    80004440:	84c50513          	addi	a0,a0,-1972 # 80020c88 <ftable>
    80004444:	ffffd097          	auipc	ra,0xffffd
    80004448:	846080e7          	jalr	-1978(ra) # 80000c8a <release>
  return 0;
    8000444c:	4481                	li	s1,0
    8000444e:	a819                	j	80004464 <filealloc+0x5e>
      f->ref = 1;
    80004450:	4785                	li	a5,1
    80004452:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004454:	0001d517          	auipc	a0,0x1d
    80004458:	83450513          	addi	a0,a0,-1996 # 80020c88 <ftable>
    8000445c:	ffffd097          	auipc	ra,0xffffd
    80004460:	82e080e7          	jalr	-2002(ra) # 80000c8a <release>
}
    80004464:	8526                	mv	a0,s1
    80004466:	60e2                	ld	ra,24(sp)
    80004468:	6442                	ld	s0,16(sp)
    8000446a:	64a2                	ld	s1,8(sp)
    8000446c:	6105                	addi	sp,sp,32
    8000446e:	8082                	ret

0000000080004470 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004470:	1101                	addi	sp,sp,-32
    80004472:	ec06                	sd	ra,24(sp)
    80004474:	e822                	sd	s0,16(sp)
    80004476:	e426                	sd	s1,8(sp)
    80004478:	1000                	addi	s0,sp,32
    8000447a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000447c:	0001d517          	auipc	a0,0x1d
    80004480:	80c50513          	addi	a0,a0,-2036 # 80020c88 <ftable>
    80004484:	ffffc097          	auipc	ra,0xffffc
    80004488:	752080e7          	jalr	1874(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000448c:	40dc                	lw	a5,4(s1)
    8000448e:	02f05263          	blez	a5,800044b2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004492:	2785                	addiw	a5,a5,1
    80004494:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004496:	0001c517          	auipc	a0,0x1c
    8000449a:	7f250513          	addi	a0,a0,2034 # 80020c88 <ftable>
    8000449e:	ffffc097          	auipc	ra,0xffffc
    800044a2:	7ec080e7          	jalr	2028(ra) # 80000c8a <release>
  return f;
}
    800044a6:	8526                	mv	a0,s1
    800044a8:	60e2                	ld	ra,24(sp)
    800044aa:	6442                	ld	s0,16(sp)
    800044ac:	64a2                	ld	s1,8(sp)
    800044ae:	6105                	addi	sp,sp,32
    800044b0:	8082                	ret
    panic("filedup");
    800044b2:	00004517          	auipc	a0,0x4
    800044b6:	1fe50513          	addi	a0,a0,510 # 800086b0 <syscalls+0x260>
    800044ba:	ffffc097          	auipc	ra,0xffffc
    800044be:	084080e7          	jalr	132(ra) # 8000053e <panic>

00000000800044c2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044c2:	7139                	addi	sp,sp,-64
    800044c4:	fc06                	sd	ra,56(sp)
    800044c6:	f822                	sd	s0,48(sp)
    800044c8:	f426                	sd	s1,40(sp)
    800044ca:	f04a                	sd	s2,32(sp)
    800044cc:	ec4e                	sd	s3,24(sp)
    800044ce:	e852                	sd	s4,16(sp)
    800044d0:	e456                	sd	s5,8(sp)
    800044d2:	0080                	addi	s0,sp,64
    800044d4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044d6:	0001c517          	auipc	a0,0x1c
    800044da:	7b250513          	addi	a0,a0,1970 # 80020c88 <ftable>
    800044de:	ffffc097          	auipc	ra,0xffffc
    800044e2:	6f8080e7          	jalr	1784(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800044e6:	40dc                	lw	a5,4(s1)
    800044e8:	06f05163          	blez	a5,8000454a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800044ec:	37fd                	addiw	a5,a5,-1
    800044ee:	0007871b          	sext.w	a4,a5
    800044f2:	c0dc                	sw	a5,4(s1)
    800044f4:	06e04363          	bgtz	a4,8000455a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800044f8:	0004a903          	lw	s2,0(s1)
    800044fc:	0094ca83          	lbu	s5,9(s1)
    80004500:	0104ba03          	ld	s4,16(s1)
    80004504:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004508:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000450c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004510:	0001c517          	auipc	a0,0x1c
    80004514:	77850513          	addi	a0,a0,1912 # 80020c88 <ftable>
    80004518:	ffffc097          	auipc	ra,0xffffc
    8000451c:	772080e7          	jalr	1906(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004520:	4785                	li	a5,1
    80004522:	04f90d63          	beq	s2,a5,8000457c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004526:	3979                	addiw	s2,s2,-2
    80004528:	4785                	li	a5,1
    8000452a:	0527e063          	bltu	a5,s2,8000456a <fileclose+0xa8>
    begin_op();
    8000452e:	00000097          	auipc	ra,0x0
    80004532:	ac8080e7          	jalr	-1336(ra) # 80003ff6 <begin_op>
    iput(ff.ip);
    80004536:	854e                	mv	a0,s3
    80004538:	fffff097          	auipc	ra,0xfffff
    8000453c:	2b6080e7          	jalr	694(ra) # 800037ee <iput>
    end_op();
    80004540:	00000097          	auipc	ra,0x0
    80004544:	b36080e7          	jalr	-1226(ra) # 80004076 <end_op>
    80004548:	a00d                	j	8000456a <fileclose+0xa8>
    panic("fileclose");
    8000454a:	00004517          	auipc	a0,0x4
    8000454e:	16e50513          	addi	a0,a0,366 # 800086b8 <syscalls+0x268>
    80004552:	ffffc097          	auipc	ra,0xffffc
    80004556:	fec080e7          	jalr	-20(ra) # 8000053e <panic>
    release(&ftable.lock);
    8000455a:	0001c517          	auipc	a0,0x1c
    8000455e:	72e50513          	addi	a0,a0,1838 # 80020c88 <ftable>
    80004562:	ffffc097          	auipc	ra,0xffffc
    80004566:	728080e7          	jalr	1832(ra) # 80000c8a <release>
  }
}
    8000456a:	70e2                	ld	ra,56(sp)
    8000456c:	7442                	ld	s0,48(sp)
    8000456e:	74a2                	ld	s1,40(sp)
    80004570:	7902                	ld	s2,32(sp)
    80004572:	69e2                	ld	s3,24(sp)
    80004574:	6a42                	ld	s4,16(sp)
    80004576:	6aa2                	ld	s5,8(sp)
    80004578:	6121                	addi	sp,sp,64
    8000457a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000457c:	85d6                	mv	a1,s5
    8000457e:	8552                	mv	a0,s4
    80004580:	00000097          	auipc	ra,0x0
    80004584:	34c080e7          	jalr	844(ra) # 800048cc <pipeclose>
    80004588:	b7cd                	j	8000456a <fileclose+0xa8>

000000008000458a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000458a:	715d                	addi	sp,sp,-80
    8000458c:	e486                	sd	ra,72(sp)
    8000458e:	e0a2                	sd	s0,64(sp)
    80004590:	fc26                	sd	s1,56(sp)
    80004592:	f84a                	sd	s2,48(sp)
    80004594:	f44e                	sd	s3,40(sp)
    80004596:	0880                	addi	s0,sp,80
    80004598:	84aa                	mv	s1,a0
    8000459a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000459c:	ffffd097          	auipc	ra,0xffffd
    800045a0:	418080e7          	jalr	1048(ra) # 800019b4 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800045a4:	409c                	lw	a5,0(s1)
    800045a6:	37f9                	addiw	a5,a5,-2
    800045a8:	4705                	li	a4,1
    800045aa:	04f76763          	bltu	a4,a5,800045f8 <filestat+0x6e>
    800045ae:	892a                	mv	s2,a0
    ilock(f->ip);
    800045b0:	6c88                	ld	a0,24(s1)
    800045b2:	fffff097          	auipc	ra,0xfffff
    800045b6:	082080e7          	jalr	130(ra) # 80003634 <ilock>
    stati(f->ip, &st);
    800045ba:	fb840593          	addi	a1,s0,-72
    800045be:	6c88                	ld	a0,24(s1)
    800045c0:	fffff097          	auipc	ra,0xfffff
    800045c4:	2fe080e7          	jalr	766(ra) # 800038be <stati>
    iunlock(f->ip);
    800045c8:	6c88                	ld	a0,24(s1)
    800045ca:	fffff097          	auipc	ra,0xfffff
    800045ce:	12c080e7          	jalr	300(ra) # 800036f6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800045d2:	46e1                	li	a3,24
    800045d4:	fb840613          	addi	a2,s0,-72
    800045d8:	85ce                	mv	a1,s3
    800045da:	05093503          	ld	a0,80(s2)
    800045de:	ffffd097          	auipc	ra,0xffffd
    800045e2:	092080e7          	jalr	146(ra) # 80001670 <copyout>
    800045e6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800045ea:	60a6                	ld	ra,72(sp)
    800045ec:	6406                	ld	s0,64(sp)
    800045ee:	74e2                	ld	s1,56(sp)
    800045f0:	7942                	ld	s2,48(sp)
    800045f2:	79a2                	ld	s3,40(sp)
    800045f4:	6161                	addi	sp,sp,80
    800045f6:	8082                	ret
  return -1;
    800045f8:	557d                	li	a0,-1
    800045fa:	bfc5                	j	800045ea <filestat+0x60>

00000000800045fc <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800045fc:	7179                	addi	sp,sp,-48
    800045fe:	f406                	sd	ra,40(sp)
    80004600:	f022                	sd	s0,32(sp)
    80004602:	ec26                	sd	s1,24(sp)
    80004604:	e84a                	sd	s2,16(sp)
    80004606:	e44e                	sd	s3,8(sp)
    80004608:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000460a:	00854783          	lbu	a5,8(a0)
    8000460e:	c3d5                	beqz	a5,800046b2 <fileread+0xb6>
    80004610:	84aa                	mv	s1,a0
    80004612:	89ae                	mv	s3,a1
    80004614:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004616:	411c                	lw	a5,0(a0)
    80004618:	4705                	li	a4,1
    8000461a:	04e78963          	beq	a5,a4,8000466c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000461e:	470d                	li	a4,3
    80004620:	04e78d63          	beq	a5,a4,8000467a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004624:	4709                	li	a4,2
    80004626:	06e79e63          	bne	a5,a4,800046a2 <fileread+0xa6>
    ilock(f->ip);
    8000462a:	6d08                	ld	a0,24(a0)
    8000462c:	fffff097          	auipc	ra,0xfffff
    80004630:	008080e7          	jalr	8(ra) # 80003634 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004634:	874a                	mv	a4,s2
    80004636:	5094                	lw	a3,32(s1)
    80004638:	864e                	mv	a2,s3
    8000463a:	4585                	li	a1,1
    8000463c:	6c88                	ld	a0,24(s1)
    8000463e:	fffff097          	auipc	ra,0xfffff
    80004642:	2aa080e7          	jalr	682(ra) # 800038e8 <readi>
    80004646:	892a                	mv	s2,a0
    80004648:	00a05563          	blez	a0,80004652 <fileread+0x56>
      f->off += r;
    8000464c:	509c                	lw	a5,32(s1)
    8000464e:	9fa9                	addw	a5,a5,a0
    80004650:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004652:	6c88                	ld	a0,24(s1)
    80004654:	fffff097          	auipc	ra,0xfffff
    80004658:	0a2080e7          	jalr	162(ra) # 800036f6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000465c:	854a                	mv	a0,s2
    8000465e:	70a2                	ld	ra,40(sp)
    80004660:	7402                	ld	s0,32(sp)
    80004662:	64e2                	ld	s1,24(sp)
    80004664:	6942                	ld	s2,16(sp)
    80004666:	69a2                	ld	s3,8(sp)
    80004668:	6145                	addi	sp,sp,48
    8000466a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000466c:	6908                	ld	a0,16(a0)
    8000466e:	00000097          	auipc	ra,0x0
    80004672:	3c6080e7          	jalr	966(ra) # 80004a34 <piperead>
    80004676:	892a                	mv	s2,a0
    80004678:	b7d5                	j	8000465c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000467a:	02451783          	lh	a5,36(a0)
    8000467e:	03079693          	slli	a3,a5,0x30
    80004682:	92c1                	srli	a3,a3,0x30
    80004684:	4725                	li	a4,9
    80004686:	02d76863          	bltu	a4,a3,800046b6 <fileread+0xba>
    8000468a:	0792                	slli	a5,a5,0x4
    8000468c:	0001c717          	auipc	a4,0x1c
    80004690:	55c70713          	addi	a4,a4,1372 # 80020be8 <devsw>
    80004694:	97ba                	add	a5,a5,a4
    80004696:	639c                	ld	a5,0(a5)
    80004698:	c38d                	beqz	a5,800046ba <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000469a:	4505                	li	a0,1
    8000469c:	9782                	jalr	a5
    8000469e:	892a                	mv	s2,a0
    800046a0:	bf75                	j	8000465c <fileread+0x60>
    panic("fileread");
    800046a2:	00004517          	auipc	a0,0x4
    800046a6:	02650513          	addi	a0,a0,38 # 800086c8 <syscalls+0x278>
    800046aa:	ffffc097          	auipc	ra,0xffffc
    800046ae:	e94080e7          	jalr	-364(ra) # 8000053e <panic>
    return -1;
    800046b2:	597d                	li	s2,-1
    800046b4:	b765                	j	8000465c <fileread+0x60>
      return -1;
    800046b6:	597d                	li	s2,-1
    800046b8:	b755                	j	8000465c <fileread+0x60>
    800046ba:	597d                	li	s2,-1
    800046bc:	b745                	j	8000465c <fileread+0x60>

00000000800046be <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800046be:	715d                	addi	sp,sp,-80
    800046c0:	e486                	sd	ra,72(sp)
    800046c2:	e0a2                	sd	s0,64(sp)
    800046c4:	fc26                	sd	s1,56(sp)
    800046c6:	f84a                	sd	s2,48(sp)
    800046c8:	f44e                	sd	s3,40(sp)
    800046ca:	f052                	sd	s4,32(sp)
    800046cc:	ec56                	sd	s5,24(sp)
    800046ce:	e85a                	sd	s6,16(sp)
    800046d0:	e45e                	sd	s7,8(sp)
    800046d2:	e062                	sd	s8,0(sp)
    800046d4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800046d6:	00954783          	lbu	a5,9(a0)
    800046da:	10078663          	beqz	a5,800047e6 <filewrite+0x128>
    800046de:	892a                	mv	s2,a0
    800046e0:	8aae                	mv	s5,a1
    800046e2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800046e4:	411c                	lw	a5,0(a0)
    800046e6:	4705                	li	a4,1
    800046e8:	02e78263          	beq	a5,a4,8000470c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046ec:	470d                	li	a4,3
    800046ee:	02e78663          	beq	a5,a4,8000471a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800046f2:	4709                	li	a4,2
    800046f4:	0ee79163          	bne	a5,a4,800047d6 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800046f8:	0ac05d63          	blez	a2,800047b2 <filewrite+0xf4>
    int i = 0;
    800046fc:	4981                	li	s3,0
    800046fe:	6b05                	lui	s6,0x1
    80004700:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004704:	6b85                	lui	s7,0x1
    80004706:	c00b8b9b          	addiw	s7,s7,-1024
    8000470a:	a861                	j	800047a2 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000470c:	6908                	ld	a0,16(a0)
    8000470e:	00000097          	auipc	ra,0x0
    80004712:	22e080e7          	jalr	558(ra) # 8000493c <pipewrite>
    80004716:	8a2a                	mv	s4,a0
    80004718:	a045                	j	800047b8 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000471a:	02451783          	lh	a5,36(a0)
    8000471e:	03079693          	slli	a3,a5,0x30
    80004722:	92c1                	srli	a3,a3,0x30
    80004724:	4725                	li	a4,9
    80004726:	0cd76263          	bltu	a4,a3,800047ea <filewrite+0x12c>
    8000472a:	0792                	slli	a5,a5,0x4
    8000472c:	0001c717          	auipc	a4,0x1c
    80004730:	4bc70713          	addi	a4,a4,1212 # 80020be8 <devsw>
    80004734:	97ba                	add	a5,a5,a4
    80004736:	679c                	ld	a5,8(a5)
    80004738:	cbdd                	beqz	a5,800047ee <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000473a:	4505                	li	a0,1
    8000473c:	9782                	jalr	a5
    8000473e:	8a2a                	mv	s4,a0
    80004740:	a8a5                	j	800047b8 <filewrite+0xfa>
    80004742:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004746:	00000097          	auipc	ra,0x0
    8000474a:	8b0080e7          	jalr	-1872(ra) # 80003ff6 <begin_op>
      ilock(f->ip);
    8000474e:	01893503          	ld	a0,24(s2)
    80004752:	fffff097          	auipc	ra,0xfffff
    80004756:	ee2080e7          	jalr	-286(ra) # 80003634 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000475a:	8762                	mv	a4,s8
    8000475c:	02092683          	lw	a3,32(s2)
    80004760:	01598633          	add	a2,s3,s5
    80004764:	4585                	li	a1,1
    80004766:	01893503          	ld	a0,24(s2)
    8000476a:	fffff097          	auipc	ra,0xfffff
    8000476e:	276080e7          	jalr	630(ra) # 800039e0 <writei>
    80004772:	84aa                	mv	s1,a0
    80004774:	00a05763          	blez	a0,80004782 <filewrite+0xc4>
        f->off += r;
    80004778:	02092783          	lw	a5,32(s2)
    8000477c:	9fa9                	addw	a5,a5,a0
    8000477e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004782:	01893503          	ld	a0,24(s2)
    80004786:	fffff097          	auipc	ra,0xfffff
    8000478a:	f70080e7          	jalr	-144(ra) # 800036f6 <iunlock>
      end_op();
    8000478e:	00000097          	auipc	ra,0x0
    80004792:	8e8080e7          	jalr	-1816(ra) # 80004076 <end_op>

      if(r != n1){
    80004796:	009c1f63          	bne	s8,s1,800047b4 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    8000479a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000479e:	0149db63          	bge	s3,s4,800047b4 <filewrite+0xf6>
      int n1 = n - i;
    800047a2:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800047a6:	84be                	mv	s1,a5
    800047a8:	2781                	sext.w	a5,a5
    800047aa:	f8fb5ce3          	bge	s6,a5,80004742 <filewrite+0x84>
    800047ae:	84de                	mv	s1,s7
    800047b0:	bf49                	j	80004742 <filewrite+0x84>
    int i = 0;
    800047b2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800047b4:	013a1f63          	bne	s4,s3,800047d2 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800047b8:	8552                	mv	a0,s4
    800047ba:	60a6                	ld	ra,72(sp)
    800047bc:	6406                	ld	s0,64(sp)
    800047be:	74e2                	ld	s1,56(sp)
    800047c0:	7942                	ld	s2,48(sp)
    800047c2:	79a2                	ld	s3,40(sp)
    800047c4:	7a02                	ld	s4,32(sp)
    800047c6:	6ae2                	ld	s5,24(sp)
    800047c8:	6b42                	ld	s6,16(sp)
    800047ca:	6ba2                	ld	s7,8(sp)
    800047cc:	6c02                	ld	s8,0(sp)
    800047ce:	6161                	addi	sp,sp,80
    800047d0:	8082                	ret
    ret = (i == n ? n : -1);
    800047d2:	5a7d                	li	s4,-1
    800047d4:	b7d5                	j	800047b8 <filewrite+0xfa>
    panic("filewrite");
    800047d6:	00004517          	auipc	a0,0x4
    800047da:	f0250513          	addi	a0,a0,-254 # 800086d8 <syscalls+0x288>
    800047de:	ffffc097          	auipc	ra,0xffffc
    800047e2:	d60080e7          	jalr	-672(ra) # 8000053e <panic>
    return -1;
    800047e6:	5a7d                	li	s4,-1
    800047e8:	bfc1                	j	800047b8 <filewrite+0xfa>
      return -1;
    800047ea:	5a7d                	li	s4,-1
    800047ec:	b7f1                	j	800047b8 <filewrite+0xfa>
    800047ee:	5a7d                	li	s4,-1
    800047f0:	b7e1                	j	800047b8 <filewrite+0xfa>

00000000800047f2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800047f2:	7179                	addi	sp,sp,-48
    800047f4:	f406                	sd	ra,40(sp)
    800047f6:	f022                	sd	s0,32(sp)
    800047f8:	ec26                	sd	s1,24(sp)
    800047fa:	e84a                	sd	s2,16(sp)
    800047fc:	e44e                	sd	s3,8(sp)
    800047fe:	e052                	sd	s4,0(sp)
    80004800:	1800                	addi	s0,sp,48
    80004802:	84aa                	mv	s1,a0
    80004804:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004806:	0005b023          	sd	zero,0(a1)
    8000480a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000480e:	00000097          	auipc	ra,0x0
    80004812:	bf8080e7          	jalr	-1032(ra) # 80004406 <filealloc>
    80004816:	e088                	sd	a0,0(s1)
    80004818:	c551                	beqz	a0,800048a4 <pipealloc+0xb2>
    8000481a:	00000097          	auipc	ra,0x0
    8000481e:	bec080e7          	jalr	-1044(ra) # 80004406 <filealloc>
    80004822:	00aa3023          	sd	a0,0(s4)
    80004826:	c92d                	beqz	a0,80004898 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004828:	ffffc097          	auipc	ra,0xffffc
    8000482c:	2be080e7          	jalr	702(ra) # 80000ae6 <kalloc>
    80004830:	892a                	mv	s2,a0
    80004832:	c125                	beqz	a0,80004892 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004834:	4985                	li	s3,1
    80004836:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000483a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000483e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004842:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004846:	00004597          	auipc	a1,0x4
    8000484a:	ea258593          	addi	a1,a1,-350 # 800086e8 <syscalls+0x298>
    8000484e:	ffffc097          	auipc	ra,0xffffc
    80004852:	2f8080e7          	jalr	760(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004856:	609c                	ld	a5,0(s1)
    80004858:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000485c:	609c                	ld	a5,0(s1)
    8000485e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004862:	609c                	ld	a5,0(s1)
    80004864:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004868:	609c                	ld	a5,0(s1)
    8000486a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000486e:	000a3783          	ld	a5,0(s4)
    80004872:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004876:	000a3783          	ld	a5,0(s4)
    8000487a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000487e:	000a3783          	ld	a5,0(s4)
    80004882:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004886:	000a3783          	ld	a5,0(s4)
    8000488a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000488e:	4501                	li	a0,0
    80004890:	a025                	j	800048b8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004892:	6088                	ld	a0,0(s1)
    80004894:	e501                	bnez	a0,8000489c <pipealloc+0xaa>
    80004896:	a039                	j	800048a4 <pipealloc+0xb2>
    80004898:	6088                	ld	a0,0(s1)
    8000489a:	c51d                	beqz	a0,800048c8 <pipealloc+0xd6>
    fileclose(*f0);
    8000489c:	00000097          	auipc	ra,0x0
    800048a0:	c26080e7          	jalr	-986(ra) # 800044c2 <fileclose>
  if(*f1)
    800048a4:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048a8:	557d                	li	a0,-1
  if(*f1)
    800048aa:	c799                	beqz	a5,800048b8 <pipealloc+0xc6>
    fileclose(*f1);
    800048ac:	853e                	mv	a0,a5
    800048ae:	00000097          	auipc	ra,0x0
    800048b2:	c14080e7          	jalr	-1004(ra) # 800044c2 <fileclose>
  return -1;
    800048b6:	557d                	li	a0,-1
}
    800048b8:	70a2                	ld	ra,40(sp)
    800048ba:	7402                	ld	s0,32(sp)
    800048bc:	64e2                	ld	s1,24(sp)
    800048be:	6942                	ld	s2,16(sp)
    800048c0:	69a2                	ld	s3,8(sp)
    800048c2:	6a02                	ld	s4,0(sp)
    800048c4:	6145                	addi	sp,sp,48
    800048c6:	8082                	ret
  return -1;
    800048c8:	557d                	li	a0,-1
    800048ca:	b7fd                	j	800048b8 <pipealloc+0xc6>

00000000800048cc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048cc:	1101                	addi	sp,sp,-32
    800048ce:	ec06                	sd	ra,24(sp)
    800048d0:	e822                	sd	s0,16(sp)
    800048d2:	e426                	sd	s1,8(sp)
    800048d4:	e04a                	sd	s2,0(sp)
    800048d6:	1000                	addi	s0,sp,32
    800048d8:	84aa                	mv	s1,a0
    800048da:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048dc:	ffffc097          	auipc	ra,0xffffc
    800048e0:	2fa080e7          	jalr	762(ra) # 80000bd6 <acquire>
  if(writable){
    800048e4:	02090d63          	beqz	s2,8000491e <pipeclose+0x52>
    pi->writeopen = 0;
    800048e8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800048ec:	21848513          	addi	a0,s1,536
    800048f0:	ffffd097          	auipc	ra,0xffffd
    800048f4:	7d0080e7          	jalr	2000(ra) # 800020c0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800048f8:	2204b783          	ld	a5,544(s1)
    800048fc:	eb95                	bnez	a5,80004930 <pipeclose+0x64>
    release(&pi->lock);
    800048fe:	8526                	mv	a0,s1
    80004900:	ffffc097          	auipc	ra,0xffffc
    80004904:	38a080e7          	jalr	906(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004908:	8526                	mv	a0,s1
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	0e0080e7          	jalr	224(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004912:	60e2                	ld	ra,24(sp)
    80004914:	6442                	ld	s0,16(sp)
    80004916:	64a2                	ld	s1,8(sp)
    80004918:	6902                	ld	s2,0(sp)
    8000491a:	6105                	addi	sp,sp,32
    8000491c:	8082                	ret
    pi->readopen = 0;
    8000491e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004922:	21c48513          	addi	a0,s1,540
    80004926:	ffffd097          	auipc	ra,0xffffd
    8000492a:	79a080e7          	jalr	1946(ra) # 800020c0 <wakeup>
    8000492e:	b7e9                	j	800048f8 <pipeclose+0x2c>
    release(&pi->lock);
    80004930:	8526                	mv	a0,s1
    80004932:	ffffc097          	auipc	ra,0xffffc
    80004936:	358080e7          	jalr	856(ra) # 80000c8a <release>
}
    8000493a:	bfe1                	j	80004912 <pipeclose+0x46>

000000008000493c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000493c:	711d                	addi	sp,sp,-96
    8000493e:	ec86                	sd	ra,88(sp)
    80004940:	e8a2                	sd	s0,80(sp)
    80004942:	e4a6                	sd	s1,72(sp)
    80004944:	e0ca                	sd	s2,64(sp)
    80004946:	fc4e                	sd	s3,56(sp)
    80004948:	f852                	sd	s4,48(sp)
    8000494a:	f456                	sd	s5,40(sp)
    8000494c:	f05a                	sd	s6,32(sp)
    8000494e:	ec5e                	sd	s7,24(sp)
    80004950:	e862                	sd	s8,16(sp)
    80004952:	1080                	addi	s0,sp,96
    80004954:	84aa                	mv	s1,a0
    80004956:	8aae                	mv	s5,a1
    80004958:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000495a:	ffffd097          	auipc	ra,0xffffd
    8000495e:	05a080e7          	jalr	90(ra) # 800019b4 <myproc>
    80004962:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004964:	8526                	mv	a0,s1
    80004966:	ffffc097          	auipc	ra,0xffffc
    8000496a:	270080e7          	jalr	624(ra) # 80000bd6 <acquire>
  while(i < n){
    8000496e:	0b405663          	blez	s4,80004a1a <pipewrite+0xde>
  int i = 0;
    80004972:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004974:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004976:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000497a:	21c48b93          	addi	s7,s1,540
    8000497e:	a089                	j	800049c0 <pipewrite+0x84>
      release(&pi->lock);
    80004980:	8526                	mv	a0,s1
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	308080e7          	jalr	776(ra) # 80000c8a <release>
      return -1;
    8000498a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000498c:	854a                	mv	a0,s2
    8000498e:	60e6                	ld	ra,88(sp)
    80004990:	6446                	ld	s0,80(sp)
    80004992:	64a6                	ld	s1,72(sp)
    80004994:	6906                	ld	s2,64(sp)
    80004996:	79e2                	ld	s3,56(sp)
    80004998:	7a42                	ld	s4,48(sp)
    8000499a:	7aa2                	ld	s5,40(sp)
    8000499c:	7b02                	ld	s6,32(sp)
    8000499e:	6be2                	ld	s7,24(sp)
    800049a0:	6c42                	ld	s8,16(sp)
    800049a2:	6125                	addi	sp,sp,96
    800049a4:	8082                	ret
      wakeup(&pi->nread);
    800049a6:	8562                	mv	a0,s8
    800049a8:	ffffd097          	auipc	ra,0xffffd
    800049ac:	718080e7          	jalr	1816(ra) # 800020c0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800049b0:	85a6                	mv	a1,s1
    800049b2:	855e                	mv	a0,s7
    800049b4:	ffffd097          	auipc	ra,0xffffd
    800049b8:	6a8080e7          	jalr	1704(ra) # 8000205c <sleep>
  while(i < n){
    800049bc:	07495063          	bge	s2,s4,80004a1c <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    800049c0:	2204a783          	lw	a5,544(s1)
    800049c4:	dfd5                	beqz	a5,80004980 <pipewrite+0x44>
    800049c6:	854e                	mv	a0,s3
    800049c8:	ffffe097          	auipc	ra,0xffffe
    800049cc:	93c080e7          	jalr	-1732(ra) # 80002304 <killed>
    800049d0:	f945                	bnez	a0,80004980 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800049d2:	2184a783          	lw	a5,536(s1)
    800049d6:	21c4a703          	lw	a4,540(s1)
    800049da:	2007879b          	addiw	a5,a5,512
    800049de:	fcf704e3          	beq	a4,a5,800049a6 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049e2:	4685                	li	a3,1
    800049e4:	01590633          	add	a2,s2,s5
    800049e8:	faf40593          	addi	a1,s0,-81
    800049ec:	0509b503          	ld	a0,80(s3)
    800049f0:	ffffd097          	auipc	ra,0xffffd
    800049f4:	d0c080e7          	jalr	-756(ra) # 800016fc <copyin>
    800049f8:	03650263          	beq	a0,s6,80004a1c <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800049fc:	21c4a783          	lw	a5,540(s1)
    80004a00:	0017871b          	addiw	a4,a5,1
    80004a04:	20e4ae23          	sw	a4,540(s1)
    80004a08:	1ff7f793          	andi	a5,a5,511
    80004a0c:	97a6                	add	a5,a5,s1
    80004a0e:	faf44703          	lbu	a4,-81(s0)
    80004a12:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a16:	2905                	addiw	s2,s2,1
    80004a18:	b755                	j	800049bc <pipewrite+0x80>
  int i = 0;
    80004a1a:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004a1c:	21848513          	addi	a0,s1,536
    80004a20:	ffffd097          	auipc	ra,0xffffd
    80004a24:	6a0080e7          	jalr	1696(ra) # 800020c0 <wakeup>
  release(&pi->lock);
    80004a28:	8526                	mv	a0,s1
    80004a2a:	ffffc097          	auipc	ra,0xffffc
    80004a2e:	260080e7          	jalr	608(ra) # 80000c8a <release>
  return i;
    80004a32:	bfa9                	j	8000498c <pipewrite+0x50>

0000000080004a34 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a34:	715d                	addi	sp,sp,-80
    80004a36:	e486                	sd	ra,72(sp)
    80004a38:	e0a2                	sd	s0,64(sp)
    80004a3a:	fc26                	sd	s1,56(sp)
    80004a3c:	f84a                	sd	s2,48(sp)
    80004a3e:	f44e                	sd	s3,40(sp)
    80004a40:	f052                	sd	s4,32(sp)
    80004a42:	ec56                	sd	s5,24(sp)
    80004a44:	e85a                	sd	s6,16(sp)
    80004a46:	0880                	addi	s0,sp,80
    80004a48:	84aa                	mv	s1,a0
    80004a4a:	892e                	mv	s2,a1
    80004a4c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a4e:	ffffd097          	auipc	ra,0xffffd
    80004a52:	f66080e7          	jalr	-154(ra) # 800019b4 <myproc>
    80004a56:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004a58:	8526                	mv	a0,s1
    80004a5a:	ffffc097          	auipc	ra,0xffffc
    80004a5e:	17c080e7          	jalr	380(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a62:	2184a703          	lw	a4,536(s1)
    80004a66:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a6a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a6e:	02f71763          	bne	a4,a5,80004a9c <piperead+0x68>
    80004a72:	2244a783          	lw	a5,548(s1)
    80004a76:	c39d                	beqz	a5,80004a9c <piperead+0x68>
    if(killed(pr)){
    80004a78:	8552                	mv	a0,s4
    80004a7a:	ffffe097          	auipc	ra,0xffffe
    80004a7e:	88a080e7          	jalr	-1910(ra) # 80002304 <killed>
    80004a82:	e941                	bnez	a0,80004b12 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a84:	85a6                	mv	a1,s1
    80004a86:	854e                	mv	a0,s3
    80004a88:	ffffd097          	auipc	ra,0xffffd
    80004a8c:	5d4080e7          	jalr	1492(ra) # 8000205c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a90:	2184a703          	lw	a4,536(s1)
    80004a94:	21c4a783          	lw	a5,540(s1)
    80004a98:	fcf70de3          	beq	a4,a5,80004a72 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a9c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a9e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004aa0:	05505363          	blez	s5,80004ae6 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004aa4:	2184a783          	lw	a5,536(s1)
    80004aa8:	21c4a703          	lw	a4,540(s1)
    80004aac:	02f70d63          	beq	a4,a5,80004ae6 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ab0:	0017871b          	addiw	a4,a5,1
    80004ab4:	20e4ac23          	sw	a4,536(s1)
    80004ab8:	1ff7f793          	andi	a5,a5,511
    80004abc:	97a6                	add	a5,a5,s1
    80004abe:	0187c783          	lbu	a5,24(a5)
    80004ac2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ac6:	4685                	li	a3,1
    80004ac8:	fbf40613          	addi	a2,s0,-65
    80004acc:	85ca                	mv	a1,s2
    80004ace:	050a3503          	ld	a0,80(s4)
    80004ad2:	ffffd097          	auipc	ra,0xffffd
    80004ad6:	b9e080e7          	jalr	-1122(ra) # 80001670 <copyout>
    80004ada:	01650663          	beq	a0,s6,80004ae6 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ade:	2985                	addiw	s3,s3,1
    80004ae0:	0905                	addi	s2,s2,1
    80004ae2:	fd3a91e3          	bne	s5,s3,80004aa4 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ae6:	21c48513          	addi	a0,s1,540
    80004aea:	ffffd097          	auipc	ra,0xffffd
    80004aee:	5d6080e7          	jalr	1494(ra) # 800020c0 <wakeup>
  release(&pi->lock);
    80004af2:	8526                	mv	a0,s1
    80004af4:	ffffc097          	auipc	ra,0xffffc
    80004af8:	196080e7          	jalr	406(ra) # 80000c8a <release>
  return i;
}
    80004afc:	854e                	mv	a0,s3
    80004afe:	60a6                	ld	ra,72(sp)
    80004b00:	6406                	ld	s0,64(sp)
    80004b02:	74e2                	ld	s1,56(sp)
    80004b04:	7942                	ld	s2,48(sp)
    80004b06:	79a2                	ld	s3,40(sp)
    80004b08:	7a02                	ld	s4,32(sp)
    80004b0a:	6ae2                	ld	s5,24(sp)
    80004b0c:	6b42                	ld	s6,16(sp)
    80004b0e:	6161                	addi	sp,sp,80
    80004b10:	8082                	ret
      release(&pi->lock);
    80004b12:	8526                	mv	a0,s1
    80004b14:	ffffc097          	auipc	ra,0xffffc
    80004b18:	176080e7          	jalr	374(ra) # 80000c8a <release>
      return -1;
    80004b1c:	59fd                	li	s3,-1
    80004b1e:	bff9                	j	80004afc <piperead+0xc8>

0000000080004b20 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004b20:	1141                	addi	sp,sp,-16
    80004b22:	e422                	sd	s0,8(sp)
    80004b24:	0800                	addi	s0,sp,16
    80004b26:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004b28:	8905                	andi	a0,a0,1
    80004b2a:	c111                	beqz	a0,80004b2e <flags2perm+0xe>
      perm = PTE_X;
    80004b2c:	4521                	li	a0,8
    if(flags & 0x2)
    80004b2e:	8b89                	andi	a5,a5,2
    80004b30:	c399                	beqz	a5,80004b36 <flags2perm+0x16>
      perm |= PTE_W;
    80004b32:	00456513          	ori	a0,a0,4
    return perm;
}
    80004b36:	6422                	ld	s0,8(sp)
    80004b38:	0141                	addi	sp,sp,16
    80004b3a:	8082                	ret

0000000080004b3c <exec>:

int
exec(char *path, char **argv)
{
    80004b3c:	de010113          	addi	sp,sp,-544
    80004b40:	20113c23          	sd	ra,536(sp)
    80004b44:	20813823          	sd	s0,528(sp)
    80004b48:	20913423          	sd	s1,520(sp)
    80004b4c:	21213023          	sd	s2,512(sp)
    80004b50:	ffce                	sd	s3,504(sp)
    80004b52:	fbd2                	sd	s4,496(sp)
    80004b54:	f7d6                	sd	s5,488(sp)
    80004b56:	f3da                	sd	s6,480(sp)
    80004b58:	efde                	sd	s7,472(sp)
    80004b5a:	ebe2                	sd	s8,464(sp)
    80004b5c:	e7e6                	sd	s9,456(sp)
    80004b5e:	e3ea                	sd	s10,448(sp)
    80004b60:	ff6e                	sd	s11,440(sp)
    80004b62:	1400                	addi	s0,sp,544
    80004b64:	892a                	mv	s2,a0
    80004b66:	dea43423          	sd	a0,-536(s0)
    80004b6a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b6e:	ffffd097          	auipc	ra,0xffffd
    80004b72:	e46080e7          	jalr	-442(ra) # 800019b4 <myproc>
    80004b76:	84aa                	mv	s1,a0

  begin_op();
    80004b78:	fffff097          	auipc	ra,0xfffff
    80004b7c:	47e080e7          	jalr	1150(ra) # 80003ff6 <begin_op>

  if((ip = namei(path)) == 0){
    80004b80:	854a                	mv	a0,s2
    80004b82:	fffff097          	auipc	ra,0xfffff
    80004b86:	258080e7          	jalr	600(ra) # 80003dda <namei>
    80004b8a:	c93d                	beqz	a0,80004c00 <exec+0xc4>
    80004b8c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004b8e:	fffff097          	auipc	ra,0xfffff
    80004b92:	aa6080e7          	jalr	-1370(ra) # 80003634 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004b96:	04000713          	li	a4,64
    80004b9a:	4681                	li	a3,0
    80004b9c:	e5040613          	addi	a2,s0,-432
    80004ba0:	4581                	li	a1,0
    80004ba2:	8556                	mv	a0,s5
    80004ba4:	fffff097          	auipc	ra,0xfffff
    80004ba8:	d44080e7          	jalr	-700(ra) # 800038e8 <readi>
    80004bac:	04000793          	li	a5,64
    80004bb0:	00f51a63          	bne	a0,a5,80004bc4 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004bb4:	e5042703          	lw	a4,-432(s0)
    80004bb8:	464c47b7          	lui	a5,0x464c4
    80004bbc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004bc0:	04f70663          	beq	a4,a5,80004c0c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004bc4:	8556                	mv	a0,s5
    80004bc6:	fffff097          	auipc	ra,0xfffff
    80004bca:	cd0080e7          	jalr	-816(ra) # 80003896 <iunlockput>
    end_op();
    80004bce:	fffff097          	auipc	ra,0xfffff
    80004bd2:	4a8080e7          	jalr	1192(ra) # 80004076 <end_op>
  }
  return -1;
    80004bd6:	557d                	li	a0,-1
}
    80004bd8:	21813083          	ld	ra,536(sp)
    80004bdc:	21013403          	ld	s0,528(sp)
    80004be0:	20813483          	ld	s1,520(sp)
    80004be4:	20013903          	ld	s2,512(sp)
    80004be8:	79fe                	ld	s3,504(sp)
    80004bea:	7a5e                	ld	s4,496(sp)
    80004bec:	7abe                	ld	s5,488(sp)
    80004bee:	7b1e                	ld	s6,480(sp)
    80004bf0:	6bfe                	ld	s7,472(sp)
    80004bf2:	6c5e                	ld	s8,464(sp)
    80004bf4:	6cbe                	ld	s9,456(sp)
    80004bf6:	6d1e                	ld	s10,448(sp)
    80004bf8:	7dfa                	ld	s11,440(sp)
    80004bfa:	22010113          	addi	sp,sp,544
    80004bfe:	8082                	ret
    end_op();
    80004c00:	fffff097          	auipc	ra,0xfffff
    80004c04:	476080e7          	jalr	1142(ra) # 80004076 <end_op>
    return -1;
    80004c08:	557d                	li	a0,-1
    80004c0a:	b7f9                	j	80004bd8 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c0c:	8526                	mv	a0,s1
    80004c0e:	ffffd097          	auipc	ra,0xffffd
    80004c12:	e6a080e7          	jalr	-406(ra) # 80001a78 <proc_pagetable>
    80004c16:	8b2a                	mv	s6,a0
    80004c18:	d555                	beqz	a0,80004bc4 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c1a:	e7042783          	lw	a5,-400(s0)
    80004c1e:	e8845703          	lhu	a4,-376(s0)
    80004c22:	c735                	beqz	a4,80004c8e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c24:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c26:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004c2a:	6a05                	lui	s4,0x1
    80004c2c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004c30:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004c34:	6d85                	lui	s11,0x1
    80004c36:	7d7d                	lui	s10,0xfffff
    80004c38:	a481                	j	80004e78 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004c3a:	00004517          	auipc	a0,0x4
    80004c3e:	ab650513          	addi	a0,a0,-1354 # 800086f0 <syscalls+0x2a0>
    80004c42:	ffffc097          	auipc	ra,0xffffc
    80004c46:	8fc080e7          	jalr	-1796(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c4a:	874a                	mv	a4,s2
    80004c4c:	009c86bb          	addw	a3,s9,s1
    80004c50:	4581                	li	a1,0
    80004c52:	8556                	mv	a0,s5
    80004c54:	fffff097          	auipc	ra,0xfffff
    80004c58:	c94080e7          	jalr	-876(ra) # 800038e8 <readi>
    80004c5c:	2501                	sext.w	a0,a0
    80004c5e:	1aa91a63          	bne	s2,a0,80004e12 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80004c62:	009d84bb          	addw	s1,s11,s1
    80004c66:	013d09bb          	addw	s3,s10,s3
    80004c6a:	1f74f763          	bgeu	s1,s7,80004e58 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80004c6e:	02049593          	slli	a1,s1,0x20
    80004c72:	9181                	srli	a1,a1,0x20
    80004c74:	95e2                	add	a1,a1,s8
    80004c76:	855a                	mv	a0,s6
    80004c78:	ffffc097          	auipc	ra,0xffffc
    80004c7c:	3ec080e7          	jalr	1004(ra) # 80001064 <walkaddr>
    80004c80:	862a                	mv	a2,a0
    if(pa == 0)
    80004c82:	dd45                	beqz	a0,80004c3a <exec+0xfe>
      n = PGSIZE;
    80004c84:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004c86:	fd49f2e3          	bgeu	s3,s4,80004c4a <exec+0x10e>
      n = sz - i;
    80004c8a:	894e                	mv	s2,s3
    80004c8c:	bf7d                	j	80004c4a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c8e:	4901                	li	s2,0
  iunlockput(ip);
    80004c90:	8556                	mv	a0,s5
    80004c92:	fffff097          	auipc	ra,0xfffff
    80004c96:	c04080e7          	jalr	-1020(ra) # 80003896 <iunlockput>
  end_op();
    80004c9a:	fffff097          	auipc	ra,0xfffff
    80004c9e:	3dc080e7          	jalr	988(ra) # 80004076 <end_op>
  p = myproc();
    80004ca2:	ffffd097          	auipc	ra,0xffffd
    80004ca6:	d12080e7          	jalr	-750(ra) # 800019b4 <myproc>
    80004caa:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004cac:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004cb0:	6785                	lui	a5,0x1
    80004cb2:	17fd                	addi	a5,a5,-1
    80004cb4:	993e                	add	s2,s2,a5
    80004cb6:	77fd                	lui	a5,0xfffff
    80004cb8:	00f977b3          	and	a5,s2,a5
    80004cbc:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004cc0:	4691                	li	a3,4
    80004cc2:	6609                	lui	a2,0x2
    80004cc4:	963e                	add	a2,a2,a5
    80004cc6:	85be                	mv	a1,a5
    80004cc8:	855a                	mv	a0,s6
    80004cca:	ffffc097          	auipc	ra,0xffffc
    80004cce:	74e080e7          	jalr	1870(ra) # 80001418 <uvmalloc>
    80004cd2:	8c2a                	mv	s8,a0
  ip = 0;
    80004cd4:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004cd6:	12050e63          	beqz	a0,80004e12 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004cda:	75f9                	lui	a1,0xffffe
    80004cdc:	95aa                	add	a1,a1,a0
    80004cde:	855a                	mv	a0,s6
    80004ce0:	ffffd097          	auipc	ra,0xffffd
    80004ce4:	95e080e7          	jalr	-1698(ra) # 8000163e <uvmclear>
  stackbase = sp - PGSIZE;
    80004ce8:	7afd                	lui	s5,0xfffff
    80004cea:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004cec:	df043783          	ld	a5,-528(s0)
    80004cf0:	6388                	ld	a0,0(a5)
    80004cf2:	c925                	beqz	a0,80004d62 <exec+0x226>
    80004cf4:	e9040993          	addi	s3,s0,-368
    80004cf8:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004cfc:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004cfe:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d00:	ffffc097          	auipc	ra,0xffffc
    80004d04:	14e080e7          	jalr	334(ra) # 80000e4e <strlen>
    80004d08:	0015079b          	addiw	a5,a0,1
    80004d0c:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d10:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004d14:	13596663          	bltu	s2,s5,80004e40 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d18:	df043d83          	ld	s11,-528(s0)
    80004d1c:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004d20:	8552                	mv	a0,s4
    80004d22:	ffffc097          	auipc	ra,0xffffc
    80004d26:	12c080e7          	jalr	300(ra) # 80000e4e <strlen>
    80004d2a:	0015069b          	addiw	a3,a0,1
    80004d2e:	8652                	mv	a2,s4
    80004d30:	85ca                	mv	a1,s2
    80004d32:	855a                	mv	a0,s6
    80004d34:	ffffd097          	auipc	ra,0xffffd
    80004d38:	93c080e7          	jalr	-1732(ra) # 80001670 <copyout>
    80004d3c:	10054663          	bltz	a0,80004e48 <exec+0x30c>
    ustack[argc] = sp;
    80004d40:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004d44:	0485                	addi	s1,s1,1
    80004d46:	008d8793          	addi	a5,s11,8
    80004d4a:	def43823          	sd	a5,-528(s0)
    80004d4e:	008db503          	ld	a0,8(s11)
    80004d52:	c911                	beqz	a0,80004d66 <exec+0x22a>
    if(argc >= MAXARG)
    80004d54:	09a1                	addi	s3,s3,8
    80004d56:	fb3c95e3          	bne	s9,s3,80004d00 <exec+0x1c4>
  sz = sz1;
    80004d5a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004d5e:	4a81                	li	s5,0
    80004d60:	a84d                	j	80004e12 <exec+0x2d6>
  sp = sz;
    80004d62:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d64:	4481                	li	s1,0
  ustack[argc] = 0;
    80004d66:	00349793          	slli	a5,s1,0x3
    80004d6a:	f9040713          	addi	a4,s0,-112
    80004d6e:	97ba                	add	a5,a5,a4
    80004d70:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdd018>
  sp -= (argc+1) * sizeof(uint64);
    80004d74:	00148693          	addi	a3,s1,1
    80004d78:	068e                	slli	a3,a3,0x3
    80004d7a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004d7e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004d82:	01597663          	bgeu	s2,s5,80004d8e <exec+0x252>
  sz = sz1;
    80004d86:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004d8a:	4a81                	li	s5,0
    80004d8c:	a059                	j	80004e12 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004d8e:	e9040613          	addi	a2,s0,-368
    80004d92:	85ca                	mv	a1,s2
    80004d94:	855a                	mv	a0,s6
    80004d96:	ffffd097          	auipc	ra,0xffffd
    80004d9a:	8da080e7          	jalr	-1830(ra) # 80001670 <copyout>
    80004d9e:	0a054963          	bltz	a0,80004e50 <exec+0x314>
  p->trapframe->a1 = sp;
    80004da2:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004da6:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004daa:	de843783          	ld	a5,-536(s0)
    80004dae:	0007c703          	lbu	a4,0(a5)
    80004db2:	cf11                	beqz	a4,80004dce <exec+0x292>
    80004db4:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004db6:	02f00693          	li	a3,47
    80004dba:	a039                	j	80004dc8 <exec+0x28c>
      last = s+1;
    80004dbc:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004dc0:	0785                	addi	a5,a5,1
    80004dc2:	fff7c703          	lbu	a4,-1(a5)
    80004dc6:	c701                	beqz	a4,80004dce <exec+0x292>
    if(*s == '/')
    80004dc8:	fed71ce3          	bne	a4,a3,80004dc0 <exec+0x284>
    80004dcc:	bfc5                	j	80004dbc <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80004dce:	4641                	li	a2,16
    80004dd0:	de843583          	ld	a1,-536(s0)
    80004dd4:	158b8513          	addi	a0,s7,344
    80004dd8:	ffffc097          	auipc	ra,0xffffc
    80004ddc:	044080e7          	jalr	68(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80004de0:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004de4:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004de8:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004dec:	058bb783          	ld	a5,88(s7)
    80004df0:	e6843703          	ld	a4,-408(s0)
    80004df4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004df6:	058bb783          	ld	a5,88(s7)
    80004dfa:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004dfe:	85ea                	mv	a1,s10
    80004e00:	ffffd097          	auipc	ra,0xffffd
    80004e04:	d14080e7          	jalr	-748(ra) # 80001b14 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e08:	0004851b          	sext.w	a0,s1
    80004e0c:	b3f1                	j	80004bd8 <exec+0x9c>
    80004e0e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004e12:	df843583          	ld	a1,-520(s0)
    80004e16:	855a                	mv	a0,s6
    80004e18:	ffffd097          	auipc	ra,0xffffd
    80004e1c:	cfc080e7          	jalr	-772(ra) # 80001b14 <proc_freepagetable>
  if(ip){
    80004e20:	da0a92e3          	bnez	s5,80004bc4 <exec+0x88>
  return -1;
    80004e24:	557d                	li	a0,-1
    80004e26:	bb4d                	j	80004bd8 <exec+0x9c>
    80004e28:	df243c23          	sd	s2,-520(s0)
    80004e2c:	b7dd                	j	80004e12 <exec+0x2d6>
    80004e2e:	df243c23          	sd	s2,-520(s0)
    80004e32:	b7c5                	j	80004e12 <exec+0x2d6>
    80004e34:	df243c23          	sd	s2,-520(s0)
    80004e38:	bfe9                	j	80004e12 <exec+0x2d6>
    80004e3a:	df243c23          	sd	s2,-520(s0)
    80004e3e:	bfd1                	j	80004e12 <exec+0x2d6>
  sz = sz1;
    80004e40:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e44:	4a81                	li	s5,0
    80004e46:	b7f1                	j	80004e12 <exec+0x2d6>
  sz = sz1;
    80004e48:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e4c:	4a81                	li	s5,0
    80004e4e:	b7d1                	j	80004e12 <exec+0x2d6>
  sz = sz1;
    80004e50:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e54:	4a81                	li	s5,0
    80004e56:	bf75                	j	80004e12 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e58:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e5c:	e0843783          	ld	a5,-504(s0)
    80004e60:	0017869b          	addiw	a3,a5,1
    80004e64:	e0d43423          	sd	a3,-504(s0)
    80004e68:	e0043783          	ld	a5,-512(s0)
    80004e6c:	0387879b          	addiw	a5,a5,56
    80004e70:	e8845703          	lhu	a4,-376(s0)
    80004e74:	e0e6dee3          	bge	a3,a4,80004c90 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e78:	2781                	sext.w	a5,a5
    80004e7a:	e0f43023          	sd	a5,-512(s0)
    80004e7e:	03800713          	li	a4,56
    80004e82:	86be                	mv	a3,a5
    80004e84:	e1840613          	addi	a2,s0,-488
    80004e88:	4581                	li	a1,0
    80004e8a:	8556                	mv	a0,s5
    80004e8c:	fffff097          	auipc	ra,0xfffff
    80004e90:	a5c080e7          	jalr	-1444(ra) # 800038e8 <readi>
    80004e94:	03800793          	li	a5,56
    80004e98:	f6f51be3          	bne	a0,a5,80004e0e <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80004e9c:	e1842783          	lw	a5,-488(s0)
    80004ea0:	4705                	li	a4,1
    80004ea2:	fae79de3          	bne	a5,a4,80004e5c <exec+0x320>
    if(ph.memsz < ph.filesz)
    80004ea6:	e4043483          	ld	s1,-448(s0)
    80004eaa:	e3843783          	ld	a5,-456(s0)
    80004eae:	f6f4ede3          	bltu	s1,a5,80004e28 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004eb2:	e2843783          	ld	a5,-472(s0)
    80004eb6:	94be                	add	s1,s1,a5
    80004eb8:	f6f4ebe3          	bltu	s1,a5,80004e2e <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    80004ebc:	de043703          	ld	a4,-544(s0)
    80004ec0:	8ff9                	and	a5,a5,a4
    80004ec2:	fbad                	bnez	a5,80004e34 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ec4:	e1c42503          	lw	a0,-484(s0)
    80004ec8:	00000097          	auipc	ra,0x0
    80004ecc:	c58080e7          	jalr	-936(ra) # 80004b20 <flags2perm>
    80004ed0:	86aa                	mv	a3,a0
    80004ed2:	8626                	mv	a2,s1
    80004ed4:	85ca                	mv	a1,s2
    80004ed6:	855a                	mv	a0,s6
    80004ed8:	ffffc097          	auipc	ra,0xffffc
    80004edc:	540080e7          	jalr	1344(ra) # 80001418 <uvmalloc>
    80004ee0:	dea43c23          	sd	a0,-520(s0)
    80004ee4:	d939                	beqz	a0,80004e3a <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ee6:	e2843c03          	ld	s8,-472(s0)
    80004eea:	e2042c83          	lw	s9,-480(s0)
    80004eee:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004ef2:	f60b83e3          	beqz	s7,80004e58 <exec+0x31c>
    80004ef6:	89de                	mv	s3,s7
    80004ef8:	4481                	li	s1,0
    80004efa:	bb95                	j	80004c6e <exec+0x132>

0000000080004efc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004efc:	7179                	addi	sp,sp,-48
    80004efe:	f406                	sd	ra,40(sp)
    80004f00:	f022                	sd	s0,32(sp)
    80004f02:	ec26                	sd	s1,24(sp)
    80004f04:	e84a                	sd	s2,16(sp)
    80004f06:	1800                	addi	s0,sp,48
    80004f08:	892e                	mv	s2,a1
    80004f0a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f0c:	fdc40593          	addi	a1,s0,-36
    80004f10:	ffffe097          	auipc	ra,0xffffe
    80004f14:	bb8080e7          	jalr	-1096(ra) # 80002ac8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f18:	fdc42703          	lw	a4,-36(s0)
    80004f1c:	47bd                	li	a5,15
    80004f1e:	02e7eb63          	bltu	a5,a4,80004f54 <argfd+0x58>
    80004f22:	ffffd097          	auipc	ra,0xffffd
    80004f26:	a92080e7          	jalr	-1390(ra) # 800019b4 <myproc>
    80004f2a:	fdc42703          	lw	a4,-36(s0)
    80004f2e:	01a70793          	addi	a5,a4,26
    80004f32:	078e                	slli	a5,a5,0x3
    80004f34:	953e                	add	a0,a0,a5
    80004f36:	611c                	ld	a5,0(a0)
    80004f38:	c385                	beqz	a5,80004f58 <argfd+0x5c>
    return -1;
  if(pfd)
    80004f3a:	00090463          	beqz	s2,80004f42 <argfd+0x46>
    *pfd = fd;
    80004f3e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f42:	4501                	li	a0,0
  if(pf)
    80004f44:	c091                	beqz	s1,80004f48 <argfd+0x4c>
    *pf = f;
    80004f46:	e09c                	sd	a5,0(s1)
}
    80004f48:	70a2                	ld	ra,40(sp)
    80004f4a:	7402                	ld	s0,32(sp)
    80004f4c:	64e2                	ld	s1,24(sp)
    80004f4e:	6942                	ld	s2,16(sp)
    80004f50:	6145                	addi	sp,sp,48
    80004f52:	8082                	ret
    return -1;
    80004f54:	557d                	li	a0,-1
    80004f56:	bfcd                	j	80004f48 <argfd+0x4c>
    80004f58:	557d                	li	a0,-1
    80004f5a:	b7fd                	j	80004f48 <argfd+0x4c>

0000000080004f5c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f5c:	1101                	addi	sp,sp,-32
    80004f5e:	ec06                	sd	ra,24(sp)
    80004f60:	e822                	sd	s0,16(sp)
    80004f62:	e426                	sd	s1,8(sp)
    80004f64:	1000                	addi	s0,sp,32
    80004f66:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f68:	ffffd097          	auipc	ra,0xffffd
    80004f6c:	a4c080e7          	jalr	-1460(ra) # 800019b4 <myproc>
    80004f70:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f72:	0d050793          	addi	a5,a0,208
    80004f76:	4501                	li	a0,0
    80004f78:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f7a:	6398                	ld	a4,0(a5)
    80004f7c:	cb19                	beqz	a4,80004f92 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f7e:	2505                	addiw	a0,a0,1
    80004f80:	07a1                	addi	a5,a5,8
    80004f82:	fed51ce3          	bne	a0,a3,80004f7a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f86:	557d                	li	a0,-1
}
    80004f88:	60e2                	ld	ra,24(sp)
    80004f8a:	6442                	ld	s0,16(sp)
    80004f8c:	64a2                	ld	s1,8(sp)
    80004f8e:	6105                	addi	sp,sp,32
    80004f90:	8082                	ret
      p->ofile[fd] = f;
    80004f92:	01a50793          	addi	a5,a0,26
    80004f96:	078e                	slli	a5,a5,0x3
    80004f98:	963e                	add	a2,a2,a5
    80004f9a:	e204                	sd	s1,0(a2)
      return fd;
    80004f9c:	b7f5                	j	80004f88 <fdalloc+0x2c>

0000000080004f9e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004f9e:	715d                	addi	sp,sp,-80
    80004fa0:	e486                	sd	ra,72(sp)
    80004fa2:	e0a2                	sd	s0,64(sp)
    80004fa4:	fc26                	sd	s1,56(sp)
    80004fa6:	f84a                	sd	s2,48(sp)
    80004fa8:	f44e                	sd	s3,40(sp)
    80004faa:	f052                	sd	s4,32(sp)
    80004fac:	ec56                	sd	s5,24(sp)
    80004fae:	e85a                	sd	s6,16(sp)
    80004fb0:	0880                	addi	s0,sp,80
    80004fb2:	8b2e                	mv	s6,a1
    80004fb4:	89b2                	mv	s3,a2
    80004fb6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004fb8:	fb040593          	addi	a1,s0,-80
    80004fbc:	fffff097          	auipc	ra,0xfffff
    80004fc0:	e3c080e7          	jalr	-452(ra) # 80003df8 <nameiparent>
    80004fc4:	84aa                	mv	s1,a0
    80004fc6:	14050f63          	beqz	a0,80005124 <create+0x186>
    return 0;

  ilock(dp);
    80004fca:	ffffe097          	auipc	ra,0xffffe
    80004fce:	66a080e7          	jalr	1642(ra) # 80003634 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004fd2:	4601                	li	a2,0
    80004fd4:	fb040593          	addi	a1,s0,-80
    80004fd8:	8526                	mv	a0,s1
    80004fda:	fffff097          	auipc	ra,0xfffff
    80004fde:	b3e080e7          	jalr	-1218(ra) # 80003b18 <dirlookup>
    80004fe2:	8aaa                	mv	s5,a0
    80004fe4:	c931                	beqz	a0,80005038 <create+0x9a>
    iunlockput(dp);
    80004fe6:	8526                	mv	a0,s1
    80004fe8:	fffff097          	auipc	ra,0xfffff
    80004fec:	8ae080e7          	jalr	-1874(ra) # 80003896 <iunlockput>
    ilock(ip);
    80004ff0:	8556                	mv	a0,s5
    80004ff2:	ffffe097          	auipc	ra,0xffffe
    80004ff6:	642080e7          	jalr	1602(ra) # 80003634 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004ffa:	000b059b          	sext.w	a1,s6
    80004ffe:	4789                	li	a5,2
    80005000:	02f59563          	bne	a1,a5,8000502a <create+0x8c>
    80005004:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd15c>
    80005008:	37f9                	addiw	a5,a5,-2
    8000500a:	17c2                	slli	a5,a5,0x30
    8000500c:	93c1                	srli	a5,a5,0x30
    8000500e:	4705                	li	a4,1
    80005010:	00f76d63          	bltu	a4,a5,8000502a <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005014:	8556                	mv	a0,s5
    80005016:	60a6                	ld	ra,72(sp)
    80005018:	6406                	ld	s0,64(sp)
    8000501a:	74e2                	ld	s1,56(sp)
    8000501c:	7942                	ld	s2,48(sp)
    8000501e:	79a2                	ld	s3,40(sp)
    80005020:	7a02                	ld	s4,32(sp)
    80005022:	6ae2                	ld	s5,24(sp)
    80005024:	6b42                	ld	s6,16(sp)
    80005026:	6161                	addi	sp,sp,80
    80005028:	8082                	ret
    iunlockput(ip);
    8000502a:	8556                	mv	a0,s5
    8000502c:	fffff097          	auipc	ra,0xfffff
    80005030:	86a080e7          	jalr	-1942(ra) # 80003896 <iunlockput>
    return 0;
    80005034:	4a81                	li	s5,0
    80005036:	bff9                	j	80005014 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005038:	85da                	mv	a1,s6
    8000503a:	4088                	lw	a0,0(s1)
    8000503c:	ffffe097          	auipc	ra,0xffffe
    80005040:	45c080e7          	jalr	1116(ra) # 80003498 <ialloc>
    80005044:	8a2a                	mv	s4,a0
    80005046:	c539                	beqz	a0,80005094 <create+0xf6>
  ilock(ip);
    80005048:	ffffe097          	auipc	ra,0xffffe
    8000504c:	5ec080e7          	jalr	1516(ra) # 80003634 <ilock>
  ip->major = major;
    80005050:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005054:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005058:	4905                	li	s2,1
    8000505a:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000505e:	8552                	mv	a0,s4
    80005060:	ffffe097          	auipc	ra,0xffffe
    80005064:	50a080e7          	jalr	1290(ra) # 8000356a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005068:	000b059b          	sext.w	a1,s6
    8000506c:	03258b63          	beq	a1,s2,800050a2 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005070:	004a2603          	lw	a2,4(s4)
    80005074:	fb040593          	addi	a1,s0,-80
    80005078:	8526                	mv	a0,s1
    8000507a:	fffff097          	auipc	ra,0xfffff
    8000507e:	cae080e7          	jalr	-850(ra) # 80003d28 <dirlink>
    80005082:	06054f63          	bltz	a0,80005100 <create+0x162>
  iunlockput(dp);
    80005086:	8526                	mv	a0,s1
    80005088:	fffff097          	auipc	ra,0xfffff
    8000508c:	80e080e7          	jalr	-2034(ra) # 80003896 <iunlockput>
  return ip;
    80005090:	8ad2                	mv	s5,s4
    80005092:	b749                	j	80005014 <create+0x76>
    iunlockput(dp);
    80005094:	8526                	mv	a0,s1
    80005096:	fffff097          	auipc	ra,0xfffff
    8000509a:	800080e7          	jalr	-2048(ra) # 80003896 <iunlockput>
    return 0;
    8000509e:	8ad2                	mv	s5,s4
    800050a0:	bf95                	j	80005014 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050a2:	004a2603          	lw	a2,4(s4)
    800050a6:	00003597          	auipc	a1,0x3
    800050aa:	66a58593          	addi	a1,a1,1642 # 80008710 <syscalls+0x2c0>
    800050ae:	8552                	mv	a0,s4
    800050b0:	fffff097          	auipc	ra,0xfffff
    800050b4:	c78080e7          	jalr	-904(ra) # 80003d28 <dirlink>
    800050b8:	04054463          	bltz	a0,80005100 <create+0x162>
    800050bc:	40d0                	lw	a2,4(s1)
    800050be:	00003597          	auipc	a1,0x3
    800050c2:	65a58593          	addi	a1,a1,1626 # 80008718 <syscalls+0x2c8>
    800050c6:	8552                	mv	a0,s4
    800050c8:	fffff097          	auipc	ra,0xfffff
    800050cc:	c60080e7          	jalr	-928(ra) # 80003d28 <dirlink>
    800050d0:	02054863          	bltz	a0,80005100 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800050d4:	004a2603          	lw	a2,4(s4)
    800050d8:	fb040593          	addi	a1,s0,-80
    800050dc:	8526                	mv	a0,s1
    800050de:	fffff097          	auipc	ra,0xfffff
    800050e2:	c4a080e7          	jalr	-950(ra) # 80003d28 <dirlink>
    800050e6:	00054d63          	bltz	a0,80005100 <create+0x162>
    dp->nlink++;  // for ".."
    800050ea:	04a4d783          	lhu	a5,74(s1)
    800050ee:	2785                	addiw	a5,a5,1
    800050f0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800050f4:	8526                	mv	a0,s1
    800050f6:	ffffe097          	auipc	ra,0xffffe
    800050fa:	474080e7          	jalr	1140(ra) # 8000356a <iupdate>
    800050fe:	b761                	j	80005086 <create+0xe8>
  ip->nlink = 0;
    80005100:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005104:	8552                	mv	a0,s4
    80005106:	ffffe097          	auipc	ra,0xffffe
    8000510a:	464080e7          	jalr	1124(ra) # 8000356a <iupdate>
  iunlockput(ip);
    8000510e:	8552                	mv	a0,s4
    80005110:	ffffe097          	auipc	ra,0xffffe
    80005114:	786080e7          	jalr	1926(ra) # 80003896 <iunlockput>
  iunlockput(dp);
    80005118:	8526                	mv	a0,s1
    8000511a:	ffffe097          	auipc	ra,0xffffe
    8000511e:	77c080e7          	jalr	1916(ra) # 80003896 <iunlockput>
  return 0;
    80005122:	bdcd                	j	80005014 <create+0x76>
    return 0;
    80005124:	8aaa                	mv	s5,a0
    80005126:	b5fd                	j	80005014 <create+0x76>

0000000080005128 <sys_dup>:
{
    80005128:	7179                	addi	sp,sp,-48
    8000512a:	f406                	sd	ra,40(sp)
    8000512c:	f022                	sd	s0,32(sp)
    8000512e:	ec26                	sd	s1,24(sp)
    80005130:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005132:	fd840613          	addi	a2,s0,-40
    80005136:	4581                	li	a1,0
    80005138:	4501                	li	a0,0
    8000513a:	00000097          	auipc	ra,0x0
    8000513e:	dc2080e7          	jalr	-574(ra) # 80004efc <argfd>
    return -1;
    80005142:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005144:	02054363          	bltz	a0,8000516a <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005148:	fd843503          	ld	a0,-40(s0)
    8000514c:	00000097          	auipc	ra,0x0
    80005150:	e10080e7          	jalr	-496(ra) # 80004f5c <fdalloc>
    80005154:	84aa                	mv	s1,a0
    return -1;
    80005156:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005158:	00054963          	bltz	a0,8000516a <sys_dup+0x42>
  filedup(f);
    8000515c:	fd843503          	ld	a0,-40(s0)
    80005160:	fffff097          	auipc	ra,0xfffff
    80005164:	310080e7          	jalr	784(ra) # 80004470 <filedup>
  return fd;
    80005168:	87a6                	mv	a5,s1
}
    8000516a:	853e                	mv	a0,a5
    8000516c:	70a2                	ld	ra,40(sp)
    8000516e:	7402                	ld	s0,32(sp)
    80005170:	64e2                	ld	s1,24(sp)
    80005172:	6145                	addi	sp,sp,48
    80005174:	8082                	ret

0000000080005176 <sys_read>:
{
    80005176:	7179                	addi	sp,sp,-48
    80005178:	f406                	sd	ra,40(sp)
    8000517a:	f022                	sd	s0,32(sp)
    8000517c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000517e:	fd840593          	addi	a1,s0,-40
    80005182:	4505                	li	a0,1
    80005184:	ffffe097          	auipc	ra,0xffffe
    80005188:	964080e7          	jalr	-1692(ra) # 80002ae8 <argaddr>
  argint(2, &n);
    8000518c:	fe440593          	addi	a1,s0,-28
    80005190:	4509                	li	a0,2
    80005192:	ffffe097          	auipc	ra,0xffffe
    80005196:	936080e7          	jalr	-1738(ra) # 80002ac8 <argint>
  if(argfd(0, 0, &f) < 0)
    8000519a:	fe840613          	addi	a2,s0,-24
    8000519e:	4581                	li	a1,0
    800051a0:	4501                	li	a0,0
    800051a2:	00000097          	auipc	ra,0x0
    800051a6:	d5a080e7          	jalr	-678(ra) # 80004efc <argfd>
    800051aa:	87aa                	mv	a5,a0
    return -1;
    800051ac:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051ae:	0007cc63          	bltz	a5,800051c6 <sys_read+0x50>
  return fileread(f, p, n);
    800051b2:	fe442603          	lw	a2,-28(s0)
    800051b6:	fd843583          	ld	a1,-40(s0)
    800051ba:	fe843503          	ld	a0,-24(s0)
    800051be:	fffff097          	auipc	ra,0xfffff
    800051c2:	43e080e7          	jalr	1086(ra) # 800045fc <fileread>
}
    800051c6:	70a2                	ld	ra,40(sp)
    800051c8:	7402                	ld	s0,32(sp)
    800051ca:	6145                	addi	sp,sp,48
    800051cc:	8082                	ret

00000000800051ce <sys_write>:
{
    800051ce:	7179                	addi	sp,sp,-48
    800051d0:	f406                	sd	ra,40(sp)
    800051d2:	f022                	sd	s0,32(sp)
    800051d4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051d6:	fd840593          	addi	a1,s0,-40
    800051da:	4505                	li	a0,1
    800051dc:	ffffe097          	auipc	ra,0xffffe
    800051e0:	90c080e7          	jalr	-1780(ra) # 80002ae8 <argaddr>
  argint(2, &n);
    800051e4:	fe440593          	addi	a1,s0,-28
    800051e8:	4509                	li	a0,2
    800051ea:	ffffe097          	auipc	ra,0xffffe
    800051ee:	8de080e7          	jalr	-1826(ra) # 80002ac8 <argint>
  if(argfd(0, 0, &f) < 0)
    800051f2:	fe840613          	addi	a2,s0,-24
    800051f6:	4581                	li	a1,0
    800051f8:	4501                	li	a0,0
    800051fa:	00000097          	auipc	ra,0x0
    800051fe:	d02080e7          	jalr	-766(ra) # 80004efc <argfd>
    80005202:	87aa                	mv	a5,a0
    return -1;
    80005204:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005206:	0007cc63          	bltz	a5,8000521e <sys_write+0x50>
  return filewrite(f, p, n);
    8000520a:	fe442603          	lw	a2,-28(s0)
    8000520e:	fd843583          	ld	a1,-40(s0)
    80005212:	fe843503          	ld	a0,-24(s0)
    80005216:	fffff097          	auipc	ra,0xfffff
    8000521a:	4a8080e7          	jalr	1192(ra) # 800046be <filewrite>
}
    8000521e:	70a2                	ld	ra,40(sp)
    80005220:	7402                	ld	s0,32(sp)
    80005222:	6145                	addi	sp,sp,48
    80005224:	8082                	ret

0000000080005226 <sys_close>:
{
    80005226:	1101                	addi	sp,sp,-32
    80005228:	ec06                	sd	ra,24(sp)
    8000522a:	e822                	sd	s0,16(sp)
    8000522c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000522e:	fe040613          	addi	a2,s0,-32
    80005232:	fec40593          	addi	a1,s0,-20
    80005236:	4501                	li	a0,0
    80005238:	00000097          	auipc	ra,0x0
    8000523c:	cc4080e7          	jalr	-828(ra) # 80004efc <argfd>
    return -1;
    80005240:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005242:	02054463          	bltz	a0,8000526a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005246:	ffffc097          	auipc	ra,0xffffc
    8000524a:	76e080e7          	jalr	1902(ra) # 800019b4 <myproc>
    8000524e:	fec42783          	lw	a5,-20(s0)
    80005252:	07e9                	addi	a5,a5,26
    80005254:	078e                	slli	a5,a5,0x3
    80005256:	97aa                	add	a5,a5,a0
    80005258:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000525c:	fe043503          	ld	a0,-32(s0)
    80005260:	fffff097          	auipc	ra,0xfffff
    80005264:	262080e7          	jalr	610(ra) # 800044c2 <fileclose>
  return 0;
    80005268:	4781                	li	a5,0
}
    8000526a:	853e                	mv	a0,a5
    8000526c:	60e2                	ld	ra,24(sp)
    8000526e:	6442                	ld	s0,16(sp)
    80005270:	6105                	addi	sp,sp,32
    80005272:	8082                	ret

0000000080005274 <sys_fstat>:
{
    80005274:	1101                	addi	sp,sp,-32
    80005276:	ec06                	sd	ra,24(sp)
    80005278:	e822                	sd	s0,16(sp)
    8000527a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000527c:	fe040593          	addi	a1,s0,-32
    80005280:	4505                	li	a0,1
    80005282:	ffffe097          	auipc	ra,0xffffe
    80005286:	866080e7          	jalr	-1946(ra) # 80002ae8 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000528a:	fe840613          	addi	a2,s0,-24
    8000528e:	4581                	li	a1,0
    80005290:	4501                	li	a0,0
    80005292:	00000097          	auipc	ra,0x0
    80005296:	c6a080e7          	jalr	-918(ra) # 80004efc <argfd>
    8000529a:	87aa                	mv	a5,a0
    return -1;
    8000529c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000529e:	0007ca63          	bltz	a5,800052b2 <sys_fstat+0x3e>
  return filestat(f, st);
    800052a2:	fe043583          	ld	a1,-32(s0)
    800052a6:	fe843503          	ld	a0,-24(s0)
    800052aa:	fffff097          	auipc	ra,0xfffff
    800052ae:	2e0080e7          	jalr	736(ra) # 8000458a <filestat>
}
    800052b2:	60e2                	ld	ra,24(sp)
    800052b4:	6442                	ld	s0,16(sp)
    800052b6:	6105                	addi	sp,sp,32
    800052b8:	8082                	ret

00000000800052ba <sys_link>:
{
    800052ba:	7169                	addi	sp,sp,-304
    800052bc:	f606                	sd	ra,296(sp)
    800052be:	f222                	sd	s0,288(sp)
    800052c0:	ee26                	sd	s1,280(sp)
    800052c2:	ea4a                	sd	s2,272(sp)
    800052c4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052c6:	08000613          	li	a2,128
    800052ca:	ed040593          	addi	a1,s0,-304
    800052ce:	4501                	li	a0,0
    800052d0:	ffffe097          	auipc	ra,0xffffe
    800052d4:	838080e7          	jalr	-1992(ra) # 80002b08 <argstr>
    return -1;
    800052d8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052da:	10054e63          	bltz	a0,800053f6 <sys_link+0x13c>
    800052de:	08000613          	li	a2,128
    800052e2:	f5040593          	addi	a1,s0,-176
    800052e6:	4505                	li	a0,1
    800052e8:	ffffe097          	auipc	ra,0xffffe
    800052ec:	820080e7          	jalr	-2016(ra) # 80002b08 <argstr>
    return -1;
    800052f0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052f2:	10054263          	bltz	a0,800053f6 <sys_link+0x13c>
  begin_op();
    800052f6:	fffff097          	auipc	ra,0xfffff
    800052fa:	d00080e7          	jalr	-768(ra) # 80003ff6 <begin_op>
  if((ip = namei(old)) == 0){
    800052fe:	ed040513          	addi	a0,s0,-304
    80005302:	fffff097          	auipc	ra,0xfffff
    80005306:	ad8080e7          	jalr	-1320(ra) # 80003dda <namei>
    8000530a:	84aa                	mv	s1,a0
    8000530c:	c551                	beqz	a0,80005398 <sys_link+0xde>
  ilock(ip);
    8000530e:	ffffe097          	auipc	ra,0xffffe
    80005312:	326080e7          	jalr	806(ra) # 80003634 <ilock>
  if(ip->type == T_DIR){
    80005316:	04449703          	lh	a4,68(s1)
    8000531a:	4785                	li	a5,1
    8000531c:	08f70463          	beq	a4,a5,800053a4 <sys_link+0xea>
  ip->nlink++;
    80005320:	04a4d783          	lhu	a5,74(s1)
    80005324:	2785                	addiw	a5,a5,1
    80005326:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000532a:	8526                	mv	a0,s1
    8000532c:	ffffe097          	auipc	ra,0xffffe
    80005330:	23e080e7          	jalr	574(ra) # 8000356a <iupdate>
  iunlock(ip);
    80005334:	8526                	mv	a0,s1
    80005336:	ffffe097          	auipc	ra,0xffffe
    8000533a:	3c0080e7          	jalr	960(ra) # 800036f6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000533e:	fd040593          	addi	a1,s0,-48
    80005342:	f5040513          	addi	a0,s0,-176
    80005346:	fffff097          	auipc	ra,0xfffff
    8000534a:	ab2080e7          	jalr	-1358(ra) # 80003df8 <nameiparent>
    8000534e:	892a                	mv	s2,a0
    80005350:	c935                	beqz	a0,800053c4 <sys_link+0x10a>
  ilock(dp);
    80005352:	ffffe097          	auipc	ra,0xffffe
    80005356:	2e2080e7          	jalr	738(ra) # 80003634 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000535a:	00092703          	lw	a4,0(s2)
    8000535e:	409c                	lw	a5,0(s1)
    80005360:	04f71d63          	bne	a4,a5,800053ba <sys_link+0x100>
    80005364:	40d0                	lw	a2,4(s1)
    80005366:	fd040593          	addi	a1,s0,-48
    8000536a:	854a                	mv	a0,s2
    8000536c:	fffff097          	auipc	ra,0xfffff
    80005370:	9bc080e7          	jalr	-1604(ra) # 80003d28 <dirlink>
    80005374:	04054363          	bltz	a0,800053ba <sys_link+0x100>
  iunlockput(dp);
    80005378:	854a                	mv	a0,s2
    8000537a:	ffffe097          	auipc	ra,0xffffe
    8000537e:	51c080e7          	jalr	1308(ra) # 80003896 <iunlockput>
  iput(ip);
    80005382:	8526                	mv	a0,s1
    80005384:	ffffe097          	auipc	ra,0xffffe
    80005388:	46a080e7          	jalr	1130(ra) # 800037ee <iput>
  end_op();
    8000538c:	fffff097          	auipc	ra,0xfffff
    80005390:	cea080e7          	jalr	-790(ra) # 80004076 <end_op>
  return 0;
    80005394:	4781                	li	a5,0
    80005396:	a085                	j	800053f6 <sys_link+0x13c>
    end_op();
    80005398:	fffff097          	auipc	ra,0xfffff
    8000539c:	cde080e7          	jalr	-802(ra) # 80004076 <end_op>
    return -1;
    800053a0:	57fd                	li	a5,-1
    800053a2:	a891                	j	800053f6 <sys_link+0x13c>
    iunlockput(ip);
    800053a4:	8526                	mv	a0,s1
    800053a6:	ffffe097          	auipc	ra,0xffffe
    800053aa:	4f0080e7          	jalr	1264(ra) # 80003896 <iunlockput>
    end_op();
    800053ae:	fffff097          	auipc	ra,0xfffff
    800053b2:	cc8080e7          	jalr	-824(ra) # 80004076 <end_op>
    return -1;
    800053b6:	57fd                	li	a5,-1
    800053b8:	a83d                	j	800053f6 <sys_link+0x13c>
    iunlockput(dp);
    800053ba:	854a                	mv	a0,s2
    800053bc:	ffffe097          	auipc	ra,0xffffe
    800053c0:	4da080e7          	jalr	1242(ra) # 80003896 <iunlockput>
  ilock(ip);
    800053c4:	8526                	mv	a0,s1
    800053c6:	ffffe097          	auipc	ra,0xffffe
    800053ca:	26e080e7          	jalr	622(ra) # 80003634 <ilock>
  ip->nlink--;
    800053ce:	04a4d783          	lhu	a5,74(s1)
    800053d2:	37fd                	addiw	a5,a5,-1
    800053d4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053d8:	8526                	mv	a0,s1
    800053da:	ffffe097          	auipc	ra,0xffffe
    800053de:	190080e7          	jalr	400(ra) # 8000356a <iupdate>
  iunlockput(ip);
    800053e2:	8526                	mv	a0,s1
    800053e4:	ffffe097          	auipc	ra,0xffffe
    800053e8:	4b2080e7          	jalr	1202(ra) # 80003896 <iunlockput>
  end_op();
    800053ec:	fffff097          	auipc	ra,0xfffff
    800053f0:	c8a080e7          	jalr	-886(ra) # 80004076 <end_op>
  return -1;
    800053f4:	57fd                	li	a5,-1
}
    800053f6:	853e                	mv	a0,a5
    800053f8:	70b2                	ld	ra,296(sp)
    800053fa:	7412                	ld	s0,288(sp)
    800053fc:	64f2                	ld	s1,280(sp)
    800053fe:	6952                	ld	s2,272(sp)
    80005400:	6155                	addi	sp,sp,304
    80005402:	8082                	ret

0000000080005404 <sys_unlink>:
{
    80005404:	7151                	addi	sp,sp,-240
    80005406:	f586                	sd	ra,232(sp)
    80005408:	f1a2                	sd	s0,224(sp)
    8000540a:	eda6                	sd	s1,216(sp)
    8000540c:	e9ca                	sd	s2,208(sp)
    8000540e:	e5ce                	sd	s3,200(sp)
    80005410:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005412:	08000613          	li	a2,128
    80005416:	f3040593          	addi	a1,s0,-208
    8000541a:	4501                	li	a0,0
    8000541c:	ffffd097          	auipc	ra,0xffffd
    80005420:	6ec080e7          	jalr	1772(ra) # 80002b08 <argstr>
    80005424:	18054163          	bltz	a0,800055a6 <sys_unlink+0x1a2>
  begin_op();
    80005428:	fffff097          	auipc	ra,0xfffff
    8000542c:	bce080e7          	jalr	-1074(ra) # 80003ff6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005430:	fb040593          	addi	a1,s0,-80
    80005434:	f3040513          	addi	a0,s0,-208
    80005438:	fffff097          	auipc	ra,0xfffff
    8000543c:	9c0080e7          	jalr	-1600(ra) # 80003df8 <nameiparent>
    80005440:	84aa                	mv	s1,a0
    80005442:	c979                	beqz	a0,80005518 <sys_unlink+0x114>
  ilock(dp);
    80005444:	ffffe097          	auipc	ra,0xffffe
    80005448:	1f0080e7          	jalr	496(ra) # 80003634 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000544c:	00003597          	auipc	a1,0x3
    80005450:	2c458593          	addi	a1,a1,708 # 80008710 <syscalls+0x2c0>
    80005454:	fb040513          	addi	a0,s0,-80
    80005458:	ffffe097          	auipc	ra,0xffffe
    8000545c:	6a6080e7          	jalr	1702(ra) # 80003afe <namecmp>
    80005460:	14050a63          	beqz	a0,800055b4 <sys_unlink+0x1b0>
    80005464:	00003597          	auipc	a1,0x3
    80005468:	2b458593          	addi	a1,a1,692 # 80008718 <syscalls+0x2c8>
    8000546c:	fb040513          	addi	a0,s0,-80
    80005470:	ffffe097          	auipc	ra,0xffffe
    80005474:	68e080e7          	jalr	1678(ra) # 80003afe <namecmp>
    80005478:	12050e63          	beqz	a0,800055b4 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000547c:	f2c40613          	addi	a2,s0,-212
    80005480:	fb040593          	addi	a1,s0,-80
    80005484:	8526                	mv	a0,s1
    80005486:	ffffe097          	auipc	ra,0xffffe
    8000548a:	692080e7          	jalr	1682(ra) # 80003b18 <dirlookup>
    8000548e:	892a                	mv	s2,a0
    80005490:	12050263          	beqz	a0,800055b4 <sys_unlink+0x1b0>
  ilock(ip);
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	1a0080e7          	jalr	416(ra) # 80003634 <ilock>
  if(ip->nlink < 1)
    8000549c:	04a91783          	lh	a5,74(s2)
    800054a0:	08f05263          	blez	a5,80005524 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800054a4:	04491703          	lh	a4,68(s2)
    800054a8:	4785                	li	a5,1
    800054aa:	08f70563          	beq	a4,a5,80005534 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800054ae:	4641                	li	a2,16
    800054b0:	4581                	li	a1,0
    800054b2:	fc040513          	addi	a0,s0,-64
    800054b6:	ffffc097          	auipc	ra,0xffffc
    800054ba:	81c080e7          	jalr	-2020(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054be:	4741                	li	a4,16
    800054c0:	f2c42683          	lw	a3,-212(s0)
    800054c4:	fc040613          	addi	a2,s0,-64
    800054c8:	4581                	li	a1,0
    800054ca:	8526                	mv	a0,s1
    800054cc:	ffffe097          	auipc	ra,0xffffe
    800054d0:	514080e7          	jalr	1300(ra) # 800039e0 <writei>
    800054d4:	47c1                	li	a5,16
    800054d6:	0af51563          	bne	a0,a5,80005580 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800054da:	04491703          	lh	a4,68(s2)
    800054de:	4785                	li	a5,1
    800054e0:	0af70863          	beq	a4,a5,80005590 <sys_unlink+0x18c>
  iunlockput(dp);
    800054e4:	8526                	mv	a0,s1
    800054e6:	ffffe097          	auipc	ra,0xffffe
    800054ea:	3b0080e7          	jalr	944(ra) # 80003896 <iunlockput>
  ip->nlink--;
    800054ee:	04a95783          	lhu	a5,74(s2)
    800054f2:	37fd                	addiw	a5,a5,-1
    800054f4:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800054f8:	854a                	mv	a0,s2
    800054fa:	ffffe097          	auipc	ra,0xffffe
    800054fe:	070080e7          	jalr	112(ra) # 8000356a <iupdate>
  iunlockput(ip);
    80005502:	854a                	mv	a0,s2
    80005504:	ffffe097          	auipc	ra,0xffffe
    80005508:	392080e7          	jalr	914(ra) # 80003896 <iunlockput>
  end_op();
    8000550c:	fffff097          	auipc	ra,0xfffff
    80005510:	b6a080e7          	jalr	-1174(ra) # 80004076 <end_op>
  return 0;
    80005514:	4501                	li	a0,0
    80005516:	a84d                	j	800055c8 <sys_unlink+0x1c4>
    end_op();
    80005518:	fffff097          	auipc	ra,0xfffff
    8000551c:	b5e080e7          	jalr	-1186(ra) # 80004076 <end_op>
    return -1;
    80005520:	557d                	li	a0,-1
    80005522:	a05d                	j	800055c8 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005524:	00003517          	auipc	a0,0x3
    80005528:	1fc50513          	addi	a0,a0,508 # 80008720 <syscalls+0x2d0>
    8000552c:	ffffb097          	auipc	ra,0xffffb
    80005530:	012080e7          	jalr	18(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005534:	04c92703          	lw	a4,76(s2)
    80005538:	02000793          	li	a5,32
    8000553c:	f6e7f9e3          	bgeu	a5,a4,800054ae <sys_unlink+0xaa>
    80005540:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005544:	4741                	li	a4,16
    80005546:	86ce                	mv	a3,s3
    80005548:	f1840613          	addi	a2,s0,-232
    8000554c:	4581                	li	a1,0
    8000554e:	854a                	mv	a0,s2
    80005550:	ffffe097          	auipc	ra,0xffffe
    80005554:	398080e7          	jalr	920(ra) # 800038e8 <readi>
    80005558:	47c1                	li	a5,16
    8000555a:	00f51b63          	bne	a0,a5,80005570 <sys_unlink+0x16c>
    if(de.inum != 0)
    8000555e:	f1845783          	lhu	a5,-232(s0)
    80005562:	e7a1                	bnez	a5,800055aa <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005564:	29c1                	addiw	s3,s3,16
    80005566:	04c92783          	lw	a5,76(s2)
    8000556a:	fcf9ede3          	bltu	s3,a5,80005544 <sys_unlink+0x140>
    8000556e:	b781                	j	800054ae <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005570:	00003517          	auipc	a0,0x3
    80005574:	1c850513          	addi	a0,a0,456 # 80008738 <syscalls+0x2e8>
    80005578:	ffffb097          	auipc	ra,0xffffb
    8000557c:	fc6080e7          	jalr	-58(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005580:	00003517          	auipc	a0,0x3
    80005584:	1d050513          	addi	a0,a0,464 # 80008750 <syscalls+0x300>
    80005588:	ffffb097          	auipc	ra,0xffffb
    8000558c:	fb6080e7          	jalr	-74(ra) # 8000053e <panic>
    dp->nlink--;
    80005590:	04a4d783          	lhu	a5,74(s1)
    80005594:	37fd                	addiw	a5,a5,-1
    80005596:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000559a:	8526                	mv	a0,s1
    8000559c:	ffffe097          	auipc	ra,0xffffe
    800055a0:	fce080e7          	jalr	-50(ra) # 8000356a <iupdate>
    800055a4:	b781                	j	800054e4 <sys_unlink+0xe0>
    return -1;
    800055a6:	557d                	li	a0,-1
    800055a8:	a005                	j	800055c8 <sys_unlink+0x1c4>
    iunlockput(ip);
    800055aa:	854a                	mv	a0,s2
    800055ac:	ffffe097          	auipc	ra,0xffffe
    800055b0:	2ea080e7          	jalr	746(ra) # 80003896 <iunlockput>
  iunlockput(dp);
    800055b4:	8526                	mv	a0,s1
    800055b6:	ffffe097          	auipc	ra,0xffffe
    800055ba:	2e0080e7          	jalr	736(ra) # 80003896 <iunlockput>
  end_op();
    800055be:	fffff097          	auipc	ra,0xfffff
    800055c2:	ab8080e7          	jalr	-1352(ra) # 80004076 <end_op>
  return -1;
    800055c6:	557d                	li	a0,-1
}
    800055c8:	70ae                	ld	ra,232(sp)
    800055ca:	740e                	ld	s0,224(sp)
    800055cc:	64ee                	ld	s1,216(sp)
    800055ce:	694e                	ld	s2,208(sp)
    800055d0:	69ae                	ld	s3,200(sp)
    800055d2:	616d                	addi	sp,sp,240
    800055d4:	8082                	ret

00000000800055d6 <sys_open>:

uint64
sys_open(void)
{
    800055d6:	7131                	addi	sp,sp,-192
    800055d8:	fd06                	sd	ra,184(sp)
    800055da:	f922                	sd	s0,176(sp)
    800055dc:	f526                	sd	s1,168(sp)
    800055de:	f14a                	sd	s2,160(sp)
    800055e0:	ed4e                	sd	s3,152(sp)
    800055e2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800055e4:	f4c40593          	addi	a1,s0,-180
    800055e8:	4505                	li	a0,1
    800055ea:	ffffd097          	auipc	ra,0xffffd
    800055ee:	4de080e7          	jalr	1246(ra) # 80002ac8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800055f2:	08000613          	li	a2,128
    800055f6:	f5040593          	addi	a1,s0,-176
    800055fa:	4501                	li	a0,0
    800055fc:	ffffd097          	auipc	ra,0xffffd
    80005600:	50c080e7          	jalr	1292(ra) # 80002b08 <argstr>
    80005604:	87aa                	mv	a5,a0
    return -1;
    80005606:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005608:	0a07c963          	bltz	a5,800056ba <sys_open+0xe4>

  begin_op();
    8000560c:	fffff097          	auipc	ra,0xfffff
    80005610:	9ea080e7          	jalr	-1558(ra) # 80003ff6 <begin_op>

  if(omode & O_CREATE){
    80005614:	f4c42783          	lw	a5,-180(s0)
    80005618:	2007f793          	andi	a5,a5,512
    8000561c:	cfc5                	beqz	a5,800056d4 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000561e:	4681                	li	a3,0
    80005620:	4601                	li	a2,0
    80005622:	4589                	li	a1,2
    80005624:	f5040513          	addi	a0,s0,-176
    80005628:	00000097          	auipc	ra,0x0
    8000562c:	976080e7          	jalr	-1674(ra) # 80004f9e <create>
    80005630:	84aa                	mv	s1,a0
    if(ip == 0){
    80005632:	c959                	beqz	a0,800056c8 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005634:	04449703          	lh	a4,68(s1)
    80005638:	478d                	li	a5,3
    8000563a:	00f71763          	bne	a4,a5,80005648 <sys_open+0x72>
    8000563e:	0464d703          	lhu	a4,70(s1)
    80005642:	47a5                	li	a5,9
    80005644:	0ce7ed63          	bltu	a5,a4,8000571e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	dbe080e7          	jalr	-578(ra) # 80004406 <filealloc>
    80005650:	89aa                	mv	s3,a0
    80005652:	10050363          	beqz	a0,80005758 <sys_open+0x182>
    80005656:	00000097          	auipc	ra,0x0
    8000565a:	906080e7          	jalr	-1786(ra) # 80004f5c <fdalloc>
    8000565e:	892a                	mv	s2,a0
    80005660:	0e054763          	bltz	a0,8000574e <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005664:	04449703          	lh	a4,68(s1)
    80005668:	478d                	li	a5,3
    8000566a:	0cf70563          	beq	a4,a5,80005734 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000566e:	4789                	li	a5,2
    80005670:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005674:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005678:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000567c:	f4c42783          	lw	a5,-180(s0)
    80005680:	0017c713          	xori	a4,a5,1
    80005684:	8b05                	andi	a4,a4,1
    80005686:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000568a:	0037f713          	andi	a4,a5,3
    8000568e:	00e03733          	snez	a4,a4
    80005692:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005696:	4007f793          	andi	a5,a5,1024
    8000569a:	c791                	beqz	a5,800056a6 <sys_open+0xd0>
    8000569c:	04449703          	lh	a4,68(s1)
    800056a0:	4789                	li	a5,2
    800056a2:	0af70063          	beq	a4,a5,80005742 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800056a6:	8526                	mv	a0,s1
    800056a8:	ffffe097          	auipc	ra,0xffffe
    800056ac:	04e080e7          	jalr	78(ra) # 800036f6 <iunlock>
  end_op();
    800056b0:	fffff097          	auipc	ra,0xfffff
    800056b4:	9c6080e7          	jalr	-1594(ra) # 80004076 <end_op>

  return fd;
    800056b8:	854a                	mv	a0,s2
}
    800056ba:	70ea                	ld	ra,184(sp)
    800056bc:	744a                	ld	s0,176(sp)
    800056be:	74aa                	ld	s1,168(sp)
    800056c0:	790a                	ld	s2,160(sp)
    800056c2:	69ea                	ld	s3,152(sp)
    800056c4:	6129                	addi	sp,sp,192
    800056c6:	8082                	ret
      end_op();
    800056c8:	fffff097          	auipc	ra,0xfffff
    800056cc:	9ae080e7          	jalr	-1618(ra) # 80004076 <end_op>
      return -1;
    800056d0:	557d                	li	a0,-1
    800056d2:	b7e5                	j	800056ba <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800056d4:	f5040513          	addi	a0,s0,-176
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	702080e7          	jalr	1794(ra) # 80003dda <namei>
    800056e0:	84aa                	mv	s1,a0
    800056e2:	c905                	beqz	a0,80005712 <sys_open+0x13c>
    ilock(ip);
    800056e4:	ffffe097          	auipc	ra,0xffffe
    800056e8:	f50080e7          	jalr	-176(ra) # 80003634 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800056ec:	04449703          	lh	a4,68(s1)
    800056f0:	4785                	li	a5,1
    800056f2:	f4f711e3          	bne	a4,a5,80005634 <sys_open+0x5e>
    800056f6:	f4c42783          	lw	a5,-180(s0)
    800056fa:	d7b9                	beqz	a5,80005648 <sys_open+0x72>
      iunlockput(ip);
    800056fc:	8526                	mv	a0,s1
    800056fe:	ffffe097          	auipc	ra,0xffffe
    80005702:	198080e7          	jalr	408(ra) # 80003896 <iunlockput>
      end_op();
    80005706:	fffff097          	auipc	ra,0xfffff
    8000570a:	970080e7          	jalr	-1680(ra) # 80004076 <end_op>
      return -1;
    8000570e:	557d                	li	a0,-1
    80005710:	b76d                	j	800056ba <sys_open+0xe4>
      end_op();
    80005712:	fffff097          	auipc	ra,0xfffff
    80005716:	964080e7          	jalr	-1692(ra) # 80004076 <end_op>
      return -1;
    8000571a:	557d                	li	a0,-1
    8000571c:	bf79                	j	800056ba <sys_open+0xe4>
    iunlockput(ip);
    8000571e:	8526                	mv	a0,s1
    80005720:	ffffe097          	auipc	ra,0xffffe
    80005724:	176080e7          	jalr	374(ra) # 80003896 <iunlockput>
    end_op();
    80005728:	fffff097          	auipc	ra,0xfffff
    8000572c:	94e080e7          	jalr	-1714(ra) # 80004076 <end_op>
    return -1;
    80005730:	557d                	li	a0,-1
    80005732:	b761                	j	800056ba <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005734:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005738:	04649783          	lh	a5,70(s1)
    8000573c:	02f99223          	sh	a5,36(s3)
    80005740:	bf25                	j	80005678 <sys_open+0xa2>
    itrunc(ip);
    80005742:	8526                	mv	a0,s1
    80005744:	ffffe097          	auipc	ra,0xffffe
    80005748:	ffe080e7          	jalr	-2(ra) # 80003742 <itrunc>
    8000574c:	bfa9                	j	800056a6 <sys_open+0xd0>
      fileclose(f);
    8000574e:	854e                	mv	a0,s3
    80005750:	fffff097          	auipc	ra,0xfffff
    80005754:	d72080e7          	jalr	-654(ra) # 800044c2 <fileclose>
    iunlockput(ip);
    80005758:	8526                	mv	a0,s1
    8000575a:	ffffe097          	auipc	ra,0xffffe
    8000575e:	13c080e7          	jalr	316(ra) # 80003896 <iunlockput>
    end_op();
    80005762:	fffff097          	auipc	ra,0xfffff
    80005766:	914080e7          	jalr	-1772(ra) # 80004076 <end_op>
    return -1;
    8000576a:	557d                	li	a0,-1
    8000576c:	b7b9                	j	800056ba <sys_open+0xe4>

000000008000576e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000576e:	7175                	addi	sp,sp,-144
    80005770:	e506                	sd	ra,136(sp)
    80005772:	e122                	sd	s0,128(sp)
    80005774:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005776:	fffff097          	auipc	ra,0xfffff
    8000577a:	880080e7          	jalr	-1920(ra) # 80003ff6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000577e:	08000613          	li	a2,128
    80005782:	f7040593          	addi	a1,s0,-144
    80005786:	4501                	li	a0,0
    80005788:	ffffd097          	auipc	ra,0xffffd
    8000578c:	380080e7          	jalr	896(ra) # 80002b08 <argstr>
    80005790:	02054963          	bltz	a0,800057c2 <sys_mkdir+0x54>
    80005794:	4681                	li	a3,0
    80005796:	4601                	li	a2,0
    80005798:	4585                	li	a1,1
    8000579a:	f7040513          	addi	a0,s0,-144
    8000579e:	00000097          	auipc	ra,0x0
    800057a2:	800080e7          	jalr	-2048(ra) # 80004f9e <create>
    800057a6:	cd11                	beqz	a0,800057c2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057a8:	ffffe097          	auipc	ra,0xffffe
    800057ac:	0ee080e7          	jalr	238(ra) # 80003896 <iunlockput>
  end_op();
    800057b0:	fffff097          	auipc	ra,0xfffff
    800057b4:	8c6080e7          	jalr	-1850(ra) # 80004076 <end_op>
  return 0;
    800057b8:	4501                	li	a0,0
}
    800057ba:	60aa                	ld	ra,136(sp)
    800057bc:	640a                	ld	s0,128(sp)
    800057be:	6149                	addi	sp,sp,144
    800057c0:	8082                	ret
    end_op();
    800057c2:	fffff097          	auipc	ra,0xfffff
    800057c6:	8b4080e7          	jalr	-1868(ra) # 80004076 <end_op>
    return -1;
    800057ca:	557d                	li	a0,-1
    800057cc:	b7fd                	j	800057ba <sys_mkdir+0x4c>

00000000800057ce <sys_mknod>:

uint64
sys_mknod(void)
{
    800057ce:	7135                	addi	sp,sp,-160
    800057d0:	ed06                	sd	ra,152(sp)
    800057d2:	e922                	sd	s0,144(sp)
    800057d4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800057d6:	fffff097          	auipc	ra,0xfffff
    800057da:	820080e7          	jalr	-2016(ra) # 80003ff6 <begin_op>
  argint(1, &major);
    800057de:	f6c40593          	addi	a1,s0,-148
    800057e2:	4505                	li	a0,1
    800057e4:	ffffd097          	auipc	ra,0xffffd
    800057e8:	2e4080e7          	jalr	740(ra) # 80002ac8 <argint>
  argint(2, &minor);
    800057ec:	f6840593          	addi	a1,s0,-152
    800057f0:	4509                	li	a0,2
    800057f2:	ffffd097          	auipc	ra,0xffffd
    800057f6:	2d6080e7          	jalr	726(ra) # 80002ac8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057fa:	08000613          	li	a2,128
    800057fe:	f7040593          	addi	a1,s0,-144
    80005802:	4501                	li	a0,0
    80005804:	ffffd097          	auipc	ra,0xffffd
    80005808:	304080e7          	jalr	772(ra) # 80002b08 <argstr>
    8000580c:	02054b63          	bltz	a0,80005842 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005810:	f6841683          	lh	a3,-152(s0)
    80005814:	f6c41603          	lh	a2,-148(s0)
    80005818:	458d                	li	a1,3
    8000581a:	f7040513          	addi	a0,s0,-144
    8000581e:	fffff097          	auipc	ra,0xfffff
    80005822:	780080e7          	jalr	1920(ra) # 80004f9e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005826:	cd11                	beqz	a0,80005842 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005828:	ffffe097          	auipc	ra,0xffffe
    8000582c:	06e080e7          	jalr	110(ra) # 80003896 <iunlockput>
  end_op();
    80005830:	fffff097          	auipc	ra,0xfffff
    80005834:	846080e7          	jalr	-1978(ra) # 80004076 <end_op>
  return 0;
    80005838:	4501                	li	a0,0
}
    8000583a:	60ea                	ld	ra,152(sp)
    8000583c:	644a                	ld	s0,144(sp)
    8000583e:	610d                	addi	sp,sp,160
    80005840:	8082                	ret
    end_op();
    80005842:	fffff097          	auipc	ra,0xfffff
    80005846:	834080e7          	jalr	-1996(ra) # 80004076 <end_op>
    return -1;
    8000584a:	557d                	li	a0,-1
    8000584c:	b7fd                	j	8000583a <sys_mknod+0x6c>

000000008000584e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000584e:	7135                	addi	sp,sp,-160
    80005850:	ed06                	sd	ra,152(sp)
    80005852:	e922                	sd	s0,144(sp)
    80005854:	e526                	sd	s1,136(sp)
    80005856:	e14a                	sd	s2,128(sp)
    80005858:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000585a:	ffffc097          	auipc	ra,0xffffc
    8000585e:	15a080e7          	jalr	346(ra) # 800019b4 <myproc>
    80005862:	892a                	mv	s2,a0
  
  begin_op();
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	792080e7          	jalr	1938(ra) # 80003ff6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000586c:	08000613          	li	a2,128
    80005870:	f6040593          	addi	a1,s0,-160
    80005874:	4501                	li	a0,0
    80005876:	ffffd097          	auipc	ra,0xffffd
    8000587a:	292080e7          	jalr	658(ra) # 80002b08 <argstr>
    8000587e:	04054b63          	bltz	a0,800058d4 <sys_chdir+0x86>
    80005882:	f6040513          	addi	a0,s0,-160
    80005886:	ffffe097          	auipc	ra,0xffffe
    8000588a:	554080e7          	jalr	1364(ra) # 80003dda <namei>
    8000588e:	84aa                	mv	s1,a0
    80005890:	c131                	beqz	a0,800058d4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005892:	ffffe097          	auipc	ra,0xffffe
    80005896:	da2080e7          	jalr	-606(ra) # 80003634 <ilock>
  if(ip->type != T_DIR){
    8000589a:	04449703          	lh	a4,68(s1)
    8000589e:	4785                	li	a5,1
    800058a0:	04f71063          	bne	a4,a5,800058e0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800058a4:	8526                	mv	a0,s1
    800058a6:	ffffe097          	auipc	ra,0xffffe
    800058aa:	e50080e7          	jalr	-432(ra) # 800036f6 <iunlock>
  iput(p->cwd);
    800058ae:	15093503          	ld	a0,336(s2)
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	f3c080e7          	jalr	-196(ra) # 800037ee <iput>
  end_op();
    800058ba:	ffffe097          	auipc	ra,0xffffe
    800058be:	7bc080e7          	jalr	1980(ra) # 80004076 <end_op>
  p->cwd = ip;
    800058c2:	14993823          	sd	s1,336(s2)
  return 0;
    800058c6:	4501                	li	a0,0
}
    800058c8:	60ea                	ld	ra,152(sp)
    800058ca:	644a                	ld	s0,144(sp)
    800058cc:	64aa                	ld	s1,136(sp)
    800058ce:	690a                	ld	s2,128(sp)
    800058d0:	610d                	addi	sp,sp,160
    800058d2:	8082                	ret
    end_op();
    800058d4:	ffffe097          	auipc	ra,0xffffe
    800058d8:	7a2080e7          	jalr	1954(ra) # 80004076 <end_op>
    return -1;
    800058dc:	557d                	li	a0,-1
    800058de:	b7ed                	j	800058c8 <sys_chdir+0x7a>
    iunlockput(ip);
    800058e0:	8526                	mv	a0,s1
    800058e2:	ffffe097          	auipc	ra,0xffffe
    800058e6:	fb4080e7          	jalr	-76(ra) # 80003896 <iunlockput>
    end_op();
    800058ea:	ffffe097          	auipc	ra,0xffffe
    800058ee:	78c080e7          	jalr	1932(ra) # 80004076 <end_op>
    return -1;
    800058f2:	557d                	li	a0,-1
    800058f4:	bfd1                	j	800058c8 <sys_chdir+0x7a>

00000000800058f6 <sys_exec>:

uint64
sys_exec(void)
{
    800058f6:	7145                	addi	sp,sp,-464
    800058f8:	e786                	sd	ra,456(sp)
    800058fa:	e3a2                	sd	s0,448(sp)
    800058fc:	ff26                	sd	s1,440(sp)
    800058fe:	fb4a                	sd	s2,432(sp)
    80005900:	f74e                	sd	s3,424(sp)
    80005902:	f352                	sd	s4,416(sp)
    80005904:	ef56                	sd	s5,408(sp)
    80005906:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005908:	e3840593          	addi	a1,s0,-456
    8000590c:	4505                	li	a0,1
    8000590e:	ffffd097          	auipc	ra,0xffffd
    80005912:	1da080e7          	jalr	474(ra) # 80002ae8 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005916:	08000613          	li	a2,128
    8000591a:	f4040593          	addi	a1,s0,-192
    8000591e:	4501                	li	a0,0
    80005920:	ffffd097          	auipc	ra,0xffffd
    80005924:	1e8080e7          	jalr	488(ra) # 80002b08 <argstr>
    80005928:	87aa                	mv	a5,a0
    return -1;
    8000592a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000592c:	0c07c263          	bltz	a5,800059f0 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005930:	10000613          	li	a2,256
    80005934:	4581                	li	a1,0
    80005936:	e4040513          	addi	a0,s0,-448
    8000593a:	ffffb097          	auipc	ra,0xffffb
    8000593e:	398080e7          	jalr	920(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005942:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005946:	89a6                	mv	s3,s1
    80005948:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000594a:	02000a13          	li	s4,32
    8000594e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005952:	00391793          	slli	a5,s2,0x3
    80005956:	e3040593          	addi	a1,s0,-464
    8000595a:	e3843503          	ld	a0,-456(s0)
    8000595e:	953e                	add	a0,a0,a5
    80005960:	ffffd097          	auipc	ra,0xffffd
    80005964:	0ca080e7          	jalr	202(ra) # 80002a2a <fetchaddr>
    80005968:	02054a63          	bltz	a0,8000599c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    8000596c:	e3043783          	ld	a5,-464(s0)
    80005970:	c3b9                	beqz	a5,800059b6 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005972:	ffffb097          	auipc	ra,0xffffb
    80005976:	174080e7          	jalr	372(ra) # 80000ae6 <kalloc>
    8000597a:	85aa                	mv	a1,a0
    8000597c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005980:	cd11                	beqz	a0,8000599c <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005982:	6605                	lui	a2,0x1
    80005984:	e3043503          	ld	a0,-464(s0)
    80005988:	ffffd097          	auipc	ra,0xffffd
    8000598c:	0f4080e7          	jalr	244(ra) # 80002a7c <fetchstr>
    80005990:	00054663          	bltz	a0,8000599c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005994:	0905                	addi	s2,s2,1
    80005996:	09a1                	addi	s3,s3,8
    80005998:	fb491be3          	bne	s2,s4,8000594e <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000599c:	10048913          	addi	s2,s1,256
    800059a0:	6088                	ld	a0,0(s1)
    800059a2:	c531                	beqz	a0,800059ee <sys_exec+0xf8>
    kfree(argv[i]);
    800059a4:	ffffb097          	auipc	ra,0xffffb
    800059a8:	046080e7          	jalr	70(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059ac:	04a1                	addi	s1,s1,8
    800059ae:	ff2499e3          	bne	s1,s2,800059a0 <sys_exec+0xaa>
  return -1;
    800059b2:	557d                	li	a0,-1
    800059b4:	a835                	j	800059f0 <sys_exec+0xfa>
      argv[i] = 0;
    800059b6:	0a8e                	slli	s5,s5,0x3
    800059b8:	fc040793          	addi	a5,s0,-64
    800059bc:	9abe                	add	s5,s5,a5
    800059be:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800059c2:	e4040593          	addi	a1,s0,-448
    800059c6:	f4040513          	addi	a0,s0,-192
    800059ca:	fffff097          	auipc	ra,0xfffff
    800059ce:	172080e7          	jalr	370(ra) # 80004b3c <exec>
    800059d2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059d4:	10048993          	addi	s3,s1,256
    800059d8:	6088                	ld	a0,0(s1)
    800059da:	c901                	beqz	a0,800059ea <sys_exec+0xf4>
    kfree(argv[i]);
    800059dc:	ffffb097          	auipc	ra,0xffffb
    800059e0:	00e080e7          	jalr	14(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059e4:	04a1                	addi	s1,s1,8
    800059e6:	ff3499e3          	bne	s1,s3,800059d8 <sys_exec+0xe2>
  return ret;
    800059ea:	854a                	mv	a0,s2
    800059ec:	a011                	j	800059f0 <sys_exec+0xfa>
  return -1;
    800059ee:	557d                	li	a0,-1
}
    800059f0:	60be                	ld	ra,456(sp)
    800059f2:	641e                	ld	s0,448(sp)
    800059f4:	74fa                	ld	s1,440(sp)
    800059f6:	795a                	ld	s2,432(sp)
    800059f8:	79ba                	ld	s3,424(sp)
    800059fa:	7a1a                	ld	s4,416(sp)
    800059fc:	6afa                	ld	s5,408(sp)
    800059fe:	6179                	addi	sp,sp,464
    80005a00:	8082                	ret

0000000080005a02 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a02:	7139                	addi	sp,sp,-64
    80005a04:	fc06                	sd	ra,56(sp)
    80005a06:	f822                	sd	s0,48(sp)
    80005a08:	f426                	sd	s1,40(sp)
    80005a0a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a0c:	ffffc097          	auipc	ra,0xffffc
    80005a10:	fa8080e7          	jalr	-88(ra) # 800019b4 <myproc>
    80005a14:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005a16:	fd840593          	addi	a1,s0,-40
    80005a1a:	4501                	li	a0,0
    80005a1c:	ffffd097          	auipc	ra,0xffffd
    80005a20:	0cc080e7          	jalr	204(ra) # 80002ae8 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005a24:	fc840593          	addi	a1,s0,-56
    80005a28:	fd040513          	addi	a0,s0,-48
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	dc6080e7          	jalr	-570(ra) # 800047f2 <pipealloc>
    return -1;
    80005a34:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a36:	0c054463          	bltz	a0,80005afe <sys_pipe+0xfc>
  fd0 = -1;
    80005a3a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a3e:	fd043503          	ld	a0,-48(s0)
    80005a42:	fffff097          	auipc	ra,0xfffff
    80005a46:	51a080e7          	jalr	1306(ra) # 80004f5c <fdalloc>
    80005a4a:	fca42223          	sw	a0,-60(s0)
    80005a4e:	08054b63          	bltz	a0,80005ae4 <sys_pipe+0xe2>
    80005a52:	fc843503          	ld	a0,-56(s0)
    80005a56:	fffff097          	auipc	ra,0xfffff
    80005a5a:	506080e7          	jalr	1286(ra) # 80004f5c <fdalloc>
    80005a5e:	fca42023          	sw	a0,-64(s0)
    80005a62:	06054863          	bltz	a0,80005ad2 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a66:	4691                	li	a3,4
    80005a68:	fc440613          	addi	a2,s0,-60
    80005a6c:	fd843583          	ld	a1,-40(s0)
    80005a70:	68a8                	ld	a0,80(s1)
    80005a72:	ffffc097          	auipc	ra,0xffffc
    80005a76:	bfe080e7          	jalr	-1026(ra) # 80001670 <copyout>
    80005a7a:	02054063          	bltz	a0,80005a9a <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a7e:	4691                	li	a3,4
    80005a80:	fc040613          	addi	a2,s0,-64
    80005a84:	fd843583          	ld	a1,-40(s0)
    80005a88:	0591                	addi	a1,a1,4
    80005a8a:	68a8                	ld	a0,80(s1)
    80005a8c:	ffffc097          	auipc	ra,0xffffc
    80005a90:	be4080e7          	jalr	-1052(ra) # 80001670 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a94:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a96:	06055463          	bgez	a0,80005afe <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005a9a:	fc442783          	lw	a5,-60(s0)
    80005a9e:	07e9                	addi	a5,a5,26
    80005aa0:	078e                	slli	a5,a5,0x3
    80005aa2:	97a6                	add	a5,a5,s1
    80005aa4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005aa8:	fc042503          	lw	a0,-64(s0)
    80005aac:	0569                	addi	a0,a0,26
    80005aae:	050e                	slli	a0,a0,0x3
    80005ab0:	94aa                	add	s1,s1,a0
    80005ab2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005ab6:	fd043503          	ld	a0,-48(s0)
    80005aba:	fffff097          	auipc	ra,0xfffff
    80005abe:	a08080e7          	jalr	-1528(ra) # 800044c2 <fileclose>
    fileclose(wf);
    80005ac2:	fc843503          	ld	a0,-56(s0)
    80005ac6:	fffff097          	auipc	ra,0xfffff
    80005aca:	9fc080e7          	jalr	-1540(ra) # 800044c2 <fileclose>
    return -1;
    80005ace:	57fd                	li	a5,-1
    80005ad0:	a03d                	j	80005afe <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005ad2:	fc442783          	lw	a5,-60(s0)
    80005ad6:	0007c763          	bltz	a5,80005ae4 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005ada:	07e9                	addi	a5,a5,26
    80005adc:	078e                	slli	a5,a5,0x3
    80005ade:	94be                	add	s1,s1,a5
    80005ae0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005ae4:	fd043503          	ld	a0,-48(s0)
    80005ae8:	fffff097          	auipc	ra,0xfffff
    80005aec:	9da080e7          	jalr	-1574(ra) # 800044c2 <fileclose>
    fileclose(wf);
    80005af0:	fc843503          	ld	a0,-56(s0)
    80005af4:	fffff097          	auipc	ra,0xfffff
    80005af8:	9ce080e7          	jalr	-1586(ra) # 800044c2 <fileclose>
    return -1;
    80005afc:	57fd                	li	a5,-1
}
    80005afe:	853e                	mv	a0,a5
    80005b00:	70e2                	ld	ra,56(sp)
    80005b02:	7442                	ld	s0,48(sp)
    80005b04:	74a2                	ld	s1,40(sp)
    80005b06:	6121                	addi	sp,sp,64
    80005b08:	8082                	ret
    80005b0a:	0000                	unimp
    80005b0c:	0000                	unimp
	...

0000000080005b10 <kernelvec>:
    80005b10:	7111                	addi	sp,sp,-256
    80005b12:	e006                	sd	ra,0(sp)
    80005b14:	e40a                	sd	sp,8(sp)
    80005b16:	e80e                	sd	gp,16(sp)
    80005b18:	ec12                	sd	tp,24(sp)
    80005b1a:	f016                	sd	t0,32(sp)
    80005b1c:	f41a                	sd	t1,40(sp)
    80005b1e:	f81e                	sd	t2,48(sp)
    80005b20:	fc22                	sd	s0,56(sp)
    80005b22:	e0a6                	sd	s1,64(sp)
    80005b24:	e4aa                	sd	a0,72(sp)
    80005b26:	e8ae                	sd	a1,80(sp)
    80005b28:	ecb2                	sd	a2,88(sp)
    80005b2a:	f0b6                	sd	a3,96(sp)
    80005b2c:	f4ba                	sd	a4,104(sp)
    80005b2e:	f8be                	sd	a5,112(sp)
    80005b30:	fcc2                	sd	a6,120(sp)
    80005b32:	e146                	sd	a7,128(sp)
    80005b34:	e54a                	sd	s2,136(sp)
    80005b36:	e94e                	sd	s3,144(sp)
    80005b38:	ed52                	sd	s4,152(sp)
    80005b3a:	f156                	sd	s5,160(sp)
    80005b3c:	f55a                	sd	s6,168(sp)
    80005b3e:	f95e                	sd	s7,176(sp)
    80005b40:	fd62                	sd	s8,184(sp)
    80005b42:	e1e6                	sd	s9,192(sp)
    80005b44:	e5ea                	sd	s10,200(sp)
    80005b46:	e9ee                	sd	s11,208(sp)
    80005b48:	edf2                	sd	t3,216(sp)
    80005b4a:	f1f6                	sd	t4,224(sp)
    80005b4c:	f5fa                	sd	t5,232(sp)
    80005b4e:	f9fe                	sd	t6,240(sp)
    80005b50:	da7fc0ef          	jal	ra,800028f6 <kerneltrap>
    80005b54:	6082                	ld	ra,0(sp)
    80005b56:	6122                	ld	sp,8(sp)
    80005b58:	61c2                	ld	gp,16(sp)
    80005b5a:	7282                	ld	t0,32(sp)
    80005b5c:	7322                	ld	t1,40(sp)
    80005b5e:	73c2                	ld	t2,48(sp)
    80005b60:	7462                	ld	s0,56(sp)
    80005b62:	6486                	ld	s1,64(sp)
    80005b64:	6526                	ld	a0,72(sp)
    80005b66:	65c6                	ld	a1,80(sp)
    80005b68:	6666                	ld	a2,88(sp)
    80005b6a:	7686                	ld	a3,96(sp)
    80005b6c:	7726                	ld	a4,104(sp)
    80005b6e:	77c6                	ld	a5,112(sp)
    80005b70:	7866                	ld	a6,120(sp)
    80005b72:	688a                	ld	a7,128(sp)
    80005b74:	692a                	ld	s2,136(sp)
    80005b76:	69ca                	ld	s3,144(sp)
    80005b78:	6a6a                	ld	s4,152(sp)
    80005b7a:	7a8a                	ld	s5,160(sp)
    80005b7c:	7b2a                	ld	s6,168(sp)
    80005b7e:	7bca                	ld	s7,176(sp)
    80005b80:	7c6a                	ld	s8,184(sp)
    80005b82:	6c8e                	ld	s9,192(sp)
    80005b84:	6d2e                	ld	s10,200(sp)
    80005b86:	6dce                	ld	s11,208(sp)
    80005b88:	6e6e                	ld	t3,216(sp)
    80005b8a:	7e8e                	ld	t4,224(sp)
    80005b8c:	7f2e                	ld	t5,232(sp)
    80005b8e:	7fce                	ld	t6,240(sp)
    80005b90:	6111                	addi	sp,sp,256
    80005b92:	10200073          	sret
    80005b96:	00000013          	nop
    80005b9a:	00000013          	nop
    80005b9e:	0001                	nop

0000000080005ba0 <timervec>:
    80005ba0:	34051573          	csrrw	a0,mscratch,a0
    80005ba4:	e10c                	sd	a1,0(a0)
    80005ba6:	e510                	sd	a2,8(a0)
    80005ba8:	e914                	sd	a3,16(a0)
    80005baa:	6d0c                	ld	a1,24(a0)
    80005bac:	7110                	ld	a2,32(a0)
    80005bae:	6194                	ld	a3,0(a1)
    80005bb0:	96b2                	add	a3,a3,a2
    80005bb2:	e194                	sd	a3,0(a1)
    80005bb4:	4589                	li	a1,2
    80005bb6:	14459073          	csrw	sip,a1
    80005bba:	6914                	ld	a3,16(a0)
    80005bbc:	6510                	ld	a2,8(a0)
    80005bbe:	610c                	ld	a1,0(a0)
    80005bc0:	34051573          	csrrw	a0,mscratch,a0
    80005bc4:	30200073          	mret
	...

0000000080005bca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005bca:	1141                	addi	sp,sp,-16
    80005bcc:	e422                	sd	s0,8(sp)
    80005bce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005bd0:	0c0007b7          	lui	a5,0xc000
    80005bd4:	4705                	li	a4,1
    80005bd6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005bd8:	c3d8                	sw	a4,4(a5)
}
    80005bda:	6422                	ld	s0,8(sp)
    80005bdc:	0141                	addi	sp,sp,16
    80005bde:	8082                	ret

0000000080005be0 <plicinithart>:

void
plicinithart(void)
{
    80005be0:	1141                	addi	sp,sp,-16
    80005be2:	e406                	sd	ra,8(sp)
    80005be4:	e022                	sd	s0,0(sp)
    80005be6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005be8:	ffffc097          	auipc	ra,0xffffc
    80005bec:	da0080e7          	jalr	-608(ra) # 80001988 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005bf0:	0085171b          	slliw	a4,a0,0x8
    80005bf4:	0c0027b7          	lui	a5,0xc002
    80005bf8:	97ba                	add	a5,a5,a4
    80005bfa:	40200713          	li	a4,1026
    80005bfe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c02:	00d5151b          	slliw	a0,a0,0xd
    80005c06:	0c2017b7          	lui	a5,0xc201
    80005c0a:	953e                	add	a0,a0,a5
    80005c0c:	00052023          	sw	zero,0(a0)
}
    80005c10:	60a2                	ld	ra,8(sp)
    80005c12:	6402                	ld	s0,0(sp)
    80005c14:	0141                	addi	sp,sp,16
    80005c16:	8082                	ret

0000000080005c18 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c18:	1141                	addi	sp,sp,-16
    80005c1a:	e406                	sd	ra,8(sp)
    80005c1c:	e022                	sd	s0,0(sp)
    80005c1e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c20:	ffffc097          	auipc	ra,0xffffc
    80005c24:	d68080e7          	jalr	-664(ra) # 80001988 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c28:	00d5179b          	slliw	a5,a0,0xd
    80005c2c:	0c201537          	lui	a0,0xc201
    80005c30:	953e                	add	a0,a0,a5
  return irq;
}
    80005c32:	4148                	lw	a0,4(a0)
    80005c34:	60a2                	ld	ra,8(sp)
    80005c36:	6402                	ld	s0,0(sp)
    80005c38:	0141                	addi	sp,sp,16
    80005c3a:	8082                	ret

0000000080005c3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c3c:	1101                	addi	sp,sp,-32
    80005c3e:	ec06                	sd	ra,24(sp)
    80005c40:	e822                	sd	s0,16(sp)
    80005c42:	e426                	sd	s1,8(sp)
    80005c44:	1000                	addi	s0,sp,32
    80005c46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c48:	ffffc097          	auipc	ra,0xffffc
    80005c4c:	d40080e7          	jalr	-704(ra) # 80001988 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c50:	00d5151b          	slliw	a0,a0,0xd
    80005c54:	0c2017b7          	lui	a5,0xc201
    80005c58:	97aa                	add	a5,a5,a0
    80005c5a:	c3c4                	sw	s1,4(a5)
}
    80005c5c:	60e2                	ld	ra,24(sp)
    80005c5e:	6442                	ld	s0,16(sp)
    80005c60:	64a2                	ld	s1,8(sp)
    80005c62:	6105                	addi	sp,sp,32
    80005c64:	8082                	ret

0000000080005c66 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c66:	1141                	addi	sp,sp,-16
    80005c68:	e406                	sd	ra,8(sp)
    80005c6a:	e022                	sd	s0,0(sp)
    80005c6c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c6e:	479d                	li	a5,7
    80005c70:	04a7cc63          	blt	a5,a0,80005cc8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005c74:	0001c797          	auipc	a5,0x1c
    80005c78:	fcc78793          	addi	a5,a5,-52 # 80021c40 <disk>
    80005c7c:	97aa                	add	a5,a5,a0
    80005c7e:	0187c783          	lbu	a5,24(a5)
    80005c82:	ebb9                	bnez	a5,80005cd8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005c84:	00451613          	slli	a2,a0,0x4
    80005c88:	0001c797          	auipc	a5,0x1c
    80005c8c:	fb878793          	addi	a5,a5,-72 # 80021c40 <disk>
    80005c90:	6394                	ld	a3,0(a5)
    80005c92:	96b2                	add	a3,a3,a2
    80005c94:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005c98:	6398                	ld	a4,0(a5)
    80005c9a:	9732                	add	a4,a4,a2
    80005c9c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005ca0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ca4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ca8:	953e                	add	a0,a0,a5
    80005caa:	4785                	li	a5,1
    80005cac:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005cb0:	0001c517          	auipc	a0,0x1c
    80005cb4:	fa850513          	addi	a0,a0,-88 # 80021c58 <disk+0x18>
    80005cb8:	ffffc097          	auipc	ra,0xffffc
    80005cbc:	408080e7          	jalr	1032(ra) # 800020c0 <wakeup>
}
    80005cc0:	60a2                	ld	ra,8(sp)
    80005cc2:	6402                	ld	s0,0(sp)
    80005cc4:	0141                	addi	sp,sp,16
    80005cc6:	8082                	ret
    panic("free_desc 1");
    80005cc8:	00003517          	auipc	a0,0x3
    80005ccc:	a9850513          	addi	a0,a0,-1384 # 80008760 <syscalls+0x310>
    80005cd0:	ffffb097          	auipc	ra,0xffffb
    80005cd4:	86e080e7          	jalr	-1938(ra) # 8000053e <panic>
    panic("free_desc 2");
    80005cd8:	00003517          	auipc	a0,0x3
    80005cdc:	a9850513          	addi	a0,a0,-1384 # 80008770 <syscalls+0x320>
    80005ce0:	ffffb097          	auipc	ra,0xffffb
    80005ce4:	85e080e7          	jalr	-1954(ra) # 8000053e <panic>

0000000080005ce8 <virtio_disk_init>:
{
    80005ce8:	1101                	addi	sp,sp,-32
    80005cea:	ec06                	sd	ra,24(sp)
    80005cec:	e822                	sd	s0,16(sp)
    80005cee:	e426                	sd	s1,8(sp)
    80005cf0:	e04a                	sd	s2,0(sp)
    80005cf2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005cf4:	00003597          	auipc	a1,0x3
    80005cf8:	a8c58593          	addi	a1,a1,-1396 # 80008780 <syscalls+0x330>
    80005cfc:	0001c517          	auipc	a0,0x1c
    80005d00:	06c50513          	addi	a0,a0,108 # 80021d68 <disk+0x128>
    80005d04:	ffffb097          	auipc	ra,0xffffb
    80005d08:	e42080e7          	jalr	-446(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d0c:	100017b7          	lui	a5,0x10001
    80005d10:	4398                	lw	a4,0(a5)
    80005d12:	2701                	sext.w	a4,a4
    80005d14:	747277b7          	lui	a5,0x74727
    80005d18:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d1c:	14f71c63          	bne	a4,a5,80005e74 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d20:	100017b7          	lui	a5,0x10001
    80005d24:	43dc                	lw	a5,4(a5)
    80005d26:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d28:	4709                	li	a4,2
    80005d2a:	14e79563          	bne	a5,a4,80005e74 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d2e:	100017b7          	lui	a5,0x10001
    80005d32:	479c                	lw	a5,8(a5)
    80005d34:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d36:	12e79f63          	bne	a5,a4,80005e74 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d3a:	100017b7          	lui	a5,0x10001
    80005d3e:	47d8                	lw	a4,12(a5)
    80005d40:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d42:	554d47b7          	lui	a5,0x554d4
    80005d46:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d4a:	12f71563          	bne	a4,a5,80005e74 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d4e:	100017b7          	lui	a5,0x10001
    80005d52:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d56:	4705                	li	a4,1
    80005d58:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d5a:	470d                	li	a4,3
    80005d5c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005d5e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005d60:	c7ffe737          	lui	a4,0xc7ffe
    80005d64:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc877>
    80005d68:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d6a:	2701                	sext.w	a4,a4
    80005d6c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d6e:	472d                	li	a4,11
    80005d70:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005d72:	5bbc                	lw	a5,112(a5)
    80005d74:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005d78:	8ba1                	andi	a5,a5,8
    80005d7a:	10078563          	beqz	a5,80005e84 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d7e:	100017b7          	lui	a5,0x10001
    80005d82:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005d86:	43fc                	lw	a5,68(a5)
    80005d88:	2781                	sext.w	a5,a5
    80005d8a:	10079563          	bnez	a5,80005e94 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d8e:	100017b7          	lui	a5,0x10001
    80005d92:	5bdc                	lw	a5,52(a5)
    80005d94:	2781                	sext.w	a5,a5
  if(max == 0)
    80005d96:	10078763          	beqz	a5,80005ea4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    80005d9a:	471d                	li	a4,7
    80005d9c:	10f77c63          	bgeu	a4,a5,80005eb4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80005da0:	ffffb097          	auipc	ra,0xffffb
    80005da4:	d46080e7          	jalr	-698(ra) # 80000ae6 <kalloc>
    80005da8:	0001c497          	auipc	s1,0x1c
    80005dac:	e9848493          	addi	s1,s1,-360 # 80021c40 <disk>
    80005db0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005db2:	ffffb097          	auipc	ra,0xffffb
    80005db6:	d34080e7          	jalr	-716(ra) # 80000ae6 <kalloc>
    80005dba:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005dbc:	ffffb097          	auipc	ra,0xffffb
    80005dc0:	d2a080e7          	jalr	-726(ra) # 80000ae6 <kalloc>
    80005dc4:	87aa                	mv	a5,a0
    80005dc6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005dc8:	6088                	ld	a0,0(s1)
    80005dca:	cd6d                	beqz	a0,80005ec4 <virtio_disk_init+0x1dc>
    80005dcc:	0001c717          	auipc	a4,0x1c
    80005dd0:	e7c73703          	ld	a4,-388(a4) # 80021c48 <disk+0x8>
    80005dd4:	cb65                	beqz	a4,80005ec4 <virtio_disk_init+0x1dc>
    80005dd6:	c7fd                	beqz	a5,80005ec4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80005dd8:	6605                	lui	a2,0x1
    80005dda:	4581                	li	a1,0
    80005ddc:	ffffb097          	auipc	ra,0xffffb
    80005de0:	ef6080e7          	jalr	-266(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005de4:	0001c497          	auipc	s1,0x1c
    80005de8:	e5c48493          	addi	s1,s1,-420 # 80021c40 <disk>
    80005dec:	6605                	lui	a2,0x1
    80005dee:	4581                	li	a1,0
    80005df0:	6488                	ld	a0,8(s1)
    80005df2:	ffffb097          	auipc	ra,0xffffb
    80005df6:	ee0080e7          	jalr	-288(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005dfa:	6605                	lui	a2,0x1
    80005dfc:	4581                	li	a1,0
    80005dfe:	6888                	ld	a0,16(s1)
    80005e00:	ffffb097          	auipc	ra,0xffffb
    80005e04:	ed2080e7          	jalr	-302(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e08:	100017b7          	lui	a5,0x10001
    80005e0c:	4721                	li	a4,8
    80005e0e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005e10:	4098                	lw	a4,0(s1)
    80005e12:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005e16:	40d8                	lw	a4,4(s1)
    80005e18:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005e1c:	6498                	ld	a4,8(s1)
    80005e1e:	0007069b          	sext.w	a3,a4
    80005e22:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005e26:	9701                	srai	a4,a4,0x20
    80005e28:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005e2c:	6898                	ld	a4,16(s1)
    80005e2e:	0007069b          	sext.w	a3,a4
    80005e32:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005e36:	9701                	srai	a4,a4,0x20
    80005e38:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005e3c:	4705                	li	a4,1
    80005e3e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005e40:	00e48c23          	sb	a4,24(s1)
    80005e44:	00e48ca3          	sb	a4,25(s1)
    80005e48:	00e48d23          	sb	a4,26(s1)
    80005e4c:	00e48da3          	sb	a4,27(s1)
    80005e50:	00e48e23          	sb	a4,28(s1)
    80005e54:	00e48ea3          	sb	a4,29(s1)
    80005e58:	00e48f23          	sb	a4,30(s1)
    80005e5c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005e60:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e64:	0727a823          	sw	s2,112(a5)
}
    80005e68:	60e2                	ld	ra,24(sp)
    80005e6a:	6442                	ld	s0,16(sp)
    80005e6c:	64a2                	ld	s1,8(sp)
    80005e6e:	6902                	ld	s2,0(sp)
    80005e70:	6105                	addi	sp,sp,32
    80005e72:	8082                	ret
    panic("could not find virtio disk");
    80005e74:	00003517          	auipc	a0,0x3
    80005e78:	91c50513          	addi	a0,a0,-1764 # 80008790 <syscalls+0x340>
    80005e7c:	ffffa097          	auipc	ra,0xffffa
    80005e80:	6c2080e7          	jalr	1730(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005e84:	00003517          	auipc	a0,0x3
    80005e88:	92c50513          	addi	a0,a0,-1748 # 800087b0 <syscalls+0x360>
    80005e8c:	ffffa097          	auipc	ra,0xffffa
    80005e90:	6b2080e7          	jalr	1714(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80005e94:	00003517          	auipc	a0,0x3
    80005e98:	93c50513          	addi	a0,a0,-1732 # 800087d0 <syscalls+0x380>
    80005e9c:	ffffa097          	auipc	ra,0xffffa
    80005ea0:	6a2080e7          	jalr	1698(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80005ea4:	00003517          	auipc	a0,0x3
    80005ea8:	94c50513          	addi	a0,a0,-1716 # 800087f0 <syscalls+0x3a0>
    80005eac:	ffffa097          	auipc	ra,0xffffa
    80005eb0:	692080e7          	jalr	1682(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80005eb4:	00003517          	auipc	a0,0x3
    80005eb8:	95c50513          	addi	a0,a0,-1700 # 80008810 <syscalls+0x3c0>
    80005ebc:	ffffa097          	auipc	ra,0xffffa
    80005ec0:	682080e7          	jalr	1666(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80005ec4:	00003517          	auipc	a0,0x3
    80005ec8:	96c50513          	addi	a0,a0,-1684 # 80008830 <syscalls+0x3e0>
    80005ecc:	ffffa097          	auipc	ra,0xffffa
    80005ed0:	672080e7          	jalr	1650(ra) # 8000053e <panic>

0000000080005ed4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ed4:	7119                	addi	sp,sp,-128
    80005ed6:	fc86                	sd	ra,120(sp)
    80005ed8:	f8a2                	sd	s0,112(sp)
    80005eda:	f4a6                	sd	s1,104(sp)
    80005edc:	f0ca                	sd	s2,96(sp)
    80005ede:	ecce                	sd	s3,88(sp)
    80005ee0:	e8d2                	sd	s4,80(sp)
    80005ee2:	e4d6                	sd	s5,72(sp)
    80005ee4:	e0da                	sd	s6,64(sp)
    80005ee6:	fc5e                	sd	s7,56(sp)
    80005ee8:	f862                	sd	s8,48(sp)
    80005eea:	f466                	sd	s9,40(sp)
    80005eec:	f06a                	sd	s10,32(sp)
    80005eee:	ec6e                	sd	s11,24(sp)
    80005ef0:	0100                	addi	s0,sp,128
    80005ef2:	8aaa                	mv	s5,a0
    80005ef4:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ef6:	00c52d03          	lw	s10,12(a0)
    80005efa:	001d1d1b          	slliw	s10,s10,0x1
    80005efe:	1d02                	slli	s10,s10,0x20
    80005f00:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005f04:	0001c517          	auipc	a0,0x1c
    80005f08:	e6450513          	addi	a0,a0,-412 # 80021d68 <disk+0x128>
    80005f0c:	ffffb097          	auipc	ra,0xffffb
    80005f10:	cca080e7          	jalr	-822(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80005f14:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005f16:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f18:	0001cb97          	auipc	s7,0x1c
    80005f1c:	d28b8b93          	addi	s7,s7,-728 # 80021c40 <disk>
  for(int i = 0; i < 3; i++){
    80005f20:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f22:	0001cc97          	auipc	s9,0x1c
    80005f26:	e46c8c93          	addi	s9,s9,-442 # 80021d68 <disk+0x128>
    80005f2a:	a08d                	j	80005f8c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005f2c:	00fb8733          	add	a4,s7,a5
    80005f30:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005f34:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005f36:	0207c563          	bltz	a5,80005f60 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005f3a:	2905                	addiw	s2,s2,1
    80005f3c:	0611                	addi	a2,a2,4
    80005f3e:	05690c63          	beq	s2,s6,80005f96 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005f42:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005f44:	0001c717          	auipc	a4,0x1c
    80005f48:	cfc70713          	addi	a4,a4,-772 # 80021c40 <disk>
    80005f4c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005f4e:	01874683          	lbu	a3,24(a4)
    80005f52:	fee9                	bnez	a3,80005f2c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80005f54:	2785                	addiw	a5,a5,1
    80005f56:	0705                	addi	a4,a4,1
    80005f58:	fe979be3          	bne	a5,s1,80005f4e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80005f5c:	57fd                	li	a5,-1
    80005f5e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005f60:	01205d63          	blez	s2,80005f7a <virtio_disk_rw+0xa6>
    80005f64:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005f66:	000a2503          	lw	a0,0(s4)
    80005f6a:	00000097          	auipc	ra,0x0
    80005f6e:	cfc080e7          	jalr	-772(ra) # 80005c66 <free_desc>
      for(int j = 0; j < i; j++)
    80005f72:	2d85                	addiw	s11,s11,1
    80005f74:	0a11                	addi	s4,s4,4
    80005f76:	ffb918e3          	bne	s2,s11,80005f66 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f7a:	85e6                	mv	a1,s9
    80005f7c:	0001c517          	auipc	a0,0x1c
    80005f80:	cdc50513          	addi	a0,a0,-804 # 80021c58 <disk+0x18>
    80005f84:	ffffc097          	auipc	ra,0xffffc
    80005f88:	0d8080e7          	jalr	216(ra) # 8000205c <sleep>
  for(int i = 0; i < 3; i++){
    80005f8c:	f8040a13          	addi	s4,s0,-128
{
    80005f90:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005f92:	894e                	mv	s2,s3
    80005f94:	b77d                	j	80005f42 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005f96:	f8042583          	lw	a1,-128(s0)
    80005f9a:	00a58793          	addi	a5,a1,10
    80005f9e:	0792                	slli	a5,a5,0x4

  if(write)
    80005fa0:	0001c617          	auipc	a2,0x1c
    80005fa4:	ca060613          	addi	a2,a2,-864 # 80021c40 <disk>
    80005fa8:	00f60733          	add	a4,a2,a5
    80005fac:	018036b3          	snez	a3,s8
    80005fb0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005fb2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005fb6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005fba:	f6078693          	addi	a3,a5,-160
    80005fbe:	6218                	ld	a4,0(a2)
    80005fc0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005fc2:	00878513          	addi	a0,a5,8
    80005fc6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005fc8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005fca:	6208                	ld	a0,0(a2)
    80005fcc:	96aa                	add	a3,a3,a0
    80005fce:	4741                	li	a4,16
    80005fd0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005fd2:	4705                	li	a4,1
    80005fd4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005fd8:	f8442703          	lw	a4,-124(s0)
    80005fdc:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005fe0:	0712                	slli	a4,a4,0x4
    80005fe2:	953a                	add	a0,a0,a4
    80005fe4:	058a8693          	addi	a3,s5,88
    80005fe8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    80005fea:	6208                	ld	a0,0(a2)
    80005fec:	972a                	add	a4,a4,a0
    80005fee:	40000693          	li	a3,1024
    80005ff2:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80005ff4:	001c3c13          	seqz	s8,s8
    80005ff8:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005ffa:	001c6c13          	ori	s8,s8,1
    80005ffe:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006002:	f8842603          	lw	a2,-120(s0)
    80006006:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000600a:	0001c697          	auipc	a3,0x1c
    8000600e:	c3668693          	addi	a3,a3,-970 # 80021c40 <disk>
    80006012:	00258713          	addi	a4,a1,2
    80006016:	0712                	slli	a4,a4,0x4
    80006018:	9736                	add	a4,a4,a3
    8000601a:	587d                	li	a6,-1
    8000601c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006020:	0612                	slli	a2,a2,0x4
    80006022:	9532                	add	a0,a0,a2
    80006024:	f9078793          	addi	a5,a5,-112
    80006028:	97b6                	add	a5,a5,a3
    8000602a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000602c:	629c                	ld	a5,0(a3)
    8000602e:	97b2                	add	a5,a5,a2
    80006030:	4605                	li	a2,1
    80006032:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006034:	4509                	li	a0,2
    80006036:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000603a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000603e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006042:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006046:	6698                	ld	a4,8(a3)
    80006048:	00275783          	lhu	a5,2(a4)
    8000604c:	8b9d                	andi	a5,a5,7
    8000604e:	0786                	slli	a5,a5,0x1
    80006050:	97ba                	add	a5,a5,a4
    80006052:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006056:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000605a:	6698                	ld	a4,8(a3)
    8000605c:	00275783          	lhu	a5,2(a4)
    80006060:	2785                	addiw	a5,a5,1
    80006062:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006066:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000606a:	100017b7          	lui	a5,0x10001
    8000606e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006072:	004aa783          	lw	a5,4(s5)
    80006076:	02c79163          	bne	a5,a2,80006098 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000607a:	0001c917          	auipc	s2,0x1c
    8000607e:	cee90913          	addi	s2,s2,-786 # 80021d68 <disk+0x128>
  while(b->disk == 1) {
    80006082:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006084:	85ca                	mv	a1,s2
    80006086:	8556                	mv	a0,s5
    80006088:	ffffc097          	auipc	ra,0xffffc
    8000608c:	fd4080e7          	jalr	-44(ra) # 8000205c <sleep>
  while(b->disk == 1) {
    80006090:	004aa783          	lw	a5,4(s5)
    80006094:	fe9788e3          	beq	a5,s1,80006084 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006098:	f8042903          	lw	s2,-128(s0)
    8000609c:	00290793          	addi	a5,s2,2
    800060a0:	00479713          	slli	a4,a5,0x4
    800060a4:	0001c797          	auipc	a5,0x1c
    800060a8:	b9c78793          	addi	a5,a5,-1124 # 80021c40 <disk>
    800060ac:	97ba                	add	a5,a5,a4
    800060ae:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800060b2:	0001c997          	auipc	s3,0x1c
    800060b6:	b8e98993          	addi	s3,s3,-1138 # 80021c40 <disk>
    800060ba:	00491713          	slli	a4,s2,0x4
    800060be:	0009b783          	ld	a5,0(s3)
    800060c2:	97ba                	add	a5,a5,a4
    800060c4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800060c8:	854a                	mv	a0,s2
    800060ca:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800060ce:	00000097          	auipc	ra,0x0
    800060d2:	b98080e7          	jalr	-1128(ra) # 80005c66 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800060d6:	8885                	andi	s1,s1,1
    800060d8:	f0ed                	bnez	s1,800060ba <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800060da:	0001c517          	auipc	a0,0x1c
    800060de:	c8e50513          	addi	a0,a0,-882 # 80021d68 <disk+0x128>
    800060e2:	ffffb097          	auipc	ra,0xffffb
    800060e6:	ba8080e7          	jalr	-1112(ra) # 80000c8a <release>
}
    800060ea:	70e6                	ld	ra,120(sp)
    800060ec:	7446                	ld	s0,112(sp)
    800060ee:	74a6                	ld	s1,104(sp)
    800060f0:	7906                	ld	s2,96(sp)
    800060f2:	69e6                	ld	s3,88(sp)
    800060f4:	6a46                	ld	s4,80(sp)
    800060f6:	6aa6                	ld	s5,72(sp)
    800060f8:	6b06                	ld	s6,64(sp)
    800060fa:	7be2                	ld	s7,56(sp)
    800060fc:	7c42                	ld	s8,48(sp)
    800060fe:	7ca2                	ld	s9,40(sp)
    80006100:	7d02                	ld	s10,32(sp)
    80006102:	6de2                	ld	s11,24(sp)
    80006104:	6109                	addi	sp,sp,128
    80006106:	8082                	ret

0000000080006108 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006108:	1101                	addi	sp,sp,-32
    8000610a:	ec06                	sd	ra,24(sp)
    8000610c:	e822                	sd	s0,16(sp)
    8000610e:	e426                	sd	s1,8(sp)
    80006110:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006112:	0001c497          	auipc	s1,0x1c
    80006116:	b2e48493          	addi	s1,s1,-1234 # 80021c40 <disk>
    8000611a:	0001c517          	auipc	a0,0x1c
    8000611e:	c4e50513          	addi	a0,a0,-946 # 80021d68 <disk+0x128>
    80006122:	ffffb097          	auipc	ra,0xffffb
    80006126:	ab4080e7          	jalr	-1356(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000612a:	10001737          	lui	a4,0x10001
    8000612e:	533c                	lw	a5,96(a4)
    80006130:	8b8d                	andi	a5,a5,3
    80006132:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006134:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006138:	689c                	ld	a5,16(s1)
    8000613a:	0204d703          	lhu	a4,32(s1)
    8000613e:	0027d783          	lhu	a5,2(a5)
    80006142:	04f70863          	beq	a4,a5,80006192 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006146:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000614a:	6898                	ld	a4,16(s1)
    8000614c:	0204d783          	lhu	a5,32(s1)
    80006150:	8b9d                	andi	a5,a5,7
    80006152:	078e                	slli	a5,a5,0x3
    80006154:	97ba                	add	a5,a5,a4
    80006156:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006158:	00278713          	addi	a4,a5,2
    8000615c:	0712                	slli	a4,a4,0x4
    8000615e:	9726                	add	a4,a4,s1
    80006160:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006164:	e721                	bnez	a4,800061ac <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006166:	0789                	addi	a5,a5,2
    80006168:	0792                	slli	a5,a5,0x4
    8000616a:	97a6                	add	a5,a5,s1
    8000616c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000616e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006172:	ffffc097          	auipc	ra,0xffffc
    80006176:	f4e080e7          	jalr	-178(ra) # 800020c0 <wakeup>

    disk.used_idx += 1;
    8000617a:	0204d783          	lhu	a5,32(s1)
    8000617e:	2785                	addiw	a5,a5,1
    80006180:	17c2                	slli	a5,a5,0x30
    80006182:	93c1                	srli	a5,a5,0x30
    80006184:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006188:	6898                	ld	a4,16(s1)
    8000618a:	00275703          	lhu	a4,2(a4)
    8000618e:	faf71ce3          	bne	a4,a5,80006146 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006192:	0001c517          	auipc	a0,0x1c
    80006196:	bd650513          	addi	a0,a0,-1066 # 80021d68 <disk+0x128>
    8000619a:	ffffb097          	auipc	ra,0xffffb
    8000619e:	af0080e7          	jalr	-1296(ra) # 80000c8a <release>
}
    800061a2:	60e2                	ld	ra,24(sp)
    800061a4:	6442                	ld	s0,16(sp)
    800061a6:	64a2                	ld	s1,8(sp)
    800061a8:	6105                	addi	sp,sp,32
    800061aa:	8082                	ret
      panic("virtio_disk_intr status");
    800061ac:	00002517          	auipc	a0,0x2
    800061b0:	69c50513          	addi	a0,a0,1692 # 80008848 <syscalls+0x3f8>
    800061b4:	ffffa097          	auipc	ra,0xffffa
    800061b8:	38a080e7          	jalr	906(ra) # 8000053e <panic>

00000000800061bc <petersoninit>:

#define NPETERSONLOCKS 15 

struct petersonlock petersonlocks[NPETERSONLOCKS] ;

void petersoninit(void) {
    800061bc:	1141                	addi	sp,sp,-16
    800061be:	e422                	sd	s0,8(sp)
    800061c0:	0800                	addi	s0,sp,16
    for(int i = 0 ; i < NPETERSONLOCKS ; i++) {
    800061c2:	0001c797          	auipc	a5,0x1c
    800061c6:	bbe78793          	addi	a5,a5,-1090 # 80021d80 <petersonlocks>
    800061ca:	0001c697          	auipc	a3,0x1c
    800061ce:	d1e68693          	addi	a3,a3,-738 # 80021ee8 <end>
        petersonlocks[i].flag[0] = 0 ;
        petersonlocks[i].flag[1] = 0 ; 
        petersonlocks[i].turn = -1;
    800061d2:	577d                	li	a4,-1
        petersonlocks[i].flag[0] = 0 ;
    800061d4:	0007a023          	sw	zero,0(a5)
        petersonlocks[i].flag[1] = 0 ; 
    800061d8:	0007a223          	sw	zero,4(a5)
        petersonlocks[i].turn = -1;
    800061dc:	c798                	sw	a4,8(a5)
        petersonlocks[i].pid[0] = -1 ;
    800061de:	cb98                	sw	a4,16(a5)
        petersonlocks[i].pid[1] = -1 ;
    800061e0:	cbd8                	sw	a4,20(a5)
        petersonlocks[i].used = 0 ;
    800061e2:	0007a623          	sw	zero,12(a5)
    for(int i = 0 ; i < NPETERSONLOCKS ; i++) {
    800061e6:	07e1                	addi	a5,a5,24
    800061e8:	fed796e3          	bne	a5,a3,800061d4 <petersoninit+0x18>
    }
}
    800061ec:	6422                	ld	s0,8(sp)
    800061ee:	0141                	addi	sp,sp,16
    800061f0:	8082                	ret

00000000800061f2 <peterson_create>:

int peterson_create(void) {
    800061f2:	1141                	addi	sp,sp,-16
    800061f4:	e422                	sd	s0,8(sp)
    800061f6:	0800                	addi	s0,sp,16

    for (int i = 0 ; i < NPETERSONLOCKS ; i++) {
    800061f8:	0001c797          	auipc	a5,0x1c
    800061fc:	b9478793          	addi	a5,a5,-1132 # 80021d8c <petersonlocks+0xc>
    80006200:	4501                	li	a0,0
        __sync_synchronize() ;
        if (__sync_lock_test_and_set(&petersonlocks[i].used, 1) == 0) {
    80006202:	4685                	li	a3,1
    for (int i = 0 ; i < NPETERSONLOCKS ; i++) {
    80006204:	463d                	li	a2,15
        __sync_synchronize() ;
    80006206:	0ff0000f          	fence
        if (__sync_lock_test_and_set(&petersonlocks[i].used, 1) == 0) {
    8000620a:	8736                	mv	a4,a3
    8000620c:	0ce7a72f          	amoswap.w.aq	a4,a4,(a5)
    80006210:	2701                	sext.w	a4,a4
    80006212:	cb09                	beqz	a4,80006224 <peterson_create+0x32>
    for (int i = 0 ; i < NPETERSONLOCKS ; i++) {
    80006214:	2505                	addiw	a0,a0,1
    80006216:	07e1                	addi	a5,a5,24
    80006218:	fec517e3          	bne	a0,a2,80006206 <peterson_create+0x14>

            return i ; // return the lockid if found 
        }
    }

    return -1 ; // no lock was found to be created 
    8000621c:	557d                	li	a0,-1

}
    8000621e:	6422                	ld	s0,8(sp)
    80006220:	0141                	addi	sp,sp,16
    80006222:	8082                	ret
            petersonlocks[i].flag[0] = 0 ;
    80006224:	00151793          	slli	a5,a0,0x1
    80006228:	97aa                	add	a5,a5,a0
    8000622a:	00379713          	slli	a4,a5,0x3
    8000622e:	0001c797          	auipc	a5,0x1c
    80006232:	b5278793          	addi	a5,a5,-1198 # 80021d80 <petersonlocks>
    80006236:	97ba                	add	a5,a5,a4
    80006238:	0007a023          	sw	zero,0(a5)
            petersonlocks[i].flag[1] = 0 ; 
    8000623c:	0007a223          	sw	zero,4(a5)
            petersonlocks[i].turn = -1;
    80006240:	577d                	li	a4,-1
    80006242:	c798                	sw	a4,8(a5)
            petersonlocks[i].pid[0] = -1 ;
    80006244:	cb98                	sw	a4,16(a5)
            petersonlocks[i].pid[1] = -1 ;
    80006246:	cbd8                	sw	a4,20(a5)
            __sync_synchronize() ; //ensures that the operations above are not interrupted 
    80006248:	0ff0000f          	fence
            return i ; // return the lockid if found 
    8000624c:	bfc9                	j	8000621e <peterson_create+0x2c>

000000008000624e <peterson_acquire>:
int peterson_acquire(int lock_id , int role) {
   

    if(lock_id >= NPETERSONLOCKS || lock_id < 0 || (role !=0 && role !=1) ) 
    8000624e:	47b9                	li	a5,14
    80006250:	0ea7e863          	bltu	a5,a0,80006340 <peterson_acquire+0xf2>
int peterson_acquire(int lock_id , int role) {
    80006254:	7179                	addi	sp,sp,-48
    80006256:	f406                	sd	ra,40(sp)
    80006258:	f022                	sd	s0,32(sp)
    8000625a:	ec26                	sd	s1,24(sp)
    8000625c:	e84a                	sd	s2,16(sp)
    8000625e:	e44e                	sd	s3,8(sp)
    80006260:	e052                	sd	s4,0(sp)
    80006262:	1800                	addi	s0,sp,48
    80006264:	84ae                	mv	s1,a1
    80006266:	892a                	mv	s2,a0
    if(lock_id >= NPETERSONLOCKS || lock_id < 0 || (role !=0 && role !=1) ) 
    80006268:	0005879b          	sext.w	a5,a1
    8000626c:	4705                	li	a4,1
    8000626e:	0cf76b63          	bltu	a4,a5,80006344 <peterson_acquire+0xf6>
        return -1 ;  //invalid lockid or role
    
    struct petersonlock* plock = &petersonlocks[lock_id] ;
    
    struct proc *p = myproc() ;
    80006272:	ffffb097          	auipc	ra,0xffffb
    80006276:	742080e7          	jalr	1858(ra) # 800019b4 <myproc>

    // if(plock->pid[role] != p->pid)
    //     return -1 ;
    if (plock->pid[role] == -1) {
    8000627a:	00191793          	slli	a5,s2,0x1
    8000627e:	97ca                	add	a5,a5,s2
    80006280:	0786                	slli	a5,a5,0x1
    80006282:	97a6                	add	a5,a5,s1
    80006284:	0791                	addi	a5,a5,4
    80006286:	078a                	slli	a5,a5,0x2
    80006288:	0001c717          	auipc	a4,0x1c
    8000628c:	af870713          	addi	a4,a4,-1288 # 80021d80 <petersonlocks>
    80006290:	97ba                	add	a5,a5,a4
    80006292:	439c                	lw	a5,0(a5)
    80006294:	577d                	li	a4,-1
    80006296:	06e78d63          	beq	a5,a4,80006310 <peterson_acquire+0xc2>
        plock->pid[role] = p->pid;
    } else if (plock->pid[role] != p->pid) {
    8000629a:	5918                	lw	a4,48(a0)
    8000629c:	0af71663          	bne	a4,a5,80006348 <peterson_acquire+0xfa>
        return -1;
    }
    
    int other = 1 - role ;
    800062a0:	4605                	li	a2,1
    800062a2:	9e05                	subw	a2,a2,s1
    800062a4:	0006099b          	sext.w	s3,a2

    plock->flag[role] = 1 ; // the process is interested 
    800062a8:	0001c697          	auipc	a3,0x1c
    800062ac:	ad868693          	addi	a3,a3,-1320 # 80021d80 <petersonlocks>
    800062b0:	00191793          	slli	a5,s2,0x1
    800062b4:	01278733          	add	a4,a5,s2
    800062b8:	0706                	slli	a4,a4,0x1
    800062ba:	9726                	add	a4,a4,s1
    800062bc:	070a                	slli	a4,a4,0x2
    800062be:	9736                	add	a4,a4,a3
    800062c0:	4585                	li	a1,1
    800062c2:	c30c                	sw	a1,0(a4)
    __sync_synchronize() ;
    800062c4:	0ff0000f          	fence

    plock->turn = other ;
    800062c8:	01278733          	add	a4,a5,s2
    800062cc:	070e                	slli	a4,a4,0x3
    800062ce:	9736                	add	a4,a4,a3
    800062d0:	c710                	sw	a2,8(a4)
    __sync_synchronize() ; 
    800062d2:	0ff0000f          	fence

    while(plock->flag[other] && plock->turn == other){
    800062d6:	97ca                	add	a5,a5,s2
    800062d8:	0786                	slli	a5,a5,0x1
    800062da:	97ce                	add	a5,a5,s3
    800062dc:	078a                	slli	a5,a5,0x2
    800062de:	97b6                	add	a5,a5,a3
    800062e0:	4388                	lw	a0,0(a5)
    800062e2:	c539                	beqz	a0,80006330 <peterson_acquire+0xe2>
    800062e4:	00191793          	slli	a5,s2,0x1
    800062e8:	993e                	add	s2,s2,a5
    800062ea:	8a3a                	mv	s4,a4
    800062ec:	0906                	slli	s2,s2,0x1
    800062ee:	994e                	add	s2,s2,s3
    800062f0:	090a                	slli	s2,s2,0x2
    800062f2:	012684b3          	add	s1,a3,s2
    800062f6:	008a2783          	lw	a5,8(s4)
    800062fa:	03379a63          	bne	a5,s3,8000632e <peterson_acquire+0xe0>
        yield();
    800062fe:	ffffc097          	auipc	ra,0xffffc
    80006302:	d22080e7          	jalr	-734(ra) # 80002020 <yield>
        __sync_synchronize() ;
    80006306:	0ff0000f          	fence
    while(plock->flag[other] && plock->turn == other){
    8000630a:	4088                	lw	a0,0(s1)
    8000630c:	f56d                	bnez	a0,800062f6 <peterson_acquire+0xa8>
    8000630e:	a00d                	j	80006330 <peterson_acquire+0xe2>
        plock->pid[role] = p->pid;
    80006310:	5914                	lw	a3,48(a0)
    80006312:	00191793          	slli	a5,s2,0x1
    80006316:	97ca                	add	a5,a5,s2
    80006318:	0786                	slli	a5,a5,0x1
    8000631a:	97a6                	add	a5,a5,s1
    8000631c:	0791                	addi	a5,a5,4
    8000631e:	078a                	slli	a5,a5,0x2
    80006320:	0001c717          	auipc	a4,0x1c
    80006324:	a6070713          	addi	a4,a4,-1440 # 80021d80 <petersonlocks>
    80006328:	97ba                	add	a5,a5,a4
    8000632a:	c394                	sw	a3,0(a5)
    8000632c:	bf95                	j	800062a0 <peterson_acquire+0x52>
    }
    return 0 ; 
    8000632e:	4501                	li	a0,0
}
    80006330:	70a2                	ld	ra,40(sp)
    80006332:	7402                	ld	s0,32(sp)
    80006334:	64e2                	ld	s1,24(sp)
    80006336:	6942                	ld	s2,16(sp)
    80006338:	69a2                	ld	s3,8(sp)
    8000633a:	6a02                	ld	s4,0(sp)
    8000633c:	6145                	addi	sp,sp,48
    8000633e:	8082                	ret
        return -1 ;  //invalid lockid or role
    80006340:	557d                	li	a0,-1
}
    80006342:	8082                	ret
        return -1 ;  //invalid lockid or role
    80006344:	557d                	li	a0,-1
    80006346:	b7ed                	j	80006330 <peterson_acquire+0xe2>
        return -1;
    80006348:	557d                	li	a0,-1
    8000634a:	b7dd                	j	80006330 <peterson_acquire+0xe2>

000000008000634c <peterson_release>:

int peterson_release(int lock_id , int role){
    

    if(lock_id >= NPETERSONLOCKS || lock_id < 0 || (role !=0 && role !=1) ) 
    8000634c:	47b9                	li	a5,14
    8000634e:	08a7e663          	bltu	a5,a0,800063da <peterson_release+0x8e>
int peterson_release(int lock_id , int role){
    80006352:	1101                	addi	sp,sp,-32
    80006354:	ec06                	sd	ra,24(sp)
    80006356:	e822                	sd	s0,16(sp)
    80006358:	e426                	sd	s1,8(sp)
    8000635a:	e04a                	sd	s2,0(sp)
    8000635c:	1000                	addi	s0,sp,32
    8000635e:	84ae                	mv	s1,a1
    80006360:	892a                	mv	s2,a0
    if(lock_id >= NPETERSONLOCKS || lock_id < 0 || (role !=0 && role !=1) ) 
    80006362:	0005879b          	sext.w	a5,a1
    80006366:	4705                	li	a4,1
    80006368:	06f76b63          	bltu	a4,a5,800063de <peterson_release+0x92>
        return -1 ;  //invalid lockid or role
    
    struct petersonlock* plock = &petersonlocks[lock_id] ;
    
    struct proc *p = myproc() ;
    8000636c:	ffffb097          	auipc	ra,0xffffb
    80006370:	648080e7          	jalr	1608(ra) # 800019b4 <myproc>

    if(plock->pid[role] != p->pid || plock->flag[role] == 0) // if the process actually hold the lock for the role
    80006374:	00191793          	slli	a5,s2,0x1
    80006378:	97ca                	add	a5,a5,s2
    8000637a:	0786                	slli	a5,a5,0x1
    8000637c:	97a6                	add	a5,a5,s1
    8000637e:	0791                	addi	a5,a5,4
    80006380:	078a                	slli	a5,a5,0x2
    80006382:	0001c717          	auipc	a4,0x1c
    80006386:	9fe70713          	addi	a4,a4,-1538 # 80021d80 <petersonlocks>
    8000638a:	97ba                	add	a5,a5,a4
    8000638c:	4398                	lw	a4,0(a5)
    8000638e:	591c                	lw	a5,48(a0)
    80006390:	04f71963          	bne	a4,a5,800063e2 <peterson_release+0x96>
    80006394:	00191793          	slli	a5,s2,0x1
    80006398:	97ca                	add	a5,a5,s2
    8000639a:	0786                	slli	a5,a5,0x1
    8000639c:	97a6                	add	a5,a5,s1
    8000639e:	078a                	slli	a5,a5,0x2
    800063a0:	0001c717          	auipc	a4,0x1c
    800063a4:	9e070713          	addi	a4,a4,-1568 # 80021d80 <petersonlocks>
    800063a8:	97ba                	add	a5,a5,a4
    800063aa:	439c                	lw	a5,0(a5)
    800063ac:	cf8d                	beqz	a5,800063e6 <peterson_release+0x9a>
        return -1 ;

    __sync_synchronize() ;
    800063ae:	0ff0000f          	fence
    __sync_lock_release(&plock->flag[role]) ; // atomically set the flag to 0
    800063b2:	00191793          	slli	a5,s2,0x1
    800063b6:	993e                	add	s2,s2,a5
    800063b8:	0906                	slli	s2,s2,0x1
    800063ba:	94ca                	add	s1,s1,s2
    800063bc:	048a                	slli	s1,s1,0x2
    800063be:	94ba                	add	s1,s1,a4
    800063c0:	0f50000f          	fence	iorw,ow
    800063c4:	0804a02f          	amoswap.w	zero,zero,(s1)
    __sync_synchronize() ;
    800063c8:	0ff0000f          	fence
    return 0 ;
    800063cc:	4501                	li	a0,0
}
    800063ce:	60e2                	ld	ra,24(sp)
    800063d0:	6442                	ld	s0,16(sp)
    800063d2:	64a2                	ld	s1,8(sp)
    800063d4:	6902                	ld	s2,0(sp)
    800063d6:	6105                	addi	sp,sp,32
    800063d8:	8082                	ret
        return -1 ;  //invalid lockid or role
    800063da:	557d                	li	a0,-1
}
    800063dc:	8082                	ret
        return -1 ;  //invalid lockid or role
    800063de:	557d                	li	a0,-1
    800063e0:	b7fd                	j	800063ce <peterson_release+0x82>
        return -1 ;
    800063e2:	557d                	li	a0,-1
    800063e4:	b7ed                	j	800063ce <peterson_release+0x82>
    800063e6:	557d                	li	a0,-1
    800063e8:	b7dd                	j	800063ce <peterson_release+0x82>

00000000800063ea <peterson_destroy>:
int peterson_destroy(int lock_id){
    800063ea:	1141                	addi	sp,sp,-16
    800063ec:	e422                	sd	s0,8(sp)
    800063ee:	0800                	addi	s0,sp,16
    
    

    if(lock_id >= NPETERSONLOCKS || lock_id < 0 ) 
    800063f0:	47b9                	li	a5,14
    800063f2:	02a7e863          	bltu	a5,a0,80006422 <peterson_destroy+0x38>
        return -1 ;  //invalid lockid or role
    
    struct petersonlock* plock = &petersonlocks[lock_id] ;
    __sync_synchronize() ;
    800063f6:	0ff0000f          	fence
    __sync_lock_release(&plock->used) ;
    800063fa:	00151793          	slli	a5,a0,0x1
    800063fe:	97aa                	add	a5,a5,a0
    80006400:	078e                	slli	a5,a5,0x3
    80006402:	0001c717          	auipc	a4,0x1c
    80006406:	97e70713          	addi	a4,a4,-1666 # 80021d80 <petersonlocks>
    8000640a:	97ba                	add	a5,a5,a4
    8000640c:	07b1                	addi	a5,a5,12
    8000640e:	0f50000f          	fence	iorw,ow
    80006412:	0807a02f          	amoswap.w	zero,zero,(a5)
    __sync_synchronize() ;
    80006416:	0ff0000f          	fence
    return 0 ;
    8000641a:	4501                	li	a0,0

}
    8000641c:	6422                	ld	s0,8(sp)
    8000641e:	0141                	addi	sp,sp,16
    80006420:	8082                	ret
        return -1 ;  //invalid lockid or role
    80006422:	557d                	li	a0,-1
    80006424:	bfe5                	j	8000641c <peterson_destroy+0x32>

0000000080006426 <sys_peterson_create>:
#include "spinlock.h"
#include "proc.h"
#include "petersonlock.h"


uint64 sys_peterson_create(void){
    80006426:	1141                	addi	sp,sp,-16
    80006428:	e406                	sd	ra,8(sp)
    8000642a:	e022                	sd	s0,0(sp)
    8000642c:	0800                	addi	s0,sp,16
   return  peterson_create() ;
    8000642e:	00000097          	auipc	ra,0x0
    80006432:	dc4080e7          	jalr	-572(ra) # 800061f2 <peterson_create>
}
    80006436:	60a2                	ld	ra,8(sp)
    80006438:	6402                	ld	s0,0(sp)
    8000643a:	0141                	addi	sp,sp,16
    8000643c:	8082                	ret

000000008000643e <sys_peterson_acquire>:
uint64 sys_peterson_acquire(void){
    8000643e:	1101                	addi	sp,sp,-32
    80006440:	ec06                	sd	ra,24(sp)
    80006442:	e822                	sd	s0,16(sp)
    80006444:	1000                	addi	s0,sp,32
    int lock_id ,  role ; 
    argint(0 , &lock_id) ;
    80006446:	fec40593          	addi	a1,s0,-20
    8000644a:	4501                	li	a0,0
    8000644c:	ffffc097          	auipc	ra,0xffffc
    80006450:	67c080e7          	jalr	1660(ra) # 80002ac8 <argint>
    argint(1 , &role) ;
    80006454:	fe840593          	addi	a1,s0,-24
    80006458:	4505                	li	a0,1
    8000645a:	ffffc097          	auipc	ra,0xffffc
    8000645e:	66e080e7          	jalr	1646(ra) # 80002ac8 <argint>

    return peterson_acquire(lock_id , role) ;
    80006462:	fe842583          	lw	a1,-24(s0)
    80006466:	fec42503          	lw	a0,-20(s0)
    8000646a:	00000097          	auipc	ra,0x0
    8000646e:	de4080e7          	jalr	-540(ra) # 8000624e <peterson_acquire>
}
    80006472:	60e2                	ld	ra,24(sp)
    80006474:	6442                	ld	s0,16(sp)
    80006476:	6105                	addi	sp,sp,32
    80006478:	8082                	ret

000000008000647a <sys_peterson_release>:
uint64 sys_peterson_release(void){
    8000647a:	1101                	addi	sp,sp,-32
    8000647c:	ec06                	sd	ra,24(sp)
    8000647e:	e822                	sd	s0,16(sp)
    80006480:	1000                	addi	s0,sp,32
    int lock_id ,  role ; 
    argint(0 , &lock_id) ;
    80006482:	fec40593          	addi	a1,s0,-20
    80006486:	4501                	li	a0,0
    80006488:	ffffc097          	auipc	ra,0xffffc
    8000648c:	640080e7          	jalr	1600(ra) # 80002ac8 <argint>
    argint(1 , &role) ;
    80006490:	fe840593          	addi	a1,s0,-24
    80006494:	4505                	li	a0,1
    80006496:	ffffc097          	auipc	ra,0xffffc
    8000649a:	632080e7          	jalr	1586(ra) # 80002ac8 <argint>

    return peterson_release(lock_id , role) ;
    8000649e:	fe842583          	lw	a1,-24(s0)
    800064a2:	fec42503          	lw	a0,-20(s0)
    800064a6:	00000097          	auipc	ra,0x0
    800064aa:	ea6080e7          	jalr	-346(ra) # 8000634c <peterson_release>
}
    800064ae:	60e2                	ld	ra,24(sp)
    800064b0:	6442                	ld	s0,16(sp)
    800064b2:	6105                	addi	sp,sp,32
    800064b4:	8082                	ret

00000000800064b6 <sys_peterson_destroy>:
uint64 sys_peterson_destroy(void){
    800064b6:	1101                	addi	sp,sp,-32
    800064b8:	ec06                	sd	ra,24(sp)
    800064ba:	e822                	sd	s0,16(sp)
    800064bc:	1000                	addi	s0,sp,32
    int lock_id  ; 
    argint(0 , &lock_id) ;
    800064be:	fec40593          	addi	a1,s0,-20
    800064c2:	4501                	li	a0,0
    800064c4:	ffffc097          	auipc	ra,0xffffc
    800064c8:	604080e7          	jalr	1540(ra) # 80002ac8 <argint>
    return peterson_destroy(lock_id) ;
    800064cc:	fec42503          	lw	a0,-20(s0)
    800064d0:	00000097          	auipc	ra,0x0
    800064d4:	f1a080e7          	jalr	-230(ra) # 800063ea <peterson_destroy>
}
    800064d8:	60e2                	ld	ra,24(sp)
    800064da:	6442                	ld	s0,16(sp)
    800064dc:	6105                	addi	sp,sp,32
    800064de:	8082                	ret
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
