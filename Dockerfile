FROM ruby:2.5.3-alpine
LABEL maintainer="a0s@github.com"

ENV LANG C.UTF-8
ENV TERM xterm-256color

WORKDIR /app
COPY . /app

RUN \
    apk add --no-cache build-base libstdc++ && \
    bundle install --deployment --without test development && \
    apk del --no-cache build-base && \
    rm -rf \
        /app/.git \
        /root/.bundle \
        /app/vendor/bundle/ruby/2.5.0/cache/*.gem

CMD ["bundle", "exec", "ruby", "./server/web_server_runner.rb", "1>&2"]
