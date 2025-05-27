#include "kernel/types.h"
#include "user/user.h"

#define PGSIZE 4096



int
main(int argc, char *argv[])
{
  int do_unmap = 1;
  if (argc > 1 && strcmp(argv[1], "nounmap") == 0) {
    do_unmap = 0;
  }

  void *initial_sz = sbrk(0);
  printf("Parent sz before fork: %p\n", initial_sz);

  int *shared = malloc(PGSIZE);
  if (!shared) {
    printf("malloc failed\n");
    exit(1);
  }

  int pid = fork();
  if (pid < 0) {
    printf("fork failed\n");
    exit(1);
  }

  if (pid == 0) {
    // Child process
    void *child_before = sbrk(0);
    printf("Child sz before mapping: %p\n", child_before);

    void *shared_child = map_shared_pages(getpid(), *shared, PGSIZE);
    if (!shared_child) {
      printf("Child failed to map shared memory\n");
      exit(1);
    }

    printf("Child sz after mapping: %p\n", sbrk(0));

    // Write to shared memory
    strcpy((char*)shared_child, "Hello daddy");

    if (do_unmap) {
      if (unmap_shared_pages(getpid(), shared_child, PGSIZE) < 0) {
        printf("Child failed to unmap\n");
        exit(1);
      }

      printf("Child sz after unmapping: %p\n", sbrk(0));

      // Test malloc after unmapping
      void *new_mem = malloc(PGSIZE);
      if (!new_mem) {
        printf("Child malloc failed after unmapping\n");
        exit(1);
      }

      printf("Child sz after malloc: %p\n", sbrk(0));
    } else {
      printf("Child exiting without unmapping (nounmap test)\n");
    }

    exit(0);

  } else {
    // Parent
    wait(0);
    printf("Parent sees message: %s\n", shared);

    printf("Parent sz after child exit: %p\n", sbrk(0));

    if (do_unmap) {
      if (unmap_shared_pages(getpid(), shared, PGSIZE) < 0) {
        printf("Parent failed to unmap\n");
        exit(1);
      }
      printf("Parent sz after unmapping: %p\n", sbrk(0));
    }

    exit(0);
  }
}
