#!/bin/bash

build:build() {
    hpkg:srclib "check" || {
        stout:error "required librar(y/ies) couldn't source"
        return 1
    } 
	for _dir_ in "${@}" ; do
	    local _reldir_="$(realpath "${_dir_}")" &> /dev/null

		if [[ -d "${_reldir_}" ]] ; then
		    local WDIR+=("${_reldir_}")
		else
			stout:error "there is no named directory as '${_dir_}', ignoring."
			local status="false"
		fi
	done
		
	if [[ -n "${WDIR[@]}" ]] ; then
		echo -e "\t\033[0;34m==>\033[0m working on \033[1;36m${CWD}\033[0m."
		for _build_ in "${WDIR[@]}" ; do
		    if [[ -d "${_build_}/meta" ]] ; then
			    if [[ -f "${_build_}/meta/package.sh" ]] ; then
                    echo -e "\t\033[1;33m==>\033[0m looking for \033[1;36m${_build_}\033[0m."

                    (
                        unset name version arch conf 
                        readonly pkgroot="${_build_}"

                        # here you can use hpkg:srclib and you can use that utilities.
                        source "${pkgroot}/meta/package.sh"
                        export status="true"

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

                        readonly name version arch

                        if ! command -v "hpkg:build" &> /dev/null ; then
                            stout:error "you just need to define \"\033[1;37mhpkg:build()\033[0m\" funtion to build your package"
                            export status="false"
                        fi

                        # Step 1: check pre requirements.
                        if ! ${status} ; then
                            exit 1
                        fi

                        cd "${pkgroot}"
                                
                        hpkg:build && { 
                            stout:success "function \"\033[1;37mhpkg:build()\033[0m\" returned with \"zero\" exit code"
                        } || {
                            stout:error "function \"\033[1;37mhpkg:build()\033[0m\" returned with \"non zero\" exit code"
                            export status="false"
                        }

                        # Step 2: check build proccess.
                        if ! ${status} ; then
                            exit 1
                        fi

                        # There is meta file.
                        echo "name=\"${name}\"" > "${pkgroot}/meta/pkginfo"
                        echo "version=\"${version}\"" >> "${pkgroot}/meta/pkginfo"
                        echo "arch=\"${arch}\"" >> "${pkgroot}/meta/pkginfo"

                        [[ -f "${pkgroot}/meta/entities" ]] && rm "${pkgroot}/meta/entities"

                        # Get etntity list in build directory
                        while IFS="" read -r _entity_ ; do
                            if  [[ "${_entity_}" != "." && "${_entity_:0:1}" == "." ]] ; then
                                echo "${_entity_#?}" >> "${pkgroot}/meta/entities"
                            fi 
                        done <<< "$(find . -path ./meta -prune -o -print)"

                        if [[ -n "${conf[@]}" ]] ; then
                            [[ -n "${pkgroot}/meta/fconf" ]] && rm "${pkgroot}/meta/fconf"
                            for _conf_ in "${conf[@]}" ; do
                                echo "${_conf_}" >> "${pkgroot}/meta/fconf"
                            done
                        fi

                        tar -zcf "${CWD}/${name}-${version}-${arch}.tar.gz" "." && {
                            echo -e "\t\033[1;32m==>\033[0m \033[1;37m${CWD}/${name}-${version}-${arch}.tar.gz\033[0m"
                        } || {
                            stout:error "the package couldn't compressing"
                            export status="false"
                        }

                        # Step 3: return to main.
                        if ! ${status} ; then
                            exit 1
                        fi
                    ) || {
                    local status="false"
                    }
                else
				    stout:warn "there is no configuration file for package in ${_build_}/meta"
                fi
			else
                stout:error "there is no \"meta\" directory in ${_build_}"
			fi
		done
	fi

    if ! ${status} ; then
        return 1
    fi
}