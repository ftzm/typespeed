from nginx

COPY main.js /usr/share/nginx/html/
COPY main.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY texts.json /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
