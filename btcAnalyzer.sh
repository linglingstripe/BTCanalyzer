#!/bin/bash

#Author: Lingling

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#clear

#ADD ASCII INTRO


trap ctrl_c INT

function ctrl_c(){
    echo -e "\n${redColour}[!] Exiting...\n${endColour}"

    rm ut.* money* amount* 2>/dev/null
    #Volver a obtener el cursor
    tput cnorm; exit 1 
}

function helpPanel(){
    echo -e "\n${redColour}[!] Use: ./btcAnalyzer${endColour}"
    for i in $(seq 1 80);
    do
        echo -ne "${redColour}-";
    done
        echo -ne "${endColour}"
    echo -e "\n\n\t${grayColour}[-e]${endColour}${yellowColour} Exploration Mode${endColour}"
    echo -e "\t\t${purpleColour}unconfirmed_transactions${endColour}${yellowColour}:\t List unconfirmed transactions${endColour}"
    echo -e "\t\t${purpleColour}inspect${endColour}${yellowColour}:\t\t\t Inspect a transaction hash${endColour}"
    echo -e "\t\t${purpleColour}address${endColour}${yellowColour}:\t\t\t Inspect a transaction address${endColour}"
    echo -e "\n\t${grayColour}[-n]${endColour}${yellowColour} Limit the number of outputs${endColour}${blueColour} (Example: -n 10)${endColour}"
    echo -e "\n\t${grayColour}[-h]${endColour}${yellowColour} Show this help panel${endColour}\n"

    tput cnorm; exit 1

}

#Variables globales

unconfirmed_transactions="https://www.blockchain.com/btc/unconfirmed-transactions"
inspect_transaction="https://www.blockchain.com/btc/tx"
inspect_address_url="https://www.blockchain.com/btc/address"

function printTable(){

    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines(){

    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){

    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){

    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){

    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

function unconfirmedTransactions(){

    number_output=$1

    touch ut.tmp

    while [ "$(cat ut.tmp | wc -l)" == "0" ]; do
        curl -s "$unconfirmed_transactions" | html2text > ut.tmp
    done
    
    hashes=$(cat ut.tmp | grep "Hash" -A 1 | grep -v -E "Hash|\--|Time" | head -n $number_output) #HASHES STORED IN VARIABLES TO ITERATE

    echo "Hash_USD_Amount_Time" > ut.table

    for hash in $hashes; do
		echo "${hash}_$(cat ut.tmp | grep "$hash" -A 6 | tail -n 1)_$(cat ut.tmp | grep "$hash" -A 4 | tail -n 1)_$(cat ut.tmp | grep "$hash" -A 2 | tail -n 1)" >> ut.table
	done; echo $

    cat ut.table | tr '_' ' ' | awk '{print $2}' | grep -v "USD" | tr -d '$' | sed 's/\..*//g' | tr -d ',' >> money.txt

    money=0; cat money.txt | while read money_in_line; do
        let money+=$money_in_line
        echo $money > money.tmp
    done;

    echo -n "Total amount in the last $number_output transactions_" > amount.table
    echo "\$$(printf "%'.d\n" $(cat money.tmp))" >> amount.table

    if [ "$(cat ut.table | wc -l)" != "1" ]; then
        echo -ne "${yellowColour}"
        printTable '_' "$(cat ut.table)"
        echo -ne "${endColour}"
        echo -ne "${blueColour}"
        printTable '_' "$(cat amount.table)"
        echo -ne "${endColour}"
        rm ut.* money* amount* 2>/dev/null
        tput cnorm; exit 0
    else
        rm ut.* money* amount* 2>/dev/null
    fi

    echo -ne "${yellowColour}"
    printTable '_' "$(cat ut.table)"
    echo -ne "${endColour}"

    rm ut.* money* amount* 2>/dev/null

    tput cnorm #TAKE POINTER AWAY OR BACK IN
}

parameter_counter=0
while getopts "e:n:h:" arg; do
    case $arg in
        e) exploration_mode=$OPTARG; let parameter_counter+=1;;
        n) number_output=$OPTARG; let parameter_counter+=1;;
        h) helpPanel;;
    esac
done

tput civis

if [ $parameter_counter -eq 0 ]; then
    helpPanel
else
    if [ "$(echo $exploration_mode)" == "unconfirmed_transactions" ]; then
        if [ ! "$number_output" ]; then
            number_output=100
            unconfirmedTransactions $number_output
        else
            unconfirmedTransactions $number_output
        fi
        #unconfirmedTransactions
    fi
fi