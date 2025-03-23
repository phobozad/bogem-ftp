FROM ubuntu:latest

ENV FTP_USER admin
ENV FTP_PASS admin
ENV PASV_ADDRESS REQUIRED
ARG FTP_UID=1000
ARG FTP_GID=1000

RUN test "$FTP_UID" = "1000" && userdel -r ubuntu || true
RUN test "$FTP_GID" = "1000" && groupdel -f ubuntu || true
RUN groupadd -g ${FTP_GID} ftp \
  && useradd --no-create-home --home-dir /srv/ftp -s /usr/sbin/nologin --uid ${FTP_UID} --gid ${FTP_GID} -c 'ftp daemon' ftp \
  ;

RUN apt-get update && \
		apt-get install -y --no-install-recommends vsftpd db-util && \
		apt-get clean

COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd.sh /usr/sbin/

RUN chmod +x /usr/sbin/run-vsftpd.sh && \
		mkdir -p /var/run/vsftpd/empty

VOLUME /home/vsftpd
VOLUME /var/log/vsftpd

EXPOSE 20 21

CMD ["/usr/sbin/run-vsftpd.sh"]
