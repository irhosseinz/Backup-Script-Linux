#!/bin/bash
APP="Project name"

function upload_ftp(){
	curl -T $1 ftp://backup_space_ip:21/$2 --user username:password
}

DATE=$(date +"%F_%H.%M.%S")
ROOT="/home/user"
cd $ROOT

#backup files
FILE="$APP.files.$DATE.tar.gz"
SAVEPATH="backups/$FILE"
echo "creating backup file $SAVEPATH for files"
tar -czf $SAVEPATH public_html # add folders you want to backup
FILESIZE=$(stat -c%s "$SAVEPATH")
echo "file created. size:$FILESIZE"
upload_ftp $SAVEPATH "$APP/$FILE"

#backup mongodb database
FILE="$APP.APP.DB_$DATE.archive.gz"
SAVEPATH="backups/$FILE"
echo "creating backup file $SAVEPATH for db"
/usr/bin/mongodump --uri=mongodb://127.0.0.1:27017/dbname --gzip --archive=$SAVEPATH
FILESIZE=$(stat -c%s "$SAVEPATH")
echo "file created. size:$FILESIZE"
upload_ftp $SAVEPATH "$APP/$FILE"

#backup sql satabase
FILE="$APP.DB_$DATE.sql.gz"
SAVEPATH="backups/$FILE"
echo "creating backup file $SAVEPATH for db"
mysqldump -u username -ppassword --master-data=2 --single-transaction -q --databases db1 db2 db3 | gzip > $SAVEPATH
FILESIZE=$(stat -c%s "$SAVEPATH")
echo "file created. size:$FILESIZE"
upload_ftp $SAVEPATH "$APP/$FILE"

#clear old files
find backups -type f -iname "*.tar.gz" -mtime +3 -exec rm {} \;
find backups -type f -iname "*.sql.gz" -mtime +3 -exec rm {} \;
