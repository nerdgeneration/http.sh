#!/usr/bin/env bash

# http.sh - the experimental bash http server
#
# Copyright Mark Griffin 2020 (BSD-3 License)
# http://nerdgeneration.com/http.sh/

export HTTPSH_VERSION='0.1-alpha'
export HTTPSH_URL='https://github.com/nerdgeneration/http.sh'

# Some notes:
# - The aim is to use native bash as much as possible
# - printf is more secure than echo because you can't tell echo to stop processing parameters
# - Based on CGI version 1.1: https://www.ietf.org/rfc/rfc3875

httpsh_serve() {
    export REQUEST_URI="TODO"

    # Ignored CGI variables: REMOTE_IDENT REMOTE_USER
    export GATEWAY_INTERFACE="CGI/1.1"
    # Optional
    # export PATH_INFO="$(url_decode "${REQUEST_URI%%\?*}")"
    # export PATH_TRANSLATED="$PWD/$(basename "$PATH_INFO")"

    export QUERY_STRING="TODO"
    export REMOTE_ADDR="$NCAT_REMOTE_ADDR"

    # TODO Has a trailing "."
    export REMOTE_HOST="$(dig +noall +answer -x "$REMOTE_ADDR" | cut -f3)"

    # TODO Needs request parsing
    export REQUEST_METHOD="GET"

    # TODO Needs request parsing and identifying RewriteRule script
    export SCRIPT_NAME="TODO"

    export SERVER_NAME="$HOSTNAME"
    export SERVER_PORT="$NCAT_LOCAL_PORT"
    export SERVER_PROTOCOL="HTTP/1.0"
    export SERVER_SOFTWARE="http.sh ($HTTPSH_VERSION; $HTTPSH_URL)"

    response="<h1>http.sh</h1><p>This is simply a demonstration of ncat, an exported function, some CGI variables and a HTTP/1.0 response.</p>"

    printf "HTTP/1.0 %s\r\n" "200 OK"
    printf "Content-Type: %s\r\n" "text/html"
    printf "Server: %s\r\n" "$SERVER_SOFTWARE"
    printf "Content-Length: %s\r\n" "${#response}"
    printf "\r\n"
    printf "%s" "$response"
}

# Make bash intolerant of errors
set -ef -o pipefail

# Read the config file
declare -A _CONFIG
_CONFIG['PORT']='8080'
_CONFIG['DOCUMENT_ROOT']='/srv/www'
[[ -f /etc/http.sh.conf ]] && source /etc/http.sh.conf
[[ -f ./http.sh.conf ]] && source ./http.sh.conf

# Ready to serve
export -f httpsh_serve
ncat --listen --keep-open --sh-exec httpsh_serve "${_CONFIG[PORT]}"
