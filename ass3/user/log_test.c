#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/riscv.h"


#define NCHILDREN 4

static int children_pids[NCHILDREN] ;
static int vas[NCHILDREN] ;


int main(){
    int parent_pid = getpid() ;
    for(int i = 0 ; i<NCHILDREN ; i++){
        children_pids[i] = fork();
        if(children_pids[i] < 0)
            return -1 ;
    }

    if(getpid() == parent_pid){ // in parent
        char* shared_buffer = (char*) malloc(PGSIZE) ; // allocate the shared buffer
        for(int i = 0 ; i < NCHILDREN ; i++){
            vas[i] =  map_shared_pages(parent_pid , children_pids[i] , (uint64) shared_buffer , PGSIZE) ;
            if(vas[i] < 0){
                printf("Failed sharing .. \n") ;
            }
        }
    }
    

    return 0;
}