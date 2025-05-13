#include "kernel/types.h"
#include "kernel/stat.h"
#include "user.h"



int main(int argc , char** argv){
    if(argc !=2){
        fprintf(2 , "invalid args\n") ;
        exit(1);
    }

    int n= atoi(argv[1]) ;

    int tournament_id = tournament_create(n) ;

    if(tournament_id < 0){
        fprintf(2 , "failed creating tournament \n");
        exit(1);
    }

    if (tournament_acquire() < 0) {
        fprintf(2, "failed acquiring\n");
        exit(1);
    }


    printf("Process with PID %d, Tournament ID %d has entered the critical section\n", getpid(), tournament_id);
    sleep(10);  // hold the lock for a while to test mutual exclusion
    printf("Process with PID %d, Tournament ID %d is leaving the critical section\n", getpid(), tournament_id);

    if (tournament_release() < 0) {
        fprintf(2, "failed releasing\n");
        exit(1);
    }

    exit(0) ;


}