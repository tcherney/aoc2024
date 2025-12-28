
def build_report(line, tolerance):
    nums = [int(s) for s in line.split()]
    res = check_report(nums)
    if res == 0 and tolerance:
        for i in range(len(nums)):
            copy = nums[:]
            copy.pop(i)
            if check_report(copy) == 1:
                return 1
        return 0
    else:
        return res


def check_report(nums):
    prev_num = None
    increasing = None
    for num in nums:
        if prev_num is None:
            prev_num = num
        else:
            if increasing is None:
                if num > prev_num:
                    increasing = True
                elif num < prev_num:
                    increasing = False
                else:
                    return 0
            if increasing and num <= prev_num:
                return 0
            if not increasing and num >= prev_num:
                return 0
            
            if abs(num-prev_num) > 3:
                return 0
            prev_num = num
    return 1

def part1(file_name):
    with open(file_name, 'r') as f:
        safe_reports = 0
        for line in f.readlines():
            safe_reports += build_report(line,False)
        return safe_reports
    
def part2(file_name):
    with open(file_name, 'r') as f:
        safe_reports = 0
        for line in f.readlines():
            safe_reports += build_report(line,True)
        return safe_reports
        
    

if __name__ == "__main__":
    print(part1("inputs/day2/input.txt"))
    print(part2("inputs/day2/input.txt"))
    