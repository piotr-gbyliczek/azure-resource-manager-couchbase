if test "$1" == "" ; then
  echo doone.sh docID
  exit
fi
curl -k $AURL/$BUCKET/$1 -X PUT -H $CTAJ -T $1