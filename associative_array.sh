#
# POSIX compliant associative array with get and put functions
#

# USAGE: put <array_name> <key> <value>
put () {
    eval "$1_$2=$3"
}

# USAGE: get <array_name> <key>
get () {
    [ -z "$(eval "echo \$$1_$2")" ] && return 1
    eval "echo \$$1_$2"
}
