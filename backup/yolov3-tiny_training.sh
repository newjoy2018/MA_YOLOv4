#!/bin/sh


echo -e "\n------ start preparing... ------\n"
mkdir dataset
mv KITMoMa dataset
mv label_xml2txt.py dataset
mv randomPick.py dataset


echo -e "\n------ 1. check label files ------\n"
cd dataset/KITMoMa/
files_txt=$(ls *.txt 2> /dev/null | wc -l)
files_xml=$(ls *.xml 2> /dev/null | wc -l)
if [ "$files_txt" != "0" ]
then
    cd ..
    mkdir label_txt
    mv KITMoMa/*.txt label_txt/
    echo "  TXT labels exist, dataset is ready!"
    cd ..
elif [ "$files_xml" != "0" ]
then
    echo "  XML labels founded, darknet needs TXT labels!"
    echo "  convert from XML labels to TXT labels ... "
    cd ../..
    ls -R dataset/KITMoMa/*.jpg > dataset/jpgList.txt
    cd dataset
    python label_xml2txt.py
    mkdir label_txt
    mv KITMoMa/*.txt label_txt/
    mkdir label_xml
    mv KITMoMa/*.xml label_xml/
    cd ..
    echo -e "  TXT labels are successfully converted!\n  Dataset is ready!"
else
    echo "  Cannot find TXT or XML labels in the given dataset!"
    read -p "  Press any key to quit!" var
    exit
fi


echo -e "\n------ 2. divide dataset into training set and test set ------\n"
cd dataset
mkdir testJpg

# pick 15% jpgs and move to testJpg, generate testJPGlist.txt
python randomPick.py
echo "  15% images are randomly picked and moved to testJpg"

# move correspondant label files to testJpg
mv testJPGlist.txt moveTxt.sh
sed -i 's/.jpg/.txt/g' moveTxt.sh
sed -i -e 's/^/mv label_txt\/&/g' moveTxt.sh
sed -i -e 's/$/& testJpg/g' moveTxt.sh
chmod +x moveTxt.sh
./moveTxt.sh
rm moveTxt.sh

# move label files of training set to KITMoMa
mv label_txt/*.txt KITMoMa
rm -r label_txt
cd ..

# generate train set list and test set list
ls -R dataset/KITMoMa/*.jpg > dataset/trainList.txt
ls -R dataset/testJpg/*.jpg > dataset/testList.txt
echo "  training set and test set are ready!"

:<<!
echo -e "\n------ 3. clone the darknet to local and compile ------\n"
#git clone https://codechina.csdn.net/weixin_42412203/darknet.git   # Alternate link
#git clone https://github.com/AlexeyAB/darknet.git
cd darknet

sed -i 's/OPENCV=0/OPENCV=1/' Makefile
sed -i 's/GPU=0/GPU=1/' Makefile
sed -i 's/CUDNN=0/CUDNN=1/' Makefile

make

cd ..
!

echo -e "\n------ 4. prepare configuration files ------\n"
mkdir weights
cd weights
# yolov4-tiny pretrained weights for the convolutional layers
#debug#wget https://drive.google.com/file/d/18v36esoXCh-PsOKwyP2GWrpYDptDY8Zf/view?usp=sharing
cd ..
cp yolov3-tiny.conv.11 weights/
echo "  pretrained weight file is ready"


# download yolov4 cfg file
mkdir cfg
cd cfg
#debug#wget https://raw.githubusercontent.com/newjoy2018/MA_YOLOv4/main/Downloads/cfg/yolov4.cfg
cp ../yolov3-tiny.cfg ./
echo "  cfg file is ready"


# Create obj.names to contain class names
touch obj.names
list="truck excavator wheel_loader bulldozer dumper person car"
for className in $list
do
    echo $className >> obj.names
done
echo "  class name file is ready"


# Create obj.data to contain cfg file directory
touch obj.data
echo "classes = 7" >> obj.data
echo "train = dataset/trainList.txt" >> obj.data
echo "valid = dataset/testList.txt" >> obj.data
echo "names = cfg/obj.names" >> obj.data
echo "backup = weights/" >> obj.data
echo "  data directory is ready"

cd ..
mkdir trainingLog


echo -e "\n------ 5. Everything is ready. Now start training... ------\n"

./darknet/darknet detector train cfg/obj.data cfg/yolov3-tiny.cfg weights/ weights/yolov3-tiny.conv.11 -map | tee -a trainingLog/yolov3-tiny_TrainingLog.txt





