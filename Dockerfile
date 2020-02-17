# Base image
FROM nginx:stable

# Copy leaflet-folder to image
COPY leaflet/ /usr/share/nginx/html

# Copy the configuration file
COPY default.conf /etc/nginx/conf.d/

# Optionally chown the files 
#RUN chown -R www-data:www-data /usr/share/nginx/html

# Expose ports
EXPOSE 8181
