#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include <math.h>

int tournament_create(int processes) {
    if( processes !=1 &&processes !=2 && processes !=4 && processes !=8 && processes !=16 )
        return -1 ; // invalid number of locks
    
    int trnmnt_id = -1 ; 
    int lock_id = 0 ;
    int curr_pid ;

    for(int i = 1 ; i < processes ; i++ ){
        if(peterson_create() < 0) {
            return -1 ; // if one failed stop 
        }
    }
    
    for(int i = 0 ; i < processes ; i++){
        curr_pid = fork() ; 
        if(curr_pid < 0){ // fork failed 
            return -1 ;
        }
        else if(curr_pid == 0) {
            for(int level = 0 ; level < processes / 2 ; level++) {
                lock_id = i / (int)pow(2 , level) ;
                peterson_acquire(lock_id , i % 2) ;
            }
            exit(0) ;
        }
    }
    trnmnt_id = getpid() ; // parent id
    return trnmnt_id ;

}

int tournament_acquire(void) {}

int tournament_release(void){}
