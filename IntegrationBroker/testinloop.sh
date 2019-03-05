--BASH
for i in {1..10}; do curl -X GET -k -H 'Accept: application/json' -u 'iot:welcome1' https://slc16jgp.us.oracle.com/iot/api/v2/monitoring/availability -s -o /dev/null -w '\n==== cURL measurement stats ====\nTotalTime: %{time_total}s\n'; done
