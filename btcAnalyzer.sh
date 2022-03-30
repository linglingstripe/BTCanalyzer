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

clear

#ADD ASCII INTRO


trap ctrl_c INT

function ctrl_c(){
    echo -e "\n${redColour}[!] Exiting...\n${endColour}"

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
    echo -e "\n\t${grayColour}[-h]${endColour}${yellowColour} Show this help panel${endColour}\n"

    tput cnorm; exit 1

}

#Variables globales

unconfirmed_transations="https://www.blockchain.com/btc/unconfirmed-transactions"
inspect_transaction="https://www.blockchain.com/btc/tx"
inspect_address_url="https://www.blockchain.com/btc/address"

function unconfirmedTransactions(){

    echo '' > ut.tmp

    while [ "$(cat ut.tmp | wc -l" == "1)" ];do
        curl -s "$unconfirmed_transactions" | html2text > ut.tmp
    done
    
    hashes=$(cat ut.tmp | grep "Hash" -A 1 | grep -v -E "Hash|\--|Time") #HASHES STORED IN VARIABLES TO ITERATE

    for hash in hashes;do
        
    done

    tput cnorm #TAKE POINTER AWAY OR BACK IN
}

parameter_counter=0
while getopts "e:h:" arg; do
    case $arg in
        e) exploration_mode=$OPTARG; let parameter_counter+=1;;
        h) helpPanel;;
    esac
done

tput civis

if [ $parameter_counter -eq 0 ]; then
    helpPanel
else
    if [ "$(echo $exploration_mode)" == "unconfirmed_transactions" ]; then
    unconfirmedTransactions
    fi
fi