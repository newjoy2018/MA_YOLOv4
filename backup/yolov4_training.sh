#!/bin/sh

:<<!


#----Check if txt labels exist----
cd KITMoMa1400

files_txt=$(ls *.txt 2> /dev/null | wc -l)
files_xml=$(ls *.xml 2> /dev/null | wc -l)

if [ "$files_txt" != "0" ]
then
    echo "Dataset is ready!"
elif [ "$files_xml" != "0" ]
then
    echo "Darknet needs txt labels!"
    echo "Transforming TXT labels from XML labels ... "
    cd ..    
    ls -R KITMoMa1400/*.jpg > jpgList.txt
    python label_xml2txt.py
else
    echo "Cannot find label files in the dataset directory! "
fi


#----split dataset into train set and test set----
#----and make corresponding txt lists----
mkdir testJpg
mkdir label_txt
mv KITMoMa1400/*.txt label_txt/
mkdir label_xml
mv KITMoMa1400/*.xml label_xml/
python randomPick.py

mv testJPGlist.txt moveTxt.sh
sed -i 's/.jpg/.txt/g' moveTxt.sh
sed -i -e 's/^/mv label_txt\/&/g' moveTxt.sh
sed -i -e 's/$/& testJpg/g' moveTxt.sh
chmod +x moveTxt.sh
./moveTxt.sh
rm moveTxt.sh

mv label_txt/*.txt KITMoMa1400
rm -r label_txt

ls -R KITMoMa1400/*.jpg > trainList.txt
ls -R testJpg/*.jpg > testList.txt


mkdir Dataset/
mv KITMoMa1400 Dataset/
mv label_xml Dataset/
mv testJpg Dataset/
mv jpgList.txt Dataset/
mv trainList.txt Dataset/
mv testList.txt Dataset/


#----Clone and make darknet----
git clone https://codechina.csdn.net/weixin_42412203/darknet.git
#git clone https://github.com/AlexeyAB/darknet.git
cd darknet

sed -i 's/OPENCV=0/OPENCV=1/' Makefile
sed -i 's/GPU=0/GPU=1/' Makefile
sed -i 's/CUDNN=0/CUDNN=1/' Makefile

make

cd ..


#----Modify configuration----


mkdir weights
cd weights
#yolov4 pretrained weights for the convolutional layers
wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.conv.137
cd ..

mkdir cfg
#cp darknet/cfg/yolov4.cfg cfg

!

# download yolov4 cfg file
mkdir cfg
cd cfg
wget https://github.com/newjoy2018/MA_YOLOv4/blob/main/Downloads/cfg/yolov4.cfg
cd ..

# Create obj.names to contain class names
touch obj.names
list="truck excavator wheel_loader bulldozer dumper person car"
for className in $list
do
    echo $className >> obj.names
done












