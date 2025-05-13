
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	01090913          	addi	s2,s2,16 # 1020 <buf>
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	00000097          	auipc	ra,0x0
  24:	39e080e7          	jalr	926(ra) # 3be <read>
  28:	84aa                	mv	s1,a0
  2a:	02a05963          	blez	a0,5c <cat+0x5c>
    if (write(1, buf, n) != n) {
  2e:	8626                	mv	a2,s1
  30:	85ca                	mv	a1,s2
  32:	4505                	li	a0,1
  34:	00000097          	auipc	ra,0x0
  38:	392080e7          	jalr	914(ra) # 3c6 <write>
  3c:	fc950ee3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  40:	00001597          	auipc	a1,0x1
  44:	b2058593          	addi	a1,a1,-1248 # b60 <tournament_release+0xd6>
  48:	4509                	li	a0,2
  4a:	00000097          	auipc	ra,0x0
  4e:	6c6080e7          	jalr	1734(ra) # 710 <fprintf>
      exit(1);
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	352080e7          	jalr	850(ra) # 3a6 <exit>
    }
  }
  if(n < 0){
  5c:	00054963          	bltz	a0,6e <cat+0x6e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  60:	70a2                	ld	ra,40(sp)
  62:	7402                	ld	s0,32(sp)
  64:	64e2                	ld	s1,24(sp)
  66:	6942                	ld	s2,16(sp)
  68:	69a2                	ld	s3,8(sp)
  6a:	6145                	addi	sp,sp,48
  6c:	8082                	ret
    fprintf(2, "cat: read error\n");
  6e:	00001597          	auipc	a1,0x1
  72:	b0a58593          	addi	a1,a1,-1270 # b78 <tournament_release+0xee>
  76:	4509                	li	a0,2
  78:	00000097          	auipc	ra,0x0
  7c:	698080e7          	jalr	1688(ra) # 710 <fprintf>
    exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	324080e7          	jalr	804(ra) # 3a6 <exit>

000000000000008a <main>:

int
main(int argc, char *argv[])
{
  8a:	7179                	addi	sp,sp,-48
  8c:	f406                	sd	ra,40(sp)
  8e:	f022                	sd	s0,32(sp)
  90:	ec26                	sd	s1,24(sp)
  92:	e84a                	sd	s2,16(sp)
  94:	e44e                	sd	s3,8(sp)
  96:	e052                	sd	s4,0(sp)
  98:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  9a:	4785                	li	a5,1
  9c:	04a7d763          	bge	a5,a0,ea <main+0x60>
  a0:	00858913          	addi	s2,a1,8
  a4:	ffe5099b          	addiw	s3,a0,-2
  a8:	1982                	slli	s3,s3,0x20
  aa:	0209d993          	srli	s3,s3,0x20
  ae:	098e                	slli	s3,s3,0x3
  b0:	05c1                	addi	a1,a1,16
  b2:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
  b4:	4581                	li	a1,0
  b6:	00093503          	ld	a0,0(s2)
  ba:	00000097          	auipc	ra,0x0
  be:	32c080e7          	jalr	812(ra) # 3e6 <open>
  c2:	84aa                	mv	s1,a0
  c4:	02054d63          	bltz	a0,fe <main+0x74>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  c8:	00000097          	auipc	ra,0x0
  cc:	f38080e7          	jalr	-200(ra) # 0 <cat>
    close(fd);
  d0:	8526                	mv	a0,s1
  d2:	00000097          	auipc	ra,0x0
  d6:	2fc080e7          	jalr	764(ra) # 3ce <close>
  for(i = 1; i < argc; i++){
  da:	0921                	addi	s2,s2,8
  dc:	fd391ce3          	bne	s2,s3,b4 <main+0x2a>
  }
  exit(0);
  e0:	4501                	li	a0,0
  e2:	00000097          	auipc	ra,0x0
  e6:	2c4080e7          	jalr	708(ra) # 3a6 <exit>
    cat(0);
  ea:	4501                	li	a0,0
  ec:	00000097          	auipc	ra,0x0
  f0:	f14080e7          	jalr	-236(ra) # 0 <cat>
    exit(0);
  f4:	4501                	li	a0,0
  f6:	00000097          	auipc	ra,0x0
  fa:	2b0080e7          	jalr	688(ra) # 3a6 <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  fe:	00093603          	ld	a2,0(s2)
 102:	00001597          	auipc	a1,0x1
 106:	a8e58593          	addi	a1,a1,-1394 # b90 <tournament_release+0x106>
 10a:	4509                	li	a0,2
 10c:	00000097          	auipc	ra,0x0
 110:	604080e7          	jalr	1540(ra) # 710 <fprintf>
      exit(1);
 114:	4505                	li	a0,1
 116:	00000097          	auipc	ra,0x0
 11a:	290080e7          	jalr	656(ra) # 3a6 <exit>

000000000000011e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 11e:	1141                	addi	sp,sp,-16
 120:	e406                	sd	ra,8(sp)
 122:	e022                	sd	s0,0(sp)
 124:	0800                	addi	s0,sp,16
  extern int main();
  main();
 126:	00000097          	auipc	ra,0x0
 12a:	f64080e7          	jalr	-156(ra) # 8a <main>
  exit(0);
 12e:	4501                	li	a0,0
 130:	00000097          	auipc	ra,0x0
 134:	276080e7          	jalr	630(ra) # 3a6 <exit>

0000000000000138 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 138:	1141                	addi	sp,sp,-16
 13a:	e422                	sd	s0,8(sp)
 13c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 13e:	87aa                	mv	a5,a0
 140:	0585                	addi	a1,a1,1
 142:	0785                	addi	a5,a5,1
 144:	fff5c703          	lbu	a4,-1(a1)
 148:	fee78fa3          	sb	a4,-1(a5)
 14c:	fb75                	bnez	a4,140 <strcpy+0x8>
    ;
  return os;
}
 14e:	6422                	ld	s0,8(sp)
 150:	0141                	addi	sp,sp,16
 152:	8082                	ret

0000000000000154 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 154:	1141                	addi	sp,sp,-16
 156:	e422                	sd	s0,8(sp)
 158:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	cb91                	beqz	a5,172 <strcmp+0x1e>
 160:	0005c703          	lbu	a4,0(a1)
 164:	00f71763          	bne	a4,a5,172 <strcmp+0x1e>
    p++, q++;
 168:	0505                	addi	a0,a0,1
 16a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 16c:	00054783          	lbu	a5,0(a0)
 170:	fbe5                	bnez	a5,160 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 172:	0005c503          	lbu	a0,0(a1)
}
 176:	40a7853b          	subw	a0,a5,a0
 17a:	6422                	ld	s0,8(sp)
 17c:	0141                	addi	sp,sp,16
 17e:	8082                	ret

0000000000000180 <strlen>:

uint
strlen(const char *s)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 186:	00054783          	lbu	a5,0(a0)
 18a:	cf91                	beqz	a5,1a6 <strlen+0x26>
 18c:	0505                	addi	a0,a0,1
 18e:	87aa                	mv	a5,a0
 190:	4685                	li	a3,1
 192:	9e89                	subw	a3,a3,a0
 194:	00f6853b          	addw	a0,a3,a5
 198:	0785                	addi	a5,a5,1
 19a:	fff7c703          	lbu	a4,-1(a5)
 19e:	fb7d                	bnez	a4,194 <strlen+0x14>
    ;
  return n;
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret
  for(n = 0; s[n]; n++)
 1a6:	4501                	li	a0,0
 1a8:	bfe5                	j	1a0 <strlen+0x20>

00000000000001aa <memset>:

void*
memset(void *dst, int c, uint n)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1b0:	ca19                	beqz	a2,1c6 <memset+0x1c>
 1b2:	87aa                	mv	a5,a0
 1b4:	1602                	slli	a2,a2,0x20
 1b6:	9201                	srli	a2,a2,0x20
 1b8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1bc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1c0:	0785                	addi	a5,a5,1
 1c2:	fee79de3          	bne	a5,a4,1bc <memset+0x12>
  }
  return dst;
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret

00000000000001cc <strchr>:

char*
strchr(const char *s, char c)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	cb99                	beqz	a5,1ec <strchr+0x20>
    if(*s == c)
 1d8:	00f58763          	beq	a1,a5,1e6 <strchr+0x1a>
  for(; *s; s++)
 1dc:	0505                	addi	a0,a0,1
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	fbfd                	bnez	a5,1d8 <strchr+0xc>
      return (char*)s;
  return 0;
 1e4:	4501                	li	a0,0
}
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret
  return 0;
 1ec:	4501                	li	a0,0
 1ee:	bfe5                	j	1e6 <strchr+0x1a>

00000000000001f0 <gets>:

char*
gets(char *buf, int max)
{
 1f0:	711d                	addi	sp,sp,-96
 1f2:	ec86                	sd	ra,88(sp)
 1f4:	e8a2                	sd	s0,80(sp)
 1f6:	e4a6                	sd	s1,72(sp)
 1f8:	e0ca                	sd	s2,64(sp)
 1fa:	fc4e                	sd	s3,56(sp)
 1fc:	f852                	sd	s4,48(sp)
 1fe:	f456                	sd	s5,40(sp)
 200:	f05a                	sd	s6,32(sp)
 202:	ec5e                	sd	s7,24(sp)
 204:	1080                	addi	s0,sp,96
 206:	8baa                	mv	s7,a0
 208:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20a:	892a                	mv	s2,a0
 20c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 20e:	4aa9                	li	s5,10
 210:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 212:	89a6                	mv	s3,s1
 214:	2485                	addiw	s1,s1,1
 216:	0344d863          	bge	s1,s4,246 <gets+0x56>
    cc = read(0, &c, 1);
 21a:	4605                	li	a2,1
 21c:	faf40593          	addi	a1,s0,-81
 220:	4501                	li	a0,0
 222:	00000097          	auipc	ra,0x0
 226:	19c080e7          	jalr	412(ra) # 3be <read>
    if(cc < 1)
 22a:	00a05e63          	blez	a0,246 <gets+0x56>
    buf[i++] = c;
 22e:	faf44783          	lbu	a5,-81(s0)
 232:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 236:	01578763          	beq	a5,s5,244 <gets+0x54>
 23a:	0905                	addi	s2,s2,1
 23c:	fd679be3          	bne	a5,s6,212 <gets+0x22>
  for(i=0; i+1 < max; ){
 240:	89a6                	mv	s3,s1
 242:	a011                	j	246 <gets+0x56>
 244:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 246:	99de                	add	s3,s3,s7
 248:	00098023          	sb	zero,0(s3)
  return buf;
}
 24c:	855e                	mv	a0,s7
 24e:	60e6                	ld	ra,88(sp)
 250:	6446                	ld	s0,80(sp)
 252:	64a6                	ld	s1,72(sp)
 254:	6906                	ld	s2,64(sp)
 256:	79e2                	ld	s3,56(sp)
 258:	7a42                	ld	s4,48(sp)
 25a:	7aa2                	ld	s5,40(sp)
 25c:	7b02                	ld	s6,32(sp)
 25e:	6be2                	ld	s7,24(sp)
 260:	6125                	addi	sp,sp,96
 262:	8082                	ret

0000000000000264 <stat>:

int
stat(const char *n, struct stat *st)
{
 264:	1101                	addi	sp,sp,-32
 266:	ec06                	sd	ra,24(sp)
 268:	e822                	sd	s0,16(sp)
 26a:	e426                	sd	s1,8(sp)
 26c:	e04a                	sd	s2,0(sp)
 26e:	1000                	addi	s0,sp,32
 270:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 272:	4581                	li	a1,0
 274:	00000097          	auipc	ra,0x0
 278:	172080e7          	jalr	370(ra) # 3e6 <open>
  if(fd < 0)
 27c:	02054563          	bltz	a0,2a6 <stat+0x42>
 280:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 282:	85ca                	mv	a1,s2
 284:	00000097          	auipc	ra,0x0
 288:	17a080e7          	jalr	378(ra) # 3fe <fstat>
 28c:	892a                	mv	s2,a0
  close(fd);
 28e:	8526                	mv	a0,s1
 290:	00000097          	auipc	ra,0x0
 294:	13e080e7          	jalr	318(ra) # 3ce <close>
  return r;
}
 298:	854a                	mv	a0,s2
 29a:	60e2                	ld	ra,24(sp)
 29c:	6442                	ld	s0,16(sp)
 29e:	64a2                	ld	s1,8(sp)
 2a0:	6902                	ld	s2,0(sp)
 2a2:	6105                	addi	sp,sp,32
 2a4:	8082                	ret
    return -1;
 2a6:	597d                	li	s2,-1
 2a8:	bfc5                	j	298 <stat+0x34>

00000000000002aa <atoi>:

int
atoi(const char *s)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b0:	00054603          	lbu	a2,0(a0)
 2b4:	fd06079b          	addiw	a5,a2,-48
 2b8:	0ff7f793          	andi	a5,a5,255
 2bc:	4725                	li	a4,9
 2be:	02f76963          	bltu	a4,a5,2f0 <atoi+0x46>
 2c2:	86aa                	mv	a3,a0
  n = 0;
 2c4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2c6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2c8:	0685                	addi	a3,a3,1
 2ca:	0025179b          	slliw	a5,a0,0x2
 2ce:	9fa9                	addw	a5,a5,a0
 2d0:	0017979b          	slliw	a5,a5,0x1
 2d4:	9fb1                	addw	a5,a5,a2
 2d6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2da:	0006c603          	lbu	a2,0(a3)
 2de:	fd06071b          	addiw	a4,a2,-48
 2e2:	0ff77713          	andi	a4,a4,255
 2e6:	fee5f1e3          	bgeu	a1,a4,2c8 <atoi+0x1e>
  return n;
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	addi	sp,sp,16
 2ee:	8082                	ret
  n = 0;
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <atoi+0x40>

00000000000002f4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2f4:	1141                	addi	sp,sp,-16
 2f6:	e422                	sd	s0,8(sp)
 2f8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2fa:	02b57463          	bgeu	a0,a1,322 <memmove+0x2e>
    while(n-- > 0)
 2fe:	00c05f63          	blez	a2,31c <memmove+0x28>
 302:	1602                	slli	a2,a2,0x20
 304:	9201                	srli	a2,a2,0x20
 306:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 30a:	872a                	mv	a4,a0
      *dst++ = *src++;
 30c:	0585                	addi	a1,a1,1
 30e:	0705                	addi	a4,a4,1
 310:	fff5c683          	lbu	a3,-1(a1)
 314:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 318:	fee79ae3          	bne	a5,a4,30c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	addi	sp,sp,16
 320:	8082                	ret
    dst += n;
 322:	00c50733          	add	a4,a0,a2
    src += n;
 326:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 328:	fec05ae3          	blez	a2,31c <memmove+0x28>
 32c:	fff6079b          	addiw	a5,a2,-1
 330:	1782                	slli	a5,a5,0x20
 332:	9381                	srli	a5,a5,0x20
 334:	fff7c793          	not	a5,a5
 338:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 33a:	15fd                	addi	a1,a1,-1
 33c:	177d                	addi	a4,a4,-1
 33e:	0005c683          	lbu	a3,0(a1)
 342:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 346:	fee79ae3          	bne	a5,a4,33a <memmove+0x46>
 34a:	bfc9                	j	31c <memmove+0x28>

000000000000034c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e422                	sd	s0,8(sp)
 350:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 352:	ca05                	beqz	a2,382 <memcmp+0x36>
 354:	fff6069b          	addiw	a3,a2,-1
 358:	1682                	slli	a3,a3,0x20
 35a:	9281                	srli	a3,a3,0x20
 35c:	0685                	addi	a3,a3,1
 35e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 360:	00054783          	lbu	a5,0(a0)
 364:	0005c703          	lbu	a4,0(a1)
 368:	00e79863          	bne	a5,a4,378 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 36c:	0505                	addi	a0,a0,1
    p2++;
 36e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 370:	fed518e3          	bne	a0,a3,360 <memcmp+0x14>
  }
  return 0;
 374:	4501                	li	a0,0
 376:	a019                	j	37c <memcmp+0x30>
      return *p1 - *p2;
 378:	40e7853b          	subw	a0,a5,a4
}
 37c:	6422                	ld	s0,8(sp)
 37e:	0141                	addi	sp,sp,16
 380:	8082                	ret
  return 0;
 382:	4501                	li	a0,0
 384:	bfe5                	j	37c <memcmp+0x30>

0000000000000386 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 386:	1141                	addi	sp,sp,-16
 388:	e406                	sd	ra,8(sp)
 38a:	e022                	sd	s0,0(sp)
 38c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 38e:	00000097          	auipc	ra,0x0
 392:	f66080e7          	jalr	-154(ra) # 2f4 <memmove>
}
 396:	60a2                	ld	ra,8(sp)
 398:	6402                	ld	s0,0(sp)
 39a:	0141                	addi	sp,sp,16
 39c:	8082                	ret

000000000000039e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 39e:	4885                	li	a7,1
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3a6:	4889                	li	a7,2
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <wait>:
.global wait
wait:
 li a7, SYS_wait
 3ae:	488d                	li	a7,3
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3b6:	4891                	li	a7,4
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <read>:
.global read
read:
 li a7, SYS_read
 3be:	4895                	li	a7,5
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <write>:
.global write
write:
 li a7, SYS_write
 3c6:	48c1                	li	a7,16
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <close>:
.global close
close:
 li a7, SYS_close
 3ce:	48d5                	li	a7,21
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3d6:	4899                	li	a7,6
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <exec>:
.global exec
exec:
 li a7, SYS_exec
 3de:	489d                	li	a7,7
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <open>:
.global open
open:
 li a7, SYS_open
 3e6:	48bd                	li	a7,15
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ee:	48c5                	li	a7,17
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3f6:	48c9                	li	a7,18
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3fe:	48a1                	li	a7,8
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <link>:
.global link
link:
 li a7, SYS_link
 406:	48cd                	li	a7,19
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 40e:	48d1                	li	a7,20
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 416:	48a5                	li	a7,9
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <dup>:
.global dup
dup:
 li a7, SYS_dup
 41e:	48a9                	li	a7,10
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 426:	48ad                	li	a7,11
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 42e:	48b1                	li	a7,12
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 436:	48b5                	li	a7,13
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 43e:	48b9                	li	a7,14
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <peterson_create>:
.global peterson_create
peterson_create:
 li a7, SYS_peterson_create
 446:	48d9                	li	a7,22
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <peterson_acquire>:
.global peterson_acquire
peterson_acquire:
 li a7, SYS_peterson_acquire
 44e:	48dd                	li	a7,23
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <peterson_release>:
.global peterson_release
peterson_release:
 li a7, SYS_peterson_release
 456:	48e1                	li	a7,24
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <peterson_destroy>:
.global peterson_destroy
peterson_destroy:
 li a7, SYS_peterson_destroy
 45e:	48e5                	li	a7,25
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 466:	1101                	addi	sp,sp,-32
 468:	ec06                	sd	ra,24(sp)
 46a:	e822                	sd	s0,16(sp)
 46c:	1000                	addi	s0,sp,32
 46e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 472:	4605                	li	a2,1
 474:	fef40593          	addi	a1,s0,-17
 478:	00000097          	auipc	ra,0x0
 47c:	f4e080e7          	jalr	-178(ra) # 3c6 <write>
}
 480:	60e2                	ld	ra,24(sp)
 482:	6442                	ld	s0,16(sp)
 484:	6105                	addi	sp,sp,32
 486:	8082                	ret

0000000000000488 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 488:	7139                	addi	sp,sp,-64
 48a:	fc06                	sd	ra,56(sp)
 48c:	f822                	sd	s0,48(sp)
 48e:	f426                	sd	s1,40(sp)
 490:	f04a                	sd	s2,32(sp)
 492:	ec4e                	sd	s3,24(sp)
 494:	0080                	addi	s0,sp,64
 496:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 498:	c299                	beqz	a3,49e <printint+0x16>
 49a:	0805c863          	bltz	a1,52a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 49e:	2581                	sext.w	a1,a1
  neg = 0;
 4a0:	4881                	li	a7,0
 4a2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4a6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4a8:	2601                	sext.w	a2,a2
 4aa:	00000517          	auipc	a0,0x0
 4ae:	70650513          	addi	a0,a0,1798 # bb0 <digits>
 4b2:	883a                	mv	a6,a4
 4b4:	2705                	addiw	a4,a4,1
 4b6:	02c5f7bb          	remuw	a5,a1,a2
 4ba:	1782                	slli	a5,a5,0x20
 4bc:	9381                	srli	a5,a5,0x20
 4be:	97aa                	add	a5,a5,a0
 4c0:	0007c783          	lbu	a5,0(a5)
 4c4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4c8:	0005879b          	sext.w	a5,a1
 4cc:	02c5d5bb          	divuw	a1,a1,a2
 4d0:	0685                	addi	a3,a3,1
 4d2:	fec7f0e3          	bgeu	a5,a2,4b2 <printint+0x2a>
  if(neg)
 4d6:	00088b63          	beqz	a7,4ec <printint+0x64>
    buf[i++] = '-';
 4da:	fd040793          	addi	a5,s0,-48
 4de:	973e                	add	a4,a4,a5
 4e0:	02d00793          	li	a5,45
 4e4:	fef70823          	sb	a5,-16(a4)
 4e8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ec:	02e05863          	blez	a4,51c <printint+0x94>
 4f0:	fc040793          	addi	a5,s0,-64
 4f4:	00e78933          	add	s2,a5,a4
 4f8:	fff78993          	addi	s3,a5,-1
 4fc:	99ba                	add	s3,s3,a4
 4fe:	377d                	addiw	a4,a4,-1
 500:	1702                	slli	a4,a4,0x20
 502:	9301                	srli	a4,a4,0x20
 504:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 508:	fff94583          	lbu	a1,-1(s2)
 50c:	8526                	mv	a0,s1
 50e:	00000097          	auipc	ra,0x0
 512:	f58080e7          	jalr	-168(ra) # 466 <putc>
  while(--i >= 0)
 516:	197d                	addi	s2,s2,-1
 518:	ff3918e3          	bne	s2,s3,508 <printint+0x80>
}
 51c:	70e2                	ld	ra,56(sp)
 51e:	7442                	ld	s0,48(sp)
 520:	74a2                	ld	s1,40(sp)
 522:	7902                	ld	s2,32(sp)
 524:	69e2                	ld	s3,24(sp)
 526:	6121                	addi	sp,sp,64
 528:	8082                	ret
    x = -xx;
 52a:	40b005bb          	negw	a1,a1
    neg = 1;
 52e:	4885                	li	a7,1
    x = -xx;
 530:	bf8d                	j	4a2 <printint+0x1a>

0000000000000532 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 532:	7119                	addi	sp,sp,-128
 534:	fc86                	sd	ra,120(sp)
 536:	f8a2                	sd	s0,112(sp)
 538:	f4a6                	sd	s1,104(sp)
 53a:	f0ca                	sd	s2,96(sp)
 53c:	ecce                	sd	s3,88(sp)
 53e:	e8d2                	sd	s4,80(sp)
 540:	e4d6                	sd	s5,72(sp)
 542:	e0da                	sd	s6,64(sp)
 544:	fc5e                	sd	s7,56(sp)
 546:	f862                	sd	s8,48(sp)
 548:	f466                	sd	s9,40(sp)
 54a:	f06a                	sd	s10,32(sp)
 54c:	ec6e                	sd	s11,24(sp)
 54e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 550:	0005c903          	lbu	s2,0(a1)
 554:	18090f63          	beqz	s2,6f2 <vprintf+0x1c0>
 558:	8aaa                	mv	s5,a0
 55a:	8b32                	mv	s6,a2
 55c:	00158493          	addi	s1,a1,1
  state = 0;
 560:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 562:	02500a13          	li	s4,37
      if(c == 'd'){
 566:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 56a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 56e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 572:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 576:	00000b97          	auipc	s7,0x0
 57a:	63ab8b93          	addi	s7,s7,1594 # bb0 <digits>
 57e:	a839                	j	59c <vprintf+0x6a>
        putc(fd, c);
 580:	85ca                	mv	a1,s2
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	ee2080e7          	jalr	-286(ra) # 466 <putc>
 58c:	a019                	j	592 <vprintf+0x60>
    } else if(state == '%'){
 58e:	01498f63          	beq	s3,s4,5ac <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 592:	0485                	addi	s1,s1,1
 594:	fff4c903          	lbu	s2,-1(s1)
 598:	14090d63          	beqz	s2,6f2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 59c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5a0:	fe0997e3          	bnez	s3,58e <vprintf+0x5c>
      if(c == '%'){
 5a4:	fd479ee3          	bne	a5,s4,580 <vprintf+0x4e>
        state = '%';
 5a8:	89be                	mv	s3,a5
 5aa:	b7e5                	j	592 <vprintf+0x60>
      if(c == 'd'){
 5ac:	05878063          	beq	a5,s8,5ec <vprintf+0xba>
      } else if(c == 'l') {
 5b0:	05978c63          	beq	a5,s9,608 <vprintf+0xd6>
      } else if(c == 'x') {
 5b4:	07a78863          	beq	a5,s10,624 <vprintf+0xf2>
      } else if(c == 'p') {
 5b8:	09b78463          	beq	a5,s11,640 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5bc:	07300713          	li	a4,115
 5c0:	0ce78663          	beq	a5,a4,68c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5c4:	06300713          	li	a4,99
 5c8:	0ee78e63          	beq	a5,a4,6c4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5cc:	11478863          	beq	a5,s4,6dc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5d0:	85d2                	mv	a1,s4
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	e92080e7          	jalr	-366(ra) # 466 <putc>
        putc(fd, c);
 5dc:	85ca                	mv	a1,s2
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	e86080e7          	jalr	-378(ra) # 466 <putc>
      }
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	b765                	j	592 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5ec:	008b0913          	addi	s2,s6,8
 5f0:	4685                	li	a3,1
 5f2:	4629                	li	a2,10
 5f4:	000b2583          	lw	a1,0(s6)
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	e8e080e7          	jalr	-370(ra) # 488 <printint>
 602:	8b4a                	mv	s6,s2
      state = 0;
 604:	4981                	li	s3,0
 606:	b771                	j	592 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 608:	008b0913          	addi	s2,s6,8
 60c:	4681                	li	a3,0
 60e:	4629                	li	a2,10
 610:	000b2583          	lw	a1,0(s6)
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	e72080e7          	jalr	-398(ra) # 488 <printint>
 61e:	8b4a                	mv	s6,s2
      state = 0;
 620:	4981                	li	s3,0
 622:	bf85                	j	592 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 624:	008b0913          	addi	s2,s6,8
 628:	4681                	li	a3,0
 62a:	4641                	li	a2,16
 62c:	000b2583          	lw	a1,0(s6)
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	e56080e7          	jalr	-426(ra) # 488 <printint>
 63a:	8b4a                	mv	s6,s2
      state = 0;
 63c:	4981                	li	s3,0
 63e:	bf91                	j	592 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 640:	008b0793          	addi	a5,s6,8
 644:	f8f43423          	sd	a5,-120(s0)
 648:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 64c:	03000593          	li	a1,48
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	e14080e7          	jalr	-492(ra) # 466 <putc>
  putc(fd, 'x');
 65a:	85ea                	mv	a1,s10
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	e08080e7          	jalr	-504(ra) # 466 <putc>
 666:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 668:	03c9d793          	srli	a5,s3,0x3c
 66c:	97de                	add	a5,a5,s7
 66e:	0007c583          	lbu	a1,0(a5)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	df2080e7          	jalr	-526(ra) # 466 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 67c:	0992                	slli	s3,s3,0x4
 67e:	397d                	addiw	s2,s2,-1
 680:	fe0914e3          	bnez	s2,668 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 684:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 688:	4981                	li	s3,0
 68a:	b721                	j	592 <vprintf+0x60>
        s = va_arg(ap, char*);
 68c:	008b0993          	addi	s3,s6,8
 690:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 694:	02090163          	beqz	s2,6b6 <vprintf+0x184>
        while(*s != 0){
 698:	00094583          	lbu	a1,0(s2)
 69c:	c9a1                	beqz	a1,6ec <vprintf+0x1ba>
          putc(fd, *s);
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	dc6080e7          	jalr	-570(ra) # 466 <putc>
          s++;
 6a8:	0905                	addi	s2,s2,1
        while(*s != 0){
 6aa:	00094583          	lbu	a1,0(s2)
 6ae:	f9e5                	bnez	a1,69e <vprintf+0x16c>
        s = va_arg(ap, char*);
 6b0:	8b4e                	mv	s6,s3
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bdf9                	j	592 <vprintf+0x60>
          s = "(null)";
 6b6:	00000917          	auipc	s2,0x0
 6ba:	4f290913          	addi	s2,s2,1266 # ba8 <tournament_release+0x11e>
        while(*s != 0){
 6be:	02800593          	li	a1,40
 6c2:	bff1                	j	69e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6c4:	008b0913          	addi	s2,s6,8
 6c8:	000b4583          	lbu	a1,0(s6)
 6cc:	8556                	mv	a0,s5
 6ce:	00000097          	auipc	ra,0x0
 6d2:	d98080e7          	jalr	-616(ra) # 466 <putc>
 6d6:	8b4a                	mv	s6,s2
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	bd65                	j	592 <vprintf+0x60>
        putc(fd, c);
 6dc:	85d2                	mv	a1,s4
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	d86080e7          	jalr	-634(ra) # 466 <putc>
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	b565                	j	592 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ec:	8b4e                	mv	s6,s3
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	b54d                	j	592 <vprintf+0x60>
    }
  }
}
 6f2:	70e6                	ld	ra,120(sp)
 6f4:	7446                	ld	s0,112(sp)
 6f6:	74a6                	ld	s1,104(sp)
 6f8:	7906                	ld	s2,96(sp)
 6fa:	69e6                	ld	s3,88(sp)
 6fc:	6a46                	ld	s4,80(sp)
 6fe:	6aa6                	ld	s5,72(sp)
 700:	6b06                	ld	s6,64(sp)
 702:	7be2                	ld	s7,56(sp)
 704:	7c42                	ld	s8,48(sp)
 706:	7ca2                	ld	s9,40(sp)
 708:	7d02                	ld	s10,32(sp)
 70a:	6de2                	ld	s11,24(sp)
 70c:	6109                	addi	sp,sp,128
 70e:	8082                	ret

0000000000000710 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 710:	715d                	addi	sp,sp,-80
 712:	ec06                	sd	ra,24(sp)
 714:	e822                	sd	s0,16(sp)
 716:	1000                	addi	s0,sp,32
 718:	e010                	sd	a2,0(s0)
 71a:	e414                	sd	a3,8(s0)
 71c:	e818                	sd	a4,16(s0)
 71e:	ec1c                	sd	a5,24(s0)
 720:	03043023          	sd	a6,32(s0)
 724:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 728:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 72c:	8622                	mv	a2,s0
 72e:	00000097          	auipc	ra,0x0
 732:	e04080e7          	jalr	-508(ra) # 532 <vprintf>
}
 736:	60e2                	ld	ra,24(sp)
 738:	6442                	ld	s0,16(sp)
 73a:	6161                	addi	sp,sp,80
 73c:	8082                	ret

000000000000073e <printf>:

void
printf(const char *fmt, ...)
{
 73e:	711d                	addi	sp,sp,-96
 740:	ec06                	sd	ra,24(sp)
 742:	e822                	sd	s0,16(sp)
 744:	1000                	addi	s0,sp,32
 746:	e40c                	sd	a1,8(s0)
 748:	e810                	sd	a2,16(s0)
 74a:	ec14                	sd	a3,24(s0)
 74c:	f018                	sd	a4,32(s0)
 74e:	f41c                	sd	a5,40(s0)
 750:	03043823          	sd	a6,48(s0)
 754:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 758:	00840613          	addi	a2,s0,8
 75c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 760:	85aa                	mv	a1,a0
 762:	4505                	li	a0,1
 764:	00000097          	auipc	ra,0x0
 768:	dce080e7          	jalr	-562(ra) # 532 <vprintf>
}
 76c:	60e2                	ld	ra,24(sp)
 76e:	6442                	ld	s0,16(sp)
 770:	6125                	addi	sp,sp,96
 772:	8082                	ret

0000000000000774 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 774:	1141                	addi	sp,sp,-16
 776:	e422                	sd	s0,8(sp)
 778:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 77a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77e:	00001797          	auipc	a5,0x1
 782:	8827b783          	ld	a5,-1918(a5) # 1000 <freep>
 786:	a805                	j	7b6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 788:	4618                	lw	a4,8(a2)
 78a:	9db9                	addw	a1,a1,a4
 78c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 790:	6398                	ld	a4,0(a5)
 792:	6318                	ld	a4,0(a4)
 794:	fee53823          	sd	a4,-16(a0)
 798:	a091                	j	7dc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 79a:	ff852703          	lw	a4,-8(a0)
 79e:	9e39                	addw	a2,a2,a4
 7a0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7a2:	ff053703          	ld	a4,-16(a0)
 7a6:	e398                	sd	a4,0(a5)
 7a8:	a099                	j	7ee <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7aa:	6398                	ld	a4,0(a5)
 7ac:	00e7e463          	bltu	a5,a4,7b4 <free+0x40>
 7b0:	00e6ea63          	bltu	a3,a4,7c4 <free+0x50>
{
 7b4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b6:	fed7fae3          	bgeu	a5,a3,7aa <free+0x36>
 7ba:	6398                	ld	a4,0(a5)
 7bc:	00e6e463          	bltu	a3,a4,7c4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c0:	fee7eae3          	bltu	a5,a4,7b4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7c4:	ff852583          	lw	a1,-8(a0)
 7c8:	6390                	ld	a2,0(a5)
 7ca:	02059713          	slli	a4,a1,0x20
 7ce:	9301                	srli	a4,a4,0x20
 7d0:	0712                	slli	a4,a4,0x4
 7d2:	9736                	add	a4,a4,a3
 7d4:	fae60ae3          	beq	a2,a4,788 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7d8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7dc:	4790                	lw	a2,8(a5)
 7de:	02061713          	slli	a4,a2,0x20
 7e2:	9301                	srli	a4,a4,0x20
 7e4:	0712                	slli	a4,a4,0x4
 7e6:	973e                	add	a4,a4,a5
 7e8:	fae689e3          	beq	a3,a4,79a <free+0x26>
  } else
    p->s.ptr = bp;
 7ec:	e394                	sd	a3,0(a5)
  freep = p;
 7ee:	00001717          	auipc	a4,0x1
 7f2:	80f73923          	sd	a5,-2030(a4) # 1000 <freep>
}
 7f6:	6422                	ld	s0,8(sp)
 7f8:	0141                	addi	sp,sp,16
 7fa:	8082                	ret

00000000000007fc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7fc:	7139                	addi	sp,sp,-64
 7fe:	fc06                	sd	ra,56(sp)
 800:	f822                	sd	s0,48(sp)
 802:	f426                	sd	s1,40(sp)
 804:	f04a                	sd	s2,32(sp)
 806:	ec4e                	sd	s3,24(sp)
 808:	e852                	sd	s4,16(sp)
 80a:	e456                	sd	s5,8(sp)
 80c:	e05a                	sd	s6,0(sp)
 80e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 810:	02051493          	slli	s1,a0,0x20
 814:	9081                	srli	s1,s1,0x20
 816:	04bd                	addi	s1,s1,15
 818:	8091                	srli	s1,s1,0x4
 81a:	0014899b          	addiw	s3,s1,1
 81e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 820:	00000517          	auipc	a0,0x0
 824:	7e053503          	ld	a0,2016(a0) # 1000 <freep>
 828:	c515                	beqz	a0,854 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 82c:	4798                	lw	a4,8(a5)
 82e:	02977f63          	bgeu	a4,s1,86c <malloc+0x70>
 832:	8a4e                	mv	s4,s3
 834:	0009871b          	sext.w	a4,s3
 838:	6685                	lui	a3,0x1
 83a:	00d77363          	bgeu	a4,a3,840 <malloc+0x44>
 83e:	6a05                	lui	s4,0x1
 840:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 844:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 848:	00000917          	auipc	s2,0x0
 84c:	7b890913          	addi	s2,s2,1976 # 1000 <freep>
  if(p == (char*)-1)
 850:	5afd                	li	s5,-1
 852:	a88d                	j	8c4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 854:	00001797          	auipc	a5,0x1
 858:	9cc78793          	addi	a5,a5,-1588 # 1220 <base>
 85c:	00000717          	auipc	a4,0x0
 860:	7af73223          	sd	a5,1956(a4) # 1000 <freep>
 864:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 866:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 86a:	b7e1                	j	832 <malloc+0x36>
      if(p->s.size == nunits)
 86c:	02e48b63          	beq	s1,a4,8a2 <malloc+0xa6>
        p->s.size -= nunits;
 870:	4137073b          	subw	a4,a4,s3
 874:	c798                	sw	a4,8(a5)
        p += p->s.size;
 876:	1702                	slli	a4,a4,0x20
 878:	9301                	srli	a4,a4,0x20
 87a:	0712                	slli	a4,a4,0x4
 87c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 87e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 882:	00000717          	auipc	a4,0x0
 886:	76a73f23          	sd	a0,1918(a4) # 1000 <freep>
      return (void*)(p + 1);
 88a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 88e:	70e2                	ld	ra,56(sp)
 890:	7442                	ld	s0,48(sp)
 892:	74a2                	ld	s1,40(sp)
 894:	7902                	ld	s2,32(sp)
 896:	69e2                	ld	s3,24(sp)
 898:	6a42                	ld	s4,16(sp)
 89a:	6aa2                	ld	s5,8(sp)
 89c:	6b02                	ld	s6,0(sp)
 89e:	6121                	addi	sp,sp,64
 8a0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8a2:	6398                	ld	a4,0(a5)
 8a4:	e118                	sd	a4,0(a0)
 8a6:	bff1                	j	882 <malloc+0x86>
  hp->s.size = nu;
 8a8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ac:	0541                	addi	a0,a0,16
 8ae:	00000097          	auipc	ra,0x0
 8b2:	ec6080e7          	jalr	-314(ra) # 774 <free>
  return freep;
 8b6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ba:	d971                	beqz	a0,88e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8be:	4798                	lw	a4,8(a5)
 8c0:	fa9776e3          	bgeu	a4,s1,86c <malloc+0x70>
    if(p == freep)
 8c4:	00093703          	ld	a4,0(s2)
 8c8:	853e                	mv	a0,a5
 8ca:	fef719e3          	bne	a4,a5,8bc <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8ce:	8552                	mv	a0,s4
 8d0:	00000097          	auipc	ra,0x0
 8d4:	b5e080e7          	jalr	-1186(ra) # 42e <sbrk>
  if(p == (char*)-1)
 8d8:	fd5518e3          	bne	a0,s5,8a8 <malloc+0xac>
        return 0;
 8dc:	4501                	li	a0,0
 8de:	bf45                	j	88e <malloc+0x92>

00000000000008e0 <tournament_create>:
    l++;
  }
  return l;
}

int tournament_create(int processes) {
 8e0:	7179                	addi	sp,sp,-48
 8e2:	f406                	sd	ra,40(sp)
 8e4:	f022                	sd	s0,32(sp)
 8e6:	ec26                	sd	s1,24(sp)
 8e8:	e84a                	sd	s2,16(sp)
 8ea:	e44e                	sd	s3,8(sp)
 8ec:	e052                	sd	s4,0(sp)
 8ee:	1800                	addi	s0,sp,48
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 8f0:	fff5071b          	addiw	a4,a0,-1
 8f4:	47bd                	li	a5,15
 8f6:	00e7ee63          	bltu	a5,a4,912 <tournament_create+0x32>
 8fa:	89aa                	mv	s3,a0
    return x > 0 && (x & (x - 1)) == 0;
 8fc:	8a3a                	mv	s4,a4
 8fe:	00e574b3          	and	s1,a0,a4
 902:	c0b9                	beqz	s1,948 <tournament_create+0x68>
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 904:	54fd                	li	s1,-1
 906:	a809                	j	918 <tournament_create+0x38>
   for(int i = 1; i < processes  ; i++){
        int pid = fork() ;
        if(pid < 0)
            return -1 ;
        if(pid == 0){
            trnmnt_idx = i ;
 908:	00000797          	auipc	a5,0x0
 90c:	7097a023          	sw	s1,1792(a5) # 1008 <trnmnt_idx>
            return trnmnt_idx ;
 910:	a021                	j	918 <tournament_create+0x38>
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;
 912:	54fd                	li	s1,-1
 914:	a011                	j	918 <tournament_create+0x38>
        return -1; //failed to create lock
 916:	54fd                	li	s1,-1
        }
   }
return trnmnt_idx ;
}
 918:	8526                	mv	a0,s1
 91a:	70a2                	ld	ra,40(sp)
 91c:	7402                	ld	s0,32(sp)
 91e:	64e2                	ld	s1,24(sp)
 920:	6942                	ld	s2,16(sp)
 922:	69a2                	ld	s3,8(sp)
 924:	6a02                	ld	s4,0(sp)
 926:	6145                	addi	sp,sp,48
 928:	8082                	ret
            return -1 ;
 92a:	54fd                	li	s1,-1
 92c:	b7f5                	j	918 <tournament_create+0x38>
   num_levels = log2(processes) ;
 92e:	00000797          	auipc	a5,0x0
 932:	6e07a123          	sw	zero,1762(a5) # 1010 <num_levels>
   trnmnt_idx = 0;
 936:	00000797          	auipc	a5,0x0
 93a:	6c07a923          	sw	zero,1746(a5) # 1008 <trnmnt_idx>
return trnmnt_idx ;
 93e:	00000497          	auipc	s1,0x0
 942:	6ca4a483          	lw	s1,1738(s1) # 1008 <trnmnt_idx>
 946:	bfc9                	j	918 <tournament_create+0x38>
   num_processes = processes ;
 948:	00000797          	auipc	a5,0x0
 94c:	6ca7a223          	sw	a0,1732(a5) # 100c <num_processes>
  if (n <= 1) 
 950:	4785                	li	a5,1
 952:	fca7dee3          	bge	a5,a0,92e <tournament_create+0x4e>
  int l = 0;
 956:	8726                	mv	a4,s1
 958:	87aa                	mv	a5,a0
  while (n > 1) {
 95a:	458d                	li	a1,3
    n /= 2;
 95c:	86be                	mv	a3,a5
 95e:	01f7d61b          	srliw	a2,a5,0x1f
 962:	9fb1                	addw	a5,a5,a2
 964:	4017d79b          	sraiw	a5,a5,0x1
    l++;
 968:	2705                	addiw	a4,a4,1
  while (n > 1) {
 96a:	fed5c9e3          	blt	a1,a3,95c <tournament_create+0x7c>
   num_levels = log2(processes) ;
 96e:	00000797          	auipc	a5,0x0
 972:	6ae7a123          	sw	a4,1698(a5) # 1010 <num_levels>
   for(int i = 0; i < processes -1 ; i++){
 976:	00001917          	auipc	s2,0x1
 97a:	8ba90913          	addi	s2,s2,-1862 # 1230 <lock_ids>
    lock_ids[i]= peterson_create() ;
 97e:	00000097          	auipc	ra,0x0
 982:	ac8080e7          	jalr	-1336(ra) # 446 <peterson_create>
 986:	00a92023          	sw	a0,0(s2)
    if(lock_ids[i] <0){
 98a:	f80546e3          	bltz	a0,916 <tournament_create+0x36>
   for(int i = 0; i < processes -1 ; i++){
 98e:	2485                	addiw	s1,s1,1
 990:	0911                	addi	s2,s2,4
 992:	ff44c6e3          	blt	s1,s4,97e <tournament_create+0x9e>
   trnmnt_idx = 0;
 996:	00000797          	auipc	a5,0x0
 99a:	6607a923          	sw	zero,1650(a5) # 1008 <trnmnt_idx>
   for(int i = 1; i < processes  ; i++){
 99e:	4785                	li	a5,1
 9a0:	f937dfe3          	bge	a5,s3,93e <tournament_create+0x5e>
 9a4:	4485                	li	s1,1
        int pid = fork() ;
 9a6:	00000097          	auipc	ra,0x0
 9aa:	9f8080e7          	jalr	-1544(ra) # 39e <fork>
        if(pid < 0)
 9ae:	f6054ee3          	bltz	a0,92a <tournament_create+0x4a>
        if(pid == 0){
 9b2:	d939                	beqz	a0,908 <tournament_create+0x28>
   for(int i = 1; i < processes  ; i++){
 9b4:	2485                	addiw	s1,s1,1
 9b6:	fe9998e3          	bne	s3,s1,9a6 <tournament_create+0xc6>
 9ba:	b751                	j	93e <tournament_create+0x5e>

00000000000009bc <tournament_acquire>:

int tournament_acquire(void){ 

    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 9bc:	00000797          	auipc	a5,0x0
 9c0:	64c7a783          	lw	a5,1612(a5) # 1008 <trnmnt_idx>
 9c4:	0a07cd63          	bltz	a5,a7e <tournament_acquire+0xc2>
 9c8:	00000717          	auipc	a4,0x0
 9cc:	64872703          	lw	a4,1608(a4) # 1010 <num_levels>
 9d0:	0ae05963          	blez	a4,a82 <tournament_acquire+0xc6>

    for(int lvl = 0 ; lvl < num_levels ; lvl++){
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 9d4:	fff7069b          	addiw	a3,a4,-1
 9d8:	4585                	li	a1,1
 9da:	00d595bb          	sllw	a1,a1,a3
 9de:	8dfd                	and	a1,a1,a5
 9e0:	40d5d5bb          	sraw	a1,a1,a3
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 9e4:	40e7d7bb          	sraw	a5,a5,a4
        int lockidx = lockl + (1<<lvl) -1 ;
        if(lockidx>=MAX_LOCKS) return -1 ;
 9e8:	4739                	li	a4,14
 9ea:	08f74e63          	blt	a4,a5,a86 <tournament_acquire+0xca>
int tournament_acquire(void){ 
 9ee:	7139                	addi	sp,sp,-64
 9f0:	fc06                	sd	ra,56(sp)
 9f2:	f822                	sd	s0,48(sp)
 9f4:	f426                	sd	s1,40(sp)
 9f6:	f04a                	sd	s2,32(sp)
 9f8:	ec4e                	sd	s3,24(sp)
 9fa:	e852                	sd	s4,16(sp)
 9fc:	e456                	sd	s5,8(sp)
 9fe:	e05a                	sd	s6,0(sp)
 a00:	0080                	addi	s0,sp,64
    for(int lvl = 0 ; lvl < num_levels ; lvl++){
 a02:	4481                	li	s1,0

        peterson_acquire(lock_ids[lockidx] , role) ;
 a04:	00001a17          	auipc	s4,0x1
 a08:	82ca0a13          	addi	s4,s4,-2004 # 1230 <lock_ids>
    for(int lvl = 0 ; lvl < num_levels ; lvl++){
 a0c:	00000997          	auipc	s3,0x0
 a10:	60498993          	addi	s3,s3,1540 # 1010 <num_levels>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 a14:	00000b17          	auipc	s6,0x0
 a18:	5f4b0b13          	addi	s6,s6,1524 # 1008 <trnmnt_idx>
 a1c:	4905                	li	s2,1
        if(lockidx>=MAX_LOCKS) return -1 ;
 a1e:	4ab9                	li	s5,14
        peterson_acquire(lock_ids[lockidx] , role) ;
 a20:	078a                	slli	a5,a5,0x2
 a22:	97d2                	add	a5,a5,s4
 a24:	4388                	lw	a0,0(a5)
 a26:	00000097          	auipc	ra,0x0
 a2a:	a28080e7          	jalr	-1496(ra) # 44e <peterson_acquire>
    for(int lvl = 0 ; lvl < num_levels ; lvl++){
 a2e:	0014871b          	addiw	a4,s1,1
 a32:	0007049b          	sext.w	s1,a4
 a36:	0009a783          	lw	a5,0(s3)
 a3a:	02f4d763          	bge	s1,a5,a68 <tournament_acquire+0xac>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 a3e:	40e7873b          	subw	a4,a5,a4
 a42:	fff7079b          	addiw	a5,a4,-1
 a46:	000b2683          	lw	a3,0(s6)
 a4a:	00f915bb          	sllw	a1,s2,a5
 a4e:	8df5                	and	a1,a1,a3
 a50:	40f5d5bb          	sraw	a1,a1,a5
        int lockidx = lockl + (1<<lvl) -1 ;
 a54:	009917bb          	sllw	a5,s2,s1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 a58:	40e6d73b          	sraw	a4,a3,a4
        int lockidx = lockl + (1<<lvl) -1 ;
 a5c:	9fb9                	addw	a5,a5,a4
 a5e:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 a60:	fcfad0e3          	bge	s5,a5,a20 <tournament_acquire+0x64>
 a64:	557d                	li	a0,-1
 a66:	a011                	j	a6a <tournament_acquire+0xae>

    }
return 0 ;
 a68:	4501                	li	a0,0
}
 a6a:	70e2                	ld	ra,56(sp)
 a6c:	7442                	ld	s0,48(sp)
 a6e:	74a2                	ld	s1,40(sp)
 a70:	7902                	ld	s2,32(sp)
 a72:	69e2                	ld	s3,24(sp)
 a74:	6a42                	ld	s4,16(sp)
 a76:	6aa2                	ld	s5,8(sp)
 a78:	6b02                	ld	s6,0(sp)
 a7a:	6121                	addi	sp,sp,64
 a7c:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 a7e:	557d                	li	a0,-1
 a80:	8082                	ret
 a82:	557d                	li	a0,-1
 a84:	8082                	ret
        if(lockidx>=MAX_LOCKS) return -1 ;
 a86:	557d                	li	a0,-1
}
 a88:	8082                	ret

0000000000000a8a <tournament_release>:

int tournament_release(void) {

    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 a8a:	00000797          	auipc	a5,0x0
 a8e:	57e7a783          	lw	a5,1406(a5) # 1008 <trnmnt_idx>
 a92:	0a07cf63          	bltz	a5,b50 <tournament_release+0xc6>
int tournament_release(void) {
 a96:	715d                	addi	sp,sp,-80
 a98:	e486                	sd	ra,72(sp)
 a9a:	e0a2                	sd	s0,64(sp)
 a9c:	fc26                	sd	s1,56(sp)
 a9e:	f84a                	sd	s2,48(sp)
 aa0:	f44e                	sd	s3,40(sp)
 aa2:	f052                	sd	s4,32(sp)
 aa4:	ec56                	sd	s5,24(sp)
 aa6:	e85a                	sd	s6,16(sp)
 aa8:	e45e                	sd	s7,8(sp)
 aaa:	0880                	addi	s0,sp,80
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 aac:	00000497          	auipc	s1,0x0
 ab0:	5644a483          	lw	s1,1380(s1) # 1010 <num_levels>
 ab4:	0a905063          	blez	s1,b54 <tournament_release+0xca>

    for(int lvl = num_levels -1 ; lvl >=0  ; lvl--){
 ab8:	34fd                	addiw	s1,s1,-1
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 aba:	0017f593          	andi	a1,a5,1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 abe:	4017d79b          	sraiw	a5,a5,0x1
        int lockidx = lockl + (1<<lvl) -1 ;
 ac2:	4705                	li	a4,1
 ac4:	0097173b          	sllw	a4,a4,s1
 ac8:	9fb9                	addw	a5,a5,a4
 aca:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 acc:	4739                	li	a4,14
 ace:	08f74563          	blt	a4,a5,b58 <tournament_release+0xce>

        peterson_release(lock_ids[lockidx] , role) ;
 ad2:	00000a17          	auipc	s4,0x0
 ad6:	75ea0a13          	addi	s4,s4,1886 # 1230 <lock_ids>
    for(int lvl = num_levels -1 ; lvl >=0  ; lvl--){
 ada:	59fd                	li	s3,-1
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 adc:	00000b97          	auipc	s7,0x0
 ae0:	534b8b93          	addi	s7,s7,1332 # 1010 <num_levels>
 ae4:	00000b17          	auipc	s6,0x0
 ae8:	524b0b13          	addi	s6,s6,1316 # 1008 <trnmnt_idx>
 aec:	4905                	li	s2,1
        if(lockidx>=MAX_LOCKS) return -1 ;
 aee:	4ab9                	li	s5,14
        peterson_release(lock_ids[lockidx] , role) ;
 af0:	078a                	slli	a5,a5,0x2
 af2:	97d2                	add	a5,a5,s4
 af4:	4388                	lw	a0,0(a5)
 af6:	00000097          	auipc	ra,0x0
 afa:	960080e7          	jalr	-1696(ra) # 456 <peterson_release>
    for(int lvl = num_levels -1 ; lvl >=0  ; lvl--){
 afe:	fff4869b          	addiw	a3,s1,-1
 b02:	0006849b          	sext.w	s1,a3
 b06:	03348963          	beq	s1,s3,b38 <tournament_release+0xae>
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
 b0a:	000ba703          	lw	a4,0(s7)
 b0e:	40d706bb          	subw	a3,a4,a3
 b12:	fff6879b          	addiw	a5,a3,-1
 b16:	000b2703          	lw	a4,0(s6)
 b1a:	00f915bb          	sllw	a1,s2,a5
 b1e:	8df9                	and	a1,a1,a4
 b20:	40f5d5bb          	sraw	a1,a1,a5
        int lockidx = lockl + (1<<lvl) -1 ;
 b24:	009917bb          	sllw	a5,s2,s1
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
 b28:	40d7573b          	sraw	a4,a4,a3
        int lockidx = lockl + (1<<lvl) -1 ;
 b2c:	9fb9                	addw	a5,a5,a4
 b2e:	37fd                	addiw	a5,a5,-1
        if(lockidx>=MAX_LOCKS) return -1 ;
 b30:	fcfad0e3          	bge	s5,a5,af0 <tournament_release+0x66>
 b34:	557d                	li	a0,-1
 b36:	a011                	j	b3a <tournament_release+0xb0>

    }
return 0 ;
 b38:	4501                	li	a0,0


}
 b3a:	60a6                	ld	ra,72(sp)
 b3c:	6406                	ld	s0,64(sp)
 b3e:	74e2                	ld	s1,56(sp)
 b40:	7942                	ld	s2,48(sp)
 b42:	79a2                	ld	s3,40(sp)
 b44:	7a02                	ld	s4,32(sp)
 b46:	6ae2                	ld	s5,24(sp)
 b48:	6b42                	ld	s6,16(sp)
 b4a:	6ba2                	ld	s7,8(sp)
 b4c:	6161                	addi	sp,sp,80
 b4e:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 b50:	557d                	li	a0,-1
}
 b52:	8082                	ret
    if(trnmnt_idx < 0 || num_levels <=0) return -1;
 b54:	557d                	li	a0,-1
 b56:	b7d5                	j	b3a <tournament_release+0xb0>
        if(lockidx>=MAX_LOCKS) return -1 ;
 b58:	557d                	li	a0,-1
 b5a:	b7c5                	j	b3a <tournament_release+0xb0>
