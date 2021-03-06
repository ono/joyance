## Joyance

Joyance is a project at [London MMXII Hackathon](http://mmxiihack.org) which
mesures and visualizes people's joyance for a theme.

It uses [Datasift](http://datasift.com/) as data backend.

## Getting started

1. Sign up Datasift and Pusher<br/>
Both [Datasift](http://datasift.com/) and [Pusher](http://pusher.com/) has free traial plan which is enough to try this application.

2. Clone this project

3. Set up Rails app

        % bundle install
        % rake db:migrate

4. Set Datasift user ID and API key in environment variables

        % export DATASIFT_KEY=YOUR-API-KEY
        % export DATASIFT_USERNAME=YOUR-USER-NAME

5. Set Pusher app ID, key and secret in environment variables

        % export PUSHER_APP_ID=APP-ID
        % export PUSHER_KEY=KEY-ID
        % export PUSHER_SECRET=SECRET

6. Run script which counts up joyance

        % rails runner "Counter.count_up :olympics"
(You don't have to stop script to go to the next step)

7. Run server

        % rails s

## Access

* Stream (every minute total): http://127.0.0.1:3000/streams/olympics
* Stream (all time total): http://127.0.0.1:3000/streams/olympics/total
* List all streams (every minute total): http://127.0.0.1:3000/counters

All support json format. e.g. http://127.0.0.1:3000/streams/olympics.json

## Stream definition

You can add streams under [app/streams](https://github.com/ono/joyance/tree/master/app/streams).

Once you define a stream, you can count up the stream like below.

    > Counter.count_up :new_stream



