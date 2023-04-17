FROM mysql:8.0.29

USER root
ENV DEBIAN_FRONTEND=noninteractive

# RUN apk install nano mc bash

RUN chmod 600 /etc/my.cnf

USER mysql
CMD ["mysqld"]
