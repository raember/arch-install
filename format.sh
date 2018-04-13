#!/bin/bash

fg_default="\033[39m"
fg_black="\033[30m"
fg_red="\033[31m"
fg_green="\033[32m"
fg_yellow="\033[33m"
fg_blue="\033[34m"
fg_magenta="\033[35m"
fg_cyan="\033[36m"
fg_light_gray="\033[37m"
fg_dark_gray="\033[90m"
fg_light_red="\033[91m"
fg_light_green="\033[92m"
fg_light_yellow="\033[93m"
fg_light_blue="\033[94m"
fg_light_magenta="\033[95m"
fg_light_cyan="\033[96m"
fg_white="\033[97m"

bg_default="\033[49m"
bg_black="\033[40m"
bg_red="\033[41m"
bg_green="\033[42m"
bg_yellow="\033[43m"
bg_blue="\033[44m"
bg_magenta="\033[45m"
bg_cyan="\033[46m"
bg_light_gray="\033[47m"
bg_dark_gray="\033[100m"
bg_light_red="\033[101m"
bg_light_green="\033[102m"
bg_light_yellow="\033[103m"
bg_light_blue="\033[104m"
bg_light_magenta="\033[105m"
bg_light_cyan="\033[106m"
bg_white="\033[107m"

font_bold="\033[1m"
font_blink="\033[5m"
font_reverse="\033[7m"

font_no_bold="\033[22m"
font_no_blink="\033[25m"
font_no_reverse="\033[27m"

font_reset="\033[0m"

bg_primary="${bg_light_green}"
fg_primary="${fg_light_green}"
if [ "$fancy" = true ] ; then
    format_title="${bg_primary}${fg_black}"
else
    format_title=""
fi
format_normal="$fg_default"
format_variable="$fg_light_cyan"
format_positive="$fg_green"
format_negative="$fg_red"
format_code="$fg_light_gray"
format_no_code="$format_normal"
format_link="$font_blink"
format_no_link="$font_no_blink"

if [ "$fancy" = true ] ; then
    format_prefix="${format_title} ${font_reset} "
else
    format_prefix="  "
fi

print_part() {
    if [ "$fancy" = true ] ; then
        len=${#1}
        printf "${format_title}    "
        printf %${len}s
        printf "    ${font_reset}\n"
        echo -e "${format_title}    $1    ${font_reset}"
        printf "${format_title}    "
        printf %${len}s
        printf "    ${font_reset}\n\n"
    else
        echo -e "${font_bold}$1${font_no_bold}"
    fi
}
print_section() {
    if [ "$fancy" = true ] ; then
        echo -e "${format_title}#${INDEX} $1  ${font_reset}\n${format_prefix}"
    else
        echo -e "#${INDEX} $1"
    fi
}
print_status() {
    echo -e "${format_prefix}${format_normal}$1${font_reset}"
}
print_status_start() {
    if [ "$fancy" = true ] ; then
        echo -e "${format_title} ${font_reset}${fg_primary}__${font_reset}\n"
    fi
}
print_status_end() {
    if [ "$fancy" = true ] ; then
        echo -e "${fg_primary}___${font_reset}\n${format_title} ${font_reset}"
    fi
}
print_pos() {
    echo -e "${format_prefix}${format_normal}${format_positive}$1${font_reset}"
}
print_neg() {
    echo -e "${format_prefix}${format_normal}${format_negative}!!! $1${font_reset}"
}
print_fail() {
    print_neg "$1"
    print_end
    exit 1;
}
print_end() {
    if [ "$fancy" = true ] ; then
        echo -e "${format_title} ${font_reset}${fg_primary}____${font_reset}\n"
    else
        echo ""
    fi
}
print_prompt() {
    print_status "$1${font_reset}"
    printf "${format_prefix}$2${font_reset}"
    read answer
}
print_prompt_boolean() { # <prompt> <preference> <var>
    choice="[y/N] "
    [[ $2 == "Y" || $2 == "y" ]] && choice="[Y/n] "
    while : ; do
        print_prompt "$1" "$choice"
        [[ $answer == "" ]] && answer=$2
        case $answer in
            [yY])
                eval "$3=true"
                return
                ;;
            [nN])
                eval "$3=false"
                return
                ;;
            *)
                print_neg "Please write either ${format_code}y/Y${format_no_code} or ${format_code}n/N${format_no_code}!";;
        esac
    done
}
print_cmd() { # <cmd> <var>
    print_status "Executing ${format_code}$1${format_no_code}"
    print_status_start
    if eval "$1"; then
        print_status_end
        eval "$2=true"
    else
        print_status_end
        eval "$2=false"
    fi
}
print_cmd_invisible() { # <cmd> <var>
    print_status "Executing ${format_code}$1${format_no_code}"
    if eval "$1 &> /dev/null"; then
        eval "$2=true"
    else
        eval "$2=false"
    fi
}
print_check_file() { # <path> <var>
    if [ -d "$1" ]; then
        eval "$2=true"
    else
        eval "$2=false"
    fi
}
sub_shell() {
    print_status "    -> Hit ${format_code}Enter${format_no_code} to exit the shell and return to the setup"
    while : ; do
        printf "$format_prefix$fg_primary\$$format_normal "
        read -e answer
        [[ $answer == "" ]] && break
        history -s "$answer"
        print_status_start
        eval "$answer"
        print_status_end
    done
    history -w arch_hist
}
[ -d arch_hist ] && history -r arch_hist
set -o vi
CMD=""
display_next_entry() {
    return
}