#!/usr/bin/python
#if you need to debug your script, uncomment multiline comments
import sys
''' this is for debug
import logging
'''
from pyzabbix import ZabbixAPI
'''this is for debug
stream = logging.StreamHandler(sys.stdout)
stream.setLevel(logging.DEBUG)
log = logging.getLogger('pyzabbix')
log.addHandler(stream)
log.setLevel(logging.DEBUG)
'''
host=sys.argv[1]
macroname="{$"+ sys.argv[2]+"}"
macrovalue=sys.argv[3]
zbxurl=sys.argv[4]
apiusr=sys.argv[5]
apipass=sys.argv[6]
zabbix = ZabbixAPI(zbxurl, user=apiusr, password=apipass)
zabbix.session.verify = False
hid=zabbix.host.get(search={'host': host})[0]['hostid']
macros=zabbix.usermacro.get(hostids=hid, output=['value'], filter={'macro':macroname})
if len(macros)==0:
        zabbix.usermacro.create(hostid=hid,macro=macroname,value=macrovalue)
else:
        zabbix.usermacro.update(hostmacroid=macros[0]['hostmacroid'],value=macrovalue)
