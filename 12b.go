package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
)

func main() {
	filename := os.Args[1]

	file, err := os.Open(filename)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	sum := int64(0)
	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.Split(line, " ")

		springs := fmt.Sprintf("%s?%s?%s?%s?%s", parts[0], parts[0], parts[0], parts[0], parts[0])
		counts_str := fmt.Sprintf("%s,%s,%s,%s,%s", parts[1], parts[1], parts[1], parts[1], parts[1])

		var counts []int
		for _, s := range strings.Split(counts_str, ",") {
			count, err := strconv.Atoi(s)
			if err != nil {
				log.Fatal(err)
			}
			counts = append(counts, count)
		}
		sum += search([]rune(springs), counts, make(map[string]int64))
	}

	fmt.Println(sum)
}

func search(springs []rune, counts []int, memo map[string](int64)) int64 {
	for len(springs) > 0 && springs[0] == '.' {
		springs = springs[1:]
	}

	memo_key := fmt.Sprintf("%s%d", string(springs), len(counts))
	result, ok := memo[memo_key]
	if ok {
		return result
	}

	leading_springs := 0
	for i, s := range springs {
		if s != '#' {
			break
		}
		leading_springs = i + 1
	}
	complete_group := leading_springs > 0 && (leading_springs > len(springs)-1 || springs[leading_springs] == '.')

	if len(springs) == 0 && len(counts) == 0 {
		result = 1
	} else if len(springs) == 0 && len(counts) > 0 {
		result = 0
	} else if leading_springs > 0 && (len(counts) == 0 || leading_springs > counts[0]) {
		result = 0
	} else if complete_group {
		if leading_springs == counts[0] {
			result = search(springs[counts[0]:], counts[1:], memo)
		} else {
			result = 0
		}
	} else {
		var unknown_idx int
		for i, s := range springs {
			if s == '?' {
				unknown_idx = i
				break
			}
		}

		before := springs[unknown_idx]

		springs[unknown_idx] = '.'
		with_working := search(springs, counts, memo)

		springs[unknown_idx] = '#'
		with_broken := search(springs, counts, memo)

		springs[unknown_idx] = before

		result = with_working + with_broken
	}

	memo[memo_key] = result

	return result
}
