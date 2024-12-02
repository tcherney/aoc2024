

def part1(file_name):
    with open(file_name, 'r') as f:
        list1 = []
        list2 = []
        for line in f.readlines():
            nums = line.split()
            list1.append(int(nums[0]))
            list2.append(int(nums[1]))
        list1.sort()
        list2.sort()
        distance = 0
        for i in range(len(list1)):
            distance += abs(list1[i]-list2[i])
        return distance
    
def part2(file_name):
    with open(file_name, 'r') as f:
        list1 = []
        list2 = []
        for line in f.readlines():
            nums = line.split()
            list1.append(int(nums[0]))
            list2.append(int(nums[1]))
        list1.sort()
        list2.sort()
        similarity = 0
        for i in range(len(list1)):
            local_sim = 0
            for j in range(len(list2)):
                if list2[j] > list1[i]:
                    break
                if list2[j] == list1[i]:
                    local_sim += 1
            similarity += local_sim * list1[i]
        return similarity
    
if __name__ == "__main__":
    print(part1("inputs/day1/input.txt"))
    print(part2("inputs/day1/input.txt"))