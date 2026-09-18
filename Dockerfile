FROM node:24.21-alpine

RUN mkdir -p /code
WORKDIR /code

COPY . /code

RUN yarn install && yarn cache clean
RUN yarn build

CMD ["yarn","start"]

EXPOSE 8080
