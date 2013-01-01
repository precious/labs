#!/usr/bin/python
# -*- coding: utf-8 -*-

inf = float('inf')
D = [
[1,2,3],
[4,inf,0],
[7,8,9],
]
n = len(D)
i = 0
k = 2

# init
a = [0 for j in range(n)]
a[i] = 1
b = D[i]
c = [i for j in range(n)]
c[i] = 0

while filter(lambda x: not a[x],range(n)):
	minimum = None
	for j in filter(lambda x: not a[x],range(n)):
		if minimum != None:
			if a[minimum] > a[j]:
				minimum = j
		else:
			minimum = j
	a[minimum] = 1
	if b[k] > b[minimum] + D[minimum][k]:
		b[k] = b[minimum] + D[minimum][k]
		c[k] = minimum

path = [c[k]]
while path[-1]:
	path.append(c[path[-1]])
	#if not path[-1]: break
path = list(reversed(path))


print b[k], path
print a,b,c
