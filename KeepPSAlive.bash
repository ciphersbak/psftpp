--BASH
#!/bin/bash
for i in {1..10}; do curl -XGET -k "http://slc08vkx.us.oracle.com:8000/psp/e92pp858x/?cmd=login&languageCd=ENG&" -s -o /dev/null --user VP1:VP1; done
