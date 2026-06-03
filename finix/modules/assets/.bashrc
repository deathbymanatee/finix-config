# We are not always an interactive shell.
if [ -n "$PS1" ]; then
  # Check the window size after every command.
  shopt -s checkwinsize

  # Disable hashing (i.e. caching) of command lookups.
  set +h

  # Provide a nice prompt if the terminal supports it.
  if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
    PROMPT_COLOR="1;31m"
    ((UID)) && PROMPT_COLOR="1;32m"
    if [ -n "$INSIDE_EMACS" ]; then
      # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
      PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
    else
      PS1="\n\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
    fi
    if test "$TERM" = "xterm"; then
      PS1="\[\033]2;\h:\u:\w\007\]$PS1"
    fi
  fi

  eval "$(dircolors -b)"

  alias -- ls='ls --color=tty'
fi

alias poweroff="sudo poweroff"
alias reboot="sudo reboot"
