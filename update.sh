#!/bin/bash
#Cloud-Fortress Let's Encrypt Automation
#Authored by: Thomas Zakrajsek <tzakrajs@linux.com>

# Globals
SHARED_IP=24.130.214.172
LE_SERVER=https://acme-v01.api.letsencrypt.org/directory
#LE_SERVER=https://acme-staging.api.letsencrypt.org/directory
RUN_FILE=/var/run/cloud-fortress-lets-encrypt.run

# check to see if the vhost files have changed. if not, then exit
current_md5=$(tar -hcf - /etc/apache2/sites-enabled/ 2>/dev/null | md5sum)
if [[ ! -f $RUN_FILE ]]; then
  echo $current_md5 > $RUN_FILE
else
  if [[ "$(echo $current_md5)" == "$(cat $RUN_FILE)" ]]; then
      echo "No changes detected..."
      exit
  fi
  echo "Changes detected, updating SSL certificate!"
fi

# iterate through all vhost files, looking for ServerName and ServerAlias
# directives and add to list of domains to update
declare -a vhosts
declare -a domains
for vhost in $(find -L /etc/apache2/sites-enabled/ -mmin -2) $(find /etc/apache2/sites-enabled/ -mtime +30); do
  if [[ $vhost == "*le-ssl*" ]]; then
    continue
  fi
  domains=""
  for domain in $(grep -Ei '(ServerName|ServerAlias)' $vhost|awk '{print $2}'); do
    if [[ "`dig @8.8.8.8 +short +time=1 +tries=2 $domain|tail -1`" == "$SHARED_IP" ]]; then
      domains="$domains-d $domain "
    fi 
  done
  if [[ "$domains" == "" ]]; then
    continue
  fi
  /opt/letsencrypt/letsencrypt-auto --break-my-certs --server $LE_SERVER --renew-by-default --standalone --standalone-supported-challenges http-01 --http-01-port 9999 --email sysadmin@cloud-fortress.com --text --agree-tos $domains run --installer apache
  touch -h $vhost
done

post_install_md5=$(tar -hcf - /etc/apache2/sites-enabled/ 2>/dev/null | md5sum)
echo $post_install_md5 > $RUN_FILE
