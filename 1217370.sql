--217370 监管季度报告数据提取(北京客服)
alter session force parallel dml parallel 40;
alter session force parallel query parallel 40;

select
o.provorgname 二级机构,
o.cityorgname 三级机构,
l.product_name 险种名称，
case 
   when   to_number(substr(t.organ_id, 6, 2)) >= 11 and to_number(substr(t.organ_id, 6, 2)) <= 98
   then '县及县以下' else '县级以上' end 区域,
case 
   when  m.applicant_age>=60
   then '老年' else '非老年' end 年龄,
     
       
case
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '13' then '寿险-投资连结保险'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '14' then '寿险-万能保险'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '12' then '寿险-分红寿险'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '11' then '寿险-普通寿险'
   when l.liab_type = 2 then '健康险'
   when l.liab_type = 3 then '意外险'
   else '其他险种'
end 险种,
decode(w.circ_sell_way,1,'公司直销',2,'个人代理',4, '银行邮政代理', '其他') 销售渠道,
decode (substr(m.agency_code,1,4),'0001','工行','0002','中行','0003','建行','0004','农行','0005','交通','0018','邮储','其他') 银行,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then m.company_id end) 本月客户数,
count (distinct case when a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then t.policy_id end) 本月件数,
sum (case when a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then b.period_prem end) 本月金额,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then m.company_id end) 上月客户数,
count (distinct case when a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then t.policy_id end) 上月件数,
sum (case when a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then b.period_prem end) 上月金额,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then m.company_id end) 本年客户数,
count (distinct case when a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then t.policy_id end) 本年件数,
sum (case when a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then b.period_prem end) 本年金额,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then m.company_id end) 去年同期累计客户数,
count (distinct case when a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then t.policy_id end) 去年同期累计件数,
sum (case when a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then b.period_prem end) 去年同期累计金额,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then m.company_id end) 去年同期客户数,
count (distinct case when a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then t.policy_id end) 去年同期件数,
sum (case when a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then b.period_prem end) 去年同期金额
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
l.product_name，
case 
   when   to_number(substr(t.organ_id, 6, 2)) >= 11 and to_number(substr(t.organ_id, 6, 2)) <= 98
   then '县及县以下' else '县级以上' end ,
case 
   when  m.applicant_age>=60
   then '老年' else '非老年' end ,
case
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '13' then '寿险-投资连结保险'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '14' then '寿险-万能保险'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '12' then '寿险-分红寿险'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '11' then '寿险-普通寿险'
   when l.liab_type = 2 then '健康险'
   when l.liab_type = 3 then '意外险'
   else '其他险种'
end,
decode(w.circ_sell_way,1,'公司直销',2,'个人代理',4, '银行邮政代理', '其他'),
decode (substr(m.agency_code,1,4),'0001','工行','0002','中行','0003','建行','0004','农行','0005','交通','0018','邮储','其他')

union all
--网销
select
o.provorgname 二级机构,
o.cityorgname 三级机构,
l.product_name 险种名称，
case 
   when   to_number(substr(t.organ_id, 6, 2)) >= 11 and to_number(substr(t.organ_id, 6, 2)) <= 98
   then '县及县以下' else '县级以上' end 区域,
case 
   when  m.applicant_age>=60
   then '老年' else '非老年' end 年龄,
case
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '13' then '寿险-投资连结保险'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '14' then '寿险-万能保险'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '12' then '寿险-分红寿险'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '11' then '寿险-普通寿险'
   when l.liab_type = 2 then '健康险'
   when l.liab_type = 3 then '意外险'
   else '其他险种'
end 险种,
'网销' 销售渠道,
decode (substr(m.agency_code,1,4),'0001','工行','0002','中行','0003','建行','0004','农行','0005','交通','0018','邮储','其他') 银行,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then m.company_id end) 本月客户数,
count (distinct case when a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then t.policy_id end) 本月件数,
sum (case when a.finish_time>=date '2016-6-1' and a.finish_time<date '2016-7-1' then b.period_prem end) 本月金额,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then m.company_id end) 上月客户数,
count (distinct case when a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then t.policy_id end) 上月件数,
sum (case when a.finish_time>=date '2016-5-1' and a.finish_time<date '2016-6-1' then b.period_prem end) 上月金额,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then m.company_id end) 本年客户数,
count (distinct case when a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then t.policy_id end) 本年件数,
sum (case when a.finish_time>=date '2016-1-1' and a.finish_time<date '2016-7-1' then b.period_prem end) 本年金额,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then m.company_id end) 去年同期累计客户数,
count (distinct case when a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then t.policy_id end) 去年同期累计件数,
sum (case when a.finish_time>=date '2015-1-1' and a.finish_time<date '2015-7-1' then b.period_prem end) 去年同期累计金额,
count (distinct case when m.policy_type in (1,3) and a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then m.applicant_id
     when m.policy_type=2 and a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then m.company_id end) 去年同期客户数,
count (distinct case when a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then t.policy_id end) 去年同期件数,
sum (case when a.finish_time>=date '2015-6-1' and a.finish_time<date '2015-7-1' then b.period_prem end) 去年同期金额
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
   then '县及县以下' else '县级以上' end ,
case 
   when  m.applicant_age>=60
   then '老年' else '非老年' end ,
case
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '13' then '寿险-投资连结保险'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '14' then '寿险-万能保险'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '12' then '寿险-分红寿险'
   when l.liab_type = 1 and l.SUB_LIAB_TYPE = '11' then '寿险-普通寿险'
   when l.liab_type = 2 then '健康险'
   when l.liab_type = 3 then '意外险'
   else '其他险种'
end,
decode (substr(m.agency_code,1,4),'0001','工行','0002','中行','0003','建行','0004','农行','0005','交通','0018','邮储','其他')
