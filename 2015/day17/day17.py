import functools
import bisect
import time

denominations = [
    (5, 0),
    (5, 1),
    (10, 2),
    (15, 3),
    (20, 4)
]

def min_containers(ans: list[tuple[int,int]]) -> int:
    minimum = len(min(ans, key=lambda x: len(x)))
    count = 0
    for a in ans:
        if len(a) == minimum:
            count += 1
    return count

total = 0

@functools.cache
def make_containers(amount: int, choices: tuple[tuple[int,int]], denominations_left: tuple[tuple[int, int]]) -> list[tuple[int,int]]:
    global total 
    total += 1
    #print(amount, choices, denominations_left)
    ret = []
    if amount == 0:
        ret.append(choices)
        return ret
    for t in denominations_left:
        if t[0] <= amount:
            c = list(choices[:])
            indx = bisect.bisect_left(c, t)
            c.insert(indx, t)
            #print(c)
            deno = list(denominations_left[:])
            deno.remove(t)
            list_choices = make_containers(amount-t[0], tuple(c), tuple(deno))
            for lc in list_choices:
                #print(f"Should we add {lc}")
                if lc not in ret:
                    ret.append(lc)
    return ret

t0 = time.time()
ans = make_containers(25, tuple([]), tuple(denominations))
#print(ans)
print(len(ans))
print(min_containers(ans))
t1 = time.time()
print(f"{t1-t0} seconds")
print(total)
total = 0



with open("matt.txt", 'r') as f:
    i = 0
    denominations = []
    for line in f:
        #print(line)
        denominations.append((int(line), i))
        i += 1
t0 = time.time()
ans = make_containers(150, tuple([]), tuple(denominations ))
#print(ans)
print(len(ans))
print(min_containers(ans))
t1 = time.time()
print(f"{t1-t0} seconds")

print(total)