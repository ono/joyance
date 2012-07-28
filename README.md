## Joyance

Joyance is a project at [London MMXII Hackathon](http://mmxiihack.org) which
mesures and visualizes people's joyance for a theme.

It uses [Datasift](http://datasift.com/) as data backend.

## Getting started

1. Clone this project

2. Set up Rails app

        % bundle install
        % rake db:migrate

3. Set Datasift use ID and API key in environment variables

        % export DATASIFT_KEY=YOUR-API-KEY
        % export DATASIFT_USERNAME=YOUR-USER-NAME

3. Run script which counts up joyance

        % rails runner "Counter.count_up :olympics"

You don't have to stop script to go to step 4.

4. Run server

        % rails s

## Access

* Stream (every minute total): http://127.0.0.1:3000/stream/olympics
* Stream (all time total): http://127.0.0.1:3000/stream/olympics/total
* List all streams (every minute total): http://127.0.0.1:3000/counters

All support json format. e.g. http://127.0.0.1:3000/stream/olympics.json

## Stream definition

You can add streams under [app/streams](https://github.com/ono/joyance/tree/master/app/streams).

Once you define a stream, you can count up the stream like below.

    > Counter.count_up :new_stream



