FROM debian:latest

LABEL maintainer="Seu Nome <seu@email.com>"

# Atualiza pacotes e instala dependências necessárias
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    tar \
    unzip \
    libc6 \
    libstdc++6 \
    libx11-6 \
    libsdl2-2.0-0 \
    openjdk-17-jre-headless # Instala o Java Runtime Environment (JRE) headless

# Baixa e instala o Box64
RUN wget https://github.com/ptitSeb/box64/releases/download/v0.2.4/box64-debian-x86_64.tar.gz -O box64.tar.gz && \
    tar -xzf box64.tar.gz -C /usr/local/bin && \
    rm box64.tar.gz

# Define o diretório de trabalho
WORKDIR /app

# Instala o SteamCMD
RUN mkdir -p /home/steamcmd && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -O /home/steamcmd/steamcmd_linux.tar.gz && \
    tar -xzf /home/steamcmd/steamcmd_linux.tar.gz -C /home/steamcmd && \
    rm /home/steamcmd/steamcmd_linux.tar.gz

# Baixa o servidor dedicado de Stardew Valley usando SteamCMD (app ID 1472170)
RUN /home/steamcmd/steamcmd +force_install_dir /app/stardewvalley_server +login anonymous +app_update 1472170 validate +quit

# Exponha a porta padrão do Stardew Valley (24670 UDP e TCP)
EXPOSE 24670/udp
EXPOSE 24670/tcp

# Comando para iniciar o servidor Stardew Valley dentro do container usando Box64 e Java
CMD ["/bin/bash", "-c", "cd stardewvalley_server && box64 java -jar StardewValleyServer.jar"]

# Instruções para o usuário sobre como executar o servidor
# CMD echo "--- INSTRUÇÕES ---" && \
#     echo "1. Construa a imagem Docker: docker build -t stardew-valley-server-arm ." && \
#     echo "2. Execute o container: docker run -it --rm -p <porta_host>:24670/udp -p <porta_host>:24670/tcp stardew-valley-server-arm" && \
#     echo "   (Substitua <porta_host> pela porta que você deseja usar na sua máquina host)" && \
#     echo "--- FIM INSTRUÇÕES ---" && \
#     /bin/bash