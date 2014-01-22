#!/bin/bash
if [ "$(whoami)" != 'root' ]; then
        echo "Execute this script as a root user"  
        # if you want to exit immediately, then uncomment this line, and comment the next one
        # exit 1;  
        # this line requires a root password.
        sudo -v
fi 

vhost-h() {
cat <<"HELP"
Usage: vhost [OPTIONS] <name>
	-h|--help	shows help text
	-pub		to create the webhost root in ~/www/name/public/
	-url 		to specify a local address, default is http://name.local		
	-rm 		to remove a previously created vhost, see examples
	-d 		    to specify the webroot directory location, default is in ~/www (NO TRAILING SLASH)
	-email 		to specify the email of the administrator in the virtual host file
	-l 			to list the current virtual hosts
  
Examples:
vhost -ls        						shows lists of available sites & enabled sites
vhost -rm laravel.loc        			disables laravel.loc virtual host; removes laravel.loc.conf file from /apache2/sites-available; removes laravel.loc entry from /etc/hosts
vhost -d ~/sites/mysite/myroot -url dev.mysite.dev mysite 	this will create a new apache2 vhost named mysite with a webroot of ~/sites/mysite/myroot reachable at http://dev.mysite.dev
vhost -rm mysite.local mysite 				this will remove the apache2 vhost named mysite and remove the mysite.local entry from the /etc/hosts file. Be sure to specify boths
HELP
exit 0
}

http-restart() {
	echo "Would you like to restart the server [y/n]?"
	read answer
	if [[ "${answer}" == "yes" ]] || [[ "${answer}" == "y" ]]; then
	        # Restart apache
	        sudo service apache2 restart
	        echo "The server has been successfully restarted!"
	fi	
	exit 0;
}

vhost-ls() 
{
	echo "Available virtual hosts:"
	ls /etc/apache2/sites-available/

	echo -e "\n Enabled virtual hosts:"
	ls /etc/apache2/sites-enabled/
	exit 0
}

# Delete vhost file and it's entry in /etc/hosts
vhost-rm() {  
	echo "Disabling $servername virtual host."
	sudo a2dissite $servername

	echo "Removing $servername virtual host."
	sudo rm "/etc/apache2/sites-available/${servername}.conf"

	echo "Removing $servername from /etc/hosts."
	sudo sudo sed -i '/'$servername'/d' /etc/hosts	

	# restarting the server
	http-restart;
	exit 0
}

 
while [ $1 ]; do
    case "$1" in
    	'-h'|'--help') vhost-h;;
    	'-l') vhost-ls;; 
        '-rm') servername="$2"
			   vhost-rm;;  
        '-url') url="$2";; 
    esac
    shift
done
 
# Change to whatever Dir you want
dir='/home/rawan/public_html/'  
publicdir='/www'

servername=$1

# read -p "Enter the server name(without www) :" servername 

hostdir=$dir$servername
fulldir=$dir$servername$publicdir


if ! mkdir -p $fulldir; then
        echo "Directory is already exist!"
else
        echo "Directory successfully created!"
fi
chmod -R '755' $hostdir

cp /etc/apache2/sites-available/000-default.conf "/etc/apache2/sites-available/${servername}.conf"
 
echo "<VirtualHost *:80>
        DocumentRoot /home/rawan/public_html/${servername}/${publicdir}
        ServerName www.${servername}.loc
        <Directory /home/rawan/public_html/${servername}/${publicdir}>
                Options +Indexes +FollowSymLinks +MultiViews +Includes
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>
</VirtualHost>"  >      "/etc/apache2/sites-available/${servername}.conf"

# Adding entry to the hosts file
echo 127.0.0.1 $servername >> /etc/hosts

# Apache 2 enable site
sudo a2ensite $servername

echo "That's it! Now, you've got a new virtual host. Make the web easy!"

http-restart;