

def part1(file_name):
    with open(file_name, 'r') as f:
        list1 = []
        list2 = []
        for line in f.readlines():
            nums = line.split()
            list1.append(nums[0])
            list2.append(nums[1])
        list1.sort()
        list2.sort()
        distance = 0
        for i in range(len(list1)):
            distance += abs(int(list1[i])-int(list2[i]))
        return distance
    
if __name__ == "__main__":
    print(part1("inputs/day1/input.txt"))