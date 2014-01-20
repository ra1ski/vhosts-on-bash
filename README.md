# About
With this script you can:
- create virtual hosts on Apache2 http-server.
- list avaiable and enabled hosts
- remove vhosts

# Options

```
vhost [OPTIONS] <name>
	-h|--help	shows help text 	
	-l 			shows lists of available sites & enabled sites
	-rm 		removes specified vhost  
```

#Usage

```
vhost laravel.loc				creates laravel.loc vhost: folder; /etc/hosts entry; sites-available & sites-enabled entry
vhost -l        				shows lists of available sites & enabled sites
vhost -rm laravel.loc   disables laravel.loc virtual host; removes laravel.loc.conf file from /apache2/sites-available; removes laravel.loc entry from /etc/hosts
```

#Variables

```
$dir 		   - Directory, where all your sites are placed. Change to whatever Dir you want
$publicdir - Public directory of your site, the only folder that is accessable via browser
$hostdir   - Full path to host directory
$fulldir	 - Full path to public directory
```