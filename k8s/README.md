## Google Container Engine (kubernetes) example

This directory contains example files for defining an iperf service to act
in the server role on a kubernetes cluster, and a one-shot kubernetes job
definition that runs the client and logs the results to a remote syslog
daemon.

Files:
  * iperf-server-rc.yaml, defines the replication controller for the server pod
  * iperf-server-svc.yaml, defines a simple clusterIP service to front end the server
  * iperf-client-job.yaml, defines a one-time job to run the client

Many other configurations are possible. For example the service could be changed
to type nodePort and the test run from outside the cluster, or to type loadBalancer
to run the test from an external client.

Notes on the example:

The server is set up to log to stdout for simplicity. The logs can be retrieved
with `kubectl logs <pod name>` where `<pod name>` is the name of the pod running
the server container.

The client shows how to connect to a remote syslog daemon but could just as easily
log to stdout, or to a local file (set RSYSLOG_REMOTE to `false`). If logging to
a file that volume could be mounted onto the host and retrieved with scp, etc.
