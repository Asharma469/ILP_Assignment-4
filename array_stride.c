#include <stdio.h>
#include <stdlib.h>

#define ARRAY_SIZE (128 * 1024) // 128K integers = 512 kB (stresses 16kB / 32kB / 64kB L1 caches)
#define NUM_ITERATIONS 5

int main(int argc, char *argv[]) {
    int stride = 1;
    if (argc > 1) {
        stride = atoi(argv[1]);
        if (stride <= 0) {
            stride = 1;
        }
    }

    // Allocate array
    int *arr = (int *)malloc(ARRAY_SIZE * sizeof(int));
    if (!arr) {
        fprintf(stderr, "Allocation failed\n");
        return 1;
    }

    // Initialize array (compulsory / cold misses)
    for (int i = 0; i < ARRAY_SIZE; i++) {
        arr[i] = i;
    }

    // Main measurement loop: repeated strided reads and updates
    long long sum = 0;
    for (int iter = 0; iter < NUM_ITERATIONS; iter++) {
        for (int i = 0; i < ARRAY_SIZE; i += stride) {
            sum += arr[i];
            arr[i] += 1;
        }
    }

    printf("Execution complete. Stride: %d, Result: %lld\n", stride, sum);

    free(arr);
    return 0;
}
