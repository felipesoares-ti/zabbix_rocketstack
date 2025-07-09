# Zabbix RocketStack

![Zabbix RocketStack Banner](https://img.shields.io/badge/Zabbix-RocketStack-blueviolet?style=for-the-badge&logo=zabbix)

> Automatize e simplifique o monitoramento da sua infraestrutura.

---

## 🚀 Visão Geral
O **Zabbix RocketStack** automatiza a implantação de um ambiente de monitoramento completo utilizando Docker. Inclui Zabbix, Grafana, MySQL, Portainer, Zabbix Java Gateway e Zabbix Agent, com foco em automação, robustez e facilidade operacional.

---

## 📋 Requisitos
- Ubuntu 20.04+, Debian 10+ ou superior
- Bash
- Docker (será instalado automaticamente se não estiver presente)
- Permissões de root (sudo)

---

## ⚡ Instalação rápida
Execute em um servidor Linux (Ubuntu/Debian):
```bash
sudo ./zabbix_rocketstack.sh
```

- O script instala e configura automaticamente todos os serviços necessários.
- Personalize variáveis no início do script ou via variáveis de ambiente.

---

## 🛠️ Funcionalidades
- Instalação automatizada de todo o stack
- Atualização e remoção fácil dos serviços
- Customização por variáveis de ambiente
- Logs detalhados e coloridos
- Validação de pré-requisitos
- Banner visual e identidade própria
- Backup/restore opcional
- Sugestão de dashboards prontos
- Suporte a integrações (Telegram, Slack, etc)
- Comandos: `install`, `update`, `remove`, `backup`, `restore`, `help`

---

## 📦 Serviços inclusos
- **Zabbix Server + Web**: Monitoramento centralizado
- **Grafana**: Dashboards avançados
- **MySQL**: Banco de dados para o Zabbix
- **Portainer**: Gerenciamento visual dos containers
- **Zabbix Java Gateway**: Monitoramento Java
- **Zabbix Agent**: Coleta de métricas

---

## 🔗 Acesso rápido
- **Portainer:** http://<IP>:9443
- **Grafana:** http://<IP>:3000
- **Zabbix Web:** http://<IP>

---

## 📝 Personalização
Você pode customizar portas, senhas, versões e outros parâmetros editando o início do script ou usando variáveis de ambiente:
```bash
export MYSQL_ROOT_PASSWORD=suasenha
export GRAFANA_PORT=4000
sudo ./zabbix_rocketstack.sh
```

---

## 🧩 Dashboards e integrações
- Exemplos de dashboards para Grafana e Zabbix podem ser adicionados na pasta `/dashboards`.
- Integração fácil com Telegram, Slack e outros sistemas de alerta (veja instruções no script).

---

## 💾 Backup e Restore
- Faça backup do banco MySQL:
  ```bash
  sudo ./zabbix_rocketstack.sh backup
  ```
- Restaure um backup existente:
  ```bash
  sudo ./zabbix_rocketstack.sh restore
  ```

---

## 🆘 Suporte e dúvidas
- Abra uma issue no GitHub
- Contato: [ti.felipesoares@gmail.com](mailto:ti.felipesoares@gmail.com)
- Veja o script para mais detalhes e dicas

---

## 💡 Dicas e boas práticas
- Sempre rode o script como root (sudo)
- Verifique se as portas necessárias estão livres
- Consulte os logs em `/var/log/zabbix-rocketstack-install.log` em caso de erro
- Use o Portainer para gerenciar visualmente os containers

---

## 🧑‍💻 Aplicabilidade e Passo a Passo

### Exemplos de uso

#### 1. Instalação padrão (tudo automático)
```bash
sudo ./zabbix_rocketstack.sh
```
- Instala e configura todos os serviços com as portas e senhas padrão.

#### 2. Instalação customizada (exemplo de variáveis)
```bash
export MYSQL_ROOT_PASSWORD=MinhaSenhaForte
export GRAFANA_PORT=4001
sudo ./zabbix_rocketstack.sh
```
- Personalize portas, senhas e versões conforme sua necessidade.

#### 3. Atualizar imagens Docker
```bash
sudo ./zabbix_rocketstack.sh update
```
- Atualiza todas as imagens do stack para as versões mais recentes.

#### 4. Remover todo o stack
```bash
sudo ./zabbix_rocketstack.sh remove
```
- Remove todos os containers e volumes criados pelo RocketStack.

#### 5. Backup e restore do banco MySQL
```bash
sudo ./zabbix_rocketstack.sh backup   # Gera arquivo mysql_backup.tar.gz
sudo ./zabbix_rocketstack.sh restore  # Restaura o backup
```

### Fluxo típico de uso
1. Faça login em um servidor Linux compatível.
2. Clone o repositório ou transfira o script para o servidor.
3. Dê permissão de execução: `chmod +x zabbix_rocketstack.sh`
4. Execute conforme o cenário desejado (padrão, customizado, update, etc).
5. Acesse os serviços via navegador usando o IP do servidor e as portas informadas.
6. Use o Portainer para gerenciar containers e o Grafana/Zabbix para criar dashboards.

### Recomendações de uso
- Ideal para ambientes de testes, laboratórios, POCs e pequenas/médias implantações.
- Para produção, revise as configurações de segurança, backup e persistência de dados.
- Consulte a documentação oficial do Zabbix e Grafana para integrações avançadas.

---

> Feito com 💜 para a comunidade de monitoramento!
