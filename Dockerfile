# Entorno de Compilación Hermético para Aetheria
# Basado en Debian Slim para velocidad
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar Toolchain ARM y utilidades
RUN apt-get update && apt-get install -y \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    libnewlib-arm-none-eabi \
    make \
    wget \
    python3 \
    git \
    cpio \
    && rm -rf /var/lib/apt/lists/*

# 2. Directorio de trabajo
WORKDIR /app

# 3. Comando por defecto
CMD ["/bin/bash"]
