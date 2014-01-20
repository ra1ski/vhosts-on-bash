#!/bin/bash
#
# $dir 		 - directory, where all your sites are placed
# $publicdir - public directory of your site, the only folder that is accessable via browser
# $hostdir   - full path to host directory
# $fulldir	 - full path to public directory
# 

dir='/home/rawan/public_html/' 
publicdir='/www'

if [ "$(whoami)" != 'root' ]; then
echo "Execute this script as a root user"
exit 1;
fi

read -p "Enter the server name(without www) :" servername 

hostdir=$dir$servername
fulldir=$dir$servername$publicdir


if ! mkdir -p $fulldir; then
echo "Directory is already exist!"
else
echo "Directory successfully created!"
fi
chmod -R '755' $hostdir

cp /etc/apache2/sites-available/000-default.conf "/etc/apache2/sites-available/${servername}.conf"

chmod '777' "/etc/apache2/sites-available/${servername}.conf" 
echo "<VirtualHost *:80>
        DocumentRoot /home/rawan/public_html/${servername}/www
        ServerName www.${servername}.loc
        <Directory /home/rawan/public_html/${servername}/www>
                Options +Indexes +FollowSymLinks +MultiViews +Includes
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>
</VirtualHost>"  >	"/etc/apache2/sites-available/${servername}.conf"

# Adding entry to the hosts file
echo 127.0.0.1 $servername >> /etc/hosts

# Apache 2 enable site
a2ensite $servername

echo "That's it! Now, you've got a new virtual host. Make the web easy!"

echo "Would you like to restart the server [y/n]?"
read answer
if [[ "${answer}" == "yes" ]] || [[ "${answer}" == "y" ]]; then
	# Restart apache
	service apache2 restart
	echo "The server has been successfully restarted!"
fi
 
