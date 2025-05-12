#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "petersonlock.h"


uint64 sys_peterson_create(void){
   return  peterson_create() ;
}
uint64 sys_peterson_acquire(void){
    int lock_id ,  role ; 
    argint(0 , &lock_id) ;
    argint(1 , &role) ;

    return peterson_acquire(lock_id , role) ;
}
uint64 sys_peterson_release(void){
    int lock_id ,  role ; 
    argint(0 , &lock_id) ;
    argint(1 , &role) ;

    return peterson_release(lock_id , role) ;
}
uint64 sys_peterson_destroy(void){
    int lock_id  ; 
    argint(0 , &lock_id) ;
    return peterson_destroy(lock_id) ;
}

///test 