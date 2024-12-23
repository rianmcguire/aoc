#!/usr/bin/env python

import sys
import networkx as nx

g = nx.Graph()
with open(sys.argv[1], 'r') as f:
    for line in f:
        a, b = line.rstrip().split("-")
        g.add_edge(a, b)

# It returns the cliques ordered by cardinality, so the last one is the largest
*rest, last = nx.enumerate_all_cliques(g)
last.sort()
print(",".join(last))
