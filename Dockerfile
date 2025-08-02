ARG NODE_VERSION=22.14.0
ARG NGINX_VERSION=alpine3.21

FROM node:${NODE_VERSION}-alpine AS build
WORKDIR /app
COPY package.json package-lock.json .
RUN --mount=type=cache,target=/root/.npm npm ci
COPY . .
RUN npm run build


FROM nginxinc/nginx-unprivileged:${NGINX_VERSION} AS final
USER nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY --chown=nginx:nginx --from=build /app/dist /usr/share/nginx/html
EXPOSE 8080
ENTRYPOINT ["nginx", "-c", "/etc/nginx/nginx.conf"]
CMD ["-g", "daemon off;"]