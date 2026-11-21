#!/usr/bin/env bash
#
# Decoder regression check.
#
# Runs the jt9 decoder on a few representative recordings and compares the
# decoded output against recorded golden files.  A generated JT65 signal is
# used as well, since the shipped JT65B recordings do not decode standalone
# with default settings.
#
# Usage:
#   tests/decoder_regression.sh            # check against golden files
#   tests/decoder_regression.sh --update   # (re)record golden files
#
# Environment:
#   JT9      path to the jt9 binary      (default: ../wsjtx-build/jt9)
#   JT65SIM  path to the jt65sim binary   (default: ../wsjtx-build/jt65sim)
#
# The golden files describe output from a particular build and toolchain, so
# they may need to be regenerated with --update after a compiler or FFTW
# change that shifts numerical results.

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
build_dir=$(cd "$repo_root/.." && pwd)/wsjtx-build

jt9=${JT9:-$build_dir/jt9}
jt65sim=${JT65SIM:-$build_dir/jt65sim}
golden_dir=$script_dir/decoder_golden

update=0
if [[ ${1:-} == --update ]]; then
    update=1
fi

if [[ ! -x $jt9 ]]; then
    echo "error: jt9 not found or not executable: $jt9" >&2
    echo "       build it first, or set JT9=/path/to/jt9" >&2
    exit 2
fi

mkdir -p "$golden_dir"
tmp_root=$(mktemp -d)
trap 'rm -rf "$tmp_root"' EXIT

failures=0
total=0

# Keep only the decode output.  Trailing whitespace and line order are not
# meaningful for a regression check, and the EOF notice embeds a path.
normalize() {
    sed -e 's/[[:space:]]*$//' "$1" \
        | grep -v '^[[:space:]]*EOF on input file' \
        | sed '/^$/d' \
        | sort
}

# Keep only the decoded message text, dropping the timing, S/N and frequency
# columns.  Used for simulated signals, where the added noise shifts those
# numeric fields slightly from run to run while the message stays fixed.
normalize_messages() {
    sed -e 's/[[:space:]]*$//' "$1" \
        | sed -n 's/.*[[:space:]][~@:&#][[:space:]]*//p' \
        | sed '/^$/d' \
        | sort
}

run_case() {
    local name=$1
    local norm=$2
    shift 2
    local -a args=("$@")
    local run_dir=$tmp_root/$name
    local got=$tmp_root/$name.out
    local golden=$golden_dir/$name.txt

    mkdir -p "$run_dir"
    total=$((total+1))

    if ! ( cd "$run_dir" && "$jt9" -a "$run_dir" -t "$run_dir" "${args[@]}" \
           > "$got.raw" 2>&1 ); then
        echo "FAIL $name: jt9 exited with an error" >&2
        failures=$((failures+1))
        return
    fi
    if [[ $norm == msg ]]; then
        normalize_messages "$got.raw" > "$got"
    else
        normalize "$got.raw" > "$got"
    fi

    if (( update )); then
        cp "$got" "$golden"
        echo "recorded $name"
        return
    fi
    if [[ ! -f $golden ]]; then
        echo "MISSING $name: no golden file (run with --update)" >&2
        failures=$((failures+1))
        return
    fi
    if diff -u "$golden" "$got" > "$tmp_root/$name.diff"; then
        echo "ok $name"
    else
        echo "FAIL $name" >&2
        cat "$tmp_root/$name.diff" >&2
        failures=$((failures+1))
    fi
}

# Recordings shipped with the distribution.
run_case jt9    full -9 "$repo_root/samples/JT9/130418_1742.wav"
run_case ft8    full -8 "$repo_root/samples/FT8/210703_133430.wav"
run_case q65    full -3 -p 60 "$repo_root/samples/Q65/60A_EME_6m/210106_1621.wav"
run_case msk144 full -k "$repo_root/samples/MSK144/181211_120500.wav"
run_case ft4    full -4 "$repo_root/samples/FT4/000000_000002.wav"
run_case fst4   full -7 "$repo_root/samples/FST4+FST4W/210115_0058.wav"

# A generated JT65 signal exercises the JT65 decoder path.
if [[ -x $jt65sim ]]; then
    gen_dir=$tmp_root/jt65sim
    mkdir -p "$gen_dir"
    ( cd "$gen_dir" && "$jt65sim" >/dev/null 2>&1 )
    wav=
    for candidate in "$gen_dir"/*.wav; do
        [[ -e $candidate ]] && { wav=$candidate; break; }
    done
    if [[ -n $wav ]]; then
        run_case jt65 msg -6 -p 60 "$wav"
    else
        echo "skip jt65: jt65sim produced no .wav file" >&2
    fi
else
    echo "skip jt65: jt65sim not found ($jt65sim)" >&2
fi

echo
if (( update )); then
    echo "golden files written to $golden_dir"
    exit 0
fi
if (( failures )); then
    echo "$failures of $total case(s) failed" >&2
    exit 1
fi
echo "all $total case(s) passed"
