set_prompt() {
    local EXIT="$?"

    # Colors
    local RESET="\[\e[0m\]"
    local WHITE="\[\e[97;1m\]"
    local RED="\[\e[91;1m\]"
    local GREEN="\[\e[92;1m\]"
    local YELLOW="\[\e[93;1m\]"
    local BLUE="\[\e[94;1m\]"
    local PURPLE="\[\e[95;1m\]"

    # Custom environments
    local CUSTOM_ENV=""
    if [ -n "$CONDA_DEFAULT_ENV" ]; then
        CUSTOM_ENV="${YELLOW}(${CONDA_DEFAULT_ENV}) ${RESET}"
    elif [ -n "$VIRTUAL_ENV" ]; then
        CUSTOM_ENV="${YELLOW}($(basename "$VIRTUAL_ENV")) ${RESET}"
    fi

    # User and host info
    local PREFIX="${CUSTOM_ENV}${PURPLE}\u@\h${WHITE}:${RESET}"

    # Working directory display
    local DIR="$PWD"
    if [[ "$DIR" == "$HOME"* ]]; then
        DIR="~${DIR#$HOME}"
    fi
    local BASE="${DIR##*/}"
    local PARENT="${DIR%/*}"
    if [ "$DIR" = "$BASE" ]; then
        local PATH_DISPLAY="${BLUE}${BASE}${RESET}"
    else
        local PATH_DISPLAY="${BLUE}${PARENT}/${BASE}${RESET}"
    fi

    # Prompt symbol
    if [ "$EUID" -eq 0 ]; then
        local PROMPT_SYMBOL="#"
    else
        local PROMPT_SYMBOL="$"
    fi

    # Prompt color
    if [ "$EXIT" -eq 0 ]; then
        local PROMPT="${GREEN}${PROMPT_SYMBOL}${RESET}"
    else
        local PROMPT="${RED}${PROMPT_SYMBOL}${RESET}"
    fi

    PS1="${PREFIX}${PATH_DISPLAY}\n${PROMPT} "
}

PROMPT_COMMAND=set_prompt
