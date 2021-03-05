import os
import numpy as np 


rootdir=os.path.join('/content/drive/My Drive/Project/logAnlysis/Annotation/')
write_path=os.path.join('/content/drive/My Drive/Project/logAnlysis/convertedTXTlabel/')

for (dirpath,dirnames,filenames) in os.walk(rootdir):
  for filename in filenames:
    if os.path.splitext(filename)[1]=='.txt':
      with open(os.path.join(rootdir, filename),'r') as readTxt:
        print("\nNow read " + filename)
        with open(os.path.join(write_path, filename), 'w') as writeTxt:
          for line in readTxt.readlines():
            if 'Image size' in line:
              # print(line.split()[8:13])
              width = int(line.split()[8])
              height = int(line.split()[10])
              # print("hello world")
              print("size Founded! --> " + str(width) + " " + str(height))
            if 'Xmin, Ymin' in line:
              print("coordinate line Founded:")
              dataLine = line.split()[12:17]
              xMin = int(dataLine[0].split('(')[1].split(',')[0])
              yMin = int(dataLine[1].split(')')[0])
              xMax = int(dataLine[3].split('(')[1].split(',')[0])
              yMax = int(dataLine[4].split(')')[0])
              print(xMin, yMin, xMax, yMax)
              writeTxt.write(str(5) + " " + str(((xMax-xMin)/2-1)/width) + " " + str(((yMax-yMin)/2-1)/height) + " " + str((xMax-xMin)/width) + " " + str((yMax-yMin)/height) + "\n")
