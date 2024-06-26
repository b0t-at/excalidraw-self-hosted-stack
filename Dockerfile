FROM node:21-alpine AS download
WORKDIR /opt/node_app

RUN wget https://github.com/excalidraw/excalidraw/archive/refs/tags/v0.17.6.tar.gz -O excalidraw.tar.gz
RUN tar -zvxf excalidraw.tar.gz
RUN mv excalidraw-* excalidraw

FROM node:21-alpine AS build

ARG PUB_SRV_NAME=draw.b0t.at
ARG PUB_SRV_NAME_WS=ws.draw.b0t.at
ARG VITE_APP_BACKEND_V2_GET_URL=https://draw.b0t.at/api/v2/scenes/
ARG VITE_APP_BACKEND_V2_POST_URL=https://draw.b0t.at/api/v2/scenes/
ARG VITE_APP_WS_SERVER_URL=https://ws.draw.b0t.at/
ARG VITE_APP_AI_BACKEND=https://ai.draw.b0t.at/

ENV PUB_SRV_NAME=${PUB_SRV_NAME}
ENV PUB_SRV_NAME_WS=${PUB_SRV_NAME_WS}
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
