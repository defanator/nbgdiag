# Zyxel NBG460N-EE router diagnostic script
<br>

This script is intented to run via cron/periodic.<br>
It collects some basic stats from Zyxel NBG460N-EE router
(probably other similar models will work too) via CLI.<br>
These data may be used later for various analyzing purposes.<br><br>

To get formatted output (without escape sequences, Unix style
linefeeds), the following commands can be used:

    sed -e "s#\x1b\x37##g" | \
    tr -d '\r' | \
    sed -e "s#----1    #----\n    #"

(last one fixes missing newline in "ip tos disp" output).
