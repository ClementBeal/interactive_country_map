from math import log, tan, pi


latitude = 41.145556  # (φ)
longitude = -73.995  #   // (λ)

mapWidth = 1009.6727
mapHeight = 665.96301

# // get x value
x = (longitude + 180) * (mapWidth / 360)

# // convert from degrees to radians
latRad = latitude * pi / 180

# // get y value
mercN = log(tan((pi / 4) + (latRad / 2)))
y = (mapHeight / 2) - (mapWidth * mercN / (2 * pi))

print(x)
print(y)
