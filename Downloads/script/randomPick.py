#!/bin/python
import os, random, shutil

test_jpg = open('./testJPGlist.txt', 'w')

def randomPick(sourceDir):
    pathDir = os.listdir(sourceDir)
    filenumber=len(pathDir)
    rate=0.15
    picknumber=int(filenumber*rate)
    sample = random.sample(pathDir, picknumber)
    #print (sample)
    for name in sample:
        test_jpg.write(str(name) + " " + '\n')   
        shutil.move(sourceDir+name, targetDir+name)             
    return

if __name__ == '__main__':
    sourceDir = "./KITMoMa/"
    targetDir = "./testJpg/"
    randomPick(sourceDir)



