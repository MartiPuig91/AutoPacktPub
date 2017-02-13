#!/bin/bash

# 10th February 2017
# created by: sergidb

#DESCRIPTION: Download all your books from 'https://www.packtpub.com/account/my-ebooks' choosing the file format [pdf,epub or mobi]

#USAGE:
#	1 - Change customizable parameters
# 	2 - Execute the script

# IMPORTANT: 
#		This script isn't malicious but I (the developer) am not responsible of ANY damage in your computer, files and any
#		problem with your www.packtpub.com account.
# 		USE IT BY YOUR OWN RISK

#CUSTOMIZABLE PARAMETERS
USER="_mpuig1991@gmail.com"						#Your packtpub user
PASS="19910210mpc"									#Your packtpub password
DESTINATIONFORMAT="epub"								#Book format [pdf, epub or mobi]

#WARNING: Don't touch below parameters if you don't know what you are doing
DESTINATIONFOLDER="downloaded_books_"$DESTINATIONFORMAT		#TMP folder where the books will be saved
TMPFOLDER="temp_files"
BOOKFOLDER="books"

#START
if [ ! -d "$TMPFOLDER" ]
	then
		mkdir $TMPFOLDER
fi

if [ ! -d "$TMPFOLDER/$BOOKFOLDER" ]
  then
    mkdir "$TMPFOLDER/$BOOKFOLDER"
fi

echo "Logging in..."
curl -c $TMPFOLDER/tmpcookies 'https://www.packtpub.com/packt/offers/free-learning' -H 'Pragma: no-cache' -H 'Origin: https://www.packtpub.com' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: es-ES,es;q=0.8,ca;q=0.6,en;q=0.4' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: no-cache' -H 'Referer: https://www.packtpub.com/packt/offers/free-learning' -H 'Connection: keep-alive' --data "email=$USER&password=$PASS&op=Login&form_build_id=form-825c8aa03cab405ef03c667d8e2a23a9&form_id=packt_user_login_form" --progress-bar -L > $TMPFOLDER/login.html

echo "Searching for your library..."
curl -b $TMPFOLDER/tmpcookies 'https://www.packtpub.com/account/my-ebooks' -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, sdch, br' -H 'Accept-Language: es-ES,es;q=0.8,ca;q=0.6,en;q=0.4' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: https://www.packtpub.com/packt/offers/free-learning' -H 'Connection: keep-alive' -H 'Cache-Control: no-cache' -L --progress-bar > $TMPFOLDER/myebooks.html

echo "Extracting titles..."
awk '/<div class="title">/{getline; print}' $TMPFOLDER/myebooks.html|rev|cut -c 7-|rev|sed -e "s/'/ /g" > $TMPFOLDER/titols

echo "Extracting book links..."
cat $TMPFOLDER/myebooks.html | grep '<a href="/ebook_download/[0-9]*/'$DESTINATIONFORMAT'">' > $TMPFOLDER/llibres

echo "Obtaining book codes..."
cut -d / -f 3 $TMPFOLDER/llibres > $TMPFOLDER/codisllibres

COMPTADOR=0
TOTAL=$(cat $TMPFOLDER/codisLlibres | wc -l | xargs)

while read codi; do
        COMPTADOR=$(expr $COMPTADOR + 1)

        TITOL=$(sed "${COMPTADOR}q;d" $TMPFOLDER/titols|xargs )

        echo "Downloading book $COMPTADOR of $TOTAL: $TITOL"
        curl https://www.packtpub.com/ebook_download/$codi/$DESTINATIONFORMAT -L -b $TMPFOLDER/tmpcookies --progress-bar > $TMPFOLDER/$BOOKFOLDER/$codi'-'$TITOL.$DESTINATIONFORMAT
done < $TMPFOLDER/codisLlibres

echo "Deleting residual files..."
mv $TMPFOLDER/books $DESTINATIONFOLDER
rm -R $TMPFOLDER

echo "Done. Thank you for use this script :)"