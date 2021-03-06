SELECT * 
  FROM ( 
 SELECT DISTINCT T1.SETID 
 ,T1.TREE_NAME 
 ,T1.EFFDT 
 ,T1.TREE_NODE LVL1 
 ,TN1.DESCR AS LVL1_DESCR 
 ,' ' LVL2 
 ,' ' LVL2_DESCR 
 ,' ' LVL3 
 ,' ' LVL3_DESCR 
 ,' ' LVL4 
 ,' ' LVL4_DESCR 
 ,' ' LVL5 
 ,' ' LVL5_DESCR 
 ,' ' LVL6 
 ,' ' LVL6_DESCR 
 ,' ' LVL7 
 ,' ' LVL7_DESCR 
 ,' ' LVL8 
 ,' ' LVL8_DESCR 
 ,' ' LVL9 
 ,' ' LVL9_DESCR 
 ,LF.RANGE_FROM 
 ,LF.RANGE_TO 
  FROM PSTREENODE T1 
  , PSTREELEAF LF 
  , PS_TREE_NODE_TBL TN1 
 WHERE T1.SETID = LF.SETID 
   AND T1.TREE_NAME = LF.TREE_NAME 
   AND T1.EFFDT = LF.EFFDT 
   AND T1.TREE_NODE_NUM = 1 
   AND T1.TREE_NODE_NUM = LF.TREE_NODE_NUM 
   AND T1.PARENT_NODE_NUM = 0 
   AND T1.SETID = TN1.SETID 
   AND T1.TREE_NODE = TN1.TREE_NODE 
   AND %EffdtCheck(PSTREELEAF LF_A, LF, %CurrentDateIn) 
   AND %EffdtCheck(PSTREENODE T1_A, T1, LF.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN1_A, TN1, T1.EFFDT) 
  UNION 
 SELECT DISTINCT T1.SETID 
 ,T1.TREE_NAME 
 ,T1.EFFDT 
 ,T1.TREE_NODE LVL1 
 ,TN1.DESCR LVL1_DESCR 
 ,T2.TREE_NODE LVL2 
 ,TN2.DESCR LVL2_DESCR 
 ,' ' LVL3 
 ,' ' LVL3_DESCR 
 ,' ' LVL4 
 ,' ' LVL4_DESCR 
 ,' ' LVL5 
 ,' ' LVL5_DESCR 
 ,' ' LVL6 
 ,' ' LVL6_DESCR 
 ,' ' LVL7 
 ,' ' LVL7_DESCR 
 ,' ' LVL8 
 ,' ' LVL8_DESCR 
 ,' ' LVL9 
 ,' ' LVL9_DESCR 
 ,LF.RANGE_FROM 
 ,LF.RANGE_TO 
  FROM PSTREENODE T1 
  , PS_TREE_NODE_TBL TN1 
  , PSTREENODE T2 
  , PS_TREE_NODE_TBL TN2 
  , PSTREELEAF LF 
 WHERE T1.SETID = T2.SETID 
   AND T1.TREE_NAME = T2.TREE_NAME 
   AND T1.EFFDT = T2.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T1.SETID = LF.SETID 
   AND T1.TREE_NAME = LF.TREE_NAME 
   AND T1.EFFDT = LF.EFFDT 
   AND T2.TREE_NODE_NUM = LF.TREE_NODE_NUM 
   AND T1.PARENT_NODE_NUM = 0 
   AND T1.SETID = TN1.SETID 
   AND T2.SETID = TN2.SETID 
   AND T1.TREE_NODE = TN1.TREE_NODE 
   AND T2.TREE_NODE = TN2.TREE_NODE 
   AND %EffdtCheck(PSTREELEAF LF_A, LF, %CurrentDateIn) 
   AND %EffdtCheck(PSTREENODE T1_A, T1, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T2_A, T2, LF.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN1_A, TN1, T1.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN2_A, TN2, T2.EFFDT) 
  UNION 
 SELECT DISTINCT T1.SETID 
 ,T1.TREE_NAME 
 ,T1.EFFDT 
 ,T1.TREE_NODE LVL1 
 ,TN1.DESCR LVL1_DESCR 
 ,T2.TREE_NODE LVL2 
 ,TN2.DESCR LVL2_DESCR 
 ,T3.TREE_NODE LVL3 
 ,TN3.DESCR LVL3_DESCR 
 ,' ' LVL4 
 ,' ' LVL4_DESCR 
 ,' ' LVL5 
 ,' ' LVL5_DESCR 
 ,' ' LVL6 
 ,' ' LVL6_DESCR 
 ,' ' LVL7 
 ,' ' LVL7_DESCR 
 ,' ' LVL8 
 ,' ' LVL8_DESCR 
 ,' ' LVL9 
 ,' ' LVL9_DESCR 
 ,LF.RANGE_FROM 
 ,LF.RANGE_TO 
  FROM PSTREENODE T1 
  , PS_TREE_NODE_TBL TN1 
  , PSTREENODE T2 
  , PS_TREE_NODE_TBL TN2 
  , PSTREENODE T3 
  , PS_TREE_NODE_TBL TN3 
  , PSTREELEAF LF 
 WHERE T1.SETID = T2.SETID 
   AND T1.TREE_NAME = T2.TREE_NAME 
   AND T1.EFFDT = T2.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T1.SETID = T3.SETID 
   AND T1.TREE_NAME = T3.TREE_NAME 
   AND T1.EFFDT = T3.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T2.TREE_NODE_NUM = T3.PARENT_NODE_NUM 
   AND T1.SETID = LF.SETID 
   AND T1.TREE_NAME = LF.TREE_NAME 
   AND T1.EFFDT = LF.EFFDT 
   AND T3.TREE_NODE_NUM = LF.TREE_NODE_NUM 
   AND T1.PARENT_NODE_NUM = 0 
   AND T1.SETID = TN1.SETID 
   AND T2.SETID = TN2.SETID 
   AND T3.SETID = TN3.SETID 
   AND T1.TREE_NODE = TN1.TREE_NODE 
   AND T2.TREE_NODE = TN2.TREE_NODE 
   AND T3.TREE_NODE = TN3.TREE_NODE 
   AND %EffdtCheck(PSTREELEAF LF_A, LF, %CurrentDateIn) 
   AND %EffdtCheck(PSTREENODE T1_A, T1, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T2_A, T2, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T3_A, T3, LF.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN1_A, TN1, T1.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN2_A, TN2, T2.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN3_A, TN3, T3.EFFDT) 
  UNION 
 SELECT DISTINCT T1.SETID 
 ,T1.TREE_NAME 
 ,T1.EFFDT 
 ,T1.TREE_NODE LVL1 
 ,TN1.DESCR LVL1_DESCR 
 ,T2.TREE_NODE LVL2 
 ,TN2.DESCR LVL2_DESCR 
 ,T3.TREE_NODE LVL3 
 ,TN3.DESCR LVL3_DESCR 
 ,T4.TREE_NODE LVL4 
 ,TN4.DESCR LVL4_DESCR 
 ,' ' LVL5 
 ,' ' LVL5_DESCR 
 ,' ' LVL6 
 ,' ' LVL6_DESCR 
 ,' ' LVL7 
 ,' ' LVL7_DESCR 
 ,' ' LVL8 
 ,' ' LVL8_DESCR 
 ,' ' LVL9 
 ,' ' LVL9_DESCR 
 ,LF.RANGE_FROM 
 ,LF.RANGE_TO 
  FROM PSTREENODE T1 
  , PS_TREE_NODE_TBL TN1 
  , PSTREENODE T2 
  , PS_TREE_NODE_TBL TN2 
  , PSTREENODE T3 
  , PS_TREE_NODE_TBL TN3 
  , PSTREENODE T4 
  , PS_TREE_NODE_TBL TN4 
  , PSTREELEAF LF 
 WHERE T1.SETID = T2.SETID 
   AND T1.TREE_NAME = T2.TREE_NAME 
   AND T1.EFFDT = T2.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T1.SETID = T3.SETID 
   AND T1.TREE_NAME = T3.TREE_NAME 
   AND T1.EFFDT = T3.EFFDT 
   AND T1.SETID = T4.SETID 
   AND T1.TREE_NAME = T4.TREE_NAME 
   AND T1.EFFDT = T4.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T2.TREE_NODE_NUM = T3.PARENT_NODE_NUM 
   AND T3.TREE_NODE_NUM = T4.PARENT_NODE_NUM 
   AND T1.SETID = LF.SETID 
   AND T1.TREE_NAME = LF.TREE_NAME 
   AND T1.EFFDT = LF.EFFDT 
   AND T4.TREE_NODE_NUM = LF.TREE_NODE_NUM 
   AND T1.PARENT_NODE_NUM = 0 
   AND T1.SETID = TN1.SETID 
   AND T2.SETID = TN2.SETID 
   AND T3.SETID = TN3.SETID 
   AND T4.SETID = TN4.SETID 
   AND T1.TREE_NODE = TN1.TREE_NODE 
   AND T2.TREE_NODE = TN2.TREE_NODE 
   AND T3.TREE_NODE = TN3.TREE_NODE 
   AND T4.TREE_NODE = TN4.TREE_NODE 
   AND %EffdtCheck(PSTREELEAF LF_A, LF, %CurrentDateIn) 
   AND %EffdtCheck(PSTREENODE T1_A, T1, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T2_A, T2, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T3_A, T3, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T4_A, T4, LF.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN1_A, TN1, T1.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN2_A, TN2, T2.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN3_A, TN3, T3.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN4_A, TN4, T4.EFFDT) 
  UNION 
 SELECT DISTINCT T1.SETID 
 ,T1.TREE_NAME 
 ,T1.EFFDT 
 ,T1.TREE_NODE LVL1 
 ,TN1.DESCR LVL1_DESCR 
 ,T2.TREE_NODE LVL2 
 ,TN2.DESCR LVL2_DESCR 
 ,T3.TREE_NODE LVL3 
 ,TN3.DESCR LVL3_DESCR 
 ,T4.TREE_NODE LVL4 
 ,TN4.DESCR LVL4_DESCR 
 ,T5.TREE_NODE LVL5 
 ,TN5.DESCR LVL5_DESCR 
 ,' ' LVL6 
 ,' ' LVL6_DESCR 
 ,' ' LVL7 
 ,' ' LVL7_DESCR 
 ,' ' LVL8 
 ,' ' LVL8_DESCR 
 ,' ' LVL9 
 ,' ' LVL9_DESCR 
 ,LF.RANGE_FROM 
 ,LF.RANGE_TO 
  FROM PSTREENODE T1 
  , PSTREENODE T2 
  , PSTREENODE T3 
  , PSTREENODE T4 
  , PSTREENODE T5 
  , PS_TREE_NODE_TBL TN1 
  , PS_TREE_NODE_TBL TN2 
  , PS_TREE_NODE_TBL TN3 
  , PS_TREE_NODE_TBL TN4 
  , PS_TREE_NODE_TBL TN5 
  , PSTREELEAF LF 
 WHERE T1.SETID = T2.SETID 
   AND T1.TREE_NAME = T2.TREE_NAME 
   AND T1.EFFDT = T2.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T1.SETID = T3.SETID 
   AND T1.TREE_NAME = T3.TREE_NAME 
   AND T1.EFFDT = T3.EFFDT 
   AND T1.SETID = T4.SETID 
   AND T1.TREE_NAME = T4.TREE_NAME 
   AND T1.EFFDT = T4.EFFDT 
   AND T1.SETID = T5.SETID 
   AND T1.TREE_NAME = T5.TREE_NAME 
   AND T1.EFFDT = T5.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T2.TREE_NODE_NUM = T3.PARENT_NODE_NUM 
   AND T3.TREE_NODE_NUM = T4.PARENT_NODE_NUM 
   AND T4.TREE_NODE_NUM = T5.PARENT_NODE_NUM 
   AND T1.SETID = LF.SETID 
   AND T1.TREE_NAME = LF.TREE_NAME 
   AND T1.EFFDT = LF.EFFDT 
   AND T5.TREE_NODE_NUM = LF.TREE_NODE_NUM 
   AND T1.PARENT_NODE_NUM = 0 
   AND T1.SETID = TN1.SETID 
   AND T2.SETID = TN2.SETID 
   AND T3.SETID = TN3.SETID 
   AND T4.SETID = TN4.SETID 
   AND T5.SETID = TN5.SETID 
   AND T1.TREE_NODE = TN1.TREE_NODE 
   AND T2.TREE_NODE = TN2.TREE_NODE 
   AND T3.TREE_NODE = TN3.TREE_NODE 
   AND T4.TREE_NODE = TN4.TREE_NODE 
   AND T5.TREE_NODE = TN5.TREE_NODE 
   AND %EffdtCheck(PSTREELEAF LF_A, LF, %CurrentDateIn) 
   AND %EffdtCheck(PSTREENODE T1_A, T1, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T2_A, T2, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T3_A, T3, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T4_A, T4, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T5_A, T5, LF.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN1_A, TN1, T1.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN2_A, TN2, T2.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN3_A, TN3, T3.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN4_A, TN4, T4.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN5_A, TN5, T5.EFFDT) 
  UNION 
 SELECT DISTINCT T1.SETID 
 ,T1.TREE_NAME 
 ,T1.EFFDT 
 ,T1.TREE_NODE LVL1 
 ,TN1.DESCR LVL1_DESCR 
 ,T2.TREE_NODE LVL2 
 ,TN2.DESCR LVL2_DESCR 
 ,T3.TREE_NODE LVL3 
 ,TN3.DESCR LVL3_DESCR 
 ,T4.TREE_NODE LVL4 
 ,TN4.DESCR LVL4_DESCR 
 ,T5.TREE_NODE LVL5 
 ,TN5.DESCR LVL5_DESCR 
 ,T6.TREE_NODE LVL6 
 ,TN6.DESCR LVL6_DESCR 
 ,' ' LVL7 
 ,' ' LVL7_DESCR 
 ,' ' LVL8 
 ,' ' LVL8_DESCR 
 ,' ' LVL9 
 ,' ' LVL9_DESCR 
 ,LF.RANGE_FROM 
 ,LF.RANGE_TO 
  FROM PSTREENODE T1 
  , PSTREENODE T2 
  , PSTREENODE T3 
  , PSTREENODE T4 
  , PSTREENODE T5 
  , PSTREENODE T6 
  , PS_TREE_NODE_TBL TN1 
  , PS_TREE_NODE_TBL TN2 
  , PS_TREE_NODE_TBL TN3 
  , PS_TREE_NODE_TBL TN4 
  , PS_TREE_NODE_TBL TN5 
  , PS_TREE_NODE_TBL TN6 
  , PSTREELEAF LF 
 WHERE T1.SETID = T2.SETID 
   AND T1.TREE_NAME = T2.TREE_NAME 
   AND T1.EFFDT = T2.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T1.SETID = T3.SETID 
   AND T1.TREE_NAME = T3.TREE_NAME 
   AND T1.EFFDT = T3.EFFDT 
   AND T1.SETID = T4.SETID 
   AND T1.TREE_NAME = T4.TREE_NAME 
   AND T1.EFFDT = T4.EFFDT 
   AND T1.SETID = T5.SETID 
   AND T1.TREE_NAME = T5.TREE_NAME 
   AND T1.EFFDT = T5.EFFDT 
   AND T1.SETID = T6.SETID 
   AND T1.TREE_NAME = T6.TREE_NAME 
   AND T1.EFFDT = T6.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T2.TREE_NODE_NUM = T3.PARENT_NODE_NUM 
   AND T3.TREE_NODE_NUM = T4.PARENT_NODE_NUM 
   AND T4.TREE_NODE_NUM = T5.PARENT_NODE_NUM 
   AND T5.TREE_NODE_NUM = T6.PARENT_NODE_NUM 
   AND T1.SETID = LF.SETID 
   AND T1.TREE_NAME = LF.TREE_NAME 
   AND T1.EFFDT = LF.EFFDT 
   AND T6.TREE_NODE_NUM = LF.TREE_NODE_NUM 
   AND T1.PARENT_NODE_NUM = 0 
   AND T1.SETID = TN1.SETID 
   AND T2.SETID = TN2.SETID 
   AND T3.SETID = TN3.SETID 
   AND T4.SETID = TN4.SETID 
   AND T5.SETID = TN5.SETID 
   AND T6.SETID = TN6.SETID 
   AND T1.TREE_NODE = TN1.TREE_NODE 
   AND T2.TREE_NODE = TN2.TREE_NODE 
   AND T3.TREE_NODE = TN3.TREE_NODE 
   AND T4.TREE_NODE = TN4.TREE_NODE 
   AND T5.TREE_NODE = TN5.TREE_NODE 
   AND T6.TREE_NODE = TN6.TREE_NODE 
   AND %EffdtCheck(PSTREELEAF LF_A, LF, %CurrentDateIn) 
   AND %EffdtCheck(PSTREENODE T1_A, T1, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T2_A, T2, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T3_A, T3, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T4_A, T4, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T5_A, T5, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T6_A, T6, LF.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN1_A, TN1, T1.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN2_A, TN2, T2.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN3_A, TN3, T3.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN4_A, TN4, T4.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN5_A, TN5, T5.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN6_A, TN6, T6.EFFDT) 
  UNION 
 SELECT DISTINCT T1.SETID 
 ,T1.TREE_NAME 
 ,T1.EFFDT 
 ,T1.TREE_NODE LVL1 
 ,TN1.DESCR LVL1_DESCR 
 ,T2.TREE_NODE LVL2 
 ,TN2.DESCR LVL2_DESCR 
 ,T3.TREE_NODE LVL3 
 ,TN3.DESCR LVL3_DESCR 
 ,T4.TREE_NODE LVL4 
 ,TN4.DESCR LVL4_DESCR 
 ,T5.TREE_NODE LVL5 
 ,TN5.DESCR LVL5_DESCR 
 ,T6.TREE_NODE LVL6 
 ,TN6.DESCR LVL6_DESCR 
 ,T7.TREE_NODE LVL7 
 ,TN7.DESCR LVL7_DESCR 
 ,' ' LVL8 
 ,' ' LVL8_DESCR 
 ,' ' LVL9 
 ,' ' LVL9_DESCR 
 ,LF.RANGE_FROM 
 ,LF.RANGE_TO 
  FROM PSTREENODE T1 
  , PSTREENODE T2 
  , PSTREENODE T3 
  , PSTREENODE T4 
  , PSTREENODE T5 
  , PSTREENODE T6 
  , PSTREENODE T7 
  , PS_TREE_NODE_TBL TN1 
  , PS_TREE_NODE_TBL TN2 
  , PS_TREE_NODE_TBL TN3 
  , PS_TREE_NODE_TBL TN4 
  , PS_TREE_NODE_TBL TN5 
  , PS_TREE_NODE_TBL TN6 
  , PS_TREE_NODE_TBL TN7 
  , PSTREELEAF LF 
 WHERE T1.SETID = T2.SETID 
   AND T1.TREE_NAME = T2.TREE_NAME 
   AND T1.EFFDT = T2.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T1.SETID = T3.SETID 
   AND T1.TREE_NAME = T3.TREE_NAME 
   AND T1.EFFDT = T3.EFFDT 
   AND T1.SETID = T4.SETID 
   AND T1.TREE_NAME = T4.TREE_NAME 
   AND T1.EFFDT = T4.EFFDT 
   AND T1.SETID = T5.SETID 
   AND T1.TREE_NAME = T5.TREE_NAME 
   AND T1.EFFDT = T5.EFFDT 
   AND T1.SETID = T6.SETID 
   AND T1.TREE_NAME = T6.TREE_NAME 
   AND T1.EFFDT = T6.EFFDT 
   AND T1.SETID = T7.SETID 
   AND T1.TREE_NAME = T7.TREE_NAME 
   AND T1.EFFDT = T7.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T2.TREE_NODE_NUM = T3.PARENT_NODE_NUM 
   AND T3.TREE_NODE_NUM = T4.PARENT_NODE_NUM 
   AND T4.TREE_NODE_NUM = T5.PARENT_NODE_NUM 
   AND T5.TREE_NODE_NUM = T6.PARENT_NODE_NUM 
   AND T6.TREE_NODE_NUM = T7.PARENT_NODE_NUM 
   AND T1.SETID = LF.SETID 
   AND T1.TREE_NAME = LF.TREE_NAME 
   AND T1.EFFDT = LF.EFFDT 
   AND T7.TREE_NODE_NUM = LF.TREE_NODE_NUM 
   AND T1.PARENT_NODE_NUM = 0 
   AND T1.SETID = TN1.SETID 
   AND T2.SETID = TN2.SETID 
   AND T3.SETID = TN3.SETID 
   AND T4.SETID = TN4.SETID 
   AND T5.SETID = TN5.SETID 
   AND T6.SETID = TN6.SETID 
   AND T7.SETID = TN7.SETID 
   AND T1.TREE_NODE = TN1.TREE_NODE 
   AND T2.TREE_NODE = TN2.TREE_NODE 
   AND T3.TREE_NODE = TN3.TREE_NODE 
   AND T4.TREE_NODE = TN4.TREE_NODE 
   AND T5.TREE_NODE = TN5.TREE_NODE 
   AND T6.TREE_NODE = TN6.TREE_NODE 
   AND T7.TREE_NODE = TN7.TREE_NODE 
   AND %EffdtCheck(PSTREELEAF LF_A, LF, %CurrentDateIn) 
   AND %EffdtCheck(PSTREENODE T1_A, T1, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T2_A, T2, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T3_A, T3, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T4_A, T4, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T5_A, T5, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T6_A, T6, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T7_A, T7, LF.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN1_A, TN1, T1.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN2_A, TN2, T2.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN3_A, TN3, T3.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN4_A, TN4, T4.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN5_A, TN5, T5.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN6_A, TN6, T6.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN7_A, TN7, T7.EFFDT) 
  UNION 
 SELECT DISTINCT T1.SETID 
 ,T1.TREE_NAME 
 ,T1.EFFDT 
 ,T1.TREE_NODE LVL1 
 ,TN1.DESCR LVL1_DESCR 
 ,T2.TREE_NODE LVL2 
 ,TN2.DESCR LVL2_DESCR 
 ,T3.TREE_NODE LVL3 
 ,TN3.DESCR LVL3_DESCR 
 ,T4.TREE_NODE LVL4 
 ,TN4.DESCR LVL4_DESCR 
 ,T5.TREE_NODE LVL5 
 ,TN5.DESCR LVL5_DESCR 
 ,T6.TREE_NODE LVL6 
 ,TN6.DESCR LVL6_DESCR 
 ,T7.TREE_NODE LVL7 
 ,TN7.DESCR LVL7_DESCR 
 ,T8.TREE_NODE LVL8 
 ,TN8.DESCR LVL8_DESCR 
 ,' ' LVL9 
 ,' ' LVL9_DESCR 
 ,LF.RANGE_FROM 
 ,LF.RANGE_TO 
  FROM PSTREENODE T1 
  , PSTREENODE T2 
  , PSTREENODE T3 
  , PSTREENODE T4 
  , PSTREENODE T5 
  , PSTREENODE T6 
  , PSTREENODE T7 
  , PSTREENODE T8 
  , PS_TREE_NODE_TBL TN1 
  , PS_TREE_NODE_TBL TN2 
  , PS_TREE_NODE_TBL TN3 
  , PS_TREE_NODE_TBL TN4 
  , PS_TREE_NODE_TBL TN5 
  , PS_TREE_NODE_TBL TN6 
  , PS_TREE_NODE_TBL TN7 
  , PS_TREE_NODE_TBL TN8 
  , PSTREELEAF LF 
 WHERE T1.SETID = T2.SETID 
   AND T1.TREE_NAME = T2.TREE_NAME 
   AND T1.EFFDT = T2.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T1.SETID = T3.SETID 
   AND T1.TREE_NAME = T3.TREE_NAME 
   AND T1.EFFDT = T3.EFFDT 
   AND T1.SETID = T4.SETID 
   AND T1.TREE_NAME = T4.TREE_NAME 
   AND T1.EFFDT = T4.EFFDT 
   AND T1.SETID = T5.SETID 
   AND T1.TREE_NAME = T5.TREE_NAME 
   AND T1.EFFDT = T5.EFFDT 
   AND T1.SETID = T6.SETID 
   AND T1.TREE_NAME = T6.TREE_NAME 
   AND T1.EFFDT = T6.EFFDT 
   AND T1.SETID = T7.SETID 
   AND T1.TREE_NAME = T7.TREE_NAME 
   AND T1.EFFDT = T7.EFFDT 
   AND T1.SETID = T8.SETID 
   AND T1.TREE_NAME = T8.TREE_NAME 
   AND T1.EFFDT = T8.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T2.TREE_NODE_NUM = T3.PARENT_NODE_NUM 
   AND T3.TREE_NODE_NUM = T4.PARENT_NODE_NUM 
   AND T4.TREE_NODE_NUM = T5.PARENT_NODE_NUM 
   AND T5.TREE_NODE_NUM = T6.PARENT_NODE_NUM 
   AND T6.TREE_NODE_NUM = T7.PARENT_NODE_NUM 
   AND T7.TREE_NODE_NUM = T8.PARENT_NODE_NUM 
   AND T1.SETID = LF.SETID 
   AND T1.TREE_NAME = LF.TREE_NAME 
   AND T1.EFFDT = LF.EFFDT 
   AND T8.TREE_NODE_NUM = LF.TREE_NODE_NUM 
   AND T1.PARENT_NODE_NUM = 0 
   AND T1.SETID = TN1.SETID 
   AND T2.SETID = TN2.SETID 
   AND T3.SETID = TN3.SETID 
   AND T4.SETID = TN4.SETID 
   AND T5.SETID = TN5.SETID 
   AND T6.SETID = TN6.SETID 
   AND T7.SETID = TN7.SETID 
   AND T8.SETID = TN8.SETID 
   AND T1.TREE_NODE = TN1.TREE_NODE 
   AND T2.TREE_NODE = TN2.TREE_NODE 
   AND T3.TREE_NODE = TN3.TREE_NODE 
   AND T4.TREE_NODE = TN4.TREE_NODE 
   AND T5.TREE_NODE = TN5.TREE_NODE 
   AND T6.TREE_NODE = TN6.TREE_NODE 
   AND T7.TREE_NODE = TN7.TREE_NODE 
   AND T8.TREE_NODE = TN8.TREE_NODE 
   AND %EffdtCheck(PSTREELEAF LF_A, LF, %CurrentDateIn) 
   AND %EffdtCheck(PSTREENODE T1_A, T1, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T2_A, T2, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T3_A, T3, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T4_A, T4, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T5_A, T5, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T6_A, T6, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T7_A, T7, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T8_A, T8, LF.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN1_A, TN1, T1.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN2_A, TN2, T2.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN3_A, TN3, T3.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN4_A, TN4, T4.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN5_A, TN5, T5.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN6_A, TN6, T6.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN7_A, TN7, T7.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN8_A, TN8, T8.EFFDT) 
  UNION 
 SELECT DISTINCT T1.SETID 
 ,T1.TREE_NAME 
 ,T1.EFFDT 
 ,T1.TREE_NODE LVL1 
 ,TN1.DESCR LVL1_DESCR 
 ,T2.TREE_NODE LVL2 
 ,TN2.DESCR LVL2_DESCR 
 ,T3.TREE_NODE LVL3 
 ,TN3.DESCR LVL3_DESCR 
 ,T4.TREE_NODE LVL4 
 ,TN4.DESCR LVL4_DESCR 
 ,T5.TREE_NODE LVL5 
 ,TN5.DESCR LVL5_DESCR 
 ,T6.TREE_NODE LVL6 
 ,TN6.DESCR LVL6_DESCR 
 ,T7.TREE_NODE LVL7 
 ,TN7.DESCR LVL7_DESCR 
 ,T8.TREE_NODE LVL8 
 ,TN8.DESCR LVL8_DESCR 
 ,T9.TREE_NODE LVL9 
 ,TN9.DESCR LVL9_DESCR 
 ,LF.RANGE_FROM 
 ,LF.RANGE_TO 
  FROM PSTREENODE T1 
  , PSTREENODE T2 
  , PSTREENODE T3 
  , PSTREENODE T4 
  , PSTREENODE T5 
  , PSTREENODE T6 
  , PSTREENODE T7 
  , PSTREENODE T8 
  , PSTREENODE T9 
  , PS_TREE_NODE_TBL TN1 
  , PS_TREE_NODE_TBL TN2 
  , PS_TREE_NODE_TBL TN3 
  , PS_TREE_NODE_TBL TN4 
  , PS_TREE_NODE_TBL TN5 
  , PS_TREE_NODE_TBL TN6 
  , PS_TREE_NODE_TBL TN7 
  , PS_TREE_NODE_TBL TN8 
  , PS_TREE_NODE_TBL TN9 
  , PSTREELEAF LF 
 WHERE T1.SETID = T2.SETID 
   AND T1.TREE_NAME = T2.TREE_NAME 
   AND T1.EFFDT = T2.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T1.SETID = T3.SETID 
   AND T1.TREE_NAME = T3.TREE_NAME 
   AND T1.EFFDT = T3.EFFDT 
   AND T1.SETID = T4.SETID 
   AND T1.TREE_NAME = T4.TREE_NAME 
   AND T1.EFFDT = T4.EFFDT 
   AND T1.SETID = T5.SETID 
   AND T1.TREE_NAME = T5.TREE_NAME 
   AND T1.EFFDT = T5.EFFDT 
   AND T1.SETID = T6.SETID 
   AND T1.TREE_NAME = T6.TREE_NAME 
   AND T1.EFFDT = T6.EFFDT 
   AND T1.SETID = T7.SETID 
   AND T1.TREE_NAME = T7.TREE_NAME 
   AND T1.EFFDT = T7.EFFDT 
   AND T1.SETID = T8.SETID 
   AND T1.TREE_NAME = T8.TREE_NAME 
   AND T1.EFFDT = T8.EFFDT 
   AND T1.SETID = T9.SETID 
   AND T1.TREE_NAME = T9.TREE_NAME 
   AND T1.EFFDT = T9.EFFDT 
   AND T1.TREE_NODE_NUM = T2.PARENT_NODE_NUM 
   AND T2.TREE_NODE_NUM = T3.PARENT_NODE_NUM 
   AND T3.TREE_NODE_NUM = T4.PARENT_NODE_NUM 
   AND T4.TREE_NODE_NUM = T5.PARENT_NODE_NUM 
   AND T5.TREE_NODE_NUM = T6.PARENT_NODE_NUM 
   AND T6.TREE_NODE_NUM = T7.PARENT_NODE_NUM 
   AND T7.TREE_NODE_NUM = T8.PARENT_NODE_NUM 
   AND T8.TREE_NODE_NUM = T9.PARENT_NODE_NUM 
   AND T1.SETID = LF.SETID 
   AND T1.TREE_NAME = LF.TREE_NAME 
   AND T1.EFFDT = LF.EFFDT 
   AND T9.TREE_NODE_NUM = LF.TREE_NODE_NUM 
   AND T1.PARENT_NODE_NUM = 0 
   AND T1.SETID = TN1.SETID 
   AND T2.SETID = TN2.SETID 
   AND T3.SETID = TN3.SETID 
   AND T4.SETID = TN4.SETID 
   AND T5.SETID = TN5.SETID 
   AND T6.SETID = TN6.SETID 
   AND T7.SETID = TN7.SETID 
   AND T8.SETID = TN8.SETID 
   AND T9.SETID = TN9.SETID 
   AND T1.TREE_NODE = TN1.TREE_NODE 
   AND T2.TREE_NODE = TN2.TREE_NODE 
   AND T3.TREE_NODE = TN3.TREE_NODE 
   AND T4.TREE_NODE = TN4.TREE_NODE 
   AND T5.TREE_NODE = TN5.TREE_NODE 
   AND T6.TREE_NODE = TN6.TREE_NODE 
   AND T7.TREE_NODE = TN7.TREE_NODE 
   AND T8.TREE_NODE = TN8.TREE_NODE 
   AND T9.TREE_NODE = TN9.TREE_NODE 
   AND %EffdtCheck(PSTREELEAF LF_A, LF, %CurrentDateIn) 
   AND %EffdtCheck(PSTREENODE T1_A, T1, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T2_A, T2, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T3_A, T3, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T4_A, T4, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T5_A, T5, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T6_A, T6, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T7_A, T7, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T8_A, T8, LF.EFFDT) 
   AND %EffdtCheck(PSTREENODE T9_A, T9, LF.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN1_A, TN1, T1.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN2_A, TN2, T2.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN3_A, TN3, T3.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN4_A, TN4, T4.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN5_A, TN5, T5.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN6_A, TN6, T6.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN7_A, TN7, T7.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN8_A, TN8, T8.EFFDT) 
   AND %EffdtCheck(TREE_NODE_TBL TN9_A, TN8, T9.EFFDT) ) DNM
