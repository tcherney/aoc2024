
def part1_rec_setup(target, nums):
    if (part1_rec(target, nums[0], nums[1:])):
        return target
    else:
        return 0
    

def part1_rec(target, current, nums):
    if len(nums) == 0:
        if target == current:
            return True
        else:
            return False
    return part1_rec(target, current + nums[0], nums[1:]) or part1_rec(target, current * nums[0], nums[1:])

def part1_iterative(target, nums):
    not_found = True
    for i in range(0, (2**(len(nums)-1))):
        answer = nums[0]
        for j in range(1,len(nums)):
            if i & (1 << (len(nums)-1-j)) > 0:
                answer *= nums[j]
            else:
                answer += nums[j]
        if answer == target:
            not_found = False
            break
    if not_found:
        #print(f"no answer for {target}: {nums}")
        return 0
    else:
        #print(f"found answer for {target}: {nums}")
        return target

def part1():
    with open("inputs/day7/test.txt", "r") as f:
        result = 0
        for line in f.readlines():
            strings = line.split(" ")
            target = int(strings[0][:-1])
            nums = [int(x) for x in strings[1:]]
            result += part1_iterative(target,nums)
        print(f"Calibration result {result}")
    with open("inputs/day7/test.txt", "r") as f:
        result = 0
        for line in f.readlines():
            strings = line.split(" ")
            target = int(strings[0][:-1])
            nums = [int(x) for x in strings[1:]]
            result += part1_rec_setup(target,nums)
        print(f"Calibration result {result}")

if __name__ == "__main__":
    part1()
