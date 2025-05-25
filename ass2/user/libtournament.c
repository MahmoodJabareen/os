#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define MAX_PROCESSES 16
#define MAX_LOCKS (MAX_PROCESSES-1)

static int num_levels ;
static int num_processes ;
static int trnmnt_idx;
static int lock_ids[MAX_LOCKS] ; 

static int is_power_of_two(int x) {
    return x > 0 && (x & (x - 1)) == 0;
}
static int log2(int n) {
  if (n <= 1) 
    return 0;
  int l = 0;
  while (n > 1) {
    n /= 2;
    l++;
  }
  return l;
}

int tournament_create(int processes) {
   if(  processes <=0 ||processes > MAX_PROCESSES || !is_power_of_two(processes)) return -1 ;

   num_processes = processes ;
   num_levels = log2(processes) ;

   for(int i = 0; i < (processes -1) ; i++){
    lock_ids[i]= peterson_create() ;
    if(lock_ids[i] <0){
        return -1; //failed to create lock
    }
   }

   trnmnt_idx = 0;
   for(int i = 1; i < processes  ; i++){
        int pid = fork() ;
        if(pid < 0)
            return -1 ;
        if(pid == 0){
            trnmnt_idx = i ;
            break ;
        }
   }
return trnmnt_idx ;
}

int tournament_acquire(void){ 

    if(trnmnt_idx < 0 || num_levels <=0) return -1;

    for(int lvl = (num_levels -1) ; lvl >= 0 ; lvl--){
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
        int lockidx = lockl + (1<<lvl) -1 ;
        if(lockidx>=MAX_LOCKS) return -1 ;

        if(peterson_acquire(lock_ids[lockidx] , role) < 0)
        return -1;

    }
return 0 ;
}

int tournament_release(void) {

    if(trnmnt_idx < 0 || num_levels <=0) return -1;

    for(int lvl = 0 ; lvl < num_levels  ; lvl++){
        int role = (trnmnt_idx&(1<<(num_levels-lvl-1)))>>(num_levels-lvl-1) ;
        int lockl = trnmnt_idx>>(num_levels-lvl) ;
        int lockidx = lockl + (1<<lvl) -1 ;
        if(lockidx>=MAX_LOCKS) return -1 ;

        if (peterson_release(lock_ids[lockidx] , role) < 0)
        return -1; 

    }
return 0 ;


}