FROM node:10-alpine

WORKDIR /wiki

COPY . .
ENV PORT=80

RUN npm i

ENTRYPOINT [ "npm", "start" ]