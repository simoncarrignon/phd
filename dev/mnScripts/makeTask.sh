
folder=$1

file="province_`basename $folder`.task"
touch $file
for i in $folder/run* ; 
do
	echo "cd $i && ./province && ./analysis && rm ./data/*"  >> $file
done
