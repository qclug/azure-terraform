# azure-terraform
Repo for Terraform configurations on Azure

## MSSQL Drivers for PHP 7.3
### Install the MSSQL Rpo, ODBC driver for Red Hat 7
```shell
curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo
sudo yum remove unixODBC-utf16 unixODBC-utf16-devel #to avoid conflicts
sudo ACCEPT_EULA=Y yum install -y msodbcsql17 mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
sudo yum install -y unixODBC-devel
```

### Install EPEL AND PHP REPOS, PHP 7.3
```shell
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm
yum-config-manager --enable remi-php73
yum install -y php php-pdo php-xml php-pear php-devel re2c gcc-c++ gcc 

# Compiling the PHP drivers with PECL with PHP 7.2 requires a more recent GCC than the default:
yum install -y centos-release-scl devtoolset-7
scl enable devtoolset-7 bash

# Install the PHP drivers for Microsoft SQL Server
yum install -y php-sqlsrv php-pdo_sqlsrv
echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini
```

### Install Apache
```shell
yum install -y httpd
setsebool -P httpd_can_network_connect on
setsebool -P httpd_can_network_connect_db on
setsebool -P httpd_can_network_connect_db 1  # Allow Apache to connect to DBs externally
systemctl enable httpd
apachectl restart
systemctl status httpd.service
```

## Setup Terraform
## Setup Terraform CLI
```shell
az ad sp create-for-rbac --name Terraform
az account show --query "{subscriptionId:id, tenantId:tenantId}"
echo "Setting environment variables for Terraform"
export ARM_SUBSCRIPTION_ID=your_subscription_id
export ARM_CLIENT_ID=your_appId
export ARM_CLIENT_SECRET=your_password
export ARM_TENANT_ID=your_tenant_id
```