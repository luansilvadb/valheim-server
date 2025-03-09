# Imagem base para ARM (Ubuntu 20.04)
FROM arm64v8/ubuntu:20.04

# Variável para evitar interatividade durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Atualiza e instala dependências essenciais e bibliotecas necessárias
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    libgl1-mesa-dev \
    libgl1-mesa-dri \
    libasound2-dev \
    libxi-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
 && rm -rf /var/lib/apt/lists/*

# Adiciona suporte para arquitetura i386 (algumas dependências podem precisar)
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y \
    gcc-multilib \
    g++-multilib \
 && rm -rf /var/lib/apt/lists/*

# Clona e compila o Box64
RUN git clone https://github.com/ptitSeb/box64.git /opt/box64
RUN mkdir -p /opt/box64/build && cd /opt/box64/build && \
    cmake .. -DRUNTEST=0 && \
    make -j$(nproc) && \
    make install

# Cria diretório e baixa o SteamCMD (versão Linux)
RUN mkdir -p /opt/steamcmd && cd /opt/steamcmd && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && rm steamcmd_linux.tar.gz

# Cria diretório onde o servidor do Stardew será instalado
RUN mkdir -p /opt/stardew

# Instala/atualiza o servidor dedicado do Stardew Valley usando SteamCMD via Box64
RUN /usr/local/bin/box64 /opt/steamcmd/steamcmd +login anonymous +force_install_dir /opt/stardew +app_update 837470 validate +quit

# Expõe a porta padrão do servidor (24642, podendo ser alterada conforme necessário)
EXPOSE 24642

# Define o diretório de trabalho
WORKDIR /opt/stardew

# Comando de inicialização do servidor dedicado via Box64
CMD ["/usr/local/bin/box64", "./StardewValleyDedicatedServer", "-port", "24642"]