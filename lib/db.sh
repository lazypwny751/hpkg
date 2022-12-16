#!/bin/bash

_init_:db() {
    export packagesdb="${SRCDIR}/packages.sdb"

    if ! command -v "sdb" &> /dev/null ; then
        stout:error "hpkg needs to work sdb (simple data base): https://github.com/radareorg/sdb."
        return 1
    fi
}

db:package:register() {
    _init_:db || {
        stout:error "couldn't initializing database"
        return 1
    }
}

db:package:remove() {
    _init_:db || {
        stout:error "couldn't initializing database"
        return 1
    }
}

db:package:want() {
    _init_:db || {
        stout:error "couldn't initializing database"
        return 1
    }

    local DO="nothing" CHECK="false" package=""

    while [[ "${#}" -gt 0 ]] ; do
        case "${1}" in
            --[pP][aA][cC][kK][aA][gG][eE]|-[pP])
                shift
                local DO="package"
                if [[ -n "${1}" ]] ; then
                    local package="${1}"
                    shift
                fi
            ;;
            --[vV][eE][rR][sS][iI][oO][nN]|-[vV])
                shift
                local DO="version"
            ;;
            --[aA][rR][cC][hH][iI][tT][eE][cC][tT][uU][rR][eE]|-[aA][rR][cC][hH])
                shift
                local DO="architecture"
            ;;
            --[dD][iI][rR][eE][cC][tT][oO][rR][yY]|-[dD][iI][rR])
                shift
                local DO="directory"
            ;;
            --[fF][iI][lL][eE]|-[fF])
                shift
                local DO="file"
            ;;
            --[cC][oO][nN][fF][iI][gG][uU][rR][aA][tT][iI][oO][nN]|-[cC][oO][nN][fF])
                shift
                local DO="confs"
            ;;
            --[cC][hH][eE][cC][kK]|-[cC])
                shift
                local CHECK="true"
            ;;
            *)
                shift
            ;;
        esac
    done

    case "${DO}" in
        package)
            if ${CHECK} ; then
                :
            else
                :
            fi
        ;;
        version)
            if ${CHECK} ; then
                :
            else
                :
            fi
        ;;
        architecture)
            if ${CHECK} ; then
                :
            else
                :
            fi
        ;;
        directory)
            if ${CHECK} ; then
                :
            else
                :
            fi
        ;;
        file)
            if ${CHECK} ; then
                :
            else
                :
            fi
        ;;
        confs)
            if ${CHECK} ; then
                :
            else
                :
            fi
        ;;
        *)
            stout:error "there is no option like \"${DO}\""
        ;;
    esac

    if ! ${status} ; then
        return 1
    fi
}