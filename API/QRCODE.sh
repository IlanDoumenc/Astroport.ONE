################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
################################################################################
## API: SALT & PEPPER
################################################################################
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
. "${MY_PATH}/../tools/my.sh"

HTTPCORS="HTTP/1.1 200 OK
Access-Control-Allow-Origin: ${myASTROPORT}
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: GET
Server: Astroport.ONE
Content-Type: text/html; charset=UTF-8

"

start=`date +%s`

PORT=$1 THAT=$2 AND=$3 THIS=$4  APPNAME=$5 WHAT=$6 OBJ=$7 VAL=$8 MOATS=$9
### transfer variables according to script
QRCODE=$THAT
TYPE=$WHAT

## GET TW
mkdir -p ~/.zen/tmp/${MOATS}/

if [[ ${QRCODE} == "station" ]]; then
    ## GENERATE PLAYER G1 TO ZEN ACCOUNTING
    ISTATION=$($MY_PATH/../tools/make_image_ipfs_index_carousel.sh | tail -n 1)
    echo $ISTATION > ~/.zen/ISTATION
    ## SEND TO ISTATION PAGE
    sed "s~_TWLINK_~${myIPFSGW}${ISTATION}/~g" ~/.zen/Astroport.ONE/templates/index.302  > ~/.zen/tmp/${MOATS}/index.redirect
    echo "url='"${myIPFSGW}${ISTATION}"'" >> ~/.zen/tmp/${MOATS}/index.redirect
    (
    cat ~/.zen/tmp/${MOATS}/index.redirect | nc -l -p ${PORT} -q 1 > /dev/null 2>&1
    ) &
    exit 0
fi

## CHECK IF QRCODE is ASTRONAUTENS or G1PUB format
ASTROPATH=$(grep $QRCODE ~/.zen/game/players/*/.playerns | cut -d ':' -f 1 | rev | cut -d '/' -f 2- | rev  2>/dev/null)
if [[ $ASTROPATH != "" ]]; then
    rm ~/.zen/game/players/.current
    ln -s $ASTROPATH ~/.zen/game/players/.current
    echo "LINKING $ASTROPATH to .current"
    #### SELECT PARRAIN "G1PalPé"

    ## SEND TO TW PAGE
    sed "s~_TWLINK_~${myIPFSGW}${QRCODE}/~g" ~/.zen/Astroport.ONE/templates/index.302  > ~/.zen/tmp/${MOATS}/index.redirect
    echo "url='"${myIPFSGW}${QRCODE}"'" >> ~/.zen/tmp/${MOATS}/index.redirect
    (
    cat ~/.zen/tmp/${MOATS}/index.redirect | nc -l -p ${PORT} -q 1 > /dev/null 2>&1
    ) &
fi

## FILTRAGE NON G1 TO IPFS READY QRCODE
ASTROTOIPFS=$(~/.zen/Astroport.ONE/tools/g1_to_ipfs.py ${QRCODE})
        [[ ! ${ASTROTOIPFS} ]] \
        && (echo "$HTTPCORS ERROR - ASTRONAUTENS !!"  | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) \
        && exit 1

echo ">>> ${QRCODE} g1_to_ipfs $ASTROTOIPFS"

## SEND MESSAGE TO CESIUM+ ACCOUNT (ME or .current)
MYPLAYERKEY=$(grep ${QRCODE} ~/.zen/game/players/*/secret.dunikey | cut -d ':' -f 1)
[[ ! $MYPLAYERKEY ]] && MYPLAYERKEY="$HOME/.zen/game/players/.current/secret.dunikey"

CURPLAYER=$(cat ~/.zen/game/players/.current/.player)
CURG1=$(cat ~/.zen/game/players/.current/.g1pub)
CURCOINS=$(~/.zen/Astroport.ONE/tools/timeout.sh -t 20 ${MY_PATH}/../tools/jaklis/jaklis.py balance -p ${CURG1})
echo "CURRENT PLAYER : $CURCOINS G1"


if [[ ${CURG1} == ${QRCODE} ]]; then

    echo "SAME PLAYER AS CURRENT"

else
    ## GET VISITOR G1 WANNET AMOUNT : VISITORCOINS
    VISITORCOINS=$(~/.zen/Astroport.ONE/tools/timeout.sh -t 20 ${MY_PATH}/../tools/jaklis/jaklis.py balance -p ${QRCODE})
    if [[ $VISITORCOINS == "" || $VISITORCOINS == "null" ]]; then
        PALPE=${RANDOM:0:2}
    else
        PALPE=0
    fi

    ## DOES CURRENT IS RICHER THAN 100 G1
    if [ $CURCOINS -gt 99 ]; then

            ## LE COMPTE VISITOR EST VIDE
            echo "## PARRAIN $CURPLAYER SEND $PALPE TO ${QRCODE}"
            ## G1 PAYEMENT
            $MY_PATH/../tools/jaklis/jaklis.py -k ~/.zen/game/players/.current/secret.dunikey pay -a ${PALPE} -p ${QRCODE} -c "ASTRO:ZEN_${PALPE}" -m
            ## MESSAGE CESIUM +
            $MY_PATH/../tools/jaklis/jaklis.py -n $myCESIUM -k $MYPLAYERKEY send -d "${QRCODE}" -t "CADEAU" \
            -m "ASTRO:${CURPLAYER} VOUS ENVOI ${PALPE} JUNE.
            GAGNEZ 100 JUNE EN PLUS !
            CREEZ ET GEOLOCALISEZ VOTRE COMPTE SUR https://gchange.fr \
            ENSUITE REVENEZ SCANNER VOTRE QRCODE"

    else
        ## CURRENT PLAYER IS TOO POOR
        PALPE=0
        echo "VISITEUR POSSEDE ${CURCOINS} G1"

        ## GET G1 WALLET HISTORY
        $MY_PATH/../tools/jaklis/jaklis.py history -p ${QRCODE} -j > ~/.zen/tmp/${MOATS}/g1history.json

        ## SCAN CCHANGE +
        curl -s ${myDATA}/user/profile/${QRCODE} > ~/.zen/tmp/${MOATS}/gchange.json
        ## CHECK IF RELATED TO CESIUM
        CPUB=$(cat ~/.zen/tmp/${MOATS}/gchange.json | jq -r '._source.pubkey' 2>/dev/null)
        ## SCAN GPUB CESIUM +
        curl -s ${myCESIUM}/user/profile/${QRCODE} > ~/.zen/tmp/${MOATS}/gplus.json 2>/dev/null

        ##### MEMBER ??
        if [[ $CPUB && $CPUB != 'null'  ]]; then

            ## SCAN CPUB CESIUM +
            curl -s ${myCESIUM}/user/profile/${CPUB} > ~/.zen/tmp/${MOATS}/cplus.json 2>/dev/null

            ## LINKED CESIUM WALLET
            $MY_PATH/../tools/jaklis/jaklis.py -n $myCESIUM -k $MYPLAYERKEY send -d "${QRCODE}" -t "FORGERON" \
            -m "ASTROPORT. G1. FORGERON ET RESEAU DE CONFIANCE Ŋ1. \
            INSCRIVEZ VOTRE COMPTE GCHANGE SUR : https://astroport.copylaradio.com"



        else

            ## EXTRACT GPS ... CONTINUE THE GAME

        fi
        # $MY_PATH/../tools/jaklis/jaklis.py -n $myGCHANGE -k $MYPLAYERKEY send -d "${QRCODE}" -t "COUCOU" -m "ASTRO ZEN CONTACT"

    fi

            echo "************************************************************"
            echo "$VISITORCOINS (+ ${PALPE}) JUNE"
            echo "************************************************************"


fi
###################################################################################################
#                                                                       THAT=$2 AND=$3 THIS=$4  APPNAME=$5 WHAT=$6 OBJ=$7 VAL=$8
###     amzqr  "$myASTROPORT/?qrcode=$G1PUB&junesec=$PASsec&askpass=$HPass&tw=$ASTRONAUTENS" \
###     amzqr "$myASTROPORT/?qrcode=$WISHKEY&junesec=$PASsec&asksalt=$HPass&flux=$VOEUNS&tw=$ASTRONAUTENS" \
###
if [[ $AND == "junesec" ]]; then
echo "♥BOX♥BOX♥BOX♥BOX♥BOX"
echo "MAGIC WORLD ASTRONAUT & WISHES"


    if [[ $APPNAME == "askpass" ]]; then
        echo ">> ASTRONAUT QRCODE $APPNAME"
        ENDCODED="$THIS"
        HPASS="$WHAT"
        TW="/ipns/$VAL"


    fi

    if [[ $APPNAME == "asksalt" ]]; then
        echo ">> WISH QRCODE $APPNAME"
        ENDCODED="$THIS"
        HSALT="$WHAT"
        FLUX="/ipns/$VAL"

    fi

fi

## TODO MAGIC QRCODE RX / TX
###################################################################################################
# API TWO : ?qrcode=G1PUB&url=____&type=____

if [[ $AND == "url" ]]; then
        URL=$THIS

        if [[ $URL ]]; then

        ## Astroport.ONE local use QRCODE Contains ${WHAT} G1PUB
        g1pubpath=$(grep $QRCODE ~/.zen/game/players/*/.g1pub | cut -d ':' -f 1 2>/dev/null)
        PLAYER=$(echo "$g1pubpath" | rev | cut -d '/' -f 2 | rev 2>/dev/null)

        ## FORCE LOCAL USE ONLY. Remove to open 1234 API
        [[ ! -d ~/.zen/game/players/${PLAYER} || ${PLAYER} == "" ]] \
        && espeak "nope" \
        && (echo "$HTTPCORS ERROR - QRCODE - NO ${PLAYER} ON BOARD !!"  | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) \
        && exit 1

        ## Demande de copie d'une URL reçue.
             [[ ${TYPE} ]] && CHOICE="${TYPE}" || CHOICE="Youtube"

            ## CREATION TIDDLER "G1Voeu" G1CopierYoutube
            # CHOICE = "Video" Page MP3 Web
            ~/.zen/Astropor.ONE/ajouter_media.sh "${URL}" "$PLAYER" "$CHOICE" &

            echo "## Insertion tiddler : G1CopierYoutube"
            echo '[
  {
    "title": "'${MOATS}'",
    "type": "'text/vnd.tiddlywiki'",
    "text": "'${URL}'",
    "tags": "'CopierYoutube ${WHAT}'"
  }
]
' > ~/.zen/tmp/${WHAT}.${MOATS}.import.json

            ## TODO ASTROBOT "G1AstroAPI" READS ~/.zen/tmp/${WHAT}.${MOATS}.import.json

            (echo "$HTTPCORS OK - ~/.zen/tmp/${WHAT}.${MOATS}.import.json WORKS IF YOU MAKE THE WISH voeu 'AstroAPI'"   | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && exit 0

        else

            (echo "$HTTPCORS ERROR - ${AND} - ${THIS} UNKNOWN"   | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && exit 1

        fi
fi
