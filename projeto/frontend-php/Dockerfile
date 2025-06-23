FROM alpine:3.22.0

# Define porta
EXPOSE 8080

# Define variáveis de ambiente
ENV PHP_INI='/etc/php83/php.ini'
ENV DB_HOST=''
ENV DB_PORT=3306
ENV DB_USER=''
ENV DB_NAME=''
ENV DB_PASS=''

# Criação de usuário não-root e diretório de app
RUN addgroup -S webgroup && \
    adduser -S webuser -G webgroup -h /home/webuser && \
    mkdir -p /app && \
    chown -R webuser:webgroup /app

# Instala apenas os pacotes essenciais do PHP
RUN apk add --no-cache \
    php-cli \
    php-mysqli \
    php-session \
    php-pecl-memcached \
    && rm -rf /var/cache/apk/*

# Copia o código para o container
COPY . /app

# Ajusta permissões
RUN chown -R webuser:webgroup /app

# Define usuário não-root e diretório de trabalho
USER webuser
WORKDIR /app

# Entrada protegida (sem shell aberto)
ENTRYPOINT ["php", "-c", "/etc/php83/php.ini", "-S", "0.0.0.0:8080", "-t", "/app"]
