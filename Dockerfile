# Use a imagem oficial do Elixir com a versão mais recente
FROM bitwalker/alpine-elixir:1.15 AS build

# Instale as dependências do sistema operacional
RUN apk update \
    && apk add --no-cache tzdata ncurses-libs postgresql-client build-base openssh-client \
    && cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
    && echo "America/Sao_Paulo" > /etc/timezone \
    && apk del tzdata
    
# Configuração do diretório de trabalho dentro do contêiner
WORKDIR /app

ARG MIX_ENV=prod

EXPOSE 4000

# Instale as dependências do Elixir
RUN mix local.hex --force && mix local.rebar --force

# Copie o arquivo mix.exs e mix.lock para o contêiner
COPY mix.exs mix.lock ./
COPY config config

# Copie todos os arquivos para o contêiner
COPY . ./

# Compile o projeto
RUN mix do deps.get, deps.compile, compile, release

# Comando padrão para iniciar o seu aplicativo
CMD ["sh", "./start.sh"]
