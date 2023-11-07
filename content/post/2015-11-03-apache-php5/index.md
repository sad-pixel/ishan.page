---
title: How to install and optimize Apache with mpm_event, php5-fpm and MariaDB
tags: [linux, sysadmin, legacy
]
date: 2015-11-03
categories:
- Legacy
---

> **A note to the reader**
> 
> This post is a legacy post. The legacy posts that are available on this website were written many years ago. These posts are made available here **for archival purposes only**.   
> They reflect the age I was, and the level of knowledge that I had when I wrote them, and they **may contain outdated information**, so please keep that in mind as you proceed to read this article.


**Original Title**: How to install a highly optimized LAMP stack with mpm_event and MariaDB

Apache is today more important as a web server than ever before. Most PHP scripts assume (or even require) apache to be installed in order to run. However, for most people running a VPS with less than a GB of RAM, having to run apache is a deal breaker. The same applies for the stock MySQL configuration. This tutorial will help you to install Apache with the event MPM + PHP [fastcgi] + MariaDB 5.5

## Step 1 - Install Prerequisites
This tutorial requires root. If you're not already root, run this command:
```
sudo su
```
and gain root priviledges. Alternatively, you may prefix the commands with ```sudo``` also.
We will use the aptitude package manager as a replacement for apt-get. Since it is not available by default, go ahead and install it.
```
apt-get install -y aptitude
```

## Step 2 - Install Apache

Apache is sometimes included by default by ubuntu, however aptitude will take care of removing the preform mpm when we install the apache fastcgi module, and the event mpm
```
aptitude install -y libapache2-mod-fastcgi apache2-mpm-event
```
Then, we disable the build in apache php modules as they consume too much precious memory
```
a2dismod php4 # PHP v4 is outdated. It should be criminal to even have it on a system
a2dismod php5 # mod_php is not usable with worker mpm, therefore we disable it
a2dismod fcgid # fcgid is not required. We will set up fastcgi later.
```
Then, we will enable the mod_fastcgi, mod_ssl, mod_actions and mod_rewrite
```
a2enmod fastcgi
a2enmod ssl
a2enmod actions
a2enmod rewrite
```
## Step 3 - Install PHP

We will be running PHP as a FastCGI process. We will configure FastCGI to run as a separate server and have a 120 second timeout.

First, we configure the apache2 fastcgi module.
```
nano /etc/apache2/mods-available/fastcgi.conf
```
```
<IfModule mod_fastcgi.c>
FastCgiIpcDir /var/lib/apache2/fastcgi
# Set FPM to run externally
FastCGIExternalServer /srv/www/fcgi-bin.d/php5-fpm -pass-header Authorization -idle-timeout 120 -socket /var/run/php5-fpm-www-data.sock
Alias /php5-fcgi /srv/www/fcgi-bin.d
AddType application/x-httpd-php5 .php
# FPM will handle all PHP files
<FilesMatch "\.php$">
SetHandler php-fpm
</FilesMatch>
Action php-fpm /php5-fcgi/php5-fpm

# Prevent external access to FPM directory
<Location "/php5-fcgi/php5-fpm">
    Order deny,allow
    Deny from All
    Allow from env=REDIRECT_STATUS
</Location>

</IfModule>
```
Finish off by creating the FPM directory
```
mkdir -p /srv/www/fcgi-bin.d
```
Then, we install the php packages
Base PHP packages. Essential to run PHP
```
aptitude install -y php5-fpm php5-common php-apc php5-mysqlnd php5-dev
```
Secondary, but useful PHP modules/packages. Feel free to omit
```
aptitude install -y php5-memcache php5-curl php5-mcrypt php5-xsl php5-gd php5-imagick php5-snmp php5-xmlrpc
```
And, we're done installing PHP

## Step 4 - Install MariaDB
We will be using MariaDB as our database server. It is an enhanced, drop-in replacement for MySQL that is developed by the original team and is more performant

Install MariaDB
```
aptitude -y install mariadb-server mariadb-client
```
Secure MariaDB
```
mysql_secure_installation
```
And we're done!

## Step 5 - Pre-Optimization
Before we optimize, we need to restart apache2 and php. 
```
service php5-fpm restart
apache2ctl graceful
```
## Step 6 - Optimize Apache
The only optimization apache really needs is the config optimization.
Edit the config file:
```
nano /etc/apache2/apache2.conf
```
```
...
LockFile ${APACHE_LOCK_DIR}/accept.lock
...
PidFile ${APACHE_PID_FILE}
...
Timeout 300
...
KeepAlive On
...
MaxKeepAliveRequests 100
...
KeepAliveTimeout 5
...
<IfModule mpm_worker_module>
    StartServers          2
    MinSpareThreads      25
    MaxSpareThreads      75 
    ThreadLimit          64
    ThreadsPerChild      25
    MaxClients          150
    MaxRequestsPerChild   0
</IfModule>
...
<IfModule mpm_event_module>
    StartServers          1
    MinSpareThreads       2
    MaxSpareThreads       5 
    ThreadLimit           20
    ThreadsPerChild       20
    MaxClients            60
    MaxRequestsPerChild   5000
</IfModule>
...
# These need to be set in /etc/apache2/envvars
User ${APACHE_RUN_USER}
Group ${APACHE_RUN_GROUP}

...

AccessFileName .htaccess

...
#
# The following lines prevent .htaccess and .htpasswd files from being 
# viewed by Web clients. 
#
<Files ~ "^\.ht">
    Order allow,deny
    Deny from all
    Satisfy all
</Files>

...
<Directory />
    Options -Indexes -FollowSymLinks
    AllowOverride All
    Order allow,deny
    allow from all
</Directory>
...
DefaultType None
...
HostnameLookups Off

...
ErrorLog ${APACHE_LOG_DIR}/error.log
...
LogLevel warn
...
# Include module configuration:
Include mods-enabled/*.load
Include mods-enabled/*.conf
...
# Include list of ports to listen on and which to use for name based vhosts
Include ports.conf
...
#
# The following directives define some format nicknames for use with
# a CustomLog directive (see below).
# If you are behind a reverse proxy, you might want to change %h into %{X-Forwarded-For}i
#
LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %O" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
...
# Include generic snippets of statements
Include conf.d/
...
# Include the virtual host configurations:
Include sites-enabled/

```
## Step 7 - Optimize FPM
> Note: Most of these steps are done with automated linux tools like `sed` which make it easy to edit the configuration files. If you want to know what's going on
> behind the scenes, refer to the comments above each command block.

Before we optimize FPM, we need to stop the service

```
service php5-fpm stop
```
The FPM configuration file is lengthy and complex. To quickly do the configuration automatically, run:
```
php_fpm_conf="/etc/php5/fpm/pool.d/www.conf"
# Configure these values to your liking. Optimized for 512MB RAM VPS
FPM_MAX_CHILDREN=5
FPM_START_SERVERS=1
FPM_MIN_SPARE_SERVERS=1
FPM_MAX_SPARE_SERVERS=2
FPM_MAX_REQUESTS=5000
```
`pm.max_children` is the configuration value that controls the maximum number of server processes that will be
started by FastCGI. 5 is usually enough, but it might be a good idea to set it to 10 or 15 for a high traffic site
on a high-end vps
```
sed -i 's/^pm.max_children.*/pm.max_children = '${FPM_MAX_CHILDREN}'/' $php_fpm_conf
```
`pm.start_servers` is the number of servers to be initially started by FastCGI. 1 is nearly always enough. Try 2 or 3 for higher traffic sites. Make sure that is it less that `pm.max_children`.
```
sed -i 's/^pm.start_servers.*/pm.start_servers = '${FPM_START_SERVERS}'/' $php_fpm_conf
```
`pm.min_spare_servers` is the minimum number of server processes FastCGI will have ready to handle additional load. Each server process is respawned when it hits `pm.max_requests`. It is here that this value becomes useful. It ensures that the site will not go offline for even a small amount of time, and will remain performant even under load. 1 is enough for small sites (< 5000 views / minute). For larger sites, try 5 or 6.
```
sed -i 's/^pm.min_spare_servers.*/pm.min_spare_servers = '${FPM_MIN_SPARE_SERVERS}'/' $php_fpm_conf
```
`pm.max_spare_servers` exists for only one reason: to prevent FastCGI from consuming too many resources in the event of high load. This is the
number of maximum server processes that will be kept ready by FastCGI. Make sure it is at least half of `pm.max_children` and greater than 
`pm.min_spare_server`s. 2 is OK for a small site. Try 9 or 10 for a large site 
```
sed -i 's/^pm.max_spare_servers.*/pm.max_spare_servers = '${FPM_MAX_SPARE_SERVERS}'/' $php_fpm_conf
```
`pm.max_requests` controls the maximum number of hits a FastCGI process is allowed to serve before it is killed and respawned. This value
is there in place to deal with the fact that over time, these processes leak memory. Periodically killing and respawning them allows 
us to keep the site snappy. 5000 is a pretty good value to begin with, give or take a couple hundreds. If `pm.min_spare_server`s is < 5, and 
this value is < 5000, the site will become more sluggish. Never set it to a 3 digit or less number. Always ensure that it is >= 5000
```
sed -i 's/\;pm.max_requests.*/pm.max_requests = '${FPM_MAX_REQUESTS}'/' $php_fpm_conf
```
Change to socket connection for better performance
```
sed -i 's/^listen =.*/listen = \/var\/run\/php5-fpm-www-data.sock/' $php_fpm_co
```
Now, configure the php.ini file.
```
php_ini_dir="/etc/php5/fpm/php.ini"
# Configure these values to your liking. Optimized for 512MB RAM VPS
PHP_MEMORY_LIMIT=192M
PHP_MAX_EXECUTION_TIME=120
PHP_MAX_INPUT_TIME=300
PHP_POST_MAX_SIZE=50M
PHP_UPLOAD_MAX_FILESIZE=50
```
`max_execution_time` is the maximum amount of time (in seconds) that a script is allowed to execute for, before it is killed. 120 is a big enough number to do most heavy calculations, but this number may be increased if many computations are required to be performed or heavy downloading needs to be done.
```
sed -i 's/^max_execution_time.*/max_execution_time = '${PHP_MAX_EXECUTION_TIME}'/' $php_ini_dir
```
`memory_limit` is the maximum amount of memory (in MB) that a PHP script is allowed to take up. 192 is more than
enough for most jobs, but you may consider raising it if you want to do heavy computations.
```
sed -i 's/^memory_limit.*/memory_limit = '${PHP_MEMORY_LIMIT}'/' $php_ini_dir
```
This is the maximum amount of time (in seconds) for which a client can upload data to the server through a keep-alive connection. 300 seconds (or 5 minutes) is usually enough. You may want to set it to something like 6300 (2 hours) if you plan on uploading huge files. 
```
sed -i 's/^max_input_time.*/max_input_time = '${PHP_MAX_INPUT_TIME}'/' $php_ini_dir
```
`post_max_size` is the maximum size (in MB) of the data that can be sent to the server through a POST request. 50 MB is usually more than enough for most needs, but feel free to change to will.
```
sed -i 's/^post_max_size.*/post_max_size = '${PHP_POST_MAX_SIZE}'/' $php_ini_dir
```
`upload_max_filesize` is the maximum size of an individual file (in MB) that can be uploaded. Change at will.
```
sed -i 's/^upload_max_filesize.*/upload_max_filesize = '${PHP_UPLOAD_MAX_FILESIZE}'/' $php_ini_dir
```
Don't expose PHP. More of a security fix than memory optimization
```
sed -i 's/^expose_php.*/expose_php = Off/' $php_ini_dir
```
Disable potentially dangerous PHP functions that may allow attackers to execute arbitary code on your machine. 
```
sed -i 's/^disable_functions.*/disable_functions = exec,system,passthru,shell_exec,escapeshellarg,escapeshellcmd,proc_close,proc_open,dl,popen,show_source/' $php_ini_dir
```
Now we restart all the services
```
service php5-fpm start
service php5-fpm restart
apache2ctl graceful
```

## Step 8 - Optimize MariaDB
MariaDB configuration is quite easy to optimize. Just dropping InnoDB can cause a huge performance gain. 
```
nano /etc/mysql/my.cnf
```
```
[mysqld]
default-storage-engine = myisam
key_buffer = 1M
query_cache_size = 1M
query_cache_limit = 128k
max_connections=25
thread_cache=1
skip-innodb
query_cache_min_res_unit=0
tmp_table_size = 1M
max_heap_table_size = 1M
table_cache=256
concurrent_insert=2 
max_allowed_packet = 1M
sort_buffer_size = 64K
read_buffer_size = 256K
read_rnd_buffer_size = 256K
net_buffer_length = 2K
thread_stack = 64K
END
```
Now we restart the service
```
service mysql restart
```

## Step 9 - Reboot
Reboot the server to get better performance
```
shutdown -r now
```

## Step 11 - Set up a non-root sudo-enabled user
We will use this user's home directory to contain our vhosts.
Add the User
```
adduser demo # Replace demo with your name
# Like `adduser ishan`
```
Grant him priviledges
```
gpasswd -a demo sudo
```

## Step 12 - Add a virtualhost
Replace "example.com" with your domain
Replace "demo" with your user
Create an FPM user
```
DOMAIN_OWNER=demo
cp /etc/php5/fpm/pool.d/{www.conf,$DOMAIN_OWNER.conf}
# Quickly edit the FPM file
# Create a new FPM pool with same name as user
sed -i 's/^\[www\]$/\['${DOMAIN_OWNER}'\]/' /etc/php5/fpm/pool.d/$DOMAIN_OWNER.conf
# set it to listen on a unix socket
sed -i 's/^listen =.*/listen = \/var\/run\/php5-fpm-'${DOMAIN_OWNER}'.sock/' /etc/php5/fpm/pool.d/$DOMAIN_OWNER.conf
# set permissions
sed -i 's/^user = www-data$/user = '${DOMAIN_OWNER}'/' /etc/php5/fpm/pool.d/$DOMAIN_OWNER.conf
sed -i 's/^group = www-data$/group = '${DOMAIN_OWNER}'/' /etc/php5/fpm/pool.d/$DOMAIN_OWNER.conf
sed -i 's/^;listen.mode =.*/listen.mode = 0660/' /etc/php5/fpm/pool.d/$DOMAIN_OWNER.conf
sed -i 's/^;listen.owner =.*/listen.owner = www-data/' /etc/php5/fpm/pool.d/$DOMAIN_OWNER.conf
sed -i 's/^;listen.group =.*/listen.group = www-data/' /etc/php5/fpm/pool.d/$DOMAIN_OWNER.conf
```
Restart FPM
```
service php5-fpm restart
```

Create a public_html for your domain
```
mkdir -p /home/demo/example_com/public_html
```
Create the log files:
```
touch /home/demo/test_digitalocean_tk/logs/{access.log,error.log}
```

Set permissions
```
chown demo:demo /home/demo/
chown -R demo:demo /home/demo/example_com
# Allow execute permissions to group and other so that the webserver can serve files
chmod 711 /home/demo/
chmod 711 /home/demo/example_com
```

Create the VirtualHost file
```
nano /etc/apache2/sites-available/example_com
```
```
<VirtualHost *:80>

    ServerName example.com
    ServerAlias www.example.com
    ServerAdmin admin@example.com
    DocumentRoot /home/demo/example_com/public_html/
    ErrorLog /home/demo/example_com/logs/error.log
    CustomLog /home/demo/example_com/logs/access.log combined

    FastCGIExternalServer /home/demo/example_com/php5-fpm -pass-header Authorization -idle-timeout 120 -socket /var/run/php5-fpm-demo.sock
    Alias /php5-fcgi /home/demo/example_com

</VirtualHost>

```

Enable the virtualhost
```
ln -s /etc/apache2/sites-available/example_com /etc/apache2/sites-available/example_com
```

Test the virtualhost
```
nano /home/demo/example_com/public_html/info.php
```
```
<?php
phpinfo();
?>
```
navigate to your domain in the browser and see that it's working correctly.

## Conclusion
Now that you know how to install and optimize a LAMP stack, get cracking and create a great site that will be big enough to crash this setup!