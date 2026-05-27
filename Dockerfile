FROM nginx:alpine
COPY iac-bicep-terraform.html /usr/share/nginx/html/
COPY aks-kubectl-cheatsheet.html  /usr/share/nginx/html/
COPY index.html /usr/share/nginx/html/
RUN chmod -R 755 /usr/share/nginx/html \
    && chown -R nginx:nginx /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
