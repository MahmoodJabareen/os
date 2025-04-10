#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"


int main (int argc , char** argv) {
    int size = memsize() ;
    fprintf(1 , "memory size before allocation is %d \n" , size ) ;
    void* idk = malloc(20000) ;
    size = memsize() ;
    fprintf(1 , "memory size after allocation is %d \n" , size ) ;
    free(idk) ;
    size = memsize() ;
    fprintf(1 , "memory size after free is %d \n" , size ) ;
    exit(0,"") ;



}