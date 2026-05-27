FROM nginx:alpine
COPY iac-bicep-terraform.html /usr/share/nginx/html/
COPY aks-kubectl-cheatsheet.html  /usr/share/nginx/html/
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
