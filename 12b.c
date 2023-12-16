#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <search.h>

int64_t search(char* springs, int* counts, int counts_len) {
    // Skip over leading "." - they don't affect the result
    while (springs[0] == '.') springs++;

    // Check memoization hash table
    ENTRY item;
    item.key = malloc(1000);
    snprintf(item.key, 1000, "%s%d", springs, counts_len);
    ENTRY *found;
    if ((found = hsearch(item, FIND)) != NULL) {
        return (int64_t)found->data;
    }

    bool springs_empty = springs[0] == '\0';

    char* strp = springs;
    while (strp[0] == '#') strp++;
    int leading_springs = strp - springs;
    bool complete_group = leading_springs > 0 && (strp[0] == '.' || strp[0] == '\0');

    int64_t result;
    if (springs_empty && counts_len == 0) {
        // Base case - we've matched everything!
        result = 1;
    } else if (springs_empty && counts_len > 0) {
        // There are no possible springs left, but there are unmatched counts
        result = 0;
    } else if (leading_springs > 0 && (counts_len == 0 || leading_springs > counts[0])) {
        // Leading number of springs is bigger than the expected count - this will never match
        result = 0;
    } else if (complete_group) {
        if (leading_springs == counts[0]) {
            result = search(springs + counts[0], counts + 1, counts_len - 1);
        } else {
            // Group was a different size - this will never match
            result = 0;
        }
    } else {
        char* unknown_p = strchr(springs, '?');
        if (unknown_p[0] == '\0') {
            printf("wtf\n");
            exit(1);
        }

        int unknown_idx = unknown_p - springs;

        char with_working[1000];
        strlcpy(with_working, springs, sizeof(with_working));
        with_working[unknown_idx] = '.';

        char with_broken[1000];
        strlcpy(with_broken, springs, sizeof(with_broken));
        with_broken[unknown_idx] = '#';

        result = search(with_working, counts, counts_len) + search(with_broken, counts, counts_len);
    }

    item.data = (void*)result;
    hsearch(item, ENTER);

    return result;
}

int main() {
    int64_t sum = 0;
    char buffer[1000];
    while (fgets(buffer, sizeof(buffer), stdin) != NULL) {
        char *buffer_p = buffer;
        char *springs = strsep(&buffer_p, " ");
        char *counts_str = buffer_p;

        // Unfold
        char springs_unfolded[1000];
        snprintf(springs_unfolded, sizeof(springs_unfolded), "%s?%s?%s?%s?%s", springs, springs, springs, springs, springs);
        char counts_unfolded[1000];
        snprintf(counts_unfolded, sizeof(counts_unfolded), "%s,%s,%s,%s,%s", counts_str, counts_str, counts_str, counts_str, counts_str);

        // Parse counts
        int counts[1000];
        int counts_len = 0;
        char* count;
        char* count_p = counts_unfolded;
        while ((count = strsep(&count_p, ",")) != NULL) {
            counts[counts_len++] = atoi(count);
        }

        hcreate(1000);
        int64_t result = search(springs_unfolded, counts, counts_len);
        hdestroy();

        sum += result;
    }
    printf("%lli\n", sum);
}
