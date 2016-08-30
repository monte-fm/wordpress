#Create container
```
docker run -it -d --name=wordpress -h=wordpress -p 1000:80 -p 1001:22 cristo/wordpress:php7 /bin/bash
```

#MySQL
```
user: root 
password: root
db_name: wordpress
```
#SSH
```
ssh -p1001 root@localhost
password: root
```
#NGINX server config file for communicate with docker

```
server {
        listen *:80;
        server_name localhost;
        proxy_set_header Host localhost;
        client_max_body_size 100M;

                location / {
                                proxy_set_header Host $host;
                                proxy_set_header X-Real_IP $remote_addr;
                                proxy_cache off;
                                proxy_pass http://localhost:1000;
                        }
}
```

#Origin
[Docker Hub] (https://registry.hub.docker.com/u/cristo/wordpress/)

[Git Hub] (https://github.com/monte-fm/wordpress)
