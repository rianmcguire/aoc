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

        sum += search(springs, &counts);
    }

    println!("{}", sum);
}

fn search(springs: &[u8], counts: &[usize]) -> u64 {
    while springs.len() > 0 && springs[0] == b'.' {
        return search(&springs[1..], &counts);
    }
    
    let mut leading_springs = 0;
    for (i, s) in springs.iter().enumerate() {
        if *s != b'#' { break; }
        leading_springs = i + 1;
    }
    let complete_group = leading_springs > 0 && (leading_springs > springs.len() - 1 || springs[leading_springs] == b'.');


    let result: u64 =
        if springs.len() == 0 && counts.len() == 0 {
            1
        } else if springs.len() == 0 && counts.len() > 0 {
            0
        } else if leading_springs > 0 && (counts.len() == 0 || leading_springs > counts[0]) {
            0
        } else if complete_group {
            if leading_springs == counts[0] {
                search(&springs[counts[0]..], &counts[1..])
            } else {
                0
            }
        } else {
            let unknown_idx = springs.iter().position(|&s| s == b'?').unwrap();

            let modified: &mut [u8] = &mut springs.to_owned();

            modified[unknown_idx] = b'.';
            let with_working = search(modified, &counts);

            modified[unknown_idx] = b'#';
            let with_broken = search(modified, &counts);

            with_working + with_broken
        };

    return result;
}
