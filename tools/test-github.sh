#!/bin/bash

set -ex

[[ -d ${0%/*} ]] && cd "${0%/*}"/../

RUN_ID="$1"
TESTS=$2

# if is cargo installed, let's build and test dracut-cpio
if command -v cargo > /dev/null; then
    ./configure --enable-dracut-cpio
else
    ./configure
fi

NCPU=$(getconf _NPROCESSORS_ONLN)

if ! [[ $TESTS ]]; then
    make -j "$NCPU" all syncheck logtee
else
    make -j "$NCPU" enable_documentation=no all logtee

    cd test

    # shellcheck disable=SC2012
    time LOGTEE_TIMEOUT_MS=590000 make \
        enable_documentation=no \
        KVERSION="$(
            cd /lib/modules
            ls -1 | tail -1
        )" \
        TEST_RUN_ID="$RUN_ID" \
        ${TESTS:+TESTS="$TESTS"} \
        -k V=1 \
        check
fi
