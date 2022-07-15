FROM ruby:3.1.2

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

COPY . /usr/src/app
RUN MAKE="--jobs=$(nproc)" bundle install --jobs=$(nproc)

EXPOSE 9292

ENTRYPOINT ["rackup", "--host", "0.0.0.0", "--port", "9292"]
