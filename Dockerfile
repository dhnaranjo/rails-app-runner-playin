# Cribb'd from: https://lipanski.com/posts/dockerfile-ruby-best-practices
FROM public.ecr.aws/g0f8a3x6/ruby:2.7.2-alpine3.13 AS base

RUN apk add --update \
  postgresql-dev \
  tzdata \
  nodejs \
  yarn

FROM base AS dependencies

RUN apk add --update build-base

COPY Gemfile Gemfile.lock ./

RUN bundle config set without "development test" && \
  bundle install --jobs=3 --retry=3

COPY package.json yarn.lock ./

RUN yarn install --frozen-lockfile

FROM base

RUN adduser -D app

USER app

WORKDIR /home/app

COPY --from=dependencies /usr/local/bundle /usr/local/bundle

COPY --chown=app --from=dependencies /node_modules/ node_modules/

COPY --chown=app . ./

# Dumb hack to avoid reinstalling node_modules: https://github.com/rails/webpacker/issues/405#issuecomment-332522148
RUN rm bin/yarn
RUN RAILS_ENV=production SECRET_KEY_BASE=assets bundle exec rake assets:precompile

CMD ["bundle", "exec", "rackup"]
