
user/_petersontest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <petersontest>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void petersontest(void)
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	e05a                	sd	s6,0(sp)
  12:	0080                	addi	s0,sp,64
    int lock_id = peterson_create();
  14:	00000097          	auipc	ra,0x0
  18:	446080e7          	jalr	1094(ra) # 45a <peterson_create>
    if (lock_id < 0)
  1c:	02054563          	bltz	a0,46 <petersontest+0x46>
  20:	892a                	mv	s2,a0
    {
        printf("Failed to create lock\n");
        exit(1);
    }
    int fork_ret = fork();
  22:	00000097          	auipc	ra,0x0
  26:	390080e7          	jalr	912(ra) # 3b2 <fork>
  2a:	8a2a                	mv	s4,a0
    int role = fork_ret > 0 ? 0 : 1;
  2c:	00152993          	slti	s3,a0,1
  30:	06400493          	li	s1,100
        }
        // Critical section
        if (role == 0)
            printf("Parent process in critical section\n");
        else
            printf("Child process in critical section\n");
  34:	00001b17          	auipc	s6,0x1
  38:	9c4b0b13          	addi	s6,s6,-1596 # 9f8 <tournament_release+0x70>
            printf("Parent process in critical section\n");
  3c:	00001a97          	auipc	s5,0x1
  40:	994a8a93          	addi	s5,s5,-1644 # 9d0 <tournament_release+0x48>
  44:	a891                	j	98 <petersontest+0x98>
        printf("Failed to create lock\n");
  46:	00001517          	auipc	a0,0x1
  4a:	95a50513          	addi	a0,a0,-1702 # 9a0 <tournament_release+0x18>
  4e:	00000097          	auipc	ra,0x0
  52:	704080e7          	jalr	1796(ra) # 752 <printf>
        exit(1);
  56:	4505                	li	a0,1
  58:	00000097          	auipc	ra,0x0
  5c:	362080e7          	jalr	866(ra) # 3ba <exit>
            printf("Failed to acquire lock\n");
  60:	00001517          	auipc	a0,0x1
  64:	95850513          	addi	a0,a0,-1704 # 9b8 <tournament_release+0x30>
  68:	00000097          	auipc	ra,0x0
  6c:	6ea080e7          	jalr	1770(ra) # 752 <printf>
            exit(1);
  70:	4505                	li	a0,1
  72:	00000097          	auipc	ra,0x0
  76:	348080e7          	jalr	840(ra) # 3ba <exit>
            printf("Parent process in critical section\n");
  7a:	8556                	mv	a0,s5
  7c:	00000097          	auipc	ra,0x0
  80:	6d6080e7          	jalr	1750(ra) # 752 <printf>
        if (peterson_release(lock_id, role) < 0)
  84:	85ce                	mv	a1,s3
  86:	854a                	mv	a0,s2
  88:	00000097          	auipc	ra,0x0
  8c:	3e2080e7          	jalr	994(ra) # 46a <peterson_release>
  90:	02054463          	bltz	a0,b8 <petersontest+0xb8>
    for (int i = 0; i < 100; i++)
  94:	34fd                	addiw	s1,s1,-1
  96:	cc95                	beqz	s1,d2 <petersontest+0xd2>
        if (peterson_acquire(lock_id, role) < 0)
  98:	85ce                	mv	a1,s3
  9a:	854a                	mv	a0,s2
  9c:	00000097          	auipc	ra,0x0
  a0:	3c6080e7          	jalr	966(ra) # 462 <peterson_acquire>
  a4:	fa054ee3          	bltz	a0,60 <petersontest+0x60>
        if (role == 0)
  a8:	fd4049e3          	bgtz	s4,7a <petersontest+0x7a>
            printf("Child process in critical section\n");
  ac:	855a                	mv	a0,s6
  ae:	00000097          	auipc	ra,0x0
  b2:	6a4080e7          	jalr	1700(ra) # 752 <printf>
  b6:	b7f9                	j	84 <petersontest+0x84>
        {
            printf("Failed to release lock\n");
  b8:	00001517          	auipc	a0,0x1
  bc:	96850513          	addi	a0,a0,-1688 # a20 <tournament_release+0x98>
  c0:	00000097          	auipc	ra,0x0
  c4:	692080e7          	jalr	1682(ra) # 752 <printf>
            exit(1);
  c8:	4505                	li	a0,1
  ca:	00000097          	auipc	ra,0x0
  ce:	2f0080e7          	jalr	752(ra) # 3ba <exit>
        }
    }
    if (fork_ret > 0)
  d2:	03405663          	blez	s4,fe <petersontest+0xfe>
    {
        wait(0);
  d6:	4501                	li	a0,0
  d8:	00000097          	auipc	ra,0x0
  dc:	2ea080e7          	jalr	746(ra) # 3c2 <wait>
        printf("Parent process destroying lock\n");
  e0:	00001517          	auipc	a0,0x1
  e4:	95850513          	addi	a0,a0,-1704 # a38 <tournament_release+0xb0>
  e8:	00000097          	auipc	ra,0x0
  ec:	66a080e7          	jalr	1642(ra) # 752 <printf>
        if (peterson_destroy(lock_id) < 0)
  f0:	854a                	mv	a0,s2
  f2:	00000097          	auipc	ra,0x0
  f6:	380080e7          	jalr	896(ra) # 472 <peterson_destroy>
  fa:	00054763          	bltz	a0,108 <petersontest+0x108>
        {
            printf("Failed to destroy lock\n");
            exit(1);
        }
    }
    exit(0);
  fe:	4501                	li	a0,0
 100:	00000097          	auipc	ra,0x0
 104:	2ba080e7          	jalr	698(ra) # 3ba <exit>
            printf("Failed to destroy lock\n");
 108:	00001517          	auipc	a0,0x1
 10c:	95050513          	addi	a0,a0,-1712 # a58 <tournament_release+0xd0>
 110:	00000097          	auipc	ra,0x0
 114:	642080e7          	jalr	1602(ra) # 752 <printf>
            exit(1);
 118:	4505                	li	a0,1
 11a:	00000097          	auipc	ra,0x0
 11e:	2a0080e7          	jalr	672(ra) # 3ba <exit>

0000000000000122 <main>:
}

int main(void){
 122:	1141                	addi	sp,sp,-16
 124:	e406                	sd	ra,8(sp)
 126:	e022                	sd	s0,0(sp)
 128:	0800                	addi	s0,sp,16
    petersontest() ;
 12a:	00000097          	auipc	ra,0x0
 12e:	ed6080e7          	jalr	-298(ra) # 0 <petersontest>

0000000000000132 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 132:	1141                	addi	sp,sp,-16
 134:	e406                	sd	ra,8(sp)
 136:	e022                	sd	s0,0(sp)
 138:	0800                	addi	s0,sp,16
  extern int main();
  main();
 13a:	00000097          	auipc	ra,0x0
 13e:	fe8080e7          	jalr	-24(ra) # 122 <main>
  exit(0);
 142:	4501                	li	a0,0
 144:	00000097          	auipc	ra,0x0
 148:	276080e7          	jalr	630(ra) # 3ba <exit>

000000000000014c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 14c:	1141                	addi	sp,sp,-16
 14e:	e422                	sd	s0,8(sp)
 150:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 152:	87aa                	mv	a5,a0
 154:	0585                	addi	a1,a1,1
 156:	0785                	addi	a5,a5,1
 158:	fff5c703          	lbu	a4,-1(a1)
 15c:	fee78fa3          	sb	a4,-1(a5)
 160:	fb75                	bnez	a4,154 <strcpy+0x8>
    ;
  return os;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	addi	sp,sp,16
 166:	8082                	ret

0000000000000168 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 16e:	00054783          	lbu	a5,0(a0)
 172:	cb91                	beqz	a5,186 <strcmp+0x1e>
 174:	0005c703          	lbu	a4,0(a1)
 178:	00f71763          	bne	a4,a5,186 <strcmp+0x1e>
    p++, q++;
 17c:	0505                	addi	a0,a0,1
 17e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 180:	00054783          	lbu	a5,0(a0)
 184:	fbe5                	bnez	a5,174 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 186:	0005c503          	lbu	a0,0(a1)
}
 18a:	40a7853b          	subw	a0,a5,a0
 18e:	6422                	ld	s0,8(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret

0000000000000194 <strlen>:

uint
strlen(const char *s)
{
 194:	1141                	addi	sp,sp,-16
 196:	e422                	sd	s0,8(sp)
 198:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 19a:	00054783          	lbu	a5,0(a0)
 19e:	cf91                	beqz	a5,1ba <strlen+0x26>
 1a0:	0505                	addi	a0,a0,1
 1a2:	87aa                	mv	a5,a0
 1a4:	4685                	li	a3,1
 1a6:	9e89                	subw	a3,a3,a0
 1a8:	00f6853b          	addw	a0,a3,a5
 1ac:	0785                	addi	a5,a5,1
 1ae:	fff7c703          	lbu	a4,-1(a5)
 1b2:	fb7d                	bnez	a4,1a8 <strlen+0x14>
    ;
  return n;
}
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	addi	sp,sp,16
 1b8:	8082                	ret
  for(n = 0; s[n]; n++)
 1ba:	4501                	li	a0,0
 1bc:	bfe5                	j	1b4 <strlen+0x20>

00000000000001be <memset>:

void*
memset(void *dst, int c, uint n)
{
 1be:	1141                	addi	sp,sp,-16
 1c0:	e422                	sd	s0,8(sp)
 1c2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c4:	ca19                	beqz	a2,1da <memset+0x1c>
 1c6:	87aa                	mv	a5,a0
 1c8:	1602                	slli	a2,a2,0x20
 1ca:	9201                	srli	a2,a2,0x20
 1cc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1d0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1d4:	0785                	addi	a5,a5,1
 1d6:	fee79de3          	bne	a5,a4,1d0 <memset+0x12>
  }
  return dst;
}
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret

00000000000001e0 <strchr>:

char*
strchr(const char *s, char c)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e422                	sd	s0,8(sp)
 1e4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1e6:	00054783          	lbu	a5,0(a0)
 1ea:	cb99                	beqz	a5,200 <strchr+0x20>
    if(*s == c)
 1ec:	00f58763          	beq	a1,a5,1fa <strchr+0x1a>
  for(; *s; s++)
 1f0:	0505                	addi	a0,a0,1
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	fbfd                	bnez	a5,1ec <strchr+0xc>
      return (char*)s;
  return 0;
 1f8:	4501                	li	a0,0
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	addi	sp,sp,16
 1fe:	8082                	ret
  return 0;
 200:	4501                	li	a0,0
 202:	bfe5                	j	1fa <strchr+0x1a>

0000000000000204 <gets>:

char*
gets(char *buf, int max)
{
 204:	711d                	addi	sp,sp,-96
 206:	ec86                	sd	ra,88(sp)
 208:	e8a2                	sd	s0,80(sp)
 20a:	e4a6                	sd	s1,72(sp)
 20c:	e0ca                	sd	s2,64(sp)
 20e:	fc4e                	sd	s3,56(sp)
 210:	f852                	sd	s4,48(sp)
 212:	f456                	sd	s5,40(sp)
 214:	f05a                	sd	s6,32(sp)
 216:	ec5e                	sd	s7,24(sp)
 218:	1080                	addi	s0,sp,96
 21a:	8baa                	mv	s7,a0
 21c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21e:	892a                	mv	s2,a0
 220:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 222:	4aa9                	li	s5,10
 224:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 226:	89a6                	mv	s3,s1
 228:	2485                	addiw	s1,s1,1
 22a:	0344d863          	bge	s1,s4,25a <gets+0x56>
    cc = read(0, &c, 1);
 22e:	4605                	li	a2,1
 230:	faf40593          	addi	a1,s0,-81
 234:	4501                	li	a0,0
 236:	00000097          	auipc	ra,0x0
 23a:	19c080e7          	jalr	412(ra) # 3d2 <read>
    if(cc < 1)
 23e:	00a05e63          	blez	a0,25a <gets+0x56>
    buf[i++] = c;
 242:	faf44783          	lbu	a5,-81(s0)
 246:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 24a:	01578763          	beq	a5,s5,258 <gets+0x54>
 24e:	0905                	addi	s2,s2,1
 250:	fd679be3          	bne	a5,s6,226 <gets+0x22>
  for(i=0; i+1 < max; ){
 254:	89a6                	mv	s3,s1
 256:	a011                	j	25a <gets+0x56>
 258:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 25a:	99de                	add	s3,s3,s7
 25c:	00098023          	sb	zero,0(s3)
  return buf;
}
 260:	855e                	mv	a0,s7
 262:	60e6                	ld	ra,88(sp)
 264:	6446                	ld	s0,80(sp)
 266:	64a6                	ld	s1,72(sp)
 268:	6906                	ld	s2,64(sp)
 26a:	79e2                	ld	s3,56(sp)
 26c:	7a42                	ld	s4,48(sp)
 26e:	7aa2                	ld	s5,40(sp)
 270:	7b02                	ld	s6,32(sp)
 272:	6be2                	ld	s7,24(sp)
 274:	6125                	addi	sp,sp,96
 276:	8082                	ret

0000000000000278 <stat>:

int
stat(const char *n, struct stat *st)
{
 278:	1101                	addi	sp,sp,-32
 27a:	ec06                	sd	ra,24(sp)
 27c:	e822                	sd	s0,16(sp)
 27e:	e426                	sd	s1,8(sp)
 280:	e04a                	sd	s2,0(sp)
 282:	1000                	addi	s0,sp,32
 284:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 286:	4581                	li	a1,0
 288:	00000097          	auipc	ra,0x0
 28c:	172080e7          	jalr	370(ra) # 3fa <open>
  if(fd < 0)
 290:	02054563          	bltz	a0,2ba <stat+0x42>
 294:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 296:	85ca                	mv	a1,s2
 298:	00000097          	auipc	ra,0x0
 29c:	17a080e7          	jalr	378(ra) # 412 <fstat>
 2a0:	892a                	mv	s2,a0
  close(fd);
 2a2:	8526                	mv	a0,s1
 2a4:	00000097          	auipc	ra,0x0
 2a8:	13e080e7          	jalr	318(ra) # 3e2 <close>
  return r;
}
 2ac:	854a                	mv	a0,s2
 2ae:	60e2                	ld	ra,24(sp)
 2b0:	6442                	ld	s0,16(sp)
 2b2:	64a2                	ld	s1,8(sp)
 2b4:	6902                	ld	s2,0(sp)
 2b6:	6105                	addi	sp,sp,32
 2b8:	8082                	ret
    return -1;
 2ba:	597d                	li	s2,-1
 2bc:	bfc5                	j	2ac <stat+0x34>

00000000000002be <atoi>:

int
atoi(const char *s)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e422                	sd	s0,8(sp)
 2c2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c4:	00054603          	lbu	a2,0(a0)
 2c8:	fd06079b          	addiw	a5,a2,-48
 2cc:	0ff7f793          	andi	a5,a5,255
 2d0:	4725                	li	a4,9
 2d2:	02f76963          	bltu	a4,a5,304 <atoi+0x46>
 2d6:	86aa                	mv	a3,a0
  n = 0;
 2d8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2da:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2dc:	0685                	addi	a3,a3,1
 2de:	0025179b          	slliw	a5,a0,0x2
 2e2:	9fa9                	addw	a5,a5,a0
 2e4:	0017979b          	slliw	a5,a5,0x1
 2e8:	9fb1                	addw	a5,a5,a2
 2ea:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ee:	0006c603          	lbu	a2,0(a3)
 2f2:	fd06071b          	addiw	a4,a2,-48
 2f6:	0ff77713          	andi	a4,a4,255
 2fa:	fee5f1e3          	bgeu	a1,a4,2dc <atoi+0x1e>
  return n;
}
 2fe:	6422                	ld	s0,8(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret
  n = 0;
 304:	4501                	li	a0,0
 306:	bfe5                	j	2fe <atoi+0x40>

0000000000000308 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e422                	sd	s0,8(sp)
 30c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 30e:	02b57463          	bgeu	a0,a1,336 <memmove+0x2e>
    while(n-- > 0)
 312:	00c05f63          	blez	a2,330 <memmove+0x28>
 316:	1602                	slli	a2,a2,0x20
 318:	9201                	srli	a2,a2,0x20
 31a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 31e:	872a                	mv	a4,a0
      *dst++ = *src++;
 320:	0585                	addi	a1,a1,1
 322:	0705                	addi	a4,a4,1
 324:	fff5c683          	lbu	a3,-1(a1)
 328:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 32c:	fee79ae3          	bne	a5,a4,320 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 330:	6422                	ld	s0,8(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret
    dst += n;
 336:	00c50733          	add	a4,a0,a2
    src += n;
 33a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 33c:	fec05ae3          	blez	a2,330 <memmove+0x28>
 340:	fff6079b          	addiw	a5,a2,-1
 344:	1782                	slli	a5,a5,0x20
 346:	9381                	srli	a5,a5,0x20
 348:	fff7c793          	not	a5,a5
 34c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 34e:	15fd                	addi	a1,a1,-1
 350:	177d                	addi	a4,a4,-1
 352:	0005c683          	lbu	a3,0(a1)
 356:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 35a:	fee79ae3          	bne	a5,a4,34e <memmove+0x46>
 35e:	bfc9                	j	330 <memmove+0x28>

0000000000000360 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 360:	1141                	addi	sp,sp,-16
 362:	e422                	sd	s0,8(sp)
 364:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 366:	ca05                	beqz	a2,396 <memcmp+0x36>
 368:	fff6069b          	addiw	a3,a2,-1
 36c:	1682                	slli	a3,a3,0x20
 36e:	9281                	srli	a3,a3,0x20
 370:	0685                	addi	a3,a3,1
 372:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 374:	00054783          	lbu	a5,0(a0)
 378:	0005c703          	lbu	a4,0(a1)
 37c:	00e79863          	bne	a5,a4,38c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 380:	0505                	addi	a0,a0,1
    p2++;
 382:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 384:	fed518e3          	bne	a0,a3,374 <memcmp+0x14>
  }
  return 0;
 388:	4501                	li	a0,0
 38a:	a019                	j	390 <memcmp+0x30>
      return *p1 - *p2;
 38c:	40e7853b          	subw	a0,a5,a4
}
 390:	6422                	ld	s0,8(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret
  return 0;
 396:	4501                	li	a0,0
 398:	bfe5                	j	390 <memcmp+0x30>

000000000000039a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 39a:	1141                	addi	sp,sp,-16
 39c:	e406                	sd	ra,8(sp)
 39e:	e022                	sd	s0,0(sp)
 3a0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a2:	00000097          	auipc	ra,0x0
 3a6:	f66080e7          	jalr	-154(ra) # 308 <memmove>
}
 3aa:	60a2                	ld	ra,8(sp)
 3ac:	6402                	ld	s0,0(sp)
 3ae:	0141                	addi	sp,sp,16
 3b0:	8082                	ret

00000000000003b2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3b2:	4885                	li	a7,1
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ba:	4889                	li	a7,2
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3c2:	488d                	li	a7,3
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ca:	4891                	li	a7,4
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <read>:
.global read
read:
 li a7, SYS_read
 3d2:	4895                	li	a7,5
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <write>:
.global write
write:
 li a7, SYS_write
 3da:	48c1                	li	a7,16
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <close>:
.global close
close:
 li a7, SYS_close
 3e2:	48d5                	li	a7,21
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ea:	4899                	li	a7,6
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3f2:	489d                	li	a7,7
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <open>:
.global open
open:
 li a7, SYS_open
 3fa:	48bd                	li	a7,15
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 402:	48c5                	li	a7,17
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 40a:	48c9                	li	a7,18
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 412:	48a1                	li	a7,8
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <link>:
.global link
link:
 li a7, SYS_link
 41a:	48cd                	li	a7,19
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 422:	48d1                	li	a7,20
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 42a:	48a5                	li	a7,9
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <dup>:
.global dup
dup:
 li a7, SYS_dup
 432:	48a9                	li	a7,10
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 43a:	48ad                	li	a7,11
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 442:	48b1                	li	a7,12
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 44a:	48b5                	li	a7,13
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 452:	48b9                	li	a7,14
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <peterson_create>:
.global peterson_create
peterson_create:
 li a7, SYS_peterson_create
 45a:	48d9                	li	a7,22
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <peterson_acquire>:
.global peterson_acquire
peterson_acquire:
 li a7, SYS_peterson_acquire
 462:	48dd                	li	a7,23
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <peterson_release>:
.global peterson_release
peterson_release:
 li a7, SYS_peterson_release
 46a:	48e1                	li	a7,24
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <peterson_destroy>:
.global peterson_destroy
peterson_destroy:
 li a7, SYS_peterson_destroy
 472:	48e5                	li	a7,25
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 47a:	1101                	addi	sp,sp,-32
 47c:	ec06                	sd	ra,24(sp)
 47e:	e822                	sd	s0,16(sp)
 480:	1000                	addi	s0,sp,32
 482:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 486:	4605                	li	a2,1
 488:	fef40593          	addi	a1,s0,-17
 48c:	00000097          	auipc	ra,0x0
 490:	f4e080e7          	jalr	-178(ra) # 3da <write>
}
 494:	60e2                	ld	ra,24(sp)
 496:	6442                	ld	s0,16(sp)
 498:	6105                	addi	sp,sp,32
 49a:	8082                	ret

000000000000049c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 49c:	7139                	addi	sp,sp,-64
 49e:	fc06                	sd	ra,56(sp)
 4a0:	f822                	sd	s0,48(sp)
 4a2:	f426                	sd	s1,40(sp)
 4a4:	f04a                	sd	s2,32(sp)
 4a6:	ec4e                	sd	s3,24(sp)
 4a8:	0080                	addi	s0,sp,64
 4aa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ac:	c299                	beqz	a3,4b2 <printint+0x16>
 4ae:	0805c863          	bltz	a1,53e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4b2:	2581                	sext.w	a1,a1
  neg = 0;
 4b4:	4881                	li	a7,0
 4b6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ba:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4bc:	2601                	sext.w	a2,a2
 4be:	00000517          	auipc	a0,0x0
 4c2:	5ba50513          	addi	a0,a0,1466 # a78 <digits>
 4c6:	883a                	mv	a6,a4
 4c8:	2705                	addiw	a4,a4,1
 4ca:	02c5f7bb          	remuw	a5,a1,a2
 4ce:	1782                	slli	a5,a5,0x20
 4d0:	9381                	srli	a5,a5,0x20
 4d2:	97aa                	add	a5,a5,a0
 4d4:	0007c783          	lbu	a5,0(a5)
 4d8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4dc:	0005879b          	sext.w	a5,a1
 4e0:	02c5d5bb          	divuw	a1,a1,a2
 4e4:	0685                	addi	a3,a3,1
 4e6:	fec7f0e3          	bgeu	a5,a2,4c6 <printint+0x2a>
  if(neg)
 4ea:	00088b63          	beqz	a7,500 <printint+0x64>
    buf[i++] = '-';
 4ee:	fd040793          	addi	a5,s0,-48
 4f2:	973e                	add	a4,a4,a5
 4f4:	02d00793          	li	a5,45
 4f8:	fef70823          	sb	a5,-16(a4)
 4fc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 500:	02e05863          	blez	a4,530 <printint+0x94>
 504:	fc040793          	addi	a5,s0,-64
 508:	00e78933          	add	s2,a5,a4
 50c:	fff78993          	addi	s3,a5,-1
 510:	99ba                	add	s3,s3,a4
 512:	377d                	addiw	a4,a4,-1
 514:	1702                	slli	a4,a4,0x20
 516:	9301                	srli	a4,a4,0x20
 518:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 51c:	fff94583          	lbu	a1,-1(s2)
 520:	8526                	mv	a0,s1
 522:	00000097          	auipc	ra,0x0
 526:	f58080e7          	jalr	-168(ra) # 47a <putc>
  while(--i >= 0)
 52a:	197d                	addi	s2,s2,-1
 52c:	ff3918e3          	bne	s2,s3,51c <printint+0x80>
}
 530:	70e2                	ld	ra,56(sp)
 532:	7442                	ld	s0,48(sp)
 534:	74a2                	ld	s1,40(sp)
 536:	7902                	ld	s2,32(sp)
 538:	69e2                	ld	s3,24(sp)
 53a:	6121                	addi	sp,sp,64
 53c:	8082                	ret
    x = -xx;
 53e:	40b005bb          	negw	a1,a1
    neg = 1;
 542:	4885                	li	a7,1
    x = -xx;
 544:	bf8d                	j	4b6 <printint+0x1a>

0000000000000546 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 546:	7119                	addi	sp,sp,-128
 548:	fc86                	sd	ra,120(sp)
 54a:	f8a2                	sd	s0,112(sp)
 54c:	f4a6                	sd	s1,104(sp)
 54e:	f0ca                	sd	s2,96(sp)
 550:	ecce                	sd	s3,88(sp)
 552:	e8d2                	sd	s4,80(sp)
 554:	e4d6                	sd	s5,72(sp)
 556:	e0da                	sd	s6,64(sp)
 558:	fc5e                	sd	s7,56(sp)
 55a:	f862                	sd	s8,48(sp)
 55c:	f466                	sd	s9,40(sp)
 55e:	f06a                	sd	s10,32(sp)
 560:	ec6e                	sd	s11,24(sp)
 562:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 564:	0005c903          	lbu	s2,0(a1)
 568:	18090f63          	beqz	s2,706 <vprintf+0x1c0>
 56c:	8aaa                	mv	s5,a0
 56e:	8b32                	mv	s6,a2
 570:	00158493          	addi	s1,a1,1
  state = 0;
 574:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 576:	02500a13          	li	s4,37
      if(c == 'd'){
 57a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 57e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 582:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 586:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 58a:	00000b97          	auipc	s7,0x0
 58e:	4eeb8b93          	addi	s7,s7,1262 # a78 <digits>
 592:	a839                	j	5b0 <vprintf+0x6a>
        putc(fd, c);
 594:	85ca                	mv	a1,s2
 596:	8556                	mv	a0,s5
 598:	00000097          	auipc	ra,0x0
 59c:	ee2080e7          	jalr	-286(ra) # 47a <putc>
 5a0:	a019                	j	5a6 <vprintf+0x60>
    } else if(state == '%'){
 5a2:	01498f63          	beq	s3,s4,5c0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5a6:	0485                	addi	s1,s1,1
 5a8:	fff4c903          	lbu	s2,-1(s1)
 5ac:	14090d63          	beqz	s2,706 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5b0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5b4:	fe0997e3          	bnez	s3,5a2 <vprintf+0x5c>
      if(c == '%'){
 5b8:	fd479ee3          	bne	a5,s4,594 <vprintf+0x4e>
        state = '%';
 5bc:	89be                	mv	s3,a5
 5be:	b7e5                	j	5a6 <vprintf+0x60>
      if(c == 'd'){
 5c0:	05878063          	beq	a5,s8,600 <vprintf+0xba>
      } else if(c == 'l') {
 5c4:	05978c63          	beq	a5,s9,61c <vprintf+0xd6>
      } else if(c == 'x') {
 5c8:	07a78863          	beq	a5,s10,638 <vprintf+0xf2>
      } else if(c == 'p') {
 5cc:	09b78463          	beq	a5,s11,654 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5d0:	07300713          	li	a4,115
 5d4:	0ce78663          	beq	a5,a4,6a0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5d8:	06300713          	li	a4,99
 5dc:	0ee78e63          	beq	a5,a4,6d8 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5e0:	11478863          	beq	a5,s4,6f0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5e4:	85d2                	mv	a1,s4
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	e92080e7          	jalr	-366(ra) # 47a <putc>
        putc(fd, c);
 5f0:	85ca                	mv	a1,s2
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	e86080e7          	jalr	-378(ra) # 47a <putc>
      }
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b765                	j	5a6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 600:	008b0913          	addi	s2,s6,8
 604:	4685                	li	a3,1
 606:	4629                	li	a2,10
 608:	000b2583          	lw	a1,0(s6)
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	e8e080e7          	jalr	-370(ra) # 49c <printint>
 616:	8b4a                	mv	s6,s2
      state = 0;
 618:	4981                	li	s3,0
 61a:	b771                	j	5a6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 61c:	008b0913          	addi	s2,s6,8
 620:	4681                	li	a3,0
 622:	4629                	li	a2,10
 624:	000b2583          	lw	a1,0(s6)
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	e72080e7          	jalr	-398(ra) # 49c <printint>
 632:	8b4a                	mv	s6,s2
      state = 0;
 634:	4981                	li	s3,0
 636:	bf85                	j	5a6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 638:	008b0913          	addi	s2,s6,8
 63c:	4681                	li	a3,0
 63e:	4641                	li	a2,16
 640:	000b2583          	lw	a1,0(s6)
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	e56080e7          	jalr	-426(ra) # 49c <printint>
 64e:	8b4a                	mv	s6,s2
      state = 0;
 650:	4981                	li	s3,0
 652:	bf91                	j	5a6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 654:	008b0793          	addi	a5,s6,8
 658:	f8f43423          	sd	a5,-120(s0)
 65c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 660:	03000593          	li	a1,48
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	e14080e7          	jalr	-492(ra) # 47a <putc>
  putc(fd, 'x');
 66e:	85ea                	mv	a1,s10
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	e08080e7          	jalr	-504(ra) # 47a <putc>
 67a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67c:	03c9d793          	srli	a5,s3,0x3c
 680:	97de                	add	a5,a5,s7
 682:	0007c583          	lbu	a1,0(a5)
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	df2080e7          	jalr	-526(ra) # 47a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 690:	0992                	slli	s3,s3,0x4
 692:	397d                	addiw	s2,s2,-1
 694:	fe0914e3          	bnez	s2,67c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 698:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 69c:	4981                	li	s3,0
 69e:	b721                	j	5a6 <vprintf+0x60>
        s = va_arg(ap, char*);
 6a0:	008b0993          	addi	s3,s6,8
 6a4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6a8:	02090163          	beqz	s2,6ca <vprintf+0x184>
        while(*s != 0){
 6ac:	00094583          	lbu	a1,0(s2)
 6b0:	c9a1                	beqz	a1,700 <vprintf+0x1ba>
          putc(fd, *s);
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	dc6080e7          	jalr	-570(ra) # 47a <putc>
          s++;
 6bc:	0905                	addi	s2,s2,1
        while(*s != 0){
 6be:	00094583          	lbu	a1,0(s2)
 6c2:	f9e5                	bnez	a1,6b2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6c4:	8b4e                	mv	s6,s3
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	bdf9                	j	5a6 <vprintf+0x60>
          s = "(null)";
 6ca:	00000917          	auipc	s2,0x0
 6ce:	3a690913          	addi	s2,s2,934 # a70 <tournament_release+0xe8>
        while(*s != 0){
 6d2:	02800593          	li	a1,40
 6d6:	bff1                	j	6b2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6d8:	008b0913          	addi	s2,s6,8
 6dc:	000b4583          	lbu	a1,0(s6)
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	d98080e7          	jalr	-616(ra) # 47a <putc>
 6ea:	8b4a                	mv	s6,s2
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	bd65                	j	5a6 <vprintf+0x60>
        putc(fd, c);
 6f0:	85d2                	mv	a1,s4
 6f2:	8556                	mv	a0,s5
 6f4:	00000097          	auipc	ra,0x0
 6f8:	d86080e7          	jalr	-634(ra) # 47a <putc>
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	b565                	j	5a6 <vprintf+0x60>
        s = va_arg(ap, char*);
 700:	8b4e                	mv	s6,s3
      state = 0;
 702:	4981                	li	s3,0
 704:	b54d                	j	5a6 <vprintf+0x60>
    }
  }
}
 706:	70e6                	ld	ra,120(sp)
 708:	7446                	ld	s0,112(sp)
 70a:	74a6                	ld	s1,104(sp)
 70c:	7906                	ld	s2,96(sp)
 70e:	69e6                	ld	s3,88(sp)
 710:	6a46                	ld	s4,80(sp)
 712:	6aa6                	ld	s5,72(sp)
 714:	6b06                	ld	s6,64(sp)
 716:	7be2                	ld	s7,56(sp)
 718:	7c42                	ld	s8,48(sp)
 71a:	7ca2                	ld	s9,40(sp)
 71c:	7d02                	ld	s10,32(sp)
 71e:	6de2                	ld	s11,24(sp)
 720:	6109                	addi	sp,sp,128
 722:	8082                	ret

0000000000000724 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 724:	715d                	addi	sp,sp,-80
 726:	ec06                	sd	ra,24(sp)
 728:	e822                	sd	s0,16(sp)
 72a:	1000                	addi	s0,sp,32
 72c:	e010                	sd	a2,0(s0)
 72e:	e414                	sd	a3,8(s0)
 730:	e818                	sd	a4,16(s0)
 732:	ec1c                	sd	a5,24(s0)
 734:	03043023          	sd	a6,32(s0)
 738:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 73c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 740:	8622                	mv	a2,s0
 742:	00000097          	auipc	ra,0x0
 746:	e04080e7          	jalr	-508(ra) # 546 <vprintf>
}
 74a:	60e2                	ld	ra,24(sp)
 74c:	6442                	ld	s0,16(sp)
 74e:	6161                	addi	sp,sp,80
 750:	8082                	ret

0000000000000752 <printf>:

void
printf(const char *fmt, ...)
{
 752:	711d                	addi	sp,sp,-96
 754:	ec06                	sd	ra,24(sp)
 756:	e822                	sd	s0,16(sp)
 758:	1000                	addi	s0,sp,32
 75a:	e40c                	sd	a1,8(s0)
 75c:	e810                	sd	a2,16(s0)
 75e:	ec14                	sd	a3,24(s0)
 760:	f018                	sd	a4,32(s0)
 762:	f41c                	sd	a5,40(s0)
 764:	03043823          	sd	a6,48(s0)
 768:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 76c:	00840613          	addi	a2,s0,8
 770:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 774:	85aa                	mv	a1,a0
 776:	4505                	li	a0,1
 778:	00000097          	auipc	ra,0x0
 77c:	dce080e7          	jalr	-562(ra) # 546 <vprintf>
}
 780:	60e2                	ld	ra,24(sp)
 782:	6442                	ld	s0,16(sp)
 784:	6125                	addi	sp,sp,96
 786:	8082                	ret

0000000000000788 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 788:	1141                	addi	sp,sp,-16
 78a:	e422                	sd	s0,8(sp)
 78c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 78e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 792:	00001797          	auipc	a5,0x1
 796:	87e7b783          	ld	a5,-1922(a5) # 1010 <freep>
 79a:	a805                	j	7ca <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 79c:	4618                	lw	a4,8(a2)
 79e:	9db9                	addw	a1,a1,a4
 7a0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a4:	6398                	ld	a4,0(a5)
 7a6:	6318                	ld	a4,0(a4)
 7a8:	fee53823          	sd	a4,-16(a0)
 7ac:	a091                	j	7f0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ae:	ff852703          	lw	a4,-8(a0)
 7b2:	9e39                	addw	a2,a2,a4
 7b4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7b6:	ff053703          	ld	a4,-16(a0)
 7ba:	e398                	sd	a4,0(a5)
 7bc:	a099                	j	802 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7be:	6398                	ld	a4,0(a5)
 7c0:	00e7e463          	bltu	a5,a4,7c8 <free+0x40>
 7c4:	00e6ea63          	bltu	a3,a4,7d8 <free+0x50>
{
 7c8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ca:	fed7fae3          	bgeu	a5,a3,7be <free+0x36>
 7ce:	6398                	ld	a4,0(a5)
 7d0:	00e6e463          	bltu	a3,a4,7d8 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d4:	fee7eae3          	bltu	a5,a4,7c8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7d8:	ff852583          	lw	a1,-8(a0)
 7dc:	6390                	ld	a2,0(a5)
 7de:	02059713          	slli	a4,a1,0x20
 7e2:	9301                	srli	a4,a4,0x20
 7e4:	0712                	slli	a4,a4,0x4
 7e6:	9736                	add	a4,a4,a3
 7e8:	fae60ae3          	beq	a2,a4,79c <free+0x14>
    bp->s.ptr = p->s.ptr;
 7ec:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7f0:	4790                	lw	a2,8(a5)
 7f2:	02061713          	slli	a4,a2,0x20
 7f6:	9301                	srli	a4,a4,0x20
 7f8:	0712                	slli	a4,a4,0x4
 7fa:	973e                	add	a4,a4,a5
 7fc:	fae689e3          	beq	a3,a4,7ae <free+0x26>
  } else
    p->s.ptr = bp;
 800:	e394                	sd	a3,0(a5)
  freep = p;
 802:	00001717          	auipc	a4,0x1
 806:	80f73723          	sd	a5,-2034(a4) # 1010 <freep>
}
 80a:	6422                	ld	s0,8(sp)
 80c:	0141                	addi	sp,sp,16
 80e:	8082                	ret

0000000000000810 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 810:	7139                	addi	sp,sp,-64
 812:	fc06                	sd	ra,56(sp)
 814:	f822                	sd	s0,48(sp)
 816:	f426                	sd	s1,40(sp)
 818:	f04a                	sd	s2,32(sp)
 81a:	ec4e                	sd	s3,24(sp)
 81c:	e852                	sd	s4,16(sp)
 81e:	e456                	sd	s5,8(sp)
 820:	e05a                	sd	s6,0(sp)
 822:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 824:	02051493          	slli	s1,a0,0x20
 828:	9081                	srli	s1,s1,0x20
 82a:	04bd                	addi	s1,s1,15
 82c:	8091                	srli	s1,s1,0x4
 82e:	0014899b          	addiw	s3,s1,1
 832:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 834:	00000517          	auipc	a0,0x0
 838:	7dc53503          	ld	a0,2012(a0) # 1010 <freep>
 83c:	c515                	beqz	a0,868 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 840:	4798                	lw	a4,8(a5)
 842:	02977f63          	bgeu	a4,s1,880 <malloc+0x70>
 846:	8a4e                	mv	s4,s3
 848:	0009871b          	sext.w	a4,s3
 84c:	6685                	lui	a3,0x1
 84e:	00d77363          	bgeu	a4,a3,854 <malloc+0x44>
 852:	6a05                	lui	s4,0x1
 854:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 858:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 85c:	00000917          	auipc	s2,0x0
 860:	7b490913          	addi	s2,s2,1972 # 1010 <freep>
  if(p == (char*)-1)
 864:	5afd                	li	s5,-1
 866:	a88d                	j	8d8 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 868:	00000797          	auipc	a5,0x0
 86c:	7c878793          	addi	a5,a5,1992 # 1030 <base>
 870:	00000717          	auipc	a4,0x0
 874:	7af73023          	sd	a5,1952(a4) # 1010 <freep>
 878:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 87a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 87e:	b7e1                	j	846 <malloc+0x36>
      if(p->s.size == nunits)
 880:	02e48b63          	beq	s1,a4,8b6 <malloc+0xa6>
        p->s.size -= nunits;
 884:	4137073b          	subw	a4,a4,s3
 888:	c798                	sw	a4,8(a5)
        p += p->s.size;
 88a:	1702                	slli	a4,a4,0x20
 88c:	9301                	srli	a4,a4,0x20
 88e:	0712                	slli	a4,a4,0x4
 890:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 892:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 896:	00000717          	auipc	a4,0x0
 89a:	76a73d23          	sd	a0,1914(a4) # 1010 <freep>
      return (void*)(p + 1);
 89e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8a2:	70e2                	ld	ra,56(sp)
 8a4:	7442                	ld	s0,48(sp)
 8a6:	74a2                	ld	s1,40(sp)
 8a8:	7902                	ld	s2,32(sp)
 8aa:	69e2                	ld	s3,24(sp)
 8ac:	6a42                	ld	s4,16(sp)
 8ae:	6aa2                	ld	s5,8(sp)
 8b0:	6b02                	ld	s6,0(sp)
 8b2:	6121                	addi	sp,sp,64
 8b4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8b6:	6398                	ld	a4,0(a5)
 8b8:	e118                	sd	a4,0(a0)
 8ba:	bff1                	j	896 <malloc+0x86>
  hp->s.size = nu;
 8bc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8c0:	0541                	addi	a0,a0,16
 8c2:	00000097          	auipc	ra,0x0
 8c6:	ec6080e7          	jalr	-314(ra) # 788 <free>
  return freep;
 8ca:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ce:	d971                	beqz	a0,8a2 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d2:	4798                	lw	a4,8(a5)
 8d4:	fa9776e3          	bgeu	a4,s1,880 <malloc+0x70>
    if(p == freep)
 8d8:	00093703          	ld	a4,0(s2)
 8dc:	853e                	mv	a0,a5
 8de:	fef719e3          	bne	a4,a5,8d0 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8e2:	8552                	mv	a0,s4
 8e4:	00000097          	auipc	ra,0x0
 8e8:	b5e080e7          	jalr	-1186(ra) # 442 <sbrk>
  if(p == (char*)-1)
 8ec:	fd5518e3          	bne	a0,s5,8bc <malloc+0xac>
        return 0;
 8f0:	4501                	li	a0,0
 8f2:	bf45                	j	8a2 <malloc+0x92>

00000000000008f4 <tournament_create>:
int num_levels = 0 ;
int num_processes = 0 ;
int* lock_ids = 0 ;

static int is_power_of_two(int x) {
    return x > 0 && (x & (x - 1)) == 0;
 8f4:	fff5071b          	addiw	a4,a0,-1
 8f8:	47bd                	li	a5,15
 8fa:	00e7eb63          	bltu	a5,a4,910 <tournament_create+0x1c>
 8fe:	fff5079b          	addiw	a5,a0,-1
 902:	8fe9                	and	a5,a5,a0
 904:	2781                	sext.w	a5,a5
 906:	c799                	beqz	a5,914 <tournament_create+0x20>
}

int tournament_create(int processes) {
   if(  processes > MAX_PROCESSES ||!is_power_of_two(processes)) return -1 ;
 908:	557d                	li	a0,-1
 90a:	8082                	ret
    
   int total_locks = (1 << num_levels) -1 ;

   lock_ids = malloc(sizeof(int) * total_locks);
    if (!lock_ids)
        return -1;
 90c:	557d                	li	a0,-1
 90e:	a095                	j	972 <tournament_create+0x7e>
   if(  processes > MAX_PROCESSES ||!is_power_of_two(processes)) return -1 ;
 910:	557d                	li	a0,-1


    return 1 ;    
}
 912:	8082                	ret
int tournament_create(int processes) {
 914:	1141                	addi	sp,sp,-16
 916:	e406                	sd	ra,8(sp)
 918:	e022                	sd	s0,0(sp)
 91a:	0800                	addi	s0,sp,16
   num_processes = processes ;
 91c:	00000797          	auipc	a5,0x0
 920:	70a7a223          	sw	a0,1796(a5) # 1020 <num_processes>
   while(temp >>=1)
 924:	4015551b          	sraiw	a0,a0,0x1
 928:	c105                	beqz	a0,948 <tournament_create+0x54>
 92a:	00000797          	auipc	a5,0x0
 92e:	6fa7a783          	lw	a5,1786(a5) # 1024 <num_levels>
 932:	2785                	addiw	a5,a5,1
        num_levels ++ ;
 934:	0007871b          	sext.w	a4,a5
   while(temp >>=1)
 938:	4015551b          	sraiw	a0,a0,0x1
 93c:	2785                	addiw	a5,a5,1
 93e:	f97d                	bnez	a0,934 <tournament_create+0x40>
 940:	00000797          	auipc	a5,0x0
 944:	6ee7a223          	sw	a4,1764(a5) # 1024 <num_levels>
   int total_locks = (1 << num_levels) -1 ;
 948:	00000797          	auipc	a5,0x0
 94c:	6dc7a783          	lw	a5,1756(a5) # 1024 <num_levels>
 950:	4505                	li	a0,1
 952:	00f5153b          	sllw	a0,a0,a5
 956:	357d                	addiw	a0,a0,-1
   lock_ids = malloc(sizeof(int) * total_locks);
 958:	0025151b          	slliw	a0,a0,0x2
 95c:	00000097          	auipc	ra,0x0
 960:	eb4080e7          	jalr	-332(ra) # 810 <malloc>
 964:	87aa                	mv	a5,a0
 966:	00000717          	auipc	a4,0x0
 96a:	6aa73923          	sd	a0,1714(a4) # 1018 <lock_ids>
    return 1 ;    
 96e:	4505                	li	a0,1
    if (!lock_ids)
 970:	dfd1                	beqz	a5,90c <tournament_create+0x18>
}
 972:	60a2                	ld	ra,8(sp)
 974:	6402                	ld	s0,0(sp)
 976:	0141                	addi	sp,sp,16
 978:	8082                	ret

000000000000097a <tournament_acquire>:

int tournament_acquire(void) { return 0;}
 97a:	1141                	addi	sp,sp,-16
 97c:	e422                	sd	s0,8(sp)
 97e:	0800                	addi	s0,sp,16
 980:	4501                	li	a0,0
 982:	6422                	ld	s0,8(sp)
 984:	0141                	addi	sp,sp,16
 986:	8082                	ret

0000000000000988 <tournament_release>:

int tournament_release(void){ return 0;}
 988:	1141                	addi	sp,sp,-16
 98a:	e422                	sd	s0,8(sp)
 98c:	0800                	addi	s0,sp,16
 98e:	4501                	li	a0,0
 990:	6422                	ld	s0,8(sp)
 992:	0141                	addi	sp,sp,16
 994:	8082                	ret
