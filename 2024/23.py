#!/usr/bin/env python

import sys
import networkx as nx

g = nx.Graph()
with open(sys.argv[1], 'r') as f:
    for line in f:
        a, b = line.rstrip().split("-")
        g.add_edge(a, b)

three_cliques = [c for c in nx.enumerate_all_cliques(g) if len(c) == 3]

count = 0
for c in three_cliques:
    for n in c:
        if n[0] == 't':
            count += 1
            break
print(count)
