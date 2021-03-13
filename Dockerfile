FROM ubuntu:latest

RUN apt update
RUN apt -y upgrade
RUN apt -y install build-essential libpcre3 libpcre3-dev libssl-dev wget zlib1g-dev

RUN cd /tmp && \
  wget https://nginx.org/download/nginx-1.18.0.tar.gz && \
  tar zxf nginx-1.18.0.tar.gz && \
  rm nginx-1.18.0.tar.gz

RUN cd /tmp && \
  wget https://github.com/arut/nginx-rtmp-module/archive/v1.2.1.tar.gz && \
  tar zxf v1.2.1.tar.gz && rm v1.2.1.tar.gz

RUN cd /tmp/nginx-1.18.0 && \
  ./configure \
  --prefix=/usr/local/nginx \
  --add-module=/tmp/nginx-rtmp-module-1.2.1 \
  --conf-path=/etc/nginx/nginx.conf \
  --with-threads \
  --with-file-aio \
  --with-http_ssl_module \
  --with-debug \
  --with-cc-opt="-Wimplicit-fallthrough=0" && \
  cd /tmp/nginx-1.18.0 && make && make install
RUN cp /tmp/nginx-rtmp-module-1.2.1/stat.xsl /usr/local/nginx/html/
RUN rm -rf /tmp/*

  # Set default ports.
ENV HTTP_PORT 80
ENV HTTPS_PORT 443
ENV RTMP_PORT 1935

#COPY --from=build-nginx /usr/local/nginx /usr/local/nginx
#COPY --from=build-nginx /etc/nginx /etc/nginx

# Add NGINX path, config and static files.
ENV PATH "${PATH}:/usr/local/nginx/sbin"
ADD nginx.conf /etc/nginx/nginx.conf
ADD live.html /usr/local/nginx/html
RUN mkdir -p /opt/data && mkdir /www
# ADD static /www/static

EXPOSE 1935
EXPOSE 80

#CMD envsubst "$(env | sed -e 's/=.*//' -e 's/^/\$/g')" < \
#  /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && \
CMD nginx -g 'daemon off;'
