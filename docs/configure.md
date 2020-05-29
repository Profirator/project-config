# FIWARE setup and configuration 

This is a step-by-step instruction on how to setup and configure the FIWARE proof-of-concept.

Expected audience are DevOps engineers with some FIWARE experience.
## Preface

It is very beneficial if you have access to a running and configured system, so you can reference some of the configuration. If this is not possible, it is possible to setup a system using these instructions, it just takes more care when replacing placeholders.

Expected audiance is devops engineers with some FIWARE experience.

### System requirements
Virtual machine with 4 cores, 4 GB of RAM and 40 GB disk. 

This guide is written for Ubuntu. However, setup is also tested with CentOS. 

A real, publicly reachable internet domain needs to be available, this setup, especially the certificates part, cannot be done on "localhost" domains.

### Placeholders in config files

To prevent secret leak to github, few placesholder tags are used: `<secret>` and `<pass>`
	
some URLs have the name of the city removed, like: https://apis.city.apinf.cloud when deciding what URLs to use, replace with what ever URI component needed.

## Install tools and configure system

Note: Using “sudo” as my login user don’t contain all the privileges, but it’s in sudo group

### Upgrade system

	sudo apt-get update
	sudo apt-get upgrade

### Install basic tools

	sudo apt-get install git

### Install Docker and Docker Compose

Follow these steps from [docker.com](https:/docs.docker.com/engine/install/ubuntu/#install-using-the-repository), using their official repository.

	sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common 
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo apt-key fingerprint 0EBFCD88
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io

After installation has completed, verify that the docker system service is running:

	sudo systemctl status docker

Start a hello-world container as another test:

    sudo docker run hello-world

### Install docker-compose

Follow these steps from [docker.com](https://docs.docker.com/compose/install/#install-compose-on-linux-systems):

	sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose

Validate installation:

	docker-compose version

### Docker swarm Mode

Current setup is designed to run on a single machine swarm. Swarm mode is used so it can be extended later to a true cluster setup.

Services are really just “containers in production”. So it takes some time for containers to be up. Use below command to enable swarm mode and make your current machine a swarm manager.

	sudo docker swarm init

Read more about orchestration with docker swarm mode on [docs.docker.com](https://docs.docker.com/engine/swarm/).

#### Troubleshooting docker swarm

If dockers are not able to connect, try to flush IP tables. 

	sudo iptables -t filter -F
	sudo iptables -t filter -X
	sudo systemctl restart docker

If you get an error that “the node is not a swarm manager”, you need to run `sudo docker swarm init` again.

### Open firewall (CHECK THAT)

Open ports 80(http) and 443(https) (depending on what firewall is used: ufw is Ubuntu default)

	sudo firewall-cmd --add-service=https
	
	sudo ufw allow http
	sudo ufw allow https

### vm.max_map_count

One of the subsystems (container “quantumleap_crate”, see below) needs a specific [`vm.max_map_count`](https://www.kernel.org/doc/Documentation/sysctl/vm.txt) to be able to run.

First check the current system setting:

	sysctl vm.max_map_count

If that is already `262144` or more, skip the following steps.

Otherwise, change the kernel setting 

Open the config file in an editor:

	sudo nano /etc/sysctl.d/10-opplafy.conf

Change or add this setting:

	vm.max_map_count=262144
	
Apply the setting:

	sudo sysctl -p /etc/sysctl.d/10-opplafy.conf

Check again if setting is now correct:

	sysctl vm.max_map_count

## Install and configure FIWARE

### Copy configuration

Clone the config from GitHub repository

	cd /opt
	sudo git clone https://github.com/Profirator/project-config.git
	
Copy configuration to a designated folder:

	sudo mkdir -p /opt/fiwarepoc
	sudo cp -r /opt/project-config/config/config /opt/fiwarepoc/
	sudo cp -r /opt/project-config/config/services /opt/fiwarepoc/

### Create directories

Create directories (used as bind mounts) required by each “yaml” file volume on host machine

	sudo mkdir -p /opt/mongo-data /opt/wirecloud-static /opt/wirecloud-data /opt/wirecloud-elasticsearch /opt/wirecloud-postgres /opt/quantumleap-crate /opt/quantumleap-redis /opt/keyrock-mysql /opt/umbrella-elasticsearch /opt/proxy-static

### Replacing URL in services folder

the YML files have urls that need to be correct for your environment. Please replace the URLs in these files before deploying the stack:

	services/ckan.yml
	services/keyrock.yml
	services/mail.yml
	services/tenant-manager.yml
	services/umbrella.yml
	services/wirecloud.yml
	
here is an example command how to run, if you do not want to do this manually:

	cd /opt/fiwarepoc
	find config/ -type f -exec sed -i 's/city\.apinf\.cloud/example\.com/g' {} +
	find services/ -type f -exec sed -i 's/city\.apinf\.cloud/example\.com/g' {} +

where you need to replace `example\.com` with your actual domain name.

### /etc/hosts configuration

Domains are defined in /etc/hosts, for example:

	127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4 	example.com accounts.example.com apis.example.com context.example.com market.example.com sthdata.example.com umbrella.example.com dashboards.example.com ngsiproxy.example.com example

You need to that example.com must be replaced through the actual domain intended to be used for the setup and you must actually modify the /etc/hosts file.

For this configuration to work, you need a public IP so that the Let's Encrypt scripts can run successfully. a wildcard record 

	*.example.com 
	
need to be pointing to the host / cluster gateway.

Add “CNAME” entries/aliases for all the subdomains you desire to work on in your DNS server.

### TLS certificates from letsencrypt

Add certificates for the domain “example.com” via letsencrypt certbot tool.

	sudo add-apt-repository ppa:certbot/certbot
	sudo apt-get update
	sudo apt-get install python-certbot-nginx

INSTALLATION:

Certificates neet to be created and updated via [certbot's manual method](https://certbot.eff.org/docs/using.html#manual):

	sudo certbot certonly --manual --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory --email xyz@test.com --manual-public-ip-logging-ok --agree-tos -d *.example.com

Please not that instead of xyz@test.com use a real email address.

Deploy a DNS TXT record provided by Let’s Encrypt certbot after running the above command = send this to DNS controller, this part:
![images/acme1.PNG](images/acme1.PNG)
 the _acme challenge and the hash. Wait 2 minutes and press enter.

if you get this, it’s fine:
	IMPORTANT NOTES:
 	- Congratulations! Your certificate and chain have been saved at:

RENEWAL:

	sudo docker service rm example_umbrella
	sudo certbot certonly --force-renew --manual --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory --email xyz@test.com --manual-public-ip-logging-ok --agree-tos -d *.example.com
	sudo vim services/umbrella.yml
	
Change certificate name under “secrets” section. OLD:-

	umbrella.crt:
		name: umbrella.crt-v9
	umbrella.key:
		name: umbrella.key-v9
		
NEW:-

	umbrella.crt:
		name: umbrella.crt-v10
	umbrella.key:
		name: umbrella.key-v10

This can be run in the scenario where all the other components are running. If you are doing this the 1st time, do not execute the following.

	sudo docker stack deploy -c services/umbrella.yml <stack>

### Deploy Services in Docker Swarm and Other Configurations

NOTE: Here, <stack_name> is the stack name. Secrets, passwords and urls have to be configured before stack deploy. example.com needs to be changed to the domain of your configuration. 

#### mongodb

No configuration changes required.

	sudo docker stack deploy -c services/mongo.yml <stack_name>
	
#### nginx

Besides the hostname manipulation, no further configuration changes are required.

	sudo docker stack deploy -c services/nginx.yml <stack_name>

#### ngsiproxy

No configuration changes required.

	sudo docker stack deploy -c services/ngsiproxy.yml <stack_name>

#### orion

No configuration changes required.

	sudo docker stack deploy -c services/orion.yml <stack_name>

#### quantumleap

No configuration changes required.

	sudo docker stack deploy -c services/quantumleap.yml <stack_name>

#### keyrock

Vanilla configuration in `config/keyrock.js` has some changes compared to the shipped configuration.

Most importantly, there are several sections containing credentials or keys marked with ```<secret>``` or similar placeholders, which need to be set according to the placeholders in `services/keyrock.yml`.

##### Key to encrypt user passwords

In `config/keyrock.js`, change

	config.password_encryption = {
		key: '<secret>'		// Must be changed
	}

##### Database info 

Database name, user and password must be entered at several locations:

In `services/keyrock.yml`, change

            - MYSQL_ROOT_PASSWORD=<pass>

and

            - DATABASE_PASS=<pass>
and

            - IDM_DB_PASS=<pass>

In `config/keyrock.js`, apply:

	// Database info
	config.database = {
		host: database_host,          
		password: '<pass>',             
		username: 'root',            
		database: 'idm',             
		dialect: 'mysql',            
	};

#### Email configuration

In `services/keyrock.yml`, change

            - SMTP_USER=<user>
            - SMTP_PASS=<pass>

In `config/keyrock.js`, add your SMTP host and port:

	// Email configuration
	config.mail = {
		host: '<emailhost>',
		port: 25,
		secure: false,
		auth: {
			user: smtp_user,
			pass: smtp_pass
		},
		from: smtp_user
	}

#### Additional custom additions

Compared to a vanilla keyrock configuration, some changes were made.

At the end of the file, before `module.exports`:

	// Enable usage control and configure the Policy Translation Point
	config.usage_control = {
	  enabled: to_boolean(process.env.IDM_USAGE_CONTROL_ENABLED, false),
	  ptp: {
	    host: (process.env.IDM_PTP_HOST || 	'localhost'),
	    port: (process.env.IDM_PTP_PORT || 8081),
	  }
	}

Change the default token validity period to desired value.

	//access_token_lifetime: 60 * 60,  // One hour
	access_token_lifetime: 60 * 60 * 60 * 146,  // Changed to one year by sumedh

	//token_lifetime: 60 * 60           // One hour
	token_lifetime: 60 * 60 * 60 * 146  // Changed to one year by sumedh

After making all changes, deploy the service to the docker stack:

	sudo docker stack deploy -c services/keyrock.yml <stack_name>

#### Umbrella

There has been updates to maxmind license that umbrella uses. Please see issue: https://github.com/Profirator/api-umbrella/issues/2

In `services/umbrella.yml`:

	MAXMIND_LICENSE_KEY

The path to the SSL-certificates must be correct.

After making all changes, deploy the service to the docker stack:

	sudo docker stack deploy -c services/umbrella.yml <stack_name>

### apinf

`services/apinf.yml`

Environment variable `SENTRY_DSN` must be set to a valid DSN from application monitoring provider sentry.io. If you do not have one, remove that line.

After making all changes, deploy the service to the docker stack:

	sudo docker stack deploy -c services/apinf.yml <stack_name>

### Configuration Changes in Umbrella

Signup at for a new user at https://umbrella.example.com/admin/ 

That first user will automatically become the admin of umbrella.

Then register website back-ends:

Configuration -> Website Backends -> Add Website Backend

	Frontend Host: accounts.example.com
	Backend Protocol: http
 	Backend Server: keyrock
 	Backend Port: 3000

 	Frontend Host: apis.example.com
 	Backend Protocol: http
 	Backend Server: apinf
 	Backend Port: 3000

 	Frontend Host: dashboards.example.com
 	Backend Protocol: http
 	Backend Server: wirecloudnginx
 	Backend Port: 80
  
	Frontend Host: example.com
	Backend Protocol: http
 	Backend Server: nginx
 	Backend Port: 80

 	Frontend Host: ngsiproxy.example.com
 	Backend Protocol: http
 	Backend Server: ngsiproxy
 	Backend Port: 3000

	Frontend Host: umbrella.example.com
 	Backend Protocol: http
 	Backend Server: nginx
 	Backend Port: 80

	Frontend Host: gis.example.com
 	Backend Protocol: http
 	Backend Server: leafletgis
 	Backend Port: 8181

	Frontend Host: charts.example.com
 	Backend Protocol: http
 	Backend Server: grafana
 	Backend Port: 3000

REMEMBER TO PUBLISH CHANGES in Umbrella.

### Configure “Oauth2 credentials” for “Wirecloud” and “API Catalog”

Here we Register application needed by API management and other components.

Login to keyrock and add applications for “Wirecloud” and then get its “Oauth2 credentials”

Note: example.com will be replaced by your desired domain name

1. Login credentials

username: admin@test.com password: <default pass> Change password immediately!

2. Register applications

Main menu - Applications - apps - Register

	
 example API Catalogue (Login)
 
 			Name: example API Catalogue
	 		Description: Catalogue of example APIs provided using APInf
 			URL: https://apis.example.com
	 		Callback URL: https://apis.example.com/_oauth/fiware
 			Signout URL: https://apis.example.com
	 		Add Roles: tenant-admin, data-provider, data-consumer
			Token Type – JSW, Permanent 
			Authorize Users: admin – assign roles - ALL
			
example Dashboards (Wirecloud)

 			Name: example Dashboards
 			Description: Dashboard portal for example
 			URL: https://dashboards.example.com
 			Callback URL: 	https://dashboards.example.com/complete/fiware/
	 		Add Roles: admin
			Authorize Users: admin - assign roles - ALL

example Market

			Name: example Market
			Description: Market service provided by the Business API Ecosystem
			URL: https://market.example.com
			Callback URL: 	https://market.example.com/auth/fiware/callback
			Add Roles: seller, customer, orgAdmin, admin
			Authorize users: admin – assign roles - ALL

Applications(after adding all applications): example API Catalogue, example Dashboards, example Market.

3. Establish a trus relationship between the applications.

Configure "Trusted applications" section in each of the previously made applications
In Applications section, you can click your application to change configurations.
In API Catalogue application settings, press Trusted applications '+ Add'
Find other applications by using Applications filter and press '+'.

After adding all the applications Press: SAVE

Repeat the process for all applications, so they all trust eachother.

4. OAuth2 credentials for Wirecloud

Go to keyrock - Applications - "example Dashboards" - OAuth2 Credentials

Note “Client ID” and “Client Secret”

Open wirecloud configuration file

	sudo vim services/wirecloud.yml
 		
Change “SOCIAL_AUTH_FIWARE_KEY” and “SOCIAL_AUTH_FIWARE_SECRET” to new “Client ID” and “Client Secret” respectively. 

Start wirecloud

	sudo docker stack deploy -c services/wirecloud.yml <stack_name>

Wirecloud configuration is not completed (out of scope of this documentation), so wirecloud may not start.

5. OAuth2 credentials for tenant-manager

All of the following needs to be changed in 

	sudo vim config/tenant-manager/credentials.json

Below `idm`, enter `user_id`, `user` and `password` of the user you created in step 1.

Go to keyrock -> Applications - "API Catalog" -> OAuth2 Credentials

Copy “Client ID” to `broker.client_id`

Go to keyrock -> Applications -> "example Market" -> OAuth2 Credentials

Copy “Client ID” to `bae.client_id`

Go to umbrella -> upper right corner -> My Account -> Admin API Access

Copy "Admin API Token" to `umbrella.token`

Got to umbrella -> Users -> API users -> Add new API user

Enter the email from step1, and tenant manager for the name.

Save, and copy the API Key to `umbrella.key`

Start tenant-manager

	sudo docker stack deploy -c services/tenant-manager.yml <stack_name>
	
	
### Add Proxies, Login Platforms and APIs in APInf Platform

Sign up to APInf platform at “apis.example.com” as 	“Admin”. If no user, first user signing up will be admin.
Enter username, email, password and Register

You’ll be signed in and will be admin

Go to settings...
 	
#### Proxy: Orion Context Broker
	
	Name: Orion Context Broker
 	Description: API umbrella installation for the Orion Context Broker service at example.
 	Type: apiUmbrella
 	URL: https://context.example.com
 	API Key: <umbrella API user API key>
 	Auth Token: <umbrella admin API access token>
 	ElasticSearch: http://elasticsearch.docker:9200

#### Proxy: Quantum Leap

	Name: Quantum Leap
 	Description: API umbrella installation for the Quantum Leap service at example.
 	Type: apiUmbrella
 	URL: https://sthdata.example.com
 	API Key: <umbrella API user API key>
 	Auth Token: <umbrella admin API access token>
 	ElasticSearch: http://elasticsearch.docker:9200
 	
#### Login Platform: FIWARE
	
	Client id: <client id> 	from “example API Catalogue” application
 	Secret: <client secret> from “example API Catalogue” application
 	Root url: https://accounts.example.com

	(No trailing slash here!)

#### Settings
	
- Only platform administrators are allowed to add new APIs
- Only platform administrators are allowed to add new Organizations

Mail – enabled

	Username: noreply@apis.example.com
	Password: <your_password>
 	SMTP Host: <mailserver url>
	SMTP Port: 587
 	
Email for sending mails: noreply@apis.example.com

Disabled login methods
		"Github" and "Hsl id"

Tenant Manager – enabled
 		Url and basepath: https://umbrella.example.com/tenant-manager/


#### APIs -> Add new API

Orion Context Broker

	API Name: Orion Context Broker
	Description: Context information provided using the FIWARE Orion Context Broker in right-time
 	API Host URL: http://orion.docker
 	Settings(General)
		API visibility: Public
		Network - Menu
 			Proxy: Orion Context Broker
	 		Proxy base path: /v2/
 			API base path: /v2/
	 		API Port: 1026
 			IDP App Id: <example API Catalogue – client_id>
	 		Rate limit mode: Unlimited requests

SAVE CONFIGURATION

Endpoints

	Provide API documentation via: URL
 	Link to API documentation: https://raw.githubusercontent.com/Fiware/specifications/master/OpenAPI/ngsiv2/ngsiv2-openapi.json
	Allow “GET” method only
	Monitoring
		Endpoint to monitor: :1026/version


#### APIs: Quantum Leap

	API Name: Quantum Leap
	Description: QuantumLeap is the first implementation of an API that supports the storage of NGSI FIWARE NGSIv2 data into a time-series database.
	API Host URL: http://quantumleap.docker
 	Settings
		API visibility: Public
	Network - Menu
 		Proxy: Quantum Leap
 		Proxy base path: /ql/
 		API base path: /
 		API Port: 8668
 		IDP App Id: <example API Catalogue – client_id>
 		Rate limit mode: Unlimited requests	

SAVE CONFIGURATION

 Endpoints
 
 	Provide API documentation via: URL
 	Link to API documentation: https://raw.githubusercontent.com/smartsdk/ngsi-timeseries-api/master/specification/quantumleap.yml
	Allow “GET” method only

	Monitoring
		Endpoint to monitor: :8668/v2/version
 	
#### Branding

Settings -> Branding -> About

Add appropriate Site title and select APIs from the list.
 
 	Site title: example
	Showcase APIs: “Quantum Leap” AND “Orion Context Broker”


### Change API backends in Umbrella

Visit https://umbrella.example.com/admin

Configuration -> API Backends -> find Orion backend config (added via API management in previous step)

#### Orion

Name: Orion Context Broker - see that the configuration matches

Server:

	Host: orion.docker
	Port: 1026
	Frontend Host: context.example.com
	Backend Host: context.example.com

URL Prefix

	Frontend Prefix: /v2/
	Backend Prefix: /v2/

Global Request Settings:

	Allow External Authorization
	IDP App ID: <client_id> of “API Catalog” IDM application
		Note:- login to Idm and get the API Catalog OAuth credentials. Client id from idm goes to “IDP App ID”
	Required Roles: orion-admin
	Rate Limit: Unlimited requests

Apply following Sub-URL Request Settings:
	
	Click on “Add URL Settings”
	GET – Regex: ^/v2/.* - Override required roles from "Global Request Settings"(Checkbox)<-NOTE! this should be added ONLY if we want an open system where anyone can get the information!
 	any – Regex: ^/v2/subscriptions – Override required roles from "Global Request Settings"(Checkbox)
	OPTIONS – Regex: ^/v2/.* - API Key Checks: Disabled – Override required roles from "Global Request Settings"(Checkbox)
	any – Regex: ^/v2/op/notify$ - API Key Checks: Disabled – Override required roles from "Global Request Settings"(Checkbox)
	any - Regex: ^/v2/op/update$ - Override required roles from "Global Request Settings"(Checkbox)
	POST - Regex: ^/v2/notify$ - Override required roles from "Global Request Settings"(Checkbox)
	DELETE - Regex: ^/v2/.* - Required Headers: fiware-delete: jOW@11hx7 - Override required roles from "Global Request Settings"(Checkbox)

NOTE the first setting (^/v2/.*) should be added ONLY if we want an open system where anyone can get the information. 

SAVE

#### QuantumLeap

Find QuantumLeap backend config - see that the configuration matches

Server

	Host: quantumleap.docker
	Port:8668
	Frontend Host: sthdata.example.com
	Backend Host: quantumleap.docker
	click “Add URL Prefix”
	Frontend Prefix: /ql/
	Backend Prefix: /

Add Global Request Settings:

	Allow External Authorization
	IDP App ID: <client_id> of “API Catalog” IDM application
		Note:- login to Idm and get the API Catalog OAuth credentials. Client id from idm goes to "IDP App ID”
	API Key Checks: Required – API keys are mandatory
 	Required Roles: orion-admin
	Rate Limit: Unlimited requests
 	Override Response Headers:
 		Access-Control-Allow-Origin: *
		Access-Control-Allow-Headers: Authorization, FIWAREService, FIWAREServicePath
		Access-Control-Allow-Credentials: true

Add Sub-URL Request Settings:

	Click on “Add URL Settings”
	GET – Regex: ^/v2/version$ - API Key Checks: Disabled – Override required roles from "Global Request Settings"
 	GET – Regex: ^/v2/.* 
	- Override required roles from "Global Request Settings" <-NOTE! this should be added ONLY if we want an open system where anyone can get the information!

SAVE

#### Tenant Manager

Name: Tenant Manager

Click “Add Server”

	Server: tenantmanager
	Port: 5000
	Frontend Host: umbrella.example.com
	Backend Host: umbrella.example.com
	Click “Add URL Prefix”
	Frontend Prefix: /tenant-manager/
	Backend Prefix: /

Global Request Settings:

	Allow External Authorization
 	IDP App ID: <client_id> of “example API Catalogue” IDM application
		Note:- login to Idm and get the API Catalog OAuth credentials. Client id from idm goes to “IDP App ID”
	Required Roles: tenant-admin
 	Rate Limit: Unlimited requests
 
Sub-URL Request Settings:

	Click “Add URL Settings”
	GET – Regex: ^/ 
	Override required roles from "Global Request Settings"

SAVE

#### Token Service

Name: Token Service

Click “Add Server”
	
	Server: keyrock
	Port: 3000
	Frontend Host: accounts.example.com
	Backend Host: keyrock

Click “Add URL Prefix”

	Frontend Prefix: /oauth2/password
	Backend Prefix: /oauth2/token

Global Request Settings:

	API Key Checks: Disabled
 	Rate Limit: Unlimited requests

SAVE

Go to https://umbrella.example.com/admin/#/config/publish
   
PUBLISH

CHANGE PASSWORD FOR USER ADMIN IN “IDM” - https://accounts.lubeck.apinf.cloud/
			OR
ADD NEW ADMIN USER AND DISABLE ADMIN IF IT HAS WEAK PASSWORD


### Mail server configuration - after mailgun changes

IF YOU HAVE YOUR OWN MAIL-SERVER - SEE BELOW MAILGUN INSTRUCTION

Mailgun:
Swaks is an smtp of CURL, install it first

	sudo curl http://www.jetmore.org/john/code/swaks/files/swaks-20130209.0/swaks -o swaks


Set the permissions for the script so you can run it
sudo chmod +x swaks


It's based on perl, so install perl

	sudo apt-get -y install perl


Now SEND
	sudo ./swaks --auth --server smtp.mailgun.org --au postmaster@YOUR_DOMAIN_NAME --ap as3kh9umujora5 --to bar@example.com --h-Subject: "Hello" --body 'Testing some Mailgun awesomness!'


Grab your SMTP credentials: 

SMTP hostname: smtp.eu.mailgun.org
	Port: 587 (recommended)
	Username: postmaster@example.com
	Default password: <pass>

Make changes in keyrock.yml & ckan.yml & API Platform mail settings

Make changes in keyrock.js in “config.mail”

	#host: ‘mail’,
	host: ‘smtp.eu.mailgun.org’,

and deploy changed settings:

	sudo docker stack deploy -c services/keyrock.yml example

With your own mail-server you only need to make changes into the configuration files: 
services/keyrock.yml

	SMTP_USER=your@email.user
	SMTP_PASS=YourEmailPassword
	services/ckan.yml
	#Email Settings
	- CKAN_SMTP_SERVER=your.email.server
	- CKAN_SMTP_USER=your@email.user
	- CKAN_SMTP_PASSWORD=YourEmailPassword
	- CKAN_SMTP_MAIL_FROM=your@email.user

config	/keyrock.js (replace 587 if your port is different!)

	config.mail = {
    host: 'your.email.server',
    port: 587,

These configuration changes might need the stack to be re-deployed. Replace YourStackName with your stacks name.

Remove stack:

	sudo docker stack rm YourStackName

Re-deploy stack (from repository folder):
	sudo docker stack deploy  -c services/tenant-manager.yml -c services/wirecloud.yml  YourStackName

	sudo docker stack deploy -c services/mongo.yml -c services/nginx.yml -c services/ngsiproxy.yml -c services/orion.yml -c services/quantumleap.yml -c services/keyrock.yml -c services/umbrella.yml -c services/apinf.yml YourStackName

### Apache Nifi deployment:

	sudo docker stack deploy -c services/nifi.yml
	
### Basic map visualisation deployment:

	sudo docker stack deploy -c services/leafletgis.yml

### Grafana

Create a data folder on the host:

	mkdir -p /opt/grafana

Change the initial admin password in `services/grafana.yml`

	environment:
       - GF_SECURITY_ADMIN_PASSWORD=<pass>

Start the service:

	sudo docker stack deploy -c services/grafana.yml

Go to the login page and log in with admin and password as above:

	https://charts.example.com

Change the password and profile data.	

### Known issues:

Quantum Leap has SQL injection vulnerability: https://github.com/smartsdk/ngsi-timeseries-api/issues/295

Let's encrypt may be blacklisting instant AWS domains.

Account user names cannot have dots and special characters: https://github.com/Profirator/Profi-platform/issues/2

When adding the Endpoints documentation, you need to add it twice.

### Smoke tests:
TBD
