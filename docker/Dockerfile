FROM alpine:3.1
MAINTAINER Mark Betz <betz.mark@gmail.com>

ADD run_iperf.sh /bin/

RUN chmod 755 /bin/run_iperf.sh &&\
 apk update &&\
 apk add bash &&\
 apk add iperf

ENTRYPOINT ["/bin/run_iperf.sh"]
