#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <IP> [-u username -p password]"
    exit 1
fi

TARGET="$1"
shift

USERNAME=""
PASSWORD=""
AUTH_OPTS="-N"

# Parse optional -u and -p flags
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -u)
            USERNAME="$2"
            shift 2
            ;;
        -p)
            PASSWORD="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# If credentials were provided, set AUTH_OPTS accordingly
if [[ -n "$USERNAME" && -n "$PASSWORD" ]]; then
    AUTH_OPTS="-U${USERNAME}%${PASSWORD}"
fi

TMPFILE="touch-test.txt"
echo "Write test file" > "$TMPFILE"

# Step 1: List shares and show table
echo "[*] Getting available shares on //$TARGET ..."
echo -e "\nAvailable Shares:"
echo "-------------------------"
smbclient $AUTH_OPTS -L "//$TARGET" 2>/dev/null | awk '/^\s*[A-Za-z0-9_\-.$]+[[:space:]]+Disk/ {printf "- %s\n", $1}' | grep -v -E '^\$|^IPC$'
echo "-------------------------"

# Step 2: Enumerate shares
SHARE_LIST=$(smbclient $AUTH_OPTS -L "//$TARGET" 2>/dev/null | awk '/^\s*[A-Za-z0-9_\-.$]+[[:space:]]+Disk/ {print $1}' | grep -v -E '^\$|^IPC$')

for SHARE in $SHARE_LIST; do
    READABLE=false
    WRITABLE=false

    # Check read
    smbclient $AUTH_OPTS "//$TARGET/$SHARE" -c "ls" > /tmp/smb_ls_$SHARE 2>/dev/null
    if [ $? -eq 0 ]; then
        READABLE=true
    fi

    # Check write
    smbclient $AUTH_OPTS "//$TARGET/$SHARE" -c "put $TMPFILE" > /tmp/smb_write_$SHARE 2>&1
    if grep -q "putting file" /tmp/smb_write_$SHARE; then
        WRITABLE=true
        smbclient $AUTH_OPTS "//$TARGET/$SHARE" -c "del $TMPFILE" > /dev/null 2>&1
    fi

    # Output only if readable or writable
    if $READABLE || $WRITABLE; then
        echo -e "\n[*] Share: $SHARE"
        if $READABLE; then
            echo "[+] Readable. Contents:"
            cat /tmp/smb_ls_$SHARE
        fi
        if $WRITABLE; then
            echo "[+] Writable."
        fi
    fi

    rm -f /tmp/smb_ls_$SHARE /tmp/smb_write_$SHARE
done

rm -f "$TMPFILE"
