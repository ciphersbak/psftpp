--BASH
#!/bin/bash
for i in {1..10}; do curl -XGET -k "http://slc08vkx.us.oracle.com:8000/psp/e92pp858x/?cmd=login&languageCd=ENG&" -s -o /dev/null --user VP1:VP1; done

--BASH
#!/bin/bash
$ proto="http" portNum="8000" wsName="slc08vkx" siteName="e92pp858" userName="VP2";
curl -X GET -k $proto"://"$wsName".us.oracle.com:"$portNum"/psp/"$siteName"x/?cmd=login&languageCd=ENG&" -v -s -o /dev/null --user $userName:$userName;
