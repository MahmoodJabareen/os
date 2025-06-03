
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/riscv.h"

#define NCHILDREN 4
#define MAX_MSG_LENGTH 50
static int children_pids[NCHILDREN];
static uint64 vas[NCHILDREN];

char *shared_buffer = 0;

// helper function to use instead of snprintf for now
int snprintf_from_temu(char *buf, int index)
{
    const char *prefix = "[child ";
    const char *suffix = "] Hello!\n";

    int i = 0;

    // Copy prefix
    for (int j = 0; prefix[j] != '\0'; j++)
    {
        buf[i++] = prefix[j];
    }

    // Handle index conversion (digits in reverse order first)
    char digits[10];
    int d = 0;

    if (index == 0)
    {
        digits[d++] = '0';
    }
    else
    {
        while (index > 0)
        {
            digits[d++] = '0' + (index % 10);
            index /= 10;
        }
    }

    // Append digits in correct order
    for (int j = d - 1; j >= 0; j--)
    {
        buf[i++] = digits[j];
    }

    // Copy suffix
    for (int j = 0; suffix[j] != '\0'; j++)
    {
        buf[i++] = suffix[j];
    }

    buf[i] = '\0'; // null-terminate
    return i;      // return length of message
}

void write_message(int child_index, uint64 va, const char *message)
{
    // write the message to the shared buffer
    int msg_length = strlen(message);
    uint64 address = va;
    while ((uint64)(address + msg_length + 4) < (uint64)(va + PGSIZE))
    {
        uint32 new_header = (child_index << 16) | (msg_length & 0xFFFF);
        if (((uint32)__sync_val_compare_and_swap((uint32 *)address, (uint32)0, new_header)) == 0)
        {
            // Successfully wrote the header, now write the message
            memcpy((uint64 *)(address + 4), message, msg_length);
            //break; // Exit the loop after writing the message
            sleep(10) ;
            
        }
        address += (uint64)(4 + msg_length);
        address = (uint64)((address) + 3) & ~3; // Advance and align to 4-byte boundary    }
    }
    exit(0);
}

void read_message(uint64 va)
{
    // read the message from the shared buffer
    uint64 addr = va;
    while ((uint64)(addr + 4) < (uint64)(va + PGSIZE))
    {
        uint32 header = *(uint32 *)addr;
        if (header == 0)
        {
            // message not yet written
            continue;
        }

        uint16 child_index = header >> 16;
        uint16 msg_len = header & 0xFFFF;
        printf("[parent] Received message from child %d with length %d, at address: 0x%lx\n", child_index, msg_len, addr);
        char msg[MAX_MSG_LENGTH] ={'\0'};
        memcpy(msg, (uint64 *)(addr + 4), msg_len);
        // msg[msg_len] = '\0';  // important!
        printf("[parent %d] %s\n", child_index, msg);

        addr += 4 + msg_len;
        addr = ((addr) + 3) & ~3;
    }
    for (int i = 0; i < NCHILDREN; i++)
    {
        wait(0);
    }
}
int main()
{
    int parent_pid = getpid();

    shared_buffer = (char *)malloc(PGSIZE); // allocate the shared buffer
    if (shared_buffer == 0)
    {
        printf("Failed to allocate shared buffer\n");
        return -1;
    }
    for (int i = 0; i < NCHILDREN; i++)
    {
        children_pids[i] = fork();
        if (children_pids[i] == 0)
        {
            children_pids[i] = getpid();
        }
        if (children_pids[i] < 0)
        {
            printf("Failed to fork child %d\n", i);
            return -1;
        }
    }
    if (getpid() == parent_pid)
    {
        // start reading form the buffer
        read_message((uint64)shared_buffer);
    }
    else
    {
        // child
        // find the index of the child in the children_pids array
        int child_index = -1;
        for (int i = 0; i < NCHILDREN; i++)
        {
            if (children_pids[i] == getpid())
            {
                child_index = i;
                break;
            }
        }
        printf("%d", child_index);
        if (child_index == -1)
        {

            printf("Child not found in the list of children\n");
            return -1;
        }
        // map the shared buffer to the child's address space
        vas[child_index] = map_shared_pages(parent_pid, getpid(), (uint64)shared_buffer, PGSIZE);
        if (vas[child_index] < 0)
        {
            printf("Failed to map shared pages for child %d\n", getpid());
            return -1;
        }
        // printf("Child %d mapped shared buffer at address %p\n", getpid(), vas[child_index]);
        // write to the shared buffer
        char message[MAX_MSG_LENGTH];
        snprintf_from_temu(message, child_index);
        write_message(child_index, vas[child_index], message);
    }
    exit(0);
}