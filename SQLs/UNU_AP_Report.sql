--UNU_AP_POSTED_TRANS_DETAIL - 2015
--With Column labels as per PSQuery
SELECT A.BUSINESS_UNIT "AP Bus Unit", A.VOUCHER_ID "Voucher Id", B.VOUCHER_STYLE "Voucher Style", B.VENDOR_ID "Vendor Id", C.NAME1 "Vendor Name 1", C.NAME2 "Vendor Name 2",
            B.INVOICE_ID "Invoice", B.INVOICE_DT "Invoice Date", A.UNPOST_SEQ "Unpost Seq", A.POSTING_PROCESS "Posting Process", A.PYMNT_CNT "Pymnt Cnt", 
            A.VOUCHER_LINE_NUM "Voucher Line", A.DISTRIB_LINE_NUM "Distrib Line", A.DST_ACCT_TYPE "Distrib Type", A.ACCOUNTING_DT "Accounting Date", 
            A.BUSINESS_UNIT_PO "PO Bus Unit", A.PO_ID "PO NO.", A.LINE_NBR "PO Line", A.SCHED_NBR "PO Sched", A.PO_DIST_LINE_NUM "PO Distrib", 
            A.BUSINESS_UNIT_RECV "Recv Bus Unit", A.RECEIVER_ID "Receipt No", A.RECV_LN_NBR "Receipt Line", A.RECV_SHIP_SEQ_NBR "Receipt Ship", 
            A.RECV_DIST_LINE_NUM "Receipt Distrib", A.SHIPTO_ID "Ship To", A.POSTING_DATE "Posting Date", A.BUSINESS_UNIT_GL "GL Bus Unit", A.ACCOUNT "Account", 
            A.OPERATING_UNIT "Oper Unit", A.FUND_CODE "Fund", A.DEPTID "DeptID", A.BUSINESS_UNIT_PC "PC Bus Unit", A.PROJECT_ID "Project", A.ACTIVITY_ID "Activity", 
            A.CHARTFIELD2 "Donor", A.OPEN_ITEM_KEY "Open Item Key", A.BUDGET_DT "Budget Date", A.DESCR "Line Descr", A.JOURNAL_ID "Journal ID", 
            A.JOURNAL_DATE "Journal Date", A.JOURNAL_LINE "Journal Line", A.FISCAL_YEAR "Fiscal Year", A.ACCOUNTING_PERIOD "Accounting Period", 
            A.FOREIGN_AMOUNT "Amount(Txn Curr)", A.FOREIGN_CURRENCY "Txn Currency", A.RATE_MULT "Exch Rate Multiplier", A.RATE_DIV "Exch Rate Divisor", 
            A.MONETARY_AMOUNT "Amount(USD)", A.QTY_VCHR "Quantity"
FROM PS_VCHR_ACCTG_LINE A, PS_VOUCHER B, PS_VENDOR C, PS_JRNL_HEADER D
WHERE A.DST_ACCT_TYPE IN ('DST','RXL','RXG')
    AND A.GL_DISTRIB_STATUS = 'D'
    AND A.BUSINESS_UNIT_GL = 'UNUNI'    
    AND A.BUSINESS_UNIT = B.BUSINESS_UNIT
    AND A.VOUCHER_ID = B.VOUCHER_ID
    AND C.VENDOR_ID = B.VENDOR_ID
    AND C.SETID = B.VENDOR_SETID
    AND A.BUSINESS_UNIT_GL = D.BUSINESS_UNIT
    AND D.JOURNAL_ID = A.JOURNAL_ID
    AND D.JOURNAL_DATE = A.JOURNAL_DATE
    AND D.JRNL_HDR_STATUS IN ('P','U')
    AND D.UNPOST_SEQ = 0
    AND A.ACCOUNTING_DT BETWEEN TO_DATE('2015-01-01','YYYY-MM-DD') AND TO_DATE('2015-12-31','YYYY-MM-DD')    
ORDER BY 1, 2, 9, 10, 11, 12, 13, 14;
--UNU_AP_PAYMENT_DETAILS - 2015
SELECT A.BANK_SETID "Bank SetID", A.BANK_CD "Bank Code", A.BANK_ACCT_KEY "Bank Account Key", A.BNK_ID_NBR "Source Bank ID", A.BANK_ACCOUNT_NUM "Source Account #", 
            A.PYMNT_METHOD "Payment Method", A.PYMNT_ID_REF "Payment Ref", A.PYMNT_DT "Payment Date", A.STTLMNT_DT_EST "Est Settlement Date", 
            A.ACCOUNTING_DT "Payment Accounting Date", A.PAY_CYCLE "pay Cycle", A.PAY_CYCLE_SEQ_NUM "Pay Cycle Seq", A.NAME1 "Payee Name 1", A.NAME2 "Payee Name 2", 
            E.NAME1 "Remit Vendor Name", A.ADDRESS1 "Remit Address 1", A.ADDRESS2 "Remit Address 2", A.ADDRESS3 "Remit Address 3", A.ADDRESS4 "Remit Address 4", 
            A.CITY "Remit City", A.STATE "Remit State", A.POSTAL "Remit Postal", A.COUNTRY "Remit Country", A.PYMNT_AMT "Payment Amount", A.CURRENCY_PYMNT "Payment Currency", 
            F.VNDR_LOC "Remit Location", F.BANK_ACCT_SEQ_NBR "Bank Seq Nbr", F.DESCR "Bank Description", F.COUNTRY "Bank Country", F.BENEFICIARY_BANK "Bank Name", 
            F.ADDRESS1 "Bank Address 1", F.ADDRESS2 "Bank Address 2", F.CITY "Bank City", F.STATE "Bank State", F.POSTAL "Bank Postal", F.BANK_ID_QUAL "Bank Id Qualifier", 
            F.BNK_ID_NBR "Bank Id", F.DFI_ID_QUAL "DFI Qualifier", F.DFI_ID_NUM "DFI Id", F.BENEF_BRANCH "Branch Name", F.BRANCH_ID "Branch", F.BANK_ACCT_TYPE "Acct Type", 
            F.BANK_ACCOUNT_NUM "Account #", F.CHECK_DIGIT "Check Digit", F.IBAN_ID "IABN", G.INTRMED_SEQ_NO "Interm Seq Num", G.INTRMED_DFI_ID "Interm DFI Id", 
            G.INTRMED_PYMNT_MSG "Interm Message", A.EFT_LAYOUT_CD "EFT Layout", A.EFT_PYMNT_FMT_CD "EFT Payment Format", G.STL_ROUTING_METHOD "EFT Routing", 
            B.BUSINESS_UNIT "Business Unit", B.VOUCHER_ID "Voucher Id", D.NAME1 "Voucher Vendor Name", C.INVOICE_ID "Invoice Id", C.INVOICE_DT "Invoice Date", 
            B.PYMNT_CNT "Pymnt Cnt", B.PYMNT_MESSAGE "Payment Message"
FROM PS_PAYMENT_TBL A, PS_PYMNT_VCHR_XREF B, PS_VOUCHER C, PS_VENDOR D, PS_VENDOR E, 
         (PS_VNDR_BANK_ACCT F LEFT OUTER JOIN  PS_VNDR_IBANK_ACCT G ON  F.SETID = G.SETID 
                                                                                                               AND F.VENDOR_ID = G.VENDOR_ID 
                                                                                                               AND F.VNDR_LOC = G.VNDR_LOC 
                                                                                                               AND F.EFFDT = G.EFFDT 
                                                                                                               AND F.BANK_ACCT_SEQ_NBR = G.BANK_ACCT_SEQ_NBR)
WHERE (A.BANK_SETID = 'SHARE'
     AND A.BANK_CD LIKE '6%'
     --AND A.BANK_ACCT_KEY LIKE :3
     --AND A.PYMNT_METHOD LIKE :4
     AND A.PYMNT_DT >= TO_DATE('2015-01-01','YYYY-MM-DD')
     AND A.PYMNT_DT <= TO_DATE('2015-12-31','YYYY-MM-DD')
     AND A.BANK_SETID = B.BANK_SETID
     AND A.BANK_CD = B.BANK_CD
     AND A.BANK_ACCT_KEY = B.BANK_ACCT_KEY
     AND A.PYMNT_ID = B.PYMNT_ID
     AND A.PYMNT_STATUS = 'P'
     AND B.BUSINESS_UNIT = C.BUSINESS_UNIT
     AND B.VOUCHER_ID = C.VOUCHER_ID
     AND D.SETID = C.VENDOR_SETID
     AND D.VENDOR_ID = C.VENDOR_ID
     AND E.SETID = A.REMIT_SETID
     AND E.VENDOR_ID = A.REMIT_VENDOR
     AND F.EFFDT = (SELECT MAX(F_ED.EFFDT) FROM PS_VNDR_BANK_ACCT F_ED WHERE F.SETID = F_ED.SETID AND F.VENDOR_ID = F_ED.VENDOR_ID 
                                                                                                                             AND F.VNDR_LOC = F_ED.VNDR_LOC)
     AND F.SETID = A.REMIT_SETID
     AND F.VENDOR_ID = A.REMIT_VENDOR
     AND F.VNDR_LOC = A.VNDR_LOC
     AND F.BANK_ACCT_SEQ_NBR = B.BANK_ACCT_SEQ_NBR)
UNION
SELECT H.BANK_SETID, H.BANK_CD, H.BANK_ACCT_KEY, H.BNK_ID_NBR, H.BANK_ACCOUNT_NUM, H.PYMNT_METHOD, H.PYMNT_ID_REF, H.PYMNT_DT, H.STTLMNT_DT_EST, 
            H.ACCOUNTING_DT, H.PAY_CYCLE, H.PAY_CYCLE_SEQ_NUM, H.NAME1, H.NAME2, L.NAME1, H.ADDRESS1, H.ADDRESS2, H.ADDRESS3, H.ADDRESS4, H.CITY, H.STATE, 
            H.POSTAL, H.COUNTRY, H.PYMNT_AMT, H.CURRENCY_PYMNT, H.VNDR_LOC, I.BANK_ACCT_SEQ_NBR, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 0, '', '', H.EFT_LAYOUT_CD, 
            H.EFT_PYMNT_FMT_CD, '', I.BUSINESS_UNIT, I.VOUCHER_ID, K.NAME1, J.INVOICE_ID, J.INVOICE_DT, I.PYMNT_CNT, I.PYMNT_MESSAGE
FROM PS_PAYMENT_TBL H, PS_PYMNT_VCHR_XREF I, PS_VOUCHER J, PS_VENDOR K, PS_VENDOR L
WHERE (H.BANK_SETID = 'SHARE'
     AND H.BANK_CD LIKE '6%'
     --AND H.BANK_ACCT_KEY LIKE :3
     --AND H.PYMNT_METHOD LIKE :4
     AND H.PYMNT_DT >= TO_DATE('2015-01-01','YYYY-MM-DD')
     AND H.PYMNT_DT <= TO_DATE('2015-12-31','YYYY-MM-DD')
     AND H.BANK_SETID = I.BANK_SETID
     AND H.BANK_CD = I.BANK_CD
     AND H.BANK_ACCT_KEY = I.BANK_ACCT_KEY
     AND H.PYMNT_ID = I.PYMNT_ID
     AND I.BUSINESS_UNIT = J.BUSINESS_UNIT
     AND I.VOUCHER_ID = J.VOUCHER_ID
     AND K.SETID = J.VENDOR_SETID
     AND K.VENDOR_ID = J.VENDOR_ID
     AND L.SETID = H.REMIT_SETID
     AND L.VENDOR_ID = H.REMIT_VENDOR
     AND H.PYMNT_STATUS = 'P'
     AND NOT EXISTS (SELECT M.SETID FROM PS_VNDR_BANK_ACCT M WHERE M.SETID = L.SETID AND M.VENDOR_ID = L.VENDOR_ID AND M.VNDR_LOC = H.VNDR_LOC 
                                                                                                             AND M.BANK_ACCT_SEQ_NBR = I.BANK_ACCT_SEQ_NBR))
ORDER BY 1, 2, 3, 8, 7, 52, 53, 57;
