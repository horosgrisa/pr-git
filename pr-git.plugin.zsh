#!/usr/bin/env zsh

GIT_STATUS_PREFIX=${GIT_STATUS_PREFIX:-' '}
GIT_STATUS_SUFIX=${GIT_STATUS_SUFIX:-''}

GIT_STATUS_SYMBOL=${GIT_STATUS_SYMBOL:-''}
GIT_STATUS_UNTRACKED="${GIT_STATUS_UNTRACKED="?"}"
GIT_STATUS_ADDED="${GIT_STATUS_ADDED="+"}"
GIT_STATUS_STAGED="${GIT_STATUS_STAGED="▸"}"
GIT_STATUS_AHEAD="${GIT_STATUS_AHEAD="⇡"}"
GIT_STATUS_BEHIND="${GIT_STATUS_BEHIND="⇣"}"


# GIT_STATUS_MODIFIED="${GIT_STATUS_MODIFIED="!"}"
# GIT_STATUS_RENAMED="${GIT_STATUS_RENAMED="»"}"
# GIT_STATUS_DELETED="${GIT_STATUS_DELETED="✘"}"
# GIT_STATUS_STASHED="${GIT_STATUS_STASHED="$"}"
# GIT_STATUS_UNMERGED="${GIT_STATUS_UNMERGED="="}"
# GIT_STATUS_DIVERGED="${GIT_STATUS_DIVERGED="⇕"}"

_git-info() {
  INDEX=$(command git status --porcelain -b 2> /dev/null)
  INDEX_STAGED=$(command git diff --staged --name-status 2> /dev/null)

  git_changes=$(echo "$INDEX" | wc -l 2>/dev/null)
  if [[ $CLICOLOR = 1 ]]; then
    if [[ "$git_changes" > "1" ]]; then
      git_status="%{$fg_bold[red]%}$GIT_STATUS_SYMBOL%{$reset_color%}"
    else
      git_status="%{$fg_bold[green]%}$GIT_STATUS_SYMBOL%{$reset_color%}"
    fi
  else
    if [[ "$git_changes" > "1" ]]; then
      git_status="-$GIT_STATUS_SYMBOL"
    else
      git_status="+$GIT_STATUS_SYMBOL"
    fi
  fi

  ref=$(command git symbolic-ref HEAD 2>/dev/null)
  if [[ $CLICOLOR = 1 ]]; then
    git_branch=" %{$fg_bold[yellow]%}${ref#refs/heads/}%{$reset_color%}"
  else
    git_branch=" ${ref#refs/heads/}"
  fi

  git_untracked_number=$(echo "$INDEX" | command grep -E '^[ MARC]M ' | wc -l)
  if [[ "$git_untracked_number" == 0 ]]; then
      git_untracked=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_untracked=" %{$fg_bold[magenta]%}${GIT_STATUS_UNTRACKED}${git_untracked_number}%{$reset_color%}"
    else
      git_untracked=" ${GIT_STATUS_UNTRACKED}${git_untracked_number}"
    fi
  fi

  git_added_number=$(echo "$INDEX" | command grep -E '^\?\? ' | wc -l)
  if [[ "$git_added_number" == 0 ]]; then
      git_added=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_added=" %{$fg_bold[red]%}${GIT_STATUS_ADDED}${git_added_number}%{$reset_color%}"
    else
      git_added=" ${GIT_STATUS_ADDED}${git_added_number}"
    fi
  fi

  git_staged_number=$(echo "$INDEX_STAGED" | command grep -E '^[ MARC]' | wc -l)
  if [[ "$git_staged_number" == 0 ]]; then
      git_staged=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_staged=" %{$fg_bold[red]%}${GIT_STATUS_STAGED}${git_staged_number}%{$reset_color%}"
    else
      git_staged=" ${GIT_STATUS_STAGED}${git_staged_number}"
    fi
  fi

  git_ahead_number=$(echo "$INDEX" | sed -n 's/.*ahead \([\0-9]\+\).*/\1/p' 2>/dev/null)
  if [[ -z "$git_ahead_number" ]]; then
      git_ahead=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_ahead=" %{$fg_bold[blue]%}${GIT_STATUS_AHEAD}${git_ahead_number}%{$reset_color%}"
    else
      git_ahead=" ${GIT_STATUS_AHEAD}${git_ahead_number}"
    fi
  fi

  git_behind_number=$(echo "$INDEX" | sed -n 's/.*behind \([\0-9]\+\).*/\1/p' 2>/dev/null)
  if [[ -z "$git_behind_number" ]]; then
      git_behind=''
  else
    if [[ $CLICOLOR = 1 ]]; then
      git_behind=" %{$fg_bold[cyan]%}${GIT_STATUS_BEHIND}${git_behind_number}%{$reset_color%}"
    else
      git_behind=" ${GIT_STATUS_BEHIND}${git_behind_number}"
    fi
  fi

  echo "$git_status$git_branch$git_untracked$git_added$git_staged_number$git_ahead$git_behind"
  
}

_git_prompt() {
  if [ "$(command git config --get --bool oh-my-zsh.hide-status 2>/dev/null)" != "true" ] \
  && _ZPM-recursive-exist .git > /dev/null 2>&1; then
    pr_git="$GIT_STATUS_PREFIX$(_git-info)$GIT_STATUS_SUFIX"
  else
    pr_git=""
  fi
}

precmd_functions+=(_git_prompt)
