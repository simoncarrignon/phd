for realfile in `ls *.tex`;
do
	
	for swapfile in `ls basename .$realfile.sw?`
	do
		recoveryfile=`basename $realfile.rec`
		echo $recoveryfile
		vim -r "$swapfile" -c ":wq! $recoveryfile" && rm "$swapfile"
		if cmp "$recoveryfile" "$realfile"
		then echo "rm $recoveryfile"
		else vimdiff "$recoveryfile" "$realfile"
		fi
	done
done

