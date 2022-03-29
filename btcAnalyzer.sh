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

trap ctrl_c INT

function ctrl_c(){
    echo -e "\n${redColour}[!] Exiting...\n${endColour}"

    #Volver a obtener el cursor
    tput cnorm; exit 1 
}

#Variables globales

unconfirmed_transations="https://www.blockchain.com/btc/unconfirmed-transactions"