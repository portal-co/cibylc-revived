cd $(dirname $0)
set -eux
find . \( -iname '*.h' -o -iname '*.cc' -o -iname '*.hh' -o -iname '*.c' \) -not -path '*/external/*' | clang-format-17 --style=file -i --files=/dev/stdin