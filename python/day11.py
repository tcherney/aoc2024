import functools
import time
from typing import Dict

@functools.cache
def score(num, iterations):
    if iterations == 0:
        return 1
    num_str = str(num)
    if num == 0:
        return score(1, iterations-1)
    elif len(num_str) % 2 == 0:
        return score(int(num_str[0:len(num_str)//2]), iterations-1) + score(int(num_str[len(num_str)//2:]), iterations-1)
    else:
        return score(num*2024, iterations-1)

cache = {}
def score_cached(num, iterations):
    key = (num,iterations)
    #print(f"cache {cache}")
    if key not in cache:
        num_str = str(num)
        if iterations == 0:
            cache[key] = 1
        elif num == 0:
            cache[key] = score_cached(1, iterations-1)
        elif len(num_str) % 2 == 0:
            cache[key] = score_cached(int(num_str[0:len(num_str)//2]), iterations-1) + score_cached(int(num_str[len(num_str)//2:]), iterations-1)
        else:
            cache[key] = score_cached(num*2024, iterations-1)
    return cache[key]

def day11(iterations, start):
    with open("inputs/day11/input.txt", "r") as f:
        result = 0
        for line in f.readlines():
            nums = [int(x) for x in line.split()]
            for num in nums:
                result += score_cached(num, iterations)
        end = time.time()
        print(f"{result} stones after {iterations} blinks in {end-start}s")

start = time.time()
day11(25,start)
start = time.time()
day11(75,start)