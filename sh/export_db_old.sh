#!/bin/sh

sql=`echo "$5" | sed s/ChangeDoublequotationSH/\"/g`

if [ $7 = "write" ]; then
    mysql -u $1 -p$2 -h $3 $4 --default-character-set=utf8 -e "${sql}" | sed -e "s/\t/,/g" | iconv -f UTF-8 -t CP932 > $6
else
    mysql -u $1 -p$2 -h $3 $4 --skip-column-names --default-character-set=utf8mb4 -e "${sql}" | sed -e "s/\t/,/g" | iconv -f UTF-8 -t CP932 >> $6
fi
