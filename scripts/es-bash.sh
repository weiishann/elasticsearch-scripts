#!/usr/local/bin/bash 


ESNODE="IP:PORT"
INDEX="INDEX_WITH_WILDCARD"

rm mapped_indices.txt
rm not_mapped_indices.txt

#curl -XGET $ESNODE/$INDEX/_mapping/?\&pretty=1
#curl -XGET $ESNODE/_cat/indices/logstash-hvca-* | cut -d' ' -f3-
curl -XGET $ESNODE/_cat/indices/logstash-hvca-* | awk '{print $3}' > all_indices.txt


cat all_indices.txt | while read line
do
    curl -XGET $ESNODE/$line/_mapping/?\&pretty=1 | grep -i not_before
        RESULT=$?
        if [ $RESULT -eq 0 ]; then
              echo $line >> mapped_indices.txt
        else
            echo $line >> not_mapped_indices.txt
        fi
done


cat not_mapped_indices.txt | while read line
do
        curl -XPOST $ESNODE/_reindex -d  '{"source": {"index": '"\"$line\""'},"dest": {"index": '"\"$line"'_reindexed"}}'
    RESULT=$?
                if [ $RESULT -eq 0 ]; then
                        echo "$line" + "has been reindexed..." >> reindexed.logs
            echo 'curl -XDELETE '"$ESNODE"'/'"$line"'' >> index_to_delete.cmd

                else
                        echo "$line"+ "has not been reindexed..." >>  reindexed.logs
                fi

done
