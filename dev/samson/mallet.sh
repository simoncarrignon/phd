#Command to create the all
bin/mallet import-dir --input ~/projects/samson/ams/textMining/data/ --output ams.mallet --keep-sequence --remove-stopwords

#command to create the topic and output the key and the given map
bin/mallet train-topics --input ams.mallet --num-topics 20 --output-state topic-state.gz --output-topic-keys tutorial_keys.txt --output-doc-topics tutorial_compostion.txt --optimize-interval 20

