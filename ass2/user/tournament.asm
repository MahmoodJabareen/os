
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
  14:	b3058593          	addi	a1,a1,-1232 # b40 <tournament_release+0xd8>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	6d4080e7          	jalr	1748(ra) # 6ee <fprintf>
        exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	360080e7          	jalr	864(ra) # 384 <exit>
    }

    int n= atoi(argv[1]) ;
  2c:	6588                	ld	a0,8(a1)
  2e:	00000097          	auipc	ra,0x0
  32:	25a080e7          	jalr	602(ra) # 288 <atoi>

    int tournament_id = tournament_create(n) ;
  36:	00001097          	auipc	ra,0x1
  3a:	888080e7          	jalr	-1912(ra) # 8be <tournament_create>
  3e:	84aa                	mv	s1,a0

    if(tournament_id < 0){
  40:	06054463          	bltz	a0,a8 <main+0xa8>
        fprintf(2 , "failed creating tournament \n");
        exit(1);
    }

    if (tournament_acquire() < 0) {
  44:	00001097          	auipc	ra,0x1
  48:	956080e7          	jalr	-1706(ra) # 99a <tournament_acquire>
  4c:	06054c63          	bltz	a0,c4 <main+0xc4>
        fprintf(2, "failed acquiring\n");
        exit(1);
    }


    printf("Process with PID %d, Tournament ID %d has entered the critical section\n", getpid(), tournament_id);
  50:	00000097          	auipc	ra,0x0
  54:	3b4080e7          	jalr	948(ra) # 404 <getpid>
  58:	85aa                	mv	a1,a0
  5a:	8626                	mv	a2,s1
  5c:	00001517          	auipc	a0,0x1
  60:	b2c50513          	addi	a0,a0,-1236 # b88 <tournament_release+0x120>
  64:	00000097          	auipc	ra,0x0
  68:	6b8080e7          	jalr	1720(ra) # 71c <printf>
    sleep(10);  // hold the lock for a while to test mutual exclusion
  6c:	4529                	li	a0,10
  6e:	00000097          	auipc	ra,0x0
  72:	3a6080e7          	jalr	934(ra) # 414 <sleep>
    printf("Process with PID %d, Tournament ID %d is leaving the critical section\n", getpid(), tournament_id);
  76:	00000097          	auipc	ra,0x0
  7a:	38e080e7          	jalr	910(ra) # 404 <getpid>
  7e:	85aa                	mv	a1,a0
  80:	8626                	mv	a2,s1
  82:	00001517          	auipc	a0,0x1
  86:	b4e50513          	addi	a0,a0,-1202 # bd0 <tournament_release+0x168>
  8a:	00000097          	auipc	ra,0x0
  8e:	692080e7          	jalr	1682(ra) # 71c <printf>

    if (tournament_release() < 0) {
  92:	00001097          	auipc	ra,0x1
  96:	9d6080e7          	jalr	-1578(ra) # a68 <tournament_release>
  9a:	04054363          	bltz	a0,e0 <main+0xe0>
        fprintf(2, "failed releasing\n");
        exit(1);
    }

    exit(0) ;
  9e:	4501                	li	a0,0
  a0:	00000097          	auipc	ra,0x0
  a4:	2e4080e7          	jalr	740(ra) # 384 <exit>
        fprintf(2 , "failed creating tournament \n");
  a8:	00001597          	auipc	a1,0x1
  ac:	aa858593          	addi	a1,a1,-1368 # b50 <tournament_release+0xe8>
  b0:	4509                	li	a0,2
  b2:	00000097          	auipc	ra,0x0
  b6:	63c080e7          	jalr	1596(ra) # 6ee <fprintf>
        exit(1);
  ba:	4505                	li	a0,1
  bc:	00000097          	auipc	ra,0x0
  c0:	2c8080e7          	jalr	712(ra) # 384 <exit>
        fprintf(2, "failed acquiring\n");
  c4:	00001597          	auipc	a1,0x1
  c8:	aac58593          	addi	a1,a1,-1364 # b70 <tournament_release+0x108>
  cc:	4509                	li	a0,2
  ce:	00000097          	auipc	ra,0x0
  d2:	620080e7          	jalr	1568(ra) # 6ee <fprintf>
        exit(1);
  d6:	4505                	li	a0,1
  d8:	00000097          	auipc	ra,0x0
  dc:	2ac080e7          	jalr	684(ra) # 384 <exit>
        fprintf(2, "failed releasing\n");
  e0:	00001597          	auipc	a1,0x1
  e4:	b3858593          	addi	a1,a1,-1224 # c18 <tournament_release+0x1b0>
  e8:	4509                	li	a0,2
  ea:	00000097          	auipc	ra,0x0
  ee:	604080e7          	jalr	1540(ra) # 6ee <fprintf>
        exit(1);
  f2:	4505                	li	a0,1
  f4:	00000097          	auipc	ra,0x0
  f8:	290080e7          	jalr	656(ra) # 384 <exit>

00000000000000fc <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e406                	sd	ra,8(sp)
 100:	e022                	sd	s0,0(sp)
 102:	0800                	addi	s0,sp,16
  extern int main();
  main();
 104:	00000097          	auipc	ra,0x0
 108:	efc080e7          	jalr	-260(ra) # 0 <main>
  exit(0);
 10c:	4501                	li	a0,0
 10e:	00000097          	auipc	ra,0x0
 112:	276080e7          	jalr	630(ra) # 384 <exit>

0000000000000116 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 116:	1141                	addi	sp,sp,-16
 118:	e422                	sd	s0,8(sp)
 11a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11c:	87aa                	mv	a5,a0
 11e:	0585                	addi	a1,a1,1
 120:	0785                	addi	a5,a5,1
 122:	fff5c703          	lbu	a4,-1(a1)
 126:	fee78fa3          	sb	a4,-1(a5)
 12a:	fb75                	bnez	a4,11e <strcpy+0x8>
    ;
  return os;
}
 12c:	6422                	ld	s0,8(sp)
 12e:	0141                	addi	sp,sp,16
 130:	8082                	ret

0000000000000132 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 132:	1141                	addi	sp,sp,-16
 134:	e422                	sd	s0,8(sp)
 136:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 138:	00054783          	lbu	a5,0(a0)
 13c:	cb91                	beqz	a5,150 <strcmp+0x1e>
 13e:	0005c703          	lbu	a4,0(a1)
 142:	00f71763          	bne	a4,a5,150 <strcmp+0x1e>
    p++, q++;
 146:	0505                	addi	a0,a0,1
 148:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14a:	00054783          	lbu	a5,0(a0)
 14e:	fbe5                	bnez	a5,13e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 150:	0005c503          	lbu	a0,0(a1)
}
 154:	40a7853b          	subw	a0,a5,a0
 158:	6422                	ld	s0,8(sp)
 15a:	0141                	addi	sp,sp,16
 15c:	8082                	ret

000000000000015e <strlen>:

uint
strlen(const char *s)
{
 15e:	1141                	addi	sp,sp,-16
 160:	e422                	sd	s0,8(sp)
 162:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 164:	00054783          	lbu	a5,0(a0)
 168:	cf91                	beqz	a5,184 <strlen+0x26>
 16a:	0505                	addi	a0,a0,1
 16c:	87aa                	mv	a5,a0
 16e:	4685                	li	a3,1
 170:	9e89                	subw	a3,a3,a0
 172:	00f6853b          	addw	a0,a3,a5
 176:	0785                	addi	a5,a5,1
 178:	fff7c703          	lbu	a4,-1(a5)
 17c:	fb7d                	bnez	a4,172 <strlen+0x14>
    ;
  return n;
}
 17e:	6422                	ld	s0,8(sp)
 180:	0141                	addi	sp,sp,16
 182:	8082                	ret
  for(n = 0; s[n]; n++)
 184:	4501                	li	a0,0
 186:	bfe5                	j	17e <strlen+0x20>

0000000000000188 <memset>:

void*
memset(void *dst, int c, uint n)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 18e:	ca19                	beqz	a2,1a4 <memset+0x1c>
 190:	87aa                	mv	a5,a0
 192:	1602                	slli	a2,a2,0x20
 194:	9201                	srli	a2,a2,0x20
 196:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 19a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 19e:	0785                	addi	a5,a5,1
 1a0:	fee79de3          	bne	a5,a4,19a <memset+0x12>
  }
  return dst;
}
 1a4:	6422                	ld	s0,8(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret

00000000000001aa <strchr>:

char*
strchr(const char *s, char c)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	cb99                	beqz	a5,1ca <strchr+0x20>
    if(*s == c)
 1b6:	00f58763          	beq	a1,a5,1c4 <strchr+0x1a>
  for(; *s; s++)
 1ba:	0505                	addi	a0,a0,1
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	fbfd                	bnez	a5,1b6 <strchr+0xc>
      return (char*)s;
  return 0;
 1c2:	4501                	li	a0,0
}
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret
  return 0;
 1ca:	4501                	li	a0,0
 1cc:	bfe5                	j	1c4 <strchr+0x1a>

00000000000001ce <gets>:

char*
gets(char *buf, int max)
{
 1ce:	711d                	addi	sp,sp,-96
 1d0:	ec86                	sd	ra,88(sp)
 1d2:	e8a2                	sd	s0,80(sp)
 1d4:	e4a6                	sd	s1,72(sp)
 1d6:	e0ca                	sd	s2,64(sp)
 1d8:	fc4e                	sd	s3,56(sp)
 1da:	f852                	sd	s4,48(sp)
 1dc:	f456                	sd	s5,40(sp)
 1de:	f05a                	sd	s6,32(sp)
 1e0:	ec5e                	sd	s7,24(sp)
 1e2:	1080                	addi	s0,sp,96
 1e4:	8baa                	mv	s7,a0
 1e6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e8:	892a                	mv	s2,a0
 1ea:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ec:	4aa9                	li	s5,10
 1ee:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1f0:	89a6                	mv	s3,s1
 1f2:	2485                	addiw	s1,s1,1
 1f4:	0344d863          	bge	s1,s4,224 <gets+0x56>
    cc = read(0, &c, 1);
 1f8:	4605                	li	a2,1
 1fa:	faf40593          	addi	a1,s0,-81
 1fe:	4501                	li	a0,0
 200:	00000097          	auipc	ra,0x0
 204:	19c080e7          	jalr	412(ra) # 39c <read>
    if(cc < 1)
 208:	00a05e63          	blez	a0,224 <gets+0x56>
    buf[i++] = c;
 20c:	faf44783          	lbu	a5,-81(s0)
 210:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 214:	01578763          	beq	a5,s5,222 <gets+0x54>
 218:	0905                	addi	s2,s2,1
 21a:	fd679be3          	bne	a5,s6,1f0 <gets+0x22>
  for(i=0; i+1 < max; ){
 21e:	89a6                	mv	s3,s1
 220:	a011                	j	224 <gets+0x56>
 222:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 224:	99de                	add	s3,s3,s7
 226:	00098023          	sb	zero,0(s3)
  return buf;
}
 22a:	855e                	mv	a0,s7
 22c:	60e6                	ld	ra,88(sp)
 22e:	6446                	ld	s0,80(sp)
 230:	64a6                	ld	s1,72(sp)
 232:	6906                	ld	s2,64(sp)
 234:	79e2                	ld	s3,56(sp)
 236:	7a42                	ld	s4,48(sp)
 238:	7aa2                	ld	s5,40(sp)
 23a:	7b02                	ld	s6,32(sp)
 23c:	6be2                	ld	s7,24(sp)
 23e:	6125                	addi	sp,sp,96
 240:	8082                	ret

0000000000000242 <stat>:

int
stat(const char *n, struct stat *st)
{
 242:	1101                	addi	sp,sp,-32
 244:	ec06                	sd	ra,24(sp)
 246:	e822                	sd	s0,16(sp)
 248:	e426                	sd	s1,8(sp)
 24a:	e04a                	sd	s2,0(sp)
 24c:	1000                	addi	s0,sp,32
 24e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 250:	4581                	li	a1,0
 252:	00000097          	auipc	ra,0x0
 256:	172080e7          	jalr	370(ra) # 3c4 <open>
  if(fd < 0)
 25a:	02054563          	bltz	a0,284 <stat+0x42>
 25e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 260:	85ca                	mv	a1,s2
 262:	00000097          	auipc	ra,0x0
 266:	17a080e7          	jalr	378(ra) # 3dc <fstat>
 26a:	892a                	mv	s2,a0
  close(fd);
 26c:	8526                	mv	a0,s1
 26e:	00000097          	auipc	ra,0x0
 272:	13e080e7          	jalr	318(ra) # 3ac <close>
  return r;
}
 276:	854a                	mv	a0,s2
 278:	60e2                	ld	ra,24(sp)
 27a:	6442                	ld	s0,16(sp)
 27c:	64a2                	ld	s1,8(sp)
 27e:	6902                	ld	s2,0(sp)
 280:	6105                	addi	sp,sp,32
 282:	8082                	ret
    return -1;
 284:	597d                	li	s2,-1
 286:	bfc5                	j	276 <stat+0x34>

0000000000000288 <atoi>:

int
atoi(const char *s)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 28e:	00054603          	lbu	a2,0(a0)
 292:	fd06079b          	addiw	a5,a2,-48
 296:	0ff7f793          	andi	a5,a5,255
 29a:	4725                	li	a4,9
 29c:	02f76963          	bltu	a4,a5,2ce <atoi+0x46>
 2a0:	86aa                	mv	a3,a0
  n = 0;
 2a2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2a4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2a6:	0685                	addi	a3,a3,1
 2a8:	0025179b          	slliw	a5,a0,0x2
 2ac:	9fa9                	addw	a5,a5,a0
 2ae:	0017979b          	slliw	a5,a5,0x1
 2b2:	9fb1                	addw	a5,a5,a2
 2b4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2b8:	0006c603          	lbu	a2,0(a3)
 2bc:	fd06071b          	addiw	a4,a2,-48
 2c0:	0ff77713          	andi	a4,a4,255
 2c4:	fee5f1e3          	bgeu	a1,a4,2a6 <atoi+0x1e>
  return n;
}
 2c8:	6422                	ld	s0,8(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
  n = 0;
 2ce:	4501                	li	a0,0
 2d0:	bfe5                	j	2c8 <atoi+0x40>

00000000000002d2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e422                	sd	s0,8(sp)
 2d6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2d8:	02b57463          	bgeu	a0,a1,300 <memmove+0x2e>
    while(n-- > 0)
 2dc:	00c05f63          	blez	a2,2fa <memmove+0x28>
 2e0:	1602                	slli	a2,a2,0x20
 2e2:	9201                	srli	a2,a2,0x20
 2e4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2e8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ea:	0585                	addi	a1,a1,1
 2ec:	0705                	addi	a4,a4,1
 2ee:	fff5c683          	lbu	a3,-1(a1)
 2f2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f6:	fee79ae3          	bne	a5,a4,2ea <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2fa:	6422                	ld	s0,8(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret
    dst += n;
 300:	00c50733          	add	a4,a0,a2
    src += n;
 304:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 306:	fec05ae3          	blez	a2,2fa <memmove+0x28>
 30a:	fff6079b          	addiw	a5,a2,-1
 30e:	1782                	slli	a5,a5,0x20
 310:	9381                	srli	a5,a5,0x20
 312:	fff7c793          	not	a5,a5
 316:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 318:	15fd                	addi	a1,a1,-1
 31a:	177d                	addi	a4,a4,-1
 31c:	0005c683          	lbu	a3,0(a1)
 320:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 324:	fee79ae3          	bne	a5,a4,318 <memmove+0x46>
 328:	bfc9                	j	2fa <memmove+0x28>

000000000000032a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 32a:	1141                	addi	sp,sp,-16
 32c:	e422                	sd	s0,8(sp)
 32e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 330:	ca05                	beqz	a2,360 <memcmp+0x36>
 332:	fff6069b          	addiw	a3,a2,-1
 336:	1682                	slli	a3,a3,0x20
 338:	9281                	srli	a3,a3,0x20
 33a:	0685                	addi	a3,a3,1
 33c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 33e:	00054783          	lbu	a5,0(a0)
 342:	0005c703          	lbu	a4,0(a1)
 346:	00e79863          	bne	a5,a4,356 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 34a:	0505                	addi	a0,a0,1
    p2++;
 34c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 34e:	fed518e3          	bne	a0,a3,33e <memcmp+0x14>
  }
  return 0;
 352:	4501                	li	a0,0
 354:	a019                	j	35a <memcmp+0x30>
      return *p1 - *p2;
 356:	40e7853b          	subw	a0,a5,a4
}
 35a:	6422                	ld	s0,8(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret
  return 0;
 360:	4501                	li	a0,0
 362:	bfe5                	j	35a <memcmp+0x30>

0000000000000364 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 364:	1141                	addi	sp,sp,-16
 366:	e406                	sd	ra,8(sp)
 368:	e022                	sd	s0,0(sp)
 36a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 36c:	00000097          	auipc	ra,0x0
 370:	f66080e7          	jalr	-154(ra) # 2d2 <memmove>
}
 374:	60a2                	ld	ra,8(sp)
 376:	6402                	ld	s0,0(sp)
 378:	0141                	addi	sp,sp,16
 37a:	8082                	ret

000000000000037c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 37c:	4885                	li	a7,1
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <exit>:
.global exit
exit:
 li a7, SYS_exit
 384:	4889                	li	a7,2
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <wait>:
.global wait
wait:
 li a7, SYS_wait
 38c:	488d                	li	a7,3
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 394:	4891                	li	a7,4
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <read>:
.global read
read:
 li a7, SYS_read
 39c:	4895                	li	a7,5
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <write>:
.global write
write:
 li a7, SYS_write
 3a4:	48c1                	li	a7,16
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <close>:
.global close
close:
 li a7, SYS_close
 3ac:	48d5                	li	a7,21
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b4:	4899                	li	a7,6
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <exec>:
.global exec
exec:
 li a7, SYS_exec
 3bc:	489d                	li	a7,7
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <open>:
.global open
open:
 li a7, SYS_open
 3c4:	48bd                	li	a7,15
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3cc:	48c5                	li	a7,17
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d4:	48c9                	li	a7,18
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3dc:	48a1                	li	a7,8
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <link>:
.global link
link:
 li a7, SYS_link
 3e4:	48cd                	li	a7,19
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ec:	48d1                	li	a7,20
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f4:	48a5                	li	a7,9
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <dup>:
.global dup
dup:
 li a7, SYS_dup
 3fc:	48a9                	li	a7,10
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 404:	48ad                	li	a7,11
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 40c:	48b1                	li	a7,12
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 414:	48b5                	li	a7,13
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 41c:	48b9                	li	a7,14
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <peterson_create>:
.global peterson_create
peterson_create:
 li a7, SYS_peterson_create
 424:	48d9                	li	a7,22
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <peterson_acquire>:
.global peterson_acquire
peterson_acquire:
 li a7, SYS_peterson_acquire
 42c:	48dd                	li	a7,23
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <peterson_release>:
.global peterson_release
peterson_release:
 li a7, SYS_peterson_release
 434:	48e1                	li	a7,24
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <peterson_destroy>:
.global peterson_destroy
peterson_destroy:
 li a7, SYS_peterson_destroy
 43c:	48e5                	li	a7,25
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 444:	1101                	addi	sp,sp,-32
 446:	ec06                	sd	ra,24(sp)
 448:	e822                	sd	s0,16(sp)
 44a:	1000                	addi	s0,sp,32
 44c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 450:	4605                	li	a2,1
 452:	fef40593          	addi	a1,s0,-17
 456:	00000097          	auipc	ra,0x0
 45a:	f4e080e7          	jalr	-178(ra) # 3a4 <write>
}
 45e:	60e2                	ld	ra,24(sp)
 460:	6442                	ld	s0,16(sp)
 462:	6105                	addi	sp,sp,32
 464:	8082                	ret

0000000000000466 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 466:	7139                	addi	sp,sp,-64
 468:	fc06                	sd	ra,56(sp)
 46a:	f822                	sd	s0,48(sp)
 46c:	f426                	sd	s1,40(sp)
 46e:	f04a                	sd	s2,32(sp)
 470:	ec4e                	sd	s3,24(sp)
 472:	0080                	addi	s0,sp,64
 474:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 476:	c299                	beqz	a3,47c <printint+0x16>
 478:	0805c863          	bltz	a1,508 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 47c:	2581                	sext.w	a1,a1
  neg = 0;
 47e:	4881                	li	a7,0
 480:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 484:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 486:	2601                	sext.w	a2,a2
 488:	00000517          	auipc	a0,0x0
 48c:	7b050513          	addi	a0,a0,1968 # c38 <digits>
 490:	883a                	mv	a6,a4
 492:	2705                	addiw	a4,a4,1
 494:	02c5f7bb          	remuw	a5,a1,a2
 498:	1782                	slli	a5,a5,0x20
 49a:	9381                	srli	a5,a5,0x20
 49c:	97aa                	add	a5,a5,a0
 49e:	0007c783          	lbu	a5,0(a5)
 4a2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4a6:	0005879b          	sext.w	a5,a1
 4aa:	02c5d5bb          	divuw	a1,a1,a2
 4ae:	0685                	addi	a3,a3,1
 4b0:	fec7f0e3          	bgeu	a5,a2,490 <printint+0x2a>
  if(neg)
 4b4:	00088b63          	beqz	a7,4ca <printint+0x64>
    buf[i++] = '-';
 4b8:	fd040793          	addi	a5,s0,-48
 4bc:	973e                	add	a4,a4,a5
 4be:	02d00793          	li	a5,45
 4c2:	fef70823          	sb	a5,-16(a4)
 4c6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ca:	02e05863          	blez	a4,4fa <printint+0x94>
 4ce:	fc040793          	addi	a5,s0,-64
 4d2:	00e78933          	add	s2,a5,a4
 4d6:	fff78993          	addi	s3,a5,-1
 4da:	99ba                	add	s3,s3,a4
 4dc:	377d                	addiw	a4,a4,-1
 4de:	1702                	slli	a4,a4,0x20
 4e0:	9301                	srli	a4,a4,0x20
 4e2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4e6:	fff94583          	lbu	a1,-1(s2)
 4ea:	8526                	mv	a0,s1
 4ec:	00000097          	auipc	ra,0x0
 4f0:	f58080e7          	jalr	-168(ra) # 444 <putc>
  while(--i >= 0)
 4f4:	197d                	addi	s2,s2,-1
 4f6:	ff3918e3          	bne	s2,s3,4e6 <printint+0x80>
}
 4fa:	70e2                	ld	ra,56(sp)
 4fc:	7442                	ld	s0,48(sp)
 4fe:	74a2                	ld	s1,40(sp)
 500:	7902                	ld	s2,32(sp)
 502:	69e2                	ld	s3,24(sp)
 504:	6121                	addi	sp,sp,64
 506:	8082                	ret
    x = -xx;
 508:	40b005bb          	negw	a1,a1
    neg = 1;
 50c:	4885                	li	a7,1
    x = -xx;
 50e:	bf8d                	j	480 <printint+0x1a>

0000000000000510 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 510:	7119                	addi	sp,sp,-128
 512:	fc86                	sd	ra,120(sp)
 514:	f8a2                	sd	s0,112(sp)
 516:	f4a6                	sd	s1,104(sp)
 518:	f0ca                	sd	s2,96(sp)
 51a:	ecce                	sd	s3,88(sp)
 51c:	e8d2                	sd	s4,80(sp)
 51e:	e4d6                	sd	s5,72(sp)
 520:	e0da                	sd	s6,64(sp)
 522:	fc5e                	sd	s7,56(sp)
 524:	f862                	sd	s8,48(sp)
 526:	f466                	sd	s9,40(sp)
 528:	f06a                	sd	s10,32(sp)
 52a:	ec6e                	sd	s11,24(sp)
 52c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 52e:	0005c903          	lbu	s2,0(a1)
 532:	18090f63          	beqz	s2,6d0 <vprintf+0x1c0>
 536:	8aaa                	mv	s5,a0
 538:	8b32                	mv	s6,a2
 53a:	00158493          	addi	s1,a1,1
  state = 0;
 53e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 540:	02500a13          	li	s4,37
      if(c == 'd'){
 544:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 548:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 54c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 550:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 554:	00000b97          	auipc	s7,0x0
 558:	6e4b8b93          	addi	s7,s7,1764 # c38 <digits>
 55c:	a839                	j	57a <vprintf+0x6a>
        putc(fd, c);
 55e:	85ca                	mv	a1,s2
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	ee2080e7          	jalr	-286(ra) # 444 <putc>
 56a:	a019                	j	570 <vprintf+0x60>
    } else if(state == '%'){
 56c:	01498f63          	beq	s3,s4,58a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 570:	0485                	addi	s1,s1,1
 572:	fff4c903          	lbu	s2,-1(s1)
 576:	14090d63          	beqz	s2,6d0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 57a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 57e:	fe0997e3          	bnez	s3,56c <vprintf+0x5c>
      if(c == '%'){
 582:	fd479ee3          	bne	a5,s4,55e <vprintf+0x4e>
        state = '%';
 586:	89be                	mv	s3,a5
 588:	b7e5                	j	570 <vprintf+0x60>
      if(c == 'd'){
 58a:	05878063          	beq	a5,s8,5ca <vprintf+0xba>
      } else if(c == 'l') {
 58e:	05978c63          	beq	a5,s9,5e6 <vprintf+0xd6>
      } else if(c == 'x') {
 592:	07a78863          	beq	a5,s10,602 <vprintf+0xf2>
      } else if(c == 'p') {
 596:	09b78463          	beq	a5,s11,61e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 59a:	07300713          	li	a4,115
 59e:	0ce78663          	beq	a5,a4,66a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5a2:	06300713          	li	a4,99
 5a6:	0ee78e63          	beq	a5,a4,6a2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5aa:	11478863          	beq	a5,s4,6ba <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ae:	85d2                	mv	a1,s4
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	e92080e7          	jalr	-366(ra) # 444 <putc>
        putc(fd, c);
 5ba:	85ca                	mv	a1,s2
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	e86080e7          	jalr	-378(ra) # 444 <putc>
      }
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	b765                	j	570 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5ca:	008b0913          	addi	s2,s6,8
 5ce:	4685                	li	a3,1
 5d0:	4629                	li	a2,10
 5d2:	000b2583          	lw	a1,0(s6)
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	e8e080e7          	jalr	-370(ra) # 466 <printint>
 5e0:	8b4a                	mv	s6,s2
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	b771                	j	570 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e6:	008b0913          	addi	s2,s6,8
 5ea:	4681                	li	a3,0
 5ec:	4629                	li	a2,10
 5ee:	000b2583          	lw	a1,0(s6)
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	e72080e7          	jalr	-398(ra) # 466 <printint>
 5fc:	8b4a                	mv	s6,s2
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bf85                	j	570 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 602:	008b0913          	addi	s2,s6,8
 606:	4681                	li	a3,0
 608:	4641                	li	a2,16
 60a:	000b2583          	lw	a1,0(s6)
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e56080e7          	jalr	-426(ra) # 466 <printint>
 618:	8b4a                	mv	s6,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bf91                	j	570 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 61e:	008b0793          	addi	a5,s6,8
 622:	f8f43423          	sd	a5,-120(s0)
 626:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 62a:	03000593          	li	a1,48
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	e14080e7          	jalr	-492(ra) # 444 <putc>
  putc(fd, 'x');
 638:	85ea                	mv	a1,s10
 63a:	8556                	mv	a0,s5
 63c:	00000097          	auipc	ra,0x0
 640:	e08080e7          	jalr	-504(ra) # 444 <putc>
 644:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 646:	03c9d793          	srli	a5,s3,0x3c
 64a:	97de                	add	a5,a5,s7
 64c:	0007c583          	lbu	a1,0(a5)
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	df2080e7          	jalr	-526(ra) # 444 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 65a:	0992                	slli	s3,s3,0x4
 65c:	397d                	addiw	s2,s2,-1
 65e:	fe0914e3          	bnez	s2,646 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 662:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 666:	4981                	li	s3,0
 668:	b721                	j	570 <vprintf+0x60>
        s = va_arg(ap, char*);
 66a:	008b0993          	addi	s3,s6,8
 66e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 672:	02090163          	beqz	s2,694 <vprintf+0x184>
        while(*s != 0){
 676:	00094583          	lbu	a1,0(s2)
 67a:	c9a1                	beqz	a1,6ca <vprintf+0x1ba>
          putc(fd, *s);
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	dc6080e7          	jalr	-570(ra) # 444 <putc>
          s++;
 686:	0905                	addi	s2,s2,1
        while(*s != 0){
 688:	00094583          	lbu	a1,0(s2)
 68c:	f9e5                	bnez	a1,67c <vprintf+0x16c>
        s = va_arg(ap, char*);
 68e:	8b4e                	mv	s6,s3
      state = 0;
 690:	4981                	li	s3,0
 692:	bdf9                	j	570 <vprintf+0x60>
          s = "(null)";
 694:	00000917          	auipc	s2,0x0
 698:	59c90913          	addi	s2,s2,1436 # c30 <tournament_release+0x1c8>
        while(*s != 0){
 69c:	02800593          	li	a1,40
 6a0:	bff1                	j	67c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6a2:	008b0913          	addi	s2,s6,8
 6a6:	000b4583          	lbu	a1,0(s6)
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	d98080e7          	jalr	-616(ra) # 444 <putc>
 6b4:	8b4a                	mv	s6,s2
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	bd65                	j	570 <vprintf+0x60>
        putc(fd, c);
 6ba:	85d2                	mv	a1,s4
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	d86080e7          	jalr	-634(ra) # 444 <putc>
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b565                	j	570 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ca:	8b4e                	mv	s6,s3
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b54d                	j	570 <vprintf+0x60>
    }
  }
}
 6d0:	70e6                	ld	ra,120(sp)
 6d2:	7446                	ld	s0,112(sp)
 6d4:	74a6                	ld	s1,104(sp)
 6d6:	7906                	ld	s2,96(sp)
 6d8:	69e6                	ld	s3,88(sp)
 6da:	6a46                	ld	s4,80(sp)
 6dc:	6aa6                	ld	s5,72(sp)
 6de:	6b06                	ld	s6,64(sp)
 6e0:	7be2                	ld	s7,56(sp)
 6e2:	7c42                	ld	s8,48(sp)
 6e4:	7ca2                	ld	s9,40(sp)
 6e6:	7d02                	ld	s10,32(sp)
 6e8:	6de2                	ld	s11,24(sp)
 6ea:	6109                	addi	sp,sp,128
 6ec:	8082                	ret

00000000000006ee <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ee:	715d                	addi	sp,sp,-80
 6f0:	ec06                	sd	ra,24(sp)
 6f2:	e822                	sd	s0,16(sp)
 6f4:	1000                	addi	s0,sp,32
 6f6:	e010                	sd	a2,0(s0)
 6f8:	e414                	sd	a3,8(s0)
 6fa:	e818                	sd	a4,16(s0)
 6fc:	ec1c                	sd	a5,24(s0)
 6fe:	03043023          	sd	a6,32(s0)
 702:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 706:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 70a:	8622                	mv	a2,s0
 70c:	00000097          	auipc	ra,0x0
 710:	e04080e7          	jalr	-508(ra) # 510 <vprintf>
}
 714:	60e2                	ld	ra,24(sp)
 716:	6442                	ld	s0,16(sp)
 718:	6161                	addi	sp,sp,80
 71a:	8082                	ret

000000000000071c <printf>:

void
printf(const char *fmt, ...)
{
 71c:	711d                	addi	sp,sp,-96
 71e:	ec06                	sd	ra,24(sp)
 720:	e822                	sd	s0,16(sp)
 722:	1000                	addi	s0,sp,32
 724:	e40c                	sd	a1,8(s0)
 726:	e810                	sd	a2,16(s0)
 728:	ec14                	sd	a3,24(s0)
 72a:	f018                	sd	a4,32(s0)
 72c:	f41c                	sd	a5,40(s0)
 72e:	03043823          	sd	a6,48(s0)
 732:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 736:	00840613          	addi	a2,s0,8
 73a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 73e:	85aa                	mv	a1,a0
 740:	4505                	li	a0,1
 742:	00000097          	auipc	ra,0x0
 746:	dce080e7          	jalr	-562(ra) # 510 <vprintf>
}
 74a:	60e2                	ld	ra,24(sp)
 74c:	6442                	ld	s0,16(sp)
 74e:	6125                	addi	sp,sp,96
 750:	8082                	ret

0000000000000752 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 752:	1141                	addi	sp,sp,-16
 754:	e422                	sd	s0,8(sp)
 756:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 758:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75c:	00001797          	auipc	a5,0x1
 760:	8a47b783          	ld	a5,-1884(a5) # 1000 <freep>
 764:	a805                	j	794 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 766:	4618                	lw	a4,8(a2)
 768:	9db9                	addw	a1,a1,a4
 76a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 76e:	6398                	ld	a4,0(a5)
 770:	6318                	ld	a4,0(a4)
 772:	fee53823          	sd	a4,-16(a0)
 776:	a091                	j	7ba <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 778:	ff852703          	lw	a4,-8(a0)
 77c:	9e39                	addw	a2,a2,a4
 77e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 780:	ff053703          	ld	a4,-16(a0)
 784:	e398                	sd	a4,0(a5)
 786:	a099                	j	7cc <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 788:	6398                	ld	a4,0(a5)
 78a:	00e7e463          	bltu	a5,a4,792 <free+0x40>
 78e:	00e6ea63          	bltu	a3,a4,7a2 <free+0x50>
{
 792:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 794:	fed7fae3          	bgeu	a5,a3,788 <free+0x36>
 798:	6398                	ld	a4,0(a5)
 79a:	00e6e463          	bltu	a3,a4,7a2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 79e:	fee7eae3          	bltu	a5,a4,792 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7a2:	ff852583          	lw	a1,-8(a0)
 7a6:	6390                	ld	a2,0(a5)
 7a8:	02059713          	slli	a4,a1,0x20
 7ac:	9301                	srli	a4,a4,0x20
 7ae:	0712                	slli	a4,a4,0x4
 7b0:	9736                	add	a4,a4,a3
 7b2:	fae60ae3          	beq	a2,a4,766 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7b6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ba:	4790                	lw	a2,8(a5)
 7bc:	02061713          	slli	a4,a2,0x20
 7c0:	9301                	srli	a4,a4,0x20
 7c2:	0712                	slli	a4,a4,0x4
 7c4:	973e                	add	a4,a4,a5
 7c6:	fae689e3          	beq	a3,a4,778 <free+0x26>
  } else
    p->s.ptr = bp;
 7ca:	e394                	sd	a3,0(a5)
  freep = p;
 7cc:	00001717          	auipc	a4,0x1
 7d0:	82f73a23          	sd	a5,-1996(a4) # 1000 <freep>
}
 7d4:	6422                	ld	s0,8(sp)
 7d6:	0141                	addi	sp,sp,16
 7d8:	8082                	ret

00000000000007da <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7da:	7139                	addi	sp,sp,-64
 7dc:	fc06                	sd	ra,56(sp)
 7de:	f822                	sd	s0,48(sp)
 7e0:	f426                	sd	s1,40(sp)
 7e2:	f04a                	sd	s2,32(sp)
 7e4:	ec4e                	sd	s3,24(sp)
 7e6:	e852                	sd	s4,16(sp)
 7e8:	e456                	sd	s5,8(sp)
 7ea:	e05a                	sd	s6,0(sp)
 7ec:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ee:	02051493          	slli	s1,a0,0x20
 7f2:	9081                	srli	s1,s1,0x20
 7f4:	04bd                	addi	s1,s1,15
 7f6:	8091                	srli	s1,s1,0x4
 7f8:	0014899b          	addiw	s3,s1,1
 7fc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7fe:	00001517          	auipc	a0,0x1
 802:	80253503          	ld	a0,-2046(a0) # 1000 <freep>
 806:	c515                	beqz	a0,832 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 808:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 80a:	4798                	lw	a4,8(a5)
 80c:	02977f63          	bgeu	a4,s1,84a <malloc+0x70>
 810:	8a4e                	mv	s4,s3
 812:	0009871b          	sext.w	a4,s3
 816:	6685                	lui	a3,0x1
 818:	00d77363          	bgeu	a4,a3,81e <malloc+0x44>
 81c:	6a05                	lui	s4,0x1
 81e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 822:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 826:	00000917          	auipc	s2,0x0
 82a:	7da90913          	addi	s2,s2,2010 # 1000 <freep>
  if(p == (char*)-1)
 82e:	5afd                	li	s5,-1
 830:	a88d                	j	8a2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 832:	00000797          	auipc	a5,0x0
 836:	7ee78793          	addi	a5,a5,2030 # 1020 <base>
 83a:	00000717          	auipc	a4,0x0
 83e:	7cf73323          	sd	a5,1990(a4) # 1000 <freep>
 842:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 844:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 848:	b7e1                	j	810 <malloc+0x36>
      if(p->s.size == nunits)
 84a:	02e48b63          	beq	s1,a4,880 <malloc+0xa6>
        p->s.size -= nunits;
 84e:	4137073b          	subw	a4,a4,s3
 852:	c798                	sw	a4,8(a5)
        p += p->s.size;
 854:	1702                	slli	a4,a4,0x20
 856:	9301                	srli	a4,a4,0x20
 858:	0712                	slli	a4,a4,0x4
 85a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 85c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 860:	00000717          	auipc	a4,0x0
 864:	7aa73023          	sd	a0,1952(a4) # 1000 <freep>
      return (void*)(p + 1);
 868:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 86c:	70e2                	ld	ra,56(sp)
 86e:	7442                	ld	s0,48(sp)
 870:	74a2                	ld	s1,40(sp)
 872:	7902                	ld	s2,32(sp)
 874:	69e2                	ld	s3,24(sp)
 876:	6a42                	ld	s4,16(sp)
 878:	6aa2                	ld	s5,8(sp)
 87a:	6b02                	ld	s6,0(sp)
 87c:	6121                	addi	sp,sp,64
 87e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 880:	6398                	ld	a4,0(a5)
 882:	e118                	sd	a4,0(a0)
 884:	bff1                	j	860 <malloc+0x86>
  hp->s.size = nu;
 886:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 88a:	0541                	addi	a0,a0,16
 88c:	00000097          	auipc	ra,0x0
 890:	ec6080e7          	jalr	-314(ra) # 752 <free>
  return freep;
 894:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 898:	d971                	beqz	a0,86c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89c:	4798                	lw	a4,8(a5)
 89e:	fa9776e3          	bgeu	a4,s1,84a <malloc+0x70>
    if(p == freep)
 8a2:	00093703          	ld	a4,0(s2)
 8a6:	853e                	mv	a0,a5
 8a8:	fef719e3          	bne	a4,a5,89a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8ac:	8552                	mv	a0,s4
 8ae:	00000097          	auipc	ra,0x0
 8b2:	b5e080e7          	jalr	-1186(ra) # 40c <sbrk>
  if(p == (char*)-1)
 8b6:	fd5518e3          	bne	a0,s5,886 <malloc+0xac>
        return 0;
 8ba:	4501                	li	a0,0
 8bc:	bf45                	j	86c <malloc+0x92>

00000000000008be <tournament_create>:
    l++;
  }
  return l;
}

int tournament_create(int processes) {
 8be:	7179                	addi	sp,sp,-48
 8c0:	f406                	sd	ra,40(sp)
 8c2:	f022                	sd	s0,32(sp)
 8c4:	ec26                	sd	s1,24(sp)
 8c6:	e84a                	sd	s2,16(sp)
 8c8:	e44e                	sd	s3,8(sp)
 8ca:	e052                	sd	s4,0(sp)
 8cc:	1800                	addi	s0,sp,48
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 8ce:	fff5071b          	addiw	a4,a0,-1
 8d2:	47bd                	li	a5,15
 8d4:	00e7ee63          	bltu	a5,a4,8f0 <tournament_create+0x32>
 8d8:	89aa                	mv	s3,a0
    return x > 0 && (x & (x - 1)) == 0;
 8da:	8a3a                	mv	s4,a4
 8dc:	00e574b3          	and	s1,a0,a4
 8e0:	c0b9                	beqz	s1,926 <tournament_create+0x68>
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 8e2:	54fd                	li	s1,-1
 8e4:	a809                	j	8f6 <tournament_create+0x38>
   for(int i = 1; i < processes  ; i++){
        int pid = fork() ;
        if(pid < 0)
            return -1 ;
        if(pid == 0){
            trnmnt_idx = i ;
 8e6:	00000797          	auipc	a5,0x0
 8ea:	7297a123          	sw	s1,1826(a5) # 1008 <trnmnt_idx>
            return trnmnt_idx ;
 8ee:	a021                	j	8f6 <tournament_create+0x38>
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 8f0:	54fd                	li	s1,-1
 8f2:	a011                	j	8f6 <tournament_create+0x38>
        return -1; //failed to create lock
 8f4:	54fd                	li	s1,-1
        }
   }
return trnmnt_idx ;
}
 8f6:	8526                	mv	a0,s1
 8f8:	70a2                	ld	ra,40(sp)
 8fa:	7402                	ld	s0,32(sp)
 8fc:	64e2                	ld	s1,24(sp)
 8fe:	6942                	ld	s2,16(sp)
 900:	69a2                	ld	s3,8(sp)
 902:	6a02                	ld	s4,0(sp)
 904:	6145                	addi	sp,sp,48
 906:	8082                	ret
            return -1 ;
 908:	54fd                	li	s1,-1
 90a:	b7f5                	j	8f6 <tournament_create+0x38>
   num_levels = log2(processes) ;
 90c:	00000797          	auipc	a5,0x0
 910:	7007a223          	sw	zero,1796(a5) # 1010 <num_levels>
   trnmnt_idx = 0;
 914:	00000797          	auipc	a5,0x0
 918:	6e07aa23          	sw	zero,1780(a5) # 1008 <trnmnt_idx>
return trnmnt_idx ;
 91c:	00000497          	auipc	s1,0x0
 920:	6ec4a483          	lw	s1,1772(s1) # 1008 <trnmnt_idx>
 924:	bfc9                	j	8f6 <tournament_create+0x38>
   num_processes = processes ;
 926:	00000797          	auipc	a5,0x0
 92a:	6ea7a323          	sw	a0,1766(a5) # 100c <num_processes>
  if (n <= 1) 
 92e:	4785                	li	a5,1
 930:	fca7dee3          	bge	a5,a0,90c <tournament_create+0x4e>
  int l = 0;
 934:	8726                	mv	a4,s1
 936:	87aa                	mv	a5,a0
  while (n > 1) {
 938:	458d                	li	a1,3
    n /= 2;
 93a:	86be                	mv	a3,a5
 93c:	01f7d61b          	srliw	a2,a5,0x1f
 940:	9fb1                	addw	a5,a5,a2
 942:	4017d79b          	sraiw	a5,a5,0x1
    l++;
 946:	2705                	addiw	a4,a4,1
  while (n > 1) {
 948:	fed5c9e3          	blt	a1,a3,93a <tournament_create+0x7c>
   num_levels = log2(processes) ;
 94c:	00000797          	auipc	a5,0x0
 950:	6ce7a223          	sw	a4,1732(a5) # 1010 <num_levels>
   for(int i = 0; i < processes -1 ; i++){
 954:	00000917          	auipc	s2,0x0
 958:	6dc90913          	addi	s2,s2,1756 # 1030 <lock_ids>
    lock_ids[i]= peterson_create() ;
 95c:	00000097          	auipc	ra,0x0
 960:	ac8080e7          	jalr	-1336(ra) # 424 <peterson_create>
 964:	00a92023          	sw	a0,0(s2)
    if(lock_ids[i] <0){
 968:	f80546e3          	bltz	a0,8f4 <tournament_create+0x36>
   for(int i = 0; i < processes -1 ; i++){
 96c:	2485                	addiw	s1,s1,1
 96e:	0911                	addi	s2,s2,4
 970:	ff44c6e3          	blt	s1,s4,95c <tournament_create+0x9e>
   trnmnt_idx = 0;
 974:	00000797          	auipc	a5,0x0
 978:	6807aa23          	sw	zero,1684(a5) # 1008 <trnmnt_idx>
   for(int i = 1; i < processes  ; i++){
 97c:	4785                	li	a5,1
 97e:	f937dfe3          	bge	a5,s3,91c <tournament_create+0x5e>
 982:	4485                	li	s1,1
        int pid = fork() ;
 984:	00000097          	auipc	ra,0x0
 988:	9f8080e7          	jalr	-1544(ra) # 37c <fork>
        if(pid < 0)
 98c:	f6054ee3          	bltz	a0,908 <tournament_create+0x4a>
        if(pid == 0){
 990:	d939                	beqz	a0,8e6 <tournament_create+0x28>
   for(int i = 1; i < processes  ; i++){
 992:	2485                	addiw	s1,s1,1
 994:	fe9998e3          	bne	s3,s1,984 <tournament_create+0xc6>
 998:	b751                	j	91c <tournament_create+0x5e>

000000000000099a <tournament_acquire>:

int tournament_acquire(void){ 

    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 99a:	00000797          	auipc	a5,0x0
 99e:	66e7a783          	lw	a5,1646(a5) # 1008 <trnmnt_idx>
 9a2:	0a07cd63          	bltz	a5,a5c <tournament_acquire+0xc2>
 9a6:	00000717          	auipc	a4,0x0
 9aa:	66a72703          	lw	a4,1642(a4) # 1010 <num_levels>
 9ae:	0ae05963          	blez	a4,a60 <tournament_acquire+0xc6>

    for(int lvl = 0 ; lvl < num_levels ; lvl++){
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 9b2:	fff7069b          	addiw	a3,a4,-1
 9b6:	4585                	li	a1,1
 9b8:	00d595bb          	sllw	a1,a1,a3
 9bc:	8dfd                	and	a1,a1,a5
 9be:	40d5d5bb          	sraw	a1,a1,a3
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 9c2:	40e7d7bb          	sraw	a5,a5,a4
        int lockidx = lockl + (1<<lvl) -1 ;
        if(lockidx>=MAX_LOCKS) return -1 ;
 9c6:	4739                	li	a4,14
 9c8:	08f74e63          	blt	a4,a5,a64 <tournament_acquire+0xca>
int tournament_acquire(void){ 
 9cc:	7139                	addi	sp,sp,-64
 9ce:	fc06                	sd	ra,56(sp)
 9d0:	f822                	sd	s0,48(sp)
 9d2:	f426                	sd	s1,40(sp)
 9d4:	f04a                	sd	s2,32(sp)
 9d6:	ec4e                	sd	s3,24(sp)
 9d8:	e852                	sd	s4,16(sp)
 9da:	e456                	sd	s5,8(sp)
 9dc:	e05a                	sd	s6,0(sp)
 9de:	0080                	addi	s0,sp,64
    for(int lvl = 0 ; lvl < num_levels ; lvl++){
 9e0:	4481                	li	s1,0

        peterson_acquire(lock_ids[lockidx] , role) ;
 9e2:	00000a17          	auipc	s4,0x0
 9e6:	64ea0a13          	addi	s4,s4,1614 # 1030 <lock_ids>
    for(int lvl = 0 ; lvl < num_levels ; lvl++){
 9ea:	00000997          	auipc	s3,0x0
 9ee:	62698993          	addi	s3,s3,1574 # 1010 <num_levels>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 9f2:	00000b17          	auipc	s6,0x0
 9f6:	616b0b13          	addi	s6,s6,1558 # 1008 <trnmnt_idx>
 9fa:	4905                	li	s2,1
        if(lockidx>=MAX_LOCKS) return -1 ;
 9fc:	4ab9                	li	s5,14
        peterson_acquire(lock_ids[lockidx] , role) ;
 9fe:	078a                	slli	a5,a5,0x2
 a00:	97d2                	add	a5,a5,s4
 a02:	4388                	lw	a0,0(a5)
 a04:	00000097          	auipc	ra,0x0
 a08:	a28080e7          	jalr	-1496(ra) # 42c <peterson_acquire>
    for(int lvl = 0 ; lvl < num_levels ; lvl++){
 a0c:	0014871b          	addiw	a4,s1,1
 a10:	0007049b          	sext.w	s1,a4
 a14:	0009a783          	lw	a5,0(s3)
 a18:	02f4d763          	bge	s1,a5,a46 <tournament_acquire+0xac>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 a1c:	40e7873b          	subw	a4,a5,a4
 a20:	fff7079b          	addiw	a5,a4,-1
 a24:	000b2683          	lw	a3,0(s6)
 a28:	00f915bb          	sllw	a1,s2,a5
 a2c:	8df5                	and	a1,a1,a3
 a2e:	40f5d5bb          	sraw	a1,a1,a5
        int lockidx = lockl + (1<<lvl) -1 ;
 a32:	009917bb          	sllw	a5,s2,s1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 a36:	40e6d73b          	sraw	a4,a3,a4
        int lockidx = lockl + (1<<lvl) -1 ;
 a3a:	9fb9                	addw	a5,a5,a4
 a3c:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 a3e:	fcfad0e3          	bge	s5,a5,9fe <tournament_acquire+0x64>
 a42:	557d                	li	a0,-1
 a44:	a011                	j	a48 <tournament_acquire+0xae>

    }
return 0 ;
 a46:	4501                	li	a0,0
}
 a48:	70e2                	ld	ra,56(sp)
 a4a:	7442                	ld	s0,48(sp)
 a4c:	74a2                	ld	s1,40(sp)
 a4e:	7902                	ld	s2,32(sp)
 a50:	69e2                	ld	s3,24(sp)
 a52:	6a42                	ld	s4,16(sp)
 a54:	6aa2                	ld	s5,8(sp)
 a56:	6b02                	ld	s6,0(sp)
 a58:	6121                	addi	sp,sp,64
 a5a:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 a5c:	557d                	li	a0,-1
 a5e:	8082                	ret
 a60:	557d                	li	a0,-1
 a62:	8082                	ret
        if(lockidx>=MAX_LOCKS) return -1 ;
 a64:	557d                	li	a0,-1
}
 a66:	8082                	ret

0000000000000a68 <tournament_release>:

int tournament_release(void) {

    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 a68:	00000797          	auipc	a5,0x0
 a6c:	5a07a783          	lw	a5,1440(a5) # 1008 <trnmnt_idx>
 a70:	0a07cf63          	bltz	a5,b2e <tournament_release+0xc6>
int tournament_release(void) {
 a74:	715d                	addi	sp,sp,-80
 a76:	e486                	sd	ra,72(sp)
 a78:	e0a2                	sd	s0,64(sp)
 a7a:	fc26                	sd	s1,56(sp)
 a7c:	f84a                	sd	s2,48(sp)
 a7e:	f44e                	sd	s3,40(sp)
 a80:	f052                	sd	s4,32(sp)
 a82:	ec56                	sd	s5,24(sp)
 a84:	e85a                	sd	s6,16(sp)
 a86:	e45e                	sd	s7,8(sp)
 a88:	0880                	addi	s0,sp,80
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 a8a:	00000497          	auipc	s1,0x0
 a8e:	5864a483          	lw	s1,1414(s1) # 1010 <num_levels>
 a92:	0a905063          	blez	s1,b32 <tournament_release+0xca>

    for(int lvl = num_levels -1 ; lvl >=0  ; lvl--){
 a96:	34fd                	addiw	s1,s1,-1
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 a98:	0017f593          	andi	a1,a5,1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 a9c:	4017d79b          	sraiw	a5,a5,0x1
        int lockidx = lockl + (1<<lvl) -1 ;
 aa0:	4705                	li	a4,1
 aa2:	0097173b          	sllw	a4,a4,s1
 aa6:	9fb9                	addw	a5,a5,a4
 aa8:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 aaa:	4739                	li	a4,14
 aac:	08f74563          	blt	a4,a5,b36 <tournament_release+0xce>

        peterson_release(lock_ids[lockidx] , role) ;
 ab0:	00000a17          	auipc	s4,0x0
 ab4:	580a0a13          	addi	s4,s4,1408 # 1030 <lock_ids>
    for(int lvl = num_levels -1 ; lvl >=0  ; lvl--){
 ab8:	59fd                	li	s3,-1
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 aba:	00000b97          	auipc	s7,0x0
 abe:	556b8b93          	addi	s7,s7,1366 # 1010 <num_levels>
 ac2:	00000b17          	auipc	s6,0x0
 ac6:	546b0b13          	addi	s6,s6,1350 # 1008 <trnmnt_idx>
 aca:	4905                	li	s2,1
        if(lockidx>=MAX_LOCKS) return -1 ;
 acc:	4ab9                	li	s5,14
        peterson_release(lock_ids[lockidx] , role) ;
 ace:	078a                	slli	a5,a5,0x2
 ad0:	97d2                	add	a5,a5,s4
 ad2:	4388                	lw	a0,0(a5)
 ad4:	00000097          	auipc	ra,0x0
 ad8:	960080e7          	jalr	-1696(ra) # 434 <peterson_release>
    for(int lvl = num_levels -1 ; lvl >=0  ; lvl--){
 adc:	fff4869b          	addiw	a3,s1,-1
 ae0:	0006849b          	sext.w	s1,a3
 ae4:	03348963          	beq	s1,s3,b16 <tournament_release+0xae>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 ae8:	000ba703          	lw	a4,0(s7)
 aec:	40d706bb          	subw	a3,a4,a3
 af0:	fff6879b          	addiw	a5,a3,-1
 af4:	000b2703          	lw	a4,0(s6)
 af8:	00f915bb          	sllw	a1,s2,a5
 afc:	8df9                	and	a1,a1,a4
 afe:	40f5d5bb          	sraw	a1,a1,a5
        int lockidx = lockl + (1<<lvl) -1 ;
 b02:	009917bb          	sllw	a5,s2,s1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 b06:	40d7573b          	sraw	a4,a4,a3
        int lockidx = lockl + (1<<lvl) -1 ;
 b0a:	9fb9                	addw	a5,a5,a4
 b0c:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 b0e:	fcfad0e3          	bge	s5,a5,ace <tournament_release+0x66>
 b12:	557d                	li	a0,-1
 b14:	a011                	j	b18 <tournament_release+0xb0>

    }
return 0 ;
 b16:	4501                	li	a0,0


}
 b18:	60a6                	ld	ra,72(sp)
 b1a:	6406                	ld	s0,64(sp)
 b1c:	74e2                	ld	s1,56(sp)
 b1e:	7942                	ld	s2,48(sp)
 b20:	79a2                	ld	s3,40(sp)
 b22:	7a02                	ld	s4,32(sp)
 b24:	6ae2                	ld	s5,24(sp)
 b26:	6b42                	ld	s6,16(sp)
 b28:	6ba2                	ld	s7,8(sp)
 b2a:	6161                	addi	sp,sp,80
 b2c:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 b2e:	557d                	li	a0,-1
}
 b30:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 b32:	557d                	li	a0,-1
 b34:	b7d5                	j	b18 <tournament_release+0xb0>
        if(lockidx>=MAX_LOCKS) return -1 ;
 b36:	557d                	li	a0,-1
 b38:	b7c5                	j	b18 <tournament_release+0xb0>
