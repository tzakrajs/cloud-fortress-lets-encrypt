## Cloud-Fortress Let's Encrypt Automation
* Writted by Thomas Zakrajsek

### What?
* A bash script that checks for Apache Vhost changes and generates Let's Encrypt virtualhosts with certificates and keys
  * Assumes one virtual host per config file in /etc/apache2/sites-enabled
  * Regenerates certificates for virtualhost files older than 30 days
  * Certificates generated are SAN certs that includes ServerName and ServerAlias FQDNs
    * All FQDNs must point to the IP address of this server or the update will fail
    * Automatically touches the vhost after updating the certificate preclude it from regeneration
* Includes daemontools supervise run script that executes the bash script every 10 seconds
  * This means that within 10 seconds of creating or editing a virtualhost, you will get an updated certificate
  * A new virtualhost file will be created in /etc/apache2/sites-available
    * Will be symlinked to /etc/apache2/sites-enabled
    * Will be suffixed with "-le-ssl.conf"
    * Apache will be restarted
### Why?
* Makes creating SSL virtualhosts even easier!
* Great for multiuser environments!

### Install
* Extract files into /opt/cloud-fortress-lets-encrypt
* Install daemontools-supervise
* Execute `nohup supervise /opt/cloud-fortress-lets-encrypt/ &`

### Support
* Open an issue on GitHub if you have any problems: https://github.com/tzakrajs/cloud-fortress-lets-encrypt
