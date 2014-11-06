#
# Regular cron jobs for the gpu-viv-bin package
#
0 4	* * *	root	[ -x /usr/bin/gpu-viv-bin_maintenance ] && /usr/bin/gpu-viv-bin_maintenance
