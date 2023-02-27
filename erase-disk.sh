#!/usr/bin/env dash
# USAGE: erase-disk.sh <passes> <device>
# Must be run as root

usage() {
    echo "Usage: erase-disk.sh PASSES DEVICE"
    echo "Securely erase DEVICE with PASSES passes"
    echo
    echo "Flags:"
    echo "  -h, --help \t\tDisplay this help message"
    echo "  -c, --crypt-prep \tPrepare DEVICE for encryption"
    echo
    echo "Options (must come after flags):"
    echo "  DEVICE \t\tThe device to erase"
    echo "  PASSES \t\tHow many times to erase DEVICE"
    echo
    echo "This script will securely erase a disk device with the specified amount"
    echo "of passes (rounds). It does so by overwriting the specified device with"
    echo "random data on the first pass, and with zeroes on the other passes."
    echo "Due to the nature of disk device access permissions, the script must"
    echo "be run as root."
    echo
    echo "erase-disk.sh is licensed under the Unlicense."
}

CRYPT=0

[ "$1" = "-h" ] || [ "$1" = "--help" ] && usage && exit 0
[ "$1" = "-c" ] || [ "$1" = "--crypt-prep" ] && CRYPT=1 && shift

if [ $# -lt 2 ]; then
    echo "=> ERROR: Not enough options!"
    echo
    usage
    exit 1
elif [ $# -gt 2 ]; then
    echo "=> ERROR: Too many options!"
    echo
    usage
    exit 1
elif [ "$(id -u)" -ne 0 ]; then
    echo "=> ERROR: Must run as root!"
    echo
    usage
    exit 1
fi

echo "=> Securely erasing the disk device $2"
i=1

while [ "$i" -le "$1" ]; do
    [ "$i" -eq 1 ] && if="/dev/urandom" || if="/dev/zero"
    [ "$CRYPT" -eq 1 ] && [ "$i" -eq "$1" ] && if="/dev/urandom"

    echo "\n  -> Begin pass $i with $if"
    dd if="$if" of="$2" status="progress"
    
    echo "\n  -> Syncing I/O"
    sync
    
    i="$(( i + 1 ))"
done

echo -n "\n=> Done! $2 securely erased"
[ $CRYPT -eq 1 ] && echo -n " and prepared for encryption"
echo "."

