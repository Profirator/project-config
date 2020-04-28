These instructions are to be used with Ubuntu. Docker needs to be installed.

1)	Download zip file from https://bitbucket.org/geowerkstatt-hamburg/masterportal/src/dev/doc/setup.md
2)	Unzip to a folder ”content”
3)	Create a Dockerfile which pulls from nginx, and copies the content of the unzipped folder to it. A simple way to copy the files is to create a Dockerfile to generate a new Docker image, based on the NGINX image from Docker Hub. When copying files in the Dockerfile, the path to the local directory is relative to the build context where the Dockerfile is located. The content is in the content directory, in the same directory as the Dockerfile. The NGINX image has the default NGINX configuration files. Dockerfile context:

FROM nginx
COPY content /usr/share/nginx/html

4)	Build the docker. You can then create an NGINX image by running the following command from the directory where the Dockerfile is located:
docker build -t mynginximage1 .
5)	

Note the period (“.”) at the end of the command. This tells Docker that the build context is the current directory. The build context contains the Dockerfile and the directories to be copied. Now we can create a container using the image by running the command:
docker run --name mynginx -P -d mynginximage1

6) use it in suitable way, depending on the deployment.
