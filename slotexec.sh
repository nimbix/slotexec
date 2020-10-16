#!/bin/sh

# print usage and exit
usage()
{
    [ -n "$1" ] && echo $0: "$*" >&2
    echo "usage: $0 <-g|-l> [-n nodefile] [-s slotfile] [-a arraybase] [-t timeout ] <command...>" >&2
    echo "  one of -g or -l must be specified" >&2
    exit 1
}

# defaults
nodefile=/etc/JARVICE/nodes
slotfile=/etc/JARVICE/cores
timeout=60
arraybase=
execmode=

# parse command line
while [ -n "$1" ]; do
    case "$1" in
        -g)
            execmode=global
            ;;
        -l)
            execmode=local
            ;;
        -n)
            [ -z "$2" ] && usage missing nodefile
            nodefile="$2"
            shift
            ;;
        -s)
            [ -z "$2" ] && usage missing slotfile
            slotfile="$2"
            shift
            ;;
        -a)
            [ -n "$2" -a "$2" -eq "$2" ] && arraybase=$2 || usage
            shift
            ;;
        -t)
            [ -n "$2" -a "$2" -eq "$2" ] && timeout=$2 || usage
            shift
            ;;
        *)
            # command begins
            break
    esac
    shift
done

[ -z "$1" -o -z "$execmode" ] && usage

# calculate slots per node (dependency free)
nnodes=0
nslots=0
while read n; do
    nnodes=`expr $nnodes + 1`
done <$nodefile
while read s; do
    nslots=`expr $nslots + 1`
done <$slotfile
slotsper=`expr $nslots / $nnodes`

[ -z "$JARVICE_JOB_ARRAY_INDEX" ] && JARVICE_JOB_ARRAY_INDEX=0
[ -z "$arraybase" ] && arraybase=`expr $JARVICE_JOB_ARRAY_INDEX \* $nslots`

if [ $execmode = global ]; then

    # global mode; ssh test up to timeout first, then spawn on each node and wait for finishes
    now=`date +%s`
    timeout=`expr $now + $timeout`
    while [ 1 ]; do
        failures=0
        while read n; do
            ssh -o ConnectTimeout=1 $n /bin/true 2>/dev/null
            failures=`expr $failures + $?`
        done <$nodefile
        if [ $failures -eq 0 ]; then
            break
        else
            if [ $(date +%s) -lt $timeout ]; then
                sleep 1
            else
                echo "Timed out waiting for nodes to be ready" >&2
                exit 1
            fi
        fi
    done

    srpath=$(echo "$(cd "$(dirname "$0")"; pwd)/$(basename "$0")")
    while read n; do
        ssh $n $srpath -l -n $nodefile -s $slotfile -a $arraybase "$@" &
        arraybase=`expr $arraybase + $slotsper`
    done <$nodefile
    set -e
    wait
    exit 0
else

    # local mode; spawn command on each slot and wait for finishes
    JARVICE_JOB_ARRAY_INDEX=$arraybase; export JARVICE_JOB_ARRAY_INDEX
    i=0
    while [ $i -lt $slotsper ]; do
        "$@" &
        JARVICE_JOB_ARRAY_INDEX=`expr $JARVICE_JOB_ARRAY_INDEX + 1`
        i=`expr $i + 1`
    done
    set -e
    wait
    exit 0
fi

