FROM node:20.10.0-alpine AS base
RUN apk add --no-cache bash
WORKDIR /app

FROM base AS install
RUN mkdir -p /temp/dev
COPY package*.json yarn.lock /temp/dev/
RUN cd /temp/dev && \
    apk add --no-cache python3 make g++ && \
    yarn config set cache-folder /app/.yarn && \
    yarn install --frozen-lockfile

FROM base AS build
COPY --from=install /temp/dev/node_modules ./node_modules
COPY . .
RUN yarn build

# FROM base AS sh
# COPY bot.sh /app/

FROM base AS release
COPY --from=build /app/dist /app/dist
COPY --from=build /app/node_modules /app/node_modules
# COPY --from=sh /app/bot.sh /app/
COPY package*.json /app/
CMD ["/bin/bash", "bot.sh"]
