cat col | awk 'BEGIN{FS="--"}{if(NF>1)print $1","$2","$2-$1; else print $1","$1","$1}' > newcol.csv

