use std::env;
use std::fs;
use std::io;
use std::io::BufRead;

fn main() {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename).unwrap();
    let reader = io::BufReader::new(file);

    let mut sum: u64 = 0;
    for line in reader.lines() {
        let line_str = line.unwrap().to_string();
        let mut splits = line_str.split(' ');

        let springs_str = splits.next().unwrap();
        let unfolded_springs = format!("{s}?{s}?{s}?{s}?{s}", s = springs_str);
        let springs = unfolded_springs.as_bytes();

        let counts_str = splits.next().unwrap();
        let unfolded_counts = format!("{s},{s},{s},{s},{s}", s = counts_str);

        let counts: Vec<usize> = unfolded_counts
            .split(',')
            .map(|s| s.parse().unwrap())
            .collect();

        sum += search(springs, &counts, 0, 0, &mut MemoMap::with_capacity(8192));
    }

    println!("{}", sum);
}

type MemoMap = std::collections::HashMap<MemoKey, u64>;

#[derive(Eq, Hash, PartialEq)]
struct MemoKey {
    springs_len: usize,
    counts_len: usize,
    working_mask: u16,
    broken_mask: u16,
}

fn search(springs: &[u8], counts: &[usize], working_mask: u16, broken_mask: u16, memo: &mut MemoMap) -> u64 {
    if springs.len() > 0 && springs[0] == b'.' || working_mask & 1 == 1 {
        return search(&springs[1..], &counts, working_mask >> 1, broken_mask >> 1, memo);
    }

    let memo_key = MemoKey {
        springs_len: springs.len(),
        counts_len: counts.len(),
        working_mask: working_mask,
        broken_mask: broken_mask,
    };
    match memo.get(&memo_key) {
        Some(&result) => return result,
        None => ()
    }
    
    let mut leading_springs = 0;
    let mut search_mask: u16 = 1;
    for (i, &s) in springs.iter().enumerate() {
        if s != b'#' && search_mask & broken_mask == 0 { break; }
        leading_springs = i + 1;
        search_mask <<= 1;
    }
    let complete_group = leading_springs > 0 && (
        leading_springs > springs.len() - 1 ||
        springs[leading_springs] == b'.' ||
        working_mask & (1 << leading_springs) != 0
    );

    let result: u64 =
        if springs.len() == 0 && counts.len() == 0 {
            1
        } else if springs.len() == 0 && counts.len() > 0 {
            0
        } else if leading_springs > 0 && (counts.len() == 0 || leading_springs > counts[0]) {
            0
        } else if complete_group {
            if leading_springs == counts[0] {
                search(&springs[counts[0]..], &counts[1..], working_mask >> counts[0], broken_mask >> counts[0], memo)
            } else {
                0
            }
        } else {
            search_mask = 1;
            for &s in springs.iter() {
                if s == b'?' && search_mask & (working_mask | broken_mask) == 0 { break; }
                search_mask <<= 1;
            }

            let with_working = search(springs, &counts, working_mask | search_mask, broken_mask, memo);
            let with_broken = search(springs, &counts, working_mask, broken_mask | search_mask, memo);

            with_working + with_broken
        };

    memo.insert(memo_key, result);

    return result;
}
