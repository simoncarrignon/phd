folder=$1
for i in $folder/run_*; 
do 
	ln -s /home/bsc21/bsc21394/roman/141110-TradeAndCulture-versionSub/province $i;
	ln -s /home/bsc21/bsc21394/roman/141110-TradeAndCulture-versionSub/AnalyseTools/analysis $i;
done
