FROM node:18.18.1

WORKDIR /wiki

COPY . .
ENV PORT=80

RUN npm i

ENTRYPOINT [ "npm", "start" ]
