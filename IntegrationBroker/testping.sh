curl -X GET -k -H 'Accept: application/json' -u 'iot:welcome1' https://slc16jgp.us.oracle.c
om/iot/api/v2/monitoring/availability -w '\n\n==== cURL measurement stats ==== \nEstConn: %{time_connect}s\nTimeNameLook
up: %{time_namelookup}s\nTimeAppConnect: %{time_appconnect}s\nTimePreTransfer: %{time_pretransfer}s\nTimeStartTransfer:
%{time_starttransfer}s\nTotalTime: %{time_total}s\n' -s -o /dev/null
