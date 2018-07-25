# Infrastructure in HYF
- Create a control panel where people can see which project are running.
-- Should empower admin to choose which project are allow to run
-- By default project should run for just 24h

- Create a cluster that allows to run containers
-- http://zachmoshe.com/2016/04/28/cheapest-single-node-docker-cluster.html

- Create a lambda function that allows to create and run a container
-- Given a repository on an "artifact" should spin the infrastructure needed
   preferably just a curl on deploy task in travis
-- Should create an nginx and assign a domain in front the application.

- Provide an easy way of debugging a production container (ssh and logs)
-- https://github.com/jorgebastida/awslogs
