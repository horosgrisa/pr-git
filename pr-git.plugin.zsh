#!/usr/bin/env zsh

GIT_PREFIX=${GIT_PREFIX:-' '}
GIT_SUFIX=${GIT_SUFIX:-''}

GIT_SYMBOL=${GIT_SYMBOL:-''}



_git-info() {
  INDEX=$(command git status --porcelain -b 2> /dev/null)

  git_changes=$(echo "$INDEX" | wc -l 2>/dev/null)
  if [[ $CLICOLOR = 1 ]]; then
    if [[ "$git_changes" > "1" ]]; then
      git_status="%{$fg_bold[red]%}$GIT_SYMBOL%{$reset_color%}"
    else
      git_status="%{$fg_bold[green]%}$GIT_SYMBOL%{$reset_color%}"
    fi
  else
    if [[ "$git_changes" > "1" ]]; then
      git_status="-$GIT_SYMBOL"
    else
      git_status="+$GIT_SYMBOL"
    fi
  fi

  git_branch_name=$(echo "$INDEX" | head -1 2>/dev/null)
  if [[ $CLICOLOR = 1 ]]; then
    git_branch=" %{$fg_bold[yellow]%}${git_branch_name#*/}%{$reset_color%}"
  else
    git_branch=" ${git_branch_name#*/}"
  fi

  git_untracked_number=$(echo "$INDEX" | command grep -E '^[ MARC]M ' | wc -l)
  if [[ "$git_untracked_number" == 0 ]]; then
      git_untracked=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_untracked=" %{$fg_bold[magenta]%}?${git_untracked_number}%{$reset_color%}"
    else
      git_untracked=" ?${git_untracked_number}"
    fi
  fi

  git_added_number=$(echo "$INDEX" | command grep -E '^\?\? ' | wc -l)
  if [[ "$git_added_number" == 0 ]]; then
      git_added=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_added=" %{$fg_bold[red]%}+${git_added_number}%{$reset_color%}"
    else
      git_added=" +${git_added_number}"
    fi
  fi

  echo "$git_status$git_branch$git_untracked$git_added"
  
}

_git_prompt() {
  if [ "$(command git config --get --bool oh-my-zsh.hide-status 2>/dev/null)" != "true" ] \
  && _ZPM-recursive-exist .git > /dev/null 2>&1; then
    pr_git="$GIT_PREFIX$(_git-info)$GIT_SUFIX"
  else
    pr_git=""
  fi
}

precmd_functions+=(_git_prompt)
