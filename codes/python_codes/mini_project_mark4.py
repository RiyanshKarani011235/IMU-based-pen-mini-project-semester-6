from graphics import *
import time

window_width = 1274
window_height = 704

win = GraphWin('MPU6050',window_width,window_height)
win.setCoords(0,0,window_width,window_height)

##win = GraphWin('MPU6050',window_width,window_height)
##
####poly = Polygon([Point(10,20),Point(30,40),Point(30,20),Point(10,10)])
####poly.draw(win)
##
##def draw_block() :
##  points = [Point(500,100),Point(520,160),Point(550,160),Point(570,100),Point(570,70), Point(500,70)]
##  poly = Polygon(points)
##  poly.draw(win)
##
##class cuboid_3D() :
##  
##while True:
##     try:
##         x = int(raw_input("Please enter a number: "))
##         break
##     except ValueError:
##         print "Oops!  That was no valid number.  Try again.."

class cuboid() :

    def __init__(self,x=0,y=0,hb=0,hs=0,wb=0,ws=0) :
        self.x = x
        self.y = y
        self.hb = hb
        self.hs = hs
        self.wb = wb
        self.ws = ws
        self.p1 = Point((x-((wb*1.0)/2)),(y-((hb*1.0)/2)-hs))
        self.p2 = Point((x+((wb*1.0)/2)),(y-((hb*1.0)/2)-hs))
        self.p3 = Point((x-((wb*1.0)/2)),(y-((hb*1.0)/2)))
        self.p4 = Point((x+((wb*1.0)/2)),(y-((hb*1.0)/2)))
        self.p5 = Point((x-((ws*1.0)/2)),(y+((hb*1.0)/2)-hs))
        self.p6 = Point((x+((ws*1.0)/2)),(y+((hb*1.0)/2)-hs))
        self.p7 = Point((x-((ws*1.0)/2)),(y+((hb*1.0)/2)))
        self.p8 = Point((x+((ws*1.0)/2)),(y+((hb*1.0)/2)))
        self.rect1 = Rectangle(self.p1,self.p4)
        self.rect2 = Rectangle(self.p5,self.p8)
        self.poly1 = Polygon(self.p1,self.p3,self.p7,self.p5)
        self.poly2 = Polygon(self.p2,self.p4,self.p8,self.p6)

    def __str__(self) :

        return ('center == (%.2d,%.2d), hb = %.2d, hs = %.2d, wb = %.2d, ws = %.2d' %(self.x,self.y,self.hb,self.hs,self.wb,self.ws))

    def d(self,win) :
 
##        s1 = Line(p1,p2)
##        s2 = Line(p3,p4)
##        s3 = Line(p3,p7)
##        s4 = Line(p1,p5)
##        s5 = Line(p4,p8)
##        s6 = Line(p2,p6)
##        s7 = Line(p7,p8)
##        s8 = Line(p5,p6)
##        s9 = Line(p1,p3)
##        s10 = Line(p5,p7)
##        s11 = Line(p6,p8)
##        s12 = Line(p2,p4)
##        s1.draw(win)
##        s2.draw(win)
##        s3.draw(win)
##        s4.draw(win)
##        s5.draw(win)
##        s6.draw(win)
##        s7.draw(win)
##        s8.draw(win)
##        s9.draw(win)
##        s10.draw(win)
##        s11.draw(win)
##        s12.draw(win)
##        rect1 = Rectangle(self.p1,self.p4)
##        rect2 = Rectangle(self.p5,self.p8)
##        s1 = Line(self.p3,self.p7)
##        s2 = Line(self.p1,self.p5)
##        s3 = Line(self.p4,self.p8)
##        s4 = Line(self.p2,self.p6)
##        rect1.draw(win)
##        rect2.draw(win)
##        s1.draw(win)
##        s2.draw(win)
##        s3.draw(win)
##        s4.draw(win)
        self.rect1.draw(win)
        self.rect2.draw(win)
        self.poly1.draw(win)
        self.poly2.draw(win)


    def animate(self) :
        self.rect1.move(0,1)
        self.rect2.move(0,-1)

c = cuboid(window_width/2,window_height/2,200,50,300,230)
c.d(win)
    
