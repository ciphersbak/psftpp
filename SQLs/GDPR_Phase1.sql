SET FEEDBACK ON;
/
--Drop Table
begin
    for c1 in (select table_name from user_tables where table_name = 'PS_ALL_EMP_FSCM_SDF_TBL') loop
        execute immediate 'drop table '||c1.table_name||'';
    end loop;
end;
/
--Create Table
CREATE TABLE PS_ALL_EMP_FSCM_SDF_TBL
AS
SELECT RECFLD.RECNAME "Record Name",
       CASE(NVL(RECD.RECTYPE, 99)) WHEN 0 THEN '0 - SQL Table' WHEN 1 THEN '1 - SQL View' WHEN 2 THEN '2 - Work Record' WHEN 3 THEN '3 - Sub Record' WHEN 5 THEN '5 - Dynamic View'
                                   WHEN 6 THEN '6 - Query View' WHEN 7 THEN '7 - Temporary Table'
       ELSE 'Excluded Record or Deleted' END AS "Record Type", RECFLD.FIELDNAME "Record Field Name",
       CASE DBF.FIELDTYPE
         WHEN 0 THEN '0 - Char' WHEN 1 THEN '1 - Long Char' WHEN 2 THEN '2 - NBR' WHEN 3 THEN '3 - Sign NBR' WHEN 4 THEN '4 - Date' WHEN 5 THEN '5 - Time' WHEN 6 THEN '6 - Dttm'
         WHEN 7 THEN '7 - Img' WHEN 8 THEN '8 - Img/Attch' WHEN 9 THEN '9 - Img/Ref'
       ELSE 'Unknown' END "DB Field Type", DBF.LENGTH, RECFLD.RECNAME_PARENT, RECFLD.DEFRECNAME, RECFLD.EDITTABLE,
       RECD.OBJECTOWNERID || ' - ' || X1.XLATLONGNAME AS "Record Object Ident", PNLD.OBJECTOWNERID || ' - ' || X2.XLATLONGNAME AS "Page Object Ident", PNLF.PNLNAME "Page Name",
       PNLD.DESCR "Page Description",
       CASE PNLD.PNLTYPE WHEN 0 THEN 'Page' WHEN 1 THEN 'Subpage' WHEN 2 THEN 'Secondary Page' WHEN 3 THEN 'Popup Page' WHEN 4 THEN 'NUI Header Page' WHEN 5 THEN 'NUI Side Page 1'
                         WHEN 6 THEN 'NUI Footer Page' WHEN 7 THEN 'NUI Layout Page' WHEN 8 THEN 'NUI Search Page' WHEN 9 THEN 'NUI Prompt Page' WHEN 10 THEN 'NUI Master Detail Target Page'
                         WHEN 11 THEN 'NUI Side Page 2'
       ELSE 'Unknown' END "Page Type", PNLF.PNLFIELDNAME "Page Field Name",
       CASE PNLF.FIELDTYPE
         WHEN 0 THEN 'Text' WHEN 1 THEN 'Frame' WHEN 2 THEN 'Group Box' WHEN 3 THEN 'Static Image' WHEN 4 THEN 'Edit Box' WHEN 5 THEN 'Drop Down List' WHEN 6 THEN 'Long Edit Box'
         WHEN 7 THEN 'Check Box' WHEN 8 THEN 'Radio Button' WHEN 9 THEN 'Image' WHEN 10 THEN 'Scroll Bar' WHEN 11 THEN 'Subpage' WHEN 12 THEN 'Push Button/Link - PeopleCode'
         WHEN 13 THEN 'Push Button/Link - Scroll Action' WHEN 14 THEN 'Push Button/Link - Toolbar Action' WHEN 15 THEN 'Push Button/Link - External Link'
         WHEN 16 THEN 'Push Button/Link - Internal Link' WHEN 17 THEN 'Push Button/Link - Process' WHEN 18 THEN 'SecPage' WHEN 19 THEN 'Grid' WHEN 20 THEN 'Tree'
         WHEN 21 THEN 'Push Button/Link - Secondary Page' WHEN 23 THEN 'Horizontal Rule' WHEN 24 THEN 'Tab Separator' WHEN 25 THEN 'HTML Area' WHEN 26 THEN 'Push Button/Link - Prompt Action'
         WHEN 27 THEN 'Scroll Area' WHEN 29 THEN 'Push Button/Link - Page Anchor' WHEN 30 THEN 'Chart' WHEN 31 THEN 'Push Button/Link - Instant Message Action' WHEN 32 THEN 'Analytic Grid'
       ELSE 'Unknown' END "PNL Field Type",
       CASE WHEN PNLF.PNLNAME IS NOT NULL THEN CASE WHEN BITAND(PNLF.FIELDUSE, 1) = 1 THEN 'Display Only' WHEN BITAND(PNLF.FIELDUSE, 1) <> 1 THEN 'XXXX' END ELSE 'Unknown' END
       AS "Display Only",           
       CASE WHEN PNLF.PNLNAME IS NOT NULL THEN CASE WHEN BITAND(PNLF.FIELDUSE, 2) = 2 THEN 'Invisible' WHEN BITAND(PNLF.FIELDUSE, 2) <> 2 THEN 'Visible' END ELSE 'Unknown' END
       AS "Visible Y/N",
       PNLF.LABEL_ID "Label ID", PNLF.LBLTEXT "Label Text",
       CAST(' ' AS VARCHAR2(100)) "Category", CAST(' ' AS VARCHAR2(100)) "Classification", CAST(' ' AS VARCHAR2(3)) "Personally Identifiable", CAST(' ' AS VARCHAR2(3)) "Sensitive",
       PNLF.PNLFLDID, PNLF.FIELDNUM, PNLF.DSPLFORMAT, PNLF.ASSOCFIELDNUM,
       PNLGRP.PNLGRPNAME "Component Name", PNLGRP.MARKET "Comp MKT", PRS.PORTAL_NAME "Portal Name",
       P3.PORTAL_LABEL || ' > ' || P2.PORTAL_LABEL || ' > ' || P1.PORTAL_LABEL || ' > ' || PRS.PORTAL_LABEL "Navigation", PRS.PORTAL_OBJNAME "Portal Object Name",
       PRS.PORTAL_PRODUCT "CREF Product", PRS.OBJECTOWNERID "Portal Object Ident", PRS.PORTAL_URI_SEG1 "Portal Registry Menu Name", PRS.PORTAL_URLTEXT "PSP URL",
       CASE WHEN PRS.PORTAL_OBJNAME IS NOT NULL THEN
         CASE WHEN dbms_lob.instr(PRSATTR.PORTAL_ATTR_VAL, 'TRUE') > 0 THEN 'Hidden' ELSE 'Visible' END ELSE 'Unknown' END "IsCREFHidden",
       PNLGRP.SUBITEMNUM "Page Tab#", CASE PNLGRP.HIDDEN WHEN 0 THEN '0 - Visible' WHEN 1 THEN '1 - Hidden' ELSE 'Unkown' END "IsPageHidden",
       MNU.MENUNAME "MENUITEM Menu Name", MNU.BARNAME "Menu Bar Name", MNU.ITEMNAME "Item Name", MNU.ITEMLABEL "Item Label", PRSATTR1.PORTAL_ATTR_VAL "Conditional Nav Attr Value"
FROM PSRECFIELDDB RECFLD, PSDBFIELD DBF, (PSRECDEFN RECD LEFT OUTER JOIN PSXLATITEM X1 ON X1.FIELDNAME = 'OBJECTOWNERID' AND X1.FIELDVALUE = RECD.OBJECTOWNERID AND X1.EFF_STATUS = 'A'),
     ((((((((PSPNLFIELD PNLF LEFT OUTER JOIN PSPNLGROUP PNLGRP ON PNLF.PNLNAME = PNLGRP.PNLNAME)
        LEFT OUTER JOIN PSMENUITEM MNU ON PNLGRP.PNLGRPNAME = MNU.PNLGRPNAME)
        LEFT OUTER JOIN PSPRSMDEFN PRS ON PRS.PORTAL_URI_SEG2 = PNLGRP.PNLGRPNAME AND PRS.PORTAL_CREF_USGT = 'TARG')
      LEFT OUTER JOIN PSPRSMDEFN P1 ON PRS.PORTAL_PRNTOBJNAME = P1.PORTAL_OBJNAME AND PRS.PORTAL_NAME = P1.PORTAL_NAME)
      LEFT OUTER JOIN PSPRSMDEFN P2 ON P1.PORTAL_PRNTOBJNAME = P2.PORTAL_OBJNAME AND P1.PORTAL_NAME = P2.PORTAL_NAME)
      LEFT OUTER JOIN PSPRSMDEFN P3 ON P2.PORTAL_PRNTOBJNAME = P3.PORTAL_OBJNAME AND P2.PORTAL_NAME = P3.PORTAL_NAME)
      LEFT OUTER JOIN PSPRSMSYSATTRVL PRSATTR ON PRSATTR.PORTAL_NAME = PRS.PORTAL_NAME AND PRSATTR.PORTAL_OBJNAME = PRS.PORTAL_OBJNAME AND PRSATTR.PORTAL_ATTR_NAM = 'PORTAL_HIDE_FROM_NAV')
      LEFT OUTER JOIN PSPRSMSYSATTRVL PRSATTR1 ON PRSATTR1.PORTAL_NAME = PRS.PORTAL_NAME AND PRSATTR1.PORTAL_OBJNAME = PRS.PORTAL_OBJNAME AND PRSATTR1.PORTAL_ATTR_NAM LIKE 'CN_DISPLAYMODE_%'),
      (PSPNLDEFN PNLD LEFT OUTER JOIN PSXLATITEM X2 ON X2.FIELDNAME = 'OBJECTOWNERID' AND X2.FIELDVALUE = PNLD.OBJECTOWNERID AND X2.EFF_STATUS = 'A')
WHERE 1 = 1
  AND RECFLD.FIELDNAME = DBF.FIELDNAME
  AND RECFLD.RECNAME = RECD.RECNAME
  AND RECD.OBJECTOWNERID NOT IN ('PPT', 'CCF', 'CCU', 'CEO', 'CEI', 'CEW', 'CLT', 'CPP', 'CTP', 'TTS')
  AND RECFLD.RECNAME = PNLF.RECNAME
  AND RECFLD.FIELDNAME = PNLF.FIELDNAME
  AND PNLF.PNLNAME = PNLD.PNLNAME
  AND RECFLD.RECNAME IN (SELECT DISTINCT X.RECNM_D FROM (SELECT DISTINCT RECFLD.RECNAME, RECFLD.FIELDNAME, RECD.RECNAME RECNM_D FROM PSRECFIELDDB RECFLD, PSRECDEFN RECD
                         WHERE RECFLD.RECNAME = RECD.RECNAME AND RECD.RECTYPE <> 7 AND RECD.OBJECTOWNERID NOT IN ('PPT', 'CCF', 'CCU', 'CEO', 'CEI', 'CEW', 'CLT', 'CPP', 'CTP', 'TTS')
                           AND (RECFLD.FIELDNAME = 'EMPLID' OR RECFLD.FIELDNAME = 'STD_ID_NUM' OR RECFLD.FIELDNAME = 'TIN' OR RECFLD.FIELDNAME = 'SUPERVISOR_PB'
                             OR RECFLD.FIELDNAME = 'SCHEDULER_PB' OR RECFLD.FIELDNAME = 'TECH_LEAD_PB' OR RECFLD.FIELDNAME = 'SUPERVISOR_ID' OR RECFLD.FIELDNAME = 'ENTERED_BY'
                             OR RECFLD.FIELDNAME = 'CUSTODIAN' OR RECFLD.FIELDNAME = 'TEAM_MEMBER' OR RECFLD.FIELDNAME = 'PROJECT_MANAGER' OR RECFLD.FIELDNAME = 'JUSTIFY_EMPLID'
                             OR RECFLD.FIELDNAME = 'PC_IM_ASSIGNED_TO' OR RECFLD.FIELDNAME = 'PC_ASSIGN_TO' OR RECFLD.FIELDNAME = 'OWNER_EMPLID' OR RECFLD.FIELDNAME = 'ASSIGNED_TO_EMPLID'
                             OR RECFLD.FIELDNAME = 'ENTERED_BY' OR RECFLD.FIELDNAME = 'POST_ADMIN' OR RECFLD.FIELDNAME = 'GM_ADMIN_CNTCT' OR RECFLD.FIELDNAME = 'CONTACT_ID'
                             OR RECFLD.FIELDNAME = 'PROJ_MANAGER' OR RECFLD.FIELDNAME = 'EMPLID2' OR RECFLD.FIELDNAME = 'BUDGET_APPROVER' OR RECFLD.FIELDNAME = 'PERSON_ID'
                             OR RECFLD.FIELDNAME = 'PERSON_ID2' OR RECFLD.FIELDNAME = 'HRS_PERSON_ID' OR RECFLD.FIELDNAME = 'WM_EMPLID' OR RECFLD.FIELDNAME = 'WM_EMPLID2'
                             OR RECFLD.FIELDNAME = 'CONTACT_EMPLID' OR RECFLD.FIELDNAME = 'CSTDN_EMPLID')
                           AND EXISTS (SELECT 'X' FROM PSPNLFIELD PNLF WHERE PNLF.RECNAME = RECFLD.RECNAME AND PNLF.FIELDNAME = RECFLD.FIELDNAME))X)
  AND RECFLD.RECNAME NOT IN ('HCR_HANDLE_WK', 'HCR_JOB_WK', 'HCR_ACK_WK', 'HCR_ERROR_WK', 'HCR_CAN_JOB_WK', 'HRS_CAND_UPD_WK', 'SAC_CANDIDATE', 'SP_EXT_TIME_HDR', 'AR_DEDUCTNS_RSP',
                             'AR_DISPUTES_RSP', 'PA_SP_MSG', 'EX_AIRLINE_TKT', 'CC_CARD_DATA_EX', 'EX_EMC_CA_APR_H', 'EX_EMC_ER_APR_H', 'EX_EMC_TR_APR_H', 'PAY_ACKNOWLEDGE',
                             'PAY_ISSUED', 'PAY_REQUEST', 'WRK_PROJ_TAO', 'PROJ_ACT_TEAM', 'PROJECT_TEAM', 'ACCOMPLISHMENTS', 'PERSONAL_DATA', 'EMAIL_ADDRESSES', 'PERSONAL_PHONE',
                             'PERS_DATA_EFFDT', 'PERS_NID', 'RS_EVALUATIONS', 'COMPETENCIES', 'CITIZENSHIP', 'CITIZEN_PSSPRT', 'VISA_PMT_DATA', 'VISA_PMT_SUPPRT', 'RS_SCHED_TASK',
                             'RS_POOL_MEMBER', 'RS_SO_LINE_REC', 'EMPL_PHOTO', 'EMPLOYMENT', 'JOB', 'BEN_PROG_PARTIC', 'COMPENSATION', 'JOB_JR', 'DIVERSITY', 'PRIORWORK_EXPER',
                             'DIRECT_DEPOSIT', 'DIR_DEP_DISTRIB', 'FO_ASGN_XREF', 'TL_EMPL_DATA', 'FO_MC_ART_SEL', 'FO_RATE_ELEMENT')
--  AND RECFLD.RECNAME NOT IN ('RUN_CNTL_PUR', 'RUN_CNTL_FO', 'RUN_CNTL_EX', 'RS_OCP_DSPL_TMP', 'RS_MYDSHBRD_WRK', 'RS_MYRSRC_GRID', 'RS_MYSORDER_WRK', 'PO_REQLOAD_RQST',
--                             'INTFC_BI', 'INTFC_BI_CMP')
    AND RECFLD.RECNAME NOT IN ('PC_COMPRESS_TPL', 'PC_PM_SUMM_TMPL', 'PC_ICLIENT_WRK', 'RUN_CNTL_PC')
    AND RECFLD.RECNAME NOT LIKE 'INSTALLATION%'
--  AND PNLD.PNLNAME = 'GM_EMPL_SRCH_SBP'
--  AND PNLF.ASSOCFIELDNUM = 0
--  AND RECFLD.RECNAME = 'WM_WR_BY_VW'
  AND DBF.FIELDTYPE IN (0, 2, 4)
  AND DBF.LENGTH > 4
  AND (RECFLD.FIELDNAME NOT LIKE 'BUSINESS_UNIT%' AND RECFLD.FIELDNAME NOT LIKE '%SETID%' AND RECFLD.FIELDNAME NOT LIKE '%CURRENCY_CD%' AND RECFLD.FIELDNAME NOT LIKE '%LINE_NBR%')
  AND RECFLD.FIELDNAME NOT IN (SELECT FIELDNAME FROM PS_FS_CF_TEMPLATE)
ORDER BY RECFLD.RECNAME, RECFLD.FIELDNUM;
/
--Verify Table
--SELECT "Record Field Name", A.* FROM PS_ALL_EMP_FSCM_SDF_TBL A WHERE rownum <= 10;
SELECT COUNT(*) FROM PS_ALL_EMP_FSCM_SDF_TBL;
/
--UPDATES
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Person Identifier', "Classification" = 'Person Number', "Personally Identifiable" = 'Yes', "Sensitive" = 'No'
WHERE ("Record Field Name" LIKE '%EMPLID%' OR "Record Field Name" = 'SUPERVISOR_ID' OR "Record Field Name" = 'TEAM_MEMBER' OR "Record Field Name" LIKE '%CANDIDATE_ID%'
    OR "Record Field Name" = 'APPLID' OR "Record Field Name" = 'PRIMARY_SPNSR_ID' OR "Record Field Name" LIKE '%PERSON_ID%' OR "Record Field Name" = 'STD_ID_NUM'
    OR "Record Field Name" = 'TIN' OR "Record Field Name" = 'CONTACT_ID');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Person Identifier', "Classification" = 'Customer Number', "Personally Identifiable" = 'Yes', "Sensitive" = 'No'
WHERE ("Record Field Name" LIKE '%CUST_ID%');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Name Details', "Classification" = 'Person Name', "Personally Identifiable" = 'Yes', "Sensitive" = 'No'
WHERE ("Record Field Name" = 'NAME' OR "Record Field Name" = 'LAST_NAME' OR "Record Field Name" = 'FIRST_NAME' OR "Record Field Name" = 'NAME_DISPLAY' OR "Record Field Name" = 'PERSON_NAME'
    OR "Record Field Name" = 'LEAD_PERSON' OR "Record Field Name" = 'SUPERVISOR' OR "Record Field Name" = 'CUSTODIAN' OR "Record Field Name" = 'NAME2' OR "Record Field Name" = 'MANAGER_NAME'
    OR "Record Field Name" = 'AUTHORIZATION_NAME' OR "Record Field Name" = 'PERSON_NAME_2' OR "Record Field Name" = 'CREATED_USER_NAME' OR "Record Field Name" = 'SUBMIT_USER_NAME'
    OR "Record Field Name" = 'UPDATED_USER_NAME' OR "Record Field Name" = 'PROJECT_MANAGER' OR "Record Field Name" = 'APPROVED_BY' OR "Record Field Name" = 'MIDDLE_NAME'
    OR "Record Field Name" = 'SUPERVISORS_NAME' OR "Record Field Name" = 'APPROVER_NAME' OR "Record Field Name" = 'SUPERVISOR_NAME' OR "Record Field Name" = 'OLD_CUSTODIAN'
    OR "Record Field Name" LIKE 'NAME1%' OR "Record Field Name" LIKE 'NAME2%' OR "Record Field Name" = 'NAME3' OR "Record Field Name" = 'NAME4' OR "Record Field Name" = 'MEMBER_NAME'
    OR "Record Field Name" = 'LASTNAME_IN' OR "Record Field Name" = 'FIRSTNAME_IN' OR "Record Field Name" = 'CR_CARD_FNAME' OR "Record Field Name" = 'CR_CARD_LNAME');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Name Details', "Classification" = 'Contact Name', "Personally Identifiable" = 'Yes', "Sensitive" = 'No'
WHERE ("Record Field Name" = 'CNTCT_NAME1' OR "Record Field Name" = 'CONTACT_NAME' OR "Record Field Name" = 'CONTACT_NAME1' OR "Record Field Name" = 'NAME_DISPLAY');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Name Details', "Classification" = 'Mothers Name', "Personally Identifiable" = 'Yes', "Sensitive" = 'Yes'
WHERE ("Record Field Name" = 'F2_MOMS_MAIDN_NAME');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Personal Information', "Classification" = 'Birth Details and Age', "Personally Identifiable" = 'No', "Sensitive" = 'Yes'
WHERE ("Record Field Name" = 'BIRTHDATE' OR "Record Field Name" = 'BIRTHDAY' OR "Record Field Name" = 'BIRTHPLACE');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'User Credentials', "Classification" = 'User Global Identifier', "Personally Identifiable" = 'Yes', "Sensitive" = 'No'
WHERE ("Record Field Name" LIKE '%OPRID%' OR "Record Field Name" = 'APPROVER_PROFILE' OR "Record Field Name" = 'ENTERED_BY' OR "Record Field Name" = 'APPROVER_ID'
    OR "Record Field Name" = 'SPB_USER_ID' OR "Record Field Name" = 'ROLEUSER_ALT' OR "Record Field Name" = 'ROLEUSER_SUPR' OR "Record Field Name" = 'ORIGINATORID'
    OR "Record Field Name" = 'LAST_UPDATED_BY');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'User Credentials', "Classification" = 'Passwords and PINs', "Personally Identifiable" = 'No', "Sensitive" = 'Yes'
WHERE ("Record Field Name" = 'OPERPSWD' OR "Record Field Name" = 'OPERPSWDCONF');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Name Details', "Classification" = 'Unclassified Name', "Personally Identifiable" = 'Yes', "Sensitive" = 'Yes'
WHERE ("Record Field Name" = 'OPRDEFNDESC');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Account Information', "Classification" = 'Bank Account Number', "Personally Identifiable" = 'Yes', "Sensitive" = 'Yes'
WHERE ("Record Field Name" = 'BANK_ACCOUNT_NUM' OR "Record Field Name" = 'REMIT_BANK_ACCOUNT' OR "Record Field Name" = 'FROM_BNK_ACCT_NUM' OR "Record Field Name" = 'CRDMEM_ACCT_NBR');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Contact Details', "Classification" = 'Business Email', "Personally Identifiable" = 'Yes', "Sensitive" = 'No'
WHERE ("Record Field Name" = 'EMAILID' OR "Record Field Name" = 'EMAIL_ADDR' OR "Record Field Name" = 'EMAIL_ID' OR "Record Field Name" = 'EXT_EMAIL_ADDR'
    OR "Record Field Name" = 'NOTIFY_EMAIL_ADDR' OR "Record Field Name" = 'CNTCT_EMAIL_ADDR' OR "Record Field Name" = 'BILL_TO_EMAILADDR' OR "Record Field Name" = 'EMAILID2');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Employment Details', "Classification" = 'Hire and Service Dates', "Personally Identifiable" = 'No', "Sensitive" = 'Yes'
WHERE ("Record Field Name" = 'HIRE_DT');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Compensation', "Classification" = 'Salary, Bonus, Stock', "Personally Identifiable" = 'No', "Sensitive" = 'Yes'
WHERE ("Record Field Name" = 'SALARY');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Location Details', "Classification" = 'Business Address', "Personally Identifiable" = 'Yes', "Sensitive" = 'No'
WHERE ("Record Field Name" = 'ADDRESS1' OR "Record Field Name" = 'ADDRESS2' OR "Record Field Name" = 'TXN_LOCATION' OR "Record Field Name" = 'STATE' OR "Record Field Name" = 'LOCALITY'
    OR "Record Field Name" = 'CITY' OR "Record Field Name" LIKE '%LOCATION%' OR "Record Field Name" = 'STATE_SHIP_TO' OR "Record Field Name" = 'STATE_SHIP_FROM'
    OR "Record Field Name" LIKE '%VNDR_LOC%' OR "Record Field Name" LIKE '%POSTAL%' OR "Record Field Name" = 'ADDRESS3' OR "Record Field Name" = 'ADDRESS4' OR "Record Field Name" = 'ZIP'
    OR "Record Field Name" = 'ADDRESS1_VNDR' OR "Record Field Name" = 'ADDRESS2_VNDR');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Attachments', "Classification" = 'Unclassified Attachment', "Personally Identifiable" = 'Yes', "Sensitive" = 'Yes'
WHERE ("Record Field Name" = 'ATTACHUSERFILE' OR "Record Field Name" = 'ATTACHSYSFILENAME' OR "Record Field Name" = 'FILENAME' OR "Record Field Name" LIKE 'EX_FILE_NAME%'
    OR "Record Field Name" = 'COVER_FILE_NAME');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Contact Details', "Classification" = 'Business Phone', "Personally Identifiable" = 'Yes', "Sensitive" = 'No'
WHERE ("Record Field Name" = 'PHONE' OR "Record Field Name" = 'EXTENSION' OR "Record Field Name" = 'AVAIL_PHONE' OR "Record Field Name" = 'CNTCT_EXTENSION'
    OR "Record Field Name" = 'CNTCT_FAX' OR "Record Field Name" = 'SUPERVISORS_PHONE' OR "Record Field Name" = 'SUPERVISORS_EXT' OR "Record Field Name" = 'FAX'
    OR "Record Field Name" = 'FAX_NUM');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Contact Details', "Classification" = 'Personal Phone', "Personally Identifiable" = 'Yes', "Sensitive" = 'Yes'
WHERE ("Record Field Name" = 'EMP_PHONE_NBR' OR "Record Field Name" = 'PHONE_NUM');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Account Information', "Classification" = 'Unique Banking Key', "Personally Identifiable" = 'Yes', "Sensitive" = 'Yes'
WHERE ("Record Field Name" = 'IBAN_ID');
/
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = 'Credit Cards', "Classification" = 'Credit or Debit Card Number', "Personally Identifiable" = 'Yes', "Sensitive" = 'Yes'
WHERE ("Record Field Name" LIKE 'CR_CARD_NBR%' OR "Record Field Name" = 'CREDIT_CARD_VENDOR');
/
--UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = '##N/A##', "Classification" = '##N/A##', "Personally Identifiable" = 'No', "Sensitive" = 'No'
UPDATE PS_ALL_EMP_FSCM_SDF_TBL SET "Category" = '##XX##', "Classification" = '##XX##', "Personally Identifiable" = 'No', "Sensitive" = 'No'
WHERE ("Record Field Name" LIKE 'BUSINESS_UNIT%' OR "Record Field Name" LIKE '%SETID%' OR "Record Field Name" LIKE '%CURRENCY_CD%' OR "Record Field Name" LIKE '%LINE_NBR%'
    OR "Record Field Name" LIKE '%DISTRIB_LINE%' OR "Record Field Name" LIKE '%ASSET_ID%' OR "Record Field Name" LIKE 'PROFILE_ID%' OR "Record Field Name" LIKE 'RESOURCE_ID%'
    OR "Record Field Name" LIKE 'SERIAL_ID%' OR "Record Field Name" LIKE 'SHEET_ID%' OR "Record Field Name" LIKE 'TRAVEL_AUTH_ID%' OR "Record Field Name" LIKE 'PO_ID%'
    OR "Record Field Name" LIKE 'INTFC_ID%' OR "Record Field Name" LIKE 'VOUCHER_ID%' OR "Record Field Name" LIKE 'RECEIVER_ID%' OR "Record Field Name" LIKE 'SHOP_ID%'
    OR "Record Field Name" LIKE 'TIME_SHEET_ID%' OR "Record Field Name" LIKE '%WO_ID%' OR "Record Field Name" LIKE 'WO_TASK_ID%' OR "Record Field Name" LIKE 'RES_LN_NBR%'
    OR "Record Field Name" LIKE '%END_DT%' OR "Record Field Name" LIKE '%QTY%' OR "Record Field Name" LIKE 'ENTRY_EVENT%' OR "Record Field Name" LIKE 'DISTRIB_PCT%'
    OR "Record Field Name" LIKE 'REQ_ID%' OR "Record Field Name" LIKE 'JOURNAL%' OR "Record Field Name" LIKE 'LEDGER_GROUP%' OR "Record Field Name" LIKE 'CUR_EFFDT%'
    OR "Record Field Name" LIKE 'RATE_DIV%' OR "Record Field Name" LIKE 'RATE_MULT%' OR "Record Field Name" LIKE '%RT_TYPE%' OR "Record Field Name" LIKE '%BUS_UNIT%'
    OR "Record Field Name" LIKE '%SEQ_NUM%' OR "Record Field Name" LIKE '%IP_ADDRESS%' OR "Record Field Name" LIKE '%AREA_ID%' OR "Record Field Name" LIKE 'INV_ITEM_ID%'
    OR "Record Field Name" LIKE 'EX_DOC_ID%' OR "Record Field Name" LIKE '%JRNL_ID%' OR "Record Field Name" LIKE '%END_DATE%' OR "Record Field Name" LIKE '%START_DATE%'
    OR "Record Field Name" LIKE '%CONTRACT_NUM%' OR "Record Field Name" LIKE '%TEMPLATE%' OR "Record Field Name" LIKE 'NEWVALUE%' OR "Record Field Name" LIKE 'OLDVALUE%'
    OR "Record Field Name" LIKE 'PC_CHC_INFO_REASON%' OR "Record Field Name" LIKE 'BUDGET_CATEGORY%' OR "Record Field Name" LIKE 'PC_BUDGET_ITEM%' OR "Record Field Name" LIKE 'BUDGET_PERIOD%'
    OR "Record Field Name" LIKE '%ROW_NUM%' OR "Record Field Name" LIKE 'PROCESS_INSTANCE%' OR "Record Field Name" LIKE 'RUN_CNTL_ID%' OR "Record Field Name" LIKE '%DEPOSIT_ID%'
    OR "Record Field Name" LIKE 'GROUP_BU%' OR "Record Field Name" LIKE '%GROUP_ID%' OR "Record Field Name" LIKE 'PAYMENT_ID%' OR "Record Field Name" LIKE 'PMT_ID%'
    OR "Record Field Name" LIKE '%DEPOSIT_BU%' OR "Record Field Name" LIKE '%LN_NBR%' OR "Record Field Name" LIKE 'KK_TRAN%' OR "Record Field Name" LIKE 'KK_SOURCE%'
    OR "Record Field Name" LIKE 'KK_PROC%' OR "Record Field Name" LIKE 'RUN_DT%' OR "Record Field Name" LIKE '%SEQ_NBR%' OR "Record Field Name" LIKE 'TAG_NUMBER%'
    OR "Record Field Name" LIKE 'MODEL%' OR "Record Field Name" LIKE 'MANUFACTURER%' OR "Record Field Name" LIKE 'FUND_SOURCE%' OR "Record Field Name" LIKE 'INTFC_LINE%'
    OR "Record Field Name" LIKE '%LINE_NUM%' OR "Record Field Name" LIKE 'MFG_ID%' OR "Record Field Name" LIKE '%PROPERTY_ID%' OR "Record Field Name" LIKE 'ACQUISITION_DT%'
    OR "Record Field Name" LIKE 'COMPONENT_OF_ID%' OR "Record Field Name" LIKE 'PARENT_ID%' OR "Record Field Name" LIKE 'MC_DEFN_ID%' OR "Record Field Name" LIKE '%REF_NO%'
    OR "Record Field Name" LIKE '%SOURCE_ID%' OR "Record Field Name" LIKE '%CYCLE_ID%' OR "Record Field Name" LIKE '%TAX_CD_VAT%' OR "Record Field Name" LIKE '%PO_SCHED%'
    OR "Record Field Name" LIKE '%PO_LINE%' OR "Record Field Name" LIKE '%VOUCHER_NBR%' OR "Record Field Name" LIKE '%TAX_D%' OR "Record Field Name" LIKE 'GROUP_CODE%'
    OR "Record Field Name" LIKE '%CONTR_ID%' OR "Record Field Name" LIKE 'RT_EFFDT%' OR "Record Field Name" LIKE 'RMA_ID%' OR "Record Field Name" LIKE 'PRODUCT_ID%'
    OR "Record Field Name" LIKE 'TAX_G%' OR "Record Field Name" LIKE 'TAX_U%' OR "Record Field Name" LIKE 'TAX_E%' OR "Record Field Name" LIKE 'TAX_C%' OR "Record Field Name" LIKE 'PROJECT_T%'
    OR "Record Field Name" LIKE '%PROJECT_ID%' OR "Record Field Name" LIKE 'CUSTOMER_TY%' OR "Record Field Name" LIKE 'PO_REF%' OR "Record Field Name" LIKE 'CONTRACT_TYPE%'
    OR "Record Field Name" LIKE 'ENTRY_TYPE%' OR "Record Field Name" LIKE 'BILL_PLAN_ID%' OR "Record Field Name" LIKE 'BILL_OF_LADING%' OR "Record Field Name" LIKE '%ADDR_NUM%'
    OR "Record Field Name" LIKE 'FREIGHT_TERMS%' OR "Record Field Name" LIKE 'ORDER_DATE%' OR "Record Field Name" LIKE 'SHIP_ID%' OR "Record Field Name" LIKE 'SHIP_TYPE_ID%'
    OR "Record Field Name" LIKE 'SHIP_FROM_BU%' OR "Record Field Name" LIKE 'SHIP_DATE%' OR "Record Field Name" LIKE '%INVOICE%' OR "Record Field Name" LIKE '%SEQUENCENO%'
    OR "Record Field Name" LIKE '%PAGE_TITLE%' OR "Record Field Name" LIKE '%ADVANCE_ID%' OR "Record Field Name" LIKE 'DST_CNTRL_ID%' OR "Record Field Name" LIKE 'REFERENCE_ID%'
    OR "Record Field Name" LIKE 'TOTAL_ROWS%' OR "Record Field Name" LIKE 'EXPENSE_TYPE%' OR "Record Field Name" LIKE '%NUM_STATUS%' OR "Record Field Name" LIKE 'VAT_ENTITY%'
    OR "Record Field Name" LIKE '%COMMENTS%' OR "Record Field Name" LIKE 'PYMNT_ID%' OR "Record Field Name" LIKE 'SUBMISSION_DATE%' OR "Record Field Name" LIKE '%SUBMISSION_DT%'
    OR "Record Field Name" LIKE '%VERIFY_DT%' OR "Record Field Name" LIKE 'AIRFARE_RCPT_NBR%' OR "Record Field Name" LIKE 'CUR_EXCHNG_RT%' OR "Record Field Name" LIKE 'TOTAL_HOURS%'
    OR "Record Field Name" LIKE 'REMAINING_HRS%' OR "Record Field Name" LIKE 'REF_AWD_NUMBER%' OR "Record Field Name" LIKE 'AWARD_DT%' OR "Record Field Name" LIKE 'PROPOSAL_ID%'
    OR "Record Field Name" LIKE 'INITIAL_AWD_AMT%' OR "Record Field Name" LIKE 'PCL_ID%' OR "Record Field Name" LIKE 'PCL_VRSN_ID%' OR "Record Field Name" LIKE 'PORTAL_NAME%'
    OR "Record Field Name" LIKE 'NODE_NAME%' OR "Record Field Name" LIKE 'VERSION_ID%' OR "Record Field Name" LIKE 'TITLE56%' OR "Record Field Name" LIKE '%AMT_EXP%'
    OR "Record Field Name" LIKE 'SUB_PROP_NBR%' OR "Record Field Name" LIKE 'AWARD_STATUS%' OR "Record Field Name" LIKE 'PROJECT_STATUS%' OR "Record Field Name" LIKE 'PI_ID%'
    OR "Record Field Name" LIKE 'PSDMUNIT_ID%' OR "Record Field Name" LIKE 'BOOK%' OR "Record Field Name" LIKE 'TRANS_CODE%' OR "Record Field Name" LIKE 'ACCOUNTING_DT%'
    OR "Record Field Name" LIKE 'TRANS_DT%' OR "Record Field Name" LIKE 'MEASUREMENT_DT%' OR "Record Field Name" LIKE 'WR_ID%' OR "Record Field Name" LIKE 'WO_DURATION%'
    OR "Record Field Name" LIKE 'PM_SCHD_ID%' OR "Record Field Name" LIKE '%START_DT%' OR "Record Field Name" LIKE 'SCHEDULER_CODE%' OR "Record Field Name" LIKE 'VIN%'
    OR "Record Field Name" LIKE 'RETURN_LNK%' OR "Record Field Name" LIKE 'ASSET_DESCR%' OR "Record Field Name" LIKE 'TASK_DESCR%' OR "Record Field Name" LIKE '%GRP_ID%'
    OR "Record Field Name" LIKE 'WM_WOE_RPT_LABEL%' OR "Record Field Name" LIKE 'CUSTODIAN_DEPTID%' OR "Record Field Name" LIKE 'ASSET_SUBTYPE%' OR "Record Field Name" LIKE '%FROM_DT%'
    OR "Record Field Name" LIKE '%TO_DT%' OR "Record Field Name" LIKE '%TAX_AUTH_CD%' OR "Record Field Name" LIKE '%TAX_RATE_CD%' OR "Record Field Name" LIKE '%SPEEDCHART%'
    OR "Record Field Name" LIKE 'ROLENAME%' OR "Record Field Name" LIKE 'BILLING_DATE%' OR "Record Field Name" LIKE 'AIRFARE_RCPT_NBR%' OR "Record Field Name" LIKE '%THRU_DATE%'
    OR "Record Field Name" LIKE '%THRU_DT%' OR "Record Field Name" LIKE 'JRNL_CODE%' OR "Record Field Name" LIKE 'TIP_STAGE%' OR "Record Field Name" LIKE 'WALLET_COUNT%'
    OR "Record Field Name" LIKE 'AUDIT_EXCEPTION%' OR "Record Field Name" LIKE '%DATE_TO%' OR "Record Field Name" LIKE 'TRANSACTION_ID%' OR "Record Field Name" LIKE 'TRANSACTION_TITLE%'
    OR "Record Field Name" LIKE 'SHEET_NAME%' OR "Record Field Name" LIKE 'CREATION_DT%' OR "Record Field Name" LIKE 'TRAVEL_AUTH_NAME%' OR "Record Field Name" LIKE 'DATE_FROM%'
    OR "Record Field Name" LIKE 'ADVANCE_NAME%' OR "Record Field Name" LIKE 'BCPGNAME%' OR "Record Field Name" LIKE 'SO_ID%' OR "Record Field Name" LIKE 'BCNAME%'
    OR "Record Field Name" LIKE '%AWARD_ID%' OR "Record Field Name" LIKE '%AWD_AMT%' OR "Record Field Name" LIKE 'MAX_ROWS_SCROLL%' OR "Record Field Name" LIKE 'RECORD_COUNT%'
    OR "Record Field Name" LIKE 'START_ROW%' OR "Record Field Name" LIKE 'END_ROW%' OR "Record Field Name" LIKE 'BARITEMNAME%' OR "Record Field Name" LIKE 'CF_SEQNO%'
    OR "Record Field Name" LIKE 'SP_ID%' OR "Record Field Name" LIKE 'ASSET_CLASS%' OR "Record Field Name" LIKE 'CAP_NUM%' OR "Record Field Name" LIKE 'COMPOSITE_ID%'
    OR "Record Field Name" LIKE 'CAP_THRSHLD_ID%' OR "Record Field Name" LIKE 'ARO_ID%' OR "Record Field Name" LIKE 'VAT_PRODUCT_GROUP%' OR "Record Field Name" LIKE 'PRODUCT_KIT_ID%'
    OR "Record Field Name" LIKE 'CONTRACT_DT%' OR "Record Field Name" LIKE 'ORDER_NO%' OR "Record Field Name" LIKE '%INT_LINE_NO%' OR "Record Field Name" LIKE 'PACKSLIP_NO%'
    OR "Record Field Name" LIKE '%INT_LINE_NO%' OR "Record Field Name" LIKE '%PPD_SEQ%' OR "Record Field Name" LIKE 'TRANS_NBR%' OR "Record Field Name" LIKE 'COMPETENCY%'
    OR "Record Field Name" LIKE 'PORTAL_OBJNAME%' OR "Record Field Name" LIKE 'GM_BEGIN_DT%' OR "Record Field Name" LIKE 'APPROVAL_DT%' OR "Record Field Name" LIKE 'OPRCLASS%'
    OR "Record Field Name" LIKE 'ROWSECCLASS%' OR "Record Field Name" LIKE 'IN_SERVICE_DT%' OR "Record Field Name" LIKE 'MESSAGE_SET_NBR%' OR "Record Field Name" LIKE 'MESSAGE_NBR%'
    OR "Record Field Name" LIKE 'INTEGRATION_TMPL%' OR "Record Field Name" LIKE '%DISTRIB_NBR%' OR "Record Field Name" LIKE '%LINE_NO%' OR "Record Field Name" LIKE 'PERCENT_COMPLETE%'
    OR "Record Field Name" LIKE '%SCHED_NUM%' OR "Record Field Name" LIKE 'SEQUENCE_NBR_6%' OR "Record Field Name" LIKE 'RETIREMENT_DT%' OR "Record Field Name" LIKE 'PRCSPRFLCLS%'
    OR "Record Field Name" LIKE 'DEFAULTNAVHP%' OR "Record Field Name" LIKE 'CLASSDEFNDESC%' OR "Record Field Name" LIKE 'ACCTG_TMPL_ID%' OR "Record Field Name" LIKE 'ACTIVITY_ID_DETAIL%'
    OR "Record Field Name" LIKE 'ACTIVITY_ID_FROM%' OR "Record Field Name" LIKE 'APPR_INSTANCE%' OR "Record Field Name" LIKE 'AUDIT_RECNAME%' OR "Record Field Name" LIKE 'CA_AP_TMPL_ID%'
    OR "Record Field Name" LIKE 'CA_BP_TMPL_ID%' OR "Record Field Name" LIKE 'DISTR_LN_NUM_FROM%' OR "Record Field Name" LIKE 'DISTR_LN_NUM_FROM%' OR "Record Field Name" LIKE 'DRAFT_BU%'
    OR "Record Field Name" LIKE 'DRAFT_ID%' OR "Record Field Name" LIKE 'DST_ID_AR%' OR "Record Field Name" LIKE 'EOEC_CCI_COMMENT%' OR "Record Field Name" LIKE 'TREECNTRLFIELD%'
    OR "Record Field Name" LIKE 'TO_BU%' OR "Record Field Name" LIKE 'TMPLDEFN_ID%' OR "Record Field Name" LIKE 'TMPLT_ID%' OR "Record Field Name" LIKE 'TOLERANCE_AMT%'
    OR "Record Field Name" LIKE 'TOOLS_ASSET_SUBTYP%' OR "Record Field Name" LIKE 'TAX_PCT%' OR "Record Field Name" LIKE 'TD_TREE_EFFDT_PROD%' OR "Record Field Name" LIKE 'TD_TREE_ID_CUST%'
    OR "Record Field Name" LIKE 'TD_TREE_ID_PROD%' OR "Record Field Name" LIKE 'SUBMIT_BTN%' OR "Record Field Name" LIKE 'SUBMIT_DT%' OR "Record Field Name" LIKE 'SETCNTRLVALUE%'
    OR "Record Field Name" LIKE '%RT_RATE%' OR "Record Field Name" LIKE '%ROWCOUNTER%' OR "Record Field Name" LIKE 'ROLE_TYPE%' OR "Record Field Name" LIKE 'RECEIPTS_ON_HOLD%'
    OR "Record Field Name" LIKE 'RECEIPT_NBR%' OR "Record Field Name" LIKE '%RECNAME%' OR "Record Field Name" LIKE 'RECON_ID%' OR "Record Field Name" LIKE 'PYCYCL_KEY_FIELD%'
    OR "Record Field Name" LIKE 'PTNODE_DESCR%' OR "Record Field Name" LIKE 'PTDESCR%IMG' OR "Record Field Name" LIKE 'PSIMAGEVER%' OR "Record Field Name" LIKE 'PTCHART_NODE%'
    OR "Record Field Name" LIKE 'PTCONNECTLINESTYLE%' OR "Record Field Name" LIKE 'PARENT_NODE%' OR "Record Field Name" LIKE 'PARENT_NODE_NAME%' OR "Record Field Name" LIKE '%FIELDNAME%'
    OR "Record Field Name" LIKE 'LINE_ROW%' OR "Record Field Name" LIKE 'LOADER_BU%' OR "Record Field Name" LIKE 'LOADER_REQ_ID%' OR "Record Field Name" LIKE 'LOAD_ID%'
    OR "Record Field Name" LIKE 'LOC_DOC_ID%' OR "Record Field Name" LIKE 'LOC_REFERENCE_ID%' OR "Record Field Name" LIKE 'LOT_ID%' OR "Record Field Name" LIKE 'MACHINENAME%'
    OR "Record Field Name" LIKE 'LC_ID%' OR "Record Field Name" LIKE 'LEDGER%' OR "Record Field Name" LIKE 'LEDGER_TYPE_ID%'
    OR "Record Field Name" LIKE 'HP_KK_DOC_ID%' OR "Record Field Name" LIKE 'IBPUBTRANSACTID%' OR "Record Field Name" LIKE 'GP_PAYGROUP%' OR "Record Field Name" LIKE 'GROUPBY%'
    OR "Record Field Name" LIKE 'FIELDVAL%' OR "Record Field Name" LIKE 'FIELD_DESCR%' OR "Record Field Name" LIKE 'FIELD_VALUE%' OR "Record Field Name" LIKE 'PROJ_ROLE%'
    OR "Record Field Name" LIKE 'EVENT_TYPE%' OR "Record Field Name" LIKE 'CRAFT_ID%');
/
SELECT A.* FROM PS_ALL_EMP_FSCM_SDF_TBL A WHERE "Personally Identifiable" = 'Yes' and rownum <= 10;
/
