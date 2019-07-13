#!/bin/bash
APP="Project"

function upload_ftp(){
	FTP_SERVER="1.2.3.4:21"
	FTP_USER="ftpuser"
	FTP_PASS="pass"
	curl -T $1 ftp://$FTP_SERVER/$2 --user $FTP_USER:$FTP_PASS
}

DATE="LAST"
#DATE=$(date +"%F_%H.%M.%S") #comment this to don't make a file for each execution 
ROOT=$(cd `dirname $0` && pwd)
cd $ROOT
mkdir -p backups

#backup files
FILE="$APP.files.$DATE.tar.gz" # Project.files.2019-07-11_05.05.01.tar.gz
SAVEPATH="backups/$FILE"
echo "creating backup file $SAVEPATH for files"
tar -czf $SAVEPATH folder1 folder2 file1 file2. # add folders you want to backup
FILESIZE=$(stat -c%s "$SAVEPATH")
echo "file created. size:$FILESIZE"
upload_ftp $SAVEPATH "$FILE"

#backup mysql satabase
FILE="$APP.DB.$DATE.sql.gz" # Project.DB.2019-07-11_05.05.01.sql.gz
SAVEPATH="backups/$FILE"
echo "creating backup file $SAVEPATH for db"
mysqldump -u username -ppassword --single-transaction -q --databases db1 db2 db3 | gzip > $SAVEPATH
#mysqldump -u username -ppassword --master-data=2 --single-transaction -q --databases db1 db2 db3 | gzip > $SAVEPATH
FILESIZE=$(stat -c%s "$SAVEPATH")
echo "file created. size:$FILESIZE"
upload_ftp $SAVEPATH "$FILE"

#backup mongodb database
#FILE="$APP.APP.DB.$DATE.archive.gz" # Project.DB.2019-07-11_05.05.01.archive.gz
#SAVEPATH="backups/$FILE"
#echo "creating backup file $SAVEPATH for db"
#/usr/bin/mongodump --uri=mongodb://127.0.0.1:27017/dbname --gzip --archive=$SAVEPATH
#FILESIZE=$(stat -c%s "$SAVEPATH")
#echo "file created. size:$FILESIZE"
#upload_ftp $SAVEPATH "$FILE"

#clear old files
find backups -type f -iname "*.tar.gz" -mtime +3 -exec rm {} \; #clean .tar.gz files older than 3 days
find backups -type f -iname "*.sql.gz" -mtime +3 -exec rm {} \; #clean .sql.gz files older than 3 days
