# docker-php-apache-typo3

## ANPASSUNGEN FÜR TYPO3 IN DOCKER

### .htaccess

Die Umschreibung auf https muss gelöscht bzw. auskommentiert werden, da innerhalb des Containers nur http benutzt wird. Der Reverse Proxy von Mittwald kümmert sich um die Verschlüsselung.
```
RewriteCond %{HTTPS} !=on
RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

### Additional Configuration

Die Option für den Reverse Proxy muss in TYPO3 aktiviert werden.
```
$GLOBALS['TYPO3_CONF_VARS']['SYS']['reverseProxyIP'] = '*';
$GLOBALS['TYPO3_CONF_VARS']['SYS']['reverseProxySSL'] = '*';
$GLOBALS['TYPO3_CONF_VARS']['SYS']['reverseProxyHeaderMultiValue'] = 'first';
$GLOBALS['TYPO3_CONF_VARS']['SYS']['trustedHostsPattern'] = '.*';
```
