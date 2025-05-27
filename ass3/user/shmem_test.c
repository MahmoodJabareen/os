// simple_shmem_test.c - Basic test to verify sharing works

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main() {
    printf("Simple Shared Memory Test\n");
    
    char *data = malloc(4096);
    if(!data) {
        printf("malloc failed\n");
        exit(1);
    }
    
    strcpy(data, "Original message");
    printf("Parent: %s (size: %d)\n", data, (int)getprocsize());
    
    int parent_pid = getpid();
    int pid = fork();
    
    if(pid == 0) {
        printf("Child before mapping (size: %d)\n", (int)getprocsize());
        
        uint64 addr = map_shared_pages(parent_pid,(uint64) data, 4096);
        if(addr == 0) {
            printf("Child: sharing failed\n");
            exit(1);
        }
        
        printf("Child after mapping (size: %d)\n", (int)getprocsize());
        
        char *shared = (char*)addr;
        strcpy(shared, "Hello daddy");
        printf("Child wrote: %s\n", shared);
        
        // Test unmapping
        if(unmap_shared_pages(addr, 4096) == 0) {
            printf("Child unmapped successfully (size: %d)\n", (int)getprocsize());
        }
        
        exit(0);
    } else {
        sleep(2);
        printf("Parent reads: %s\n", data);
        wait(0);
        free(data);
    }
    
    return 0;
}