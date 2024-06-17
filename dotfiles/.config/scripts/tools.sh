#!/bin/bash

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
    exit 1
fi


alias l="ls -A  | fzf-tmux --preview 'bat --style=numbers --color=always {}' | tr -d '\n'"
alias lc="ls -A | fzf-tmux --preview 'bat --style=numbers --color=always {}' | tr -d '\n' | tee >(pbcopy) | (xargs -0 printf \"Filename: %s was copied in clipboard\")"


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
