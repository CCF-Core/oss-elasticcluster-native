FROM logstash

COPY conf.d /etc/logstash/conf.d

CMD ["-f", "/etc/logstash/conf.d"]
