#!/usr/bin/env bash
# Usage: [VERSION=x.y.z] ./runfs [-r] file1 file2 ...

[[ $1 == -r ]] && RUN=1 && shift

COMP="$1"
BASE="${COMP%.fs}"
shift

FSC_PATH="$(find /usr/share/dotnet/sdk -wholename "*/${VERSION:-*}/FSharp/fsc.dll" | tail -n 1)"
[[ -z $FSC_PATH ]] && exit 1

# Compile
dotnet "$FSC_PATH" \
    --targetprofile:netcore \
    --target:exe \
    --out:"$BASE.exe" \
    -r "$HOME/.local/bin/fsharp/FsLexYacc.Runtime.dll" \
    "$@" "$COMP"

# Runtime config
cat <<EOF> "$BASE.runtimeconfig.json"
{
  "runtimeOptions": {
    "tfm": "net7.0",
    "framework": {
      "name": "Microsoft.NETCore.App",
      "version": "7.0"
    },
    "rollForwardOnNoCandidateFx": 2
  }
}
EOF

# Run
[[ -n $RUN ]] && dotnet "$BASE.exe"

# Cleanup
[[ -n $RUN ]] && rm -f "$BASE.runtimeconfig.json"
