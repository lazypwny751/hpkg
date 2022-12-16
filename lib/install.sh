#!/bin/bash

install:tmp:up() {
    if ! [[ -n "${_HPKG_TMP_}" ]] ; then
        local _HPKG_TMP_="/tmp/hpkgsh"
    fi

    if ! [[ -n "${_HPKG_PROC_}" ]] ; then
        local _HPKG_PROC_="${$}"
    fi

    if ! [[ -f "${_HPKG_TMP_}/pkg.lock" ]] ; then
        [[ -d "${_HPKG_TMP_}" ]] && rm -rf "${_HPKG_TMP_}"
        mkdir -p "${_HPKG_TMP_}"
        echo "proc=\"${_HPKG_PROC_}\"" > "${_HPKG_TMP_}/pkg.lock"
    else
        source "${_HPKG_TMP_}/pkg.lock" || {
            stout:error "pkg.lock file exists but it couldn't sourcing in this time: ${_HPKG_TMP_}"
            return 2
        }
        stout:error "an another installation already in process: \"${proc}\" at ${_HPKG_TMP_}"
        return 1
    fi
}

install:tmp:down() {
    if ! [[ -n "${_HPKG_TMP_}" ]] ; then
        local _HPKG_TMP_="/tmp/hpkgsh"
    fi

    if [[ -d "${_HPKG_TMP_}" ]] ; then
        rm -rf "${_HPKG_TMP_}"
    fi
}

install:install() {
    if ! [[ -n "${_HPKG_TMP_}" ]] ; then
        local _HPKG_TMP_="/tmp/hpkgsh"
    fi

    local status="true" _PKGS_+=()
    unset _pkg_ _isfile_

    hpkg:srclib "check" "db" || {
        stout:error "required librar(y/ies) couldn't source"
        return 1
    }

    for _isfile_ in "${@}" ; do
        if [[ -f "${_isfile_}" ]] ; then
            local _PKGS_+=("$(realpath "${_isfile_}")")
        fi
    done


    if [[ -n "${_PKGS_[@]}" ]] ; then
        for _pkg_ in "${_PKGS_[@]}" ; do
            (
                export status="true"
                # using subshell for some reasons..
                unset name version arch conf 

                if tar -zxf "${_pkg_}" -C "${_HPKG_TMP_}" "./meta/pkginfo" &> /dev/null ; then
                    source "${_HPKG_TMP_}/meta/pkginfo"
                    # Check the project name:
                    if ! [[ -n "${name}" ]] ; then
                        stout:error "\"\033[1;37m\$name\033[0m\" variable could not be null"
                        export status="false"
                    elif ! check:have:specialchar "${name}" ; then
                        stout:error "\"\033[1;37m\$name\033[0m\" variable is maintain unsupported characters"
                        export status="false"
                    fi

                    # Check version:
                    if ! [[ -n "${version}" ]] ; then
                        stout:error "\"\033[1;37m\$version\033[0m\" variable could not be null"
                        # using check compare version in command substitution because when user
                        # definie broken variable it's return non zero.
                    elif ! $(check:compare:version "${version}" "0.0.0" &> /dev/null) ; then
                        stout:error "\"\033[1;37m\$version\033[0m\" must be like \"n.n.n\" and minimum value can be must be \"0.0.1\""
                        export status="false"
                    fi

                    if ! [[ -n "${arch}" ]] ; then
                        stout:error "\"\033[1;37m\$arch\033[0m\" variable could not be null"
                    else
                        case "${arch}" in
                            [sS][cC][rR][iI][pP][tT]|[mM][uU][lL][tT][iI]|[mM][uU][lL][tT][iI]-[aA][rR][cC][hH])
                                true
                            ;;
                            *)
                                if ! check:is:arch "${arch}" &> /dev/null ; then
                                    stout:error "\"\033[1;37m\$arch\033[0m\" your system couldn't build this package"
                                    export status="false"
                                fi
                            ;;
                        esac
                    fi

                    readonly _name_="${name}" _version_="${version}" _arch_="${arch}" _conf_="${conf}" 

                    # Check the package is installable:
                    if ! ${status} ; then
                        stout:error "the package \"${_pkg_##*/}\" has bad configured"
                        exit 1
                    fi

                    export DIRS="" FILES=""

                    if tar -zxf "${_pkg_}" -C "${_HPKG_TMP_}" &> /dev/null ; then
                        if [[ -f "${_HPKG_TMP_}/meta/entities" ]] ; then
                            while IFS="" read -r entity ; do
                                if [[ -f "${_HPKG_TMP_}/${entity}" ]] ; then
                                    echo -e "file:\t\t${entity}"
                                    if [[ -n "${FILES}" ]] ; then
                                        FILES+=":${entity}"
                                    else
                                        FILES="${entity}"
                                    fi
                                elif [[ -d "${_HPKG_TMP_}/${entity}" ]] ; then
                                    echo -e "directory:\t${entity}"
                                    if [[ -n "${DIRS}" ]] ; then
                                        DIRS+=":${entity}"
                                    else
                                        DIRS="${entity}"
                                    fi
                                fi
                            done < "${_HPKG_TMP_}/meta/entities"
                        else
                            stout:error "there is no file accessible in ${name}"
                            export status="false"
                        fi 
                    else
                        stout:error "${_pkg_##*/} couldn't extracting to the temp directory"    
                    fi
                else
                    stout:error "${_pkg_##*/} isn't a hera package"
                    exit 1
                fi
            ) || {
                local status="false"
            }
        done
    fi

    if ! ${status} ; then
        return 1
    fi
}