#!/bin/bash
# Claude Code statusLine script
# Reads the statusLine JSON payload on stdin and renders (all truecolor 24-bit):
#   repo | (branch) | #PR | [gradient ctx bar] ctx% | Cache R/W/H/Sz | Think | Effort | S:5h% W:7d% | +add -del | model

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Cache fields (from the most recent API call's usage block).
cache_read_tokens=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
cache_write_tokens=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cur_input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')

# Extended thinking flag.
thinking_enabled=$(echo "$input" | jq -r '.thinking.enabled // false')

# Reasoning effort level (only present when the current model supports it).
effort_level=$(echo "$input" | jq -r '.effort.level // empty')

# PR fields (documented schema: pr.number, pr.url, pr.review_state — the
# latter one of approved|pending|changes_requested|draft; absent when the
# current branch has no open PR).
pr_number=$(echo "$input" | jq -r '.pr.number // empty')
pr_review_state=$(echo "$input" | jq -r '.pr.review_state // empty')

# Rate-limit fields (only populated for Claude.ai subscribers after the
# first API response — read defensively and degrade if absent).
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Velocity fields (not part of the documented statusLine schema this script
# was authored against — read defensively and degrade if absent).
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')

# --- truecolor (24-bit) helpers ---
rgb()  { printf '\033[38;2;%sm' "$1"; }          # foreground truecolor, arg "R;G;B"
rgbb() { printf '\033[1;38;2;%sm' "$1"; }        # bold foreground truecolor
RESET=$'\033[0m'
DIMGRAY=$'\033[2;38;2;120;120;120m'
GRAY_EMPTY=$'\033[2;38;2;90;90;90m'
YELLOW="$(rgbb '230;200;40')"
CYAN="$(rgbb '60;210;230')"
MAGENTA="$(rgb '210;110;230')"
GREEN="$(rgb '90;220;90')"
RED="$(rgb '235;80;80')"
PURPLE="$(rgbb '180;140;255')"
ORANGE="$(rgb '255;165;60')"
TEAL="$(rgbb '80;220;200')"
SEP="${DIMGRAY} | ${RESET}"

# fmt_tokens N -> human-readable token count (e.g. 1234 -> 1.2k, 1234567 -> 1.2M)
fmt_tokens() {
  local n="$1"
  case "$n" in
    ''|*[!0-9]*) echo "0"; return ;;
  esac
  if [ "$n" -ge 1000000 ]; then
    awk -v n="$n" 'BEGIN{printf "%.1fM", n/1000000}'
  elif [ "$n" -ge 1000 ]; then
    awk -v n="$n" 'BEGIN{printf "%.1fk", n/1000}'
  else
    printf '%s' "$n"
  fi
}

# fmt_until EPOCH -> compact time until that unix timestamp (e.g. 42m, 2h15m,
# 3d4h); empty if the timestamp is invalid or already past.
fmt_until() {
  local now diff d h m
  case "$1" in
    ''|*[!0-9]*) return ;;
  esac
  now=$(date +%s)
  diff=$(( $1 - now ))
  [ "$diff" -le 0 ] && return
  d=$(( diff / 86400 ))
  h=$(( (diff % 86400) / 3600 ))
  m=$(( (diff % 3600) / 60 ))
  if [ "$d" -gt 0 ]; then
    printf '%dd%dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then
    printf '%dh%dm' "$h" "$m"
  else
    printf '%dm' "$m"
  fi
}

# usage_color PCT -> bold truecolor escape, keyed to the same thresholds as
# the context bar (green <20%, blue <50%, yellow <80%, red >=80%).
usage_color() {
  local p pi
  p="$1"
  pi=$(printf '%.0f' "$p" 2>/dev/null)
  if [ -z "$pi" ]; then
    printf '%s' "$DIMGRAY"
    return
  fi
  if [ "$pi" -lt 20 ]; then
    rgbb '150;220;150'
  elif [ "$pi" -lt 50 ]; then
    rgbb '100;170;255'
  elif [ "$pi" -lt 80 ]; then
    rgbb '240;205;40'
  else
    rgbb '255;70;70'
  fi
}

BAR_WIDTH=10

# --- repo name (git root basename, else cwd basename) ---
repo_name=""
in_git_repo=0
branch=""
if [ -n "$cwd" ] && git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  in_git_repo=1
  repo_root=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
  [ -n "$repo_root" ] && repo_name=$(basename "$repo_root")
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
fi
if [ -z "$repo_name" ] && [ -n "$cwd" ]; then
  repo_name=$(basename "$cwd")
fi

# --- PR segment (#NNN, colored by review_state when available) ---
pr_seg=""
if [ -n "$pr_number" ]; then
  case "$pr_review_state" in
    approved)
      pr_color="$(rgbb '150;220;150')"   # matches pastel green
      ;;
    changes_requested)
      pr_color="$(rgbb '255;70;70')"
      ;;
    pending)
      pr_color="$(rgbb '240;205;40')"
      ;;
    draft)
      pr_color="$DIMGRAY"
      ;;
    *)
      pr_color="$PURPLE"                 # no/unknown review_state
      ;;
  esac
  pr_seg="${pr_color}#${pr_number}${RESET}"
fi

# --- context usage level -> gradient endpoints + solid percentage color ---
# dark/light are "R;G;B" gradient endpoints for the filled bar blocks.
level_dark="70;130;70"; level_light="150;220;150"; pct_color="150;220;150"    # pastel green (<20%)
used_int=""
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct" 2>/dev/null)
fi
if [ -n "$used_int" ]; then
  [ "$used_int" -lt 0 ] && used_int=0
  [ "$used_int" -gt 100 ] && used_int=100
  if [ "$used_int" -lt 20 ]; then
    level_dark="70;130;70"; level_light="150;220;150"; pct_color="150;220;150"
  elif [ "$used_int" -lt 50 ]; then
    level_dark="0;60;130"; level_light="120;190;255"; pct_color="100;170;255"
  elif [ "$used_int" -lt 80 ]; then
    level_dark="120;95;0"; level_light="255;225;110"; pct_color="240;205;40"
  else
    level_dark="120;0;0"; level_light="255;120;120"; pct_color="255;70;70"
  fi
fi

IFS=';' read -r dr dg db <<< "$level_dark"
IFS=';' read -r lr lg lb <<< "$level_light"

# --- build the gradient (dark -> light) context bar ---
bar=""
if [ -n "$used_int" ]; then
  filled=$(( used_int * BAR_WIDTH / 100 ))
else
  filled=0
fi
for ((i = 0; i < BAR_WIDTH; i++)); do
  if [ "$i" -lt "$filled" ]; then
    # interpolate color across the full bar width (position-based gradient)
    r=$(( (dr * (BAR_WIDTH - 1 - i) + lr * i) / (BAR_WIDTH - 1) ))
    g=$(( (dg * (BAR_WIDTH - 1 - i) + lg * i) / (BAR_WIDTH - 1) ))
    b=$(( (db * (BAR_WIDTH - 1 - i) + lb * i) / (BAR_WIDTH - 1) ))
    bar="${bar}$(rgb "${r};${g};${b}")█"
  else
    bar="${bar}${GRAY_EMPTY}░"
  fi
done
bar="${bar}${RESET}"

if [ -n "$used_int" ]; then
  ctx_pct_seg="$(rgbb "$pct_color")${used_int}%${RESET}"
else
  ctx_pct_seg="${GRAY_EMPTY}n/a${RESET}"
fi

# --- rate-limit usage (session / 5h and weekly / 7d) ---
five_part=""
if [ -n "$five_pct" ]; then
  five_int=$(printf '%.0f' "$five_pct" 2>/dev/null)
  if [ -n "$five_int" ]; then
    five_part="$(usage_color "$five_pct")S:${five_int}%${RESET}"
    five_left=$(fmt_until "$five_reset")
    [ -n "$five_left" ] && five_part="${five_part}${DIMGRAY}(${five_left})${RESET}"
  fi
fi
week_part=""
if [ -n "$week_pct" ]; then
  week_int=$(printf '%.0f' "$week_pct" 2>/dev/null)
  if [ -n "$week_int" ]; then
    week_part="$(usage_color "$week_pct")W:${week_int}%${RESET}"
    week_left=$(fmt_until "$week_reset")
    [ -n "$week_left" ] && week_part="${week_part}${DIMGRAY}(${week_left})${RESET}"
  fi
fi
rate_seg=""
if [ -n "$five_part" ] && [ -n "$week_part" ]; then
  rate_seg="${five_part} ${week_part}"
elif [ -n "$five_part" ]; then
  rate_seg="$five_part"
elif [ -n "$week_part" ]; then
  rate_seg="$week_part"
fi

# --- cache usage (read/write/hit-rate/total cached size) ---
cache_seg=""
total_cache=$((cache_read_tokens + cache_write_tokens))
total_tokens=$((total_cache + cur_input_tokens))
if [ "$total_tokens" -gt 0 ]; then
  hit_pct=$(awk -v r="$cache_read_tokens" -v t="$total_tokens" 'BEGIN{printf "%.0f", (r/t)*100}')
  cache_seg="${ORANGE}Cache${RESET} ${DIMGRAY}R:${RESET}$(fmt_tokens "$cache_read_tokens") ${DIMGRAY}W:${RESET}$(fmt_tokens "$cache_write_tokens") ${DIMGRAY}H:${RESET}${hit_pct}% ${DIMGRAY}Sz:${RESET}$(fmt_tokens "$total_cache")"
fi

# --- extended thinking indicator ---
thinking_seg=""
if [ "$thinking_enabled" = "true" ]; then
  thinking_seg="${TEAL}Think${RESET}"
fi

# --- reasoning effort level (low/medium/high/xhigh/max) ---
effort_seg=""
if [ -n "$effort_level" ]; then
  case "$effort_level" in
    low)
      effort_color="$(rgbb '150;220;150')"
      ;;
    medium)
      effort_color="$(rgbb '100;170;255')"
      ;;
    high)
      effort_color="$(rgbb '240;205;40')"
      ;;
    xhigh|max)
      effort_color="$(rgbb '255;70;70')"
      ;;
    *)
      effort_color="$DIMGRAY"
      ;;
  esac
  effort_seg="${effort_color}${effort_level}${RESET}"
fi

# --- code velocity (+added / -removed) ---
velocity_seg=""
if [ -n "$lines_added" ] || [ -n "$lines_removed" ]; then
  [ -z "$lines_added" ] && lines_added=0
  [ -z "$lines_removed" ] && lines_removed=0
  velocity_seg="${GREEN}+${lines_added}${RESET} ${RED}-${lines_removed}${RESET}"
fi

# --- assemble segments ---
segments=()
[ -n "$repo_name" ] && segments+=("${YELLOW}${repo_name}${RESET}")
if [ "$in_git_repo" -eq 1 ] && [ -n "$branch" ]; then
  segments+=("${CYAN}(${branch})${RESET}")
fi
[ -n "$pr_seg" ] && segments+=("$pr_seg")
segments+=("${bar} ${ctx_pct_seg}")
[ -n "$cache_seg" ] && segments+=("$cache_seg")
[ -n "$rate_seg" ] && segments+=("$rate_seg")
[ -n "$velocity_seg" ] && segments+=("$velocity_seg")
[ -n "$model" ] && segments+=("${MAGENTA}${model}${RESET}")
[ -n "$effort_seg" ] && segments+=("$effort_seg")
[ -n "$thinking_seg" ] && segments+=("$thinking_seg")

output=""
for i in "${!segments[@]}"; do
  if [ "$i" -eq 0 ]; then
    output="${segments[$i]}"
  else
    output="${output}${SEP}${segments[$i]}"
  fi
done

printf "%b\n" "$output"
