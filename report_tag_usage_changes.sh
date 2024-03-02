# -----------------------------------------------------------------------------
# report_tag_usage_changes.sh
#
# Count 0-value usage tags referenced by a project,
# and see if there are more or fewer that when we last looked.
#
# Copyright (C) 2021-2024  Andy Townsend
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# -----------------------------------------------------------------------------
# The taginfo API call we make is:
# https://taginfo.openstreetmap.org/api/4/project/tags?project=${local_project}&page=1&rp=10&sortname=count_all&sortorder=asc&format=json_pretty"
#
# Parameters:
# project=${local_project}    We're only interested in one project_id.  See the start of each line at:
# https://github.com/taginfo/taginfo-projects/blob/master/project_list.txt
#
# &page=1&rp=${tag_count}     First page, only a few results per page
# &sortname=count_all         Sort by count of tag usage
# &sortorder=asc              Sort ascending (0 usage first)
# &format=json_pretty"        Return something that'll work better with "diff"
#
# We expect about 7 or so 0-usage tag/value combinations (things that are
# catered for "just in case", like "highway=unclassified_link").  Any new ones
# we will see in the emailed diff output.
#
# "stdout" from wget will be empty and "stderr" is ignored.
# The results of the diff (if any) are what we are interested in.
# This script is designed to run from cron as "local_filesystem_user".
# Any output will be emailed.
# -----------------------------------------------------------------------------
local_filesystem_user=ajtown
tag_count=20
#
if [ $# -eq 0 ]
then
    echo "$0 - no arguments passed"
else
    #echo "$0 - $# arguments passed"     #debug
    local_project=$1
    mv /home/${local_filesystem_user}/data/${local_project}_tags_first_page.justnow /home/${local_filesystem_user}/data/${local_project}_tags_first_page.previously
    wget  -O /home/${local_filesystem_user}/data/${local_project}_tags_first_page.justnow "https://taginfo.openstreetmap.org/api/4/project/tags?project=${local_project}&page=1&rp=${tag_count}&sortname=count_all&sortorder=asc&format=json_pretty" 2> /dev/null
    grep -v data_until /home/${local_filesystem_user}/data/${local_project}_tags_first_page.previously > $$.previously
    grep -v data_until /home/${local_filesystem_user}/data/${local_project}_tags_first_page.justnow > $$.justnow
    diff $$.previously $$.justnow
    rm $$.previously $$.justnow
fi
