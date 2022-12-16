#!/bin/bash

#    hera package manager for every simple systems - hpkg
#    Copyright (C) 2022  lazypwny751
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -e
shopt -s expand_aliases

# Requirements:
#	-> sdb (simple data base)
#	-> coreutils
#	-> tar
#	-> gzip
#	-> findutils
#	-> awk

# Define variables:
export ROOT=""
export PREFIX="${ROOT}/usr" _HPKG_TMP_="${ROOT}/tmp/hpkgsh" _HPKG_PROC_="${$}"
export SRCDIR="${PREFIX}/share/hpkg" 
export LIBDIR="${SRCDIR}/lib"
export CWD="${PWD}" DO="help"
export status="true" version="1.0.0"
export NULLOPT=()
readonly ROOT PREFIX SRCDIR LIBDIR _HPKG_TMP_ _HPKG_PROC_
export requirements=(
	"sdb"
	"gzip"
	"mv"
	"ln"
	"find"
	"awk"
	"mkdir"
	"rm"
	"rmdir"
	"cp"
	"chmod"
	"tar"
)
export srclib=(
	"os"
	"stoutput"
	"alternative"
)

# Define functions:
hpkg:srclib() {
	local arg status="true"
	for arg in "${@}" ; do
		if [[ -f "${LIBDIR}/${arg}.sh" ]] ; then
			source "${LIBDIR}/${arg}.sh" || {
				return 1
			}
		elif [[ -f "${LIBDIR}/${arg}" ]] ; then
			source "${LIBDIR}/${arg}" || {
				return 1
			}
		else
			echo "there is no library found named as \"${arg}\"."
			export status="false"
		fi
	done

	if ! ${status} ; then
		return 1
	fi
}

# Source all those libraries
hpkg:srclib "${srclib[@]}"

os:check:have --command "${requirements[@]}"

# Define aliases
alias realpath="alternative:realpath"

# Parse parameters:
while [[ "${#}" -gt 0 ]] ; do
	case "${1}" in
		[mM][oO][oO]|--[mM][oO][oO])
			shift
			export DO="moo"
		;;
		--[bB][uU][iI][lL][dD]|-[bB])
			shift
			export DO="build" OPTARG=()
			while [[  "${#}" -gt 0 ]] ; do
				case "${1}" in
					--*|-*)
						break
					;;
					*)
						export OPTARG+=("${1}")
						shift
					;;
				esac
			done
		;;
		--[iI][nN][sS][tT][aA][lL][lL]|-[iI])
			shift
			export DO="install" OPTARG=()
			while [[  "${#}" -gt 0 ]] ; do
				case "${1}" in
					--*|-*)
						break
					;;
					*)
						export OPTARG+=("${1}")
						shift
					;;
				esac
			done
		;;
		--[uU][nN][iI][nN][sS][tT][aA][lL]|-[uU])
			shift
			export DO="uninstall" OPTARG=()
			while [[  "${#}" -gt 0 ]] ; do
				case "${1}" in
					--*|-*)
						break
					;;
					*)
						export OPTARG+=("${1}")
						shift
					;;
				esac
			done
		;;
		--[lL][iI][sS][tT]|-[lL])
			shift
			export DO="list"
		;;
		--[hH][eE][lL][pP]|-[hH])
			shift
			export DO="help"
		;;
		--[vV][eE][rR][sS][iI][oO][nN]|-[vV])
			shift
			export DO="version"
		;;
		*)
			export NULLOPT+=("${1}")
			shift
		;;
	esac
done

# Execution the option:
case "${DO}" in
	build)
		hpkg:srclib "build"
		export status="true" WDIR=() _dir_="" _build_=""

		set +e

		if [[ -n "${OPTARG[@]}"	 ]] ; then
			build:build "${OPTARG[@]}" || {
				export status="false"
			}
		else
			stout:error "build: there is no parameter given"
			export status="false"
		fi
	;;
	install)
		hpkg:srclib "install"
		export status="true"
		set +e
		
		if [[ -n "${OPTARG[@]}"	 ]] ; then
			install:tmp:up
			install:install "${OPTARG[@]}" || {
				export status="false"
			}
			install:tmp:down
		else
			stout:error "install: there is no parameter given"
			export status="false"
		fi
	;;
	moo)
		# art by Shanaka Dias: https://www.asciiart.eu/animals/cows.
		echo -e "           __n__n__
    .------\`-/00\-\'
   /  ##  ## (oo)
  / \## __   ./
     |//YY \|/
     |||   |||
[*<]---------------------[OK]
...Yes, i have mooed today..."
	;;
	help)
		echo -e "This helper text about ${0##/*}"
	;;
	version)
		echo "${version}"
	;;
	*)
		echo "${0##*/}: there is no option like: '${DO}'."
	;;
esac

if ${status} ; then
	exit 0
else
	exit 1
fi