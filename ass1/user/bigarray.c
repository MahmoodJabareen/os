#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define ARR_LEN (1 << 16) // 65536 elements

int numbers[ARR_LEN]; // Global data array

void validate_input(int n)
{
    if (n <= 0 || n >= 16)
    {
        printf("Error: n must be 1-15\n");
        exit(1, "Invalid input");
    }
}

void initialize_array()
{
    for (int idx = 0; idx < ARR_LEN; idx++)
    {
        numbers[idx] = idx;
    }
}

void child_work(int child_num, int total_children)
{
    // Calculate partition boundaries
    int base_chunk = ARR_LEN / total_children;
    int extra = ARR_LEN % total_children;

    int lower_bound = child_num * base_chunk;
    if (child_num < extra)
    {
        lower_bound += child_num;
    }
    else
    {
        lower_bound += extra;
    }

    int upper_bound = lower_bound + base_chunk;
    if (child_num < extra)
    {
        upper_bound += 1;
    }

    // Compute partial sum
    int partial_sum = 0;
    for (int i = lower_bound; i < upper_bound; i++)
    {
        partial_sum += numbers[i];
    }

    sleep(child_num + 1);
    printf("Worker %d computed sum: %d\n", child_num + 1, partial_sum);
    exit(partial_sum, "child exit");
}

void parent_work(int child_count, int *child_pids)
{
    int completed;
    int results[child_count];

    if (waitall(&completed, results) < 0)
    {
        printf("Error in waitall\n");
        exit(1, "waitall failed");
    }

    int grand_total = 0;
    for (int i = 0; i < child_count; i++)
    {
        grand_total += results[i];
        printf("Child %d returned: %d\n", i + 1, results[i]);
    }
    printf("Combined total: %d\n", grand_total);
}

void parallel_sum(int process_count)
{
    validate_input(process_count);
    initialize_array();

    int child_ids[process_count];
    int fork_result = forkn(process_count, child_ids);

    if (fork_result == -1)
    {
        printf("Failed to create processes\n");
        exit(1, "forkn error");
    }

    if (fork_result > 0)
    {
        // Child process
        child_work(fork_result - 1, process_count);
    }
    else
    {
        // Parent process
        parent_work(process_count, child_ids);
    }
}

int main(void)
{
    parallel_sum(5); // Use 5 worker processes
    exit(0, "Program completed successfully\n");
}