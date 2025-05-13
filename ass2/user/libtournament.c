#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include <math.h>

#define MAX_PROCESSES 16
#define MAX_LOCK (MAX_PROCESSES-1)

int tournament_id = -1 ;
int num_levels = 0 ;
int num_processes = 0 ;
int* lock_ids = 0 ;

static int is_power_of_two(int x) {
    return x > 0 && (x & (x - 1)) == 0;
}

int tournament_create(int processes) {
   if(  processes > MAX_PROCESSES ||!is_power_of_two(processes)) return -1 ;

   num_processes = processes ;
   
   int temp = processes ;
   while(temp >>=1)
        num_levels ++ ;
    
   int total_locks = (1 << num_levels) -1 ;

   lock_ids = malloc(sizeof(int) * total_locks);
    if (!lock_ids)
        return -1;


    return 1 ;    
}

int tournament_acquire(void) { return 0;}

int tournament_release(void){ return 0;}
