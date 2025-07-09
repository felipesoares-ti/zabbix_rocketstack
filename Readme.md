# Zabbix RocketStack

Um conjunto avançado de scripts para instalar e gerenciar um servidor de monitoramento completo, incluindo Docker, Portainer, Grafana, MySQL e Zabbix, com opções de personalização, atualização e remoção.

## 🚀 Sumário
- [Descrição](#descrição)
- [Funcionalidades](#funcionalidades)
- [Prérequisitos](#prérequisitos)
- [Sistemas Suportados](#sistemas-suportados)
- [Instalação](#instalação)
- [Personalização](#personalização)
- [Remoção/Reset](#remoçãoreset)
- [Atualização de Imagens](#atualização-de-imagens)
- [FAQ](#faq)
- [Contribuição](#contribuição)
- [Agradecimentos](#agradecimentos)

## Descrição

O **Zabbix RocketStack** automatiza a instalação e gerenciamento de um servidor de monitoramento moderno em sistemas Linux (Debian/Ubuntu). Todos os componentes rodam em containers Docker, com logs detalhados e opções de customização.

## Funcionalidades
- Instalação e configuração do Docker Engine (ou uso do já instalado)
- Deploy de Portainer, Grafana, MySQL e Zabbix em containers
- Parâmetros personalizáveis via variáveis de ambiente
- Atualização automática das imagens Docker
- Remoção/reset de todos os containers criados
- Logs detalhados em `/var/log/zabbix-rocketstack-install.log`
- Checagem de sistema operacional suportado

## Prérequisitos
- Acesso root ou permissão `sudo`
- Conexão com a internet
- Firewall liberando portas:
  - 9443 (Portainer)
  - 3000 (Grafana)
  - 3306 (MySQL)
  - 10051 (Zabbix Server)
  - 10050 (Zabbix Agent)
  - 80 (Zabbix Web)

## Sistemas Suportados
- Ubuntu 20.04+
- Debian 10+

## Instalação
```bash
git clone https://github.com/EsleyLeal/monitoring-server-setup.git
cd monitoring-server-setup
chmod +x install_monitoring_serverV2.sh
sudo ./install_monitoring_serverV2.sh
```

## Personalização
Você pode customizar variáveis de ambiente ao rodar o script:
```bash
sudo MYSQL_ROOT_PASSWORD=MinhaSenha PORTAINER_PORT=9000 ./install_monitoring_serverV2.sh
```
Principais variáveis:
- `MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD`, `MYSQL_USER`, `MYSQL_DATABASE`
- `PORTAINER_VERSION`, `GRAFANA_VERSION`, `MYSQL_VERSION`
- `PORTAINER_PORT`, `GRAFANA_PORT`, `MYSQL_PORT`, `ZABBIX_SERVER_PORT`, `ZABBIX_AGENT_PORT`, `ZABBIX_WEB_PORT`
- `QUIET` (true/false), `SKIP_DESIGN` (true/false)

## Remoção/Reset
Para remover todos os containers, volumes e imagens criados:
```bash
sudo ./install_monitoring_serverV2.sh --remove
```

## Atualização de Imagens
Para atualizar todas as imagens Docker utilizadas:
```bash
sudo ./install_monitoring_serverV2.sh --update
```

## FAQ
**1. Como vejo os logs da instalação?**
- Os logs ficam em `/var/log/zabbix-rocketstack-install.log`.

**2. Posso rodar em CentOS ou outros sistemas?**
- Não. Apenas Ubuntu 20.04+ e Debian 10+ são suportados.

**3. Como customizar as portas?**
- Defina as variáveis de ambiente correspondentes antes de rodar o script.

## Contribuição
Pull requests são bem-vindos! Abra uma issue para sugestões ou problemas.

## Screenshots
*Adicione aqui prints dos dashboards e containers rodando*

## Agradecimentos
Este projeto é licenciado sob a Licença MIT.

---
**Obrigado por usar o Zabbix RocketStack!**
