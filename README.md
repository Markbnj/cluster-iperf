# cluster-iperf
A docker image for running iperf in client or server mode on kubernetes and ECS

## Desired features

 - Configured through environment or possible config files added to derived image
 - Single image runs as either client or server
 - Client gets the remote IP through config or possibly through discovery (on k8s)
 - iperf options passed through as env vars
 - Pod description for k8s and task description for ecs
 - Runs the test as described by the config and exits
 - Some way to get the results out (rsyslog? log to volume? email?)
 - iperf2 or iperf3?
