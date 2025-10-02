main() {
    define_colors
    remove_empty_space_at_right_end_of_prompt
    modify_left_prompt_elements
    modify_right_prompt_elements
    set_icon_mode_and_padding
    remove_prompt_frame
    set_transient_prompt
    set_segment_separators
    set_head_and_tail_symbols
    modify_prompt_character
    modify_os_icon_segment
    modify_dir_segment
    modify_git_segment
    modify_status_segment
    modify_execution_time_segment
    modify_time_segment
    modify_battery_segment
}

define_colors() {
    # Catppuccin Mocha colors
    # Powerlevel10k just supports 256 colors so these colors below are not accurate
    # Some of them may share the same code
    declare -gA P10K_COLORS=(
        "rosewater" "224"
        "flamingo" "225"
        "pink" "218"
        "mauve" "183"
        "red" "211"
        "maroon" "217"
        "peach" "223"
        "yellow" "223"
        "green" "156"
        "teal" "158"
        "sky" "159"
        "sapphire" "153"
        "blue" "153"
        "lavender" "189"
        "text" "189"
        "subtext1" "146"
        "subtext0" "145"
        "overlay2" "103"
        "overlay1" "102"
        "overlay0" "60"
        "surface2" "59"
        "surface1" "238"
        "surface0" "236"
        "base" "235"
        "mantle" "234"
        "crust" "233"
    )
}

remove_empty_space_at_right_end_of_prompt() {
    ZLE_RPROMPT_INDENT=0
}

modify_left_prompt_elements() {
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
        os_icon             # OS identifier
        dir                 # Current directory
        vcs                 # Git status
        newline             # \n
        prompt_char         # Prompt symbol
    )
}

modify_right_prompt_elements() {
    # Remove "background_jobs"
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS:#background_jobs})

    # Insert "time" before "newline"
    index_of_newline=${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[(I)newline]}
    if (( index_of_newline > 0 )); then
        POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
            ${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[1,index_of_newline-1]}
            "time"
            ${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[index_of_newline,-1]}
        )
    fi
}

set_icon_mode_and_padding() {
    POWERLEVEL9K_MODE=nerdfont-v3
    POWERLEVEL9K_ICON_PADDING=moderate
}

remove_prompt_frame() {
    POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
    POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=
    POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX=
    POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
    POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
    POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=
}

set_transient_prompt() {
    POWERLEVEL9K_TRANSIENT_PROMPT=same-dir
}

set_segment_separators() {
    POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='\uE0B5'
    POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='\uE0B7'
    POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0B4'
    POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0B6'
}

set_head_and_tail_symbols() {
    POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL='\uE0B4'
    POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='\uE0B6'
    POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
    POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
}

modify_prompt_character() {
    # Normal user
    typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=${P10K_COLORS[green]}
    typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=${P10K_COLORS[red]}
    # Root user
    POWERLEVEL9K_PROMPT_CHAR_ROOT_FOREGROUND=${P10K_COLORS[red]}
}

modify_os_icon_segment() {
    POWERLEVEL9K_OS_ICON_FOREGROUND=${P10K_COLORS[base]}
    POWERLEVEL9K_OS_ICON_BACKGROUND=${P10K_COLORS[red]}
}

modify_dir_segment() {
    POWERLEVEL9K_DIR_FOREGROUND=${P10K_COLORS[base]}
    POWERLEVEL9K_DIR_BACKGROUND=${P10K_COLORS[mauve]}
    POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=${P10K_COLORS[base]}
    POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=${P10K_COLORS[base]}
}

modify_git_segment() {
    POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '
    POWERLEVEL9K_VCS_CLEAN_FOREGROUND=${P10K_COLORS[base]}
    POWERLEVEL9K_VCS_CLEAN_BACKGROUND=${P10K_COLORS[green]}
    POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=${P10K_COLORS[base]}
    POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=${P10K_COLORS[yellow]}
    POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=${P10K_COLORS[base]}
    POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=${P10K_COLORS[red]}
}

modify_status_segment() {
    # Icons
    POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION=''
    POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION=''
    POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION=''
    POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION=''
    POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION=''
    # Colors
    POWERLEVEL9K_STATUS_OK_FOREGROUND=${P10K_COLORS[base]}
    POWERLEVEL9K_STATUS_OK_BACKGROUND=${P10K_COLORS[green]}
    POWERLEVEL9K_STATUS_ERROR_FOREGROUND=${P10K_COLORS[base]}
    POWERLEVEL9K_STATUS_ERROR_BACKGROUND=${P10K_COLORS[red]}
}

modify_execution_time_segment() {
    POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=${P10K_COLORS[base]}
    POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=${P10K_COLORS[rosewater]}
}

modify_time_segment() {
    POWERLEVEL9K_TIME_FORMAT='%D{%I:%M:%S %p}'
    POWERLEVEL9K_TIME_FOREGROUND=${P10K_COLORS[base]}
    POWERLEVEL9K_TIME_BACKGROUND=${P10K_COLORS[blue]}
}

modify_battery_segment() {
    POWERLEVEL9K_BATTERY_STAGES='\UF008E\UF007A\UF007B\UF007C\UF007D\UF007E\UF007F\UF0080\UF0081\UF0082\UF0079'
}

main
