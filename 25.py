#!/usr/bin/env python

import sys
import re
import networkx as nx

g = nx.Graph()
with open(sys.argv[1], 'r') as f:
    for line in f:
        head, *others = re.findall(r"\w+", line)
        for o in others:
            g.add_edge(head, o)
_, partitions = nx.stoer_wagner(g)
a, b = partitions
print(len(a) * len(b))
