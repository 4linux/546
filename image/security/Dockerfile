# Etapa 1 – Build
FROM docker.io/golang:alpine3.21 AS build

# Cria diretório de trabalho (boa prática)
WORKDIR /app

# Copia o código-fonte
COPY app.go .

# Compila binário estático
ENV CGO_ENABLED=0
RUN go build -trimpath -ldflags="-s -w" -o /app/app app.go

# Etapa 2 – Runtime
FROM docker.io/alpine:3.22.0

# Diretório /etc somente-leitura
RUN chmod a-w /etc

# Cria usuário e grupo não-root
RUN addgroup -S poduser && adduser -S curso -G poduser -h /home/curso

# Remove utilitários padrão que você não quer expor
RUN rm -rf /bin/*

# Copia apenas o binário final
COPY --from=build /app/app /home/curso/app

USER curso
WORKDIR /home/curso
CMD ["./app"]
