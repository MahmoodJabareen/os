#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include <math.h>

#define MAX_PROCESSES 16
#define MAX_LOCKS (MAX_PROCESSES-1)

int tournament_id = -1 ;
int num_levels = 0 ;
int num_processes = 0 ;
int trnmnt_idx = 0;
int lock_ids[MAX_LOCKS] ; 

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

   for(int i = 0; i < processes -1 ; i++){
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
            return trnmnt_idx ;
        }
   }
return trnmnt_idx ;
}

int tournament_acquire(void) { return 0;}

int tournament_release(void){ return 0;}
