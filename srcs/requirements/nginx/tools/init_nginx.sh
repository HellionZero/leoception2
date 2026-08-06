set -e

SSL_DIR="/etc/nginx/ssl"
DOMAIN_NAME="${DOMAIN_NAME:-localhost}"

mkdir -p "$SSL_DIR"

#check if the certificate already exists
if [ -f "$SSL_DIR/nginx.crt" ] && [ -f "$SSL_DIR/nginx.key" ]; then
    echo "SSL certificate and key already exist. Skipping generation."
else
    echo "Generating a new SSL certificate and key..."
    # Generate a self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SSL_DIR/nginx.key" \
        -out "$SSL_DIR/nginx.crt" \
        -subj "/C=BR/ST=SP/O=42SP/CN=${DOMAIN_NAME}"
fi

echo "SSL certificate and key are ready."

exec nginx -g "daemon off;"
