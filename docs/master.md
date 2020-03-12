## placeholder for master documentation

DRAFT DRAFT DRAFT DRAFT DRAFT DRAFT DRAFT DRAFT DRAFT DRAFT DRAFT DRAFT

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
- Open Data Portal (CKAN)
- Wirecloud Portal

High level architecture:
![Architecture](images/Archtecture2.png)

More information on the components can be found on [FIWARE catalog page](https://www.fiware.org/developers/catalogue/), and on their respective sites (Apache Nifi and Grafana). Basic map visualisation is developed from scratch for this project.

### UML Diagram
TBD

### Onboarding users / new user creation

Sign up at https://accounts.lubeck.apinf.cloud/ (you need to confirm email address)

Sign in at https://apis.lubeck.apinf.cloud/ using FIWARE login

The NGSI V2 API is exposed at https://context.lubeck.apinf.cloud/v2/ and

https://sthdata.lubeck.apinf.cloud/ql/ for historical data

Accesses for data can be handled by using Oauth Bearer tokens. Once you have signed in, you can fetch a token from platform:

![images/oauthtoken.PNG](images/oauthtoken.PNG)

This will allow you to access all the tenants on the Context Broker you have access to. Please see [documentation](https://apinf-fiware.readthedocs.io/en/latest/#tenant-manager-ui) on how to add tenants.

### Component overview and documentation:

Tenant-manager

How to is covered in: [Tenant-manager documentation](https://apinf-fiware.readthedocs.io/en/latest/#tenant-manager-ui)

Grafana

Access via https://charts.lubeck.apinf.cloud/ the admin access is secured by password, which is in the grafana.yml TBD handle via github secrets. Otherwise, Grafana usage is standard; connect database:

and configure the charts you need.

Basic map Visualisation

Landing page: https://gis.lubeck.apinf.cloud/ holds two sub pages, one for static data and another one with Weather observed and ParkingSpot. Source code is in github: https://github.com/Profirator/lubeck

Orion Context broker for real time data and Quantum leap for historical data. Are accessed via NGSI v2 API. Their respective documentation can be found [here](https://fiware-orion.rtfd.io/) and [here](https://github.com/smartsdk/ngsi-timeseries-api/).

Apache Nifi
End users shall not access / use Apache Nifi.

Identity manager

Identity manager (keyrock) is configured and needed for initial user account creation. More documentation [here](https://fiware-idm.readthedocs.io/en/latest/)

API management 
Usage in relevant parts are described in this documentation. More information can be found [here](https://github.com/apinf/platform)

API proxy
End users shall not access API-umbrella. 
Is based on the NREL/Api-umbrella. NREL documentation is [here](https://api-umbrella.readthedocs.io/en/latest/)

Open Data Portal (CKAN) 
Is installed, but not configured. Documentation can be found [here](https://fiware-ckan-extensions.rtfd.io/)

Wirecloud Portal
Is installed, but not configured. Documentation can be found [here](https://wirecloud.rtfd.io/)

### Niota connection

### Connecting new datasources

### Options for High Availability

### Options for Restoring system state after failure

### Security
