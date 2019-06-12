curl -k $AURL/$BUCKET/_user/public -X PUT -H $CTAJ -T publicuser.json
curl -k $AURL/$BUCKET/_user/ws_notif_user -X PUT -H $CTAJ -T wsnotifuser.json