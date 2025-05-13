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

    


}