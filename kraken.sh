#!/usr/bin/env bash

# Author: Haitham Aouati
# GitHub: github.com/haithamaouati
# Kraken - Social network username hunter

# System Enforcement: Exit on error, unset variables, or pipe failures
set -euo pipefail

# Colors
nc="\e[0m"
bold="\e[1m"
underline="\e[4m"
bold_green="\e[1;32m"
bold_red="\e[1;31m"
bold_yellow="\e[1;33m"
bold_pink="\e[1;35m"
orange='\033[38;5;214m'

# Dependency Verification
readonly REQUIRED_DEPS=("curl" "clear")
for cmd in "${REQUIRED_DEPS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${bold_red}[ERROR]${nc} Missing critical dependency: $cmd\n" >&2
        exit 1
    fi
done

# Data
readonly SITE_NAMES=(Facebook Twitter Instagram LinkedIn GitHub Pinterest Tumblr Youtube SoundCloud Snapchat TikTok Behance Medium Quora Flickr Periscope Twitch Dribbble StumbleUpon Ello "Product Hunt" Telegram "We Heart It")
readonly SITE_URLS=(
    "https://www.facebook.com/%s"
    "https://www.twitter.com/%s"
    "https://www.instagram.com/%s"
    "https://www.linkedin.com/in/%s"
    "https://www.github.com/%s"
    "https://www.pinterest.com/%s"
    "https://www.tumblr.com/%s"
    "https://www.youtube.com/%s"
    "https://soundcloud.com/%s"
    "https://www.snapchat.com/add/%s"
    "https://www.tiktok.com/@%s"
    "https://www.behance.net/%s"
    "https://www.medium.com/@%s"
    "https://www.quora.com/profile/%s"
    "https://www.flickr.com/people/%s"
    "https://www.periscope.tv/%s"
    "https://www.twitch.tv/%s"
    "https://www.dribbble.com/%s"
    "https://www.stumbleupon.com/stumbler/%s"
    "https://www.ello.co/%s"
    "https://www.producthunt.com/@%s"
    "https://www.telegram.me/%s"
    "https://www.weheartit.com/%s"
)

# Core Functions
reset_environment() {
    clear
    echo -e "${bold_pink}"
    cat << 'EOF'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⣶⣤⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⣠⡤⣤⣄⣾⣿⣿⣿⣿⣿⣿⣷⣠⣀⣄⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠙⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣬⡿⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣼⠟⢿⣿⣿⣿⣿⣿⣿⡿⠘⣷⣄⠀⠀⠀⠀⠀
⣰⠛⠛⣿⢠⣿⠋⠀⠀⢹⠻⣿⣿⡿⢻⠁⠀⠈⢿⣦⠀⠀⠀⠀
⢈⣵⡾⠋⣿⣯⠀⠀⢀⣼⣷⣿⣿⣶⣷⡀⠀⠀⢸⣿⣀⣀⠀⠀
⢾⣿⣀⠀⠘⠻⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⠿⣿⡁⠀⠀⠀
⠈⠙⠛⠿⠿⠿⢿⣿⡿⣿⣿⡿⢿⣿⣿⣿⣷⣄⠀⠘⢷⣆⠀⠀
⠀⠀⠀⠀⠀⢠⣿⠏⠀⣿⡏⠀⣼⣿⠛⢿⣿⣿⣆⠀⠀⣿⡇⡀
⠀⠀⠀⠀⢀⣾⡟⠀⠀⣿⣇⠀⢿⣿⡀⠈⣿⡌⠻⠷⠾⠿⣻⠁
⠀⠀⣠⣶⠟⠫⣤⠀⠀⢸⣿⠀⣸⣿⢇⡤⢼⣧⠀⠀⠀⢀⣿⠀
⠀⣾⡏⠀⡀⣠⡟⠀⠀⢀⣿⣾⠟⠁⣿⡄⠀⠻⣷⣤⣤⡾⠋⠀
⠀⠙⠷⠾⠁⠻⣧⣀⣤⣾⣿⠋⠀⠀⢸⣧⠀⠀⠀⠉⠁⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⠉⠉⠹⣿⣄⠀⠀⣸⡿⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠿⠟⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀
EOF
    echo -e "\n Kraken${nc} social network username hunter\n"
    echo -e " Author: Haitham Aouati"
    echo -e " GitHub: ${underline}github.com/haithamaouati${nc}\n"
}

die() {
    echo -e "${bold_red}[ERROR]${nc} $1\n" >&2
    exit 1
}

usage() {
    echo -e "Usage: $0 ${bold_pink}[options]${nc}\n"
    echo -e "Options:"
    echo -e "  -u, --username ${bold_pink}<username>${nc}   Hunt a username on social networks"
    echo -e "  -h, --help                  Show this help message\n"
}

# Helper: percent-encode a string (no external tools needed)
urlencode() {
    local LC_ALL=C
    local s="$1" out="" c hex i
    for (( i = 0; i < ${#s}; i++ )); do
        c=${s:i:1}
        case "$c" in
            [a-zA-Z0-9.~_-]) out+="$c" ;;
            *) printf -v hex '%%%02X' "'$c"; out+="$hex" ;;
        esac
    done
    echo "$out"
}

hunt_username() {
    local username="$1" enc i url code

    echo -e "Hunting username ${bold_pink}@${username}${nc}\n"

    enc=$(urlencode "$username")

    for i in "${!SITE_NAMES[@]}"; do
        # shellcheck disable=SC2059
        printf -v url "${SITE_URLS[$i]}" "$enc"
        code=$(curl -s -o /dev/null -L --max-time 10 -A 'Mozilla/5.0' -w '%{http_code}' "$url" || true)
        if [[ "$code" == "200" ]]; then
            echo -e "${bold_green}[+]${nc} ${SITE_NAMES[$i]}: ${bold_green}${url}${nc}"
        else
            echo -e "${bold_red}[-]${nc} ${SITE_NAMES[$i]}: ${bold_yellow}Username not found!${nc}"
        fi
    done
    echo
}

# Argument parsing
parse_arguments() {
    if [[ $# -eq 0 ]]; then
        reset_environment
        usage >&2
        exit 1
    fi

    reset_environment

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -u|--username)
                if [[ $# -lt 2 || "$2" == -* ]]; then
                    die "Option $1 requires an argument."
                fi
                hunt_username "$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                die "Invalid input argument format: $1 (use -h for help)"
                ;;
        esac
    done
}

# Entry Execution Trace
parse_arguments "$@"
