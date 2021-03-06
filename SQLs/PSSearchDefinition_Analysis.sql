--FSCM Search Definitions
--Version 1
SELECT SFSD.PTSF_SBO_NAME "Search Defn", SFSD.DESCR100 "Search Descr", SFSD.PTSF_SOURCE_TYPE "Source Type", SFSD.PTSF_SOURCE_NAME "Source Name",
       SDATR.QRYNAME "Query Name", SDATR.QRYFLDNAME "Source Field", SDATR.SEQNUM, SDATR.PTSF_SRCATTR_NAME "Attribute Name", RECD.RECNAME, RECD.RECTYPE,
       SFDC.QRYNAME "Security Query Name", SFDC.QRYFLDNAME "Security Qry Field Name", SFDC.PTSF_DOCACL_PVLG "Doc ACL Privilege",
       SDATR.PTSF_ISFIELDTOIDX "Field to Index", SDATR.PTSF_ISFLDTODISPL "Field to Display", SDATR.PTSF_ISATTACHMENT "Attachment Field", SDATR.PTSF_IS_CLUSTERD "Define Hierarchy",
       SDATR.PTSF_IS_FACETED "IsFaceted", SFSD.PTSF_ISGBLSRCH "IsGlobalSearch", SFSD.PTSF_ISSRCACL "Source Level", SFSD.PTSF_ISDOCACL "Document Level",
       SFSD.OBJECTOWNERID  || ' - ' || X1.XLATLONGNAME AS "Search Object Ident", RECD.OBJECTOWNERID || ' - ' || X2.XLATLONGNAME AS "Record Object Ident"
FROM (PSPTSF_SD SFSD LEFT OUTER JOIN PSXLATITEM X1 ON X1.FIELDNAME = 'OBJECTOWNERID' AND X1.FIELDVALUE = SFSD.OBJECTOWNERID AND X1.EFF_STATUS = 'A'),
     (((((PSPTSF_SD_ATTR SDATR LEFT OUTER JOIN PSQRYDEFN QRYD ON QRYD.QRYNAME = SDATR.QRYNAME)
      LEFT OUTER JOIN PSPTSF_SD_DCATR SFDC ON SDATR.PTSF_SBO_NAME = SFDC.PTSF_SBO_NAME AND SFDC.PTSF_SRCATTR_NAME = SDATR.PTSF_SRCATTR_NAME)
      LEFT OUTER JOIN PSQRYFIELD QRYF ON QRYF.QRYNAME = QRYD.QRYNAME AND QRYF.QRYFLDNAME = SDATR.QRYFLDNAME)
      LEFT OUTER JOIN PSRECDEFN RECD ON QRYF.RECNAME = RECD.RECNAME)
      LEFT OUTER JOIN PSXLATITEM X2 ON X2.FIELDNAME = 'OBJECTOWNERID' AND X2.FIELDVALUE = RECD.OBJECTOWNERID AND X2.EFF_STATUS = 'A')
WHERE 1 = 1
  AND SFSD.PTSF_SBO_NAME = SDATR.PTSF_SBO_NAME
--  AND SFSD.PTSF_SBO_NAME = 'AP_SDN_ADDRESS'
ORDER BY SFSD.PTSF_SBO_NAME, SDATR.SEQNUM;
