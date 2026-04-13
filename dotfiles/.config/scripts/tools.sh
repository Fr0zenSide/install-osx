#!/bin/bash

# Remove oh-my-zsh aliases that conflict with our function names
# (oh-my-zsh lib/directories.zsh defines alias l='ls -lah' etc.)
unalias l la lc ll ls lsa 2>/dev/null

# Helper to auto activate/disable mitm proxy for localhost
function mitm_on() {
    networksetup -setsecurewebproxystate wi-fi on
    networksetup -setwebproxystate wi-fi on
    
    networksetup -setwebproxy wi-fi localhost 8080
    networksetup -setsecurewebproxy wi-fi localhost 8080
}

function mitm_off() {
    networksetup -setsecurewebproxystate wi-fi off
    networksetup -setwebproxystate wi-fi off
}

ff () {
    TF_PYTHONIOENCODING=$PYTHONIOENCODING;
    export TF_SHELL=zsh;
    export TF_ALIAS=ff;
    TF_SHELL_ALIASES=$(alias);
    export TF_SHELL_ALIASES;
    TF_HISTORY="$(fc -ln -10)";
    export TF_HISTORY;
    export PYTHONIOENCODING=utf-8;
    TF_CMD=$(
        thefuck THEFUCK_ARGUMENT_PLACEHOLDER $@
    ) && eval $TF_CMD;
    unset TF_HISTORY;
    export PYTHONIOENCODING=$TF_PYTHONIOENCODING;
    test -n "$TF_CMD" && print -s $TF_CMD
}

if ! command -v fzf &> /dev/null
then
    echo "fzf could not be found"
    return 1
fi

# ─── FZF defaults ─────────────────────────────────────────────────
# fd respects .gitignore, is fast, and skips junk automatically
export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
export FZF_DEFAULT_OPTS="
  --layout=reverse
  --border
  --color=fg:#f8f8f2,bg:-1,hl:#bd93f9
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
  --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
  --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
  --bind='ctrl-d:half-page-down,ctrl-u:half-page-up'
  --bind='ctrl-y:execute-silent(echo -n {+} | pbcopy)+abort'
"

# Ctrl+T: file finder (like Xcode Cmd+O)
export FZF_CTRL_T_COMMAND="fd --type f --hidden --exclude .git"
export FZF_CTRL_T_OPTS="
  --preview 'bat --style=numbers,changes --color=always --line-range :300 {}'
  --preview-window 'right:60%:border-left'
  --header '⌃O open · ⌃Y copy path · ⌃D/⌃U scroll preview'
  --bind='ctrl-o:execute(emacs {})+abort'
"

# Ctrl+R: history search with preview of full command
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window 'down:3:wrap'
"

# Alt+C: cd into directory
export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"
export FZF_ALT_C_OPTS="
  --preview 'ls -la --color=always {}'
"

# ─── IDE-like commands ────────────────────────────────────────────

# o: Open file — the Cmd+O of your terminal
#    Fuzzy search all project files, preview with syntax highlighting, open in emacs
o () {
    local file
    file=$(fd --type f --hidden --exclude .git | fzf-tmux \
        -p 90%,80% \
        --layout reverse \
        --preview 'bat --style=numbers,changes --color=always --line-range :300 {}' \
        --preview-window 'right:60%:border-left' \
        --header '⏎ open · ⌃Y copy path' \
        --bind='ctrl-y:execute-silent(echo -n {} | pbcopy)+abort')
    [[ -n "$file" ]] && emacs "$file"
}

# rg: Grep + open — search content then jump to the line
#    Like Xcode's Cmd+Shift+F (Find in project)
s () {
    local selection file line
    selection=$(rg --color=always --line-number --no-heading --smart-case "${*:-}" |
        fzf-tmux -p 90%,80% \
            --ansi \
            --layout reverse \
            --delimiter : \
            --preview 'bat --style=numbers,changes --color=always --highlight-line {2} --line-range {2}: {1}' \
            --preview-window 'right:60%:border-left:+{2}-10' \
            --header '⏎ open at line')
    if [[ -n "$selection" ]]; then
        file=$(echo "$selection" | cut -d: -f1)
        line=$(echo "$selection" | cut -d: -f2)
        emacs +${line} "$file"
    fi
}

# l: browse files in current dir with preview
l () {
    local file
    file=$(fd --type f --max-depth 1 | fzf-tmux \
        -p 80%,60% \
        --layout reverse \
        --preview 'bat --style=numbers,changes --color=always {}')
    [[ -n "$file" ]] && echo -n "$file"
}

# lc: browse + copy filename to clipboard
lc () {
    local file
    file=$(fd --type f --max-depth 1 | fzf-tmux \
        -p 80%,60% \
        --layout reverse \
        --preview 'bat --style=numbers,changes --color=always {}')
    [[ -n "$file" ]] && echo -n "$file" | pbcopy && echo "Copied: $file"
}

# li: browse images with kitty preview
li () {
    fd --type f -e png -e jpg -e jpeg -e gif -e svg -e webp | fzf \
        --preview 'kitten icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 {} > /dev/tty'
}

# ee: quick emacs open (no popup, inline fzf)
alias ee='emacs $(fzf --preview "bat --style=numbers,changes --color=always {}")'

# ema: emacs open via popup
alias ema='o'


if ! command -v tmux &> /dev/null
then
    echo "tmux could not be found"
    exit 1
fi


# Script to open tmux popup (called with M-f)
toggle-tmux-popup () {
    tmux_popup_session_name="_popup"

    if [ "$(tmux display-message -p -F "#{session_name}")" = "${tmux_popup_session_name}" ];then
	tmux detach-client
    else
	tmux popup -d '#{pane_current_path}' -xC -yC -w80% -h80% -E\
	     "tmux new-session -A -s ${tmux_popup_session_name}"
    fi
}


# Launch tmux to attach a session or window already exist
ts () { tmux attach -t "$(tmux list-sessions | fzf -m --header "Choose a session:" | awk -F: '{print $1}')" }
tw () { tmux a -t "$(tmux list-windows -a | fzf -m --header "Choose a session:" | awk '{print substr($1, 1, length($1)-1)}')" }
t () {
    folder=$(pwd | sed 's/.*\///g')
    # Search in tmux list session to display in fzf a menu to select a session to reopen it + add the current folder name to create a new session direclty
    labelFolder="New session >> $folder"
    search=$(tmux list-sessions \
	| awk -F: -v f=$folder -v lf=$labelFolder '$1==f {found=1} END {if(!found) print lf} {print $0}' \
	| fzf -m --header "Choose a session:" \
	| awk -F: -v f=$folder -v lf=$labelFolder '{ if($0==lf) {print f"-"} else {print $1} }')
    
    if [[ -n $search ]]
    then

	if [[ $search == "$folder-" ]]
	then
	    #echo "cmd: tmux new -s $folder"
	    tmux new -s "$folder"
	else
	    #echo "cmd: tmux a -t $search"
	    tmux a -t "$search"
	fi
	
    else
	echo "Not a tmux time"
    fi
}
