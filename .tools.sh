#!/bin/bash


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