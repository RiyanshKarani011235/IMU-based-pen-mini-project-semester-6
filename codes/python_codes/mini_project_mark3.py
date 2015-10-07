from graphics import *

window_width = 1274
window_height = 704

win = GraphWin('MPU6050',window_width,window_height)

##poly = Polygon([Point(10,20),Point(30,40),Point(30,20),Point(10,10)])
##poly.draw(win)

def draw_block() :
  points = [Point(500,100),Point(520,160),Point(550,160),Point(570,100),Point(570,70), Point(500,70)]
  poly = Polygon(points)
  poly.draw(win)
