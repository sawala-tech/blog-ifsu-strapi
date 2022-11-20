FROM node:16.13-buster
WORKDIR /app
COPY ./package.json ./yarn.lock ./
RUN yarn install
ENV NODE_ENV=production
COPY . .
RUN cd ./src/extensions/users-permissions && yarn install --frozen-lockfile
RUN yarn build && yarn cache clean
EXPOSE 1337
CMD ["yarn", "start"]
