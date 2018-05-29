--217370 ��ܼ��ȱ���������ȡ(�����ͷ�)
alter session force parallel dml parallel 40;
alter session force parallel query parallel 40;

select
o.provorgname ��������,
o.cityorgname ��������,
l.product_name �������ƣ�
case 
   when   to_number(substr(t.organ_id, 6, 2)) >= 11 and to_number(substr(t.organ_id, 6, 2)) <= 98
   then '�ؼ�������' else '�ؼ�����' end ����,
case 
   when  m.applicant_age>=60
   then '����' else '������' end ����,
     
       
case
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '13' then '����-Ͷ�����ᱣ��'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '14' then '����-���ܱ���'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '12' then '����-�ֺ�����'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '11' then '����-��ͨ����'
   when l.liab_type = 2 then '������'
   when l.liab_type = 3 then '������'
   else '��������'
end ����,
decode(w.circ_sell_way,1,'��˾ֱ��',2,'���˴���',4, '������������', '����') ��������,
decode (substr(m.agency_code,1,4),'0001','����','0002','����','0003','����','0004','ũ��','0005','��ͨ','0018','�ʴ�','����') ����,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then m.company_id end) ���¿ͻ���,
count (distinct case when a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then t.policy_id end) ���¼���,
sum (case when a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then b.period_prem end) ���½��,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then m.company_id end) ���¿ͻ���,
count (distinct case when a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then t.policy_id end) ���¼���,
sum (case when a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then b.period_prem end) ���½��,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then m.company_id end) ����ͻ���,
count (distinct case when a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then t.policy_id end) �������,
sum (case when a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then b.period_prem end) ������,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then m.company_id end) ȥ��ͬ���ۼƿͻ���,
count (distinct case when a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then t.policy_id end) ȥ��ͬ���ۼƼ���,
sum (case when a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then b.period_prem end) ȥ��ͬ���ۼƽ��,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then m.company_id end) ȥ��ͬ�ڿͻ���,
count (distinct case when a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then t.policy_id end) ȥ��ͬ�ڼ���,
sum (case when a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then b.period_prem end) ȥ��ͬ�ڽ��
FROM
ODSUSER.t_policy_change             t
inner join odsuser.t_policy_fee     a
on t.change_id = a.change_id
inner join odsuser.t_product_fee    b
on a.fee_id=b.fee_id
inner join dmuser.d_org             o
on t.organ_id=o.orgcode
inner join circ_user.circ_t_product_life l
on b.product_id=l.product_id
inner join circ_user.circ_t_policy_sell_way w
on t.policy_id=w.policy_id
inner join odsuser.t_contract_master m
on t.policy_id=m.policy_id
where
t.service_id = 421
AND not EXISTS
(
   SELECT POLICY_ID
     FROM odsuser.T_CONTRACT_MASTER TCM
    WHERE t.POLICY_ID = TCM.POLICY_ID
      AND tcm.policy_code LIKE '%158'
    union all
   SELECT POLICY_ID
     FROM odsuser.T_POLICY TP
    WHERE t.POLICY_ID = TP.POLICY_ID
      AND TP.POLICY_INPUT_SOURCE IN
          (SELECT INPUT_SOURCE_CODE
             FROM odsuser.T_ACCEPT_MODE
            WHERE IS_NETSALE = 'Y')
      and TP.p_state_id = 53
)
and a.fee_status = 1
and t.change_status = 3
and a.fee_type = 152
and a.finish_time < date '2016-7-1'
and a.finish_time >= date '2015-1-1'
group by
o.provorgname,
o.cityorgname,
l.product_name��
case 
   when   to_number(substr(t.organ_id, 6, 2)) >= 11 and to_number(substr(t.organ_id, 6, 2)) <= 98
   then '�ؼ�������' else '�ؼ�����' end ,
case 
   when  m.applicant_age>=60
   then '����' else '������' end ,
case
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '13' then '����-Ͷ�����ᱣ��'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '14' then '����-���ܱ���'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '12' then '����-�ֺ�����'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '11' then '����-��ͨ����'
   when l.liab_type = 2 then '������'
   when l.liab_type = 3 then '������'
   else '��������'
end,
decode(w.circ_sell_way,1,'��˾ֱ��',2,'���˴���',4, '������������', '����'),
decode (substr(m.agency_code,1,4),'0001','����','0002','����','0003','����','0004','ũ��','0005','��ͨ','0018','�ʴ�','����')

union all
--����
select
o.provorgname ��������,
o.cityorgname ��������,
l.product_name �������ƣ�
case 
   when   to_number(substr(t.organ_id, 6, 2)) >= 11 and to_number(substr(t.organ_id, 6, 2)) <= 98
   then '�ؼ�������' else '�ؼ�����' end ����,
case 
   when  m.applicant_age>=60
   then '����' else '������' end ����,
case
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '13' then '����-Ͷ�����ᱣ��'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '14' then '����-���ܱ���'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '12' then '����-�ֺ�����'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '11' then '����-��ͨ����'
   when l.liab_type = 2 then '������'
   when l.liab_type = 3 then '������'
   else '��������'
end ����,
'����' ��������,
decode (substr(m.agency_code,1,4),'0001','����','0002','����','0003','����','0004','ũ��','0005','��ͨ','0018','�ʴ�','����') ����,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then m.company_id end) ���¿ͻ���,
count (distinct case when a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then t.policy_id end) ���¼���,
sum (case when a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then b.period_prem end) ���½��,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then m.company_id end) ���¿ͻ���,
count (distinct case when a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then t.policy_id end) ���¼���,
sum (case when a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then b.period_prem end) ���½��,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then m.company_id end) ����ͻ���,
count (distinct case when a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then t.policy_id end) �������,
sum (case when a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then b.period_prem end) ������,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then m.company_id end) ȥ��ͬ���ۼƿͻ���,
count (distinct case when a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then t.policy_id end) ȥ��ͬ���ۼƼ���,
sum (case when a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then b.period_prem end) ȥ��ͬ���ۼƽ��,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then m.company_id end) ȥ��ͬ�ڿͻ���,
count (distinct case when a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then t.policy_id end) ȥ��ͬ�ڼ���,
sum (case when a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then b.period_prem end) ȥ��ͬ�ڽ��
FROM
ODSUSER.t_policy_change             t
inner join odsuser.t_policy_fee     a
on t.change_id = a.change_id
inner join odsuser.t_product_fee    b
on a.fee_id=b.fee_id
inner join dmuser.d_org             o
on t.organ_id=o.orgcode
inner join circ_user.circ_t_product_life l
on b.product_id=l.product_id
inner join circ_user.circ_t_policy_sell_way w
on t.policy_id=w.policy_id
inner join odsuser.t_contract_master m
on t.policy_id=m.policy_id
where
t.service_id = 421
and EXISTS
(
   SELECT POLICY_ID
     FROM odsuser.T_CONTRACT_MASTER TCM
    WHERE t.POLICY_ID = TCM.POLICY_ID
      AND tcm.policy_code LIKE '%158'
    union all
   SELECT POLICY_ID
     FROM odsuser.T_POLICY TP
    WHERE t.POLICY_ID = TP.POLICY_ID
      AND TP.POLICY_INPUT_SOURCE IN
          (SELECT INPUT_SOURCE_CODE
             FROM odsuser.T_ACCEPT_MODE
            WHERE IS_NETSALE = 'Y')
      and TP.p_state_id = 53
)
and a.fee_status = 1
and t.change_status = 3
and a.fee_type = 152
and a.finish_time < date '2016-7-1'
and a.finish_time >= date '2015-1-1'
group by
o.provorgname,
o.cityorgname,
l.product_name,
case 
   when   to_number(substr(t.organ_id, 6, 2)) >= 11 and to_number(substr(t.organ_id, 6, 2)) <= 98
   then '�ؼ�������' else '�ؼ�����' end ,
case 
   when  m.applicant_age>=60
   then '����' else '������' end ,
case
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '13' then '����-Ͷ�����ᱣ��'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '14' then '����-���ܱ���'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '12' then '����-�ֺ�����'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '11' then '����-��ͨ����'
   when l.liab_type = 2 then '������'
   when l.liab_type = 3 then '������'
   else '��������'
end,
decode (substr(m.agency_code,1,4),'0001','����','0002','����','0003','����','0004','ũ��','0005','��ͨ','0018','�ʴ�','����')
