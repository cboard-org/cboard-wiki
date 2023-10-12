/* Title: How to deploy to Production */

## Deployment Commands

By having `cboard-bootstrap` we can just deploy Cboard entirely by having docker installed and running some commands.

#### Pull Bootstrap
```
$ docker pull cboard/cboard-bootstrap
```

The above command will pull the bootstrap image needed to deploy and run Cboard.

#### Deploy and Run Cboard
```
$ docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --env-file /home/sharedFolder/env.prod \
    cboard/cboard-bootstrap \
    up -d
```

The above command will run a new instance of `cboard/cboard-bootstrap` docker image with the `up -d` command.

The parameter `-v /var/run/docker.sock:/var/run/docker.sock` is needed just to share the same docker engine (host and cboard-bootstrap instance).

If the deploy is for QA, the `--env-file /home/sharedFolder/env.prod` parameter should be replaced with `--env-file /home/sharedFolder/env.qa`.

#### Update a Service

In order to update a service (any of the images), there are some steps we need to do just to pull new images and run a service again.
```
$ docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    cboard/cboard-bootstrap \
    pull
```

The above command will pull updates for the images (from Docker Hub). In order to update a running service it will be needed to execute the Deploy and Run Cboard command again and it will be done automatically by docker-compose.


#### Update Bootstrap

In some cases we might need to update `cboard-bootstrap` image, like updating docker-compose definition. If that's the case we need to stop all the services, pull a new cboard-bootstrap image, and deploy and run Cboard again.
```
$ docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    cboard/cboard-bootstrap \
    down
```

The above command will stop and kill the entire application. This should be done before pulling a new image.

---

### Deployment Cases

#### Update a single service (not all the application)

Taking into account that we want to update the frontend service (`cboard`), we need to follow these steps:

1. `$ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock cboard/cboard-bootstrap pull`
2. `$ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock cboard/cboard-bootstrap stop cboard`
3. `$ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock cboard/cboard-bootstrap kill cboard`
4. `$ docker run --rm -v /var/run/docker.sock:/var/run/docker.sock cboard/cboard-bootstrap up -d --no-deps cboard`

We need to pull new images for the services (`1`), then we need to stop and kill `cboard` service from `cboard-bootstrap` (`2` and `3`) and finally we just need to put up the new image for the service (`4`) without dependencies (`--no-deps`).

If we need to update `cboard-api` service, we need to replace `cboard` parameter (at the end of commands 2, 3 and 4) with `cboard-api`.