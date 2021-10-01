FROM crashvb/supervisord:202103212252
LABEL maintainer "Richard Davis <crashvb@gmail.com>"

# Install packages, download files ...
RUN docker-apt clamav-daemon clamav-freshclam clamav-milter clamdscan libclamunrar9

# Configure: clamav
ENV CLAMAV_CONFIG=/etc/clamav CLAMAV_DATA=/var/lib/clamav CLAMAV_UPDATE_INTERVAL=2
ADD clamav-* /usr/local/bin/
RUN install --directory --group=root --mode=0775 --owner=root /usr/local/share/clamav && \
	install --directory --group=clamav --mode=0750 --owner=clamav /run/clamav && \
	sed --expression="/^CommandReadTimeout /cCommandReadTimeout 30" \
		--expression="/^IdleTimeout /cIdleTimeout 120" \
		--expression="\$aPidFile /run/clamav/clamd.pid" \
		--expression="/^LogFileMaxSize /cLogFileMaxSize 50M" \
		--expression="/^MaxEmbeddedPE /cMaxEmbeddedPE 20M" \
		--expression="/^MaxFileSize /cMaxFileSize 50M" \
		--expression="/^MaxRecursion /cMaxRecursion 24" \
		--expression="/^MaxScanSize /cMaxScanSize 150M" \
		--expression="/^MaxThreads /cMaxThreads 15" \
		--expression="/^SendBufTimeout /cSendBufTimeout 300" \
		--expression="\$aTCPAddr 0.0.0.0\nTCPSocket 3310" \
		--in-place=.dist ${CLAMAV_CONFIG}/clamd.conf && \
	cat ${CLAMAV_CONFIG}/clamd.conf | \
		grep --invert-match "^#" | \
		sort > /tmp/clamd.conf && \
		cat /tmp/clamd.conf > ${CLAMAV_CONFIG}/clamd.conf && \
		rm --force /tmp/clamd.conf && \
	sed --expression="\$a#TODO: MilterSocket inet:7357" \
		--expression="/^LogFileMaxSize /cLogFileMaxSize 50M" \
		--in-place=.dist ${CLAMAV_CONFIG}/clamav-milter.conf && \
	cat ${CLAMAV_CONFIG}/clamav-milter.conf | \
		grep --invert-match "^#" | \
		sort > /tmp/clamav-milter.conf && \
		cat /tmp/clamav-milter.conf > ${CLAMAV_CONFIG}/clamav-milter.conf && \
		rm --force /tmp/clamav-milter.conf && \
	sed --expression="\$aPidFile /run/clamav/freshclam.pid" \
		--expression="/^LogFileMaxSize /cLogFileMaxSize 50M" \
		--expression="/^SafeBrowsing /d" \
		--in-place=.dist ${CLAMAV_CONFIG}/freshclam.conf && \
	cat ${CLAMAV_CONFIG}/freshclam.conf | \
		grep --invert-match "^#" | \
		sort > /tmp/freshclam.conf && \
		cat /tmp/freshclam.conf > ${CLAMAV_CONFIG}/freshclam.conf && \
		rm --force /tmp/freshclam.conf && \
	mv ${CLAMAV_CONFIG} /usr/local/share/clamav/config

# Configure: supervisor
ADD supervisord.clamav.conf /etc/supervisor/conf.d/clamav.conf

# Configure: entrypoint
ADD entrypoint.clamav /etc/entrypoint.d/clamav

# Configure: healthcheck
ADD healthcheck.clamav /etc/healthcheck.d/clamav

EXPOSE 3310/tcp 7357/tcp

VOLUME ${CLAMAV_CONFIG} ${CLAMAV_DATA}
