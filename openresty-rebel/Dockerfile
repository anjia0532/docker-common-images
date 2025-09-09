FROM openresty/openresty:alpine-fat

#ADD openresty-rebel/lib /usr/local/openresty/site/lualib
#ADD openresty-rebel/default.conf /etc/nginx/conf.d/default.conf
ADD openresty-rebel/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
RUN opm get anjia0532/lua-rebel-license-server
