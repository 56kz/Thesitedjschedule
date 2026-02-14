# Imagen base Ruby (coincide con .ruby-version)
FROM ruby:3.3.6-slim-bookworm

# Dependencias: compilar gems nativas (mysql2), runtime JS (ExecJS/autoprefixer) y runtime
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    default-libmysqlclient-dev \
    pkg-config \
    libvips \
    curl \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Gemfile primero para aprovechar caché de capas
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' \
    && bundle config set --local without 'development test' \
    && bundle install -j4

# Código de la aplicación
COPY . .
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# Precompilar assets (SECRET_KEY_BASE dummy solo para el build)
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Exponer puerto de Puma
EXPOSE 3000

# Health check opcional
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:3000/up || exit 1

# Puma como proceso principal (mantiene el contenedor en ejecución)
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
