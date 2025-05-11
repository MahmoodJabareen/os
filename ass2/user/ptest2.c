#include "kernel/types.h"
#include "user/user.h"

int main() {
    int lockid = peterson_create();
    if (lockid < 0) {
        printf("Failed to create Peterson lock\n");
        exit(1);
    }

    int *shared_counter = (int *) malloc(sizeof(int));
    *shared_counter = 0;

    int pid = fork();

    // We assign roles: parent = 0, child = 1
    int turn = (pid == 0) ? 1 : 0;

    for (int i = 0; i < 1000; i++) {
        if (peterson_acquire(lockid, turn) < 0) {
            printf("Process %d failed to acquire lock\n", getpid());
            exit(1);
        }

        // Critical section
        int temp = *shared_counter;
        temp++;
        *shared_counter = temp;

        if (peterson_release(lockid, turn) < 0) {
            printf("Process %d failed to release lock\n", getpid());
            exit(1);
        }
    }

    if (pid != 0) {
        wait(0);  // Parent waits for child
        printf("Final value of shared_counter: %d\n", *shared_counter);
        peterson_destroy(lockid);
        free(shared_counter);
    }

    exit(0);
}
