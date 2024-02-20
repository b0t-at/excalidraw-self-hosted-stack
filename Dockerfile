FROM node:21-alpine AS download
WORKDIR /opt/node_app

RUN wget https://github.com/excalidraw/excalidraw/archive/refs/tags/v0.17.3.tar.gz -O excalidraw.tar.gz
RUN tar -zvxf excalidraw.tar.gz
RUN mv excalidraw-* excalidraw

FROM node:21-alpine AS build

ARG PUB_SRV_NAME
ARG PUB_SRV_NAME_WS
ARG VITE_APP_BACKEND_V2_GET_URL
ARG VITE_APP_BACKEND_V2_POST_URL
ARG VITE_APP_WS_SERVER_URL

ENV VITE_APP_BACKEND_V2_GET_URL=${VITE_APP_BACKEND_V2_GET_URL}
ENV VITE_APP_BACKEND_V2_POST_URL=${VITE_APP_BACKEND_V2_POST_URL}
ENV VITE_APP_WS_SERVER_URL=${VITE_APP_WS_SERVER_URL}

WORKDIR /opt/node_app

COPY --from=download /opt/node_app/excalidraw/package.json /opt/node_app/excalidraw/yarn.lock ./
RUN yarn --ignore-optional --network-timeout 600000

COPY --from=download /opt/node_app/excalidraw/ .
RUN yarn build:app:docker

FROM nginx:1.25.4-alpine

COPY --from=build /opt/node_app/build /usr/share/nginx/html

HEALTHCHECK CMD wget -q -O /dev/null http://localhost || exit 1
