#!/usr/bin/env sh

# set up the ERL_LIBS environment variable so that this project can be built from the top level
# as a cohesive whole - this script will push the current directory in front of your existing ERL_LIBS

case "$NODEWATCH_SETENV" in
    true)
        echo "./setenv.sh has already been run (ignoring)."
        ;;
    *)
        export PYTHONPATH="`pwd`:$PYTHONPATH"
        export NODEWATCH=`pwd`
        export DXKIT_NET_CONF="$NODEWATCH/release/files"
        export NODEWATCH_SETENV="true"
        echo "Environment Setup Complete."
esac
