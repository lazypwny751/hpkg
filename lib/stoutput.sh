#!/bin/bash

stout:die() {
	# fatal error means: deadly error for the proccess. 
	[[ -n "${1}" ]] && local TEXT="${1}" || local TEXT="${BASH_SOURCE[-1]##*/}: fatal error occured."
    echo -e "\033[1;31mfatal\033[0m: ${TEXT}."
	exit 1
}

stout:error() {
	[[ -n "${1}" ]] && local TEXT="${1}" || local TEXT="an error occured"
    echo -e "\t\033[0;31m${BASH_SOURCE[-1]##*/}\033[0m: \033[0;31merror\033[0m: ${TEXT}!"
	return 1
}

stout:warn() {
	[[ -n "${1}" ]] && local TEXT="${1}" || local TEXT="there is something not happend"
    echo -e "\t\033[0;33m${BASH_SOURCE[-1]##*/}\033[0m: \033[0;33mwarning\033[0m: ${TEXT}."
	return 0
}

stout:info() {
	[[ -n "${1}" ]] && local TEXT="${1}" || local TEXT="there was a information about something."
    echo -e "\t\033[0;34m${BASH_SOURCE[-1]##*/}\033[0m: \033[0;34minfo\033[0m: ${TEXT}."
	return 0
}

stout:success() {
	[[ -n "${1}" ]] && local TEXT="${1}" || local TEXT="all good"
    echo -e "\t\033[0;32m${BASH_SOURCE[-1]##*/}\033[0m: \033[0;32msuccess\033[0m: ${TEXT}."
	return 0
}
