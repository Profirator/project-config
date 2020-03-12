## placeholder for master documentation

### Preface
This basic is documentation of FIWARE based PoC setup for the city of Lübeck. Basic documentation is:
Overview of structure, functionality and basic usage.
Basic documentation is not:
- Complete tutorial on every feature of the FIWARE components.
- Debugging reference.

The FIWARE PoC for the city of Lübeck is:
- Proof of Concept on how the FIWARE and other open source components work together.
The FIWARE PoC for the city of Lübeck is not:
- Production ready
- High available


### Overall Architecture / structure

The following components are deployed:

- Orion Context broker for real time data
- Quantum leap for historical data
- Apache Nifi
- Identity manager
- Grafana for data visualizations
- API management
- API proxy
- Basic map Visualization
- API Catalogue and Tenant Management
- Open Data Portal (CKAN)
- Wirecloud Portal

More information on the components can be found on [FIWARE catalog page](https://www.fiware.org/developers/catalogue/), and on their respective sites (Apache Nifi and Grafana). Basic map visualisation is developed from scratch for this project.

### UML Diagram

### Onboarding users / new user creation

Platform / API access:

sign up at https://accounts.lubeck.apinf.cloud/ (you need to confirm email address)

sign in at https://apis.lubeck.apinf.cloud/ using FIWARE login

the NGSI V2 API is exposed at https://context.lubeck.apinf.cloud/v2/

and

https://sthdata.lubeck.apinf.cloud/ql/ for historical data

Accesses for data can be handlied by using Oauth Bearer tokens. Once you have logged in, you can fetch a token from platfrom:

### Component descriptions:

Tenant-manager

How to is covered in: https://apinf-fiware.readthedocs.io/en/latest/#tenant-manager-ui

Grafana

Access via https://charts.lubeck.apinf.cloud/ the admin access is secured by password, which is in the grafana.yml TBD handle via github secrets. Otherwise, Grafana usage is standard; connect database:

and configure the charts you need.

Basic map Visualisation:

Landing page: https://gis.lubeck.apinf.cloud/ holds two sub pages, one for static data and another one with Weather observed and ParkingSpot. Source code is in github: https://github.com/Profirator/lubeck

### Niota connection

### Connecting new datasources

### Options for High Availability

### Options for Restoring system state after failure

### Security
