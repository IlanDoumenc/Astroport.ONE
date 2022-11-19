#!/bin/bash
################################################################################
# Author: Fred (support@qo-op.com)
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
################################################################################
## ASTROPORT API SERVER http://$myIP:1234
## ATOMIC GET REDIRECT TO ONE SHOT WEB SERVICE THROUGH PORTS
## ASYNCHRONOUS IPFS API
################################################################################
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
ME="${0##*/}"

MOATS=$(date -u +"%Y%m%d%H%M%S%4N")
IPFSNODEID=$(cat ~/.ipfs/config | jq -r .Identity.PeerID)
myIP=$(hostname -I | awk '{print $1}' | head -n 1)
isLAN=$(echo $myIP | grep -E "/(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^::1$)|(^[fF][cCdD])/")
[[ ! $myIP || $isLAN ]] && myIP="astroport.localhost"

PORT=12345

    YOU=$(ipfs swarm peers >/dev/null 2>&1 && echo "$USER" || ps auxf --sort=+utime | grep -w ipfs | grep -v -E 'color=auto|grep' | tail -n 1 | cut -d " " -f 1); ## $USER running ipfs
    LIBRA=$(head -n 2 ~/.zen/Astroport.ONE/A_boostrap_nodes.txt | tail -n 1 | cut -d ' ' -f 2) ## SWARM#0 ENTRANCE URL

mkdir -p ~/.zen/tmp/coucou/

## CHECK FOR ANY ALREADY RUNNING nc
ncrunning=$(ps auxf --sort=+utime | grep -w 'nc -l -p 1234' | grep -v -E 'color=auto|grep' | tail -n 1 | cut -d " " -f 1)
[[ $ncrunning ]] && echo "ERROR - API Server Already Running -  http://$myIP:1234/?salt=totodu56&pepper=totodu56&getipns " && exit 1
## NOT RUNNING TWICE

# Some client needs to respect that
HTTPCORS="HTTP/1.1 200 OK
Access-Control-Allow-Origin: \*
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: GET
Server: Astroport.ONE
Content-Type: text/html; charset=UTF-8

"

echo "_________________________________________________________"
echo "LAUNCHING Astroport  API Server - TEST - "
echo
echo "CREATE GCHANGE + TW http://$myIP:1234/?salt=totodu56&pepper=totodu56&g1pub=on&email=fred@astroport.com"
echo
echo "OPEN TW R/W http://$myIP:1234/?salt=totodu56&pepper=totodu56&official"
echo
echo "GCHANGE MESSAGING http://$myIP:1234/?salt=totodu56&pepper=totodu56&messaging"
echo "GCHANGE PLAYER URL http://$myIP:1234/?salt=totodu56&pepper=totodu56&g1pub"
echo
echo "TESTCRAFT http://$myIP:1234/?salt=totodu56&pepper=totodu56&testcraft=on&nodeid=12D3KooWK1ACupF7RD3MNvkBFU9Z6fX11pKRAR99WDzEUiYp5t8j&dataid=QmPXhrqQrS1bePKJUPH9cJ2qe4RrNjaJdRXaJzSjxWuvDi"
echo "_________________________________________________________"

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

while true; do
    start=`date +%s`

    MOATS=$(date -u +"%Y%m%d%H%M%S%4N")
    ## CHANGE NEXT PORT (HERE YOU CREATE A SOCKET QUEUE)
    [ ${PORT} -le 12345 ] && PORT=$((PORT+${RANDOM:0:2})) || PORT=$((PORT-${RANDOM:0:2}))
    pidportinuse=$(ps axf --sort=+utime | grep -w "nc -l -p ${PORT}" | grep -v -E 'color=auto|grep' | tail -n 1 | cut -d " " -f 2)
    [[ $pidportinuse ]] && kill -9 $pidportinuse && echo "KILLING $portinuse " && continue
                ## RANDOM PORT SWAPPINESS AVOIDING COLLISION

    ## CHECK 12345 PORT RUNNING (PUBLISHING IPNS SWARM MAP)
    maprunning=$(ps auxf --sort=+utime | grep -w '_12345.sh' | grep -v -E 'color=auto|grep' | tail -n 1 | cut -d " " -f 1)
    #maprunning=$(ps auxf --sort=+utime | grep -w 'nc -l -p 12345' | grep -v -E 'color=auto|grep' | tail -n 1 | cut -d " " -f 1)
    [[ ! $maprunning ]] && ($MY_PATH/_12345.sh &) && echo '(ᵔ◡◡ᵔ) LAUNCHING http://'$myIP:'12345 (ᵔ◡◡ᵔ)'

    ############### IPNS SESSION KEY TRY LATER
    ### CREATE IPNS KEY - ACTIVATE WHITH ENOUGH BOOTSTRAP
        ### echo
        ### ipfs key rm ${PORT} > /dev/null 2>&1
        ### SESSIONNS=$(ipfs key gen ${PORT})
        ### echo "IPNS SESSION http://$myIP:8080/ipns/$SESSIONNS CREATED"
        ### MIAM=$(echo ${PORT} | ipfs add -q)
        ### ipfs name publish --allow-offline --key=${PORT} /ipfs/$MIAM
        ### end=`date +%s`
        ### echo ${PORT} initialisation time was `expr $end - $start` seconds.
        ### echo
    ###############
    ###############

    # RESET VARIABLES
    SALT=""; PEPPER=""; APPNAME=""
    echo "************************************************************************* "
    echo "ASTROPORT 1234 UP & RUNNING.......................... http://$myIP:1234 PORT"
    echo "${MOATS} NEXT COMMAND DELIVERY PAGE http://$myIP:${PORT}"

    ###############    ###############    ###############    ############### templates/index.http
    # REPLACE myIP in http response template (fixing next API meeting point)
    sed "s~127.0.0.1:12345~$myIP:${PORT}~g" $HOME/.zen/Astroport.ONE/templates/index.http > ~/.zen/tmp/coucou/${MOATS}.myIP.http
    sed -i "s~127.0.0.1~$myIP~g" ~/.zen/tmp/coucou/${MOATS}.myIP.http
    sed -i "s~:12345~:${PORT}~g" ~/.zen/tmp/coucou/${MOATS}.myIP.http
    sed -i "s~_IPFSNODEID_~${IPFSNODEID}~g" ~/.zen/tmp/coucou/${MOATS}.myIP.http ## NODE PUBLISH HOSTED ${WHAT}'S JSON
    sed -i "s~_HOSTNAME_~$(hostname)~g" ~/.zen/tmp/coucou/${MOATS}.myIP.http ## HOSTNAME
    ###############    ###############    ###############    ###############
    ############################################################################
    ## SERVE LANDING REDIRECT PAGE ~/.zen/tmp/coucou/${MOATS}.myIP.http on PORT 1234 (LOOP BLOCKING POINT)
    ############################################################################
    URL=$(cat $HOME/.zen/tmp/coucou/${MOATS}.myIP.http | nc -l -p 1234 -q 1 | grep '^GET' | cut -d ' ' -f2  | cut -d '?' -f2)
    ############################################################################
    espeak "Ding" > /dev/null 2>&1

    echo "URL" > ~/.zen/tmp/coucou/${MOATS}.url ## LOGGING URL
    ############################################################################
    start=`date +%s`

    ############################################################################
    ## / CONTACT - PUBLISH HTML HOMEPAGE (ADD HTTP HEADER)
    if [[ $URL == "/" ]]; then
        echo "/ CONTACT :  http://$myIP:1234"
        echo "___________________________ Preparing register.html"
        echo "$HTTPCORS" > ~/.zen/tmp/coucou/${MOATS}.index.redirect ## HTTP 1.1 HEADER + HTML BODY
sed "s~127.0.0.1~$myIP~g" $HOME/.zen/Astroport.ONE/templates/register.html >> ~/.zen/tmp/coucou/${MOATS}.index.redirect
sed -i "s~_IPFSNODEID_~${IPFSNODEID}~g" ~/.zen/tmp/coucou/${MOATS}.index.redirect
sed -i "s~_HOSTNAME_~$(hostname)~g" ~/.zen/tmp/coucou/${MOATS}.index.redirect

## Random Background image ;)
sed -i "s~.000.~.$(printf '%03d' $(echo ${RANDOM} % 18 | bc)).~g" ~/.zen/tmp/coucou/${MOATS}.index.redirect

        cat ~/.zen/tmp/coucou/${MOATS}.index.redirect | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &
        end=`date +%s`
        echo " (☓‿‿☓) Execution time was "`expr $end - $start` seconds.
        continue
    fi
    ############################################################################
    ############################################################################

    ############################################################################
    echo "=================================================="
    echo "GET RECEPTION : $URL"
    arr=(${URL//[=&]/ })

    # CHECK APPNAME
        APPNAME=$(urldecode ${arr[4]})
        WHAT=$(urldecode ${arr[5]})

    [[ ${arr[0]} == "" || ${arr[1]} == "" ]] && (echo "$HTTPCORS ERROR - MISSING DATA" | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && continue

########## CHECK GET PARAM NAMES
###################################################################################################
###################################################################################################
# API ZERO ## Made In Zion & La Bureautique
    if [[ ${arr[0]} == "salt" ]]; then
        ################### KEY GEN ###################################
        echo ">>>>>>>>>>>>>> Application LaBureautique >><< APPNAME = $APPNAME <<<<<<<<<<<<<<<<<<<<"

        SALT=$(urldecode ${arr[1]} | xargs);
        [[ ! $SALT ]] && (echo "$HTTPCORS ERROR - SALT MISSING" | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && continue
        PEPPER=$(urldecode ${arr[3]} | xargs)
        [[ ! $PEPPER ]] && (echo "$HTTPCORS ERROR - PEPPER MISSING" | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && continue

        APPNAME=$(urldecode ${arr[4]} | xargs)
        [[ ! $APPNAME ]] && (echo "$HTTPCORS ERROR - APPNAME MISSING" | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && continue

        WHAT=$(urldecode ${arr[5]} | xargs)

        ## SAVE "salt" "pepper" DEBUG REMOVE OR PASS ENCRYPT FOR SECURITY REASON
        echo "PLAYER CREDENTIALS : \"$SALT\" \"$PEPPER\""
        echo "\"$SALT\" \"$PEPPER\"" > ~/.zen/tmp/coucou/${MOATS}.secret.june

        # CALCULATING ${MOATS}.secret.key + G1PUB
        ${MY_PATH}/tools/keygen -t duniter -o ~/.zen/tmp/coucou/${MOATS}.secret.key  "$SALT" "$PEPPER"
        G1PUB=$(cat ~/.zen/tmp/coucou/${MOATS}.secret.key | grep 'pub:' | cut -d ' ' -f 2)
        [[ ! ${G1PUB} ]] && (echo "$HTTPCORS ERROR - KEYGEN  COMPUTATION DISFUNCTON"  | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && continue
        echo "G1PUB : ${G1PUB}"

        ## CALCULATING IPNS ADDRESS
        ipfs key rm ${G1PUB} > /dev/null 2>&1
        rm -f ~/.zen/tmp/coucou/${MOATS}.${G1PUB}.ipns.key
        ${MY_PATH}/tools/keygen -t ipfs -o ~/.zen/tmp/coucou/${MOATS}.${G1PUB}.ipns.key "$SALT" "$PEPPER"
        ASTRONAUTENS=$(ipfs key import ${G1PUB} -f pem-pkcs8-cleartext ~/.zen/tmp/coucou/${MOATS}.${G1PUB}.ipns.key )
        echo "ASTRONAUTE TW : http://$myIP:8080/ipns/${ASTRONAUTENS}"
        echo
        ################### KEY GEN ###################################
    # Get PLAYER wallet amount
    ( ## SUB PROCESS
        COINS=$($MY_PATH/tools/jaklis/jaklis.py -k ~/.zen/tmp/coucou/${MOATS}.secret.key balance)
        echo "+++ WALLET BALANCE _ $COINS (G1) _"
        end=`date +%s`
        echo "G1WALLET  (☓‿‿☓) Execution time was "`expr $end - $start` seconds.
    ) &
########################################
        ## ARCHIVE TOCTOC ${WHAT}S & KEEPS LOGS CLEAN
        mkdir -p ~/.zen/game/players/.toctoc/
        ISTHERE=$(ls -t ~/.zen/game/players/.toctoc/*.${G1PUB}.ipns.key 2>/dev/null | tail -n 1)
        TTIME=$(echo $ISTHERE | rev | cut -d '.' -f 4 | cut -d '/' -f 1  | rev)
        if [[ ! $ISTHERE ]]; then
            echo "${WHAT} 1ST TOCTOC : ${MOATS}"
            cp ~/.zen/tmp/coucou/${MOATS}.* ~/.zen/game/players/.toctoc/
        else ## KEEP 1ST CONTACT ONLY
            OLDONE=$(ls -t ~/.zen/tmp/coucou/*.${G1PUB}.ipns.key | tail -n 1)
            DTIME=$(echo $OLDONE | rev | cut -d '.' -f 4 | cut -d '/' -f 1  | rev)
            [[ $DTIME != ${MOATS} ]] && rm ~/.zen/tmp/coucou/$DTIME.*
        fi

## APPNAME SLECTION  ########################
        # MESSAGING
        if [[ $APPNAME == "messaging" || $APPNAME == "email" ]]; then
            ( ## SUB PROCESS
            echo "Extracting ${G1PUB} messages..."
            ~/.zen/Astroport.ONE/tools/timeout.sh -t 12 \
            ${MY_PATH}/tools/jaklis/jaklis.py -k ~/.zen/tmp/coucou/${MOATS}.secret.key read -n 10 -j  > ~/.zen/tmp/coucou/messin.${G1PUB}.json
            [[ ! -s ~/.zen/tmp/coucou/messin.${G1PUB}.json || $(grep  -v -E 'Aucun message à afficher' ~/.zen/tmp/coucou/messin.${G1PUB}.json) == "True" ]] && echo "[]" > ~/.zen/tmp/coucou/messin.${G1PUB}.json

            ~/.zen/Astroport.ONE/tools/timeout.sh -t 12 \
            ${MY_PATH}/tools/jaklis/jaklis.py -k ~/.zen/tmp/coucou/${MOATS}.secret.key read -n 10 -j -o > ~/.zen/tmp/coucou/messout.${G1PUB}.json
            [[ ! -s ~/.zen/tmp/coucou/messout.${G1PUB}.json || $(grep  -v -E 'Aucun message à afficher' ~/.zen/tmp/coucou/messout.${G1PUB}.json) == "True" ]] && echo "[]" > ~/.zen/tmp/coucou/messout.${G1PUB}.json

            echo "Creating messages In/Out JSON ~/.zen/tmp/coucou/${MOATS}.messaging.json"
            echo '[' > ~/.zen/tmp/coucou/${MOATS}.messaging.json
            cat ~/.zen/tmp/coucou/messin.${G1PUB}.json >> ~/.zen/tmp/coucou/${MOATS}.messaging.json
            echo "," >> ~/.zen/tmp/coucou/${MOATS}.messaging.json
            cat ~/.zen/tmp/coucou/messout.${G1PUB}.json >> ~/.zen/tmp/coucou/${MOATS}.messaging.json
            echo ']' >> ~/.zen/tmp/coucou/${MOATS}.messaging.json

            ## ADDING HTTP/1.1 PROTOCOL HEADER
            echo "$HTTPCORS" > ~/.zen/tmp/coucou/${MOATS}.index.redirect
            sed -i "s~text/html~application/json~g"  ~/.zen/tmp/coucou/${MOATS}.index.redirect
            cat ~/.zen/tmp/coucou/${MOATS}.messaging.json >> ~/.zen/tmp/coucou/${MOATS}.index.redirect

            ### REPONSE=$(cat ~/.zen/tmp/coucou/${MOATS}.messaging.json | ipfs add -q)
            ###   ipfs name publish --allow-offline --key=${PORT} /ipfs/$REPONSE
            ###   echo "SESSION http://$myIP:8080/ipns/$SESSIONNS "

            cat ~/.zen/tmp/coucou/${MOATS}.index.redirect | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &
            end=`date +%s`
            dur=`expr $end - $start`
            echo ${MOATS}:${G1PUB}:${PLAYER}:${APPNAME}:$dur >> ~/.zen/tmp/${IPFSNODEID}/_timings
            cat ~/.zen/tmp/${IPFSNODEID}/_timings | tail -n 1
            ) &

            end=`date +%s`
            echo " Messaging launch (☓‿‿☓) Execution time was "`expr $end - $start` seconds.
            continue
        fi
        ######################## MESSAGING END

########################################
# G1PUB -> Open Gchange Profile
########################################
        if [[ "$APPNAME" == "g1pub" && ${arr[7]} == "" ]]; then
            ## NO EMAIL = REDIRECT TO GCHANGE PROFILE
            sed "s~_TWLINK_~https://www.gchange.fr/#/app/user/${G1PUB}/~g" ~/.zen/Astroport.ONE/templates/index.302  > ~/.zen/tmp/coucou/${MOATS}.index.redirect
            ## https://git.p2p.legal/La_Bureautique/zeg1jeux/src/branch/main/lib/Fred.class.php#L81
            echo "url='https://www.gchange.fr/#/app/user/"${G1PUB}"/'" >> ~/.zen/tmp/coucou/${MOATS}.index.redirect
            echo "GCHANGE REDIRECTING https://www.gchange.fr/#/app/user/"${G1PUB}"/"
            ###  REPONSE=$(echo https://www.gchange.fr/#/app/user/${G1PUB}/ | ipfs add -q)
            ### ipfs name publish --allow-offline --key=${PORT} /ipfs/$REPONSE
            ### echo "SESSION http://$myIP:8080/ipns/$SESSIONNS "

            cat ~/.zen/tmp/coucou/${MOATS}.index.redirect | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &
            end=`date +%s`
            echo $APPNAME" (☓‿‿☓) Execution time was "`expr $end - $start` seconds.
            continue
        fi
########################################
########################################
########################################
#TESTCRAFT=ON nodeid dataid
########################################
########################################
        if [[ "$APPNAME" == "testcraft" ]]; then
        ( # testcraft SUB PROCESS
            start=`date +%s`
            ## RECORD DATA MADE IN BROWSER (JSON)
            SALT=$(urldecode ${arr[1]} | xargs)
            PEPPER=$(urldecode ${arr[3]} | xargs)
            NODEID=$(urldecode ${arr[7]} | xargs)
            DATAID=$(urldecode ${arr[9]} | xargs)

            ## IS IT INDEX JSON
            echo "$APPNAME IS ${WHAT}"
            mkdir -p ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}

            [[ $WHAT == "on" ]] && WHAT="json" # data mimetype (default "on" = json)

            ## TODO : modify timeout if isLAN or NOT
            [[ $isLAN ]] && WAIT=3 || WAIT=6
            echo "1ST TRY : ipfs --timeout ${WAIT}s cat /ipfs/$DATAID  > ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}/${MOATS}.data.${WHAT}"
            ipfs --timeout ${WAIT}s cat /ipfs/$DATAID  > ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}/${MOATS}.data.${WHAT}

echo "" > ~/.zen/tmp/.ipfsgw.bad.twt # TODO move in 20h12.sh

            if [[ ! -s ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}/${MOATS}.data.${WHAT} ]]; then

                echo "IPFS TIMEOUT >>> (°▃▃°) $DATAID STILL MISSING GATEWAY BANGING FOR IT (°▃▃°)"
                array=(https://tube.copylaradio.com/ipfs/:hash https://ipns.co/:hash https://dweb.link/ipfs/:hash https://ipfs.io/ipfs/:hash https://ipfs.fleek.co/ipfs/:hash https://ipfs.best-practice.se/ipfs/:hash https://gateway.pinata.cloud/ipfs/:hash https://gateway.ipfs.io/ipfs/:hash https://cf-ipfs.com/ipfs/:hash https://cloudflare-ipfs.com/ipfs/:hash)
                # size=${#array[@]}; index=$(($RANDOM % $size)); echo ${array[$index]} ## TODO CHOOSE RANDOM

                # official ipfs best gateway from https://luke.lol/ipfs.php
                for nicegw in ${array[@]}; do

                    [[ $(cat ~/.zen/tmp/.ipfsgw.bad.twt | grep -w $nicegw) ]] && echo "<<< BAD GATEWAY >>>  $nicegw" && continue
                    gum=$(echo  "$nicegw" | sed "s~:hash~$DATAID~g")
                    echo "LOADING $gum"
                    curl -m 5 -so ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}/${MOATS}.data.${WHAT} "$gum"
                    [[ $? != 0 ]] && echo "(✜‿‿✜) BYPASSING"

                    if [[ -s ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}/${MOATS}.data.${WHAT} ]]; then

                        MIME=$(mimetype -b ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}/${MOATS}.data.${WHAT})
                        GOAL=$(ipfs add -q ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}/${MOATS}.data.${WHAT})

                        if [[ ${GOAL} != ${DATAID} ]]; then
                            echo " (╥☁╥ ) - BAD ${WHAT} FORMAT ERROR ${MIME} - (╥☁╥ )"
                            ipfs pin rm /ipfs/${GOAL}
                            rm ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}/${MOATS}.data.${WHAT}
                            # NOT A JSON AVOID BANISHMENT
                            echo $nicegw >> ~/.zen/tmp/.ipfsgw.bad.twt
                            continue

                        else
                            ## GOT IT !! IPFS ADD
                            ipfs pin add /ipfs/${GOAL}
                            ## + TW ADD (new_file_in_astroport.sh)

                            echo "(♥‿‿♥) FILE UPLOAD OK"; echo
                            break

                        fi

                    else

                        echo " (⇀‿‿↼) - NO FILE - (⇀‿‿↼)"
                        continue

                    fi

                done

            fi ## NO DIRECT IPFS - GATEWAY TRY

           ## REALLY NO FILE FOUND !!!
           [[ ! -s ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}/${MOATS}.data.${WHAT} ]] && \
           echo "$HTTPCORS ERROR (╥☁╥ ) - $DATAID TIMEOUT - (╥☁╥ )" | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &

            ## SPECIAL  index.[json/html/...] MODE.
            [[ ${WHAT} == "index" ]] && cp ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}/${MOATS}.data.${WHAT} ~/.zen/tmp/${IPFSNODEID}/${APPNAME}.json
## TODO MAKE MULTIFORMAT DATA & INDEX
#            RWHAT=$(echo "$WHAT" | cut -d '.' -f 1)
#            TWHAT=$(echo "$WHAT" | cut -d '.' -f 2)
#            cp ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}/${MOATS}.data.${WHAT} ~/.zen/tmp/${IPFSNODEID}/${APPNAME}/${RWHAT}.${TWHAT}

            ## REPONSE ON PORT
                echo "$HTTPCORS" > ~/.zen/tmp/coucou/${MOATS}.index.redirect
                sed -i "s~text/html~application/json~g"  ~/.zen/tmp/coucou/${MOATS}.index.redirect
                cat ~/.zen/tmp/${IPFSNODEID}/${ASTRONAUTENS}/${APPNAME}/${MOATS}.data.${WHAT} >> ~/.zen/tmp/coucou/${MOATS}.index.redirect

                cat ~/.zen/tmp/coucou/${MOATS}.index.redirect | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &

            ## REPONSE ON IPFSNODEID
                (
                    start=`date +%s`
                    echo "¯\_༼<O͡〰o>༽_/¯ $IPFSNODEID $PLAYER SIGNALING"
                    ROUTING=$(ipfs add -rwq ~/.zen/tmp/${IPFSNODEID}/* | tail -n 1 )
                    ipfs name publish --allow-offline /ipfs/$ROUTING
                    echo "DONE"
                    end=`date +%s`
                    dur=`expr $end - $start`
                    echo ${MOATS}:${G1PUB}:${PLAYER}:SELF:$dur >> ~/.zen/tmp/${IPFSNODEID}/_timings
                    cat ~/.zen/tmp/${IPFSNODEID}/_timings | tail -n 1
                ) &

            end=`date +%s`
            dur=`expr $end - $start`
            echo ${MOATS}:${G1PUB}:${PLAYER}:${APPNAME}:$dur >> ~/.zen/tmp/${IPFSNODEID}/_timings
            cat ~/.zen/tmp/${IPFSNODEID}/_timings | tail -n 1
        ) & # testcraft SUB PROCESS

            end=`date +%s`
            echo "(☓‿‿☓) Execution time was "`expr $end - $start` seconds.
            continue
        fi

##############################################
# GETIPNS
##############################################
        if [[ $APPNAME == "getipns" ]]; then
            echo "$HTTPCORS /ipns/${ASTRONAUTENS}"| nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &
            end=`date +%s`
            echo $APPNAME" (☓‿‿☓) Execution time was "`expr $end - $start` seconds.
            continue
        fi


##############################################
# DEFAULT (NO REDIRECT DONE YET) CHECK OFFICIAL GATEWAY
##############################################
        TWIP=$(hostname)
        # OFFICIAL Gateway ( increase waiting time ) - MORE SECURE
        if [[ $APPNAME == "official" ]]; then

            echo "SEARCHING FOR OFFICIAL TW GW... $LIBRA/ipns/${ASTRONAUTENS} ($YOU)"

            ## GETTING LAST TW via IPFS or HTTP GW
            [[ $YOU ]] && echo "http://$myIP:8080/ipns/${ASTRONAUTENS} ($YOU)" && ipfs --timeout 12s cat  /ipns/${ASTRONAUTENS} > ~/.zen/tmp/coucou/${MOATS}.astroindex.html
            [[ ! -s ~/.zen/tmp/coucou/${MOATS}.astroindex.html ]] && echo "$LIBRA/ipns/${ASTRONAUTENS}" && curl -m 12 -so ~/.zen/tmp/coucou/${MOATS}.astroindex.html "$LIBRA/ipns/${ASTRONAUTENS}"

            # DEBUG
            # echo "tiddlywiki --load ~/.zen/tmp/coucou/${MOATS}.astroindex.html  --output ~/.zen/tmp --render '.' 'miz.json' 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' 'MadeInZion'"
            # echo "cat ~/.zen/tmp/miz.json | jq -r .[].secret"

            if [[ -s ~/.zen/tmp/coucou/${MOATS}.astroindex.html ]]; then
                echo "GOT TW CACHE !!"
                tiddlywiki --load ~/.zen/tmp/coucou/${MOATS}.astroindex.html  --output ~/.zen/tmp --render '.' 'miz.json' 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' 'MadeInZion'
                SECRET=$(cat ~/.zen/tmp/miz.json | jq -r .[].secret)
                [[ ! $SECRET ]] && (echo "$HTTPCORS SECRET ERROR - SORRY - CANNOT CONTINUE " | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && echo "BAD SECRET (☓‿‿☓) Execution time was "`expr $(date +%s) - $start` seconds. && continue
#
        # CRYPTO DECODING CRYPTIP -> myIP
                cat ~/.zen/tmp/miz.json | jq -r .[].secret | base16 -d > ~/.zen/tmp/myIP.$G1PUB.enc.2
                $MY_PATH/tools/natools.py decrypt -f pubsec -k ~/.zen/tmp/coucou/${MOATS}.secret.key -i ~/.zen/tmp/myIP.$G1PUB.enc.2 -o ~/.zen/tmp/myIP.$G1PUB > /dev/null 2>&1
                GWIP=$(cat  ~/.zen/tmp/myIP.$G1PUB > /dev/null 2>&1)

                [[ ! $GWIP ]] && GWIP=$myIP ## CLEAR
#
                echo "TW is on $GWIP"

                echo "WAS $GWIP ($TUBE) BECOMING TW GATEWAY : $myIP" ## BECOMING OFFICIAL BECOME R/W TW

                ###########################
                # Modification Tiddlers de contrôle de GW & API
                echo '[{"title":"$:/ipfs/saver/api/http/localhost/5001","tags":"$:/ipfs/core $:/ipfs/saver/api","text":"http://'$myIP':5001"}]' > ~/.zen/tmp/5001.json
                echo '[{"title":"$:/ipfs/saver/gateway/http/localhost","tags":"$:/ipfs/core $:/ipfs/saver/gateway","text":"http://'$myIP':8080"}]' > ~/.zen/tmp/8080.json

                tiddlywiki --load ~/.zen/tmp/coucou/${MOATS}.astroindex.html \
                            --import "$HOME/.zen/tmp/5001.json" "application/json" \
                            --import "$HOME/.zen/tmp/8080.json" "application/json" \
                            --output ~/.zen/tmp/coucou --render "$:/core/save/all" "${MOATS}.newindex.html" "text/plain"

                [[ -s ~/.zen/tmp/coucou/${MOATS}.newindex.html ]] \
                    && cp ~/.zen/tmp/coucou/${MOATS}.newindex.html ~/.zen/tmp/coucou/${MOATS}.astroindex.html \
                    && rm ~/.zen/tmp/coucou/${MOATS}.newindex.html
                ###########################

                    # GET PLAYER FROM Dessin de $PLAYER
                    tiddlywiki --load ~/.zen/tmp/coucou/${MOATS}.astroindex.html --output ~/.zen/tmp --render '.' 'MOA.json' 'text/plain' '$:/core/templates/exporters/JsonFile' 'exportFilter' '[tag[moa]]'
                    PLAYER=$(cat ~/.zen/tmp/MOA.json | jq -r .[].president | head -n 1) ## TRY WITH MULTI moa & G1Moa ?

                    [[ ! $PLAYER ]] \
                    && (echo "$HTTPCORS ERROR - BAD [tag[moa]] president field /ipns/${ASTRONAUTENS} - CONTINUE " | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) &&  echo "BAD MOA (☓‿‿☓) Execution time was "`expr $(date +%s) - $start` seconds. && continue

        if [[ "${PLAYER}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
            echo "VALID PLAYER OK"
        else
            echo "BAD EMAIL"
            (echo "$HTTPCORS KO ${PLAYER} : IPNS key identification failed<br>please correct 'Dessin president field' with your email"   | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && continue
        fi

                    ##  CREATE $PLAYER IPNS KEY (for next 20h12)
                    ipfs key import ${PLAYER} -f pem-pkcs8-cleartext ~/.zen/tmp/coucou/${MOATS}.${G1PUB}.ipns.key
                    [[ ! -d ~/.zen/game/players/$PLAYER/ipfs/moa ]] && mkdir -p ~/.zen/game/players/$PLAYER/ipfs/moa/
                    cp ~/.zen/tmp/coucou/${MOATS}.astroindex.html ~/.zen/game/players/$PLAYER/ipfs/moa/index.html

                    echo "## PUBLISHING ${PLAYER} /ipns/$ASTRONAUTENS/ &"
                    (
                    startipfs=`date +%s`
                    IPUSH=$(ipfs add -Hq ~/.zen/tmp/coucou/${MOATS}.astroindex.html | tail -n 1)
                    [[ $IPUSH ]] && ipfs name publish --key=${PLAYER} /ipfs/$IPUSH 2>/dev/null
                    echo "## PUBLISHING ${PLAYER} /ipns/$ASTRONAUTENS/ END"
                    end=`date +%s`
                    dur=`expr $end - $start`
                    echo ${MOATS}:${G1PUB}:${PLAYER}:TWUPDATE:$dur >> ~/.zen/tmp/${IPFSNODEID}/_timings
                    cat ~/.zen/tmp/${IPFSNODEID}/_timings | tail -n 1
                    ) & # ~~bbbzzzzzz~~&

                    ## MEMORISE PLAYER Ŋ1 ZONE (TODO compare with VISA.new.sh)
                    echo "$PLAYER" > ~/.zen/game/players/$PLAYER/.player
                    echo "$G1PUB" > ~/.zen/game/players/$PLAYER/.g1pub
                    echo "${ASTRONAUTENS}" > ~/.zen/game/players/$PLAYER/.playerns
                    GWIP=${myIP}
                    TWIP=${myIP}
                echo "***********  OFFICIAL LOGIN GOES TO $TWIP"

            else
                echo "NO TW FOUND - LAUNCHING CENTRAL"
                ## 302 REDIRECT CENTRAL GW
                TUBE=$(head -n 2 ~/.zen/Astroport.ONE/A_boostrap_nodes.txt | tail -n 1 | cut -d ' ' -f 3)
                TWIP=${TUBE}
            fi

        ## 302 REDIRECT $TWIP
        cat ~/.zen/Astroport.ONE/templates/index.302 >> ~/.zen/tmp/coucou/${MOATS}.index.redirect
        sed -i "s~_TWLINK_~http://$TWIP:8080/ipns/${ASTRONAUTENS}~g" ~/.zen/tmp/coucou/${MOATS}.index.redirect
        cat ~/.zen/tmp/coucou/${MOATS}.index.redirect | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &

            end=`date +%s`
            dur=`expr $end - $start`
            echo ${MOATS}:${G1PUB}:${PLAYER}:${APPNAME}:$dur >> ~/.zen/tmp/${IPFSNODEID}/_timings
            cat ~/.zen/tmp/${IPFSNODEID}/_timings | tail -n 1

            continue
        fi ## official


        ###################################################################################################
        ###################################################################################################
        # API ONE : ?salt=PHRASE%20UNE&pepper=PHRASE%20DEUX&g1pub=on&email/elastic=ELASTICID&pseudo=PROFILENAME
    if [[ (${arr[6]} == "email" || ${arr[6]} == "elastic") && ${arr[7]} != "" ]]; then

                [[ $APPNAME != "g1pub" ]] && (echo "$HTTPCORS ERROR - BAD COMMAND $APPNAME" | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) &&  echo "(☓‿‿☓) Execution time was "`expr $(date +%s) - $start` seconds. && continue

                start=`date +%s`

                SALT=$(urldecode ${arr[1]} | xargs)
                PEPPER=$(urldecode ${arr[3]} | xargs)
                WHAT=$(urldecode ${arr[7]} | xargs)
                PSEUDO=$(urldecode ${arr[9]} | xargs)

                [[ ! ${WHAT} ]] && (echo "$HTTPCORS ERROR - MISSING ${WHAT} FOR ${WHAT} CONTACT" | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) &&  echo "(☓‿‿☓) Execution time was "`expr $(date +%s) - $start` seconds. &&  continue

        if [[ "${WHAT}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]; then
            echo "VALID EMAIL OK"
        else
            echo "BAD EMAIL"
            (echo "$HTTPCORS KO ${WHAT} : bad '"   | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && continue
        fi

                if [[ ! $PSEUDO ]]; then
                    PSEUDO=$(echo ${WHAT} | cut -d '@' -f 1)
                    PSEUDO=${PSEUDO,,}; PSEUDO=${PSEUDO%%[0-9]*}${RANDOM:0:3}
                fi
                # PASS CRYPTING KEY
                PASS=$(echo "${RANDOM}${RANDOM}${RANDOM}${RANDOM}" | tail -c-7)

            echo "$SALT / $PEPPER ($PASS)"

                if [[ ! -d ~/.zen/game/players/${WHAT} ]]; then
                    echo "# ASTRONAUT NEW VISA Create VISA.new.sh in background (~/.zen/tmp/email.${WHAT}.${MOATS}.txt)"
                    (
                    startvisa=`date +%s`
                    $MY_PATH/tools/VISA.new.sh "$SALT" "$PEPPER" "${WHAT}" "$PSEUDO" > ~/.zen/tmp/email.${WHAT}.${MOATS}.txt
                    $MY_PATH/tools/mailjet.sh "${WHAT}" ~/.zen/tmp/email.${WHAT}.${MOATS}.txt
                    end=`date +%s`
                    dur=`expr $end - $startvisa`
                    echo ${MOATS}:${G1PUB}:${PLAYER}:VISA:$dur >> ~/.zen/tmp/${IPFSNODEID}/_timings
                    cat ~/.zen/tmp/${IPFSNODEID}/_timings | tail -n 1
                    ) &

                    echo "$HTTPCORS -    <meta http-equiv='refresh' content='3; url=\"http://"$myIP":8080/ipns/"$ASTRONAUTENS"\"'/>
                    <h1>BOOTING - ASTRONAUT $PSEUDO </h1> IPFS FORMATING - [$SALT + $PEPPER] (${WHAT})
                    <br>- TW - http://$myIP:8080/ipns/$ASTRONAUTENS <br> - GW - /ipns/$IPFSNODEID" | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &
                     echo "(☓‿‿☓) Execution time was "`expr $end - $start` seconds.
                    continue
               else
                    # ASTRONAUT EXISTING ${WHAT}
                    CHECK=$(cat ~/.zen/game/players/${WHAT}/secret.june | grep -w "$SALT")
                    [[ $CHECK ]] && CHECK=$(cat ~/.zen/game/players/${WHAT}/secret.june | grep -w "$PEPPER")
                    [[ ! $CHECK ]] && (echo "$HTTPCORS ERROR - ${WHAT} ${WHAT} ALREADY EXISTS"  | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) &&  echo "(☓‿‿☓) Execution time was "`expr $(date +%s) - $start` seconds. &&  continue
               fi

                 ###################################################################################################
                end=`date +%s`
                echo " (☓‿‿☓) Execution time was "`expr $end - $start` seconds.

    fi


        ## RESPONDING
        cat ~/.zen/tmp/coucou/${MOATS}.index.redirect | nc -l -p ${PORT} -q 1 > ~/.zen/tmp/coucou/${MOATS}.official.swallow &
        echo "HTTP 1.1 PROTOCOL DOCUMENT READY"
        cat ~/.zen/tmp/coucou/${MOATS}.index.redirect
        echo "${MOATS} -----> PAGE AVAILABLE -----> http://$myIP:${PORT}"

        #echo "${ASTRONAUTENS}" | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &

        ## CHECK IF ALREADY EXISTING ${WHAT}
        # IF NOT = BATCH CREATE TW
        end=`date +%s`
        echo $type" (☓‿‿☓) Execution time was "`expr $end - $start` seconds.

    fi ## END IF SALT




###################################################################################################
###################################################################################################
# API TWO : ?qrcode=G1PUB
    if [[ ${arr[0]} == "qrcode" ]]; then
        ## Astroport.ONE local use QRCODE Contains ${WHAT} G1PUB
        QRCODE=$(echo $URL | cut -d ' ' -f2 | cut -d '=' -f 2 | cut -d '&' -f 1)   && echo "QRCODE : $QRCODE"
        g1pubpath=$(grep $QRCODE ~/.zen/game/players/*/.g1pub | cut -d ':' -f 1 2>/dev/null)
        WHAT=$(echo "$g1pubpath" | rev | cut -d '/' -f 2 | rev 2>/dev/null)

        ## FORCE LOCAL USE ONLY. Remove to open 1234 API
        [[ ! -d ~/.zen/game/players/${WHAT} || ${WHAT} == "" ]] && (echo "$HTTPCORS ERROR - QRCODE - NO ${WHAT} ON BOARD !!"  | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && continue

        ## USE SECOND HTTP SERVER TO RECEIVE PASS

        [[ ${arr[2]} == "" ]] && (echo "$HTTPCORS ERROR - QRCODE - MISSING ACTION"   | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && continue
        ## Demande de copie d'une URL reçue.
        if [[ ${arr[2]} == "url" ]]; then
            wsource="${arr[3]}"
             [[ ${arr[4]} == "type" ]] && wtype="${arr[5]}" || wtype="Youtube"

            ## CREATION TIDDLER "G1Voeu" G1CopierYoutube
            # /.zen/Astropor.ONE/ajouter_media.sh "$(urldecode $wsource)" "$wtype" "$QRCODE" &
            echo "## Insertion tiddler : G1CopierYoutube"
            echo '[
  {
    "title": "'${MOATS}'",
    "type": "'text/vnd.tiddlywiki'",
    "text": "'$(urldecode $wsource)'",
    "tags": "'CopierYoutube ${${WHAT}}'"
  }
]
' > ~/.zen/tmp/${${WHAT}}.${MOATS}.import.json

            ## TODO ASTROBOT "G1AstroAPI" READS ~/.zen/tmp/${${WHAT}}.${MOATS}.import.json

            (echo "$HTTPCORS OK - ~/.zen/tmp/${${WHAT}}.${MOATS}.import.json WORKS IF YOU MAKE THE WISH voeu 'AstroAPI'"   | nc -l -p ${PORT} -q 1 > /dev/null 2>&1 &) && continue
        fi

    fi


done
exit 0
