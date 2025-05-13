
user/_ptest3:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <simple_delay>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// Simple busy-wait sleep (xv6 sleep needs a channel)
void simple_delay(int loops) {
   0:	1101                	addi	sp,sp,-32
   2:	ec22                	sd	s0,24(sp)
   4:	1000                	addi	s0,sp,32
  volatile int i;
  for (i = 0; i < loops * 10000; i++) {
   6:	fe042623          	sw	zero,-20(s0)
   a:	6789                	lui	a5,0x2
   c:	7107879b          	addiw	a5,a5,1808
  10:	02a7853b          	mulw	a0,a5,a0
  14:	fec42783          	lw	a5,-20(s0)
  18:	2781                	sext.w	a5,a5
  1a:	00a7dc63          	bge	a5,a0,32 <simple_delay+0x32>
  1e:	fec42783          	lw	a5,-20(s0)
  22:	2785                	addiw	a5,a5,1
  24:	fef42623          	sw	a5,-20(s0)
  28:	fec42783          	lw	a5,-20(s0)
  2c:	2781                	sext.w	a5,a5
  2e:	fea7c8e3          	blt	a5,a0,1e <simple_delay+0x1e>
    // just waste some cycles
  }
}
  32:	6462                	ld	s0,24(sp)
  34:	6105                	addi	sp,sp,32
  36:	8082                	ret

0000000000000038 <main>:

int
main(int argc, char *argv[])
{
  38:	715d                	addi	sp,sp,-80
  3a:	e486                	sd	ra,72(sp)
  3c:	e0a2                	sd	s0,64(sp)
  3e:	fc26                	sd	s1,56(sp)
  40:	f84a                	sd	s2,48(sp)
  42:	f44e                	sd	s3,40(sp)
  44:	f052                	sd	s4,32(sp)
  46:	ec56                	sd	s5,24(sp)
  48:	e85a                	sd	s6,16(sp)
  4a:	e45e                	sd	s7,8(sp)
  4c:	e062                	sd	s8,0(sp)
  4e:	0880                	addi	s0,sp,80
  int lock_id = peterson_create();
  50:	00000097          	auipc	ra,0x0
  54:	45a080e7          	jalr	1114(ra) # 4aa <peterson_create>
  if (lock_id < 0) {
  58:	02054763          	bltz	a0,86 <main+0x4e>
  5c:	89aa                	mv	s3,a0
    printf("Failed to create lock\n");
    exit(1);
  }

  int fork_ret = fork();
  5e:	00000097          	auipc	ra,0x0
  62:	3a4080e7          	jalr	932(ra) # 402 <fork>
  66:	8c2a                	mv	s8,a0
  int role = (fork_ret > 0) ? 0 : 1;
  68:	00152913          	slti	s2,a0,1

  for (int i = 0; i < 100; i++) {
  6c:	4481                	li	s1,0
      printf("Failed to acquire lock\n");
      exit(1);
    }

    // Critical section
    printf(">>> [Role %d] start iteration %d\n", role, i);
  6e:	00001a97          	auipc	s5,0x1
  72:	b82a8a93          	addi	s5,s5,-1150 # bf0 <tournament_release+0x102>
    simple_delay(1); // waste a little time
    printf("<<< [Role %d] end iteration %d\n", role, i);
  76:	00001a17          	auipc	s4,0x1
  7a:	ba2a0a13          	addi	s4,s4,-1118 # c18 <tournament_release+0x12a>
      printf("Failed to release lock\n");
      exit(1);
    }

    // Random small delay outside critical section
    if (i % 5 == 0) {
  7e:	4b95                	li	s7,5
  for (int i = 0; i < 100; i++) {
  80:	06400b13          	li	s6,100
  84:	a899                	j	da <main+0xa2>
    printf("Failed to create lock\n");
  86:	00001517          	auipc	a0,0x1
  8a:	b3a50513          	addi	a0,a0,-1222 # bc0 <tournament_release+0xd2>
  8e:	00000097          	auipc	ra,0x0
  92:	714080e7          	jalr	1812(ra) # 7a2 <printf>
    exit(1);
  96:	4505                	li	a0,1
  98:	00000097          	auipc	ra,0x0
  9c:	372080e7          	jalr	882(ra) # 40a <exit>
      printf("Failed to acquire lock\n");
  a0:	00001517          	auipc	a0,0x1
  a4:	b3850513          	addi	a0,a0,-1224 # bd8 <tournament_release+0xea>
  a8:	00000097          	auipc	ra,0x0
  ac:	6fa080e7          	jalr	1786(ra) # 7a2 <printf>
      exit(1);
  b0:	4505                	li	a0,1
  b2:	00000097          	auipc	ra,0x0
  b6:	358080e7          	jalr	856(ra) # 40a <exit>
      printf("Failed to release lock\n");
  ba:	00001517          	auipc	a0,0x1
  be:	b7e50513          	addi	a0,a0,-1154 # c38 <tournament_release+0x14a>
  c2:	00000097          	auipc	ra,0x0
  c6:	6e0080e7          	jalr	1760(ra) # 7a2 <printf>
      exit(1);
  ca:	4505                	li	a0,1
  cc:	00000097          	auipc	ra,0x0
  d0:	33e080e7          	jalr	830(ra) # 40a <exit>
  for (int i = 0; i < 100; i++) {
  d4:	2485                	addiw	s1,s1,1
  d6:	05648e63          	beq	s1,s6,132 <main+0xfa>
    if (peterson_acquire(lock_id, role) < 0) {
  da:	85ca                	mv	a1,s2
  dc:	854e                	mv	a0,s3
  de:	00000097          	auipc	ra,0x0
  e2:	3d4080e7          	jalr	980(ra) # 4b2 <peterson_acquire>
  e6:	fa054de3          	bltz	a0,a0 <main+0x68>
    printf(">>> [Role %d] start iteration %d\n", role, i);
  ea:	8626                	mv	a2,s1
  ec:	85ca                	mv	a1,s2
  ee:	8556                	mv	a0,s5
  f0:	00000097          	auipc	ra,0x0
  f4:	6b2080e7          	jalr	1714(ra) # 7a2 <printf>
    simple_delay(1); // waste a little time
  f8:	4505                	li	a0,1
  fa:	00000097          	auipc	ra,0x0
  fe:	f06080e7          	jalr	-250(ra) # 0 <simple_delay>
    printf("<<< [Role %d] end iteration %d\n", role, i);
 102:	8626                	mv	a2,s1
 104:	85ca                	mv	a1,s2
 106:	8552                	mv	a0,s4
 108:	00000097          	auipc	ra,0x0
 10c:	69a080e7          	jalr	1690(ra) # 7a2 <printf>
    if (peterson_release(lock_id, role) < 0) {
 110:	85ca                	mv	a1,s2
 112:	854e                	mv	a0,s3
 114:	00000097          	auipc	ra,0x0
 118:	3a6080e7          	jalr	934(ra) # 4ba <peterson_release>
 11c:	f8054fe3          	bltz	a0,ba <main+0x82>
    if (i % 5 == 0) {
 120:	0374e7bb          	remw	a5,s1,s7
 124:	fbc5                	bnez	a5,d4 <main+0x9c>
      simple_delay(2); // sometimes delay more
 126:	4509                	li	a0,2
 128:	00000097          	auipc	ra,0x0
 12c:	ed8080e7          	jalr	-296(ra) # 0 <simple_delay>
 130:	b755                	j	d4 <main+0x9c>
    }
  }

  if (fork_ret > 0) {
 132:	03805663          	blez	s8,15e <main+0x126>
    wait(0);
 136:	4501                	li	a0,0
 138:	00000097          	auipc	ra,0x0
 13c:	2da080e7          	jalr	730(ra) # 412 <wait>
    printf("Parent process destroying lock\n");
 140:	00001517          	auipc	a0,0x1
 144:	b1050513          	addi	a0,a0,-1264 # c50 <tournament_release+0x162>
 148:	00000097          	auipc	ra,0x0
 14c:	65a080e7          	jalr	1626(ra) # 7a2 <printf>
    if (peterson_destroy(lock_id) < 0) {
 150:	854e                	mv	a0,s3
 152:	00000097          	auipc	ra,0x0
 156:	370080e7          	jalr	880(ra) # 4c2 <peterson_destroy>
 15a:	00054763          	bltz	a0,168 <main+0x130>
      printf("Failed to destroy lock\n");
      exit(1);
    }
  }

  exit(0);
 15e:	4501                	li	a0,0
 160:	00000097          	auipc	ra,0x0
 164:	2aa080e7          	jalr	682(ra) # 40a <exit>
      printf("Failed to destroy lock\n");
 168:	00001517          	auipc	a0,0x1
 16c:	b0850513          	addi	a0,a0,-1272 # c70 <tournament_release+0x182>
 170:	00000097          	auipc	ra,0x0
 174:	632080e7          	jalr	1586(ra) # 7a2 <printf>
      exit(1);
 178:	4505                	li	a0,1
 17a:	00000097          	auipc	ra,0x0
 17e:	290080e7          	jalr	656(ra) # 40a <exit>

0000000000000182 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 182:	1141                	addi	sp,sp,-16
 184:	e406                	sd	ra,8(sp)
 186:	e022                	sd	s0,0(sp)
 188:	0800                	addi	s0,sp,16
  extern int main();
  main();
 18a:	00000097          	auipc	ra,0x0
 18e:	eae080e7          	jalr	-338(ra) # 38 <main>
  exit(0);
 192:	4501                	li	a0,0
 194:	00000097          	auipc	ra,0x0
 198:	276080e7          	jalr	630(ra) # 40a <exit>

000000000000019c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 19c:	1141                	addi	sp,sp,-16
 19e:	e422                	sd	s0,8(sp)
 1a0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1a2:	87aa                	mv	a5,a0
 1a4:	0585                	addi	a1,a1,1
 1a6:	0785                	addi	a5,a5,1
 1a8:	fff5c703          	lbu	a4,-1(a1)
 1ac:	fee78fa3          	sb	a4,-1(a5) # 1fff <lock_ids+0xfcf>
 1b0:	fb75                	bnez	a4,1a4 <strcpy+0x8>
    ;
  return os;
}
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	addi	sp,sp,16
 1b6:	8082                	ret

00000000000001b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b8:	1141                	addi	sp,sp,-16
 1ba:	e422                	sd	s0,8(sp)
 1bc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	cb91                	beqz	a5,1d6 <strcmp+0x1e>
 1c4:	0005c703          	lbu	a4,0(a1)
 1c8:	00f71763          	bne	a4,a5,1d6 <strcmp+0x1e>
    p++, q++;
 1cc:	0505                	addi	a0,a0,1
 1ce:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1d0:	00054783          	lbu	a5,0(a0)
 1d4:	fbe5                	bnez	a5,1c4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1d6:	0005c503          	lbu	a0,0(a1)
}
 1da:	40a7853b          	subw	a0,a5,a0
 1de:	6422                	ld	s0,8(sp)
 1e0:	0141                	addi	sp,sp,16
 1e2:	8082                	ret

00000000000001e4 <strlen>:

uint
strlen(const char *s)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ea:	00054783          	lbu	a5,0(a0)
 1ee:	cf91                	beqz	a5,20a <strlen+0x26>
 1f0:	0505                	addi	a0,a0,1
 1f2:	87aa                	mv	a5,a0
 1f4:	4685                	li	a3,1
 1f6:	9e89                	subw	a3,a3,a0
 1f8:	00f6853b          	addw	a0,a3,a5
 1fc:	0785                	addi	a5,a5,1
 1fe:	fff7c703          	lbu	a4,-1(a5)
 202:	fb7d                	bnez	a4,1f8 <strlen+0x14>
    ;
  return n;
}
 204:	6422                	ld	s0,8(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret
  for(n = 0; s[n]; n++)
 20a:	4501                	li	a0,0
 20c:	bfe5                	j	204 <strlen+0x20>

000000000000020e <memset>:

void*
memset(void *dst, int c, uint n)
{
 20e:	1141                	addi	sp,sp,-16
 210:	e422                	sd	s0,8(sp)
 212:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 214:	ca19                	beqz	a2,22a <memset+0x1c>
 216:	87aa                	mv	a5,a0
 218:	1602                	slli	a2,a2,0x20
 21a:	9201                	srli	a2,a2,0x20
 21c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 220:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 224:	0785                	addi	a5,a5,1
 226:	fee79de3          	bne	a5,a4,220 <memset+0x12>
  }
  return dst;
}
 22a:	6422                	ld	s0,8(sp)
 22c:	0141                	addi	sp,sp,16
 22e:	8082                	ret

0000000000000230 <strchr>:

char*
strchr(const char *s, char c)
{
 230:	1141                	addi	sp,sp,-16
 232:	e422                	sd	s0,8(sp)
 234:	0800                	addi	s0,sp,16
  for(; *s; s++)
 236:	00054783          	lbu	a5,0(a0)
 23a:	cb99                	beqz	a5,250 <strchr+0x20>
    if(*s == c)
 23c:	00f58763          	beq	a1,a5,24a <strchr+0x1a>
  for(; *s; s++)
 240:	0505                	addi	a0,a0,1
 242:	00054783          	lbu	a5,0(a0)
 246:	fbfd                	bnez	a5,23c <strchr+0xc>
      return (char*)s;
  return 0;
 248:	4501                	li	a0,0
}
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret
  return 0;
 250:	4501                	li	a0,0
 252:	bfe5                	j	24a <strchr+0x1a>

0000000000000254 <gets>:

char*
gets(char *buf, int max)
{
 254:	711d                	addi	sp,sp,-96
 256:	ec86                	sd	ra,88(sp)
 258:	e8a2                	sd	s0,80(sp)
 25a:	e4a6                	sd	s1,72(sp)
 25c:	e0ca                	sd	s2,64(sp)
 25e:	fc4e                	sd	s3,56(sp)
 260:	f852                	sd	s4,48(sp)
 262:	f456                	sd	s5,40(sp)
 264:	f05a                	sd	s6,32(sp)
 266:	ec5e                	sd	s7,24(sp)
 268:	1080                	addi	s0,sp,96
 26a:	8baa                	mv	s7,a0
 26c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26e:	892a                	mv	s2,a0
 270:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 272:	4aa9                	li	s5,10
 274:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 276:	89a6                	mv	s3,s1
 278:	2485                	addiw	s1,s1,1
 27a:	0344d863          	bge	s1,s4,2aa <gets+0x56>
    cc = read(0, &c, 1);
 27e:	4605                	li	a2,1
 280:	faf40593          	addi	a1,s0,-81
 284:	4501                	li	a0,0
 286:	00000097          	auipc	ra,0x0
 28a:	19c080e7          	jalr	412(ra) # 422 <read>
    if(cc < 1)
 28e:	00a05e63          	blez	a0,2aa <gets+0x56>
    buf[i++] = c;
 292:	faf44783          	lbu	a5,-81(s0)
 296:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 29a:	01578763          	beq	a5,s5,2a8 <gets+0x54>
 29e:	0905                	addi	s2,s2,1
 2a0:	fd679be3          	bne	a5,s6,276 <gets+0x22>
  for(i=0; i+1 < max; ){
 2a4:	89a6                	mv	s3,s1
 2a6:	a011                	j	2aa <gets+0x56>
 2a8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2aa:	99de                	add	s3,s3,s7
 2ac:	00098023          	sb	zero,0(s3)
  return buf;
}
 2b0:	855e                	mv	a0,s7
 2b2:	60e6                	ld	ra,88(sp)
 2b4:	6446                	ld	s0,80(sp)
 2b6:	64a6                	ld	s1,72(sp)
 2b8:	6906                	ld	s2,64(sp)
 2ba:	79e2                	ld	s3,56(sp)
 2bc:	7a42                	ld	s4,48(sp)
 2be:	7aa2                	ld	s5,40(sp)
 2c0:	7b02                	ld	s6,32(sp)
 2c2:	6be2                	ld	s7,24(sp)
 2c4:	6125                	addi	sp,sp,96
 2c6:	8082                	ret

00000000000002c8 <stat>:

int
stat(const char *n, struct stat *st)
{
 2c8:	1101                	addi	sp,sp,-32
 2ca:	ec06                	sd	ra,24(sp)
 2cc:	e822                	sd	s0,16(sp)
 2ce:	e426                	sd	s1,8(sp)
 2d0:	e04a                	sd	s2,0(sp)
 2d2:	1000                	addi	s0,sp,32
 2d4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d6:	4581                	li	a1,0
 2d8:	00000097          	auipc	ra,0x0
 2dc:	172080e7          	jalr	370(ra) # 44a <open>
  if(fd < 0)
 2e0:	02054563          	bltz	a0,30a <stat+0x42>
 2e4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2e6:	85ca                	mv	a1,s2
 2e8:	00000097          	auipc	ra,0x0
 2ec:	17a080e7          	jalr	378(ra) # 462 <fstat>
 2f0:	892a                	mv	s2,a0
  close(fd);
 2f2:	8526                	mv	a0,s1
 2f4:	00000097          	auipc	ra,0x0
 2f8:	13e080e7          	jalr	318(ra) # 432 <close>
  return r;
}
 2fc:	854a                	mv	a0,s2
 2fe:	60e2                	ld	ra,24(sp)
 300:	6442                	ld	s0,16(sp)
 302:	64a2                	ld	s1,8(sp)
 304:	6902                	ld	s2,0(sp)
 306:	6105                	addi	sp,sp,32
 308:	8082                	ret
    return -1;
 30a:	597d                	li	s2,-1
 30c:	bfc5                	j	2fc <stat+0x34>

000000000000030e <atoi>:

int
atoi(const char *s)
{
 30e:	1141                	addi	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 314:	00054603          	lbu	a2,0(a0)
 318:	fd06079b          	addiw	a5,a2,-48
 31c:	0ff7f793          	andi	a5,a5,255
 320:	4725                	li	a4,9
 322:	02f76963          	bltu	a4,a5,354 <atoi+0x46>
 326:	86aa                	mv	a3,a0
  n = 0;
 328:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 32a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 32c:	0685                	addi	a3,a3,1
 32e:	0025179b          	slliw	a5,a0,0x2
 332:	9fa9                	addw	a5,a5,a0
 334:	0017979b          	slliw	a5,a5,0x1
 338:	9fb1                	addw	a5,a5,a2
 33a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 33e:	0006c603          	lbu	a2,0(a3)
 342:	fd06071b          	addiw	a4,a2,-48
 346:	0ff77713          	andi	a4,a4,255
 34a:	fee5f1e3          	bgeu	a1,a4,32c <atoi+0x1e>
  return n;
}
 34e:	6422                	ld	s0,8(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret
  n = 0;
 354:	4501                	li	a0,0
 356:	bfe5                	j	34e <atoi+0x40>

0000000000000358 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 358:	1141                	addi	sp,sp,-16
 35a:	e422                	sd	s0,8(sp)
 35c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 35e:	02b57463          	bgeu	a0,a1,386 <memmove+0x2e>
    while(n-- > 0)
 362:	00c05f63          	blez	a2,380 <memmove+0x28>
 366:	1602                	slli	a2,a2,0x20
 368:	9201                	srli	a2,a2,0x20
 36a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 36e:	872a                	mv	a4,a0
      *dst++ = *src++;
 370:	0585                	addi	a1,a1,1
 372:	0705                	addi	a4,a4,1
 374:	fff5c683          	lbu	a3,-1(a1)
 378:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 37c:	fee79ae3          	bne	a5,a4,370 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 380:	6422                	ld	s0,8(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret
    dst += n;
 386:	00c50733          	add	a4,a0,a2
    src += n;
 38a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 38c:	fec05ae3          	blez	a2,380 <memmove+0x28>
 390:	fff6079b          	addiw	a5,a2,-1
 394:	1782                	slli	a5,a5,0x20
 396:	9381                	srli	a5,a5,0x20
 398:	fff7c793          	not	a5,a5
 39c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 39e:	15fd                	addi	a1,a1,-1
 3a0:	177d                	addi	a4,a4,-1
 3a2:	0005c683          	lbu	a3,0(a1)
 3a6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3aa:	fee79ae3          	bne	a5,a4,39e <memmove+0x46>
 3ae:	bfc9                	j	380 <memmove+0x28>

00000000000003b0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3b0:	1141                	addi	sp,sp,-16
 3b2:	e422                	sd	s0,8(sp)
 3b4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3b6:	ca05                	beqz	a2,3e6 <memcmp+0x36>
 3b8:	fff6069b          	addiw	a3,a2,-1
 3bc:	1682                	slli	a3,a3,0x20
 3be:	9281                	srli	a3,a3,0x20
 3c0:	0685                	addi	a3,a3,1
 3c2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3c4:	00054783          	lbu	a5,0(a0)
 3c8:	0005c703          	lbu	a4,0(a1)
 3cc:	00e79863          	bne	a5,a4,3dc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3d0:	0505                	addi	a0,a0,1
    p2++;
 3d2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3d4:	fed518e3          	bne	a0,a3,3c4 <memcmp+0x14>
  }
  return 0;
 3d8:	4501                	li	a0,0
 3da:	a019                	j	3e0 <memcmp+0x30>
      return *p1 - *p2;
 3dc:	40e7853b          	subw	a0,a5,a4
}
 3e0:	6422                	ld	s0,8(sp)
 3e2:	0141                	addi	sp,sp,16
 3e4:	8082                	ret
  return 0;
 3e6:	4501                	li	a0,0
 3e8:	bfe5                	j	3e0 <memcmp+0x30>

00000000000003ea <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ea:	1141                	addi	sp,sp,-16
 3ec:	e406                	sd	ra,8(sp)
 3ee:	e022                	sd	s0,0(sp)
 3f0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3f2:	00000097          	auipc	ra,0x0
 3f6:	f66080e7          	jalr	-154(ra) # 358 <memmove>
}
 3fa:	60a2                	ld	ra,8(sp)
 3fc:	6402                	ld	s0,0(sp)
 3fe:	0141                	addi	sp,sp,16
 400:	8082                	ret

0000000000000402 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 402:	4885                	li	a7,1
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <exit>:
.global exit
exit:
 li a7, SYS_exit
 40a:	4889                	li	a7,2
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <wait>:
.global wait
wait:
 li a7, SYS_wait
 412:	488d                	li	a7,3
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 41a:	4891                	li	a7,4
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <read>:
.global read
read:
 li a7, SYS_read
 422:	4895                	li	a7,5
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <write>:
.global write
write:
 li a7, SYS_write
 42a:	48c1                	li	a7,16
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <close>:
.global close
close:
 li a7, SYS_close
 432:	48d5                	li	a7,21
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <kill>:
.global kill
kill:
 li a7, SYS_kill
 43a:	4899                	li	a7,6
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <exec>:
.global exec
exec:
 li a7, SYS_exec
 442:	489d                	li	a7,7
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <open>:
.global open
open:
 li a7, SYS_open
 44a:	48bd                	li	a7,15
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 452:	48c5                	li	a7,17
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 45a:	48c9                	li	a7,18
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 462:	48a1                	li	a7,8
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <link>:
.global link
link:
 li a7, SYS_link
 46a:	48cd                	li	a7,19
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 472:	48d1                	li	a7,20
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 47a:	48a5                	li	a7,9
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <dup>:
.global dup
dup:
 li a7, SYS_dup
 482:	48a9                	li	a7,10
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 48a:	48ad                	li	a7,11
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 492:	48b1                	li	a7,12
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 49a:	48b5                	li	a7,13
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4a2:	48b9                	li	a7,14
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <peterson_create>:
.global peterson_create
peterson_create:
 li a7, SYS_peterson_create
 4aa:	48d9                	li	a7,22
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <peterson_acquire>:
.global peterson_acquire
peterson_acquire:
 li a7, SYS_peterson_acquire
 4b2:	48dd                	li	a7,23
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <peterson_release>:
.global peterson_release
peterson_release:
 li a7, SYS_peterson_release
 4ba:	48e1                	li	a7,24
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <peterson_destroy>:
.global peterson_destroy
peterson_destroy:
 li a7, SYS_peterson_destroy
 4c2:	48e5                	li	a7,25
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ca:	1101                	addi	sp,sp,-32
 4cc:	ec06                	sd	ra,24(sp)
 4ce:	e822                	sd	s0,16(sp)
 4d0:	1000                	addi	s0,sp,32
 4d2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4d6:	4605                	li	a2,1
 4d8:	fef40593          	addi	a1,s0,-17
 4dc:	00000097          	auipc	ra,0x0
 4e0:	f4e080e7          	jalr	-178(ra) # 42a <write>
}
 4e4:	60e2                	ld	ra,24(sp)
 4e6:	6442                	ld	s0,16(sp)
 4e8:	6105                	addi	sp,sp,32
 4ea:	8082                	ret

00000000000004ec <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ec:	7139                	addi	sp,sp,-64
 4ee:	fc06                	sd	ra,56(sp)
 4f0:	f822                	sd	s0,48(sp)
 4f2:	f426                	sd	s1,40(sp)
 4f4:	f04a                	sd	s2,32(sp)
 4f6:	ec4e                	sd	s3,24(sp)
 4f8:	0080                	addi	s0,sp,64
 4fa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4fc:	c299                	beqz	a3,502 <printint+0x16>
 4fe:	0805c863          	bltz	a1,58e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 502:	2581                	sext.w	a1,a1
  neg = 0;
 504:	4881                	li	a7,0
 506:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 50a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 50c:	2601                	sext.w	a2,a2
 50e:	00000517          	auipc	a0,0x0
 512:	78250513          	addi	a0,a0,1922 # c90 <digits>
 516:	883a                	mv	a6,a4
 518:	2705                	addiw	a4,a4,1
 51a:	02c5f7bb          	remuw	a5,a1,a2
 51e:	1782                	slli	a5,a5,0x20
 520:	9381                	srli	a5,a5,0x20
 522:	97aa                	add	a5,a5,a0
 524:	0007c783          	lbu	a5,0(a5)
 528:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 52c:	0005879b          	sext.w	a5,a1
 530:	02c5d5bb          	divuw	a1,a1,a2
 534:	0685                	addi	a3,a3,1
 536:	fec7f0e3          	bgeu	a5,a2,516 <printint+0x2a>
  if(neg)
 53a:	00088b63          	beqz	a7,550 <printint+0x64>
    buf[i++] = '-';
 53e:	fd040793          	addi	a5,s0,-48
 542:	973e                	add	a4,a4,a5
 544:	02d00793          	li	a5,45
 548:	fef70823          	sb	a5,-16(a4)
 54c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 550:	02e05863          	blez	a4,580 <printint+0x94>
 554:	fc040793          	addi	a5,s0,-64
 558:	00e78933          	add	s2,a5,a4
 55c:	fff78993          	addi	s3,a5,-1
 560:	99ba                	add	s3,s3,a4
 562:	377d                	addiw	a4,a4,-1
 564:	1702                	slli	a4,a4,0x20
 566:	9301                	srli	a4,a4,0x20
 568:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 56c:	fff94583          	lbu	a1,-1(s2)
 570:	8526                	mv	a0,s1
 572:	00000097          	auipc	ra,0x0
 576:	f58080e7          	jalr	-168(ra) # 4ca <putc>
  while(--i >= 0)
 57a:	197d                	addi	s2,s2,-1
 57c:	ff3918e3          	bne	s2,s3,56c <printint+0x80>
}
 580:	70e2                	ld	ra,56(sp)
 582:	7442                	ld	s0,48(sp)
 584:	74a2                	ld	s1,40(sp)
 586:	7902                	ld	s2,32(sp)
 588:	69e2                	ld	s3,24(sp)
 58a:	6121                	addi	sp,sp,64
 58c:	8082                	ret
    x = -xx;
 58e:	40b005bb          	negw	a1,a1
    neg = 1;
 592:	4885                	li	a7,1
    x = -xx;
 594:	bf8d                	j	506 <printint+0x1a>

0000000000000596 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 596:	7119                	addi	sp,sp,-128
 598:	fc86                	sd	ra,120(sp)
 59a:	f8a2                	sd	s0,112(sp)
 59c:	f4a6                	sd	s1,104(sp)
 59e:	f0ca                	sd	s2,96(sp)
 5a0:	ecce                	sd	s3,88(sp)
 5a2:	e8d2                	sd	s4,80(sp)
 5a4:	e4d6                	sd	s5,72(sp)
 5a6:	e0da                	sd	s6,64(sp)
 5a8:	fc5e                	sd	s7,56(sp)
 5aa:	f862                	sd	s8,48(sp)
 5ac:	f466                	sd	s9,40(sp)
 5ae:	f06a                	sd	s10,32(sp)
 5b0:	ec6e                	sd	s11,24(sp)
 5b2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5b4:	0005c903          	lbu	s2,0(a1)
 5b8:	18090f63          	beqz	s2,756 <vprintf+0x1c0>
 5bc:	8aaa                	mv	s5,a0
 5be:	8b32                	mv	s6,a2
 5c0:	00158493          	addi	s1,a1,1
  state = 0;
 5c4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5c6:	02500a13          	li	s4,37
      if(c == 'd'){
 5ca:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5ce:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5d2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5d6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5da:	00000b97          	auipc	s7,0x0
 5de:	6b6b8b93          	addi	s7,s7,1718 # c90 <digits>
 5e2:	a839                	j	600 <vprintf+0x6a>
        putc(fd, c);
 5e4:	85ca                	mv	a1,s2
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	ee2080e7          	jalr	-286(ra) # 4ca <putc>
 5f0:	a019                	j	5f6 <vprintf+0x60>
    } else if(state == '%'){
 5f2:	01498f63          	beq	s3,s4,610 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5f6:	0485                	addi	s1,s1,1
 5f8:	fff4c903          	lbu	s2,-1(s1)
 5fc:	14090d63          	beqz	s2,756 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 600:	0009079b          	sext.w	a5,s2
    if(state == 0){
 604:	fe0997e3          	bnez	s3,5f2 <vprintf+0x5c>
      if(c == '%'){
 608:	fd479ee3          	bne	a5,s4,5e4 <vprintf+0x4e>
        state = '%';
 60c:	89be                	mv	s3,a5
 60e:	b7e5                	j	5f6 <vprintf+0x60>
      if(c == 'd'){
 610:	05878063          	beq	a5,s8,650 <vprintf+0xba>
      } else if(c == 'l') {
 614:	05978c63          	beq	a5,s9,66c <vprintf+0xd6>
      } else if(c == 'x') {
 618:	07a78863          	beq	a5,s10,688 <vprintf+0xf2>
      } else if(c == 'p') {
 61c:	09b78463          	beq	a5,s11,6a4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 620:	07300713          	li	a4,115
 624:	0ce78663          	beq	a5,a4,6f0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 628:	06300713          	li	a4,99
 62c:	0ee78e63          	beq	a5,a4,728 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 630:	11478863          	beq	a5,s4,740 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 634:	85d2                	mv	a1,s4
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	e92080e7          	jalr	-366(ra) # 4ca <putc>
        putc(fd, c);
 640:	85ca                	mv	a1,s2
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	e86080e7          	jalr	-378(ra) # 4ca <putc>
      }
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b765                	j	5f6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 650:	008b0913          	addi	s2,s6,8
 654:	4685                	li	a3,1
 656:	4629                	li	a2,10
 658:	000b2583          	lw	a1,0(s6)
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	e8e080e7          	jalr	-370(ra) # 4ec <printint>
 666:	8b4a                	mv	s6,s2
      state = 0;
 668:	4981                	li	s3,0
 66a:	b771                	j	5f6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66c:	008b0913          	addi	s2,s6,8
 670:	4681                	li	a3,0
 672:	4629                	li	a2,10
 674:	000b2583          	lw	a1,0(s6)
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	e72080e7          	jalr	-398(ra) # 4ec <printint>
 682:	8b4a                	mv	s6,s2
      state = 0;
 684:	4981                	li	s3,0
 686:	bf85                	j	5f6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 688:	008b0913          	addi	s2,s6,8
 68c:	4681                	li	a3,0
 68e:	4641                	li	a2,16
 690:	000b2583          	lw	a1,0(s6)
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	e56080e7          	jalr	-426(ra) # 4ec <printint>
 69e:	8b4a                	mv	s6,s2
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	bf91                	j	5f6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6a4:	008b0793          	addi	a5,s6,8
 6a8:	f8f43423          	sd	a5,-120(s0)
 6ac:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6b0:	03000593          	li	a1,48
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e14080e7          	jalr	-492(ra) # 4ca <putc>
  putc(fd, 'x');
 6be:	85ea                	mv	a1,s10
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	e08080e7          	jalr	-504(ra) # 4ca <putc>
 6ca:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6cc:	03c9d793          	srli	a5,s3,0x3c
 6d0:	97de                	add	a5,a5,s7
 6d2:	0007c583          	lbu	a1,0(a5)
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	df2080e7          	jalr	-526(ra) # 4ca <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e0:	0992                	slli	s3,s3,0x4
 6e2:	397d                	addiw	s2,s2,-1
 6e4:	fe0914e3          	bnez	s2,6cc <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6e8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b721                	j	5f6 <vprintf+0x60>
        s = va_arg(ap, char*);
 6f0:	008b0993          	addi	s3,s6,8
 6f4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6f8:	02090163          	beqz	s2,71a <vprintf+0x184>
        while(*s != 0){
 6fc:	00094583          	lbu	a1,0(s2)
 700:	c9a1                	beqz	a1,750 <vprintf+0x1ba>
          putc(fd, *s);
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	dc6080e7          	jalr	-570(ra) # 4ca <putc>
          s++;
 70c:	0905                	addi	s2,s2,1
        while(*s != 0){
 70e:	00094583          	lbu	a1,0(s2)
 712:	f9e5                	bnez	a1,702 <vprintf+0x16c>
        s = va_arg(ap, char*);
 714:	8b4e                	mv	s6,s3
      state = 0;
 716:	4981                	li	s3,0
 718:	bdf9                	j	5f6 <vprintf+0x60>
          s = "(null)";
 71a:	00000917          	auipc	s2,0x0
 71e:	56e90913          	addi	s2,s2,1390 # c88 <tournament_release+0x19a>
        while(*s != 0){
 722:	02800593          	li	a1,40
 726:	bff1                	j	702 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 728:	008b0913          	addi	s2,s6,8
 72c:	000b4583          	lbu	a1,0(s6)
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	d98080e7          	jalr	-616(ra) # 4ca <putc>
 73a:	8b4a                	mv	s6,s2
      state = 0;
 73c:	4981                	li	s3,0
 73e:	bd65                	j	5f6 <vprintf+0x60>
        putc(fd, c);
 740:	85d2                	mv	a1,s4
 742:	8556                	mv	a0,s5
 744:	00000097          	auipc	ra,0x0
 748:	d86080e7          	jalr	-634(ra) # 4ca <putc>
      state = 0;
 74c:	4981                	li	s3,0
 74e:	b565                	j	5f6 <vprintf+0x60>
        s = va_arg(ap, char*);
 750:	8b4e                	mv	s6,s3
      state = 0;
 752:	4981                	li	s3,0
 754:	b54d                	j	5f6 <vprintf+0x60>
    }
  }
}
 756:	70e6                	ld	ra,120(sp)
 758:	7446                	ld	s0,112(sp)
 75a:	74a6                	ld	s1,104(sp)
 75c:	7906                	ld	s2,96(sp)
 75e:	69e6                	ld	s3,88(sp)
 760:	6a46                	ld	s4,80(sp)
 762:	6aa6                	ld	s5,72(sp)
 764:	6b06                	ld	s6,64(sp)
 766:	7be2                	ld	s7,56(sp)
 768:	7c42                	ld	s8,48(sp)
 76a:	7ca2                	ld	s9,40(sp)
 76c:	7d02                	ld	s10,32(sp)
 76e:	6de2                	ld	s11,24(sp)
 770:	6109                	addi	sp,sp,128
 772:	8082                	ret

0000000000000774 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 774:	715d                	addi	sp,sp,-80
 776:	ec06                	sd	ra,24(sp)
 778:	e822                	sd	s0,16(sp)
 77a:	1000                	addi	s0,sp,32
 77c:	e010                	sd	a2,0(s0)
 77e:	e414                	sd	a3,8(s0)
 780:	e818                	sd	a4,16(s0)
 782:	ec1c                	sd	a5,24(s0)
 784:	03043023          	sd	a6,32(s0)
 788:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 78c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 790:	8622                	mv	a2,s0
 792:	00000097          	auipc	ra,0x0
 796:	e04080e7          	jalr	-508(ra) # 596 <vprintf>
}
 79a:	60e2                	ld	ra,24(sp)
 79c:	6442                	ld	s0,16(sp)
 79e:	6161                	addi	sp,sp,80
 7a0:	8082                	ret

00000000000007a2 <printf>:

void
printf(const char *fmt, ...)
{
 7a2:	711d                	addi	sp,sp,-96
 7a4:	ec06                	sd	ra,24(sp)
 7a6:	e822                	sd	s0,16(sp)
 7a8:	1000                	addi	s0,sp,32
 7aa:	e40c                	sd	a1,8(s0)
 7ac:	e810                	sd	a2,16(s0)
 7ae:	ec14                	sd	a3,24(s0)
 7b0:	f018                	sd	a4,32(s0)
 7b2:	f41c                	sd	a5,40(s0)
 7b4:	03043823          	sd	a6,48(s0)
 7b8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7bc:	00840613          	addi	a2,s0,8
 7c0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c4:	85aa                	mv	a1,a0
 7c6:	4505                	li	a0,1
 7c8:	00000097          	auipc	ra,0x0
 7cc:	dce080e7          	jalr	-562(ra) # 596 <vprintf>
}
 7d0:	60e2                	ld	ra,24(sp)
 7d2:	6442                	ld	s0,16(sp)
 7d4:	6125                	addi	sp,sp,96
 7d6:	8082                	ret

00000000000007d8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7d8:	1141                	addi	sp,sp,-16
 7da:	e422                	sd	s0,8(sp)
 7dc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7de:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e2:	00001797          	auipc	a5,0x1
 7e6:	81e7b783          	ld	a5,-2018(a5) # 1000 <freep>
 7ea:	a805                	j	81a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ec:	4618                	lw	a4,8(a2)
 7ee:	9db9                	addw	a1,a1,a4
 7f0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f4:	6398                	ld	a4,0(a5)
 7f6:	6318                	ld	a4,0(a4)
 7f8:	fee53823          	sd	a4,-16(a0)
 7fc:	a091                	j	840 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7fe:	ff852703          	lw	a4,-8(a0)
 802:	9e39                	addw	a2,a2,a4
 804:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 806:	ff053703          	ld	a4,-16(a0)
 80a:	e398                	sd	a4,0(a5)
 80c:	a099                	j	852 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80e:	6398                	ld	a4,0(a5)
 810:	00e7e463          	bltu	a5,a4,818 <free+0x40>
 814:	00e6ea63          	bltu	a3,a4,828 <free+0x50>
{
 818:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81a:	fed7fae3          	bgeu	a5,a3,80e <free+0x36>
 81e:	6398                	ld	a4,0(a5)
 820:	00e6e463          	bltu	a3,a4,828 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 824:	fee7eae3          	bltu	a5,a4,818 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 828:	ff852583          	lw	a1,-8(a0)
 82c:	6390                	ld	a2,0(a5)
 82e:	02059713          	slli	a4,a1,0x20
 832:	9301                	srli	a4,a4,0x20
 834:	0712                	slli	a4,a4,0x4
 836:	9736                	add	a4,a4,a3
 838:	fae60ae3          	beq	a2,a4,7ec <free+0x14>
    bp->s.ptr = p->s.ptr;
 83c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 840:	4790                	lw	a2,8(a5)
 842:	02061713          	slli	a4,a2,0x20
 846:	9301                	srli	a4,a4,0x20
 848:	0712                	slli	a4,a4,0x4
 84a:	973e                	add	a4,a4,a5
 84c:	fae689e3          	beq	a3,a4,7fe <free+0x26>
  } else
    p->s.ptr = bp;
 850:	e394                	sd	a3,0(a5)
  freep = p;
 852:	00000717          	auipc	a4,0x0
 856:	7af73723          	sd	a5,1966(a4) # 1000 <freep>
}
 85a:	6422                	ld	s0,8(sp)
 85c:	0141                	addi	sp,sp,16
 85e:	8082                	ret

0000000000000860 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 860:	7139                	addi	sp,sp,-64
 862:	fc06                	sd	ra,56(sp)
 864:	f822                	sd	s0,48(sp)
 866:	f426                	sd	s1,40(sp)
 868:	f04a                	sd	s2,32(sp)
 86a:	ec4e                	sd	s3,24(sp)
 86c:	e852                	sd	s4,16(sp)
 86e:	e456                	sd	s5,8(sp)
 870:	e05a                	sd	s6,0(sp)
 872:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 874:	02051493          	slli	s1,a0,0x20
 878:	9081                	srli	s1,s1,0x20
 87a:	04bd                	addi	s1,s1,15
 87c:	8091                	srli	s1,s1,0x4
 87e:	0014899b          	addiw	s3,s1,1
 882:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 884:	00000517          	auipc	a0,0x0
 888:	77c53503          	ld	a0,1916(a0) # 1000 <freep>
 88c:	c515                	beqz	a0,8b8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 890:	4798                	lw	a4,8(a5)
 892:	02977f63          	bgeu	a4,s1,8d0 <malloc+0x70>
 896:	8a4e                	mv	s4,s3
 898:	0009871b          	sext.w	a4,s3
 89c:	6685                	lui	a3,0x1
 89e:	00d77363          	bgeu	a4,a3,8a4 <malloc+0x44>
 8a2:	6a05                	lui	s4,0x1
 8a4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8a8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ac:	00000917          	auipc	s2,0x0
 8b0:	75490913          	addi	s2,s2,1876 # 1000 <freep>
  if(p == (char*)-1)
 8b4:	5afd                	li	s5,-1
 8b6:	a88d                	j	928 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8b8:	00000797          	auipc	a5,0x0
 8bc:	76878793          	addi	a5,a5,1896 # 1020 <base>
 8c0:	00000717          	auipc	a4,0x0
 8c4:	74f73023          	sd	a5,1856(a4) # 1000 <freep>
 8c8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ca:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ce:	b7e1                	j	896 <malloc+0x36>
      if(p->s.size == nunits)
 8d0:	02e48b63          	beq	s1,a4,906 <malloc+0xa6>
        p->s.size -= nunits;
 8d4:	4137073b          	subw	a4,a4,s3
 8d8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8da:	1702                	slli	a4,a4,0x20
 8dc:	9301                	srli	a4,a4,0x20
 8de:	0712                	slli	a4,a4,0x4
 8e0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8e6:	00000717          	auipc	a4,0x0
 8ea:	70a73d23          	sd	a0,1818(a4) # 1000 <freep>
      return (void*)(p + 1);
 8ee:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f2:	70e2                	ld	ra,56(sp)
 8f4:	7442                	ld	s0,48(sp)
 8f6:	74a2                	ld	s1,40(sp)
 8f8:	7902                	ld	s2,32(sp)
 8fa:	69e2                	ld	s3,24(sp)
 8fc:	6a42                	ld	s4,16(sp)
 8fe:	6aa2                	ld	s5,8(sp)
 900:	6b02                	ld	s6,0(sp)
 902:	6121                	addi	sp,sp,64
 904:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 906:	6398                	ld	a4,0(a5)
 908:	e118                	sd	a4,0(a0)
 90a:	bff1                	j	8e6 <malloc+0x86>
  hp->s.size = nu;
 90c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 910:	0541                	addi	a0,a0,16
 912:	00000097          	auipc	ra,0x0
 916:	ec6080e7          	jalr	-314(ra) # 7d8 <free>
  return freep;
 91a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 91e:	d971                	beqz	a0,8f2 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 920:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 922:	4798                	lw	a4,8(a5)
 924:	fa9776e3          	bgeu	a4,s1,8d0 <malloc+0x70>
    if(p == freep)
 928:	00093703          	ld	a4,0(s2)
 92c:	853e                	mv	a0,a5
 92e:	fef719e3          	bne	a4,a5,920 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 932:	8552                	mv	a0,s4
 934:	00000097          	auipc	ra,0x0
 938:	b5e080e7          	jalr	-1186(ra) # 492 <sbrk>
  if(p == (char*)-1)
 93c:	fd5518e3          	bne	a0,s5,90c <malloc+0xac>
        return 0;
 940:	4501                	li	a0,0
 942:	bf45                	j	8f2 <malloc+0x92>

0000000000000944 <tournament_create>:
    l++;
  }
  return l;
}

int tournament_create(int processes) {
 944:	7179                	addi	sp,sp,-48
 946:	f406                	sd	ra,40(sp)
 948:	f022                	sd	s0,32(sp)
 94a:	ec26                	sd	s1,24(sp)
 94c:	e84a                	sd	s2,16(sp)
 94e:	e44e                	sd	s3,8(sp)
 950:	e052                	sd	s4,0(sp)
 952:	1800                	addi	s0,sp,48
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 954:	fff5071b          	addiw	a4,a0,-1
 958:	47bd                	li	a5,15
 95a:	00e7ee63          	bltu	a5,a4,976 <tournament_create+0x32>
 95e:	89aa                	mv	s3,a0
    return x > 0 && (x & (x - 1)) == 0;
 960:	8a3a                	mv	s4,a4
 962:	00e574b3          	and	s1,a0,a4
 966:	c0b9                	beqz	s1,9ac <tournament_create+0x68>
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 968:	54fd                	li	s1,-1
 96a:	a809                	j	97c <tournament_create+0x38>
   for(int i = 1; i < processes  ; i++){
        int pid = fork() ;
        if(pid < 0)
            return -1 ;
        if(pid == 0){
            trnmnt_idx = i ;
 96c:	00000797          	auipc	a5,0x0
 970:	6897ae23          	sw	s1,1692(a5) # 1008 <trnmnt_idx>
            return trnmnt_idx ;
 974:	a021                	j	97c <tournament_create+0x38>
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 976:	54fd                	li	s1,-1
 978:	a011                	j	97c <tournament_create+0x38>
        return -1; //failed to create lock
 97a:	54fd                	li	s1,-1
        }
   }
return trnmnt_idx ;
}
 97c:	8526                	mv	a0,s1
 97e:	70a2                	ld	ra,40(sp)
 980:	7402                	ld	s0,32(sp)
 982:	64e2                	ld	s1,24(sp)
 984:	6942                	ld	s2,16(sp)
 986:	69a2                	ld	s3,8(sp)
 988:	6a02                	ld	s4,0(sp)
 98a:	6145                	addi	sp,sp,48
 98c:	8082                	ret
            return -1 ;
 98e:	54fd                	li	s1,-1
 990:	b7f5                	j	97c <tournament_create+0x38>
   num_levels = log2(processes) ;
 992:	00000797          	auipc	a5,0x0
 996:	6607af23          	sw	zero,1662(a5) # 1010 <num_levels>
   trnmnt_idx = 0;
 99a:	00000797          	auipc	a5,0x0
 99e:	6607a723          	sw	zero,1646(a5) # 1008 <trnmnt_idx>
return trnmnt_idx ;
 9a2:	00000497          	auipc	s1,0x0
 9a6:	6664a483          	lw	s1,1638(s1) # 1008 <trnmnt_idx>
 9aa:	bfc9                	j	97c <tournament_create+0x38>
   num_processes = processes ;
 9ac:	00000797          	auipc	a5,0x0
 9b0:	66a7a023          	sw	a0,1632(a5) # 100c <num_processes>
  if (n <= 1) 
 9b4:	4785                	li	a5,1
 9b6:	fca7dee3          	bge	a5,a0,992 <tournament_create+0x4e>
  int l = 0;
 9ba:	8726                	mv	a4,s1
 9bc:	87aa                	mv	a5,a0
  while (n > 1) {
 9be:	458d                	li	a1,3
    n /= 2;
 9c0:	86be                	mv	a3,a5
 9c2:	01f7d61b          	srliw	a2,a5,0x1f
 9c6:	9fb1                	addw	a5,a5,a2
 9c8:	4017d79b          	sraiw	a5,a5,0x1
    l++;
 9cc:	2705                	addiw	a4,a4,1
  while (n > 1) {
 9ce:	fed5c9e3          	blt	a1,a3,9c0 <tournament_create+0x7c>
   num_levels = log2(processes) ;
 9d2:	00000797          	auipc	a5,0x0
 9d6:	62e7af23          	sw	a4,1598(a5) # 1010 <num_levels>
   for(int i = 0; i < processes -1 ; i++){
 9da:	00000917          	auipc	s2,0x0
 9de:	65690913          	addi	s2,s2,1622 # 1030 <lock_ids>
    lock_ids[i]= peterson_create() ;
 9e2:	00000097          	auipc	ra,0x0
 9e6:	ac8080e7          	jalr	-1336(ra) # 4aa <peterson_create>
 9ea:	00a92023          	sw	a0,0(s2)
    if(lock_ids[i] <0){
 9ee:	f80546e3          	bltz	a0,97a <tournament_create+0x36>
   for(int i = 0; i < processes -1 ; i++){
 9f2:	2485                	addiw	s1,s1,1
 9f4:	0911                	addi	s2,s2,4
 9f6:	ff44c6e3          	blt	s1,s4,9e2 <tournament_create+0x9e>
   trnmnt_idx = 0;
 9fa:	00000797          	auipc	a5,0x0
 9fe:	6007a723          	sw	zero,1550(a5) # 1008 <trnmnt_idx>
   for(int i = 1; i < processes  ; i++){
 a02:	4785                	li	a5,1
 a04:	f937dfe3          	bge	a5,s3,9a2 <tournament_create+0x5e>
 a08:	4485                	li	s1,1
        int pid = fork() ;
 a0a:	00000097          	auipc	ra,0x0
 a0e:	9f8080e7          	jalr	-1544(ra) # 402 <fork>
        if(pid < 0)
 a12:	f6054ee3          	bltz	a0,98e <tournament_create+0x4a>
        if(pid == 0){
 a16:	d939                	beqz	a0,96c <tournament_create+0x28>
   for(int i = 1; i < processes  ; i++){
 a18:	2485                	addiw	s1,s1,1
 a1a:	fe9998e3          	bne	s3,s1,a0a <tournament_create+0xc6>
 a1e:	b751                	j	9a2 <tournament_create+0x5e>

0000000000000a20 <tournament_acquire>:

int tournament_acquire(void){ 

    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 a20:	00000797          	auipc	a5,0x0
 a24:	5e87a783          	lw	a5,1512(a5) # 1008 <trnmnt_idx>
 a28:	0a07cd63          	bltz	a5,ae2 <tournament_acquire+0xc2>
 a2c:	00000717          	auipc	a4,0x0
 a30:	5e472703          	lw	a4,1508(a4) # 1010 <num_levels>
 a34:	0ae05963          	blez	a4,ae6 <tournament_acquire+0xc6>

    for(int lvl = 0 ; lvl < num_levels ; lvl++){
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 a38:	fff7069b          	addiw	a3,a4,-1
 a3c:	4585                	li	a1,1
 a3e:	00d595bb          	sllw	a1,a1,a3
 a42:	8dfd                	and	a1,a1,a5
 a44:	40d5d5bb          	sraw	a1,a1,a3
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 a48:	40e7d7bb          	sraw	a5,a5,a4
        int lockidx = lockl + (1<<lvl) -1 ;
        if(lockidx>=MAX_LOCKS) return -1 ;
 a4c:	4739                	li	a4,14
 a4e:	08f74e63          	blt	a4,a5,aea <tournament_acquire+0xca>
int tournament_acquire(void){ 
 a52:	7139                	addi	sp,sp,-64
 a54:	fc06                	sd	ra,56(sp)
 a56:	f822                	sd	s0,48(sp)
 a58:	f426                	sd	s1,40(sp)
 a5a:	f04a                	sd	s2,32(sp)
 a5c:	ec4e                	sd	s3,24(sp)
 a5e:	e852                	sd	s4,16(sp)
 a60:	e456                	sd	s5,8(sp)
 a62:	e05a                	sd	s6,0(sp)
 a64:	0080                	addi	s0,sp,64
    for(int lvl = 0 ; lvl < num_levels ; lvl++){
 a66:	4481                	li	s1,0

        peterson_acquire(lock_ids[lockidx] , role) ;
 a68:	00000a17          	auipc	s4,0x0
 a6c:	5c8a0a13          	addi	s4,s4,1480 # 1030 <lock_ids>
    for(int lvl = 0 ; lvl < num_levels ; lvl++){
 a70:	00000997          	auipc	s3,0x0
 a74:	5a098993          	addi	s3,s3,1440 # 1010 <num_levels>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 a78:	00000b17          	auipc	s6,0x0
 a7c:	590b0b13          	addi	s6,s6,1424 # 1008 <trnmnt_idx>
 a80:	4905                	li	s2,1
        if(lockidx>=MAX_LOCKS) return -1 ;
 a82:	4ab9                	li	s5,14
        peterson_acquire(lock_ids[lockidx] , role) ;
 a84:	078a                	slli	a5,a5,0x2
 a86:	97d2                	add	a5,a5,s4
 a88:	4388                	lw	a0,0(a5)
 a8a:	00000097          	auipc	ra,0x0
 a8e:	a28080e7          	jalr	-1496(ra) # 4b2 <peterson_acquire>
    for(int lvl = 0 ; lvl < num_levels ; lvl++){
 a92:	0014871b          	addiw	a4,s1,1
 a96:	0007049b          	sext.w	s1,a4
 a9a:	0009a783          	lw	a5,0(s3)
 a9e:	02f4d763          	bge	s1,a5,acc <tournament_acquire+0xac>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 aa2:	40e7873b          	subw	a4,a5,a4
 aa6:	fff7079b          	addiw	a5,a4,-1
 aaa:	000b2683          	lw	a3,0(s6)
 aae:	00f915bb          	sllw	a1,s2,a5
 ab2:	8df5                	and	a1,a1,a3
 ab4:	40f5d5bb          	sraw	a1,a1,a5
        int lockidx = lockl + (1<<lvl) -1 ;
 ab8:	009917bb          	sllw	a5,s2,s1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 abc:	40e6d73b          	sraw	a4,a3,a4
        int lockidx = lockl + (1<<lvl) -1 ;
 ac0:	9fb9                	addw	a5,a5,a4
 ac2:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 ac4:	fcfad0e3          	bge	s5,a5,a84 <tournament_acquire+0x64>
 ac8:	557d                	li	a0,-1
 aca:	a011                	j	ace <tournament_acquire+0xae>

    }
return 0 ;
 acc:	4501                	li	a0,0
}
 ace:	70e2                	ld	ra,56(sp)
 ad0:	7442                	ld	s0,48(sp)
 ad2:	74a2                	ld	s1,40(sp)
 ad4:	7902                	ld	s2,32(sp)
 ad6:	69e2                	ld	s3,24(sp)
 ad8:	6a42                	ld	s4,16(sp)
 ada:	6aa2                	ld	s5,8(sp)
 adc:	6b02                	ld	s6,0(sp)
 ade:	6121                	addi	sp,sp,64
 ae0:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 ae2:	557d                	li	a0,-1
 ae4:	8082                	ret
 ae6:	557d                	li	a0,-1
 ae8:	8082                	ret
        if(lockidx>=MAX_LOCKS) return -1 ;
 aea:	557d                	li	a0,-1
}
 aec:	8082                	ret

0000000000000aee <tournament_release>:

int tournament_release(void) {

    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 aee:	00000797          	auipc	a5,0x0
 af2:	51a7a783          	lw	a5,1306(a5) # 1008 <trnmnt_idx>
 af6:	0a07cf63          	bltz	a5,bb4 <tournament_release+0xc6>
int tournament_release(void) {
 afa:	715d                	addi	sp,sp,-80
 afc:	e486                	sd	ra,72(sp)
 afe:	e0a2                	sd	s0,64(sp)
 b00:	fc26                	sd	s1,56(sp)
 b02:	f84a                	sd	s2,48(sp)
 b04:	f44e                	sd	s3,40(sp)
 b06:	f052                	sd	s4,32(sp)
 b08:	ec56                	sd	s5,24(sp)
 b0a:	e85a                	sd	s6,16(sp)
 b0c:	e45e                	sd	s7,8(sp)
 b0e:	0880                	addi	s0,sp,80
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 b10:	00000497          	auipc	s1,0x0
 b14:	5004a483          	lw	s1,1280(s1) # 1010 <num_levels>
 b18:	0a905063          	blez	s1,bb8 <tournament_release+0xca>

    for(int lvl = num_levels -1 ; lvl >=0  ; lvl--){
 b1c:	34fd                	addiw	s1,s1,-1
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 b1e:	0017f593          	andi	a1,a5,1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 b22:	4017d79b          	sraiw	a5,a5,0x1
        int lockidx = lockl + (1<<lvl) -1 ;
 b26:	4705                	li	a4,1
 b28:	0097173b          	sllw	a4,a4,s1
 b2c:	9fb9                	addw	a5,a5,a4
 b2e:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 b30:	4739                	li	a4,14
 b32:	08f74563          	blt	a4,a5,bbc <tournament_release+0xce>

        peterson_release(lock_ids[lockidx] , role) ;
 b36:	00000a17          	auipc	s4,0x0
 b3a:	4faa0a13          	addi	s4,s4,1274 # 1030 <lock_ids>
    for(int lvl = num_levels -1 ; lvl >=0  ; lvl--){
 b3e:	59fd                	li	s3,-1
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 b40:	00000b97          	auipc	s7,0x0
 b44:	4d0b8b93          	addi	s7,s7,1232 # 1010 <num_levels>
 b48:	00000b17          	auipc	s6,0x0
 b4c:	4c0b0b13          	addi	s6,s6,1216 # 1008 <trnmnt_idx>
 b50:	4905                	li	s2,1
        if(lockidx>=MAX_LOCKS) return -1 ;
 b52:	4ab9                	li	s5,14
        peterson_release(lock_ids[lockidx] , role) ;
 b54:	078a                	slli	a5,a5,0x2
 b56:	97d2                	add	a5,a5,s4
 b58:	4388                	lw	a0,0(a5)
 b5a:	00000097          	auipc	ra,0x0
 b5e:	960080e7          	jalr	-1696(ra) # 4ba <peterson_release>
    for(int lvl = num_levels -1 ; lvl >=0  ; lvl--){
 b62:	fff4869b          	addiw	a3,s1,-1
 b66:	0006849b          	sext.w	s1,a3
 b6a:	03348963          	beq	s1,s3,b9c <tournament_release+0xae>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 b6e:	000ba703          	lw	a4,0(s7)
 b72:	40d706bb          	subw	a3,a4,a3
 b76:	fff6879b          	addiw	a5,a3,-1
 b7a:	000b2703          	lw	a4,0(s6)
 b7e:	00f915bb          	sllw	a1,s2,a5
 b82:	8df9                	and	a1,a1,a4
 b84:	40f5d5bb          	sraw	a1,a1,a5
        int lockidx = lockl + (1<<lvl) -1 ;
 b88:	009917bb          	sllw	a5,s2,s1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 b8c:	40d7573b          	sraw	a4,a4,a3
        int lockidx = lockl + (1<<lvl) -1 ;
 b90:	9fb9                	addw	a5,a5,a4
 b92:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 b94:	fcfad0e3          	bge	s5,a5,b54 <tournament_release+0x66>
 b98:	557d                	li	a0,-1
 b9a:	a011                	j	b9e <tournament_release+0xb0>

    }
return 0 ;
 b9c:	4501                	li	a0,0


}
 b9e:	60a6                	ld	ra,72(sp)
 ba0:	6406                	ld	s0,64(sp)
 ba2:	74e2                	ld	s1,56(sp)
 ba4:	7942                	ld	s2,48(sp)
 ba6:	79a2                	ld	s3,40(sp)
 ba8:	7a02                	ld	s4,32(sp)
 baa:	6ae2                	ld	s5,24(sp)
 bac:	6b42                	ld	s6,16(sp)
 bae:	6ba2                	ld	s7,8(sp)
 bb0:	6161                	addi	sp,sp,80
 bb2:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 bb4:	557d                	li	a0,-1
}
 bb6:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 bb8:	557d                	li	a0,-1
 bba:	b7d5                	j	b9e <tournament_release+0xb0>
        if(lockidx>=MAX_LOCKS) return -1 ;
 bbc:	557d                	li	a0,-1
 bbe:	b7c5                	j	b9e <tournament_release+0xb0>
