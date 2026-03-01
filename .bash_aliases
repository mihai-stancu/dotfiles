#!/usr/bin/bash

source ~/Projects/curatorium/bash-import/.deps/assert.sh;
source ~/Projects/curatorium/bash-import/.deps/docs.sh;
source ~/Projects/curatorium/bash-import/.deps/namespace.sh;
source ~/Projects/curatorium/bash-import/.deps/strict.sh;
source ~/Projects/curatorium/bash-import/.deps/trace.sh;

#
#region shortcuts

# overrides
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'

# ls
alias ll='ls -halFv --group-directories-first'
alias ls='ls -h --color'
alias la='ls -hA'
alias lm='ll | more'       #  Pipe through 'more'
alias lr='ll -R'           #  Recursive ls.
alias lx='ls -lXB'         #  Sort by extension.
alias lk='ls -lSr'         #  Sort by size, biggest last.
alias lt='ls -ltr'         #  Sort by date, most recent last.
alias lc='ls -ltcr'        #  Sort by/show change time,most recent last.
alias lu='ls -ltur'        #  Sort by/show access time,most recent last.
alias l='ls -hCF'
alias tree='tree -Csuh'    #  Nice alternative to 'recursive ls' ...

alias h='history'
alias j='jobs -l'
alias kj='kill -9 $(jobs -p | head -1)'
alias which='type -a'

# pretty-print PATH:
alias path='echo -e ${PATH//:/\\n}';
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}';

# typos
alias xs='cd'
alias vf='cd'
alias moer='more'
alias moew='more'
alias kk='ll'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias watch='watch --color'
fi

# xdebug
function xdebug_on() {
  server="$1";
    export PHP_IDE_CONFIG="serverName=$server";
    export XDEBUG_CONFIG="idekey=MIHAI_STANCU_STORM remote_host=$server remote_enable=1";
}
function xdebug_off() {
    export XDEBUG_CONFIG="remote_enable=0"
}

#endregion shortcuts


#
#region symfony
alias sf='php bin/console';
alias cc="sf cache:clear";
alias cache:clear="sf cache:clear";
alias clear:cache="sf cache:clear";
alias config="sf debug:config";
alias dump='php vendor/bin/var-dump-server';
alias env-vars="sf debug:container --env-vars";
alias env-var="sf debug:container --env-var";
alias events="sf debug:event-dispatcher";
alias event="sf debug:event-dispatcher";
alias fixtures="sf doctrine:fixtures:load --append"
[[ -f $PWD/symfony.lock ]] && alias migrate="sf doctrine:migrations:migrate";
alias migrate:diff="sf doctrine:migrations:diff";
alias params="sf debug:container --parameters";
alias param="sf debug:container --parameter";
alias psysh='php vendor/bin/psysh --cwd /app';
alias router="sf debug:router";
alias schema:create="sf doctrine:schema:create";
alias schema:drop="sf doctrine:schema:drop";
alias schema:update="sf doctrine:schema:update";
alias schema:validate="sf doctrine:schema:validate";
alias services="sf debug:container";
#endregion symfony


#
#region laravel
alias artisan="php artisan";
alias db:seed="artisan db:seed";
#alias migrate="artisan migrate";
alias migrate:fresh="artisan migrate:fresh";
alias migrate:refresh="artisan migrate:refresh";
alias queue:work="artisan queue:work";
alias route:list="artisan route:list";
alias tinker="artisan tinker";
#endregion laravel


#
#region STAN
alias phpstan='qa phpstan';
alias stan-sf='phpstan analyse -c $(find -name "*symfony*.neon")'
alias stan-zf='phpstan analyse -c $(find -name "*zend*.neon")'
alias stan-lara='phpstan analyse -c $(find -name "*laravel*.neon")'
alias stan='stan-sf && stan-zf';

alias php-cs-fixer='qa php-cs-fixer';
alias cs-check='php-cs-fixer check';
alias cs-fix='php-cs-fixer fix';
#endregion


#
#region generic

#
# Find which parent directory contains $search
# -d | --dir  Output the directory path
# -f | --file Output the file path
function find-up {
  # Parse options & arguments.
  local inc="true";
  local search="";
  while [ "$1" != "$EOL" ]; do case "$1" in
      -f | --file  ) inc="true"   ;;
      -d | --dir   ) inc="false"  ;;
      *            ) search="$1"  ;;
  esac; shift; done


  # Iterate through parent directories until a match is found.
  local path=$(pwd);
  while [[ "$path" != "" && ! -e "$path/$search" ]]; do
    path=${path%/*};
  done
  if [[ ! -e "$path/$search" ]]; then
    return;
  fi

  # Output the result.
  if [[ $inc == 'true' ]]; then
    path="$path/$search";
  fi
  echo "$path";
}

function memusage() {
  local count=${1:-5}; shift;
  (
    printf "SIZE %%MEM COMMAND\n";
    ps -A --sort -rss -o comm,pmem,rss                                                                  \
    | awk '{ pcts[$1] += $2; abs[$1] += $3*1024; c[$1]++; } END {for (cmd in pcts) { printf "%s %s %s %s\n", abs[cmd], pcts[cmd], cmd, c[cmd] }}' \
    | sort -rn                                                                                          \
    | numfmt --to=iec                                                                                   \
  )                                                                                                     \
  | column -t                                                                                           \
  | head -n$count                                                                                       \
  ;
}

function extract {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xvjf $1     ;;
            *.tar.gz)    tar xvzf $1     ;;
            *.bz2)       bunzip2 $1      ;;
            *.rar)       unrar x $1      ;;
            *.gz)        gunzip $1       ;;
            *.tar)       tar xvf $1      ;;
            *.tbz2)      tar xvjf $1     ;;
            *.tgz)       tar xvzf $1     ;;
            *.zip)       unzip $1        ;;
            *.Z)         uncompress $1   ;;
            *.7z)        7z x $1         ;;
            *)           echo "'$1' cannot be extracted via >extract<" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# TAR entire directory
function maketar {
    tar cvzf "${1%%/}.tar.gz"  "${1%%/}/";
}

# ZIP entire directory
function makezip {
    zip -r "${1%%/}.zip" "$1" ;
}

function display-aliases() {
    [[ -f $PWD/artisan      ]] && REGION=laravel;
    [[ -f $PWD/symfony.lock ]] && REGION=symfony;

    echo "";
    echo "#";
    echo "# Aliases";
    echo "";
    awk '/^#region '$REGION'$/,/^#endregion '$REGION'$/{if($0!~/^#(region|endregion)/)print}' ~/.bash_aliases \
    | sed 's/.*alias //' | awk -F= '{name=$1; $1=""; printf "%-20s %s\n", name, $0}';
    echo "";
}

#endregion


#
#region docker compose exec
function dc {
  local type="$1"; shift;
  local service="$1"; shift;

  docker compose $type $service "${@}";
}
function dcb {
  dc 'build --no-cache' "$1" "${@:2}";
}
function dce {
  dc exec "$1" "${2:-bash}" "${@:3}";
}
function dcl {
  dc 'logs -f' "$1" "${@:2}";
}
function dcr {
  dc 'run --rm' "$1" "${2:-bash}" "${@:3}";
}
function dcx {
  local service="$1";
  dc 'down --remove-orphans' $service;

  local volume="$2";
  if [[ ! -z "$volume" ]]; then
    local volume="$(docker compose config $volume | yq e .volumes.$volume.name)";
    docker volume rm $volume;
  fi

  dc 'up -d' $service;
  dcl $service;
}
function qa {
  docker run -it -v "$PWD:/app" --env-file .env neurony/php-8.2:qa ${1:-bash};
}
alias fe-do="dce frontend"
alias be-do="dce backend"
alias  q-do="dce queue"
alias  r-do="dce redis"

alias php="be-do php";
alias composer="be-do composer";
alias phpunit="be-do phpunit";
alias phpstan="qa phpstan analyse -c .stan/phpstan-symfony.neon && qa phpstan analyse -c .stan/phpstan-zend.neon";
alias psalm="be-do psalm";
alias composer-require-checker="qa composer-require-checker"
alias local-php-security-checker="qa local-php-security-checker"

#endregion docker compose exec


#
#region kubernetes

KUBECTL='kubectl';
alias k='$KUBECTL';
alias kube='$KUBECTL';

function kcp() {
  query="$1"; shift;
  kpods $query cp "$@";
}

function kedit() {
  query=$(sed 's|^i/|ingress/|; s|^d/|deploy/|; s|^c/|cronjob/|; s|^cron/|cronjob/|; s|^s/|service/|'<<<"$1"); shift;
  $KUBECTL edit "$query" "$@";
}

function kexec() {
  query="$1"; shift;
  kpods $query exec "$@";
}

function kdbg() {
  TARGET="${1?Specify a target deployment or cron}"; shift;
  IMAGE="$($KUBECTL get $TARGET -ojson | jq -rc '.spec.template.spec.containers[0].image // .spec.jobTemplate.spec.template.spec.containers[0].image')";
  NAME="debug-${TARGET//\//-}";
  $KUBECTL run "$NAME" --image="$IMAGE" -it -- $@;
}

function klogs()
{
  query="$1"; shift;
  kpods "$query" logs;
}

function kns() {
  local namespace="${1:-$($KUBECTL config get-contexts | grep -P '^\*' | tail -1 | awk '{ print $5 }')}"; shift;
  ktxt "" "$namespace" > /dev/null;
  $KUBECTL get namespaces | sed "s/^$namespace.*/\o33[47;31;1m&\o033[0m/";
}

function kpod() {
  query="$1"; shift;
  kpods "$query" | awk '{print $1}' | head -n1;
}
function kpods() {
  query="$1"; shift;
  pods=$($KUBECTL get pods | grep Running);
  [[ -z  "$query" ]] && echo "$pods" && return;

  action="$1"; shift || true;
  pods=$(echo "$pods" | grep -P "^$query");
  [[ -z "$action" ]] && echo "$pods" && return;

  id=$(echo "$pods" | tail -1 | awk '{ print $1; }');

  case $action in
    "cp")
      dst="$1"; shift;
      src="$1"; shift;
      echo "$KUBECTL cp $src $id:$dst;";
      $KUBECTL cp $src $id:$dst;
    ;;
    "exec")
      command="${1:-bash}";
      $KUBECTL exec -it "$id" -- sh -c "$command";
    ;;
    "logs")
      since="${1:-10s}";
      $KUBECTL logs -f "$id" --since "$since";
    ;;
    *)
      $KUBECTL "$action" pod "$id" "$@";
    ;;
  esac
}

function krestart() {
    query=$(sed 's|^i/|ingress/|; s|^d/|deploy/|; s|^c/|cronjob/|; s|^cron/|cronjob/|; s|^s/|service/|'<<<"$1"); shift;
    $KUBECTL rollout restart "$query" "$@";
}

function ktxt() {
  local context="${1:-$($KUBECTL config get-contexts | grep -P '^\*' | tail -1 | awk '{ print $2 }')}"; shift;
  $KUBECTL config use-context "$context" > /dev/null 2>&1;
  local namespace="--namespace=${1:-$($KUBECTL config get-contexts | grep -P '^\*' | tail -1 | awk '{ print $5 }')}";
  $KUBECTL config set-context "$context" "$namespace" > /dev/null;
  $KUBECTL config get-contexts | sed 's/^\*.*/\o33[47;31;1m&\o033[0m/';
}

#endregion kubernetes


#
#region chosen tools
alias display=
alias terminal=terminator
alias browser=chromium
alias ide=phpstorm
alias files=
alias calc=galculator
alias myip="curl -4 icanhazip.com"
#endregion

#region other
function cleanreg() {
  local registry="${1:?Usage: cleanreg <registry> [keep-count]}"; shift;
  local count="${1:-50}";    shift;
  for repository in $(az acr repository list --name $registry --output tsv); do
    az acr repository show-tags --name $registry --repository $repository  --output tsv --orderby time_desc |\
      sed 1,${count}d |\
      xargs -I{} az acr repository delete --name $registry --yes --image $repository:{} \
    ;
  done
}

alias teams-emulator='NODE_TLS_REJECT_UNAUTHORIZED=0 /usr/local/bin/teams-emulator'

# Apply a (chain of) PHP functions to a value
# phpf <func1> [func2] ... [funcN] <value>
function phpf() {
  local fns=("${@:1:$#-1}");
  local call="${@: -1}";
  for (( i=${#fns[@]}-1; i>=0; i-- )); do
    call="${fns[i]}($call)";
  done
  php -r "echo $call.\"\n\";";
}
# Same us phpf but it quotes the value
function phpfs() {
  phpf ${@:1:$#-1} "'${@: -1}'";
}

function update-ip-list() {
  local NOW="$(date +'%Y-%m-%d %H')";
  local IP="$(curl -4 icanhazip.com 2>/dev/null)";
  if grep -i "$IP" ~/.myip >/dev/null 2>&1; then
    return;
  fi

  echo "$NOW  $IP" >> ~/.myip;
}

function unwhitelist() {
  IP="$1"; shift;
  kexec redis redis-cli <<REDIS
    SREM banned-ips:whitelist $IP
REDIS
}
function whitelist() {
  IP="$1"; shift;
  kexec redis redis-cli <<REDIS
    SADD banned-ips:whitelist $IP
    ZREM banned-ips $IP
    ZREM banned-ips:counter:$(date -u +%H) $IP
REDIS
}
function blacklist() {
  IP="$1"; shift;
  kexec redis redis-cli <<REDIS
    ZREM banned-ips:whitelist $IP
    ZADD banned-ips $(date +%s) $IP
REDIS
}

#endregion other
