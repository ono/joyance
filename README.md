## Joyce

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

        % rails c
        > Counter.count_up :olympics
You don't have to stop script to go to step 4.

4. Access via http

        % rails s
Then access `http://127.0.0.1:3000/counters` or `http://127.0.0.1:3000/counters.json`.

## Stream definition

You can add streams under [app/definitions](https://github.com/ono/joyance/tree/master/app/definitions).

Once you define a stream, you can count up the stream like below.

        > Counter.count_up :new_stream



