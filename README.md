
cloudflash
==========

CloudFlash is a web framework for cloud based automation of openvpn, dhcp,firmware, modules, and services.

CloudFlash supports JSON data serialization format. The format for both the request and the response
should be specified by using the Content-Type header, the Accept header.

Steps to Install
===============
1) Download cloudflash files into your system
2) Run the follwing commands in cloudflash directory
   - npm install 
   - sudo coffee cloudflash.coffee

Note: During new service post, deb package uses npm to fetch the published package

*List of APIs*
==============

<table>
  <tr>
    <th>Verb</th><th>URI</th><th>Description</th>
  </tr>
  <tr>
    <td>GET</td><td>/services</td><td>List summary of services installed in VCG identified by service ID</td>
  </tr>
  <tr>
    <td>POST</td><td>/services</td><td>Create a new service in VCG</td>
  </tr>
  <tr>
    <td>GET</td><td>/services/service-id</td><td>Describes an installed service in VCG by service ID</td>
  </tr>
  <tr>
    <td>DELETE</td><td>/services/service-id</td><td>Delete an installed service in VCG by service ID</td>
  </tr>
  <tr>
    <td>POST</td><td>/services/service-id/action</td><td>Execute command on the VCG</td>
  </tr>

</table>


*URI structure*

For now there is no API version specified in either URI or JSON data. But, in future we plan to use
API version in the URI.

For example

      /services/V1.0/service family/service type


*Authentication*

Current implementation of cloudflash in VCG does not require that each request will include the credntials of
the user submiting the request.
Plan is to have OAuth scheme of authentication.

*Services API*
==============

 List Services
--------------

    Verb   URI       Description
    GET	/services	Lists summary of services configured in VCG identified by service ID.


Note: The request does not require a message body.
Success: Returns JSON data with list of services installed on VCG. Each service is identified by service ID

The service ID is generated is a UUID.

Service Family is the generic service type while name is the actual service name.

pkgurl: The package download link provided to VCG

api: Supported APIs for this service.

*Note: Currently no validation of the package contents done*

*TODO: Caller to provide md5sum of the package along with pkgurl*


**Example Request and Response**

*Request*

    GET /services

*Response*

```
{
    "services": 
    [
        {
            "id": "40860f06-7dcf-41ab-a414-98957b092b7b",
            "status": "installed"
            "api": "/dhcp",
			"description": {
				 "name": "udhcpd",
            	 "family": "dhcp",
			     "version": "1.0",
            	 "pkgurl": "http://my-url.com/udhcpd-0.0.1.deb"
			}
        }
    ]
}
```

Create Service
---------------


    Verb	URI	        Description
    POST	/services	Create a new service in VCG.


The request **must** have the following parameters in JSON data

      1. service version
      2. service Name
      3. Service Family
      4. Package URL

On success it returns JSON data with the UUID for the service created.

**Example Request and Response**

### Request JSON

    {
    	"name": "udhcpd",
    	"family": "dhcp",
    	"version": "1.0",
    	"pkgurl": "http://my-url.com/udhcpd-0.0.1.deb"
    }


### Response JSON

    {
        "id": "61df014d-90cd-4f6f-8928-0a3aadff4658",
        "description": {
            "version": "1.0",
            "name": "udhcpd",
            "family": "dhcp",
            "pkgurl": "http://10.1.10.145/udhcpd-0.0.1.deb",
            "id": "48c8d63e-1a3e-4f99-bf2b-a8c5c57afe8d"
        },
        "api": "/to/be/defined/in/future",
        "status": {
            "installed": true
        }
    }

Describe Service
----------------

    Verb	   URI	                     Description
    GET	    /services/service-id	  Show a service in VCG specified by service-ID

**Example Request and Response**

### Request Headers

    GET /services/d40d38bd-aab0-4430-ac61-4b8ee91dc668

### Response JSON

    {
        "id": "492e025d-2ae7-49e6-b27d-441ba3784ce3",
        "description": {
            "version": "1.0",
            "name": "udhcpd",
            "family": "dhcp",
            "pkgurl": "http://10.1.10.145/udhcpd-0.0.1.deb",
            "id": "7aeeb1a6-88ae-401b-95b6-c5d059b77db0"
        },
        "status": {
            "installed": true,
            "initialized": false,
            "enabled": false,
            "running": false,
            "result": "/home/plee/hack.node/cloudflash\n"
        }
    }

Delete a service
----------------

    Verb	  URI	                    Description
    DELETE	/services/service-id	  Delete a service in VCG specified by service-ID


On Success returns 200 with JSON data

*TODO: Return appropriate error code and description in case of failure.*

**Example Request and Response**

### Request Headers

    DELETE /services/d40d38bd-aab0-4430-ac61-4b8ee91dc668

### Response JSON

    { deleted: true }


Action Command API
------------------
This API is used to perform the action like start, stop, restart and sync on the installed services as identified by service-id


    Verb	URI	                          Description
    POST	/services/service-id/action	  Execute an action command

**Example Request and Response**

### Request Headers

    POST /services/a12796b8-c786-4351-ba7d-4b95cd8e0797/action

### Request JSON

    { command: "stop" }

### Response JSON

    { result: true }


*DHCP API*
=============

Post DHCP subnet Configuration
-------------------------------

    Verb	URI	      		         Description
    POST	/network/dhcp/subnet	 Update the dhcp udhcpd.conf file in VCG.

On success it returns JSON data with the service-id, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
           "start": "192.168.0.20",
           "end": "192.168.0.254",
           "interface": "eth0",
           "max_leases": 254,
           "remaining": "yes",
           "auto_time": 7200,
           "decline_time": 3600,
           "conflict_time": 3600,
           "offer_time": 60,
           "min_lease": 60,
           "lease_file": "/var/lib/misc/udhcpd.leases",
           "pidfile": "/var/run/udhcpd.pid",
           "notify_file": "dumpleases",
           "siaddr": "192.168.0.22",
           "sname": "zorak",
           "boot_file": "/var/lib/misc/udhcpd.leases",
           "option": ["subnet 192.168.0.25",
                      "timezone IST"]     
    }

### Response JSON


	{ "result": "success" }


Upon error, error code 500 will be returned


Post DHCP router Configuration
-------------------------------

    Verb    URI	   		          Description
    POST	/network/dhcp/router	 Update the dhcp udhcpd.conf file in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
      "optionparam": "router",
      "address": [
        "192.10.0.40",
        "192.10.0.41"
       ]
    }

### Response JSON


	{ "result": "success" }


Upon error, error code 500 will be returned


Post DHCP time server  Configuration
-------------------------------------

    Verb    URI        		      Description
    POST	/network/dhcp/timesvr	 Update the dhcp udhcpd.conf file in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
      "optionparam": "timesvr",
      "address": [
        "192.10.0.40",
        "192.10.0.41"
       ]
    }

### Response JSON


	{ "result": "success" }


Upon error, error code 500 will be returned



Post DHCP name server Configuration
-----------------------------------

    Verb    URI        		      Description
    POST	/network/dhcp/namesvr	 Update the dhcp udhcpd.conf file in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
      "optionparam": "namesvr",
      "address": [
        "192.10.0.40",
        "192.10.0.41"
       ]
    }

### Response JSON


	{ "result": "success" }


Upon error, error code 500 will be returned



Post DHCP dns Configuration
----------------------------

    Verb    URI      		         Description
    POST	/network/dhcp/dns  	      Update the dhcp udhcpd.conf file in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
      "optionparam": "dns",
      "address": [
        "192.10.0.40",
        "192.10.0.41"
       ]
    }

### Response JSON


	{ "result": "success" }


Upon error, error code 500 will be returned


Post DHCP log server Configuration
-----------------------------------

    Verb    URI        		      Description
    POST	/network/dhcp/logsvr	 Update the dhcp udhcpd.conf file in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
      "optionparam": "logsvr",
      "address": [
        "192.10.0.40",
        "192.10.0.41"
       ]
    }

### Response JSON


	{ "result": "success" }


Upon error, error code 500 will be returned


Post DHCP cookie server Configuration
--------------------------------------

    Verb    URI        		      Description
    POST	/network/dhcp/cookiesvr	 Update the dhcp udhcpd.conf file in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
      "optionparam": "cookiesvr",
      "address": [
        "192.10.0.40",
        "192.10.0.41"
       ]
    }

### Response JSON


	{ "result": "success" }


Upon error, error code 500 will be returned


Post DHCP lpr server Configuration
--------------------------------------

    Verb    URI          	        Description
    POST	/network/dhcp/lprsvr	 Update the dhcp udhcpd.conf file in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
      "optionparam": "lprsvr",
      "address": [
        "192.10.0.40",
        "192.10.0.41"
       ]
    }

### Response JSON


	{ "result": "success" }


Upon error, error code 500 will be returned


Post DHCP ntp server Configuration
--------------------------------------

    Verb    URI          	        Description
    POST	/network/dhcp/ntpsrv	 Update the dhcp udhcpd.conf file in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
      "optionparam": "ntpsrv",
      "address": [
        "192.10.0.40",
        "192.10.0.41"
       ]
    }

### Response JSON


	{ "result": "success" }


Upon error, error code 500 will be returned

Post DHCP wins server Configuration
------------------------------------

    Verb    URI          	    Description
    POST	/network/dhcp/wins	 Update the dhcp udhcpd.conf file in VCG.

On success it returns JSON data with the service-id, service-name, config success.

*TODO: Define JSON format for error codes and description.*

**Example Request and Response**

### Request Headers


### Request JSON

    {
      "optionparam": "wins",
      "address": [
        "192.10.0.40",
        "192.10.0.41"
       ]
    }

### Response JSON


	{ "result": "success" }


Upon error, error code 500 will be returned




Delete subnet config from DHCP configuration
---------------------------------------------

    Verb	URI	                           Description
    DELETE  /network/dhcp/subnet/:id 	  Delete subnet config from udhcpd.conf file


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/subnet/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }
    

Delete router config from DHCP configuration
---------------------------------------------

    Verb    URI	                        Description
    DELETE  /network/dhcp/router/:id 	  Delete router config from udhcpd.conf file


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/router/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }


Delete time server config from DHCP configuration
--------------------------------------------------

    Verb    URI	                         Description
    DELETE  /network/dhcp/timesvr/:id 	  Delete time server config from udhcpd.conf file


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/timesvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }



Delete name server config from DHCP configuration
--------------------------------------------------

    Verb    URI	                         Description
    DELETE  /network/dhcp/namesvr/:id 	  Delete name server config from udhcpd.conf file


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/namesvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }



Delete dns config from DHCP configuration
------------------------------------------

    Verb    URI	                     Description
    DELETE  /network/dhcp/dns/:id 	  Delete dns config from udhcpd.conf file


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/dns/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }


Delete log server config from DHCP configuration
-------------------------------------------------

    Verb    URI	                        Description
    DELETE  /network/dhcp/logsvr/:id 	  Delete log server config from udhcpd.conf file


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/logsvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }



Delete cookie server config from DHCP configuration
----------------------------------------------------

    Verb    URI	                           Description
    DELETE  /network/dhcp/cookiesvr/:id 	  Delete cookie server config from udhcpd.conf file


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/cookiesvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }



Delete lpr server config from DHCP configuration
-------------------------------------------------

    Verb    URI	                        Description
    DELETE  /network/dhcp/lprsvr/:id 	  Delete lpr server config from udhcpd.conf file


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/lprsvr/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }


Delete ntp server config from DHCP configuration
-------------------------------------------------

    Verb    URI	                        Description
    DELETE  /network/dhcp/ntpsrv/:id 	  Delete ntp server config from udhcpd.conf file


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/ntpsrv/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }


Delete wins config from DHCP configuration
-------------------------------------------

    Verb    URI	                      Description
    DELETE  /network/dhcp/wins/:id 	  Delete win server config from udhcpd.conf file


On Success returns 200 with JSON data

**Example Request and Response**

### Request Headers

    DELETE  /network/dhcp/wins/85108146-6233-42d9-8f1c-2c8fca63f236
    
### Response JSON

    { "deleted": "success" }





Describe DHCP 
--------------

    Verb	   URI	                 Description
    GET	    /network/dhcp/:id	  Show DHCP config info in VCG specified by service-ID

**Example Request and Response**

### Request Headers

    GET /network/dhcp/2da8f435-42c1-45d2-9fad-04fdf7298c80

### Response JSON

    {
            "key":"2da8f435-42c1-45d2-9fad-04fdf7298c80",
            "val":
              {
                   "start":"192.168.0.20",
                    "end":"192.168.0.254",
                    "interface":"eth0",
                    "max_leases":254,
                    "remaining":"yes",
                    "auto_time":7200,
                    "decline_time":3600,
                    "conflict_time":3600,
                    "offer_time":60,
                    "min_lease":60,
                    "lease_file":"/var/lib/misc/udhcpd.leases",
                    "pidfile":"/var/run/udhcpd.pid",
                    "notify_file":"dumpleases",
                    "siaddr":"192.168.0.22",
                    "sname":"zorak",
                    "boot_file":"/var/lib/misc/udhcpd.leases",
                    "option":
                    [
                      "subnet 192.168.0.25",
                      "timezone IST"
                    ]
                }
    }
    

Please note that the top-level `id` returned above refers to the service-ID.

Upon error, error code 500 will be returned


