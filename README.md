# zabbix_intel_rst_template
## Description
This template is for discovering and monitoring Intel RST (Intel VROC) storage controllers. Works with zabbix 4.2 and higher. Template uses
action with zabbix API.

## Main features

* Discovering of correct version of utility, depending on driver version
* Discovering of logical and physical disks
* Comfortable changing of time intervals, regular expression for triggers by macroses
* Only one request of data for all (discovering and etc).

## Installation

### Zabbix server

* Import template
* Set your values of macroses in template
* Create user for creating {$IRST_CLI} macros. It contains correct version of utility. This user must have access to change settings of
servers, monitoring by this template
* Install pyzabbix module for you default python version (Something like pip install pyzabbix)
* Copy updatehostmacro.py script to your zabbix external script folder
* Than you have to create macroses (i use global) for login and password of this user. Create macros for zabbix server URL.For example: {$ZBX_API_WRITER_USER}, {$ZBX_API_WRITER_PASSWORD}, {$ZBX_URL}. Zabbix url macros must equal something like that: http://zabbix_server_address/zabbix
* Create action with name like "Change IRST cli version macros on host" and condition "Value of tag SOURCE equals Intel RST path"

![action name and condition](https://github.com/mykolq/zabbix_intel_rst_template/blob/master/screenshots/2020-05-18_16-59-40.png?raw=true)

* Add step for execution updatehostmacro.py script

![action name and condition](https://github.com/mykolq/zabbix_intel_rst_template/blob/master/screenshots/execute_script.png?raw=true)






