#! /bin/bash

site_name=$1

checkFolder () {
    folder_site=$1
    if [[ -d $folder_site ]];
        then
            return
    else
        echo -e "The folder $1 doesn't exists, does the site you want to configure really exist?.\n"
        exit
    fi
}

checkUser () {
    user=$1
    getent passwd $user
    if [[ $? -eq 0 ]];
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
    cat /etc/nginx/conf.d/template.conf__  > /etc/nginx/conf.d/$site_name.conf__testscript
    sed -i 's/{HOSTING}/'"$site_name"'/g' /etc/nginx/conf.d/$site_name.conf__testscript
    if [[ $? -ne 0 ]];
        then
            echo -e "Something went wrong with template or config file.\n Check /etc/nginx/conf.d folder.\n"
            exit
    else
        echo -e "Nginx tailored config file created successfully.\n"
    fi
}

createFpmConfig () {
    site_name=$1
    cat /etc/php-fpm.d/template.conf__  > /etc/php-fpm.d/$site_name.conf__testscript
    sed -i 's/{HOSTING}/'"$site_name"'/g' /etc/php-fpm.d/$site_name.conf__testscript
    if [[ $? -ne 0  ]];
        then
            echo -e "Something went wrong with template or config file.\\n Check /etc/php-fpm.d folder.\n"
            exit
    else
        echo -e "PHP-FPM tailored config file created successfully.\n"
    fi
}

nginxSyntaxValidator () {
    site_name=$1
    regex=successful$
    #result=`nginx -t -c /etc/nginx/conf.d/$site_name 2>&1`
    result=`nginx -t -c /etc/nginx/nginx.conf 2>&1`
    if [[ $result =~ $regex ]];
        then
            echo -e "Nginx syntax successfully verified.\n"
    else
        echo -e "Some errors have been found:\n${result}"
    fi
}

phpSyntaxValidator () {
    site_name=$1
    regex=successful$
    regex_err="(?i)(\W|^)(Unable)(\s)(to)(\s)(include)(\W|$)"
    result=`php-fpm -t`
    if [[ $result =~ $regex ]];
        then
            echo -e "PHP-FPM syntax successfully verified.\n"
    else
        bad_lines=`echo "$result" | grep $regex_err`
        echo -e "Some errors have been found:\n$bad_lines"
    fi
}


# MAIN ------------------------------------

#checkFolder $site_name

#checkUser $site_name

#createUser $site_name

#createNginxConfig $site_name

#createFpmConfig $site_name

#nginxSyntaxValidator $site_name

phpSyntaxValidator $site_name


# systemctl reload php-fpm;systemctl reload nginx
