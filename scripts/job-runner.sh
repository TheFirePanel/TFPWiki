#!/bin/bash
MW_INSTALL_PATH="/var/www/html"
RUN_JOBS="$MW_INSTALL_PATH/maintenance/run.php runJobs --maxtime=3600"
echo Starting job service...
# Wait a few seconds before running service
sleep 15
echo Started.
while true; do
	php $RUN_JOBS --type="enotifNotify"
	php $RUN_JOBS --wait --maxjobs=20
	sleep 10
done
