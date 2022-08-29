#!/bin/bash
# -----------------------------------------------------------------------------
# make_gis3_live.sh
# Designed to be used after update_render.sh has loaded some new data into
# gis3, while gis is still live, and the tiles based on gis3 have been tested.
# -----------------------------------------------------------------------------
local_filesystem_user=ajtown
local_renderd_user=_renderd
local_postgres_user=postgres
#
# First things first - define some shared functions
#
reinstate_crontabs()
{
    crontab -u $local_renderd_user local_renderd_user_crontab_safe.$$
    mv osm_ldp1 /etc/cron.d/
    mv osm_ldp2 /etc/cron.d/
    mv osm_ldp3 /etc/cron.d/
}

final_tidy_up()
{
    rm make_gis3_live.running
}

m_error_01()
{
    reinstate_crontabs
    final_tidy_up
    date | mail -s "make_gis3_live.sh FAILED on `hostname`." ${local_filesystem_user}
    exit 1
}

#
# Before anything else, is an update script for the previous database still running?
#
if [[ -f /var/cache/renderd/pyosmium.gis/call_pyosmium.running ]]
then
    echo "call_pyosmium still running; /var/cache/renderd/pyosmium.gis/call_pyosmium.running exists"
    exit 1
fi
#
# Next, is another copy of the script already running?
#
cd /home/${local_filesystem_user}/data
if test -e make_gis3_live.running
then
    echo make_gis3_live.running exists so exiting
    exit 1
else
    touch make_gis3_live.running
fi
# -----------------------------------------------------------------------------
#
# Remove some entries including the openstreetmap-tiles-update-expire one
# from the crontab.  Note that this matches a comment on the crontab line.
# The files are stored safely and restored at the end of the process.
#
crontab -u $local_renderd_user -l > local_renderd_user_crontab_safe.$$
grep -v "\#CONTROLLED BY update_render.sh" local_renderd_user_crontab_safe.$$ > local_renderd_user_crontab_new.$$
crontab -u $local_renderd_user local_renderd_user_crontab_new.$$
rm local_renderd_user_crontab_new.$$
#
# Also move some cron entries from "/etc/cron.d" out of the way
#
mv /etc/cron.d/osm_ldp1 .
mv /etc/cron.d/osm_ldp2 .
mv /etc/cron.d/osm_ldp3 .
#
# How much disk space are we currently using?
#
df
cd /home/${local_filesystem_user}/data
#
# Stop rendering so that we can use "ALTER" to change database names
#
/etc/init.d/renderd stop
/etc/init.d/apache2 stop
#
# Rename the databases
#
sudo -u ${local_postgres_user} psql -c "ALTER DATABASE gis rename to gis2;"
sudo -u ${local_postgres_user} psql -c "ALTER DATABASE gis3 rename to gis;"
sudo -u ${local_postgres_user} psql -c "ALTER DATABASE gis2 rename to gis3;"
#
# Rename the pyosmium directories
#
sudo mv /var/cache/renderd/pyosmium.gis      /var/cache/renderd/pyosmium.gis2
sudo mv /var/cache/renderd/pyosmium.gis.old  /var/cache/renderd/pyosmium.gis2.old
sudo mv /var/cache/renderd/pyosmium.gis3     /var/cache/renderd/pyosmium.gis
sudo mv /var/cache/renderd/pyosmium.gis3.old /var/cache/renderd/pyosmium.gis.old
sudo mv /var/cache/renderd/pyosmium.gis2     /var/cache/renderd/pyosmium.gis3
sudo mv /var/cache/renderd/pyosmium.gis2.old /var/cache/renderd/pyosmium.gis3.old
pyosmium_replag.sh -h
#
# Start rendering again
#
/etc/init.d/renderd start
/etc/init.d/apache2 start
#
# Reinstate the crontabs
#
reinstate_crontabs
# 
# And final tidying up
#
final_tidy_up
#
