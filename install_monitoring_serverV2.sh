#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# =============================================================================
# 🚀✨ Zabbix RocketStack: Instalação Premium de Monitoramento ✨🚀
# 🌐 Portfolio:
#   \e]8;;https://esleylealportfolio.vercel.app/\aVisite meu Portfólio\e]8;;\a
# =============================================================================

# =====================
# VARIÁVEIS DE VERSÃO
# =====================
ROCKETSTACK_VERSION="2.0.0"

# =====================
# PARÂMETROS PERSONALIZÁVEIS
# =====================
QUIET=${QUIET:-true}
SKIP_DESIGN=${SKIP_DESIGN:-false}
LOG_FILE=${LOG_FILE:-/var/log/zabbix-rocketstack-install.log}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-zabbix}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-zabbix}
MYSQL_USER=${MYSQL_USER:-zabbix}
MYSQL_DATABASE=${MYSQL_DATABASE:-zabbix}
PORTAINER_VERSION=${PORTAINER_VERSION:-2.9.3}
MYSQL_VERSION=${MYSQL_VERSION:-8.0.30}
GRAFANA_VERSION=${GRAFANA_VERSION:-latest}
ZABBIX_SERVER_IMAGE=${ZABBIX_SERVER_IMAGE:-zabbix/zabbix-server-mysql}
ZABBIX_AGENT_IMAGE=${ZABBIX_AGENT_IMAGE:-zabbix/zabbix-agent}
ZABBIX_WEB_IMAGE=${ZABBIX_WEB_IMAGE:-zabbix/zabbix-web-nginx-mysql}
ZABBIX_JAVA_IMAGE=${ZABBIX_JAVA_IMAGE:-zabbix/zabbix-java-gateway}
PORTAINER_PORT=${PORTAINER_PORT:-9443}
GRAFANA_PORT=${GRAFANA_PORT:-3000}
MYSQL_PORT=${MYSQL_PORT:-3306}
ZABBIX_SERVER_PORT=${ZABBIX_SERVER_PORT:-10051}
ZABBIX_AGENT_PORT=${ZABBIX_AGENT_PORT:-10050}
ZABBIX_WEB_PORT=${ZABBIX_WEB_PORT:-80}

# =====================
# LOGGING
# =====================
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# =====================
# CHECAGEM DE SO SUPORTADO
# =====================
check_os() {
  if ! grep -E 'Ubuntu 2[0-9]|Debian (1[0-9]|[2-9][0-9])' /etc/os-release > /dev/null; then
    echo "\e[1;31m[ERRO] Este script só suporta Ubuntu 20.04+ ou Debian 10+.\e[0m"
    exit 1
  fi
}

# =====================
# CHECAGEM DE DOCKER
# =====================
check_docker() {
  if command -v docker > /dev/null 2>&1; then
    log "Docker já instalado. Pulando instalação."
    return 0
  fi
  log "Docker não encontrado. Instalando..."
  run_cmd apt-get update -qq && run_cmd apt-get install -y -qq apt-transport-https ca-certificates curl gnupg2 software-properties-common
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
  run_cmd add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
  run_cmd apt-get update -qq && run_cmd apt-get install -y -qq docker-ce docker-ce-cli containerd.io
}

# =====================
# REMOÇÃO/RESET
# =====================
remove_all() {
  log "Removendo todos os containers, volumes e imagens criados pelo RocketStack..."
  docker rm -f portainer grafana mysql-server zabbix-java-gateway zabbix-server zabbix-agent zabbix-web-nginx-mysql 2>/dev/null || true
  docker volume rm portainer_data 2>/dev/null || true
  log "Remoção concluída."
  echo -e "${COLOR_OK}RocketStack removido com sucesso!${COLOR_RESET}"
  exit 0
}

# =====================
# ATUALIZAÇÃO DE IMAGENS
# =====================
update_images() {
  log "Atualizando imagens Docker..."
  docker pull portainer/portainer-ce:${PORTAINER_VERSION}
  docker pull grafana/grafana-enterprise:${GRAFANA_VERSION}
  docker pull mysql:${MYSQL_VERSION}
  docker pull ${ZABBIX_SERVER_IMAGE}
  docker pull ${ZABBIX_AGENT_IMAGE}
  docker pull ${ZABBIX_WEB_IMAGE}
  docker pull ${ZABBIX_JAVA_IMAGE}
  log "Imagens atualizadas."
}

# =====================
# WRAPPER PARA EXECUTAR COMANDOS
# =====================
run_cmd() {
  if [ "$QUIET" = "true" ]; then
    "$@" >> "$LOG_FILE" 2>&1
  else
    "$@" | tee -a "$LOG_FILE"
  fi
}

# Cores ANSI
COLOR_RESET="\e[0m"
COLOR_BANNER="\e[1;36m"    # Cyan bold
COLOR_SECTION="\e[1;35m"   # Magenta bold
COLOR_OK="\e[1;32m"        # Green bold
COLOR_WARN="\e[1;33m"      # Yellow bold

# Funções de design
print_banner() {
  if [ "$SKIP_DESIGN" = "false" ]; then
    local emoji="$1" msg="$2"
    echo -e "${COLOR_BANNER}═══════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${COLOR_BANNER}  ${emoji}  ${msg}  ${emoji}${COLOR_RESET}"
    echo -e "${COLOR_BANNER}═══════════════════════════════════════════════════${COLOR_RESET}"
  fi
}
print_slogan() {
  if [ "$SKIP_DESIGN" = "false" ]; then
    echo -e "${COLOR_SECTION}🔖 Slogan: Conecte, Monitore e Cresça com Elegância!${COLOR_RESET}"
  fi
}

# Banner e slogan iniciais
echo
print_banner "🚀" "Bem-vindo ao Instalador Zabbix & Stack"
print_slogan
[ "$QUIET" = "true" ] || sleep 2

echo
# Etapas de instalação (sempre silenciosas, mostram apenas status)

section() {
  if [ "$SKIP_DESIGN" = "false" ]; then
    echo -e "${COLOR_SECTION}$1${COLOR_RESET}"
  fi
}
finish() {
  echo -e "${COLOR_OK}✔ Concluído!${COLOR_RESET}"
  echo
}

# 1) Preparar ambiente
echo -n "⚙️  Preparando ambiente... "
run_cmd apt-get update -qq && run_cmd apt-get install -y -qq apt-transport-https ca-certificates curl gnupg2 software-properties-common
finish

# 2) Adicionar chave GPG do Docker
echo -n "🔐  Adicionando chave GPG do Docker... "
if [ "$QUIET" = "true" ]; then
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - >/dev/null 2>&1
else
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
fi
finish

# 3) Adicionar repositório Docker
echo -n "📦  Adicionando repositório Docker... "
run_cmd add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
run_cmd apt-get update -qq && run_cmd apt-get install -y -qq docker-ce docker-ce-cli containerd.io
finish

# 4) Iniciar Docker
echo -n "🐳  Iniciando Docker... "
run_cmd systemctl start docker && run_cmd systemctl enable docker
finish

# 5) Portainer
echo -n "📑  Iniciando Portainer... "
run_cmd docker run -d --name portainer --restart=always -p 8000:8000 -p ${PORTAINER_PORT}:${PORTAINER_PORT} -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:${PORTAINER_VERSION}
finish

# 6) Grafana
echo -n "📊  Iniciando Grafana... "
run_cmd docker run -d --name grafana --restart=always -p ${GRAFANA_PORT}:3000 grafana/grafana-enterprise:${GRAFANA_VERSION}
finish

# 7) MySQL com healthcheck
echo -n "🗄️  Iniciando MySQL com healthcheck... "
run_cmd docker run -d --name mysql-server --restart=always --health-cmd='mysqladmin ping -h localhost' --health-interval=3s --health-timeout=5s --health-retries=5 -e MYSQL_DATABASE="${MYSQL_DATABASE}" -e MYSQL_USER="${MYSQL_USER}" -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" -p ${MYSQL_PORT}:3306 mysql:${MYSQL_VERSION} --character-set-server=utf8 --collation-server=utf8_bin --default-authentication-plugin=mysql_native_password

echo -n "⌛  Aguardando MySQL... "
until [ "$(docker inspect -f '{{.State.Health.Status}}' mysql-server)" = "healthy" ]; do echo -n "."; sleep 2; done
echo
finish

# 8) Zabbix Java Gateway
echo -n "☕  Iniciando Zabbix Java Gateway... "
run_cmd docker run -d --name zabbix-java-gateway --restart=unless-stopped ${ZABBIX_JAVA_IMAGE}
finish

# 9) Zabbix Server
echo -n "🖥️  Iniciando Zabbix Server... "
run_cmd docker run -d --name zabbix-server --restart=unless-stopped -p ${ZABBIX_SERVER_PORT}:10051 --link mysql-server:mysql --link zabbix-java-gateway:zabbix-java-gateway -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="${MYSQL_DATABASE}" -e MYSQL_USER="${MYSQL_USER}" -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" ${ZABBIX_SERVER_IMAGE}
finish

# 10) Zabbix Agent
echo -n "👮  Iniciando Zabbix Agent... "
run_cmd docker run -d --name zabbix-agent --restart=unless-stopped -p ${ZABBIX_AGENT_PORT}:10050 --link zabbix-server:zabbix-server -e ZBX_HOSTNAME="Zabbix server" -e ZBX_SERVER_HOST="zabbix-server" ${ZABBIX_AGENT_IMAGE}
finish

# 11) Zabbix Web
echo -n "🌐  Iniciando Zabbix Web (NGINX+MySQL)... "
run_cmd docker run -d --name zabbix-web-nginx-mysql --restart=unless-stopped -p ${ZABBIX_WEB_PORT}:8080 --link mysql-server:mysql -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="${MYSQL_DATABASE}" -e MYSQL_USER="${MYSQL_USER}" -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" ${ZABBIX_WEB_IMAGE}
finish

# Finalização
echo
print_banner "🎉" "Todos os containers iniciados com sucesso!"
echo -e "${COLOR_OK}Pronto para monitorar! 🚀${COLOR_RESET}"

# Mensagens de erro e finalização
trap 'echo -e "\e[1;31m[ERRO] Ocorreu um erro. Veja o log em $LOG_FILE\e[0m"; exit 1' ERR
