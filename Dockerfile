# Use uma imagem base ARM Linux (Debian, Ubuntu são boas opções)
FROM ubuntu:latest

# Informações sobre o autor (opcional)
LABEL maintainer="Seu Nome <seuemail@example.com>"

# Atualiza o sistema e instala dependências necessárias
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl ca-certificates lib32stdc++6 lib32z1 lib32ncurses5 iproute2 \
    && rm -rf /var/lib/apt/lists/* # Limpa listas do apt para reduzir tamanho da imagem

# Instala o Box64
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "aarch64" ]; then \
      wget https://github.com/ptitSeb/box64/releases/download/v0.2.5/box64-debian-bullseye.deb && \
      dpkg -i box64-debian-bullseye.deb && \
      rm box64-debian-bullseye.deb; \
    else \
      echo "Arquitetura não ARM64, Box64 não é necessário diretamente"; \
    fi

# Instala SteamCMD (versão Linux x86)
RUN mkdir -p /home/steamcmd
WORKDIR /home/steamcmd
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Define o diretório de trabalho para o servidor de jogo
WORKDIR /serverfiles

# Expõe as portas necessárias para o servidor de jogo (CS:GO exemplo)
EXPOSE 27015/udp
EXPOSE 27015/tcp
EXPOSE 27005/udp # Porta RCON (opcional, mas útil para administração remota)

# Comando para iniciar o servidor de jogo
# IMPORTANTE: Use `box64` para executar o steamcmd e o servidor
ENTRYPOINT ["/bin/bash", "-c", \
    "export LD_LIBRARY_PATH=.:/usr/lib:/usr/lib32:/usr/local/lib:/usr/local/lib32:$LD_LIBRARY_PATH && \
     /home/steamcmd/steamcmd +login anonymous +force_install_dir /serverfiles +app_update 740 validate +quit && \
     box64 ./srcds_run -game csgo -console -usercon +game_type 0 +game_mode 0 +mapgroup mg_bomb +map de_dust2" \
]

# Notas:
# - `740` é o App ID do CS:GO Dedicated Server no Steam. Consulte o App ID do jogo que você quer.
# - `srcds_run` é o executável do servidor CS:GO. O nome pode variar para outros jogos.
# - Ajuste os parâmetros de inicialização do servidor (`+game_type`, `+game_mode`, `+map`, etc.) conforme necessário.
# - `export LD_LIBRARY_PATH=...` é importante para garantir que o Box64 encontre as bibliotecas necessárias dentro do container.