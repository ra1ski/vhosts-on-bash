#!/bin/bash
#
# By Rawanski [ra1almaty[-at-]gmail.com]
# www.rawanski.com
# 
#
# $dir           - Directory, where all your sites are placed. Change to whatever Dir you want
# $publicdir - Public directory of your site, the only folder that is accessable via browser
# $hostdir   - Full path to host directory
# $fulldir       - Full path to public directory
# 

vhost-h() {
cat <<"HELP"
Usage: vhost [OPTIONS] <name>
        -h|--help       shows help text         
        -l                      shows lists of available sites & enabled sites
        -rm             removes specified vhost  
  
Examples:
vhost laravel.loc                                               creates laravel.loc vhost: folder; /etc/hosts entry; sites-available & sites-enabled entry
vhost -l                                                        shows lists of available sites & enabled sites
vhost -rm laravel.loc                           disables laravel.loc virtual host; removes laravel.loc.conf file from /apache2/sites-available; removes laravel.loc entry from /etc/hosts
HELP
exit 0
}

http-restart() {
        as-root;

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
        as-root;
        echo "Available virtual hosts:"
        ls /etc/apache2/sites-available/

        echo -e "\n Enabled virtual hosts:"
        ls /etc/apache2/sites-enabled/
        exit 0
}

# Delete vhost file and it's entry in /etc/hosts
vhost-rm() {  
        as-root;

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

as-root() {
        sudo -v
        # if [ "$(whoami)" != 'root' ]; then
        #         echo "Execute this script as a root user"   
        #         exit 0;  
        #         # this line requires a root password.
        #         # sudo -v
        # fi    
}

 
# Cases 
case "$1" in
        '-h'|'--help') vhost-h;;
        '-l') vhost-ls;; 
    '-rm') servername="$2"
                   vhost-rm;;   
esac
 
# Change to whatever Dir you want
dir='/home/rawan/public_html/'  
publicdir='/www'

# set servername
servername=$1 

hostdir=$dir$servername
fulldir=$dir$servername$publicdir

as-root;
 
if ! mkdir -p $fulldir; then
        echo "Directory already exists!"
else
        echo "Directory is successfully created!"
fi
chmod -R '755' $hostdir

sudo cp /etc/apache2/sites-available/000-default.conf "/etc/apache2/sites-available/${servername}.conf"
 
sudo sh -c "echo '<VirtualHost *:80>
        DocumentRoot /home/rawan/public_html/${servername}/${publicdir}
        ServerName www.${servername}.loc
        <Directory /home/rawan/public_html/${servername}/${publicdir}>
                Options +Indexes +FollowSymLinks +MultiViews +Includes
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>
</VirtualHost>'  >      '/etc/apache2/sites-available/${servername}.conf'"

# Adding entry to the hosts file
sudo sh -c "echo '127.0.0.1 $servername' >> '/etc/hosts'"

# Apache 2 enable site
sudo a2ensite $servername

echo "That's it! Now, you've got a new virtual host. Make the web easy!"

http-restart;