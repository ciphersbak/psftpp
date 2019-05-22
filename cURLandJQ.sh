alias jq=./jq-win64.exe
echo '{"foo": 0}' | jq
 
curl -XGET http://slc11ohu.us.oracle.com:8000/PSIGW/RESTListeningConnector/E92PP858/CIRT_PP_WEB_PROF_HIST_C_G_GET.V1/slc11ohu/8000/e92pp858x -H "Accept: application/json" -s | jq
 
curl -XGET http://slc11ohu.us.oracle.com:8000/PSIGW/RESTListeningConnector/E92PP858/CIRT_PP_WEB_PROF_HIST_C_G_GET.V1/slc11ohu/8000/e92pp858x -H "Accept: application/json" -s | jq '.Get__CompIntfc_PP_WEB_PROF_HIST_CIResponse.WEBPROFILENAME'
 
curl -XGET http://slc11ohu.us.oracle.com:8000/PSIGW/RESTListeningConnector/E92PP858/CIRT_PP_WEB_PROF_HIST_C_G_GET.V1/slc11ohu/8000/e92pp858x -H "Accept: application/json" -s | jq '.Get__CompIntfc_PP_WEB_PROF_HIST_CIResponse.WEBPROFILENAME, .Get__CompIntfc_PP_WEB_PROF_HIST_CIResponse.WEBSITENAME'
 
curl -XGET http://slc11ohu.us.oracle.com:8000/PSIGW/RESTListeningConnector/E92PP858/CIRT_PP_WEB_PROF_HIST_C_G_GET.V1/slc11ohu/8000/e92pp858x -H "Accept: application/json" -s | jq '{webprofileName: .Get__CompIntfc__PP_WEB_PROF_HIST_CIResponse.WEBPROFILENAME, websiteName: .Get__CompIntfc__PP_WEB_PROF_HIST_CIResponse.WEBSITENAME}'
