#!/bin/bash

# Variáveis de ambiente com valores padrão
SERVER_NAME="${SERVER_NAME:-My Docker Valheim Server}"
WORLD_NAME="${WORLD_NAME:-Dedicated}"
PASSWORD="${PASSWORD:-secret}"
PUBLIC="${PUBLIC:-1}" # 1 para público, 0 para privado
PORT="${PORT:-2456}"
SAVEDIR="${SAVEDIR:-/home/ubuntu/valheim_data}"

echo "Starting Valheim Server with:"
echo "  Server Name: ${SERVER_NAME}"
echo "  World Name: ${WORLD_NAME}"
echo "  Password: ${PASSWORD}"
echo "  Public: ${PUBLIC}"
echo "  Port: ${PORT}"
echo "  Save Directory: ${SAVEDIR}"

# Criar diretório de salvamento se não existir
mkdir -p "${SAVEDIR}"

# Executar o servidor Valheim
./valheim_server.x86_64 \
    -nographics \
    -batchmode \
    -port "${PORT}" \
    -public "${PUBLIC}" \
    -name "${SERVER_NAME}" \
    -world "${WORLD_NAME}" \
    -password "${PASSWORD}" \
    -savedir "${SAVEDIR}" 2>&1 | tee nohup.out