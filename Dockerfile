FROM ubuntu:20.04

# Informações do autor (opcional)
LABEL maintainer="Seu Nome <seuemail@example.com>"

# Definir DEBIAN_FRONTEND para não interativo para evitar prompts
ENV DEBIAN_FRONTEND=noninteractive
# Definir o fuso horário para São Paulo
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Atualizar pacotes e instalar dependências gerais
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y wget curl tar gzip bzip2 sudo nano

# Instalar dependências para Box86/64
RUN apt-get install -y git build-essential cmake
RUN dpkg --add-architecture armhf
RUN apt-get update
RUN apt-get install -y gcc-arm-linux-gnueabihf libc6:armhf libncurses5:armhf libstdc++6:armhf

# Instalar Box86
WORKDIR /opt
RUN git clone https://github.com/ptitSeb/box86
WORKDIR /opt/box86
RUN mkdir build && cd build
RUN cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
RUN make -j$(nproc)
RUN sudo make install
RUN sudo systemctl restart systemd-binfmt

# Instalar Box64
WORKDIR /opt
RUN git clone https://github.com/ptitSeb/box64
WORKDIR /opt/box64
RUN mkdir build && cd build
RUN cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
RUN make -j$(nproc)
RUN sudo make install
RUN sudo systemctl restart systemd-binfmt

# Instalar SteamCMD
WORKDIR /home/ubuntu
RUN mkdir steamcmd
WORKDIR /home/ubuntu/steamcmd
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
RUN ./steamcmd.sh +quit # Inicializar SteamCMD

# Instalar Servidor Valheim
RUN ./steamcmd.sh +@sSteamCmdForcePlatformType linux +login anonymous +force_install_dir /home/ubuntu/valheim_server +app_update 896660 validate +quit

# Criar script start_server.sh e torná-lo executável
WORKDIR /home/ubuntu/valheim_server
COPY start_server.sh .
RUN chmod +x start_server.sh

# Expor portas do servidor Valheim
EXPOSE 2456-2459/tcp
EXPOSE 2456-2459/udp

# Instalar screen (opcional, mas segue o guia)
RUN apt-get install -y screen

# Comando para executar o servidor quando o contêiner iniciar
CMD ["/bin/bash", "-c", "screen -dmS valheim ./start_server.sh; tail -f nohup.out"]