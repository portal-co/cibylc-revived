cd $(dirname $0)
set -eux
cmake -GNinja -Bout
ninja -C out