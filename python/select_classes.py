# remove the unwanted classes
import os
import numpy as np

indir = '/home/zahid/darknet_classifier/darknet/out/'
outdir = '/home/zahid/darknet_classifier/darknet/out2/'
os.mkdir(outdir)

filenames = os.listdir(indir)

size = np.array([1280, 720])

def convert(size, box):
    dw = 1./(size[0])
    dh = 1./(size[1])
    x = (box[0] + box[1])/2.0 - 1
    y = (box[2] + box[3])/2.0 - 1
    w = box[1] - box[0]
    h = box[3] - box[2]
    x = x*dw
    w = w*dw
    y = y*dh
    h = h*dh
    return (x,y,w,h)


for names in filenames:
	if names.endswith('.txt'):
		fp = open(indir + names ,'r')
		fp2 = open(outdir + names[0:10] + '.txt' ,'wt')
		lines = fp.read().splitlines()
		for i in range(len(lines)):
			line = lines[i]
			temp = line.split()
			if(temp[0] == '0' or temp[0] == '2' or temp[0] == '9' or temp[0] == '24' or temp[0] == '26' or temp[0] == '27' or temp[0] == '39' or temp[0] == '41' or temp[0] == '45' or temp[0] == '56' or temp[0] == '58' or temp[0] == '60' or temp[0] == '62' or temp[0] == '67' or temp[0] == '72' or temp[0] == '73' or temp[0] == '75'):
				box = np.array([float(temp[1]), float(temp[3])+float(temp[1]), float(temp[2]), float(temp[4])+float(temp[2])])
				bb = convert(size, box)
				fp2.write(temp[0] + " " + " ".join([str(a) for a in bb]) + '\n')
				#fp2.write(temp[0] + " " + temp[1] + " " +temp[2] + " " +temp[3] + " " + temp[4] +  '\n')
		fp.close()
		fp2.close()
			
			
		
