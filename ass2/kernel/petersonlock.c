
#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "proc.h"
#include "defs.h"
#include "petersonlock.h"

#define NPETERSONLOCKS 16 

struct petersonlock petersonlocks[NPETERSONLOCKS] ;

void petersoninit(void) {
    for(int i = 0 ; i < NPETERSONLOCKS ; i++) {
        petersonlocks[i].flag[0] = 0 ;
        petersonlocks[i].flag[1] = 0 ; 
        petersonlocks[i].turn = -1;
        petersonlocks[i].used = 0 ;
    }
}

int peterson_create(void) {

    for (int i = 0 ; i < NPETERSONLOCKS ; i++) {
        if (__sync_lock_test_and_set(&petersonlocks[i].used, 1) == 0) {
            // reinitilize the fields avoiding wrong values from previous use of the lock
            petersonlocks[i].flag[0] = 0 ;
            petersonlocks[i].flag[1] = 0 ; 
            petersonlocks[i].turn = -1;
            __sync_synchronize() ; //ensures that the operations above are not interrupted 
            return i ; // return the lockid if found 
        }
    }
    return -1 ; // no lock was found to be created 

}
int peterson_acquire(int lock_id , int role) {
    if(lock_id >= NPETERSONLOCKS || lock_id < 0 || (role !=0 && role !=1) ) 
        return -1 ;  //invalid lockid or role
    
    struct petersonlock* plock = &petersonlocks[lock_id] ;
    
    
    
    int other = 1 - role ;

    __sync_lock_test_and_set(&plock->flag[role], 1);
    __sync_synchronize() ;

    plock->turn = other ;
    __sync_synchronize() ; 

    while(plock->flag[other] && plock->turn == other){
        yield();
        __sync_synchronize() ;
    }
    return 0 ; 
}
int peterson_release(int lock_id , int role){
    

    if(lock_id >= NPETERSONLOCKS || lock_id < 0 || (role !=0 && role !=1) ) 
        return -1 ;  //invalid lockid or role
    
    
    struct petersonlock* plock = &petersonlocks[lock_id] ;
    if (plock->used == 0)
        return -1;
    

    __sync_synchronize() ;
    __sync_lock_release(&plock->flag[role]) ; // atomically set the flag to 0
    __sync_synchronize() ;
    return 0 ;
}
int peterson_destroy(int lock_id){

    if(lock_id >= NPETERSONLOCKS || lock_id < 0 ) 
        return -1 ;  //invalid lockid or role
    
    struct petersonlock* plock = &petersonlocks[lock_id] ;
    __sync_synchronize() ;
    __sync_lock_release(&plock->used) ;
    __sync_synchronize() ;
    return 0 ;

}
