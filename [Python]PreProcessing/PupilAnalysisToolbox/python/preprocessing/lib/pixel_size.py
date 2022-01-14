import math
import numpy as np

def pixel_size(dotpitch,visual_angle,visual_range):
  
    # dotpitch = 0.282; #(mm) SMI
    # visual_angle = 0.29 #(deg)
    # visual_range = 60 #(cm)
    
    visual_angle = visual_angle * (math.pi / 180)
    a = visual_range * math.tan(visual_angle)
    a = a * 10
#    disp(concat([num2str(a),'mm']))
    pixel_num = a / dotpitch

    return pixel_num
    
def pixel2angle(dotpitch,pixel_num,visual_range):
    
    # if len(pixel_num) > 1:
    angle = []
    for i in np.arange(len(pixel_num)):
        angle.append(math.atan(((pixel_num[i]*dotpitch)/10)/visual_range))
        
    ans = np.array(angle) * (180/math.pi)
    # else:
    # angle = math.atan(((pixel_num*dotpitch)/10)/visual_range)
    # ans = angle * (180/math.pi)
        
    return ans
