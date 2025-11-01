

import functools
import random
import sys

molecules = [
    ("H","HO"),
    ("H","OH"),
    ("O","HH")
]
start_string = "HOH"
def replace_molecules(input_str: str) -> set[str]:
    ret = set()
    for m in molecules:
        start_find = 0
        found = input_str.find(m[0], start_find)
        while found != -1:
            ret.add(input_str[:found] + m[1] + input_str[found+len(m[0]):])
            start_find = found+1
            found = input_str.find(m[0], start_find)
    return ret


print(len(replace_molecules(start_string)))

with open("input.txt", 'r') as f:
    molecules.clear()
    for line in f:
        line = line.strip()
        if len(line) == 0:
            continue
        if line.find("=>") == -1:
            start_string = line
        else:
            parts: list[str] = line.split("=>")
            molecules.append((parts[0].strip(), parts[1].strip()))

print(len(replace_molecules(start_string)))


molecules = [
    ("e", "H"),
    ("e", "O"),
    ("H", "HO"),
    ("H", "OH"),
    ("O", "HH")
]
start_string = "e"

@functools.cache
def replace_molecule(input_str: str, output_str: str, step: int) -> int:
    min_steps = sys.maxsize
    if input_str == output_str:
        return step
    elif len(input_str) > len(output_str):
        return sys.maxsize
    for m in molecules:
        start_find = 0
        found = input_str.find(m[0], start_find)
        while found != -1:
            min_steps = min(min_steps, replace_molecule(input_str[:found] + m[1] + input_str[found+len(m[0]):], output_str, step+1))
            start_find = found+1
            found = input_str.find(m[0], start_find)
    return min_steps

solution_found = False
@functools.cache
def replace_molecule_backwards(input_str: str, output_str: str, step: int) -> int:
    #print(input_str)
    global solution_found
    min_steps = sys.maxsize
    if input_str == output_str:
        solution_found = True
        return step
    for m in molecules:
        start_find = 0
        found = input_str.find(m[1], start_find)
        while found != -1:
            min_steps = min(min_steps, replace_molecule_backwards(input_str[:found] + m[0] + input_str[found+len(m[1]):], output_str, step+1))
            if solution_found:
                return min_steps
            start_find = found+1
            found = input_str.find(m[1], start_find)
    return min_steps

def replace_molecule_backwards_dumb(input_str: str, output_str: str, step: int) -> int:
    min_steps = sys.maxsize
    if input_str == output_str:
        return step
    for m in molecules:
        if input_str.find(m[1]):
            min_steps = min(min_steps, replace_molecule_backwards_dumb(input_str.replace(m[1], m[0]), output_str, step+1))
    return min_steps

def replace_molecule_iter(input_str: str, output_str: str) -> int:
    step = 0
    while input_str != output_str:
        prev = input_str
        random.shuffle(molecules)
        for m in molecules:
            while m[1] in input_str:
                input_str = input_str.replace(m[1], m[0],1)
                step += 1
        if input_str == prev:
            #print(molecules, input_str, prev)
            return sys.maxsize
    return step




result = replace_molecule_iter("HOHOHO", "e")
while(result == sys.maxsize):
    result = replace_molecule_iter("HOHOHO", "e")
print(result)

solution_found = False
molecules.sort(key=lambda x: len(x[1]))
print(replace_molecule_backwards("HOHOHO","e", 0))

with open("input.txt", 'r') as f:
    molecules.clear()
    for line in f:
        line = line.strip()
        if len(line) == 0:
            continue
        if line.find("=>") == -1:
            start_string = line
        else:
            parts: list[str] = line.split("=>")
            molecules.append((parts[0].strip(), parts[1].strip()))

result = replace_molecule_iter(start_string, "e")
while(result == sys.maxsize):
    result = replace_molecule_iter(start_string, "e")
print(result)

solution_found = False
molecules.sort(key=lambda x: len(x[1]))
print(replace_molecule_backwards(start_string,"e", 0))