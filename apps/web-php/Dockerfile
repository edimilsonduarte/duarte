FROM php:8.3-apache

# Extensões comuns; adicione outras conforme o projeto precisar (ex.: gd, intl)
RUN docker-php-ext-install pdo pdo_mysql

COPY public/ /var/www/html/

EXPOSE 80
