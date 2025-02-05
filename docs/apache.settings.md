

# Sample site configuration for apache.

Οι παρακάτω ρυθμίσεις κάνουν τον Apache Proxy Server
για την εφαρμογή (δεδομένου ότι τρέχει στο port 12233).

Το _`X_FORWARDED_PROTO`_ το αντιλαμβάνεται το rails 
και δεν παραπονιέται ότι υπάρχει https στο αρχικό request,
ενώ αυτό βλέπει http.


```
<VirtualHost *:443>
ServerName certbot.pdekritis.gr
DocumentRoot /var/www/certbot.pdekritis.gr
ServerAdmin webmaster@ych.gr

ErrorLog ${APACHE_LOG_DIR}/error.certbot.pdekritis.gr.log
CustomLog ${APACHE_LOG_DIR}/access.certbot.pdekritis.gr.log combined

<Location />
Require all granted
ProxyPass http://127.0.0.1:12233/
ProxyPassReverse http://127.0.0.1:12233/
ProxyPassReverseCookieDomain 127.0.0.1 certbot.pdekritis.gr
ProxyPreserveHost on
RequestHeader set X_FORWARDED_PROTO 'https'
</Location>

SSLCertificateFile /etc/letsencrypt/live/certbot.pdekritis.gr/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/certbot.pdekritis.gr/privkey.pem
SSLProxyEngine on
Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>

```
