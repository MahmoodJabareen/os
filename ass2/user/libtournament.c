#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int tournament_create(int processes) {
    if( processes !=1 &&processes !=2 && processes !=4 && processes !=8 && processes !=16 )
        return -1 ; // invalid number of locks
    
    int trnmnt_id = -1 ; 
    int lock_id = 0 ;
    int pid ;

    for(int i = 1 ; i < processes ; i++ ){
        if(peterson_create() < 0) {
            return -1 ; // if one failed stop 
        }
    }
    

}

int tournament_acquire(void) {}

int tournament_release(void){}
