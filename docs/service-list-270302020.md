```
ID                  NAME                             MODE                REPLICAS            IMAGE                                PORTS
3wsr5m3hdoa7        lubeck_apinf                     replicated          1/1                 apinf/platform:latest
bg6i079xc0n7        lubeck_grafana                   replicated          1/1                 grafana/grafana:latest
jxnpyeicdgiv        lubeck_keyrock                   replicated          1/1                 fiware/idm:latest
vlx1p9hftgpp        lubeck_keyrock_mysql             replicated          1/1                 mysql:5.7
lt3lypv7cwql        lubeck_leafletgis                replicated          1/1                 profiville/lubeck:leafletgis
0elaqbt1gj8z        lubeck_mongo                     replicated          1/1                 mongo:3.6
zlcoc2nu7hwv        lubeck_nginx                     replicated          1/1                 nginx:latest                         *:80->80/tcp
49l6nlxd16op        lubeck_ngsiproxy                 replicated          1/1                 fiware/ngsiproxy:1.1
ns13x2tz5kqr        lubeck_nifi                      replicated          1/1                 apache/nifi:1.10.0
erxdzw0kntk1        lubeck_orion                     replicated          1/1                 fiware/orion:2.3.0
1shx8fywou9z        lubeck_quantumleap               replicated          1/1                 smartsdk/quantumleap:0.7.5
w00ok5d56wry        lubeck_quantumleap_redis         replicated          1/1                 redis:latest
whjvpzd9i2dx        lubeck_quantumleapcrate          replicated          1/1                 crate:2.3
pbsxe0wyguka        lubeck_tenantmanager             replicated          1/1                 profirator/tenant-manager:latest
a5kapk6qrkqi        lubeck_umbrella                  replicated          1/1                 profirator/api-umbrella:pre-0.15.3   *:443->443/tcp
swe0whee1ion        lubeck_umbrella_elasticsearch    replicated          1/1                 elasticsearch:2.4
rqrm2hdl6lfh        lubeck_wirecloud                 replicated          1/1                 fiware/wirecloud:latest
as3a7apjin1u        lubeck_wirecloud_elasticsearch   replicated          1/1                 elasticsearch:2.4
o2g8b6664pud        lubeck_wirecloud_memcached       replicated          1/1                 memcached:1
c1imgcdy1qxz        lubeck_wirecloud_postgres        replicated          1/1                 postgres:9.6
ycgr77btuiar        lubeck_wirecloudnginx            replicated          1/1                 nginx:latest
moszbuyq3v3c        lubeck_zookeeper                 replicated          1/1                 bitnami/zookeeper:latest
```
