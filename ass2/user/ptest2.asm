
user/_ptest2:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main() {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
    int lockid = peterson_create();
  12:	00000097          	auipc	ra,0x0
  16:	42a080e7          	jalr	1066(ra) # 43c <peterson_create>
    if (lockid < 0) {
  1a:	06054263          	bltz	a0,7e <main+0x7e>
  1e:	892a                	mv	s2,a0
        printf("Failed to create Peterson lock\n");
        exit(1);
    }

    int *shared_counter = (int *) malloc(sizeof(int));
  20:	4511                	li	a0,4
  22:	00000097          	auipc	ra,0x0
  26:	7d0080e7          	jalr	2000(ra) # 7f2 <malloc>
  2a:	89aa                	mv	s3,a0
    *shared_counter = 0;
  2c:	00052023          	sw	zero,0(a0)

    int pid = fork();
  30:	00000097          	auipc	ra,0x0
  34:	364080e7          	jalr	868(ra) # 394 <fork>
  38:	8aaa                	mv	s5,a0

    // We assign roles: parent = 0, child = 1
    int turn = (pid == 0) ? 1 : 0;
  3a:	00153a13          	seqz	s4,a0
  3e:	3e800493          	li	s1,1000

    for (int i = 0; i < 1000; i++) {
        if (peterson_acquire(lockid, turn) < 0) {
  42:	85d2                	mv	a1,s4
  44:	854a                	mv	a0,s2
  46:	00000097          	auipc	ra,0x0
  4a:	3fe080e7          	jalr	1022(ra) # 444 <peterson_acquire>
  4e:	04054563          	bltz	a0,98 <main+0x98>
            printf("Process %d failed to acquire lock\n", getpid());
            exit(1);
        }

        // Critical section
        int temp = *shared_counter;
  52:	0009a783          	lw	a5,0(s3)
        temp++;
  56:	2785                	addiw	a5,a5,1
        *shared_counter = temp;
  58:	00f9a023          	sw	a5,0(s3)

        if (peterson_release(lockid, turn) < 0) {
  5c:	85d2                	mv	a1,s4
  5e:	854a                	mv	a0,s2
  60:	00000097          	auipc	ra,0x0
  64:	3ec080e7          	jalr	1004(ra) # 44c <peterson_release>
  68:	04054a63          	bltz	a0,bc <main+0xbc>
    for (int i = 0; i < 1000; i++) {
  6c:	34fd                	addiw	s1,s1,-1
  6e:	f8f1                	bnez	s1,42 <main+0x42>
            printf("Process %d failed to release lock\n", getpid());
            exit(1);
        }
    }

    if (pid != 0) {
  70:	060a9863          	bnez	s5,e0 <main+0xe0>
        printf("Final value of shared_counter: %d\n", *shared_counter);
        peterson_destroy(lockid);
        free(shared_counter);
    }

    exit(0);
  74:	4501                	li	a0,0
  76:	00000097          	auipc	ra,0x0
  7a:	326080e7          	jalr	806(ra) # 39c <exit>
        printf("Failed to create Peterson lock\n");
  7e:	00001517          	auipc	a0,0x1
  82:	ae250513          	addi	a0,a0,-1310 # b60 <tournament_release+0xe0>
  86:	00000097          	auipc	ra,0x0
  8a:	6ae080e7          	jalr	1710(ra) # 734 <printf>
        exit(1);
  8e:	4505                	li	a0,1
  90:	00000097          	auipc	ra,0x0
  94:	30c080e7          	jalr	780(ra) # 39c <exit>
            printf("Process %d failed to acquire lock\n", getpid());
  98:	00000097          	auipc	ra,0x0
  9c:	384080e7          	jalr	900(ra) # 41c <getpid>
  a0:	85aa                	mv	a1,a0
  a2:	00001517          	auipc	a0,0x1
  a6:	ade50513          	addi	a0,a0,-1314 # b80 <tournament_release+0x100>
  aa:	00000097          	auipc	ra,0x0
  ae:	68a080e7          	jalr	1674(ra) # 734 <printf>
            exit(1);
  b2:	4505                	li	a0,1
  b4:	00000097          	auipc	ra,0x0
  b8:	2e8080e7          	jalr	744(ra) # 39c <exit>
            printf("Process %d failed to release lock\n", getpid());
  bc:	00000097          	auipc	ra,0x0
  c0:	360080e7          	jalr	864(ra) # 41c <getpid>
  c4:	85aa                	mv	a1,a0
  c6:	00001517          	auipc	a0,0x1
  ca:	ae250513          	addi	a0,a0,-1310 # ba8 <tournament_release+0x128>
  ce:	00000097          	auipc	ra,0x0
  d2:	666080e7          	jalr	1638(ra) # 734 <printf>
            exit(1);
  d6:	4505                	li	a0,1
  d8:	00000097          	auipc	ra,0x0
  dc:	2c4080e7          	jalr	708(ra) # 39c <exit>
        wait(0);  // Parent waits for child
  e0:	4501                	li	a0,0
  e2:	00000097          	auipc	ra,0x0
  e6:	2c2080e7          	jalr	706(ra) # 3a4 <wait>
        printf("Final value of shared_counter: %d\n", *shared_counter);
  ea:	0009a583          	lw	a1,0(s3)
  ee:	00001517          	auipc	a0,0x1
  f2:	ae250513          	addi	a0,a0,-1310 # bd0 <tournament_release+0x150>
  f6:	00000097          	auipc	ra,0x0
  fa:	63e080e7          	jalr	1598(ra) # 734 <printf>
        peterson_destroy(lockid);
  fe:	854a                	mv	a0,s2
 100:	00000097          	auipc	ra,0x0
 104:	354080e7          	jalr	852(ra) # 454 <peterson_destroy>
        free(shared_counter);
 108:	854e                	mv	a0,s3
 10a:	00000097          	auipc	ra,0x0
 10e:	660080e7          	jalr	1632(ra) # 76a <free>
 112:	b78d                	j	74 <main+0x74>

0000000000000114 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 114:	1141                	addi	sp,sp,-16
 116:	e406                	sd	ra,8(sp)
 118:	e022                	sd	s0,0(sp)
 11a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 11c:	00000097          	auipc	ra,0x0
 120:	ee4080e7          	jalr	-284(ra) # 0 <main>
  exit(0);
 124:	4501                	li	a0,0
 126:	00000097          	auipc	ra,0x0
 12a:	276080e7          	jalr	630(ra) # 39c <exit>

000000000000012e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 12e:	1141                	addi	sp,sp,-16
 130:	e422                	sd	s0,8(sp)
 132:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 134:	87aa                	mv	a5,a0
 136:	0585                	addi	a1,a1,1
 138:	0785                	addi	a5,a5,1
 13a:	fff5c703          	lbu	a4,-1(a1)
 13e:	fee78fa3          	sb	a4,-1(a5)
 142:	fb75                	bnez	a4,136 <strcpy+0x8>
    ;
  return os;
}
 144:	6422                	ld	s0,8(sp)
 146:	0141                	addi	sp,sp,16
 148:	8082                	ret

000000000000014a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 14a:	1141                	addi	sp,sp,-16
 14c:	e422                	sd	s0,8(sp)
 14e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 150:	00054783          	lbu	a5,0(a0)
 154:	cb91                	beqz	a5,168 <strcmp+0x1e>
 156:	0005c703          	lbu	a4,0(a1)
 15a:	00f71763          	bne	a4,a5,168 <strcmp+0x1e>
    p++, q++;
 15e:	0505                	addi	a0,a0,1
 160:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 162:	00054783          	lbu	a5,0(a0)
 166:	fbe5                	bnez	a5,156 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 168:	0005c503          	lbu	a0,0(a1)
}
 16c:	40a7853b          	subw	a0,a5,a0
 170:	6422                	ld	s0,8(sp)
 172:	0141                	addi	sp,sp,16
 174:	8082                	ret

0000000000000176 <strlen>:

uint
strlen(const char *s)
{
 176:	1141                	addi	sp,sp,-16
 178:	e422                	sd	s0,8(sp)
 17a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 17c:	00054783          	lbu	a5,0(a0)
 180:	cf91                	beqz	a5,19c <strlen+0x26>
 182:	0505                	addi	a0,a0,1
 184:	87aa                	mv	a5,a0
 186:	4685                	li	a3,1
 188:	9e89                	subw	a3,a3,a0
 18a:	00f6853b          	addw	a0,a3,a5
 18e:	0785                	addi	a5,a5,1
 190:	fff7c703          	lbu	a4,-1(a5)
 194:	fb7d                	bnez	a4,18a <strlen+0x14>
    ;
  return n;
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	addi	sp,sp,16
 19a:	8082                	ret
  for(n = 0; s[n]; n++)
 19c:	4501                	li	a0,0
 19e:	bfe5                	j	196 <strlen+0x20>

00000000000001a0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1a6:	ca19                	beqz	a2,1bc <memset+0x1c>
 1a8:	87aa                	mv	a5,a0
 1aa:	1602                	slli	a2,a2,0x20
 1ac:	9201                	srli	a2,a2,0x20
 1ae:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1b2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1b6:	0785                	addi	a5,a5,1
 1b8:	fee79de3          	bne	a5,a4,1b2 <memset+0x12>
  }
  return dst;
}
 1bc:	6422                	ld	s0,8(sp)
 1be:	0141                	addi	sp,sp,16
 1c0:	8082                	ret

00000000000001c2 <strchr>:

char*
strchr(const char *s, char c)
{
 1c2:	1141                	addi	sp,sp,-16
 1c4:	e422                	sd	s0,8(sp)
 1c6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	cb99                	beqz	a5,1e2 <strchr+0x20>
    if(*s == c)
 1ce:	00f58763          	beq	a1,a5,1dc <strchr+0x1a>
  for(; *s; s++)
 1d2:	0505                	addi	a0,a0,1
 1d4:	00054783          	lbu	a5,0(a0)
 1d8:	fbfd                	bnez	a5,1ce <strchr+0xc>
      return (char*)s;
  return 0;
 1da:	4501                	li	a0,0
}
 1dc:	6422                	ld	s0,8(sp)
 1de:	0141                	addi	sp,sp,16
 1e0:	8082                	ret
  return 0;
 1e2:	4501                	li	a0,0
 1e4:	bfe5                	j	1dc <strchr+0x1a>

00000000000001e6 <gets>:

char*
gets(char *buf, int max)
{
 1e6:	711d                	addi	sp,sp,-96
 1e8:	ec86                	sd	ra,88(sp)
 1ea:	e8a2                	sd	s0,80(sp)
 1ec:	e4a6                	sd	s1,72(sp)
 1ee:	e0ca                	sd	s2,64(sp)
 1f0:	fc4e                	sd	s3,56(sp)
 1f2:	f852                	sd	s4,48(sp)
 1f4:	f456                	sd	s5,40(sp)
 1f6:	f05a                	sd	s6,32(sp)
 1f8:	ec5e                	sd	s7,24(sp)
 1fa:	1080                	addi	s0,sp,96
 1fc:	8baa                	mv	s7,a0
 1fe:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 200:	892a                	mv	s2,a0
 202:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 204:	4aa9                	li	s5,10
 206:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 208:	89a6                	mv	s3,s1
 20a:	2485                	addiw	s1,s1,1
 20c:	0344d863          	bge	s1,s4,23c <gets+0x56>
    cc = read(0, &c, 1);
 210:	4605                	li	a2,1
 212:	faf40593          	addi	a1,s0,-81
 216:	4501                	li	a0,0
 218:	00000097          	auipc	ra,0x0
 21c:	19c080e7          	jalr	412(ra) # 3b4 <read>
    if(cc < 1)
 220:	00a05e63          	blez	a0,23c <gets+0x56>
    buf[i++] = c;
 224:	faf44783          	lbu	a5,-81(s0)
 228:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 22c:	01578763          	beq	a5,s5,23a <gets+0x54>
 230:	0905                	addi	s2,s2,1
 232:	fd679be3          	bne	a5,s6,208 <gets+0x22>
  for(i=0; i+1 < max; ){
 236:	89a6                	mv	s3,s1
 238:	a011                	j	23c <gets+0x56>
 23a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 23c:	99de                	add	s3,s3,s7
 23e:	00098023          	sb	zero,0(s3)
  return buf;
}
 242:	855e                	mv	a0,s7
 244:	60e6                	ld	ra,88(sp)
 246:	6446                	ld	s0,80(sp)
 248:	64a6                	ld	s1,72(sp)
 24a:	6906                	ld	s2,64(sp)
 24c:	79e2                	ld	s3,56(sp)
 24e:	7a42                	ld	s4,48(sp)
 250:	7aa2                	ld	s5,40(sp)
 252:	7b02                	ld	s6,32(sp)
 254:	6be2                	ld	s7,24(sp)
 256:	6125                	addi	sp,sp,96
 258:	8082                	ret

000000000000025a <stat>:

int
stat(const char *n, struct stat *st)
{
 25a:	1101                	addi	sp,sp,-32
 25c:	ec06                	sd	ra,24(sp)
 25e:	e822                	sd	s0,16(sp)
 260:	e426                	sd	s1,8(sp)
 262:	e04a                	sd	s2,0(sp)
 264:	1000                	addi	s0,sp,32
 266:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 268:	4581                	li	a1,0
 26a:	00000097          	auipc	ra,0x0
 26e:	172080e7          	jalr	370(ra) # 3dc <open>
  if(fd < 0)
 272:	02054563          	bltz	a0,29c <stat+0x42>
 276:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 278:	85ca                	mv	a1,s2
 27a:	00000097          	auipc	ra,0x0
 27e:	17a080e7          	jalr	378(ra) # 3f4 <fstat>
 282:	892a                	mv	s2,a0
  close(fd);
 284:	8526                	mv	a0,s1
 286:	00000097          	auipc	ra,0x0
 28a:	13e080e7          	jalr	318(ra) # 3c4 <close>
  return r;
}
 28e:	854a                	mv	a0,s2
 290:	60e2                	ld	ra,24(sp)
 292:	6442                	ld	s0,16(sp)
 294:	64a2                	ld	s1,8(sp)
 296:	6902                	ld	s2,0(sp)
 298:	6105                	addi	sp,sp,32
 29a:	8082                	ret
    return -1;
 29c:	597d                	li	s2,-1
 29e:	bfc5                	j	28e <stat+0x34>

00000000000002a0 <atoi>:

int
atoi(const char *s)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2a6:	00054603          	lbu	a2,0(a0)
 2aa:	fd06079b          	addiw	a5,a2,-48
 2ae:	0ff7f793          	andi	a5,a5,255
 2b2:	4725                	li	a4,9
 2b4:	02f76963          	bltu	a4,a5,2e6 <atoi+0x46>
 2b8:	86aa                	mv	a3,a0
  n = 0;
 2ba:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2bc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2be:	0685                	addi	a3,a3,1
 2c0:	0025179b          	slliw	a5,a0,0x2
 2c4:	9fa9                	addw	a5,a5,a0
 2c6:	0017979b          	slliw	a5,a5,0x1
 2ca:	9fb1                	addw	a5,a5,a2
 2cc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2d0:	0006c603          	lbu	a2,0(a3)
 2d4:	fd06071b          	addiw	a4,a2,-48
 2d8:	0ff77713          	andi	a4,a4,255
 2dc:	fee5f1e3          	bgeu	a1,a4,2be <atoi+0x1e>
  return n;
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
  n = 0;
 2e6:	4501                	li	a0,0
 2e8:	bfe5                	j	2e0 <atoi+0x40>

00000000000002ea <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2f0:	02b57463          	bgeu	a0,a1,318 <memmove+0x2e>
    while(n-- > 0)
 2f4:	00c05f63          	blez	a2,312 <memmove+0x28>
 2f8:	1602                	slli	a2,a2,0x20
 2fa:	9201                	srli	a2,a2,0x20
 2fc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 300:	872a                	mv	a4,a0
      *dst++ = *src++;
 302:	0585                	addi	a1,a1,1
 304:	0705                	addi	a4,a4,1
 306:	fff5c683          	lbu	a3,-1(a1)
 30a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 30e:	fee79ae3          	bne	a5,a4,302 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 312:	6422                	ld	s0,8(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret
    dst += n;
 318:	00c50733          	add	a4,a0,a2
    src += n;
 31c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 31e:	fec05ae3          	blez	a2,312 <memmove+0x28>
 322:	fff6079b          	addiw	a5,a2,-1
 326:	1782                	slli	a5,a5,0x20
 328:	9381                	srli	a5,a5,0x20
 32a:	fff7c793          	not	a5,a5
 32e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 330:	15fd                	addi	a1,a1,-1
 332:	177d                	addi	a4,a4,-1
 334:	0005c683          	lbu	a3,0(a1)
 338:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 33c:	fee79ae3          	bne	a5,a4,330 <memmove+0x46>
 340:	bfc9                	j	312 <memmove+0x28>

0000000000000342 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 342:	1141                	addi	sp,sp,-16
 344:	e422                	sd	s0,8(sp)
 346:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 348:	ca05                	beqz	a2,378 <memcmp+0x36>
 34a:	fff6069b          	addiw	a3,a2,-1
 34e:	1682                	slli	a3,a3,0x20
 350:	9281                	srli	a3,a3,0x20
 352:	0685                	addi	a3,a3,1
 354:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 356:	00054783          	lbu	a5,0(a0)
 35a:	0005c703          	lbu	a4,0(a1)
 35e:	00e79863          	bne	a5,a4,36e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 362:	0505                	addi	a0,a0,1
    p2++;
 364:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 366:	fed518e3          	bne	a0,a3,356 <memcmp+0x14>
  }
  return 0;
 36a:	4501                	li	a0,0
 36c:	a019                	j	372 <memcmp+0x30>
      return *p1 - *p2;
 36e:	40e7853b          	subw	a0,a5,a4
}
 372:	6422                	ld	s0,8(sp)
 374:	0141                	addi	sp,sp,16
 376:	8082                	ret
  return 0;
 378:	4501                	li	a0,0
 37a:	bfe5                	j	372 <memcmp+0x30>

000000000000037c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 37c:	1141                	addi	sp,sp,-16
 37e:	e406                	sd	ra,8(sp)
 380:	e022                	sd	s0,0(sp)
 382:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 384:	00000097          	auipc	ra,0x0
 388:	f66080e7          	jalr	-154(ra) # 2ea <memmove>
}
 38c:	60a2                	ld	ra,8(sp)
 38e:	6402                	ld	s0,0(sp)
 390:	0141                	addi	sp,sp,16
 392:	8082                	ret

0000000000000394 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 394:	4885                	li	a7,1
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <exit>:
.global exit
exit:
 li a7, SYS_exit
 39c:	4889                	li	a7,2
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a4:	488d                	li	a7,3
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ac:	4891                	li	a7,4
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <read>:
.global read
read:
 li a7, SYS_read
 3b4:	4895                	li	a7,5
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <write>:
.global write
write:
 li a7, SYS_write
 3bc:	48c1                	li	a7,16
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <close>:
.global close
close:
 li a7, SYS_close
 3c4:	48d5                	li	a7,21
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3cc:	4899                	li	a7,6
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d4:	489d                	li	a7,7
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <open>:
.global open
open:
 li a7, SYS_open
 3dc:	48bd                	li	a7,15
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e4:	48c5                	li	a7,17
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ec:	48c9                	li	a7,18
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f4:	48a1                	li	a7,8
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <link>:
.global link
link:
 li a7, SYS_link
 3fc:	48cd                	li	a7,19
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 404:	48d1                	li	a7,20
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 40c:	48a5                	li	a7,9
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <dup>:
.global dup
dup:
 li a7, SYS_dup
 414:	48a9                	li	a7,10
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 41c:	48ad                	li	a7,11
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 424:	48b1                	li	a7,12
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 42c:	48b5                	li	a7,13
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 434:	48b9                	li	a7,14
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <peterson_create>:
.global peterson_create
peterson_create:
 li a7, SYS_peterson_create
 43c:	48d9                	li	a7,22
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <peterson_acquire>:
.global peterson_acquire
peterson_acquire:
 li a7, SYS_peterson_acquire
 444:	48dd                	li	a7,23
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <peterson_release>:
.global peterson_release
peterson_release:
 li a7, SYS_peterson_release
 44c:	48e1                	li	a7,24
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <peterson_destroy>:
.global peterson_destroy
peterson_destroy:
 li a7, SYS_peterson_destroy
 454:	48e5                	li	a7,25
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 45c:	1101                	addi	sp,sp,-32
 45e:	ec06                	sd	ra,24(sp)
 460:	e822                	sd	s0,16(sp)
 462:	1000                	addi	s0,sp,32
 464:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 468:	4605                	li	a2,1
 46a:	fef40593          	addi	a1,s0,-17
 46e:	00000097          	auipc	ra,0x0
 472:	f4e080e7          	jalr	-178(ra) # 3bc <write>
}
 476:	60e2                	ld	ra,24(sp)
 478:	6442                	ld	s0,16(sp)
 47a:	6105                	addi	sp,sp,32
 47c:	8082                	ret

000000000000047e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47e:	7139                	addi	sp,sp,-64
 480:	fc06                	sd	ra,56(sp)
 482:	f822                	sd	s0,48(sp)
 484:	f426                	sd	s1,40(sp)
 486:	f04a                	sd	s2,32(sp)
 488:	ec4e                	sd	s3,24(sp)
 48a:	0080                	addi	s0,sp,64
 48c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 48e:	c299                	beqz	a3,494 <printint+0x16>
 490:	0805c863          	bltz	a1,520 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 494:	2581                	sext.w	a1,a1
  neg = 0;
 496:	4881                	li	a7,0
 498:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 49c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 49e:	2601                	sext.w	a2,a2
 4a0:	00000517          	auipc	a0,0x0
 4a4:	76050513          	addi	a0,a0,1888 # c00 <digits>
 4a8:	883a                	mv	a6,a4
 4aa:	2705                	addiw	a4,a4,1
 4ac:	02c5f7bb          	remuw	a5,a1,a2
 4b0:	1782                	slli	a5,a5,0x20
 4b2:	9381                	srli	a5,a5,0x20
 4b4:	97aa                	add	a5,a5,a0
 4b6:	0007c783          	lbu	a5,0(a5)
 4ba:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4be:	0005879b          	sext.w	a5,a1
 4c2:	02c5d5bb          	divuw	a1,a1,a2
 4c6:	0685                	addi	a3,a3,1
 4c8:	fec7f0e3          	bgeu	a5,a2,4a8 <printint+0x2a>
  if(neg)
 4cc:	00088b63          	beqz	a7,4e2 <printint+0x64>
    buf[i++] = '-';
 4d0:	fd040793          	addi	a5,s0,-48
 4d4:	973e                	add	a4,a4,a5
 4d6:	02d00793          	li	a5,45
 4da:	fef70823          	sb	a5,-16(a4)
 4de:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4e2:	02e05863          	blez	a4,512 <printint+0x94>
 4e6:	fc040793          	addi	a5,s0,-64
 4ea:	00e78933          	add	s2,a5,a4
 4ee:	fff78993          	addi	s3,a5,-1
 4f2:	99ba                	add	s3,s3,a4
 4f4:	377d                	addiw	a4,a4,-1
 4f6:	1702                	slli	a4,a4,0x20
 4f8:	9301                	srli	a4,a4,0x20
 4fa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4fe:	fff94583          	lbu	a1,-1(s2)
 502:	8526                	mv	a0,s1
 504:	00000097          	auipc	ra,0x0
 508:	f58080e7          	jalr	-168(ra) # 45c <putc>
  while(--i >= 0)
 50c:	197d                	addi	s2,s2,-1
 50e:	ff3918e3          	bne	s2,s3,4fe <printint+0x80>
}
 512:	70e2                	ld	ra,56(sp)
 514:	7442                	ld	s0,48(sp)
 516:	74a2                	ld	s1,40(sp)
 518:	7902                	ld	s2,32(sp)
 51a:	69e2                	ld	s3,24(sp)
 51c:	6121                	addi	sp,sp,64
 51e:	8082                	ret
    x = -xx;
 520:	40b005bb          	negw	a1,a1
    neg = 1;
 524:	4885                	li	a7,1
    x = -xx;
 526:	bf8d                	j	498 <printint+0x1a>

0000000000000528 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 528:	7119                	addi	sp,sp,-128
 52a:	fc86                	sd	ra,120(sp)
 52c:	f8a2                	sd	s0,112(sp)
 52e:	f4a6                	sd	s1,104(sp)
 530:	f0ca                	sd	s2,96(sp)
 532:	ecce                	sd	s3,88(sp)
 534:	e8d2                	sd	s4,80(sp)
 536:	e4d6                	sd	s5,72(sp)
 538:	e0da                	sd	s6,64(sp)
 53a:	fc5e                	sd	s7,56(sp)
 53c:	f862                	sd	s8,48(sp)
 53e:	f466                	sd	s9,40(sp)
 540:	f06a                	sd	s10,32(sp)
 542:	ec6e                	sd	s11,24(sp)
 544:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 546:	0005c903          	lbu	s2,0(a1)
 54a:	18090f63          	beqz	s2,6e8 <vprintf+0x1c0>
 54e:	8aaa                	mv	s5,a0
 550:	8b32                	mv	s6,a2
 552:	00158493          	addi	s1,a1,1
  state = 0;
 556:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 558:	02500a13          	li	s4,37
      if(c == 'd'){
 55c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 560:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 564:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 568:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 56c:	00000b97          	auipc	s7,0x0
 570:	694b8b93          	addi	s7,s7,1684 # c00 <digits>
 574:	a839                	j	592 <vprintf+0x6a>
        putc(fd, c);
 576:	85ca                	mv	a1,s2
 578:	8556                	mv	a0,s5
 57a:	00000097          	auipc	ra,0x0
 57e:	ee2080e7          	jalr	-286(ra) # 45c <putc>
 582:	a019                	j	588 <vprintf+0x60>
    } else if(state == '%'){
 584:	01498f63          	beq	s3,s4,5a2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 588:	0485                	addi	s1,s1,1
 58a:	fff4c903          	lbu	s2,-1(s1)
 58e:	14090d63          	beqz	s2,6e8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 592:	0009079b          	sext.w	a5,s2
    if(state == 0){
 596:	fe0997e3          	bnez	s3,584 <vprintf+0x5c>
      if(c == '%'){
 59a:	fd479ee3          	bne	a5,s4,576 <vprintf+0x4e>
        state = '%';
 59e:	89be                	mv	s3,a5
 5a0:	b7e5                	j	588 <vprintf+0x60>
      if(c == 'd'){
 5a2:	05878063          	beq	a5,s8,5e2 <vprintf+0xba>
      } else if(c == 'l') {
 5a6:	05978c63          	beq	a5,s9,5fe <vprintf+0xd6>
      } else if(c == 'x') {
 5aa:	07a78863          	beq	a5,s10,61a <vprintf+0xf2>
      } else if(c == 'p') {
 5ae:	09b78463          	beq	a5,s11,636 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5b2:	07300713          	li	a4,115
 5b6:	0ce78663          	beq	a5,a4,682 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5ba:	06300713          	li	a4,99
 5be:	0ee78e63          	beq	a5,a4,6ba <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5c2:	11478863          	beq	a5,s4,6d2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5c6:	85d2                	mv	a1,s4
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	e92080e7          	jalr	-366(ra) # 45c <putc>
        putc(fd, c);
 5d2:	85ca                	mv	a1,s2
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	e86080e7          	jalr	-378(ra) # 45c <putc>
      }
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	b765                	j	588 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5e2:	008b0913          	addi	s2,s6,8
 5e6:	4685                	li	a3,1
 5e8:	4629                	li	a2,10
 5ea:	000b2583          	lw	a1,0(s6)
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	e8e080e7          	jalr	-370(ra) # 47e <printint>
 5f8:	8b4a                	mv	s6,s2
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	b771                	j	588 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fe:	008b0913          	addi	s2,s6,8
 602:	4681                	li	a3,0
 604:	4629                	li	a2,10
 606:	000b2583          	lw	a1,0(s6)
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	e72080e7          	jalr	-398(ra) # 47e <printint>
 614:	8b4a                	mv	s6,s2
      state = 0;
 616:	4981                	li	s3,0
 618:	bf85                	j	588 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 61a:	008b0913          	addi	s2,s6,8
 61e:	4681                	li	a3,0
 620:	4641                	li	a2,16
 622:	000b2583          	lw	a1,0(s6)
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	e56080e7          	jalr	-426(ra) # 47e <printint>
 630:	8b4a                	mv	s6,s2
      state = 0;
 632:	4981                	li	s3,0
 634:	bf91                	j	588 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 636:	008b0793          	addi	a5,s6,8
 63a:	f8f43423          	sd	a5,-120(s0)
 63e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 642:	03000593          	li	a1,48
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	e14080e7          	jalr	-492(ra) # 45c <putc>
  putc(fd, 'x');
 650:	85ea                	mv	a1,s10
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	e08080e7          	jalr	-504(ra) # 45c <putc>
 65c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65e:	03c9d793          	srli	a5,s3,0x3c
 662:	97de                	add	a5,a5,s7
 664:	0007c583          	lbu	a1,0(a5)
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	df2080e7          	jalr	-526(ra) # 45c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 672:	0992                	slli	s3,s3,0x4
 674:	397d                	addiw	s2,s2,-1
 676:	fe0914e3          	bnez	s2,65e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 67a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 67e:	4981                	li	s3,0
 680:	b721                	j	588 <vprintf+0x60>
        s = va_arg(ap, char*);
 682:	008b0993          	addi	s3,s6,8
 686:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 68a:	02090163          	beqz	s2,6ac <vprintf+0x184>
        while(*s != 0){
 68e:	00094583          	lbu	a1,0(s2)
 692:	c9a1                	beqz	a1,6e2 <vprintf+0x1ba>
          putc(fd, *s);
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	dc6080e7          	jalr	-570(ra) # 45c <putc>
          s++;
 69e:	0905                	addi	s2,s2,1
        while(*s != 0){
 6a0:	00094583          	lbu	a1,0(s2)
 6a4:	f9e5                	bnez	a1,694 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6a6:	8b4e                	mv	s6,s3
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	bdf9                	j	588 <vprintf+0x60>
          s = "(null)";
 6ac:	00000917          	auipc	s2,0x0
 6b0:	54c90913          	addi	s2,s2,1356 # bf8 <tournament_release+0x178>
        while(*s != 0){
 6b4:	02800593          	li	a1,40
 6b8:	bff1                	j	694 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6ba:	008b0913          	addi	s2,s6,8
 6be:	000b4583          	lbu	a1,0(s6)
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	d98080e7          	jalr	-616(ra) # 45c <putc>
 6cc:	8b4a                	mv	s6,s2
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	bd65                	j	588 <vprintf+0x60>
        putc(fd, c);
 6d2:	85d2                	mv	a1,s4
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	d86080e7          	jalr	-634(ra) # 45c <putc>
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	b565                	j	588 <vprintf+0x60>
        s = va_arg(ap, char*);
 6e2:	8b4e                	mv	s6,s3
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	b54d                	j	588 <vprintf+0x60>
    }
  }
}
 6e8:	70e6                	ld	ra,120(sp)
 6ea:	7446                	ld	s0,112(sp)
 6ec:	74a6                	ld	s1,104(sp)
 6ee:	7906                	ld	s2,96(sp)
 6f0:	69e6                	ld	s3,88(sp)
 6f2:	6a46                	ld	s4,80(sp)
 6f4:	6aa6                	ld	s5,72(sp)
 6f6:	6b06                	ld	s6,64(sp)
 6f8:	7be2                	ld	s7,56(sp)
 6fa:	7c42                	ld	s8,48(sp)
 6fc:	7ca2                	ld	s9,40(sp)
 6fe:	7d02                	ld	s10,32(sp)
 700:	6de2                	ld	s11,24(sp)
 702:	6109                	addi	sp,sp,128
 704:	8082                	ret

0000000000000706 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 706:	715d                	addi	sp,sp,-80
 708:	ec06                	sd	ra,24(sp)
 70a:	e822                	sd	s0,16(sp)
 70c:	1000                	addi	s0,sp,32
 70e:	e010                	sd	a2,0(s0)
 710:	e414                	sd	a3,8(s0)
 712:	e818                	sd	a4,16(s0)
 714:	ec1c                	sd	a5,24(s0)
 716:	03043023          	sd	a6,32(s0)
 71a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 71e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 722:	8622                	mv	a2,s0
 724:	00000097          	auipc	ra,0x0
 728:	e04080e7          	jalr	-508(ra) # 528 <vprintf>
}
 72c:	60e2                	ld	ra,24(sp)
 72e:	6442                	ld	s0,16(sp)
 730:	6161                	addi	sp,sp,80
 732:	8082                	ret

0000000000000734 <printf>:

void
printf(const char *fmt, ...)
{
 734:	711d                	addi	sp,sp,-96
 736:	ec06                	sd	ra,24(sp)
 738:	e822                	sd	s0,16(sp)
 73a:	1000                	addi	s0,sp,32
 73c:	e40c                	sd	a1,8(s0)
 73e:	e810                	sd	a2,16(s0)
 740:	ec14                	sd	a3,24(s0)
 742:	f018                	sd	a4,32(s0)
 744:	f41c                	sd	a5,40(s0)
 746:	03043823          	sd	a6,48(s0)
 74a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 74e:	00840613          	addi	a2,s0,8
 752:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 756:	85aa                	mv	a1,a0
 758:	4505                	li	a0,1
 75a:	00000097          	auipc	ra,0x0
 75e:	dce080e7          	jalr	-562(ra) # 528 <vprintf>
}
 762:	60e2                	ld	ra,24(sp)
 764:	6442                	ld	s0,16(sp)
 766:	6125                	addi	sp,sp,96
 768:	8082                	ret

000000000000076a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 76a:	1141                	addi	sp,sp,-16
 76c:	e422                	sd	s0,8(sp)
 76e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 770:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 774:	00001797          	auipc	a5,0x1
 778:	88c7b783          	ld	a5,-1908(a5) # 1000 <freep>
 77c:	a805                	j	7ac <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 77e:	4618                	lw	a4,8(a2)
 780:	9db9                	addw	a1,a1,a4
 782:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 786:	6398                	ld	a4,0(a5)
 788:	6318                	ld	a4,0(a4)
 78a:	fee53823          	sd	a4,-16(a0)
 78e:	a091                	j	7d2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 790:	ff852703          	lw	a4,-8(a0)
 794:	9e39                	addw	a2,a2,a4
 796:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 798:	ff053703          	ld	a4,-16(a0)
 79c:	e398                	sd	a4,0(a5)
 79e:	a099                	j	7e4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a0:	6398                	ld	a4,0(a5)
 7a2:	00e7e463          	bltu	a5,a4,7aa <free+0x40>
 7a6:	00e6ea63          	bltu	a3,a4,7ba <free+0x50>
{
 7aa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ac:	fed7fae3          	bgeu	a5,a3,7a0 <free+0x36>
 7b0:	6398                	ld	a4,0(a5)
 7b2:	00e6e463          	bltu	a3,a4,7ba <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b6:	fee7eae3          	bltu	a5,a4,7aa <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7ba:	ff852583          	lw	a1,-8(a0)
 7be:	6390                	ld	a2,0(a5)
 7c0:	02059713          	slli	a4,a1,0x20
 7c4:	9301                	srli	a4,a4,0x20
 7c6:	0712                	slli	a4,a4,0x4
 7c8:	9736                	add	a4,a4,a3
 7ca:	fae60ae3          	beq	a2,a4,77e <free+0x14>
    bp->s.ptr = p->s.ptr;
 7ce:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d2:	4790                	lw	a2,8(a5)
 7d4:	02061713          	slli	a4,a2,0x20
 7d8:	9301                	srli	a4,a4,0x20
 7da:	0712                	slli	a4,a4,0x4
 7dc:	973e                	add	a4,a4,a5
 7de:	fae689e3          	beq	a3,a4,790 <free+0x26>
  } else
    p->s.ptr = bp;
 7e2:	e394                	sd	a3,0(a5)
  freep = p;
 7e4:	00001717          	auipc	a4,0x1
 7e8:	80f73e23          	sd	a5,-2020(a4) # 1000 <freep>
}
 7ec:	6422                	ld	s0,8(sp)
 7ee:	0141                	addi	sp,sp,16
 7f0:	8082                	ret

00000000000007f2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f2:	7139                	addi	sp,sp,-64
 7f4:	fc06                	sd	ra,56(sp)
 7f6:	f822                	sd	s0,48(sp)
 7f8:	f426                	sd	s1,40(sp)
 7fa:	f04a                	sd	s2,32(sp)
 7fc:	ec4e                	sd	s3,24(sp)
 7fe:	e852                	sd	s4,16(sp)
 800:	e456                	sd	s5,8(sp)
 802:	e05a                	sd	s6,0(sp)
 804:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 806:	02051493          	slli	s1,a0,0x20
 80a:	9081                	srli	s1,s1,0x20
 80c:	04bd                	addi	s1,s1,15
 80e:	8091                	srli	s1,s1,0x4
 810:	0014899b          	addiw	s3,s1,1
 814:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 816:	00000517          	auipc	a0,0x0
 81a:	7ea53503          	ld	a0,2026(a0) # 1000 <freep>
 81e:	c515                	beqz	a0,84a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 820:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 822:	4798                	lw	a4,8(a5)
 824:	02977f63          	bgeu	a4,s1,862 <malloc+0x70>
 828:	8a4e                	mv	s4,s3
 82a:	0009871b          	sext.w	a4,s3
 82e:	6685                	lui	a3,0x1
 830:	00d77363          	bgeu	a4,a3,836 <malloc+0x44>
 834:	6a05                	lui	s4,0x1
 836:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 83a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 83e:	00000917          	auipc	s2,0x0
 842:	7c290913          	addi	s2,s2,1986 # 1000 <freep>
  if(p == (char*)-1)
 846:	5afd                	li	s5,-1
 848:	a88d                	j	8ba <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 84a:	00000797          	auipc	a5,0x0
 84e:	7d678793          	addi	a5,a5,2006 # 1020 <base>
 852:	00000717          	auipc	a4,0x0
 856:	7af73723          	sd	a5,1966(a4) # 1000 <freep>
 85a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 85c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 860:	b7e1                	j	828 <malloc+0x36>
      if(p->s.size == nunits)
 862:	02e48b63          	beq	s1,a4,898 <malloc+0xa6>
        p->s.size -= nunits;
 866:	4137073b          	subw	a4,a4,s3
 86a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 86c:	1702                	slli	a4,a4,0x20
 86e:	9301                	srli	a4,a4,0x20
 870:	0712                	slli	a4,a4,0x4
 872:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 874:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 878:	00000717          	auipc	a4,0x0
 87c:	78a73423          	sd	a0,1928(a4) # 1000 <freep>
      return (void*)(p + 1);
 880:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 884:	70e2                	ld	ra,56(sp)
 886:	7442                	ld	s0,48(sp)
 888:	74a2                	ld	s1,40(sp)
 88a:	7902                	ld	s2,32(sp)
 88c:	69e2                	ld	s3,24(sp)
 88e:	6a42                	ld	s4,16(sp)
 890:	6aa2                	ld	s5,8(sp)
 892:	6b02                	ld	s6,0(sp)
 894:	6121                	addi	sp,sp,64
 896:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 898:	6398                	ld	a4,0(a5)
 89a:	e118                	sd	a4,0(a0)
 89c:	bff1                	j	878 <malloc+0x86>
  hp->s.size = nu;
 89e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8a2:	0541                	addi	a0,a0,16
 8a4:	00000097          	auipc	ra,0x0
 8a8:	ec6080e7          	jalr	-314(ra) # 76a <free>
  return freep;
 8ac:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8b0:	d971                	beqz	a0,884 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b4:	4798                	lw	a4,8(a5)
 8b6:	fa9776e3          	bgeu	a4,s1,862 <malloc+0x70>
    if(p == freep)
 8ba:	00093703          	ld	a4,0(s2)
 8be:	853e                	mv	a0,a5
 8c0:	fef719e3          	bne	a4,a5,8b2 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8c4:	8552                	mv	a0,s4
 8c6:	00000097          	auipc	ra,0x0
 8ca:	b5e080e7          	jalr	-1186(ra) # 424 <sbrk>
  if(p == (char*)-1)
 8ce:	fd5518e3          	bne	a0,s5,89e <malloc+0xac>
        return 0;
 8d2:	4501                	li	a0,0
 8d4:	bf45                	j	884 <malloc+0x92>

00000000000008d6 <tournament_create>:
    l++;
  }
  return l;
}

int tournament_create(int processes) {
 8d6:	7179                	addi	sp,sp,-48
 8d8:	f406                	sd	ra,40(sp)
 8da:	f022                	sd	s0,32(sp)
 8dc:	ec26                	sd	s1,24(sp)
 8de:	e84a                	sd	s2,16(sp)
 8e0:	e44e                	sd	s3,8(sp)
 8e2:	e052                	sd	s4,0(sp)
 8e4:	1800                	addi	s0,sp,48
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 8e6:	fff5071b          	addiw	a4,a0,-1
 8ea:	47bd                	li	a5,15
 8ec:	00e7ee63          	bltu	a5,a4,908 <tournament_create+0x32>
 8f0:	89aa                	mv	s3,a0
    return x > 0 && (x & (x - 1)) == 0;
 8f2:	8a3a                	mv	s4,a4
 8f4:	00e574b3          	and	s1,a0,a4
 8f8:	c0b9                	beqz	s1,93e <tournament_create+0x68>
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 8fa:	54fd                	li	s1,-1
 8fc:	a809                	j	90e <tournament_create+0x38>
   for(int i = 1; i < processes  ; i++){
        int pid = fork() ;
        if(pid < 0)
            return -1 ;
        if(pid == 0){
            trnmnt_idx = i ;
 8fe:	00000797          	auipc	a5,0x0
 902:	7097a523          	sw	s1,1802(a5) # 1008 <trnmnt_idx>
            return trnmnt_idx ;
 906:	a021                	j	90e <tournament_create+0x38>
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 908:	54fd                	li	s1,-1
 90a:	a011                	j	90e <tournament_create+0x38>
        return -1; //failed to create lock
 90c:	54fd                	li	s1,-1
        }
   }
return trnmnt_idx ;
}
 90e:	8526                	mv	a0,s1
 910:	70a2                	ld	ra,40(sp)
 912:	7402                	ld	s0,32(sp)
 914:	64e2                	ld	s1,24(sp)
 916:	6942                	ld	s2,16(sp)
 918:	69a2                	ld	s3,8(sp)
 91a:	6a02                	ld	s4,0(sp)
 91c:	6145                	addi	sp,sp,48
 91e:	8082                	ret
            return -1 ;
 920:	54fd                	li	s1,-1
 922:	b7f5                	j	90e <tournament_create+0x38>
   num_levels = log2(processes) ;
 924:	00000797          	auipc	a5,0x0
 928:	6e07a623          	sw	zero,1772(a5) # 1010 <num_levels>
   trnmnt_idx = 0;
 92c:	00000797          	auipc	a5,0x0
 930:	6c07ae23          	sw	zero,1756(a5) # 1008 <trnmnt_idx>
return trnmnt_idx ;
 934:	00000497          	auipc	s1,0x0
 938:	6d44a483          	lw	s1,1748(s1) # 1008 <trnmnt_idx>
 93c:	bfc9                	j	90e <tournament_create+0x38>
   num_processes = processes ;
 93e:	00000797          	auipc	a5,0x0
 942:	6ca7a723          	sw	a0,1742(a5) # 100c <num_processes>
  if (n <= 1) 
 946:	4785                	li	a5,1
 948:	fca7dee3          	bge	a5,a0,924 <tournament_create+0x4e>
  int l = 0;
 94c:	8726                	mv	a4,s1
 94e:	87aa                	mv	a5,a0
  while (n > 1) {
 950:	458d                	li	a1,3
    n /= 2;
 952:	86be                	mv	a3,a5
 954:	01f7d61b          	srliw	a2,a5,0x1f
 958:	9fb1                	addw	a5,a5,a2
 95a:	4017d79b          	sraiw	a5,a5,0x1
    l++;
 95e:	2705                	addiw	a4,a4,1
  while (n > 1) {
 960:	fed5c9e3          	blt	a1,a3,952 <tournament_create+0x7c>
   num_levels = log2(processes) ;
 964:	00000797          	auipc	a5,0x0
 968:	6ae7a623          	sw	a4,1708(a5) # 1010 <num_levels>
   for(int i = 0; i < processes -1 ; i++){
 96c:	00000917          	auipc	s2,0x0
 970:	6c490913          	addi	s2,s2,1732 # 1030 <lock_ids>
    lock_ids[i]= peterson_create() ;
 974:	00000097          	auipc	ra,0x0
 978:	ac8080e7          	jalr	-1336(ra) # 43c <peterson_create>
 97c:	00a92023          	sw	a0,0(s2)
    if(lock_ids[i] <0){
 980:	f80546e3          	bltz	a0,90c <tournament_create+0x36>
   for(int i = 0; i < processes -1 ; i++){
 984:	2485                	addiw	s1,s1,1
 986:	0911                	addi	s2,s2,4
 988:	ff44c6e3          	blt	s1,s4,974 <tournament_create+0x9e>
   trnmnt_idx = 0;
 98c:	00000797          	auipc	a5,0x0
 990:	6607ae23          	sw	zero,1660(a5) # 1008 <trnmnt_idx>
   for(int i = 1; i < processes  ; i++){
 994:	4785                	li	a5,1
 996:	f937dfe3          	bge	a5,s3,934 <tournament_create+0x5e>
 99a:	4485                	li	s1,1
        int pid = fork() ;
 99c:	00000097          	auipc	ra,0x0
 9a0:	9f8080e7          	jalr	-1544(ra) # 394 <fork>
        if(pid < 0)
 9a4:	f6054ee3          	bltz	a0,920 <tournament_create+0x4a>
        if(pid == 0){
 9a8:	d939                	beqz	a0,8fe <tournament_create+0x28>
   for(int i = 1; i < processes  ; i++){
 9aa:	2485                	addiw	s1,s1,1
 9ac:	fe9998e3          	bne	s3,s1,99c <tournament_create+0xc6>
 9b0:	b751                	j	934 <tournament_create+0x5e>

00000000000009b2 <tournament_acquire>:

int tournament_acquire(void){ 

    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 9b2:	00000797          	auipc	a5,0x0
 9b6:	6567a783          	lw	a5,1622(a5) # 1008 <trnmnt_idx>
 9ba:	0a07cd63          	bltz	a5,a74 <tournament_acquire+0xc2>
 9be:	00000717          	auipc	a4,0x0
 9c2:	65272703          	lw	a4,1618(a4) # 1010 <num_levels>
 9c6:	0ae05963          	blez	a4,a78 <tournament_acquire+0xc6>

    for(int lvl = 0 ; lvl < num_levels ; lvl++){
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 9ca:	fff7069b          	addiw	a3,a4,-1
 9ce:	4585                	li	a1,1
 9d0:	00d595bb          	sllw	a1,a1,a3
 9d4:	8dfd                	and	a1,a1,a5
 9d6:	40d5d5bb          	sraw	a1,a1,a3
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 9da:	40e7d7bb          	sraw	a5,a5,a4
        int lockidx = lockl + (1<<lvl) -1 ;
        if(lockidx>=MAX_LOCKS) return -1 ;
 9de:	4739                	li	a4,14
 9e0:	08f74e63          	blt	a4,a5,a7c <tournament_acquire+0xca>
int tournament_acquire(void){ 
 9e4:	7139                	addi	sp,sp,-64
 9e6:	fc06                	sd	ra,56(sp)
 9e8:	f822                	sd	s0,48(sp)
 9ea:	f426                	sd	s1,40(sp)
 9ec:	f04a                	sd	s2,32(sp)
 9ee:	ec4e                	sd	s3,24(sp)
 9f0:	e852                	sd	s4,16(sp)
 9f2:	e456                	sd	s5,8(sp)
 9f4:	e05a                	sd	s6,0(sp)
 9f6:	0080                	addi	s0,sp,64
    for(int lvl = 0 ; lvl < num_levels ; lvl++){
 9f8:	4481                	li	s1,0

        peterson_acquire(lock_ids[lockidx] , role) ;
 9fa:	00000a17          	auipc	s4,0x0
 9fe:	636a0a13          	addi	s4,s4,1590 # 1030 <lock_ids>
    for(int lvl = 0 ; lvl < num_levels ; lvl++){
 a02:	00000997          	auipc	s3,0x0
 a06:	60e98993          	addi	s3,s3,1550 # 1010 <num_levels>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 a0a:	00000b17          	auipc	s6,0x0
 a0e:	5feb0b13          	addi	s6,s6,1534 # 1008 <trnmnt_idx>
 a12:	4905                	li	s2,1
        if(lockidx>=MAX_LOCKS) return -1 ;
 a14:	4ab9                	li	s5,14
        peterson_acquire(lock_ids[lockidx] , role) ;
 a16:	078a                	slli	a5,a5,0x2
 a18:	97d2                	add	a5,a5,s4
 a1a:	4388                	lw	a0,0(a5)
 a1c:	00000097          	auipc	ra,0x0
 a20:	a28080e7          	jalr	-1496(ra) # 444 <peterson_acquire>
    for(int lvl = 0 ; lvl < num_levels ; lvl++){
 a24:	0014871b          	addiw	a4,s1,1
 a28:	0007049b          	sext.w	s1,a4
 a2c:	0009a783          	lw	a5,0(s3)
 a30:	02f4d763          	bge	s1,a5,a5e <tournament_acquire+0xac>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 a34:	40e7873b          	subw	a4,a5,a4
 a38:	fff7079b          	addiw	a5,a4,-1
 a3c:	000b2683          	lw	a3,0(s6)
 a40:	00f915bb          	sllw	a1,s2,a5
 a44:	8df5                	and	a1,a1,a3
 a46:	40f5d5bb          	sraw	a1,a1,a5
        int lockidx = lockl + (1<<lvl) -1 ;
 a4a:	009917bb          	sllw	a5,s2,s1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 a4e:	40e6d73b          	sraw	a4,a3,a4
        int lockidx = lockl + (1<<lvl) -1 ;
 a52:	9fb9                	addw	a5,a5,a4
 a54:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 a56:	fcfad0e3          	bge	s5,a5,a16 <tournament_acquire+0x64>
 a5a:	557d                	li	a0,-1
 a5c:	a011                	j	a60 <tournament_acquire+0xae>

    }
return 0 ;
 a5e:	4501                	li	a0,0
}
 a60:	70e2                	ld	ra,56(sp)
 a62:	7442                	ld	s0,48(sp)
 a64:	74a2                	ld	s1,40(sp)
 a66:	7902                	ld	s2,32(sp)
 a68:	69e2                	ld	s3,24(sp)
 a6a:	6a42                	ld	s4,16(sp)
 a6c:	6aa2                	ld	s5,8(sp)
 a6e:	6b02                	ld	s6,0(sp)
 a70:	6121                	addi	sp,sp,64
 a72:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 a74:	557d                	li	a0,-1
 a76:	8082                	ret
 a78:	557d                	li	a0,-1
 a7a:	8082                	ret
        if(lockidx>=MAX_LOCKS) return -1 ;
 a7c:	557d                	li	a0,-1
}
 a7e:	8082                	ret

0000000000000a80 <tournament_release>:

int tournament_release(void) {

    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 a80:	00000797          	auipc	a5,0x0
 a84:	5887a783          	lw	a5,1416(a5) # 1008 <trnmnt_idx>
 a88:	0a07cf63          	bltz	a5,b46 <tournament_release+0xc6>
int tournament_release(void) {
 a8c:	715d                	addi	sp,sp,-80
 a8e:	e486                	sd	ra,72(sp)
 a90:	e0a2                	sd	s0,64(sp)
 a92:	fc26                	sd	s1,56(sp)
 a94:	f84a                	sd	s2,48(sp)
 a96:	f44e                	sd	s3,40(sp)
 a98:	f052                	sd	s4,32(sp)
 a9a:	ec56                	sd	s5,24(sp)
 a9c:	e85a                	sd	s6,16(sp)
 a9e:	e45e                	sd	s7,8(sp)
 aa0:	0880                	addi	s0,sp,80
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 aa2:	00000497          	auipc	s1,0x0
 aa6:	56e4a483          	lw	s1,1390(s1) # 1010 <num_levels>
 aaa:	0a905063          	blez	s1,b4a <tournament_release+0xca>

    for(int lvl = num_levels -1 ; lvl >=0  ; lvl--){
 aae:	34fd                	addiw	s1,s1,-1
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 ab0:	0017f593          	andi	a1,a5,1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 ab4:	4017d79b          	sraiw	a5,a5,0x1
        int lockidx = lockl + (1<<lvl) -1 ;
 ab8:	4705                	li	a4,1
 aba:	0097173b          	sllw	a4,a4,s1
 abe:	9fb9                	addw	a5,a5,a4
 ac0:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 ac2:	4739                	li	a4,14
 ac4:	08f74563          	blt	a4,a5,b4e <tournament_release+0xce>

        peterson_release(lock_ids[lockidx] , role) ;
 ac8:	00000a17          	auipc	s4,0x0
 acc:	568a0a13          	addi	s4,s4,1384 # 1030 <lock_ids>
    for(int lvl = num_levels -1 ; lvl >=0  ; lvl--){
 ad0:	59fd                	li	s3,-1
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 ad2:	00000b97          	auipc	s7,0x0
 ad6:	53eb8b93          	addi	s7,s7,1342 # 1010 <num_levels>
 ada:	00000b17          	auipc	s6,0x0
 ade:	52eb0b13          	addi	s6,s6,1326 # 1008 <trnmnt_idx>
 ae2:	4905                	li	s2,1
        if(lockidx>=MAX_LOCKS) return -1 ;
 ae4:	4ab9                	li	s5,14
        peterson_release(lock_ids[lockidx] , role) ;
 ae6:	078a                	slli	a5,a5,0x2
 ae8:	97d2                	add	a5,a5,s4
 aea:	4388                	lw	a0,0(a5)
 aec:	00000097          	auipc	ra,0x0
 af0:	960080e7          	jalr	-1696(ra) # 44c <peterson_release>
    for(int lvl = num_levels -1 ; lvl >=0  ; lvl--){
 af4:	fff4869b          	addiw	a3,s1,-1
 af8:	0006849b          	sext.w	s1,a3
 afc:	03348963          	beq	s1,s3,b2e <tournament_release+0xae>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 b00:	000ba703          	lw	a4,0(s7)
 b04:	40d706bb          	subw	a3,a4,a3
 b08:	fff6879b          	addiw	a5,a3,-1
 b0c:	000b2703          	lw	a4,0(s6)
 b10:	00f915bb          	sllw	a1,s2,a5
 b14:	8df9                	and	a1,a1,a4
 b16:	40f5d5bb          	sraw	a1,a1,a5
        int lockidx = lockl + (1<<lvl) -1 ;
 b1a:	009917bb          	sllw	a5,s2,s1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 b1e:	40d7573b          	sraw	a4,a4,a3
        int lockidx = lockl + (1<<lvl) -1 ;
 b22:	9fb9                	addw	a5,a5,a4
 b24:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 b26:	fcfad0e3          	bge	s5,a5,ae6 <tournament_release+0x66>
 b2a:	557d                	li	a0,-1
 b2c:	a011                	j	b30 <tournament_release+0xb0>

    }
return 0 ;
 b2e:	4501                	li	a0,0


}
 b30:	60a6                	ld	ra,72(sp)
 b32:	6406                	ld	s0,64(sp)
 b34:	74e2                	ld	s1,56(sp)
 b36:	7942                	ld	s2,48(sp)
 b38:	79a2                	ld	s3,40(sp)
 b3a:	7a02                	ld	s4,32(sp)
 b3c:	6ae2                	ld	s5,24(sp)
 b3e:	6b42                	ld	s6,16(sp)
 b40:	6ba2                	ld	s7,8(sp)
 b42:	6161                	addi	sp,sp,80
 b44:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 b46:	557d                	li	a0,-1
}
 b48:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 b4a:	557d                	li	a0,-1
 b4c:	b7d5                	j	b30 <tournament_release+0xb0>
        if(lockidx>=MAX_LOCKS) return -1 ;
 b4e:	557d                	li	a0,-1
 b50:	b7c5                	j	b30 <tournament_release+0xb0>
