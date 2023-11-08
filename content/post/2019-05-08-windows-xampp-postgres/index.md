---
title: Install Postgres into XAMPP on Windows
tags: [postgres, windows]
date: 2019-05-08
categories:
- Snippets
slug: 2019-05-08-windows-xampp-postgres
---


# Setting up a local Postgres development environment


## 1. Install Postgres
1. Download the installer from [EnterpriseDB](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads#windows)
2. Run the installer
3. Install Postgres into C:\xampp\pgsql\{version_number} folder

## 2. Enable PostGres modules for PHP
1. Open php.ini file located in C:\xampp\php.
2. Uncomment the following lines in php.ini
	```
	extension=php_pdo_pgsql.dll
	extension=php_pgsql.dll
	```

## 3. Install Adminer
1. Download [Adminer](https://www.adminer.org/#download)
2. Place the PHP file into HTDOCS

## 4. Wrapping up
1. Restart Apache
2. Adminer is now accessible [here](http://localhost/adminer.php)
