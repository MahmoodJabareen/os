
user/_tournament:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user.h"



int main(int argc , char** argv){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
    if(argc !=2){
   a:	4789                	li	a5,2
   c:	02f50063          	beq	a0,a5,2c <main+0x2c>
        fprintf(2 , "invalid args\n") ;
  10:	00001597          	auipc	a1,0x1
  14:	b3058593          	addi	a1,a1,-1232 # b40 <tournament_release+0xe2>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	6ca080e7          	jalr	1738(ra) # 6e4 <fprintf>
        exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	356080e7          	jalr	854(ra) # 37a <exit>
    }

    int n= atoi(argv[1]) ;
  2c:	6588                	ld	a0,8(a1)
  2e:	00000097          	auipc	ra,0x0
  32:	250080e7          	jalr	592(ra) # 27e <atoi>

    int tournament_id = tournament_create(n) ;
  36:	00001097          	auipc	ra,0x1
  3a:	87e080e7          	jalr	-1922(ra) # 8b4 <tournament_create>
  3e:	84aa                	mv	s1,a0

    if(tournament_id < 0){
  40:	04054f63          	bltz	a0,9e <main+0x9e>
        fprintf(2 , "failed creating tournament \n");
        exit(1);
    }

    if (tournament_acquire() < 0) {
  44:	00001097          	auipc	ra,0x1
  48:	940080e7          	jalr	-1728(ra) # 984 <tournament_acquire>
  4c:	06054763          	bltz	a0,ba <main+0xba>
        fprintf(2, "failed acquiring\n");
        exit(1);
    }


    printf("Process with PID %d, Tournament ID %d has entered the critical section\n", getpid(), tournament_id);
  50:	00000097          	auipc	ra,0x0
  54:	3aa080e7          	jalr	938(ra) # 3fa <getpid>
  58:	85aa                	mv	a1,a0
  5a:	8626                	mv	a2,s1
  5c:	00001517          	auipc	a0,0x1
  60:	b2c50513          	addi	a0,a0,-1236 # b88 <tournament_release+0x12a>
  64:	00000097          	auipc	ra,0x0
  68:	6ae080e7          	jalr	1710(ra) # 712 <printf>
    // sleep(10);  // hold the lock for a while to test mutual exclusion
   
    printf("Process with PID %d, Tournament ID %d is leaving the critical section\n", getpid(), tournament_id);
  6c:	00000097          	auipc	ra,0x0
  70:	38e080e7          	jalr	910(ra) # 3fa <getpid>
  74:	85aa                	mv	a1,a0
  76:	8626                	mv	a2,s1
  78:	00001517          	auipc	a0,0x1
  7c:	b5850513          	addi	a0,a0,-1192 # bd0 <tournament_release+0x172>
  80:	00000097          	auipc	ra,0x0
  84:	692080e7          	jalr	1682(ra) # 712 <printf>

    if (tournament_release() < 0) {
  88:	00001097          	auipc	ra,0x1
  8c:	9d6080e7          	jalr	-1578(ra) # a5e <tournament_release>
  90:	04054363          	bltz	a0,d6 <main+0xd6>
        fprintf(2, "failed releasing\n");
        exit(1);
    }

    exit(0) ;
  94:	4501                	li	a0,0
  96:	00000097          	auipc	ra,0x0
  9a:	2e4080e7          	jalr	740(ra) # 37a <exit>
        fprintf(2 , "failed creating tournament \n");
  9e:	00001597          	auipc	a1,0x1
  a2:	ab258593          	addi	a1,a1,-1358 # b50 <tournament_release+0xf2>
  a6:	4509                	li	a0,2
  a8:	00000097          	auipc	ra,0x0
  ac:	63c080e7          	jalr	1596(ra) # 6e4 <fprintf>
        exit(1);
  b0:	4505                	li	a0,1
  b2:	00000097          	auipc	ra,0x0
  b6:	2c8080e7          	jalr	712(ra) # 37a <exit>
        fprintf(2, "failed acquiring\n");
  ba:	00001597          	auipc	a1,0x1
  be:	ab658593          	addi	a1,a1,-1354 # b70 <tournament_release+0x112>
  c2:	4509                	li	a0,2
  c4:	00000097          	auipc	ra,0x0
  c8:	620080e7          	jalr	1568(ra) # 6e4 <fprintf>
        exit(1);
  cc:	4505                	li	a0,1
  ce:	00000097          	auipc	ra,0x0
  d2:	2ac080e7          	jalr	684(ra) # 37a <exit>
        fprintf(2, "failed releasing\n");
  d6:	00001597          	auipc	a1,0x1
  da:	b4258593          	addi	a1,a1,-1214 # c18 <tournament_release+0x1ba>
  de:	4509                	li	a0,2
  e0:	00000097          	auipc	ra,0x0
  e4:	604080e7          	jalr	1540(ra) # 6e4 <fprintf>
        exit(1);
  e8:	4505                	li	a0,1
  ea:	00000097          	auipc	ra,0x0
  ee:	290080e7          	jalr	656(ra) # 37a <exit>

00000000000000f2 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e406                	sd	ra,8(sp)
  f6:	e022                	sd	s0,0(sp)
  f8:	0800                	addi	s0,sp,16
  extern int main();
  main();
  fa:	00000097          	auipc	ra,0x0
  fe:	f06080e7          	jalr	-250(ra) # 0 <main>
  exit(0);
 102:	4501                	li	a0,0
 104:	00000097          	auipc	ra,0x0
 108:	276080e7          	jalr	630(ra) # 37a <exit>

000000000000010c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 10c:	1141                	addi	sp,sp,-16
 10e:	e422                	sd	s0,8(sp)
 110:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 112:	87aa                	mv	a5,a0
 114:	0585                	addi	a1,a1,1
 116:	0785                	addi	a5,a5,1
 118:	fff5c703          	lbu	a4,-1(a1)
 11c:	fee78fa3          	sb	a4,-1(a5)
 120:	fb75                	bnez	a4,114 <strcpy+0x8>
    ;
  return os;
}
 122:	6422                	ld	s0,8(sp)
 124:	0141                	addi	sp,sp,16
 126:	8082                	ret

0000000000000128 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 128:	1141                	addi	sp,sp,-16
 12a:	e422                	sd	s0,8(sp)
 12c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 12e:	00054783          	lbu	a5,0(a0)
 132:	cb91                	beqz	a5,146 <strcmp+0x1e>
 134:	0005c703          	lbu	a4,0(a1)
 138:	00f71763          	bne	a4,a5,146 <strcmp+0x1e>
    p++, q++;
 13c:	0505                	addi	a0,a0,1
 13e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 140:	00054783          	lbu	a5,0(a0)
 144:	fbe5                	bnez	a5,134 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 146:	0005c503          	lbu	a0,0(a1)
}
 14a:	40a7853b          	subw	a0,a5,a0
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret

0000000000000154 <strlen>:

uint
strlen(const char *s)
{
 154:	1141                	addi	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cf91                	beqz	a5,17a <strlen+0x26>
 160:	0505                	addi	a0,a0,1
 162:	87aa                	mv	a5,a0
 164:	4685                	li	a3,1
 166:	9e89                	subw	a3,a3,a0
 168:	00f6853b          	addw	a0,a3,a5
 16c:	0785                	addi	a5,a5,1
 16e:	fff7c703          	lbu	a4,-1(a5)
 172:	fb7d                	bnez	a4,168 <strlen+0x14>
    ;
  return n;
}
 174:	6422                	ld	s0,8(sp)
 176:	0141                	addi	sp,sp,16
 178:	8082                	ret
  for(n = 0; s[n]; n++)
 17a:	4501                	li	a0,0
 17c:	bfe5                	j	174 <strlen+0x20>

000000000000017e <memset>:

void*
memset(void *dst, int c, uint n)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e422                	sd	s0,8(sp)
 182:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 184:	ca19                	beqz	a2,19a <memset+0x1c>
 186:	87aa                	mv	a5,a0
 188:	1602                	slli	a2,a2,0x20
 18a:	9201                	srli	a2,a2,0x20
 18c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 190:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 194:	0785                	addi	a5,a5,1
 196:	fee79de3          	bne	a5,a4,190 <memset+0x12>
  }
  return dst;
}
 19a:	6422                	ld	s0,8(sp)
 19c:	0141                	addi	sp,sp,16
 19e:	8082                	ret

00000000000001a0 <strchr>:

char*
strchr(const char *s, char c)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	cb99                	beqz	a5,1c0 <strchr+0x20>
    if(*s == c)
 1ac:	00f58763          	beq	a1,a5,1ba <strchr+0x1a>
  for(; *s; s++)
 1b0:	0505                	addi	a0,a0,1
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	fbfd                	bnez	a5,1ac <strchr+0xc>
      return (char*)s;
  return 0;
 1b8:	4501                	li	a0,0
}
 1ba:	6422                	ld	s0,8(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret
  return 0;
 1c0:	4501                	li	a0,0
 1c2:	bfe5                	j	1ba <strchr+0x1a>

00000000000001c4 <gets>:

char*
gets(char *buf, int max)
{
 1c4:	711d                	addi	sp,sp,-96
 1c6:	ec86                	sd	ra,88(sp)
 1c8:	e8a2                	sd	s0,80(sp)
 1ca:	e4a6                	sd	s1,72(sp)
 1cc:	e0ca                	sd	s2,64(sp)
 1ce:	fc4e                	sd	s3,56(sp)
 1d0:	f852                	sd	s4,48(sp)
 1d2:	f456                	sd	s5,40(sp)
 1d4:	f05a                	sd	s6,32(sp)
 1d6:	ec5e                	sd	s7,24(sp)
 1d8:	1080                	addi	s0,sp,96
 1da:	8baa                	mv	s7,a0
 1dc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1de:	892a                	mv	s2,a0
 1e0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e2:	4aa9                	li	s5,10
 1e4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1e6:	89a6                	mv	s3,s1
 1e8:	2485                	addiw	s1,s1,1
 1ea:	0344d863          	bge	s1,s4,21a <gets+0x56>
    cc = read(0, &c, 1);
 1ee:	4605                	li	a2,1
 1f0:	faf40593          	addi	a1,s0,-81
 1f4:	4501                	li	a0,0
 1f6:	00000097          	auipc	ra,0x0
 1fa:	19c080e7          	jalr	412(ra) # 392 <read>
    if(cc < 1)
 1fe:	00a05e63          	blez	a0,21a <gets+0x56>
    buf[i++] = c;
 202:	faf44783          	lbu	a5,-81(s0)
 206:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 20a:	01578763          	beq	a5,s5,218 <gets+0x54>
 20e:	0905                	addi	s2,s2,1
 210:	fd679be3          	bne	a5,s6,1e6 <gets+0x22>
  for(i=0; i+1 < max; ){
 214:	89a6                	mv	s3,s1
 216:	a011                	j	21a <gets+0x56>
 218:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 21a:	99de                	add	s3,s3,s7
 21c:	00098023          	sb	zero,0(s3)
  return buf;
}
 220:	855e                	mv	a0,s7
 222:	60e6                	ld	ra,88(sp)
 224:	6446                	ld	s0,80(sp)
 226:	64a6                	ld	s1,72(sp)
 228:	6906                	ld	s2,64(sp)
 22a:	79e2                	ld	s3,56(sp)
 22c:	7a42                	ld	s4,48(sp)
 22e:	7aa2                	ld	s5,40(sp)
 230:	7b02                	ld	s6,32(sp)
 232:	6be2                	ld	s7,24(sp)
 234:	6125                	addi	sp,sp,96
 236:	8082                	ret

0000000000000238 <stat>:

int
stat(const char *n, struct stat *st)
{
 238:	1101                	addi	sp,sp,-32
 23a:	ec06                	sd	ra,24(sp)
 23c:	e822                	sd	s0,16(sp)
 23e:	e426                	sd	s1,8(sp)
 240:	e04a                	sd	s2,0(sp)
 242:	1000                	addi	s0,sp,32
 244:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 246:	4581                	li	a1,0
 248:	00000097          	auipc	ra,0x0
 24c:	172080e7          	jalr	370(ra) # 3ba <open>
  if(fd < 0)
 250:	02054563          	bltz	a0,27a <stat+0x42>
 254:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 256:	85ca                	mv	a1,s2
 258:	00000097          	auipc	ra,0x0
 25c:	17a080e7          	jalr	378(ra) # 3d2 <fstat>
 260:	892a                	mv	s2,a0
  close(fd);
 262:	8526                	mv	a0,s1
 264:	00000097          	auipc	ra,0x0
 268:	13e080e7          	jalr	318(ra) # 3a2 <close>
  return r;
}
 26c:	854a                	mv	a0,s2
 26e:	60e2                	ld	ra,24(sp)
 270:	6442                	ld	s0,16(sp)
 272:	64a2                	ld	s1,8(sp)
 274:	6902                	ld	s2,0(sp)
 276:	6105                	addi	sp,sp,32
 278:	8082                	ret
    return -1;
 27a:	597d                	li	s2,-1
 27c:	bfc5                	j	26c <stat+0x34>

000000000000027e <atoi>:

int
atoi(const char *s)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e422                	sd	s0,8(sp)
 282:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 284:	00054603          	lbu	a2,0(a0)
 288:	fd06079b          	addiw	a5,a2,-48
 28c:	0ff7f793          	andi	a5,a5,255
 290:	4725                	li	a4,9
 292:	02f76963          	bltu	a4,a5,2c4 <atoi+0x46>
 296:	86aa                	mv	a3,a0
  n = 0;
 298:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 29a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 29c:	0685                	addi	a3,a3,1
 29e:	0025179b          	slliw	a5,a0,0x2
 2a2:	9fa9                	addw	a5,a5,a0
 2a4:	0017979b          	slliw	a5,a5,0x1
 2a8:	9fb1                	addw	a5,a5,a2
 2aa:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ae:	0006c603          	lbu	a2,0(a3)
 2b2:	fd06071b          	addiw	a4,a2,-48
 2b6:	0ff77713          	andi	a4,a4,255
 2ba:	fee5f1e3          	bgeu	a1,a4,29c <atoi+0x1e>
  return n;
}
 2be:	6422                	ld	s0,8(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret
  n = 0;
 2c4:	4501                	li	a0,0
 2c6:	bfe5                	j	2be <atoi+0x40>

00000000000002c8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e422                	sd	s0,8(sp)
 2cc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2ce:	02b57463          	bgeu	a0,a1,2f6 <memmove+0x2e>
    while(n-- > 0)
 2d2:	00c05f63          	blez	a2,2f0 <memmove+0x28>
 2d6:	1602                	slli	a2,a2,0x20
 2d8:	9201                	srli	a2,a2,0x20
 2da:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2de:	872a                	mv	a4,a0
      *dst++ = *src++;
 2e0:	0585                	addi	a1,a1,1
 2e2:	0705                	addi	a4,a4,1
 2e4:	fff5c683          	lbu	a3,-1(a1)
 2e8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ec:	fee79ae3          	bne	a5,a4,2e0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2f0:	6422                	ld	s0,8(sp)
 2f2:	0141                	addi	sp,sp,16
 2f4:	8082                	ret
    dst += n;
 2f6:	00c50733          	add	a4,a0,a2
    src += n;
 2fa:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2fc:	fec05ae3          	blez	a2,2f0 <memmove+0x28>
 300:	fff6079b          	addiw	a5,a2,-1
 304:	1782                	slli	a5,a5,0x20
 306:	9381                	srli	a5,a5,0x20
 308:	fff7c793          	not	a5,a5
 30c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 30e:	15fd                	addi	a1,a1,-1
 310:	177d                	addi	a4,a4,-1
 312:	0005c683          	lbu	a3,0(a1)
 316:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 31a:	fee79ae3          	bne	a5,a4,30e <memmove+0x46>
 31e:	bfc9                	j	2f0 <memmove+0x28>

0000000000000320 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 320:	1141                	addi	sp,sp,-16
 322:	e422                	sd	s0,8(sp)
 324:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 326:	ca05                	beqz	a2,356 <memcmp+0x36>
 328:	fff6069b          	addiw	a3,a2,-1
 32c:	1682                	slli	a3,a3,0x20
 32e:	9281                	srli	a3,a3,0x20
 330:	0685                	addi	a3,a3,1
 332:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 334:	00054783          	lbu	a5,0(a0)
 338:	0005c703          	lbu	a4,0(a1)
 33c:	00e79863          	bne	a5,a4,34c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 340:	0505                	addi	a0,a0,1
    p2++;
 342:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 344:	fed518e3          	bne	a0,a3,334 <memcmp+0x14>
  }
  return 0;
 348:	4501                	li	a0,0
 34a:	a019                	j	350 <memcmp+0x30>
      return *p1 - *p2;
 34c:	40e7853b          	subw	a0,a5,a4
}
 350:	6422                	ld	s0,8(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret
  return 0;
 356:	4501                	li	a0,0
 358:	bfe5                	j	350 <memcmp+0x30>

000000000000035a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 35a:	1141                	addi	sp,sp,-16
 35c:	e406                	sd	ra,8(sp)
 35e:	e022                	sd	s0,0(sp)
 360:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 362:	00000097          	auipc	ra,0x0
 366:	f66080e7          	jalr	-154(ra) # 2c8 <memmove>
}
 36a:	60a2                	ld	ra,8(sp)
 36c:	6402                	ld	s0,0(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret

0000000000000372 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 372:	4885                	li	a7,1
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <exit>:
.global exit
exit:
 li a7, SYS_exit
 37a:	4889                	li	a7,2
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <wait>:
.global wait
wait:
 li a7, SYS_wait
 382:	488d                	li	a7,3
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 38a:	4891                	li	a7,4
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <read>:
.global read
read:
 li a7, SYS_read
 392:	4895                	li	a7,5
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <write>:
.global write
write:
 li a7, SYS_write
 39a:	48c1                	li	a7,16
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <close>:
.global close
close:
 li a7, SYS_close
 3a2:	48d5                	li	a7,21
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <kill>:
.global kill
kill:
 li a7, SYS_kill
 3aa:	4899                	li	a7,6
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3b2:	489d                	li	a7,7
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <open>:
.global open
open:
 li a7, SYS_open
 3ba:	48bd                	li	a7,15
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3c2:	48c5                	li	a7,17
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ca:	48c9                	li	a7,18
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3d2:	48a1                	li	a7,8
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <link>:
.global link
link:
 li a7, SYS_link
 3da:	48cd                	li	a7,19
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3e2:	48d1                	li	a7,20
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ea:	48a5                	li	a7,9
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3f2:	48a9                	li	a7,10
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3fa:	48ad                	li	a7,11
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 402:	48b1                	li	a7,12
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 40a:	48b5                	li	a7,13
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 412:	48b9                	li	a7,14
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <peterson_create>:
.global peterson_create
peterson_create:
 li a7, SYS_peterson_create
 41a:	48d9                	li	a7,22
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <peterson_acquire>:
.global peterson_acquire
peterson_acquire:
 li a7, SYS_peterson_acquire
 422:	48dd                	li	a7,23
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <peterson_release>:
.global peterson_release
peterson_release:
 li a7, SYS_peterson_release
 42a:	48e1                	li	a7,24
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <peterson_destroy>:
.global peterson_destroy
peterson_destroy:
 li a7, SYS_peterson_destroy
 432:	48e5                	li	a7,25
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 43a:	1101                	addi	sp,sp,-32
 43c:	ec06                	sd	ra,24(sp)
 43e:	e822                	sd	s0,16(sp)
 440:	1000                	addi	s0,sp,32
 442:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 446:	4605                	li	a2,1
 448:	fef40593          	addi	a1,s0,-17
 44c:	00000097          	auipc	ra,0x0
 450:	f4e080e7          	jalr	-178(ra) # 39a <write>
}
 454:	60e2                	ld	ra,24(sp)
 456:	6442                	ld	s0,16(sp)
 458:	6105                	addi	sp,sp,32
 45a:	8082                	ret

000000000000045c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 45c:	7139                	addi	sp,sp,-64
 45e:	fc06                	sd	ra,56(sp)
 460:	f822                	sd	s0,48(sp)
 462:	f426                	sd	s1,40(sp)
 464:	f04a                	sd	s2,32(sp)
 466:	ec4e                	sd	s3,24(sp)
 468:	0080                	addi	s0,sp,64
 46a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 46c:	c299                	beqz	a3,472 <printint+0x16>
 46e:	0805c863          	bltz	a1,4fe <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 472:	2581                	sext.w	a1,a1
  neg = 0;
 474:	4881                	li	a7,0
 476:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 47a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 47c:	2601                	sext.w	a2,a2
 47e:	00000517          	auipc	a0,0x0
 482:	7ba50513          	addi	a0,a0,1978 # c38 <digits>
 486:	883a                	mv	a6,a4
 488:	2705                	addiw	a4,a4,1
 48a:	02c5f7bb          	remuw	a5,a1,a2
 48e:	1782                	slli	a5,a5,0x20
 490:	9381                	srli	a5,a5,0x20
 492:	97aa                	add	a5,a5,a0
 494:	0007c783          	lbu	a5,0(a5)
 498:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 49c:	0005879b          	sext.w	a5,a1
 4a0:	02c5d5bb          	divuw	a1,a1,a2
 4a4:	0685                	addi	a3,a3,1
 4a6:	fec7f0e3          	bgeu	a5,a2,486 <printint+0x2a>
  if(neg)
 4aa:	00088b63          	beqz	a7,4c0 <printint+0x64>
    buf[i++] = '-';
 4ae:	fd040793          	addi	a5,s0,-48
 4b2:	973e                	add	a4,a4,a5
 4b4:	02d00793          	li	a5,45
 4b8:	fef70823          	sb	a5,-16(a4)
 4bc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4c0:	02e05863          	blez	a4,4f0 <printint+0x94>
 4c4:	fc040793          	addi	a5,s0,-64
 4c8:	00e78933          	add	s2,a5,a4
 4cc:	fff78993          	addi	s3,a5,-1
 4d0:	99ba                	add	s3,s3,a4
 4d2:	377d                	addiw	a4,a4,-1
 4d4:	1702                	slli	a4,a4,0x20
 4d6:	9301                	srli	a4,a4,0x20
 4d8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4dc:	fff94583          	lbu	a1,-1(s2)
 4e0:	8526                	mv	a0,s1
 4e2:	00000097          	auipc	ra,0x0
 4e6:	f58080e7          	jalr	-168(ra) # 43a <putc>
  while(--i >= 0)
 4ea:	197d                	addi	s2,s2,-1
 4ec:	ff3918e3          	bne	s2,s3,4dc <printint+0x80>
}
 4f0:	70e2                	ld	ra,56(sp)
 4f2:	7442                	ld	s0,48(sp)
 4f4:	74a2                	ld	s1,40(sp)
 4f6:	7902                	ld	s2,32(sp)
 4f8:	69e2                	ld	s3,24(sp)
 4fa:	6121                	addi	sp,sp,64
 4fc:	8082                	ret
    x = -xx;
 4fe:	40b005bb          	negw	a1,a1
    neg = 1;
 502:	4885                	li	a7,1
    x = -xx;
 504:	bf8d                	j	476 <printint+0x1a>

0000000000000506 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 506:	7119                	addi	sp,sp,-128
 508:	fc86                	sd	ra,120(sp)
 50a:	f8a2                	sd	s0,112(sp)
 50c:	f4a6                	sd	s1,104(sp)
 50e:	f0ca                	sd	s2,96(sp)
 510:	ecce                	sd	s3,88(sp)
 512:	e8d2                	sd	s4,80(sp)
 514:	e4d6                	sd	s5,72(sp)
 516:	e0da                	sd	s6,64(sp)
 518:	fc5e                	sd	s7,56(sp)
 51a:	f862                	sd	s8,48(sp)
 51c:	f466                	sd	s9,40(sp)
 51e:	f06a                	sd	s10,32(sp)
 520:	ec6e                	sd	s11,24(sp)
 522:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 524:	0005c903          	lbu	s2,0(a1)
 528:	18090f63          	beqz	s2,6c6 <vprintf+0x1c0>
 52c:	8aaa                	mv	s5,a0
 52e:	8b32                	mv	s6,a2
 530:	00158493          	addi	s1,a1,1
  state = 0;
 534:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 536:	02500a13          	li	s4,37
      if(c == 'd'){
 53a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 53e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 542:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 546:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 54a:	00000b97          	auipc	s7,0x0
 54e:	6eeb8b93          	addi	s7,s7,1774 # c38 <digits>
 552:	a839                	j	570 <vprintf+0x6a>
        putc(fd, c);
 554:	85ca                	mv	a1,s2
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	ee2080e7          	jalr	-286(ra) # 43a <putc>
 560:	a019                	j	566 <vprintf+0x60>
    } else if(state == '%'){
 562:	01498f63          	beq	s3,s4,580 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 566:	0485                	addi	s1,s1,1
 568:	fff4c903          	lbu	s2,-1(s1)
 56c:	14090d63          	beqz	s2,6c6 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 570:	0009079b          	sext.w	a5,s2
    if(state == 0){
 574:	fe0997e3          	bnez	s3,562 <vprintf+0x5c>
      if(c == '%'){
 578:	fd479ee3          	bne	a5,s4,554 <vprintf+0x4e>
        state = '%';
 57c:	89be                	mv	s3,a5
 57e:	b7e5                	j	566 <vprintf+0x60>
      if(c == 'd'){
 580:	05878063          	beq	a5,s8,5c0 <vprintf+0xba>
      } else if(c == 'l') {
 584:	05978c63          	beq	a5,s9,5dc <vprintf+0xd6>
      } else if(c == 'x') {
 588:	07a78863          	beq	a5,s10,5f8 <vprintf+0xf2>
      } else if(c == 'p') {
 58c:	09b78463          	beq	a5,s11,614 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 590:	07300713          	li	a4,115
 594:	0ce78663          	beq	a5,a4,660 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 598:	06300713          	li	a4,99
 59c:	0ee78e63          	beq	a5,a4,698 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5a0:	11478863          	beq	a5,s4,6b0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5a4:	85d2                	mv	a1,s4
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	e92080e7          	jalr	-366(ra) # 43a <putc>
        putc(fd, c);
 5b0:	85ca                	mv	a1,s2
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	e86080e7          	jalr	-378(ra) # 43a <putc>
      }
      state = 0;
 5bc:	4981                	li	s3,0
 5be:	b765                	j	566 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5c0:	008b0913          	addi	s2,s6,8
 5c4:	4685                	li	a3,1
 5c6:	4629                	li	a2,10
 5c8:	000b2583          	lw	a1,0(s6)
 5cc:	8556                	mv	a0,s5
 5ce:	00000097          	auipc	ra,0x0
 5d2:	e8e080e7          	jalr	-370(ra) # 45c <printint>
 5d6:	8b4a                	mv	s6,s2
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	b771                	j	566 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5dc:	008b0913          	addi	s2,s6,8
 5e0:	4681                	li	a3,0
 5e2:	4629                	li	a2,10
 5e4:	000b2583          	lw	a1,0(s6)
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	e72080e7          	jalr	-398(ra) # 45c <printint>
 5f2:	8b4a                	mv	s6,s2
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	bf85                	j	566 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5f8:	008b0913          	addi	s2,s6,8
 5fc:	4681                	li	a3,0
 5fe:	4641                	li	a2,16
 600:	000b2583          	lw	a1,0(s6)
 604:	8556                	mv	a0,s5
 606:	00000097          	auipc	ra,0x0
 60a:	e56080e7          	jalr	-426(ra) # 45c <printint>
 60e:	8b4a                	mv	s6,s2
      state = 0;
 610:	4981                	li	s3,0
 612:	bf91                	j	566 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 614:	008b0793          	addi	a5,s6,8
 618:	f8f43423          	sd	a5,-120(s0)
 61c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 620:	03000593          	li	a1,48
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	e14080e7          	jalr	-492(ra) # 43a <putc>
  putc(fd, 'x');
 62e:	85ea                	mv	a1,s10
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	e08080e7          	jalr	-504(ra) # 43a <putc>
 63a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 63c:	03c9d793          	srli	a5,s3,0x3c
 640:	97de                	add	a5,a5,s7
 642:	0007c583          	lbu	a1,0(a5)
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	df2080e7          	jalr	-526(ra) # 43a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 650:	0992                	slli	s3,s3,0x4
 652:	397d                	addiw	s2,s2,-1
 654:	fe0914e3          	bnez	s2,63c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 658:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 65c:	4981                	li	s3,0
 65e:	b721                	j	566 <vprintf+0x60>
        s = va_arg(ap, char*);
 660:	008b0993          	addi	s3,s6,8
 664:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 668:	02090163          	beqz	s2,68a <vprintf+0x184>
        while(*s != 0){
 66c:	00094583          	lbu	a1,0(s2)
 670:	c9a1                	beqz	a1,6c0 <vprintf+0x1ba>
          putc(fd, *s);
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	dc6080e7          	jalr	-570(ra) # 43a <putc>
          s++;
 67c:	0905                	addi	s2,s2,1
        while(*s != 0){
 67e:	00094583          	lbu	a1,0(s2)
 682:	f9e5                	bnez	a1,672 <vprintf+0x16c>
        s = va_arg(ap, char*);
 684:	8b4e                	mv	s6,s3
      state = 0;
 686:	4981                	li	s3,0
 688:	bdf9                	j	566 <vprintf+0x60>
          s = "(null)";
 68a:	00000917          	auipc	s2,0x0
 68e:	5a690913          	addi	s2,s2,1446 # c30 <tournament_release+0x1d2>
        while(*s != 0){
 692:	02800593          	li	a1,40
 696:	bff1                	j	672 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 698:	008b0913          	addi	s2,s6,8
 69c:	000b4583          	lbu	a1,0(s6)
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	d98080e7          	jalr	-616(ra) # 43a <putc>
 6aa:	8b4a                	mv	s6,s2
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	bd65                	j	566 <vprintf+0x60>
        putc(fd, c);
 6b0:	85d2                	mv	a1,s4
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	d86080e7          	jalr	-634(ra) # 43a <putc>
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	b565                	j	566 <vprintf+0x60>
        s = va_arg(ap, char*);
 6c0:	8b4e                	mv	s6,s3
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	b54d                	j	566 <vprintf+0x60>
    }
  }
}
 6c6:	70e6                	ld	ra,120(sp)
 6c8:	7446                	ld	s0,112(sp)
 6ca:	74a6                	ld	s1,104(sp)
 6cc:	7906                	ld	s2,96(sp)
 6ce:	69e6                	ld	s3,88(sp)
 6d0:	6a46                	ld	s4,80(sp)
 6d2:	6aa6                	ld	s5,72(sp)
 6d4:	6b06                	ld	s6,64(sp)
 6d6:	7be2                	ld	s7,56(sp)
 6d8:	7c42                	ld	s8,48(sp)
 6da:	7ca2                	ld	s9,40(sp)
 6dc:	7d02                	ld	s10,32(sp)
 6de:	6de2                	ld	s11,24(sp)
 6e0:	6109                	addi	sp,sp,128
 6e2:	8082                	ret

00000000000006e4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e4:	715d                	addi	sp,sp,-80
 6e6:	ec06                	sd	ra,24(sp)
 6e8:	e822                	sd	s0,16(sp)
 6ea:	1000                	addi	s0,sp,32
 6ec:	e010                	sd	a2,0(s0)
 6ee:	e414                	sd	a3,8(s0)
 6f0:	e818                	sd	a4,16(s0)
 6f2:	ec1c                	sd	a5,24(s0)
 6f4:	03043023          	sd	a6,32(s0)
 6f8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6fc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 700:	8622                	mv	a2,s0
 702:	00000097          	auipc	ra,0x0
 706:	e04080e7          	jalr	-508(ra) # 506 <vprintf>
}
 70a:	60e2                	ld	ra,24(sp)
 70c:	6442                	ld	s0,16(sp)
 70e:	6161                	addi	sp,sp,80
 710:	8082                	ret

0000000000000712 <printf>:

void
printf(const char *fmt, ...)
{
 712:	711d                	addi	sp,sp,-96
 714:	ec06                	sd	ra,24(sp)
 716:	e822                	sd	s0,16(sp)
 718:	1000                	addi	s0,sp,32
 71a:	e40c                	sd	a1,8(s0)
 71c:	e810                	sd	a2,16(s0)
 71e:	ec14                	sd	a3,24(s0)
 720:	f018                	sd	a4,32(s0)
 722:	f41c                	sd	a5,40(s0)
 724:	03043823          	sd	a6,48(s0)
 728:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 72c:	00840613          	addi	a2,s0,8
 730:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 734:	85aa                	mv	a1,a0
 736:	4505                	li	a0,1
 738:	00000097          	auipc	ra,0x0
 73c:	dce080e7          	jalr	-562(ra) # 506 <vprintf>
}
 740:	60e2                	ld	ra,24(sp)
 742:	6442                	ld	s0,16(sp)
 744:	6125                	addi	sp,sp,96
 746:	8082                	ret

0000000000000748 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 748:	1141                	addi	sp,sp,-16
 74a:	e422                	sd	s0,8(sp)
 74c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 74e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 752:	00001797          	auipc	a5,0x1
 756:	8ae7b783          	ld	a5,-1874(a5) # 1000 <freep>
 75a:	a805                	j	78a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 75c:	4618                	lw	a4,8(a2)
 75e:	9db9                	addw	a1,a1,a4
 760:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 764:	6398                	ld	a4,0(a5)
 766:	6318                	ld	a4,0(a4)
 768:	fee53823          	sd	a4,-16(a0)
 76c:	a091                	j	7b0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 76e:	ff852703          	lw	a4,-8(a0)
 772:	9e39                	addw	a2,a2,a4
 774:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 776:	ff053703          	ld	a4,-16(a0)
 77a:	e398                	sd	a4,0(a5)
 77c:	a099                	j	7c2 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77e:	6398                	ld	a4,0(a5)
 780:	00e7e463          	bltu	a5,a4,788 <free+0x40>
 784:	00e6ea63          	bltu	a3,a4,798 <free+0x50>
{
 788:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78a:	fed7fae3          	bgeu	a5,a3,77e <free+0x36>
 78e:	6398                	ld	a4,0(a5)
 790:	00e6e463          	bltu	a3,a4,798 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 794:	fee7eae3          	bltu	a5,a4,788 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 798:	ff852583          	lw	a1,-8(a0)
 79c:	6390                	ld	a2,0(a5)
 79e:	02059713          	slli	a4,a1,0x20
 7a2:	9301                	srli	a4,a4,0x20
 7a4:	0712                	slli	a4,a4,0x4
 7a6:	9736                	add	a4,a4,a3
 7a8:	fae60ae3          	beq	a2,a4,75c <free+0x14>
    bp->s.ptr = p->s.ptr;
 7ac:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7b0:	4790                	lw	a2,8(a5)
 7b2:	02061713          	slli	a4,a2,0x20
 7b6:	9301                	srli	a4,a4,0x20
 7b8:	0712                	slli	a4,a4,0x4
 7ba:	973e                	add	a4,a4,a5
 7bc:	fae689e3          	beq	a3,a4,76e <free+0x26>
  } else
    p->s.ptr = bp;
 7c0:	e394                	sd	a3,0(a5)
  freep = p;
 7c2:	00001717          	auipc	a4,0x1
 7c6:	82f73f23          	sd	a5,-1986(a4) # 1000 <freep>
}
 7ca:	6422                	ld	s0,8(sp)
 7cc:	0141                	addi	sp,sp,16
 7ce:	8082                	ret

00000000000007d0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7d0:	7139                	addi	sp,sp,-64
 7d2:	fc06                	sd	ra,56(sp)
 7d4:	f822                	sd	s0,48(sp)
 7d6:	f426                	sd	s1,40(sp)
 7d8:	f04a                	sd	s2,32(sp)
 7da:	ec4e                	sd	s3,24(sp)
 7dc:	e852                	sd	s4,16(sp)
 7de:	e456                	sd	s5,8(sp)
 7e0:	e05a                	sd	s6,0(sp)
 7e2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e4:	02051493          	slli	s1,a0,0x20
 7e8:	9081                	srli	s1,s1,0x20
 7ea:	04bd                	addi	s1,s1,15
 7ec:	8091                	srli	s1,s1,0x4
 7ee:	0014899b          	addiw	s3,s1,1
 7f2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7f4:	00001517          	auipc	a0,0x1
 7f8:	80c53503          	ld	a0,-2036(a0) # 1000 <freep>
 7fc:	c515                	beqz	a0,828 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 800:	4798                	lw	a4,8(a5)
 802:	02977f63          	bgeu	a4,s1,840 <malloc+0x70>
 806:	8a4e                	mv	s4,s3
 808:	0009871b          	sext.w	a4,s3
 80c:	6685                	lui	a3,0x1
 80e:	00d77363          	bgeu	a4,a3,814 <malloc+0x44>
 812:	6a05                	lui	s4,0x1
 814:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 818:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 81c:	00000917          	auipc	s2,0x0
 820:	7e490913          	addi	s2,s2,2020 # 1000 <freep>
  if(p == (char*)-1)
 824:	5afd                	li	s5,-1
 826:	a88d                	j	898 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 828:	00000797          	auipc	a5,0x0
 82c:	7e878793          	addi	a5,a5,2024 # 1010 <base>
 830:	00000717          	auipc	a4,0x0
 834:	7cf73823          	sd	a5,2000(a4) # 1000 <freep>
 838:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 83a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 83e:	b7e1                	j	806 <malloc+0x36>
      if(p->s.size == nunits)
 840:	02e48b63          	beq	s1,a4,876 <malloc+0xa6>
        p->s.size -= nunits;
 844:	4137073b          	subw	a4,a4,s3
 848:	c798                	sw	a4,8(a5)
        p += p->s.size;
 84a:	1702                	slli	a4,a4,0x20
 84c:	9301                	srli	a4,a4,0x20
 84e:	0712                	slli	a4,a4,0x4
 850:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 852:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 856:	00000717          	auipc	a4,0x0
 85a:	7aa73523          	sd	a0,1962(a4) # 1000 <freep>
      return (void*)(p + 1);
 85e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 862:	70e2                	ld	ra,56(sp)
 864:	7442                	ld	s0,48(sp)
 866:	74a2                	ld	s1,40(sp)
 868:	7902                	ld	s2,32(sp)
 86a:	69e2                	ld	s3,24(sp)
 86c:	6a42                	ld	s4,16(sp)
 86e:	6aa2                	ld	s5,8(sp)
 870:	6b02                	ld	s6,0(sp)
 872:	6121                	addi	sp,sp,64
 874:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 876:	6398                	ld	a4,0(a5)
 878:	e118                	sd	a4,0(a0)
 87a:	bff1                	j	856 <malloc+0x86>
  hp->s.size = nu;
 87c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 880:	0541                	addi	a0,a0,16
 882:	00000097          	auipc	ra,0x0
 886:	ec6080e7          	jalr	-314(ra) # 748 <free>
  return freep;
 88a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 88e:	d971                	beqz	a0,862 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 890:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 892:	4798                	lw	a4,8(a5)
 894:	fa9776e3          	bgeu	a4,s1,840 <malloc+0x70>
    if(p == freep)
 898:	00093703          	ld	a4,0(s2)
 89c:	853e                	mv	a0,a5
 89e:	fef719e3          	bne	a4,a5,890 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8a2:	8552                	mv	a0,s4
 8a4:	00000097          	auipc	ra,0x0
 8a8:	b5e080e7          	jalr	-1186(ra) # 402 <sbrk>
  if(p == (char*)-1)
 8ac:	fd5518e3          	bne	a0,s5,87c <malloc+0xac>
        return 0;
 8b0:	4501                	li	a0,0
 8b2:	bf45                	j	862 <malloc+0x92>

00000000000008b4 <tournament_create>:
  }
  return l;
}

int tournament_create(int processes) {
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 8b4:	fff5071b          	addiw	a4,a0,-1
 8b8:	47bd                	li	a5,15
 8ba:	08e7eb63          	bltu	a5,a4,950 <tournament_create+0x9c>
int tournament_create(int processes) {
 8be:	7179                	addi	sp,sp,-48
 8c0:	f406                	sd	ra,40(sp)
 8c2:	f022                	sd	s0,32(sp)
 8c4:	ec26                	sd	s1,24(sp)
 8c6:	e84a                	sd	s2,16(sp)
 8c8:	e44e                	sd	s3,8(sp)
 8ca:	e052                	sd	s4,0(sp)
 8cc:	1800                	addi	s0,sp,48
 8ce:	89aa                	mv	s3,a0
    return x > 0 && (x & (x - 1)) == 0;
 8d0:	8a3a                	mv	s4,a4
 8d2:	00e574b3          	and	s1,a0,a4
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 8d6:	557d                	li	a0,-1
    return x > 0 && (x & (x - 1)) == 0;
 8d8:	ecbd                	bnez	s1,956 <tournament_create+0xa2>
  if (n <= 1) 
 8da:	4785                	li	a5,1
 8dc:	0937d763          	bge	a5,s3,96a <tournament_create+0xb6>
  int l = 0;
 8e0:	8726                	mv	a4,s1
 8e2:	87ce                	mv	a5,s3
  while (n > 1) {
 8e4:	458d                	li	a1,3
    n /= 2;
 8e6:	86be                	mv	a3,a5
 8e8:	01f7d61b          	srliw	a2,a5,0x1f
 8ec:	9fb1                	addw	a5,a5,a2
 8ee:	4017d79b          	sraiw	a5,a5,0x1
    l++;
 8f2:	2705                	addiw	a4,a4,1
  while (n > 1) {
 8f4:	fed5c9e3          	blt	a1,a3,8e6 <tournament_create+0x32>

   num_processes = processes ;
   num_levels = log2(processes) ;
 8f8:	00000797          	auipc	a5,0x0
 8fc:	70e7aa23          	sw	a4,1812(a5) # 100c <num_levels>

   for(int i = 0; i < (processes -1) ; i++){
 900:	00000917          	auipc	s2,0x0
 904:	72090913          	addi	s2,s2,1824 # 1020 <lock_ids>
    lock_ids[i]= peterson_create() ;
 908:	00000097          	auipc	ra,0x0
 90c:	b12080e7          	jalr	-1262(ra) # 41a <peterson_create>
 910:	00a92023          	sw	a0,0(s2)
    if(lock_ids[i] <0){
 914:	04054063          	bltz	a0,954 <tournament_create+0xa0>
   for(int i = 0; i < (processes -1) ; i++){
 918:	2485                	addiw	s1,s1,1
 91a:	0911                	addi	s2,s2,4
 91c:	ff44c6e3          	blt	s1,s4,908 <tournament_create+0x54>
        return -1; //failed to create lock
    }
   }

   trnmnt_idx = 0;
 920:	00000797          	auipc	a5,0x0
 924:	6e07a423          	sw	zero,1768(a5) # 1008 <trnmnt_idx>
   for(int i = 1; i < processes  ; i++){
 928:	4785                	li	a5,1
 92a:	0537d863          	bge	a5,s3,97a <tournament_create+0xc6>
 92e:	4485                	li	s1,1
        int pid = fork() ;
 930:	00000097          	auipc	ra,0x0
 934:	a42080e7          	jalr	-1470(ra) # 372 <fork>
        if(pid < 0)
 938:	02054763          	bltz	a0,966 <tournament_create+0xb2>
            return -1 ;
        if(pid == 0){
 93c:	c509                	beqz	a0,946 <tournament_create+0x92>
   for(int i = 1; i < processes  ; i++){
 93e:	2485                	addiw	s1,s1,1
 940:	fe9998e3          	bne	s3,s1,930 <tournament_create+0x7c>
 944:	a81d                	j	97a <tournament_create+0xc6>
            trnmnt_idx = i ;
 946:	00000797          	auipc	a5,0x0
 94a:	6c97a123          	sw	s1,1730(a5) # 1008 <trnmnt_idx>
            break ;
 94e:	a035                	j	97a <tournament_create+0xc6>
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 950:	557d                	li	a0,-1
        }
   }
return trnmnt_idx ;
}
 952:	8082                	ret
        return -1; //failed to create lock
 954:	557d                	li	a0,-1
}
 956:	70a2                	ld	ra,40(sp)
 958:	7402                	ld	s0,32(sp)
 95a:	64e2                	ld	s1,24(sp)
 95c:	6942                	ld	s2,16(sp)
 95e:	69a2                	ld	s3,8(sp)
 960:	6a02                	ld	s4,0(sp)
 962:	6145                	addi	sp,sp,48
 964:	8082                	ret
            return -1 ;
 966:	557d                	li	a0,-1
 968:	b7fd                	j	956 <tournament_create+0xa2>
   num_levels = log2(processes) ;
 96a:	00000797          	auipc	a5,0x0
 96e:	6a07a123          	sw	zero,1698(a5) # 100c <num_levels>
   trnmnt_idx = 0;
 972:	00000797          	auipc	a5,0x0
 976:	6807ab23          	sw	zero,1686(a5) # 1008 <trnmnt_idx>
return trnmnt_idx ;
 97a:	00000517          	auipc	a0,0x0
 97e:	68e52503          	lw	a0,1678(a0) # 1008 <trnmnt_idx>
 982:	bfd1                	j	956 <tournament_create+0xa2>

0000000000000984 <tournament_acquire>:

int tournament_acquire(void){ 

    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 984:	00000797          	auipc	a5,0x0
 988:	6847a783          	lw	a5,1668(a5) # 1008 <trnmnt_idx>
 98c:	0a07c763          	bltz	a5,a3a <tournament_acquire+0xb6>
int tournament_acquire(void){ 
 990:	715d                	addi	sp,sp,-80
 992:	e486                	sd	ra,72(sp)
 994:	e0a2                	sd	s0,64(sp)
 996:	fc26                	sd	s1,56(sp)
 998:	f84a                	sd	s2,48(sp)
 99a:	f44e                	sd	s3,40(sp)
 99c:	f052                	sd	s4,32(sp)
 99e:	ec56                	sd	s5,24(sp)
 9a0:	e85a                	sd	s6,16(sp)
 9a2:	e45e                	sd	s7,8(sp)
 9a4:	0880                	addi	s0,sp,80
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 9a6:	00000497          	auipc	s1,0x0
 9aa:	6664a483          	lw	s1,1638(s1) # 100c <num_levels>
 9ae:	08905863          	blez	s1,a3e <tournament_acquire+0xba>

    for(int lvl = (num_levels -1) ; lvl >= 0 ; lvl--){
 9b2:	34fd                	addiw	s1,s1,-1
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 9b4:	0017f593          	andi	a1,a5,1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 9b8:	4017d79b          	sraiw	a5,a5,0x1
        int lockidx = lockl + (1<<lvl) -1 ;
 9bc:	4705                	li	a4,1
 9be:	0097173b          	sllw	a4,a4,s1
 9c2:	9fb9                	addw	a5,a5,a4
 9c4:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 9c6:	4739                	li	a4,14
 9c8:	06f74d63          	blt	a4,a5,a42 <tournament_acquire+0xbe>

        if(peterson_acquire(lock_ids[lockidx] , role) < 0)
 9cc:	00000997          	auipc	s3,0x0
 9d0:	65498993          	addi	s3,s3,1620 # 1020 <lock_ids>
    for(int lvl = (num_levels -1) ; lvl >= 0 ; lvl--){
 9d4:	5a7d                	li	s4,-1
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 9d6:	00000b97          	auipc	s7,0x0
 9da:	636b8b93          	addi	s7,s7,1590 # 100c <num_levels>
 9de:	00000b17          	auipc	s6,0x0
 9e2:	62ab0b13          	addi	s6,s6,1578 # 1008 <trnmnt_idx>
 9e6:	4905                	li	s2,1
        if(lockidx>=MAX_LOCKS) return -1 ;
 9e8:	4ab9                	li	s5,14
        if(peterson_acquire(lock_ids[lockidx] , role) < 0)
 9ea:	078a                	slli	a5,a5,0x2
 9ec:	97ce                	add	a5,a5,s3
 9ee:	4388                	lw	a0,0(a5)
 9f0:	00000097          	auipc	ra,0x0
 9f4:	a32080e7          	jalr	-1486(ra) # 422 <peterson_acquire>
 9f8:	04054763          	bltz	a0,a46 <tournament_acquire+0xc2>
    for(int lvl = (num_levels -1) ; lvl >= 0 ; lvl--){
 9fc:	fff4869b          	addiw	a3,s1,-1
 a00:	0006849b          	sext.w	s1,a3
 a04:	03448963          	beq	s1,s4,a36 <tournament_acquire+0xb2>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 a08:	000ba703          	lw	a4,0(s7)
 a0c:	40d706bb          	subw	a3,a4,a3
 a10:	fff6879b          	addiw	a5,a3,-1
 a14:	000b2703          	lw	a4,0(s6)
 a18:	00f915bb          	sllw	a1,s2,a5
 a1c:	8df9                	and	a1,a1,a4
 a1e:	40f5d5bb          	sraw	a1,a1,a5
        int lockidx = lockl + (1<<lvl) -1 ;
 a22:	009917bb          	sllw	a5,s2,s1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 a26:	40d7573b          	sraw	a4,a4,a3
        int lockidx = lockl + (1<<lvl) -1 ;
 a2a:	9fb9                	addw	a5,a5,a4
 a2c:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 a2e:	fafadee3          	bge	s5,a5,9ea <tournament_acquire+0x66>
 a32:	557d                	li	a0,-1
 a34:	a811                	j	a48 <tournament_acquire+0xc4>
        return -1;

    }
return 0 ;
 a36:	4501                	li	a0,0
 a38:	a801                	j	a48 <tournament_acquire+0xc4>
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 a3a:	557d                	li	a0,-1
}
 a3c:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 a3e:	557d                	li	a0,-1
 a40:	a021                	j	a48 <tournament_acquire+0xc4>
        if(lockidx>=MAX_LOCKS) return -1 ;
 a42:	557d                	li	a0,-1
 a44:	a011                	j	a48 <tournament_acquire+0xc4>
        return -1;
 a46:	557d                	li	a0,-1
}
 a48:	60a6                	ld	ra,72(sp)
 a4a:	6406                	ld	s0,64(sp)
 a4c:	74e2                	ld	s1,56(sp)
 a4e:	7942                	ld	s2,48(sp)
 a50:	79a2                	ld	s3,40(sp)
 a52:	7a02                	ld	s4,32(sp)
 a54:	6ae2                	ld	s5,24(sp)
 a56:	6b42                	ld	s6,16(sp)
 a58:	6ba2                	ld	s7,8(sp)
 a5a:	6161                	addi	sp,sp,80
 a5c:	8082                	ret

0000000000000a5e <tournament_release>:

int tournament_release(void) {

    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 a5e:	00000797          	auipc	a5,0x0
 a62:	5aa7a783          	lw	a5,1450(a5) # 1008 <trnmnt_idx>
 a66:	0a07c663          	bltz	a5,b12 <tournament_release+0xb4>
 a6a:	00000717          	auipc	a4,0x0
 a6e:	5a272703          	lw	a4,1442(a4) # 100c <num_levels>
 a72:	0ae05263          	blez	a4,b16 <tournament_release+0xb8>

    for(int lvl = 0 ; lvl < num_levels  ; lvl++){
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 a76:	fff7069b          	addiw	a3,a4,-1
 a7a:	4585                	li	a1,1
 a7c:	00d595bb          	sllw	a1,a1,a3
 a80:	8dfd                	and	a1,a1,a5
 a82:	40d5d5bb          	sraw	a1,a1,a3
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 a86:	40e7d7bb          	sraw	a5,a5,a4
        int lockidx = lockl + (1<<lvl) -1 ;
        if(lockidx>=MAX_LOCKS) return -1 ;
 a8a:	4739                	li	a4,14
 a8c:	08f74763          	blt	a4,a5,b1a <tournament_release+0xbc>
int tournament_release(void) {
 a90:	7139                	addi	sp,sp,-64
 a92:	fc06                	sd	ra,56(sp)
 a94:	f822                	sd	s0,48(sp)
 a96:	f426                	sd	s1,40(sp)
 a98:	f04a                	sd	s2,32(sp)
 a9a:	ec4e                	sd	s3,24(sp)
 a9c:	e852                	sd	s4,16(sp)
 a9e:	e456                	sd	s5,8(sp)
 aa0:	e05a                	sd	s6,0(sp)
 aa2:	0080                	addi	s0,sp,64
    for(int lvl = 0 ; lvl < num_levels  ; lvl++){
 aa4:	4481                	li	s1,0

        if (peterson_release(lock_ids[lockidx] , role) < 0)
 aa6:	00000997          	auipc	s3,0x0
 aaa:	57a98993          	addi	s3,s3,1402 # 1020 <lock_ids>
    for(int lvl = 0 ; lvl < num_levels  ; lvl++){
 aae:	00000a17          	auipc	s4,0x0
 ab2:	55ea0a13          	addi	s4,s4,1374 # 100c <num_levels>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 ab6:	00000b17          	auipc	s6,0x0
 aba:	552b0b13          	addi	s6,s6,1362 # 1008 <trnmnt_idx>
 abe:	4905                	li	s2,1
        if(lockidx>=MAX_LOCKS) return -1 ;
 ac0:	4ab9                	li	s5,14
        if (peterson_release(lock_ids[lockidx] , role) < 0)
 ac2:	078a                	slli	a5,a5,0x2
 ac4:	97ce                	add	a5,a5,s3
 ac6:	4388                	lw	a0,0(a5)
 ac8:	00000097          	auipc	ra,0x0
 acc:	962080e7          	jalr	-1694(ra) # 42a <peterson_release>
 ad0:	04054763          	bltz	a0,b1e <tournament_release+0xc0>
    for(int lvl = 0 ; lvl < num_levels  ; lvl++){
 ad4:	0014871b          	addiw	a4,s1,1
 ad8:	0007049b          	sext.w	s1,a4
 adc:	000a2783          	lw	a5,0(s4)
 ae0:	02f4d763          	bge	s1,a5,b0e <tournament_release+0xb0>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 ae4:	40e7873b          	subw	a4,a5,a4
 ae8:	fff7079b          	addiw	a5,a4,-1
 aec:	000b2683          	lw	a3,0(s6)
 af0:	00f915bb          	sllw	a1,s2,a5
 af4:	8df5                	and	a1,a1,a3
 af6:	40f5d5bb          	sraw	a1,a1,a5
        int lockidx = lockl + (1<<lvl) -1 ;
 afa:	009917bb          	sllw	a5,s2,s1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 afe:	40e6d73b          	sraw	a4,a3,a4
        int lockidx = lockl + (1<<lvl) -1 ;
 b02:	9fb9                	addw	a5,a5,a4
 b04:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 b06:	fafadee3          	bge	s5,a5,ac2 <tournament_release+0x64>
 b0a:	557d                	li	a0,-1
 b0c:	a811                	j	b20 <tournament_release+0xc2>
        return -1; 

    }
return 0 ;
 b0e:	4501                	li	a0,0
 b10:	a801                	j	b20 <tournament_release+0xc2>
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 b12:	557d                	li	a0,-1
 b14:	8082                	ret
 b16:	557d                	li	a0,-1
 b18:	8082                	ret
        if(lockidx>=MAX_LOCKS) return -1 ;
 b1a:	557d                	li	a0,-1


 b1c:	8082                	ret
        return -1; 
 b1e:	557d                	li	a0,-1
 b20:	70e2                	ld	ra,56(sp)
 b22:	7442                	ld	s0,48(sp)
 b24:	74a2                	ld	s1,40(sp)
 b26:	7902                	ld	s2,32(sp)
 b28:	69e2                	ld	s3,24(sp)
 b2a:	6a42                	ld	s4,16(sp)
 b2c:	6aa2                	ld	s5,8(sp)
 b2e:	6b02                	ld	s6,0(sp)
 b30:	6121                	addi	sp,sp,64
 b32:	8082                	ret
