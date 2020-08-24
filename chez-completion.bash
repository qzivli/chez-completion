# Copyright (c) 2010-2014 PLT Design Inc.
# Copyright (c) 2018 Q. Ziv Li
#
# This package is distributed under the GNU Lesser General Public
# License (LGPL).  This means that you can link this package into proprietary
# applications, provided you follow the rules stated in the LGPL.  You
# can also modify this package; if you distribute a modified version,
# you must distribute it under the terms of the LGPL, which in
# particular means that you must release the source code for the
# modified software.  See http://www.gnu.org/copyleft/lesser.html
# for more information.


export CHEZ_COMPLETION_CLIENT=bash


# On macOS, you need install Bash v4 by yourself.
if [[ $BASH_VERSINFO -lt 4 ]]; then
    return 1
fi


if [[ $(uname) = "Darwin" ]]; then
    source "$(dirname "$BASH_SOURCE")"/completion-functions.bash
fi


_chez_filedir() {
    COMPREPLY=()
    _filedir "@(ss|sls|scm|sch|sps|sld|so)"
    if [[ "${#COMPREPLY[@]}" -eq 0 ]]; then
        _filedir
    fi
}



_chez_completion() {

    local cur prev single_boolean_opts single_opts double_boolean_opts double_opts

    COMPREPLY=()

    cur="$(_get_cword)"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    double_boolean_opts="--quiet --compile-imported-libraries --import-notify"
    double_boolean_opts+=" --debug-on-exception --eedisable --enable-object-counts"
    double_boolean_opts+=" --retain-static-relocation --verbose --version --help"

    double_opts="--script --program --libdirs --libexts --optimize-level --eehistory --boot"

    single_boolean_opts="-q"
    single_opts="-b"

    optimize_levels="0 1 2 3"



    # if "--" is already given, complete all kind of files, but no options
    for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
        if [[ "${COMP_WORDS[i]}" == "--" ]]; then _chez_filedir; return; fi
    done


    case "$cur" in
        "--"*)
            COMPREPLY=( $(compgen -W "$double_boolean_opts $double_opts" -- "$cur") )
            ;;
        "-"*)
            COMPREPLY=( $(compgen -W "$single_boolean_opts $single_opts" -- "$cur") )
            ;;
        *)
            case "$prev" in
                # these do not take anything completable as arguments
                "-q" | "--quiet" | "--compile-imported-libraries" | "--import-notify" | \
                    "--debug-on-exception" | "--eedisable" | "--enable-object-counts" | \
                    "--retain-static-relocation" | "--verbose" | "--version" | "--help")
                    :  # Do nothing.
                    ;;
                # these takes optimize levels as arguments
                "--optimize-level")
                    COMPREPLY=( $(compgen -W "$optimize_levels" -- "$cur") )
                    ;;
                # otherwise, just a file
                *)
                    _chez_filedir
                    ;;
            esac
            ;;
    esac
}


complete -F _chez_completion scheme
complete -F _chez_completion petite
complete -F _chez_completion chez
