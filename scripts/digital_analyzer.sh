#!/bin/sh

driver="fx2lafw"
channels=""
rate=""
edge=""
samples=""
trigger_ch=""
output="capture$(date +%Y%m%d_%H%M%S).sr"

usage() {
    cat <<EOF
Usage: $0 [-c channels] [-r rate_mhz] [-e rising|falling] [-s samples] [-t trigger_ch] [-o output_file]
  -c  Comma-separated list or range of channels (e.g., D0,D1 or 0-3)
  -r  Sample rate in MHz (e.g., 1, 10, 24)
  -e  Trigger edge: rising or falling
  -s  Number of samples to capture
  -t  Trigger channel (e.g., D0 or 0)
  -o  Output filename (default: captureYYYYMMDD_HHMMSS.sr)
  -h  Show this help message
EOF
    exit "${1:-0}"
}

while getopts "c:r:e:s:t:o:h" opt; do
    case "$opt" in
        c) channels="$OPTARG" ;;
        r) rate="$OPTARG" ;;
        e) edge="$OPTARG" ;;
        s) samples="$OPTARG" ;;
        t) trigger_ch="$OPTARG" ;;
        o) output="$OPTARG" ;;
        h) usage 0 ;;
        \?) usage 1 ;;
    esac
done
shift $((OPTIND - 1))

# Validate edge and map to sigrok-cli syntax (r or f)
trig_edge=""
if [ -n "$edge" ]; then
    case "$edge" in
        rising)  trig_edge="r" ;;
        falling) trig_edge="f" ;;
        *)
            printf "Error: -e must be 'rising' or 'falling'\n" >&2
            exit 1
            ;;
    esac
fi

# Ensure trigger channel and edge are paired properly
if [ -n "$trigger_ch" ] && [ -z "$trig_edge" ]; then
    printf "Error: -t requires -e (rising or falling)\n" >&2
    exit 1
fi
if [ -n "$trig_edge" ] && [ -z "$trigger_ch" ]; then
    printf "Error: -e requires -t (trigger channel)\n" >&2
    exit 1
fi

# Build arguments safely using the positional parameters ($@)
set -- --driver "$driver" --output-file "$output"

[ -n "$channels" ] && set -- "$@" --channels "$channels"
[ -n "$rate" ]     && set -- "$@" --config "samplerate=${rate}m"
[ -n "$samples" ]  && set -- "$@" --samples "$samples"

if [ -n "$trigger_ch" ]; then
    set -- "$@" --triggers "${trigger_ch}=${trig_edge}" --wait-trigger
fi

echo "sigrok-cli $@"
