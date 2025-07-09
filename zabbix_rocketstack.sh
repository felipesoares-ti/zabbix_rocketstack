#!/usr/bin/env bash
# Zabbix RocketStack - Script principal de instalação e configuração

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# =============================================================================
# 🚀✨ Zabbix RocketStack: Instalação Premium de Monitoramento ✨🚀
# =============================================================================

# =====================
# VARIÁVEIS DE VERSÃO E PERSONALIZAÇÃO
# =====================
ROCKETSTACK_VERSION="2.0.0"
QUIET=${QUIET:-false}
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
# CORES E DESIGN
# =====================
COLOR_RESET="\e[0m"
COLOR_BANNER="\e[1;36m"
COLOR_SECTION="\e[1;35m"
COLOR_OK="\e[1;32m"
COLOR_WARN="\e[1;33m"
COLOR_ERROR="\e[1;31m"

banner() {
  echo -e "${COLOR_BANNER}═══════════════════════════════════════════════════${COLOR_RESET}"
  echo -e "${COLOR_BANNER} 🚀 Zabbix RocketStack - Instalação Premium 🚀 ${COLOR_RESET}"
  echo -e "${COLOR_BANNER}═══════════════════════════════════════════════════${COLOR_RESET}"
}

# =====================
# LOG E STATUS
# =====================
log() {
  echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}
status() {
  echo -e "${COLOR_OK}✔ $1${COLOR_RESET}"
}
warn() {
  echo -e "${COLOR_WARN}⚠ $1${COLOR_RESET}"
}
error() {
  echo -e "${COLOR_ERROR}✖ $1${COLOR_RESET}" >&2
}

# =====================
# PRÉ-REQUISITOS
# =====================
check_prereqs() {
  if ! command -v docker &>/dev/null; then
    warn "Docker não encontrado. Instalando..."
    apt-get update -qq && apt-get install -y -qq apt-transport-https ca-certificates curl gnupg2 software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
    add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    apt-get update -qq && apt-get install -y -qq docker-ce docker-ce-cli containerd.io
    status "Docker instalado."
  else
    status "Docker já está instalado."
  fi
}

# =====================
# INSTALAÇÃO DO STACK
# =====================
install_stack() {
  log "Iniciando containers do RocketStack..."
  docker run -d --name portainer --restart=always -p 8000:8000 -p ${PORTAINER_PORT}:${PORTAINER_PORT} -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:${PORTAINER_VERSION}
  docker run -d --name grafana --restart=always -p ${GRAFANA_PORT}:3000 grafana/grafana-enterprise:${GRAFANA_VERSION}
  docker run -d --name mysql-server --restart=always -e MYSQL_DATABASE="${MYSQL_DATABASE}" -e MYSQL_USER="${MYSQL_USER}" -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" -p ${MYSQL_PORT}:3306 mysql:${MYSQL_VERSION} --character-set-server=utf8 --collation-server=utf8_bin --default-authentication-plugin=mysql_native_password
  docker run -d --name zabbix-java-gateway --restart=unless-stopped ${ZABBIX_JAVA_IMAGE}
  docker run -d --name zabbix-server --restart=unless-stopped -p ${ZABBIX_SERVER_PORT}:10051 --link mysql-server:mysql --link zabbix-java-gateway:zabbix-java-gateway -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="${MYSQL_DATABASE}" -e MYSQL_USER="${MYSQL_USER}" -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" ${ZABBIX_SERVER_IMAGE}
  docker run -d --name zabbix-agent --restart=unless-stopped -p ${ZABBIX_AGENT_PORT}:10050 --link zabbix-server:zabbix-server -e ZBX_HOSTNAME="Zabbix server" -e ZBX_SERVER_HOST="zabbix-server" ${ZABBIX_AGENT_IMAGE}
  docker run -d --name zabbix-web-nginx-mysql --restart=unless-stopped -p ${ZABBIX_WEB_PORT}:8080 --link mysql-server:mysql -e DB_SERVER_HOST="mysql-server" -e MYSQL_DATABASE="${MYSQL_DATABASE}" -e MYSQL_USER="${MYSQL_USER}" -e MYSQL_PASSWORD="${MYSQL_PASSWORD}" -e MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}" ${ZABBIX_WEB_IMAGE}
  status "Todos os containers iniciados com sucesso!"
}

# =====================
# ATUALIZAÇÃO E REMOÇÃO
# =====================
update_stack() {
  log "Atualizando imagens Docker..."
  docker pull portainer/portainer-ce:${PORTAINER_VERSION}
  docker pull grafana/grafana-enterprise:${GRAFANA_VERSION}
  docker pull mysql:${MYSQL_VERSION}
  docker pull ${ZABBIX_SERVER_IMAGE}
  docker pull ${ZABBIX_AGENT_IMAGE}
  docker pull ${ZABBIX_WEB_IMAGE}
  docker pull ${ZABBIX_JAVA_IMAGE}
  status "Imagens atualizadas."
}
remove_stack() {
  log "Removendo containers e volumes..."
  docker rm -f portainer grafana mysql-server zabbix-java-gateway zabbix-server zabbix-agent zabbix-web-nginx-mysql 2>/dev/null || true
  docker volume rm portainer_data 2>/dev/null || true
  status "RocketStack removido com sucesso!"
}

# =====================
# BACKUP E RESTORE (EXEMPLO)
# =====================
backup_stack() {
  log "Backup dos volumes Docker..."
  docker run --rm --volumes-from mysql-server -v $(pwd):/backup busybox tar czvf /backup/mysql_backup.tar.gz /var/lib/mysql
  status "Backup realizado em ./mysql_backup.tar.gz"
}
restore_stack() {
  log "Restaurando backup do MySQL..."
  docker run --rm --volumes-from mysql-server -v $(pwd):/backup busybox tar xzvf /backup/mysql_backup.tar.gz -C /
  status "Restore concluído."
}

# =====================
# AJUDA E USO
# =====================
usage() {
  echo -e "\n${COLOR_SECTION}Uso:${COLOR_RESET}"
  echo "  sudo ./zabbix_rocketstack.sh [comando]"
  echo "\nComandos disponíveis:"
  echo "  install     Instala todo o stack (padrão)"
  echo "  update      Atualiza as imagens Docker"
  echo "  remove      Remove todos os containers e volumes"
  echo "  backup      Realiza backup do banco MySQL"
  echo "  restore     Restaura backup do banco MySQL"
  echo "  help        Mostra esta mensagem"
  echo "\nExemplo: sudo ./zabbix_rocketstack.sh update"
}

# =====================
# EXECUÇÃO PRINCIPAL
# =====================
banner
check_prereqs

case "${1:-install}" in
  install) install_stack ;;
  update) update_stack ;;
  remove) remove_stack ;;
  backup) backup_stack ;;
  restore) restore_stack ;;
  help|--help|-h) usage ;;
  *) usage ;;
esac

status "Acesse o Portainer em http://<IP>:${PORTAINER_PORT}"
status "Acesse o Grafana em http://<IP>:${GRAFANA_PORT}"
status "Acesse o Zabbix Web em http://<IP>:${ZABBIX_WEB_PORT}"
