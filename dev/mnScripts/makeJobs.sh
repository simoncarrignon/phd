#./makefolder folder time
#folder : the folder name of the experiment (where are all the folders run_XXXX/)
#time : the expected time of the experiment

folder=$1
time=$2

name=`basename $folder`
ntask=`wc -l < province_$name.task`
sed  -e "s/province_proto/province_$name/" -e "s/#BSUB -W TIME/#BSUB -W $time/"  -e "s/#BSUB -n NTASKS/#BSUB -n $ntask/" provinceProto.job > province_$name.job
