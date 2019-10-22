#! /bin/bash

# @author: ajfernandez
# @last_edit: 22/10/19
# @Create Nginx & PHP-FPM .conf files from a tailored template

site_name=$1

checkFolder () {
    folder_site=$1
    if [ -d $folder_site ];
        then
            return
    else
        echo -e "The folder $1 doesn't exists, does the site you want to configure really exist?.\n"
        exit
    fi
}

checkUser () {
    user=$1
    #getent passwd | cut -d: -f1,7
    getent passwd $user
    if [ $? -eq 0 ];
        then
            echo -e "Site user owner already exist, has the site already been customized?\n"
            exit
    else
        echo -e "Adding user and group: \"$user\" to system.\n"
    fi
}

createUser () {
   user=$1
   useradd -r -s /sbin/nologin $user
}

createNginxConfig () {
    site_name=$1
    cat /etc/nginx/conf.d/template.conf__  > /etc/nginx/conf.d/$site_name.conf
    sed -i 's/{HOSTING}/'"$site_name"'/g' /etc/nginx/conf.d/$site_name.conf
    if [ $? -ne 0  ];
        then
            echo -e "Something went wrong with template or config file.\n Check /etc/nginx/conf.d folder.\n"
            exit
    else
        echo -e "Nginx tailored config file created successfully.\n"
    fi
}

createFpmConfig () {
    site_name=$1
    cat /etc/php-fpm.d/template.conf__  > /etc/php-fpm.d/$site_name.conf
    sed -i 's/{HOSTING}/'"$site_name"'/g' /etc/php-fpm.d/$site_name.conf
    if [ $? -ne 0  ];
        then
            echo -e "Something went wrong with template or config file.\\n Check /etc/php-fpm.d folder.\n"
            exit
    else
        echo -e "PHP-FPM tailored config file created successfully.\n"
    fi
}


# MAIN ------------------------------------

checkFolder $site_name

checkUser $site_name

createUser $site_name

createNginxConfig $site_name

createFpmConfig $site_name

# systemctl reload php-fpm;systemctl reload nginx
