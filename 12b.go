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
		sum += search([]rune(springs), counts, 0, 0, make(map[memoKey]int64))
	}

	fmt.Println(sum)
}

type memoKey struct {
	springs_len  int
	counts_len   int
	working_mask uint16
	broken_mask  uint16
}

func search(springs []rune, counts []int, working_mask uint16, broken_mask uint16, memo map[memoKey](int64)) int64 {
	for len(springs) > 0 && springs[0] == '.' || working_mask&1 == 1 {
		springs = springs[1:]
		working_mask >>= 1
		broken_mask >>= 1
	}

	memo_key := memoKey{springs_len: len(springs), counts_len: len(counts), working_mask: working_mask, broken_mask: broken_mask}
	result, ok := memo[memo_key]
	if ok {
		return result
	}

	leading_springs := 0
	var search_mask uint16 = 1
	for i, s := range springs {
		if s != '#' && search_mask&broken_mask == 0 {
			break
		}
		leading_springs = i + 1
		search_mask <<= 1
	}
	complete_group := leading_springs > 0 && (leading_springs > len(springs)-1 || springs[leading_springs] == '.' || working_mask&(1<<leading_springs) != 0)

	if len(springs) == 0 && len(counts) == 0 {
		result = 1
	} else if len(springs) == 0 && len(counts) > 0 {
		result = 0
	} else if leading_springs > 0 && (len(counts) == 0 || leading_springs > counts[0]) {
		result = 0
	} else if complete_group {
		if leading_springs == counts[0] {
			result = search(springs[counts[0]:], counts[1:], working_mask>>counts[0], broken_mask>>counts[0], memo)
		} else {
			result = 0
		}
	} else {
		search_mask = 1
		for _, s := range springs {
			if s == '?' && (search_mask&(working_mask|broken_mask) == 0) {
				break
			}
			search_mask <<= 1
		}

		with_working := search(springs, counts, working_mask|search_mask, broken_mask, memo)
		with_broken := search(springs, counts, working_mask, broken_mask|search_mask, memo)

		result = with_working + with_broken
	}

	memo[memo_key] = result

	return result
}
