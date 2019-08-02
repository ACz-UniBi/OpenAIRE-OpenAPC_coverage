#!/bin/bash
#
#
# 
# 2019 Andreas Czerniak <andreas.czerniak@uni-bielefeld.de>
# 2019-08-02 ; initial version on github and clean-up

OAPCDATACSV="../openapc-de/data/apc_de.csv"
MAXLINES=100
SKIPLINES=1

ADATE=`date +%Y%m%d` 
LOGFILE="openAPC2OpenAIRE_${ADATE}.log"

if [ -n $1 ] ; then
  if [ "--help" == "$1" ] || [ "help" == "$1" ] ; then
    echo "usage: $0 [[max. first lines] [skipping lines]]" 
    exit
  fi
  MAXLINES=$1
fi
if [ -n $2 ] ; then
  SKIPLINES=$2
fi

APCDOIS=`cat ${OAPCDATACSV} | tail -n +$((1 + 1)) | awk -F , '{print $4","$3}' | sed 's/"//g' `
#APCDOIS=`cat ${OAPCDATACSV} | tail -n +$((1921 + 1)) | awk -F , '{print $4","$3}' | sed 's/"//g' `
#APCDOIS=`cat ${OAPCDATACSV} | tail -n +$((1 + 1)) | head -n $((10 + 1)) | awk -F , '{print $4","$3}' | sed 's/"//g' `

PID=$$
OAAPIURL="http://api.openaire.eu/search/publications"

FROMID=""
OLDFROM=""
FOUND=0
FROMFOUND=0
FROMCOUNT=0
COUNT=0
SUMEUR=0
PROJECTCOUNT=0

echo $APCDOIS

for i in ${APCDOIS}; do
  COUNT=$((COUNT + 1))
  FROMID=`echo $i | awk -F , '{ print $1 }' `
  APCEUR=`echo $i | awk -F , '{ print $2 }' `

  echo $FROMID
  SAVEDOIFILENAME=`echo $FROMID | sed 's#/#_#g' `
  SAVEDOIDIR=`echo $FROMID | awk '{split($0,a,"/"); print a[1]}' `


  if [ "$FROMID" != "$OLDFROM" ] ; then
     FROMCOUNT=$((FROMCOUNT + 1))
#     echo "   =>   $FROMID  !=  $OLDFROM "
     if [ ! -f "data/${ADATE}/${SAVEDOIDIR}/${SAVEDOIFILENAME}.xml" ] ; then
       GETURL="${OAAPIURL}?format=xml&model=openaire&doi=$FROMID"
       echo "    *  $GETURL"
       HTTPRESPONSE=`curl --silent --fail -X GET "$GETURL" -H "accept: */*" `
       RES=$?
#     echo $HTTPRESPONSE
#     echo -e "\nReturnResult:  $RES"
       TOTAL=` echo $HTTPRESPONSE | xmllint --xpath "//response/header/total/text()" -   ` 
#     TITLE=` echo $HTTPRESPONSE | xmllint --xpath "//results/result/response/header/total/text()" -   ` 
       XMLRET=$?
#     echo -en "* "
#     echo "Answer Total:  $TOTAL"
        if [ ! -d "data/${ADATE}/${SAVEDOIDIR}" ] ; then
          mkdir -p data/${ADATE}/${SAVEDOIDIR}
        fi
       echo $HTTPRESPONSE > data/${ADATE}/${SAVEDOIDIR}/${SAVEDOIFILENAME}.xml
     else
       XMLRET="0"
       TOTAL=`xmlstarlet sel -t -v '//response/header/total/text()'  data/${ADATE}/${SAVEDOIDIR}/${SAVEDOIFILENAME}.xml ` 
     fi
     if [ "$XMLRET" == "0" ] && [ "$TOTAL" != 0 ] ; then
        FROMFOUND=$((FROMFOUND + 1))
        PROJECTSHORTNAME=`xmlstarlet sel -t -v '//funder/@shortname'  data/${ADATE}/${SAVEDOIDIR}/${SAVEDOIFILENAME}.xml | sort -u  | sed ':a;N;$!ba;s/\n/ /g' ` 
        PROJECTLONGNAME=`xmlstarlet sel -t -v '//funder/@name'  data/${ADATE}/${SAVEDOIDIR}/${SAVEDOIFILENAME}.xml | sort -u  | sed 's/ /_/g' | sed ':a;N;$!ba;s/\n/ /g' ` 
	# EC
	PROJECTFUNDINGL0=`xmlstarlet sel -t -v '//funding_level_0/@name' data/${ADATE}/${SAVEDOIDIR}/${SAVEDOIFILENAME}.xml | sort -u   | sed 's/ /_/g' | sed ':a;N;$!ba;s/\n/ /g' `
	# ec__________::EC::FP7
	PROJECTACRONYM=`xmlstarlet sel -t -v '//acronym/text()' data/${ADATE}/${SAVEDOIDIR}/${SAVEDOIFILENAME}.xml | sort -u  | sed 's/ /_/g' | sed ':a;N;$!ba;s/\n/ /g' `
	# ECO2

        echo -e "\n*****************************"
        echo "($PID) FromDOI:  $FROMID  --  $PROJECTSHORTNAME|$PROJECTFUNDINGL0|$PROJECTACRONYM  ( data/${ADATE}/${SAVEDOIDIR}/${SAVEDOIFILENAME}.xml )"
#        echo "     $GETURL"
        echo -n "   TitleName: "
        TITLENAME=`xmlstarlet sel -N oaf="http://namespace.openaire.eu/oaf" -t -v "/response/results/result/metadata/oaf:entity/oaf:result/title/text()" data/${ADATE}/${SAVEDOIDIR}/${SAVEDOIFILENAME}.xml ` 
#        TITLENAME=`xmllint --xpath "//oaf:result/title/text()" data/${ADATE}/${SAVEDOIDIR}/${SAVEDOIFILENAME}.xml ` 
        echo $TITLENAME
        echo ; echo
        echo "$FROMID|$APCEUR|$PROJECTSHORTNAME|$PROJECTLONGNAME|$PROJECTFUNDINGL0|$PROJECTACRONYM" >> ${LOGFILE}
        echo -n "actual sum: "
        SUMEUR=` echo "scale=2; $SUMEUR+$APCEUR" | bc `
        echo "scale=2; $SUMEUR+$APCEUR" | bc
        echo ; echo
     fi
     OLDFROM=$FROMID
     
#     echo "($PID) $TOID"
  fi

done

echo
echo "found: $FROMFOUND / $FROMCOUNT"
echo "found: $FROMFOUND / $FROMCOUNT"  >> ${LOGFILE}
echo "Sum APC: $SUMEUR EUR" | tee -a ${LOGFILE}
echo "scale=2; $SUMEUR/$FROMFOUND" | bc
echo "scale=2; $SUMEUR/$FROMFOUND" | bc >> ${LOGFILE}
echo "  ^^--- EUR per article" | tee -a ${LOGFILE}
