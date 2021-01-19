#!/usr/bin/env bash

# Color Settings of Icon shown in Polybar
COLOR_BATTERY_90='#88C0D0'         # Battery >= 90
COLOR_BATTERY_80='#81A1C1'         # Battery >= 80
COLOR_BATTERY_70='#5E81AC'         # Battery >= 70
COLOR_BATTERY_60='#EBCB8B'         # Battery >= 60
COLOR_BATTERY_50='#D08770'         # Battery >= 50
COLOR_BATTERY_LOW='#BF616A'        # Battery <  50
COLOR_DISCONNECTED='#434C5E'       # Device Disconnected
COLOR_NEWDEVICE='#8FBCBB'          # New Device

# Icons shown in Polybar
ICON_SMARTPHONE=''
ICON_TABLET='臨'
SEPERATOR=' '

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

kde() {
    # shellcheck disable=SC2086
    qdbus org.kde.kdeconnect "/modules/kdeconnect/devices/$1" "org.kde.kdeconnect.device.$2" $3
}

show_devices (){
    IFS=$','
    devices=""
    for device in $(qdbus --literal org.kde.kdeconnect /modules/kdeconnect org.kde.kdeconnect.daemon.devices); do
        deviceid=$(echo "$device" | awk -F'["|"]' '{print $2}')
        devicename=$(kde "$deviceid" name)
        devicetype=$(kde "$deviceid" type)
        isreach=$(kde "$deviceid" isReachable)
        istrust=$(kde "$deviceid" isTrusted)

        if [ "$isreach" = "true" ] && [ "$istrust" = "true" ]; then
            battery="$(kde "$deviceid/battery" battery.charge)"
            icon=$(get_icon "$battery" "$devicetype")
            devices+="%{A1:$DIR/polybar-kdeconnect.sh -n '$devicename' -i $deviceid -b $battery -m:}$icon%{A}$SEPERATOR"
        elif [ "$isreach" = "false" ] && [ "$istrust" = "true" ]; then
            devices+="$(get_icon -1 "$devicetype")$SEPERATOR"
        else
            haspairing="$(kde "$deviceid" hasPairingRequests)"
            [ "$haspairing" = "true" ] && show_pmenu2 "$devicename" "$deviceid"
            icon=$(get_icon -2 "$devicetype")
            devices+="%{A1:$DIR/polybar-kdeconnect.sh -n $devicename -i $deviceid -p:}$icon%{A}$SEPERATOR"
        fi
    done
    echo "${devices::-1}"
}

show_menu () {
    menu=$(dmenu -i -p "$DEV_NAME" <<< "$(printf "Battery: $DEV_BATTERY%%\nPing\nFind Device\nSend File\nBrowse Files\nUnpair")")
    case "$menu" in
        *Ping)
            kde "$DEV_ID/ping" ping.sendPing ;;
        *'Find Device')
            kde "$DEV_ID/findmyphone" findmyphone.ring ;;
        *'Send File')
            kde "$DEV_ID/share" share.shareUrl "file://$(zenity --file-selection)" ;;
        *'Browse Files')
            [ "$(kde "$DEV_ID/sftp" sftp.isMounted)" = "false" ] && kde "$DEV_ID/sftp" sftp.mount
            sleep 1
            pcmanfm "$(kde "$DEV_ID/sftp" sftp.mountPoint)/primary" ;;
        *'Unpair' )
            kde "$DEV_ID" unpair ;;
    esac
}

show_pmenu () {
    menu="$(echo Pair Device | dmenu -i)"
    case "$menu" in
        *'Pair Device') kde "$DEV_ID" requestPair
    esac
}

show_pmenu2 () {
    menu="$(printf "Accept\nReject" | dmenu -i -p "$1 has sent a pairing request")"
    case "$menu" in
        *'Accept') kde "$2" acceptPairing ;;
        *)         kde "$2" rejectPairing ;;
    esac

}
get_icon () {
    icon=$ICON_SMARTPHONE
    [ "$2" = "tablet" ] && icon=$ICON_TABLET

    case $1 in
        "-1")   colour="$COLOR_DISCONNECTED" ;;
        "-2")   colour="$COLOR_NEWDEVICE" ;;
        3*)     colour="$COLOR_BATTERY_50" ;;
        4*)     colour="$COLOR_BATTERY_60" ;;
        5*)     colour="$COLOR_BATTERY_70" ;;
        6*)     colour="$COLOR_BATTERY_80" ;;
        7*|8*|9*|100)
                colour="$COLOR_BATTERY_90" ;;
        *)      colour="$COLOR_BATTERY_LOW" ;;
    esac

    if (( $1 > 0)); then
        echo "%{F$colour}$icon $1%%{F-}"
    else
        echo "%{F$colour}$icon%{F-}"
    fi
}

unset DEV_ID DEV_NAME DEV_BATTERY
while getopts 'di:n:b:mp' c
do
    # shellcheck disable=SC2220
    case $c in
        d) show_devices ;;
        i) DEV_ID=$OPTARG ;;
        n) DEV_NAME=$OPTARG ;;
        b) DEV_BATTERY=$OPTARG ;;
        m) show_menu  ;;
        p) show_pmenu ;;
    esac
done

