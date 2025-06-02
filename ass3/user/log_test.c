// #include "kernel/types.h"
// #include "kernel/stat.h"
// #include "user/user.h"
// #include "kernel/riscv.h"
// #include <stdio.h>

// #define NCHILDREN 4
// #define MAX_MSG_LENGTH 15



// static int children_pids[NCHILDREN] ;
// static int ready[NCHILDREN] = {0};




// int main(){


//     char* shared_buffer = malloc(PGSIZE) ;
//     uint64 current_addr = (uint64) shared_buffer ;
//     uint64 end = (uint64) (shared_buffer + PGSIZE) ;
     
//     int parent_pid = getpid() ;
//     for(int i = 0 ; i < 4 ; i++){
//         int pid = fork();

//         if(pid < 0) { // child
//             printf("Fork failed... \n") ;
//         }
//         else if(pid == parent_pid){
//             children_pids[i] = pid ;
//         }
//     }

//     if(getpid() == parent_pid){
//         for(int i = 0 ; i < NCHILDREN ; i++){
//             map_shared_pages(parent_pid , children_pids[i] , (uint64)shared_buffer , PGSIZE) ; 
//             map_shared_pages(parent_pid , children_pids[i] , (uint64)ready[i] , sizeof(ready)) ;
//             ready[i] = 1 ;
//         }
//         while(current_addr < end ){
//             uint32 header = *(uint32 *) current_addr; 
//             uint16 index = header >> 16;
//             uint16 length = header & 0xFFFF ;
//             if(index != 0 ){
//                 char* msg_ptr = (char*) (current_addr + 4) ; 
//                 char buf[length] ;
//                 memcpy(buf , msg_ptr , length) ; 
//                 printf("Message (index %d, length %d): %s\n", index, length, buf);
//                 current_addr += 4 + length ;
//                 current_addr = (current_addr + 3) & ~3;
//             } 
//         }
//     }
//     else{//children


//     }



// }







#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/riscv.h"


//helper function to use instead of snprintf for now 
static int write_message(char *buf, int index) {
    const char *prefix = "[child ";
    const char *suffix = "] Hello!\n";

    int i = 0;

    // Copy prefix
    for (int j = 0; prefix[j] != '\0'; j++) {
        buf[i++] = prefix[j];
    }

    // Handle index conversion (digits in reverse order first)
    char digits[10];
    int d = 0;

    if (index == 0) {
        digits[d++] = '0';
    } else {
        while (index > 0) {
            digits[d++] = '0' + (index % 10);
            index /= 10;
        }
    }

    // Append digits in correct order
    for (int j = d - 1; j >= 0; j--) {
        buf[i++] = digits[j];
    }

    // Copy suffix
    for (int j = 0; suffix[j] != '\0'; j++) {
        buf[i++] = suffix[j];
    }

    buf[i] = '\0';  // null-terminate
    return i;       // return length of message
}


#define NCHILDREN 4
#define MAX_MSG_LENGTH 40
static int children_pids[NCHILDREN] ;
static int* ready;

int main(){
    int parent_pid = getpid() ;
    ready = malloc(sizeof(int)) ;
    char* shared_buffer = (char*)malloc(PGSIZE) ;
    *ready = 0 ;

    for(int i = 0 ; i < NCHILDREN ; i++){
        children_pids[i] = fork() ;
        if(children_pids[i] < 0) {
            printf("Failed Forking ..\n") ;
            exit(1) ;
        }
        if(children_pids[i] == 0){ // child proc
            while(*ready == 0){
                //do nothing until you are allowd to go
                ;
            }
            int index = i ; 
            char msg[MAX_MSG_LENGTH] ;
            int len ; 

            while(1){
                len = write_message(msg , index) ; //write the messgae and return the lenght
                uint64 addr = (uint64) shared_buffer ;
                uint64 end = addr + PGSIZE ;

                while(addr + 4 + len < end){
                    uint32* header = (uint32*) addr;
                    uint32 old_header = 0 ; //at first all of the segments are 0 valued 
                    uint32 new_header = (index << 16) | (len & 0xFFFF) ;// 4 bytes , 2 for index 2 for len for the process msg

                    if(__sync_val_compare_and_swap(header , old_header,new_header ) == old_header){
                        char* msg_ptr = (char*)(addr + 4) ;
                        memcpy(msg_ptr , msg , len) ; 
                        continue;
                    }
                    addr += 4 + len ;
                    addr = (addr + 3) & ~3;
                }
                if(addr + 4 + len > end) break;
            }
            exit(0);
        }
    }

    for(int i = 0 ; i < NCHILDREN ; i++){
        if(map_shared_pages(parent_pid , children_pids[i] , (uint64)shared_buffer , PGSIZE) < 0){
            printf("Failed mapping the buffer with child %d" , children_pids[i]) ;
            exit(1) ;
        }
        if(map_shared_pages(parent_pid , children_pids[i] , (uint64)ready , sizeof(int)) < 0){
            printf("Failed mapping the ready_sign with child %d" , children_pids[i]) ;
            exit(1) ;
        }
        
    }
    *ready = 1 ; // signal the children to start writing 

    uint64 addr = (uint64)shared_buffer ;
    uint64 end = (uint64)shared_buffer + PGSIZE ;

    while(1){
        if(addr + 4 >=end) break ;

        uint32* header = (uint32*) (shared_buffer) ;
        if(*header !=0){
            int index = (*header >>16 ) & 0xFFFF ;
            int length = (*header) & 0xFFFF ;

            char* msg_ptr = (char*) (addr + 4) ; 
            char msg[MAX_MSG_LENGTH] ;
            memcpy(msg_ptr , msg , length) ;
            printf("[parent] Message received from child %d :%s " , index , msg) ;
        }
        addr += addr + 4 + MAX_MSG_LENGTH ;
        addr = (addr + 3) & ~3;
    }
    for(int i = 0 ; i < NCHILDREN ; i++){
        wait(0) ;
    }
    exit(0) ;
}