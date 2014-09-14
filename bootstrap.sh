#!/usr/bin/env bash

echo "deb http://cran.rstudio.com/bin/linux/ubuntu precise/" | sudo tee -a /etc/apt/sources.list

# Update apt
apt-get update

# Install requirements
apt-get install -y apache2 build-essential checkinstall php5 php5-cli php5-mcrypt php5-gd php-apc git sqlite php5-sqlite curl php5-curl php5-dev php-pear php5-xdebug vim-nox ruby rubygems sqlite3 libsqlite3-dev r-base nodejs npm python-dev libevent-dev python-pip

# Install MySQL
sudo debconf-set-selections <<< 'mysql-server-<version> mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server-<version> mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server

# If phpmyadmin does not exist, install it
if [ ! -f /etc/phpmyadmin/config.inc.php ];
then

    # Used debconf-get-selections to find out what questions will be asked
    # This command needs debconf-utils

    # Handy for debugging. clear answers phpmyadmin: echo PURGE | debconf-communicate phpmyadmin

    echo 'phpmyadmin phpmyadmin/dbconfig-install boolean false' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections

    echo 'phpmyadmin phpmyadmin/app-password-confirm password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/admin-pass password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/password-confirm password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/setup-password password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/database-type select mysql' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/app-pass password root' | debconf-set-selections
    
    echo 'dbconfig-common dbconfig-common/mysql/app-pass password root' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/mysql/app-pass password' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/password-confirm password root' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/app-password-confirm password root' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/app-password-confirm password root' | debconf-set-selections
    echo 'dbconfig-common dbconfig-common/password-confirm password root' | debconf-set-selections
    
    apt-get -y install phpmyadmin
fi


# Setup hosts file
VHOST=$(cat <<EOF
    <VirtualHost *:80>
            ServerAdmin webmaster@localhost

            DocumentRoot /var/www/webapp/
            Alias /webgrind /var/www/webgrind
            <Directory />
                    Options FollowSymLinks
                    AllowOverride All
            </Directory>
            <Directory /var/www/webapp/>
                    Options Indexes FollowSymLinks MultiViews
                    AllowOverride All
                    Order allow,deny
                    allow from all
            </Directory>
            DirectoryIndex index.php
            ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
            <Directory "/usr/lib/cgi-bin">
                    AllowOverride None
                    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                    Order allow,deny
                    Allow from all
            </Directory>
            Alias /xhprof "/usr/share/php/xhprof_html"
            <Directory "/usr/share/php/xhprof_html">
                Options FollowSymLinks
                AllowOverride All
                Order allow,deny
                allow from all
            </Directory>
    </VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/default

# Configure XDebug
XDEBUG=$(cat <<EOF
zend_extension=/usr/lib/php5/20100525/xdebug.so
xdebug.profiler_enable=1
xdebug.profiler_output_dir="/tmp"
xdebug.profiler_append=0
xdebug.profiler_output_name = "cachegrind.out.%t.%p"
EOF
)
echo "${XDEBUG}" > /etc/php5/conf.d/xdebug.ini

# Install webgrind if not already present
if [ ! -d /var/www/webgrind ];
then
    git clone https://github.com/jokkedk/webgrind.git /var/www/webgrind
fi

# Install XHProf
CONFIG=$(cat <<EOF
extension=xhprof.so
xhprof.output_dir="/var/tmp/xhprof"
EOF
)
echo "${CONFIG}" > /etc/php5/conf.d/xhprof.ini
if [ ! -d /usr/share/php/xhprof_html ];
then
    sudo pecl install xhprof-beta
fi

if [ ! -d /var/tmp/xhprof ];
then
    sudo mkdir /var/tmp/xhprof
    sudo chmod 777 /var/tmp/xhprof
fi

# Install Composer globally
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Enable mod_rewrite
sudo a2enmod rewrite

# Restart Apache
sudo service apache2 restart

# phantomjs
wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-i686.tar.bz2
tar xvjf phantomjs-1.9.7-linux-i686.tar.bz2
cd phantomjs-1.9.7-linux-i686
ln -sf "$(pwd)"/bin/phantomjs /usr/local/bin/phantomjs

# pip install
sudo pip install py_w3c==0.1.1
sudo pip install colorific==0.2.2
sudo pip install webcolors==1.4

# Create the database
# mysql -uroot -proot < /var/www/webapp/sql/setup.sql

# Install R packages
wget http://cran.r-project.org/src/contrib/CORElearn_0.9.43.tar.gz
wget http://cran.r-project.org/src/contrib/DEoptimR_1.0-1.tar.gz
wget http://cran.r-project.org/src/contrib/robustbase_0.91-1.tar.gz
wget http://cran.r-project.org/src/contrib/cvTools_0.3.2.tar.gz
wget http://cran.r-project.org/src/contrib/nnet_7.3-8.tar.gz
wget http://cran.r-project.org/src/contrib/rpart_4.1-8.tar.gz
wget http://cran.r-project.org/src/contrib/numDeriv_2012.9-1.tar.gz
wget http://cran.r-project.org/src/contrib/lava_1.2.6.tar.gz
wget http://cran.r-project.org/src/contrib/prodlim_1.4.5.tar.gz
wget http://cran.r-project.org/src/contrib/ipred_0.9-3.tar.gz
wget http://cran.r-project.org/src/contrib/e1071_1.6-4.tar.gz
wget http://cran.r-project.org/src/contrib/randomForest_4.6-10.tar.gz
wget http://cran.r-project.org/src/contrib/FNN_1.1.tar.gz
wget http://cran.r-project.org/src/contrib/kknn_1.2-5.tar.gz

sudo R CMD INSTALL CORElearn_0.9.43.tar.gz
sudo R CMD INSTALL DEoptimR_1.0-1.tar.gz
sudo R CMD INSTALL robustbase_0.91-1.tar.gz
sudo R CMD INSTALL cvTools_0.3.2.tar.gz
sudo R CMD INSTALL nnet_7.3-8.tar.gz
sudo R CMD INSTALL rpart_4.1-8.tar.gz
sudo R CMD INSTALL numDeriv_2012.9-1.tar.gz
sudo R CMD INSTALL lava_1.2.6.tar.gz
sudo R CMD INSTALL prodlim_1.4.5.tar.gz
sudo R CMD INSTALL ipred_0.9-3.tar.gz
sudo R CMD INSTALL e1071_1.6-4.tar.gz
sudo R CMD INSTALL randomForest_4.6-10.tar.gz
sudo R CMD INSTALL FNN_1.1.tar.gz
sudo R CMD INSTALL kknn_1.2-5.tar.gz