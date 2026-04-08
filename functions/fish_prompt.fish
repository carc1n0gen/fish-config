function fish_prompt
    set -l last_status $status

    if test $last_status -eq 0
        set fish_icon "><(((°>"
        set fish_color green
    else
        set fish_icon "><(((ˣ>"
        set fish_color red
    end

    set -l git_info ""
    set -l branch (git branch --show-current 2>/dev/null)
    if test -n "$branch"
        set git_status ""
        if not git diff --cached --quiet 2>/dev/null
            set git_status "$git_status $(set_color green)+"
        end
        if not git diff --quiet 2>/dev/null
            set git_status "$git_status $(set_color yellow)✗"
        end
        if test -n "$(git ls-files --others --exclude-standard 2>/dev/null | head -1)"
            set git_status "$git_status $(set_color red)?"
        end
        if test -z "$git_status"
            set git_status " $(set_color green)✔"
        end
        if git stash list 2>/dev/null | string length -q
            set git_stash " $(set_color cyan)≡"
        else
            set git_stash ""
        end

        # Background fetch with 5-minute cooldown per repo
        set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
        if test -n "$git_root"
            set -l fetch_stamp /tmp/fish_fetch_(string replace -a / _ $git_root)
            set -l now (date +%s)
            if not test -f $fetch_stamp; or test (math $now - (cat $fetch_stamp)) -gt 300
                echo $now > $fetch_stamp
                git fetch --quiet >/dev/null 2>&1 &
            end
        end

        set -l ahead (git rev-list --count @{upstream}..HEAD 2>/dev/null)
        set -l behind (git rev-list --count HEAD..@{upstream} 2>/dev/null)
        set git_sync ""
        if test -n "$ahead" && test -n "$behind"
            if test $ahead -gt 0 && test $behind -gt 0
                set git_sync " $(set_color brred)↑$ahead↓$behind"
            else if test $ahead -gt 0
                set git_sync " $(set_color brgreen)↑$ahead"
            else if test $behind -gt 0
                set git_sync " $(set_color bryellow)↓$behind"
            end
        end
        set git_info "$(set_color magenta) ⎇ $branch$git_status$git_stash$git_sync $(set_color normal)"
    end

    set -l node_info ""
    if command -q node && test -f package.json
        set node_info "$(set_color brblue)⬢$(node --version)$(set_color normal) "
    end

    set -l venv_info ""
    if test -n "$VIRTUAL_ENV"
        set -l venv_name (basename $VIRTUAL_ENV)
        set venv_info "$(set_color brblue)($venv_name)$(set_color normal) "
    end

    set -l time_str (date "+%I:%M%P %Y-%m-%d")
    set -l time_len (string length $time_str)
    set -l time_col (math $COLUMNS - $time_len + 1)


    set -l user "$(set_color cyan)$(whoami)$(set_color normal)"
    set -l host_str "$(set_color brblue)$hostname$(set_color normal)"
    set -l pwd_short "$(set_color yellow)$(prompt_pwd)$(set_color normal)"
    set -l fish_str "$(set_color $fish_color)$fish_icon$(set_color normal)"
    set -l time_colored "$(set_color brblack)$time_str$(set_color normal)"

    printf "\n"
    printf "\033[s\033[%dG%s\033[u" $time_col $time_colored
    printf "%s@%s %s%s\n%s%s%s " \
        $user \
        $host_str \
        $pwd_short \
        $git_info \
        $venv_info \
        $node_info \
        $fish_str
end
