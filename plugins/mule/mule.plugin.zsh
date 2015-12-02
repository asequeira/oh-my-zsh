export MULE_ROOT="/opt"
export MULE_LOG="mule_ee.log"

# For Mule Kernel replace the line below with: MULE_SERVER=mule-standalone
MULE_SERVER=mule-enterprise-standalone

# For configuring your default MULE_HOME uncomment the followint line
# MULE_HOME=/path/to/mule/server

function mule() {
    if [ -z $1 ]; then
        muleconsole
        return 0
    fi
    type mule$1 1> /dev/null
    if [ $? -eq 0 ]; then
        mule$1 $@ ;
    else
        echo "Command \033[1m$1\033[0m not found"
        return 1
    fi
}

function muleclean() {
    rm -rf $MULE_HOME/.mule
}

function muledeploy() {
    cp $2 ${MULE_HOME}/apps
    ${MULE_HOME}/bin/mule start
}

function checkorder() {
    if ! [ -z "$(grep \.$1= $MULE_HOME/conf/wrapper.conf)" ]; then 
        echo "There is already a property with order $1";
        return 1
    else
        return 0
    fi
}

function mulenodebug() {
    if [ -z "$MULE_HOME" ]; then
        echo "MULE_HOME not defined"
        exit 1
    fi
    echo "Restoring \"$MULE_HOME/conf/wrapper.conf.bak\""
    cp $MULE_HOME/conf/wrapper.conf.bak $MULE_HOME/conf/wrapper.conf
}    

function muledebug() {
    if [ -z "$MULE_HOME" ]; then
        echo "MULE_HOME not defined"
        exit 1
    fi
    ! checkorder '900' && return 1
    ! checkorder '901' && return 1
    ! checkorder '902'  && return 1
    ! checkorder '903'  && return 1
    echo "Backing up wrapper.conf to wrapper.conf.bak, to revert call 'mule nodebug'"
    cp $MULE_HOME/conf/wrapper.conf $MULE_HOME/conf/wrapper.conf.bak
    sed -e 's/#wrapper.java.additional.<n>=-Xdebug/wrapper.java.additional.900=-Xdebug/g' $MULE_HOME/conf/wrapper.conf > copy ; mv copy $MULE_HOME/conf/wrapper.conf
    sed -e 's/#wrapper.java.additional.<n>=-Xnoagent/wrapper.java.additional.901=-Xnoagent/g' $MULE_HOME/conf/wrapper.conf  > copy ; mv copy $MULE_HOME/conf/wrapper.conf
    sed -e 's/#wrapper.java.additional.<n>=-Djava.compiler=NONE/wrapper.java.additional.902=-Djava.compiler=NONE/g' $MULE_HOME/conf/wrapper.conf  > copy ; mv copy $MULE_HOME/conf/wrapper.conf
    sed -e 's/#wrapper.java.additional.<n>=-Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005/wrapper.java.additional.903=-Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005/g' $MULE_HOME/conf/wrapper.conf  > copy ; mv copy $MULE_HOME/conf/wrapper.conf
    muleconsole
    mulenodebug
}

function mulego() {
    if [ -z "$2" ]; then
        cd $MULE_HOME
    else
        if [ -d "${MULE_ROOT}/${MULE_SERVER}-$2" ]; then
            cd ${MULE_ROOT}/${MULE_SERVER}-$2
            mulehome
        else
            if [ -d "${MULE_ROOT}/${MULE_SERVER}-$2-SNAPSHOT" ]; then
                cd ${MULE_ROOT}/${MULE_SERVER}-$2-SNAPSHOT
                mulehome
            else
                echo "Mule server not found: ${MULE_ROOT}/${MULE_SERVER}-$2";
                return 1
            fi
        fi
    fi
    echo "MULE_ROOT=${MULE_ROOT}"
}

function mulehelp() {
    echo "oh-my-zsh Mule plugin"
    echo 
    echo -e "Usage: \033[1mm\033[0m command [arguments...]";
    echo
    echo "Example:"
    echo
    echo "m go 3.7.0"
    echo "m start"
    echo "m deploy my-mule-app.zip"
    echo "m status"
    echo "m ps"
    echo "m stop"
    echo
}

function mulelog() {
    tail -f "${MULE_HOME}/logs/${MULE_LOG}"
}

function mulelogs() {
    tail -f $MULE_HOME/logs/*
}

function muleps() {
    ps -ax | grep mule | grep 'wrapper-macosx-universal' | grep -v '0:00.00 grep mule' | cut -c 1-5
    # TODO Make it work with other *nix systems
}

function muleroot() { 
    if [ -z "$2" ]; then
        if [ -z "$MULE_HOME" ]; then
            export MULE_ROOT="/opt/"
        else
            # TODO Validate that directory exists
            export MULE_ROOT=$(dirname $MULE_HOME)
        fi
    else
        # TODO Validate that directory exists
        export MULE_ROOT=$2
    fi
    echo "MULE_ROOT=${MULE_ROOT}"
}

function muleconsole() {
    ${MULE_HOME}/bin/mule $@
}

function mulestart() {
    ${MULE_HOME}/bin/mule start $@
}

function mulestop() {
    ${MULE_HOME}/bin/mule stop $@
}

function mulestatus() {
    ${MULE_HOME}/bin/mule status $@
}

function mulerestart() {
    ${MULE_HOME}/bin/mule restart $@
}

function mulehome() {
    if [ -z "$2" ]; then
        export MULE_HOME=$(pwd)
    else
        # TODO Validate that directory exists
        MULE_HOME=$(cd $2; pwd)
        export MULE_HOME
    fi
    echo "MULE_HOME=${MULE_HOME}"
}

#
# Aliases
#
alias m='mule'
