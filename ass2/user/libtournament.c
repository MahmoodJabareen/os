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
   
}

int tournament_acquire(void) {}

int tournament_release(void){}
