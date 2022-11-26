FROM public.ecr.aws/lambda/ruby:2.7

WORKDIR WORKDIR /var/task

RUN yum update -y
RUN yum install -y amazon-linux-extras
RUN amazon-linux-extras install postgresql13
RUN yum install -y git postgresql-devel libidn-devel libicu-devel zlib-devel openssl-devel libyaml-devel ca-certificates shared-mime-info ruby-devel make gcc gcc-c++ which

COPY Gemfile* ./
RUN     bundle config set --local without 'development test' && \
        bundle config set silence_root_warning true && \
        bundle install -j"$(nproc)"

RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash -
RUN curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo
RUN yum install -y nodejs yarn

# TODO: multi-stage build to remove build bloat from image

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    RAILS_SERVE_STATIC_FILES="true" \
    BIND="0.0.0.0"

COPY . .

# Precompile assets
RUN OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder bundle exec rails assets:precompile

#CMD ["app.handler"]
