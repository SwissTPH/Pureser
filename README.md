# Pureser


![Swift 5.4](https://img.shields.io/badge/swift-5.4-red.svg?style=flat)


Welcome to Pureser, a fast and flexible parser for survey form files *(ODK XLSForm .xlsx files)*, written in Swift. 

Pureser can be used to convert these files into HTML, making them printable.

These HTML file can be opened in your favourite modern browser and can be printed directly from there or saved to a PDF file *(using the modern browser's PDF renderer)*.


--------------------
## How to use?

1. As a web app that you **run locally** (and offline) **with docker compose**. [Jump there.](#1-run-locally-with-docker-compose)

2. As a web app that you **deploy to server**. [Jump there.](#2-deploy-to-server)

3. As a web app that you **run locally** (and offline) **with Xcode**. [Jump there.](#3-run-locally-with-xcode)

##
#### 1. Run locally with docker compose

Prerequisites:

- Docker \
Download [Docker Desktop](https://www.docker.com/products/docker-desktop), if you don't already have it.

Steps:

1. Go to Pureser folder, e.g.: \
`$ cd Desktop/path/to/Pureser/`

2. Make sure Docker is running. \
If not, open Docker and have it running.

3. Build with docker compose, run: \
`$ docker-compose -p pureser build -q` \
from the root directory of your app's project (the folder containing docker-compose.yml). \
This may take several minutes.

4. Start up the app: \
`$ docker-compose up --detach app` \
Your app is going to start up "detached" (i.e. in the background).

5. *(Optional)* To verify that the app is running, run: \
`$ docker ps` \
This prints a list of running containers.

6. To run migrations, execute: \
`$ docker-compose up migrate`

7. Pureser is running now. \
Go to http://127.0.0.1:8080 or http://0.0.0.0:8080 in your browser to use or test it.

8. When you're done, to shut down these containers, run: \
`$ docker-compose down` \
Or, to stop & wipe database: \
`$ docker-compose down -v`

More details:

- [Vapor Docs - Docker Deploys - Docker Compose File](https://docs.vapor.codes/4.0/deploy/docker/#docker-compose-file)

##
#### 2. Deploy to server

The web app is built on [Vapor, a web framework for Swift](https://vapor.codes). \
So Pureser can be deployed to server the same as any Vapor web app.

##### Deploy to server without docker:

- [Vapor Docs - Deploying to DigitalOcean](https://docs.vapor.codes/4.0/deploy/digital-ocean/)
- [Vapor Docs - Deploying to Heroku](https://docs.vapor.codes/4.0/deploy/heroku/)

##### Deploy to server with docker:

- [Vapor Docs - Docker Deploys](https://docs.vapor.codes/4.0/deploy/docker/)

##
#### 3. Run locally with Xcode

1. Set up a PostgreSQL server 12.2 or later. \
You will need a database and a connection URL.

2. Add *your PostgreSQL connection URL* as an environment variable, \
Set name to "`POSTGRESQL_URL`" and value to *`your PostgreSQL connection URL`*.

3. Make sure the selected scheme is "Pureser > My Mac".

4. Run Pureser from Xcode (menu > Product > Run). \
Wait for server to start.

5. Pureser is running now. \
Go to http://127.0.0.1:8080 or http://0.0.0.0:8080 in your browser to use or test it.

6. When you're done, stop Pureser from Xcode (menu > Product > Stop). \
Note that the database won't be wiped, if you want to wipe database, you have to do that manually.


--------------------

Hope you'll enjoy using **Pureser**!
