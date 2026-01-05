select * into[2025-10-14-108_Nutrisana] from MB_GES_2020 where MB024 = 1 

insert into[2025-10-14-108_Nutrisana] select * from MB_GES_2020 where (MB024=1 or LIGHT24 = 1 or LIGHT24_HH = 1)and urngem not in (select urngem from[2025-10-14-108_Nutrisana]) and URNHHGEM in (
	select distinct(URNHHGEM) from PERSON_1 where urn in (
		select distinct(urn) from TRANSACTION_1 where affiliateid in (	1040,1081,1120,1241,1243,1244,1246,1249,1390,1391,
																		1530,1650,2000,2112,2213,2390,2421,2422,2682,3041,
																		3042,3043,3201,3202,3421,3422,3423,3451,3571,3611,
																		3701,3721,3722,3731,3741))
or URN in (select URN from INFOS_1 where AFFILIATEID in (3401,3402,3403,3091))or URN in (select urn from CLUSTER_1 where ClusterID in ('C01','C03')))

delete from[2025-10-14-108_Nutrisana] where GENDERTYPEID not in (1,2)

delete from[2025-10-14-108_Nutrisana] where urngem in (select urngem from zusatz_1 where urn in (
	select distinct(urn) from TRANSACTION_1 where AFFILIATEID = 3521))
	
delete from[2025-10-14-108_Nutrisana] where DNMFLAG = 1

delete from[2025-10-14-108_Nutrisana] where urngem in (select urngem from zusatz_1 where urn in (
	select distinct(urn) from TRANSACTION_1 where AFFILIATEID in (
		select AFFILIATEEXCLUDEID from AFFILIATEEXCLUDE_1 where AFFILIATEID = 3521))
		) 
and CountAffiliates = 2

delete from[2025-10-14-108_Nutrisana] where urngem in (select urngem from zusatz_1 where urn in (
	select distinct(urn) from PRIVATE_1 where AFFILIATEID = 3521))
	
delete from[2025-10-14-108_Nutrisana] where urngem in (select urngem from zusatz_1 where urn in (select urn from TOERASE_1))

delete from[2025-10-14-108_Nutrisana] where (GEBJAHR not between '1928' and '1974') 
or (GEBJAHR is NULL and [ALTER] < '5')

delete from[2025-10-14-108_Nutrisana] where URNHHGEM in (select URNHHGEM from PERSON_1 where urn in (
	select distinct(urn) from TRANSACTION_1	where AFFILIATEID = 3521)
	)

delete from[2025-10-14-108_Nutrisana] where urngem in (select URNGEM from nix_pers)
delete from[2025-10-14-108_Nutrisana] where urngem in (select urngem from ZUSATZ_1 where URNHHGEM in (select URNHHGEM from nix_hh))
delete from[2025-10-14-108_Nutrisana] where urngem in (select urngem from ZUSATZ_1 where URNHHGEM in (select URNHHGEM from robinson))
delete from[2025-10-14-108_Nutrisana] where urngem not in (select URNGEM from gem_gesamt)
delete from[2025-10-14-108_Nutrisana] where urngem in (select URNGEM from nix_ausland)
delete from[2025-10-14-108_Nutrisana] where urngem in (select URNGEM from nix_tote)
delete from[2025-10-14-108_Nutrisana] where urngem in (select urngem from zusatz_1 where urn in (select urn from umz_tbl where flag = 'Umgezogen'))

alter table[2025-10-14-108_Nutrisana] add 	
	alter_kl char(10),
	seg_kgm numeric(3,0),
	score_kgm real,
	synergie int  not null  DEFAULT 0,
	syn012 int  not null  DEFAULT 0,
	syn012m int  not null  DEFAULT 0,
	ealter char(10),
	urn numeric(18,0)
	,old int
--go

update[2025-10-14-108_Nutrisana] set[2025-10-14-108_Nutrisana].urn = zusatz_1.urn from[2025-10-14-108_Nutrisana], zusatz_1 where[2025-10-14-108_Nutrisana].urngem = zusatz_1.urngem



select urn, affiliateid into zg1 from TRANSACTION_1 where ACTIVITYTYPEID in (2,5) and affiliateid in ( 
																		1040,1081,1120,1241,1243,1244,1246,1249,1390,1391,
																		1530,1650,2000,2112,2213,2390,2421,2422,2682,3041,
																		3042,3043,3201,3202,3421,3422,3423,3451,3571,3611,
																		3701,3721,3722,3731,3741) and datediff(m, activitydate, getdate()) <= 12
																	group by URN, AFFILIATEID having COUNT(*) >= 2

update[2025-10-14-108_Nutrisana] set syn012m = 1 where  URNHHGEM in (
select distinct(URNHHGEM) from PERSON_1 where urn in (select urn from zg1  group by urn ))

drop table zg1







update[2025-10-14-108_Nutrisana] set syn012 = a.anzahl from[2025-10-14-108_Nutrisana],( select urnhhgem,COUNT(urnhhgem) as anzahl from TRANSACTION_1, PERSON_1
												where affiliateid in(	1040,1081,1120,1241,1243,1244,1246,1249,1390,1391,
																		1530,1650,2000,2112,2213,2390,2421,2422,2682,3041,
																		3042,3043,3201,3202,3421,3422,3423,3451,3571,3611,
																		3701,3721,3722,3731,3741) and datediff(m, activitydate, getdate()) <= 12 
																		and transaction_1.urn = PERSON_1.urn
																		group by urnhhgem) a
										  where a.URNHHGEM =[2025-10-14-108_Nutrisana].urnhhgem 






update[2025-10-14-108_Nutrisana] set syn012 = syn012 + a.anzahl from[2025-10-14-108_Nutrisana], (select urnhhgem,COUNT(urnhhgem) as anzahl from cluster_1
												where ClusterID in('C01','C03') and datediff(m, activitydate, getdate()) <= 12 
																		group by urnhhgem) a
										  where a.URNHHGEM =[2025-10-14-108_Nutrisana].urnhhgem 


update[2025-10-14-108_Nutrisana] set synergie = a.anzahl from[2025-10-14-108_Nutrisana],( select urnhhgem,COUNT(urnhhgem) as anzahl from TRANSACTION_1, PERSON_1
												where affiliateid in(	040,1081,1120,1241,1243,1244,1246,1249,1390,1391,
																		1530,1650,2000,2112,2213,2390,2421,2422,2682,3041,
																		3042,3043,3201,3202,3421,3422,3423,3451,3571,3611,
																		3701,3721,3722,3731,3741)
																		and transaction_1.urn = PERSON_1.urn
																		group by urnhhgem) a
										  where a.URNHHGEM =[2025-10-14-108_Nutrisana].urnhhgem 


update[2025-10-14-108_Nutrisana] set synergie = synergie + a.anzahl from[2025-10-14-108_Nutrisana], (select PERSON_1.urnhhgem,COUNT(PERSON_1.urnhhgem) as anzahl from INFOS_1, PERSON_1
												where affiliateid in(	3401,3402,3403)
																		and INFOS_1.urn = PERSON_1.urn
																		group by PERSON_1.urnhhgem) a
										  where a.URNHHGEM =[2025-10-14-108_Nutrisana].urnhhgem 
										  
										  
	

update[2025-10-14-108_Nutrisana] set synergie =  synergie + a.anzahl from[2025-10-14-108_Nutrisana], (select urnhhgem,COUNT(urnhhgem) as anzahl from cluster_1
												where ClusterID in('C01','C03')
																		group by urnhhgem) a
										  where a.URNHHGEM =[2025-10-14-108_Nutrisana].urnhhgem 
	
	





update[2025-10-14-108_Nutrisana] 
set alter_kl = 
(case when GEBJAHR >= 1951 and GEBJAHR <= 1965 and gebjahr is not null THEN '60-75'
	  when GEBJAHR >= 1930 and GEBJAHR <= 1950 and gebjahr is not null THEN '75+'
      when GEBJAHR IS null and [ALTER] IN ('5','6') THEN '60-75'
      when GEBJAHR IS null and [ALTER] IN ('7') THEN '75+'
      END)

update[2025-10-14-108_Nutrisana] 
set ealter = 
(case   when GEBJAHR >= 1951 and GEBJAHR <= 1965 and gebjahr is not null THEN '60-75'
	  when GEBJAHR >= 1930 and GEBJAHR <= 1950 and gebjahr is not null THEN '75+'
	  
    
      END)

alter table[2025-10-14-108_Nutrisana] add ealter2 varchar(5)
--go
update[2025-10-14-108_Nutrisana] 
set ealter2 = 
(case   when GEBJAHR >= 1930 and GEBJAHR <= 1950 and gebjahr is not null THEN '75-95'
	       END)



-- --select *from CAMPAIGN_1 where AFFILIATEID = 3521 order by CAMPAIGNID desc
-- --update[2025-10-14-108_Nutrisana] set old = 1 where urngem in( select urngem from ZUSATZ_1 where urn in (select urn from DELIVERY_1 where AFFILIATEID=3521 and CAMPAIGNID in (181,182,183,184,187,188) ))





-- --------------------
update[2025-10-14-108_Nutrisana] set
	seg_kgm = Scores_2025-10-14-108_Nutrisana.seg_kgm,
	score_kgm = Scores_2025-10-14-108_Nutrisana.score_kgm
from[2025-10-14-108_Nutrisana] join Scores_2025-10-14-108_Nutrisana on (2025-10-14-108_Nutrisana.URNgem = Scores_2025-10-14-108_Nutrisana.urngem)
-----------------------------------------------

------Synergie Mit K�uferscore
---M�nner

------Synergie Mit K�uferscore
---M�nner
-- select 
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+],		
-- mb024_p_rest.[60-75],	mb024_p_rest.[75+],	
-- mb024_rest.[60-75],		mb024_rest.[75+]
-- from 
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb012_P = 1 and synergie >= 1
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+])) P) mb012_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb012 = 1 and synergie >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+])) p) mb012
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p = 1 and synergie >= 1
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P) mb024_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 = 1 and synergie >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P) mb024
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p is null and synergie >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P)mb024_p_rest
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 is null and synergie >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P) mb024_rest
-- where 
-- mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
-- and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
-- and mb012_p.gendertypeid=1
-- order by mb012_p.seg_kgm

-- ;


-- ---Frauen
-- select 
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+],		
-- mb024_p_rest.[60-75],	mb024_p_rest.[75+],	
-- mb024_rest.[60-75],		mb024_rest.[75+]
-- from 
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb012_P = 1 and synergie >= 1
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+])) P) mb012_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb012 = 1 and synergie >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+])) p) mb012
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p = 1 and synergie >= 1
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P) mb024_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 = 1 and synergie >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P) mb024
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p is null and synergie >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P)mb024_p_rest
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 is null and synergie >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P) mb024_rest
-- where 
-- mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
-- and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
-- and mb012_p.gendertypeid=2
-- order by mb012_p.seg_kgm
-- ;



-- ------Synergie Mit K�uferscore
-- ---M�nner
-- select 
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+],		
-- mb024_p_rest.[60-75],	mb024_p_rest.[75+],	
-- mb024_rest.[60-75],		mb024_rest.[75+]
-- from 
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb012_P = 1 and syn012 >= 1
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+])) P) mb012_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb012 = 1 and syn012 >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+])) p) mb012
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p = 1 and syn012 >= 1
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P) mb024_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 = 1 and syn012 >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P) mb024
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p is null and syn012 >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P)mb024_p_rest
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 is null and syn012 >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P) mb024_rest
-- where 
-- mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
-- and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
-- and mb012_p.gendertypeid=1
-- order by mb012_p.seg_kgm
-- ;

-- ---Frauen
-- select 
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+],		
-- mb024_p_rest.[60-75],	mb024_p_rest.[75+],	
-- mb024_rest.[60-75],		mb024_rest.[75+]
-- from 
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb012_P = 1 and syn012 >= 1
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+])) P) mb012_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb012 = 1 and syn012 >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+])) p) mb012
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p = 1 and syn012 >= 1
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P) mb024_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 = 1 and syn012 >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P) mb024
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p is null and syn012 >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P)mb024_p_rest
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 is null and syn012 >= 1 
-- ) b pivot(count(urngem) for alter_kl in ([90-95],[60-75],[75+]))P) mb024_rest
-- where 
-- mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
-- and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
-- and mb012_p.gendertypeid=2
-- order by mb012_p.seg_kgm

-- ;

-- -- mann
-- select 
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+]
-- from[2025-10-14-108_Nutrisana] basis
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 = 1 
-- ) b pivot(count(urngem) for alter_kl in ([45-60],[90-95],[60-75],[75+])) P) mb024
-- on basis.gendertypeid = mb024.gendertypeid and basis.seg_kgm = mb024.seg_kgm
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p = 1   
-- ) b pivot(count(urngem) for alter_kl in ([45-60],[90-95],[60-75],[75+])) p) mb024_p
-- on basis.gendertypeid = mb024_p.gendertypeid and basis.seg_kgm = mb024_p.seg_kgm
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana] 
-- where mb012 = 1  
-- ) b pivot(count(urngem) for alter_kl in ([45-60],[90-95],[60-75],[75+]))P) mb012
-- on basis.gendertypeid = mb012.gendertypeid and basis.seg_kgm = mb012.seg_kgm
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb012_p = 1  
-- ) b pivot(count(urngem) for alter_kl in ([45-60],[90-95],[60-75],[75+]))P) mb012_p
-- on basis.gendertypeid = mb012_p.gendertypeid and basis.seg_kgm = mb012_p.seg_kgm

-- where mb024.gendertypeid = 1 
-- group by basis.gendertypeid, basis.seg_kgm, mb024.seg_kgm,
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+]
-- order by mb024.seg_kgm

-- ;


-- ---kgm

-- -- frauen
-- select 
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+]
-- from[2025-10-14-108_Nutrisana] basis
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 = 1 
-- ) b pivot(count(urngem) for alter_kl in ([45-60],[90-95],[60-75],[75+])) P) mb024
-- on basis.gendertypeid = mb024.gendertypeid and basis.seg_kgm = mb024.seg_kgm
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p = 1   
-- ) b pivot(count(urngem) for alter_kl in ([45-60],[90-95],[60-75],[75+])) p) mb024_p
-- on basis.gendertypeid = mb024_p.gendertypeid and basis.seg_kgm = mb024_p.seg_kgm
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana] 
-- where mb012 = 1  
-- ) b pivot(count(urngem) for alter_kl in ([45-60],[90-95],[60-75],[75+]))P) mb012
-- on basis.gendertypeid = mb012.gendertypeid and basis.seg_kgm = mb012.seg_kgm
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from[2025-10-14-108_Nutrisana]
-- where mb012_p = 1  
-- ) b pivot(count(urngem) for alter_kl in ([45-60],[90-95],[60-75],[75+]))P) mb012_p
-- on basis.gendertypeid = mb012_p.gendertypeid and basis.seg_kgm = mb012_p.seg_kgm

-- where mb024.gendertypeid = 2 
-- group by basis.gendertypeid, basis.seg_kgm, mb024.seg_kgm,
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+]
-- order by mb024.seg_kgm

-- ;



-- ------Synergie Mit K�uferscore
-- ---M�nner
-- select 
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+],		
-- mb024_p_rest.[60-75],	mb024_p_rest.[75+],	
-- mb024_rest.[60-75],		mb024_rest.[75+]
-- from 
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb012_P = 1 and synergie >= 1
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+])) P) mb012_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb012 = 1 and synergie >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+])) p) mb012
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p = 1 and synergie >= 1
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P) mb024_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 = 1 and synergie >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P) mb024
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p is null and synergie >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P)mb024_p_rest
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 is null and synergie >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P) mb024_rest
-- where 
-- mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
-- and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
-- and mb012_p.gendertypeid=1
-- order by mb012_p.seg_kgm
-- ;



-- ---Frauen
-- select 
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+],		
-- mb024_p_rest.[60-75],	mb024_p_rest.[75+],	
-- mb024_rest.[60-75],		mb024_rest.[75+]
-- from 
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb012_P = 1 and synergie >= 1
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+])) P) mb012_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb012 = 1 and synergie >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+])) p) mb012
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p = 1 and synergie >= 1
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P) mb024_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 = 1 and synergie >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P) mb024
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p is null and synergie >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P)mb024_p_rest
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 is null and synergie >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P) mb024_rest
-- where 
-- mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
-- and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
-- and mb012_p.gendertypeid=2
-- order by mb012_p.seg_kgm
-- ;



-- ------Synergie Mit K�uferscore
-- ---M�nner
-- select 
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+],		
-- mb024_p_rest.[60-75],	mb024_p_rest.[75+],	
-- mb024_rest.[60-75],		mb024_rest.[75+]
-- from 
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb012_P = 1 and syn012 >= 1
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+])) P) mb012_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb012 = 1 and syn012 >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+])) p) mb012
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p = 1 and syn012 >= 1
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P) mb024_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 = 1 and syn012 >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P) mb024
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p is null and syn012 >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P)mb024_p_rest
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 is null and syn012 >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P) mb024_rest
-- where 
-- mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
-- and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
-- and mb012_p.gendertypeid=1
-- order by mb012_p.seg_kgm
-- ;

-- ---Frauen
-- select 
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+],		
-- mb024_p_rest.[60-75],	mb024_p_rest.[75+],	
-- mb024_rest.[60-75],		mb024_rest.[75+]
-- from 
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb012_P = 1 and syn012 >= 1
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+])) P) mb012_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb012 = 1 and syn012 >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+])) p) mb012
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p = 1 and syn012 >= 1
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P) mb024_p
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 = 1 and syn012 >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P) mb024
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p is null and syn012 >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P)mb024_p_rest
-- ,
-- (select gendertypeid, seg_kgm, [90-95],[60-75],[75+] from (
-- select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 is null and syn012 >= 1 
-- ) b pivot(count(urngem) for ealter in ([90-95],[60-75],[75+]))P) mb024_rest
-- where 
-- mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
-- and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
-- and mb012_p.gendertypeid=2
-- order by mb012_p.seg_kgm

-- ;

-- -- mann
-- select 
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+]
-- from[2025-10-14-108_Nutrisana] basis
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 = 1 
-- ) b pivot(count(urngem) for ealter in ([45-60],[90-95],[60-75],[75+])) P) mb024
-- on basis.gendertypeid = mb024.gendertypeid and basis.seg_kgm = mb024.seg_kgm
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p = 1   
-- ) b pivot(count(urngem) for ealter in ([45-60],[90-95],[60-75],[75+])) p) mb024_p
-- on basis.gendertypeid = mb024_p.gendertypeid and basis.seg_kgm = mb024_p.seg_kgm
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana] 
-- where mb012 = 1  
-- ) b pivot(count(urngem) for ealter in ([45-60],[90-95],[60-75],[75+]))P) mb012
-- on basis.gendertypeid = mb012.gendertypeid and basis.seg_kgm = mb012.seg_kgm
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb012_p = 1  
-- ) b pivot(count(urngem) for ealter in ([45-60],[90-95],[60-75],[75+]))P) mb012_p
-- on basis.gendertypeid = mb012_p.gendertypeid and basis.seg_kgm = mb012_p.seg_kgm

-- where mb024.gendertypeid = 1 
-- group by basis.gendertypeid, basis.seg_kgm, mb024.seg_kgm,
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+]
-- order by mb024.seg_kgm
-- ;



-- ---kgm

-- -- frauen
-- select 
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+]
-- from[2025-10-14-108_Nutrisana] basis
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024 = 1 
-- ) b pivot(count(urngem) for ealter in ([45-60],[90-95],[60-75],[75+])) P) mb024
-- on basis.gendertypeid = mb024.gendertypeid and basis.seg_kgm = mb024.seg_kgm
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb024_p = 1   
-- ) b pivot(count(urngem) for ealter in ([45-60],[90-95],[60-75],[75+])) p) mb024_p
-- on basis.gendertypeid = mb024_p.gendertypeid and basis.seg_kgm = mb024_p.seg_kgm
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana] 
-- where mb012 = 1  
-- ) b pivot(count(urngem) for ealter in ([45-60],[90-95],[60-75],[75+]))P) mb012
-- on basis.gendertypeid = mb012.gendertypeid and basis.seg_kgm = mb012.seg_kgm
-- left join
-- (select gendertypeid, seg_kgm, [45-60],[90-95],[60-75],[75+] from (select gendertypeid, seg_kgm, ealter, urngem from[2025-10-14-108_Nutrisana]
-- where mb012_p = 1  
-- ) b pivot(count(urngem) for ealter in ([45-60],[90-95],[60-75],[75+]))P) mb012_p
-- on basis.gendertypeid = mb012_p.gendertypeid and basis.seg_kgm = mb012_p.seg_kgm

-- where mb024.gendertypeid = 2 
-- group by basis.gendertypeid, basis.seg_kgm, mb024.seg_kgm,
-- mb012_p.[60-75],		mb012_p.[75+],		
-- mb012.[60-75],			mb012.[75+],		
-- mb024_p.[60-75],		mb024_p.[75+],		
-- mb024.[60-75],			mb024.[75+]
-- order by mb024.seg_kgm
-- ;



-- exec sp_rename '2025-10-14-108_Nutrisana','2025-10-14-108_2025-10-14-108_Nutrisana'

-- select * into[2025-10-14-108_Nutrisana] from  [2025-05-20-126_2025-10-14-108_Nutrisana] where old is null
-- drop table[2025-10-14-108_Nutrisana]

