--Version 2
--Added PSPROJECTDEFN
SELECT I.PROJECTNAME, PD.PROJECTDESCR, OBJECTTYPE,
CASE OBJECTTYPE
  WHEN 0   THEN CASE NVL((SELECT RECTYPE FROM PSRECDEFN WHERE RECNAME = I.OBJECTVALUE1), 99)
                           WHEN 0 THEN 'SQL Table in DB'
                           WHEN 1 THEN 'SQL View in DB'
                           WHEN 2 THEN 'Work Record'
                           WHEN 3 THEN 'Sub Record'
                           WHEN 5 THEN 'Dynamic View'
                           WHEN 6 THEN 'Query View'
                           WHEN 7 THEN 'Temporary Table'
                           ELSE 'Other Record or Deleted' END
 
  WHEN 1   THEN 'Index'
  WHEN 2   THEN 'Field'
  WHEN 3   THEN 'Field Format'
  WHEN 4   THEN 'Translate Value'
  WHEN 5   THEN 'Page'
  WHEN 6   THEN 'Menu'
  WHEN 7   THEN 'Component'
  WHEN 8   THEN 'Record PeopleCode'
  WHEN 9   THEN 'Menu PeopleCode'
  WHEN 10  THEN 'Query'
  WHEN 11  THEN 'Tree Structure'
  WHEN 12  THEN 'Tree'
  WHEN 13  THEN 'Access Group'
  WHEN 14  THEN 'Color'
  WHEN 15  THEN 'Style'
  WHEN 16  THEN 'Business Process Map'
  WHEN 17  THEN 'Business Process'
  WHEN 18  THEN 'Activity'
  WHEN 19  THEN 'Role'
  WHEN 20  THEN 'Process Definition'
  WHEN 21  THEN 'Process Server Definition'
  WHEN 22  THEN 'Process Type Definition'
  WHEN 23  THEN 'Process Job Definition'
  WHEN 24  THEN 'Process Recurrence Definition'
  WHEN 25  THEN 'Message Catalog'
  WHEN 26  THEN 'Dimension'
  WHEN 27  THEN 'Cube Definition'
  WHEN 28  THEN 'Cube Instance Definition'
  WHEN 29  THEN 'Business Interlink'
  WHEN 30  THEN CASE OBJECTVALUE2
                               WHEN '0' THEN 'SQL Object'
                               WHEN '1' THEN 'App Engine SQL'
                               WHEN '2' THEN 'Record View SQL'
                               WHEN '5' THEN 'Query for DDDAUDIT or SYSAUDIT'
                               WHEN '6' THEN 'App Engine XML SQL'
                               ELSE 'SQL' END
  WHEN 31  THEN 'File Layout'
  WHEN 32  THEN 'Component Interface'
  WHEN 33  THEN 'Application Engine Program'
  WHEN 34  THEN 'Application Engine Section'
  WHEN 35  THEN 'Message Node'
  WHEN 36  THEN 'Message Channel'
  WHEN 37  THEN 'Message'
  WHEN 38  THEN 'Approval Rule Se'
  WHEN 39  THEN 'Message PeopleCode'
  WHEN 40  THEN 'Subscription PeopleCode'
  WHEN 41  THEN 'N/A'
  WHEN 42  THEN 'Component Interface PeopleCode'
  WHEN 43  THEN 'Application Engine PeopleCode'
  WHEN 44  THEN 'Page PeopleCode'
  WHEN 45  THEN 'Page Field PeopleCode'
  WHEN 46  THEN 'Component PeopleCode'
  WHEN 47  THEN 'Component Record PeopleCode'
  WHEN 48  THEN 'Component Rec Fld PeopleCode'
  WHEN 49  THEN 'Image'
  WHEN 50  THEN 'Style Sheet'
  WHEN 51  THEN 'HTML'
  WHEN 52  THEN 'Not used'
  WHEN 53  THEN 'Permission List'
  WHEN 54  THEN 'Portal Registry Definitions'
  WHEN 55  THEN 'Portal Registry Structure'
  WHEN 56  THEN 'URL Definitions'
  WHEN 57  THEN 'Application Packages'
  WHEN 58  THEN 'Application Package PeopleCode'
  WHEN 59  THEN 'Portal Registry User Homepage'
  WHEN 60  THEN 'Problem Type'
  WHEN 61  THEN 'Archive Templates'
  WHEN 62  THEN 'XSLT'
  WHEN 63  THEN 'Portal Registry User Favorite'
  WHEN 64  THEN 'Mobile Page'
  WHEN 65  THEN 'Relationships'
  WHEN 66  THEN 'Comp Intfce Property PCode'
  WHEN 67  THEN 'Optimization Models'
  WHEN 68  THEN 'File References'
  WHEN 69  THEN 'File Type Codes'
  WHEN 70  THEN 'Archive Object Definitions'
  WHEN 71  THEN 'Archive Templates (Type 2)'
  WHEN 72  THEN 'Diagnostic Plug In'
  WHEN 73  THEN 'Analytic Model'
  WHEN 74  THEN 'unused'
  WHEN 75  THEN 'Java Portlet User Preferences'
  WHEN 76  THEN 'WSRP Remote Producers'
  WHEN 77  THEN 'WSRP Remote Portlets'
  WHEN 78  THEN 'WSRP Cloned Portlets Handles'
  WHEN 79  THEN 'Service'
  WHEN 80  THEN 'Service Operation'
  WHEN 81  THEN 'Service Operation Handler'
  WHEN 82  THEN 'Service Operation Version'
  WHEN 83  THEN 'Service Operation Routing'
  WHEN 84  THEN 'Info Broker Queues'
  WHEN 85  THEN 'XLMP Template Definition'
  WHEN 86  THEN 'XLMP Report Definition'
  WHEN 87  THEN 'XMLP File Definition'
  WHEN 88  THEN 'XMPL Data Source Definition'
  WHEN 89  THEN 'WSDL'
  WHEN 90  THEN 'Schema'
  WHEN 91  THEN 'Connected Queries'
  WHEN 92  THEN 'Logical Schema'
  WHEN 93  THEN 'Physical Schema'
  WHEN 94  THEN 'Relational Schema'
  WHEN 95  THEN 'Logical Schema Dependancy'
  WHEN 96  THEN 'Document Schema'
  WHEN 97  THEN 'Essbase Cube Dimensions'
  WHEN 98  THEN 'Essbase Cube Outlines'
  WHEN 99  THEN 'Essbase Cube Connections'
  WHEN 100 THEN 'Essbase Cube Templates'
  ELSE 'Unknown '  END  AS Object_Type,
  CASE OBJECTTYPE
  WHEN 12  THEN OBJECTVALUE3
  WHEN 30  THEN CASE WHEN OBJECTVALUE2 = 0 THEN OBJECTVALUE1
                       WHEN OBJECTVALUE2 = 1 THEN SUBSTR(OBJECTVALUE1, 1, 12)
                       WHEN OBJECTVALUE2 = 2 THEN OBJECTVALUE1
                       ELSE ' ' END
  WHEN 34  THEN ltrim(RTRIM(OBJECTVALUE1)) || '.' || ltrim(RTRIM(OBJECTVALUE2))
  WHEN 62  THEN ltrim(rTRIM(SUBSTR(OBJECTVALUE1, 1, 12)))
  ELSE OBJECTVALUE1 END AS NAME,
  CASE
  WHEN OBJECTTYPE = 1    THEN 'Index: ' || OBJECTVALUE2
  WHEN OBJECTTYPE = 4    THEN 'XLAT: ' || OBJECTVALUE2 || '; Date: ' || OBJECTVALUE3 || '; ' || NVL((SELECT 'ShortName: ' || XLATSHORTNAME || '; LongName: ' || XLATLONGNAME || '; Status: ' || EFF_STATUS
                                  FROM PSXLATITEM WHERE FIELDNAME = I.OBJECTVALUE1 AND FIELDVALUE = I.OBJECTVALUE2 AND EFFDT = TO_DATE(I.OBJECTVALUE3, 'YYYY-MM-DD')), 'XLAT Deleted')
  WHEN OBJECTTYPE = 7    THEN 'Market: ' || OBJECTVALUE2
  WHEN OBJECTTYPE = 8    THEN OBJECTVALUE1 || '.' || OBJECTVALUE2 || '.' || OBJECTVALUE3
  WHEN OBJECTTYPE = 9    THEN OBJECTVALUE2 || '.' || OBJECTVALUE3 || '.' || OBJECTVALUE4
  WHEN OBJECTTYPE = 12   THEN 'EFFDT: ' || OBJECTVALUE4
  WHEN OBJECTTYPE = 20   THEN 'Process Name: ' || OBJECTVALUE2
  WHEN OBJECTTYPE IN(22, 40)   THEN OBJECTVALUE2 || '.' || OBJECTVALUE3
  WHEN OBJECTTYPE = 25   THEN 'Message: ' || OBJECTVALUE2 || '(Message Set Descr: ' || ltrim(rtrim(OBJECTVALUE3)) || ')'
  WHEN OBJECTTYPE = 30   THEN 
                         CASE WHEN OBJECTVALUE2 = 0 THEN ' '
                              WHEN OBJECTVALUE2 = 1 THEN 'AE Progam: ' || SUBSTR(OBJECTVALUE1, 1, 12) || '  Section: ' || SUBSTR(OBJECTVALUE1, 13, 8) || '  Step: ' || SUBSTR(OBJECTVALUE1, 21, 8) || '  Type: ' ||
                                           CASE WHEN SUBSTR(OBJECTVALUE1, 29, 1) = 'S' THEN 'SQL'
                                                WHEN SUBSTR(OBJECTVALUE1, 29, 1) = 'D' THEN 'Do Select' 
                                                WHEN SUBSTR(OBJECTVALUE1, 29, 1) = 'W' THEN 'Do While'
                                                WHEN SUBSTR(OBJECTVALUE1, 29, 1) = 'H' THEN 'Do When' 
                                                WHEN SUBSTR(OBJECTVALUE1, 29, 1) = 'N' THEN 'Do Until'
                               WHEN OBJECTVALUE2 = 2 THEN ' ' 
                               ELSE ' ' END
                         END     
  WHEN OBJECTTYPE = 38   THEN 'EFFDT: ' || OBJECTVALUE2
  WHEN OBJECTTYPE IN(39, 42, 44)   THEN OBJECTVALUE2
  WHEN OBJECTTYPE = 43   THEN
                         CASE 
                         WHEN ltrim(rTRIM(OBJECTVALUE4)) = 'OnExecute' 
                            THEN 'Section: ' || SUBSTR(OBJECTVALUE2, 1, 8) || '; Step: ' || OBJECTVALUE3 || '; Market: ' || SUBSTR(OBJECTVALUE2, 9, 3) || '; Database: ' || ltrim(rTRIM(SUBSTR(OBJECTVALUE2, 12, 8))) ||
                                     '; EFFDT: ' || ltrim(rTRIM(SUBSTR(OBJECTVALUE2, 21, 10)))
                            ELSE 'Section: ' || OBJECTVALUE2 || '; Market: ' || OBJECTVALUE3 || '; Database: ' || ltrim(rTRIM(SUBSTR(OBJECTVALUE4, 12, 8))) || '; EFFDT: ' || ltrim(rTRIM(SUBSTR(OBJECTVALUE4, 21, 10))) 
                         END
  WHEN OBJECTTYPE = 46   THEN 'Market: ' || OBJECTVALUE2 || '; Event: ' || OBJECTVALUE3
  WHEN OBJECTTYPE = 47   THEN 'Market: ' || OBJECTVALUE2 || '; Record: ' || OBJECTVALUE3 || '; Event: ' || OBJECTVALUE4
  WHEN OBJECTTYPE = 48   THEN 'Market: ' || OBJECTVALUE2 || '; Record: ' || OBJECTVALUE3 || '; Field: ' || ltrim(rTRIM(SUBSTR(OBJECTVALUE4, 1, 18))) || '; Event: ' || ltrim(rTRIM(SUBSTR(OBJECTVALUE4, 19, 16)))
  WHEN OBJECTTYPE = 55   THEN 
                         CASE WHEN ltrim(rtrim(OBJECTVALUE2)) = 'C' THEN 'Content: ' ELSE 'Folder: ' END || OBJECTVALUE3
  WHEN OBJECTTYPE = 57   THEN
                         CASE WHEN ltrim(rTRIM(OBJECTVALUE4)) NOT IN(' ', ':', '.') THEN
                                  'Subclass: ' || ltrim(rTRIM(OBJECTVALUE2)) || ':' || ltrim(rTRIM(OBJECTVALUE3)) || ':' || ltrim(rTRIM(OBJECTVALUE4))
                              ELSE
                                 CASE WHEN ltrim(rTRIM(OBJECTVALUE3)) NOT IN(' ', ':', '.') THEN
                                           'Subclass: ' || ltrim(rTRIM(OBJECTVALUE2)) || ':' || ltrim(rTRIM(OBJECTVALUE3))
                                     ELSE
                                         CASE WHEN ltrim(rTRIM(OBJECTVALUE2)) NOT IN(' ', ':', '.') THEN
                                                  'Subclass: ' ||  ltrim(rTRIM(OBJECTVALUE2))
                                              ELSE ' '
                                         END
                                 END
                         END
  WHEN OBJECTTYPE IN(58, 63, 68, 81, 82, 83, 87, 88) THEN
                         CASE WHEN ltrim(rTRIM(OBJECTVALUE4)) IS NOT NULL THEN
                                   ltrim(rTRIM(OBJECTVALUE2)) || '.' || ltrim(rTRIM(OBJECTVALUE3))  || '.' || ltrim(rTRIM(OBJECTVALUE4))
                              ELSE
                                  CASE WHEN ltrim(rTRIM(OBJECTVALUE3)) IS NOT NULL THEN
                                            ltrim(rTRIM(OBJECTVALUE2)) || '.' || ltrim(rTRIM(OBJECTVALUE3))
                                  ELSE
                                      CASE WHEN ltrim(rTRIM(OBJECTVALUE2)) IS NOT NULL THEN
                                                ltrim(rTRIM(OBJECTVALUE2))
                                           ELSE ' '
                                      END
                                  END
                              END
  WHEN OBJECTTYPE = 59   THEN ltrim(rTRIM(OBJECTVALUE2))
  WHEN OBJECTTYPE = 62   THEN 'AE Progam: ' || SUBSTR(OBJECTVALUE1, 1, 12) || '  Section: ' || SUBSTR(OBJECTVALUE1, 13, 8) || '  Step: ' || SUBSTR(OBJECTVALUE1, 21, 8)
  ELSE ' ' 
  END EXTENDED_OBJ_NAME,  
  CASE OBJECTTYPE
  WHEN 0    THEN NVL((SELECT OBJECTOWNERID || ' - ' || RECDESCR FROM PSRECDEFN WHERE RECNAME = I.OBJECTVALUE1), ' ')
  WHEN 8    THEN NVL((SELECT OBJECTOWNERID || ' - ' || RECDESCR FROM PSRECDEFN WHERE RECNAME = I.OBJECTVALUE1), ' ')
  WHEN 1    THEN NVL((SELECT IDXCOMMENTS FROM PSINDEXDEFN WHERE RECNAME = I.OBJECTVALUE1 AND INDEXID = I.OBJECTVALUE2), ' ')
  --WHEN 2    THEN NVL((SELECT DESCRLONG FROM PSDBFIELD WHERE FIELDNAME = I.OBJECTVALUE1), ' ')
  WHEN 3    THEN NVL((SELECT DESCR FROM PSFMTDEFN WHERE FORMATFAMILY = I.OBJECTVALUE1), ' ')
  WHEN 5    THEN NVL((SELECT OBJECTOWNERID || ' - ' || DESCR FROM PSPNLDEFN WHERE PNLNAME = I.OBJECTVALUE1), ' ')
  WHEN 6    THEN NVL((SELECT OBJECTOWNERID || ' - ' || DESCR FROM PSMENUDEFN WHERE MENUNAME = I.OBJECTVALUE1), ' ')
  WHEN 7    THEN NVL((SELECT OBJECTOWNERID || ' - ' || DESCR FROM PSPNLGRPDEFN WHERE PNLGRPNAME = I.OBJECTVALUE1 AND MARKET = I.OBJECTVALUE2), ' ')
  --WHEN 10   THEN NVL((SELECT DESCR FROM PSQRYDEFN WHERE QRYNAME = I.OBJECTVALUE1), ' ')
  WHEN 12   THEN NVL((SELECT SETCNTRLVALUE || ' - ' || TREE_STRCT_ID || ' - ' || DESCR FROM PSTREEDEFN WHERE TREE_NAME = I.OBJECTVALUE3), ' ')
  WHEN 13   THEN NVL((SELECT DESCR FROM PS_ACCESS_GRP_TBL WHERE ACCESS_GROUP = I.OBJECTVALUE1), ' ')
  WHEN 17   THEN NVL((SELECT OBJECTOWNERID || ' - ' || DESCR60 FROM PSBUSPROCDEFN WHERE BUSPROCNAME = I.OBJECTVALUE1), ' ')
  WHEN 18   THEN NVL((SELECT OBJECTOWNERID || ' - ' || DESCR60 FROM PSACTIVITYDEFN WHERE ACTIVITYNAME = I.OBJECTVALUE1), ' ')
  WHEN 19   THEN NVL((SELECT DESCR FROM PSROLEDEFN WHERE ROLENAME = I.OBJECTVALUE1), ' ')
  WHEN 20   THEN NVL((SELECT DESCR FROM PS_PRCSDEFN WHERE PRCSTYPE = I.OBJECTVALUE1 AND PRCSNAME = I.OBJECTVALUE2), ' ')
  WHEN 23   THEN NVL((SELECT DESCR FROM PS_PRCSJOBDEFN WHERE PRCSJOBNAME = I.OBJECTVALUE1), ' ')
  WHEN 21   THEN NVL((SELECT DESCR FROM PS_SERVERDEFN WHERE SERVERNAME = I.OBJECTVALUE1), ' ')
  WHEN 25   THEN NVL((SELECT MESSAGE_SET_NBR || ' - ' || MESSAGE_NBR || ' - ' || MESSAGE_TEXT FROM PSMSGCATDEFN WHERE MESSAGE_SET_NBR = I.OBJECTVALUE1 AND MESSAGE_NBR = I.OBJECTVALUE2), ' ') 
  WHEN 31   THEN NVL((SELECT DESCR FROM PSFLDDEFN WHERE FLDDEFNNAME = I.OBJECTVALUE1), ' ') 
  WHEN 32   THEN NVL((SELECT OBJECTOWNERID || ' - ' || DESCR FROM PSBCDEFN WHERE BCNAME = I.OBJECTVALUE1), ' ')
  WHEN 33   THEN NVL((SELECT OBJECTOWNERID || ' - ' || DESCR FROM PSAEAPPLDEFN WHERE AE_APPLID = I.OBJECTVALUE1), ' ')
  --WHEN 34   THEN NVL((SELECT TOP 1 DESCR FROM PSAESECTDTLDEFN WHERE AE_APPLID = I.OBJECTVALUE1 AND AE_SECTION = I.OBJECTVALUE2), ' ')
  WHEN 53   THEN NVL((SELECT CLASSDEFNDESC FROM PSCLASSDEFN WHERE CLASSID = I.OBJECTVALUE1), ' ')
  WHEN 56   THEN NVL((SELECT OBJECTOWNERID || ' - ' || DESCR || ' - ' || URL FROM PSURLDEFN WHERE URL_ID = I.OBJECTVALUE1), ' ')
  ELSE ' ' END AS "DESCR",
  PD.LASTUPDOPRID, PD.LASTUPDDTTM, dbms_lob.substr(PD.DESCRLONG) AS PROJECT_LONG_DESCR
FROM PSPROJECTITEM I, PSPROJECTDEFN PD
WHERE PD.PROJECTNAME = I.PROJECTNAME
  AND I.PROJECTNAME LIKE 'UN%'
ORDER BY PD.LASTUPDDTTM DESC, OBJECTTYPE, OBJECTVALUE1, OBJECTVALUE2, OBJECTVALUE3, OBJECTVALUE4;
