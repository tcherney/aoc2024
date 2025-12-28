import itertools
import matplotlib
from matplotlib import pyplot as plt

class Rectangle:
    def __init__(self, xy1, xy2):
        self.left   = min(xy1[0], xy2[0])
        self.right  = max(xy1[0], xy2[0])
        self.bottom = min(xy1[1], xy2[1])
        self.top    = max(xy1[1], xy2[1])

        self.area = (self.right - self.left + 1) * (self.top - self.bottom + 1)

class Segment:
    def __init__(self, xy1, xy2):
        if xy1[0] != xy2[0] and xy1[1] != xy2[1]:
            raise ValueError('Segment is neither horizontal nor vertical')

        self.left   = min(xy1[0], xy2[0])
        self.right  = max(xy1[0], xy2[0])
        self.bottom = min(xy1[1], xy2[1])
        self.top    = max(xy1[1], xy2[1])

        self.isHorizontal = (self.top == self.bottom)
        self.length = self.right - self.left + self.top - self.bottom

    def intersectsRectangle(self, r):
        if self.isHorizontal:
            return ( r.bottom < self.top < r.top and
                     self.left < r.right and
                     r.left < self.right )
        else:
            return ( r.left < self.left < r.right and
                     self.bottom < r.top and
                     r.bottom < self.top )

data = [[int(x) for x in s.split(',')] for s in open('2025/inputs/day9/input.txt').readlines()]

# Create all rectangles, sort by decreasing area.
# We want to find the first rectangle of the list
# that is fully inside the contour.
rectangles = []
for xy1, xy2 in itertools.combinations(data, 2):
    # Assume the rectangle we'll find has distinct xmin/xmax and ymin/ymax
    if xy1[0] == xy2[0] or xy1[1] == xy2[1]:
        continue
    rectangles.append(Rectangle(xy1, xy2))

# Create all segments, sort by decreasing length
segments = []
xy_prev = data[-1]
for xy in data:
    segments.append(Segment(xy_prev, xy))
    xy_prev = xy

# Delete rectangles that intersect segments
# Start with the largest segments, they have more
# chances to intersect rectangles.
for s in sorted(segments, key = lambda s : s.length, reverse = True):
    toPop = []
    for i, r in enumerate(rectangles):
        if s.intersectsRectangle(r):
            toPop.append(i)
    for i in toPop[::-1]:
        rectangles.pop(i)

# Show remaining rectangles to user (in reverse area order),
# so that they can select the largest rectangle that's inside
# the shape (for my input, it's the first one, but Eric could
# have been sneaky and make is so the largest rectangle that
# doesn't intersect the contour is outside of it).
plt.plot(
    [x[0] for x in data] + [data[0][0]],
    [x[1] for x in data] + [data[0][1]])
plt_rect = matplotlib.patches.Rectangle((0, 0), 0, 0, color = 'red')
plt.gca().add_patch(plt_rect)
for r in sorted(rectangles, key = lambda r : r.area, reverse = True):
    plt_rect.set_xy((r.left, r.bottom))
    plt_rect.set_width(r.right - r.left)
    plt_rect.set_height(r.top - r.bottom)
    plt.show(block = False)
    print(f'Rectangle area: {r.area}')
    print(f'Top Left: {r.left},{r.top}\n Bottom Right: {r.right},{r.bottom}')
    print('Presse enter to check next rectangle, q + enter to exit')
    if 'q' == input():
        break
