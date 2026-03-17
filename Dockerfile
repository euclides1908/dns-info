FROM docker.io/library/ruby:3.3-slim

# Atualiza pacotes e instala dependências do sistema
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      whois \
      dnsutils \
    && rm -rf /var/lib/apt/lists/*

# Instala a gem necessária
RUN gem install colorize

# Cria diretório de trabalho
WORKDIR /app

# Copia o script para dentro do container
COPY dominio.rb /app/dominio.rb

# Define o comando padrão (modo interativo)
CMD ["ruby", "dominio.rb"]