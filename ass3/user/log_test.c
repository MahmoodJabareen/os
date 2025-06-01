#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/riscv.h"
#include <stdio.h>

#define NCHILDREN 4
#define MSGLENGTH 15



static int children_pids[NCHILDREN] ;
static int ready[NCHILDREN] = {0};




int main(){


    char* shared_buffer = malloc(PGSIZE) ;
    uint64 current_addr = (uint64) shared_buffer ;
    uint64 end = (uint64) (shared_buffer + PGSIZE) ;
     
    int parent_pid = getpid() ;
    for(int i = 0 ; i < 4 ; i++){
        int pid = fork();

        if(pid < 0) { // child
            printf("Fork failed... \n") ;
        }
        else if(pid == parent_pid){
            children_pids[i] = pid ;
        }
    }

    if(getpid() == parent_pid){
        for(int i = 0 ; i < NCHILDREN ; i++){
            map_shared_pages(parent_pid , children_pids[i] , (uint64)shared_buffer , PGSIZE) ; 
            map_shared_pages(parent_pid , children_pids[i] , (uint64)ready[i] , sizeof(ready)) ;
            ready[i] = 1 ;
        }
        while(current_addr < end ){
            uint32 header = *(uint32 *) current_addr; 
            uint16 index = header >> 16;
            uint16 length = header & 0xFFFF ;
            if(index != 0 ){
                char* msg_ptr = (char*) (current_addr + 4) ; 
                char buf[length] ;
                memcpy(buf , msg_ptr , length) ; 
                printf("Message (index %d, length %d): %s\n", index, length, buf);
                current_addr += 4 + length ;
                current_addr = (current_addr + 3) & ~3;
            } 
        }
    }
    else{//children


    }



}


// int main(){
//     int parent_pid = getpid() ;
//     for(int i = 0 ; i<NCHILDREN ; i++){
//         children_pids[i] = fork();
//         if(children_pids[i] < 0)
//             return -1 ;
        
//         if(children_pids[i] == 0){//in child
//             int index = i ; 
//             sleep(100) ; //wait for parent to map (not the best solution )
//             char* shared_buffer = (char*)vas[index] ;

//             if(!shared_buffer){
//                 printf("Child %d has no shared buffer..\n " , index) ;
//                 exit(1) ;
//             }
//             //constructing the message
//             char msg[64] ;
//             int len = snprintf(msg , sizeof(msg) ,"Hello from child %d", index  );

//             uint64 addr  = (uint64) shared_buffer ;
//             uint64 end = addr + PGSIZE ;

//             //look for header 
//             while(addr + 4 + len < end){
//                 uint32* header = (uint32*) addr ;
//                 uint32 expected = 0 ;

//                 uint32 new_header = (index << 16) | (len & 0xFFFF) ;


//                 if(__sync_val_compare_and_swap(header , expected , new_header) == expected){

//                     //msg_ptr points to a shared memory 
//                     char* msg_ptr = (char*)(addr +4) ;
//                     for(int j = 0 ; j < len ; j++){
//                         msg_ptr[j] = msg[j] ;
//                     }
//                     break ;
//                 }
//                  // skip to next aligned slot
//                 addr += 4 + len;
//                 addr = (addr + 3) & ~3; 

//             }
//             exit(0);
//         }
//     }

//     if(getpid() == parent_pid){ // in parent
//         char* shared_buffer = (char*) malloc(PGSIZE) ; // allocate the shared buffer
//         for(int i = 0 ; i < NCHILDREN ; i++){
//             vas[i] =  map_shared_pages(parent_pid , children_pids[i] , (uint64) shared_buffer , PGSIZE) ;
//             if(vas[i] < 0){
//                 printf("Failed sharing .. \n") ;
//             }
//         }
//     }
    
    

//     return 0;
// }