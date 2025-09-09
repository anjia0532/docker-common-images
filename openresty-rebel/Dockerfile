FROM openresty/openresty:alpine-fat

#ADD lib /usr/local/openresty/site/lualib
#ADD default.conf /etc/nginx/conf.d/default.conf
ADD nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
RUN opm get anjia0532/lua-rebel-license-server
