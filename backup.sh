#!/bin/bash
# based on https://github.com/dlabey/Simple-Linux-Bash-Rotating-Backup-Script

# init
PRJ='Project'
SOURCE='/full/path'
DESTINATION='/full/path'

DAY_OF_YEAR=$(date '+%j')
DAY_OF_MONTH=$(date '+%d')
DAY_OF_WEEK=$(date '+%w')
# start week on monday
if [ $DAY_OF_WEEK -eq 0 ] ; then
  DAY_OF_WEEK=7
fi
MONTH=$(date '+%m')
YEAR=$(date '+%Y')

TEMP='/tmp/backup'
FILENAME=${PRJ}'-files_'${DAY_OF_WEEK}'.zip'

# Make Temporary Folders
mkdir ${TEMP}
mkdir ${TEMP}/weekly
mkdir ${TEMP}/${YEAR}
mkdir ${TEMP}/${YEAR}/${MONTH}
echo 'created temp folders'

cd $SOURCE
zip -q ${TEMP}/weekly/${FILENAME} * -x \*@Recycle\*
echo 'Made daily backup...'

# make quarter-yearly backup
if [ $DAY_OF_MONTH -eq 1 ] ; then
  if [ $MONTH -eq 1 -o $MONTH -eq 4 -o $MONTH -eq 7 -o $MONTH -eq 10 ] ; then
    cp ${TEMP}/weekly/${FILENAME} ${TEMP}/${YEAR}/${PRJ}-files_${YEAR}-${MONTH}-${DAY_OF_MONTH}.zip
    echo 'Made quarterly backup...'
  fi
fi

# make sunday backup
if [ $DAY_OF_WEEK -eq 7 ] ; then
    cp ${TEMP}/weekly/${FILENAME} ${TEMP}/${YEAR}/${MONTH}/${PRJ}-files_${YEAR}-${MONTH}-${DAY_OF_MONTH}.zip
    echo 'Made sunday backup...'
fi

# Merge The Backup To The Local Destination's Backup Folder
cp -rf ${TEMP}/* $DESTINATION

# Delete The Temporary Folder
rm -rf ${TEMP}
echo 'finished backup.'

# on new year delete monthly backup-folders older than 2 years
if [ $DAY_OF_MONTH -eq 1 ] ; then
  if [ $MONTH -eq 1 ] ; then
    LIMIT=$((2*365))
    cd $DESTINATION
    for dir in $(find . -maxdepth 2 -mindepth 2 -type d); do test $(find $dir -type f -mtime -$LIMIT -print -quit) || rm -rf $dir; done
    echo 'deleted old backups'
  fi
fi
