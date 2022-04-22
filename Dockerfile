FROM node:16 as migration

WORKDIR /app

COPY package.json .
COPY package-lock.json .

RUN npm i -D db-migrate db-migrate-mysql

COPY /migrations ./migrations
COPY database.json .

RUN git clone https://github.com/vishnubob/wait-for-it.git

FROM node:16 as development

WORKDIR /app

COPY package.json .
COPY package-lock.json .

RUN npm install

COPY . ./

RUN npm run gen-env
RUN npm run build
# RUN git clone https://github.com/vishnubob/wait-for-it.git
COPY --from=migration /app/wait-for-it ./wait-for-it


FROM node:16 as production

WORKDIR /app

COPY package.json .
COPY package-lock.json .
COPY .env.production .env
COPY .env.example .

RUN npm ci --only=production

COPY --from=development /app/dist ./dist
COPY --from=development /app/wait-for-it ./wait-for-it

CMD ["node", "dist/index.js"]