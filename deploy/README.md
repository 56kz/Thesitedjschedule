# Despliegue en VPS (Hostinger) con Nginx y Let's Encrypt

## 1. En el VPS (una vez)

- Instalar Docker, Docker Compose, Nginx y Certbot (ej. `certbot` + `python3-certbot-nginx`).
- Obtener certificado Let's Encrypt (sustituye `tudominio.com` y tu email):
  ```bash
  sudo certbot certonly --webroot -w /var/www/certbot -d tudominio.com -d www.tudominio.com --email tu@email.com --agree-tos
  ```

## 2. Configurar Nginx

- Copiar `deploy/nginx.conf.example` a `/etc/nginx/sites-available/thesitedj`.
- Sustituir todas las apariciones de `TUDOMINIO.COM` por tu dominio.
- Activar el sitio y recargar Nginx:
  ```bash
  sudo ln -s /etc/nginx/sites-available/thesitedj /etc/nginx/sites-enabled/
  sudo nginx -t && sudo systemctl reload nginx
  ```

## 3. Desplegar la app

- En tu máquina: `DEPLOY_TARGET=usuario@tu-vps.com ./deploy.sh` (sube el código; no sube `.env`).
- En el VPS, en la carpeta del proyecto:
  - Crear `.env` a partir de `.env.production.example` y rellenar `SECRET_KEY_BASE`, contraseñas, etc.
  - Levantar con el override de producción (puerto solo en localhost):
    ```bash
    docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
    ```

Con esto, Nginx sirve HTTPS y pasa `X-Forwarded-Proto: https` a la app; el `.env` del servidor tiene `FORCE_SSL=true`, así que Rails asume HTTPS y el login/CSRF funcionan bien.

Renovación de certificados: `sudo certbot renew` (puedes poner un cron cada 2 meses).
