 drop table if exists woolovers
select * into Woolovers from [dbo].[MB_GES_2020] where MB024 = 1


insert into Woolovers select * from MB_GES_2020 where (LIGHT24 = 1 or MB024 = 1 ) and URNgem not in (select URNgem from Woolovers) and URNHHGEM in (
	select distinct(URNHHGEM) from PERSON_1 where URN in (
		select distinct(URN) from TRANSACTION_1 where affiliateid in (	1720,2030,2190,2684,2721,2722,2723,2921,2922,2931,
																		2991,3071,3231,3271,3321,3361,3641,3651,3801))
		  or urn in (select urn from infos_1 where affiliateid in (1590))or URN in (select urn from CLUSTER_1 where ClusterID in ('C09')))


	
CREATE CLUSTERED INDEX [ClusteredIndex-fgdswooloversadsaf54545f] ON Woolovers
([urngem] ASC) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

delete from Woolovers where gendertypeid not in (2)

delete from Woolovers where urngem in (select urngem from zusatz_1 where urn in (
	select distinct(urn) from TRANSACTION_1 where AFFILIATEID = 3581))
	
delete from Woolovers where DNMFLAG = 1

delete from Woolovers where urngem in (select urngem from zusatz_1 where urn in (
	select distinct(urn) from TRANSACTION_1 where AFFILIATEID in (
		select AFFILIATEEXCLUDEID from AFFILIATEEXCLUDE_1 where AFFILIATEID = 3581))
		) 
and CountAffiliates = 2

delete from Woolovers where urngem in (select urngem from zusatz_1 where urn in (
	select distinct(urn) from PRIVATE_1 where AFFILIATEID = 3581))
	
delete from Woolovers where urngem in (Select urngem from zusatz_1 where urn in (select urn from TOERASE_1))

delete from Woolovers where (GEBJAHR not between '1932' and '1965') 
or (GEBJAHR is NULL and [ALTER] <'5')

delete from Woolovers where URNHHGEM in (select URNHHGEM from PERSON_1 where urn in (
	select distinct(urn) from TRANSACTION_1	where AFFILIATEID = 3581)	)

delete from Woolovers where urngem in (select URNGEM from nix_pers)
--delete from Woolovers where urngem in (select urngem from ZUSATZ_1 where URNHHGEM in (select URNHHGEM from nix_hh))
delete from Woolovers where urngem in (select urngem from ZUSATZ_1 where URNHHGEM in (select URNHHGEM from robinson))
delete from Woolovers where urngem not in (select URNGEM from gem_gesamt)
delete from Woolovers where urngem in (select URNGEM from nix_ausland)
delete from Woolovers where urngem in (select URNGEM from nix_tote)
delete from Woolovers where urngem in (select urngem from zusatz_1 where urn in (select urn from umz_tbl where flag = 'Umgezogen'))

update Woolovers set GEBJAHR = GESGEB.GEBJAHR from GESGEB where Woolovers.urngem = GESGEB.URNGEM and (Woolovers.GEBJAHR is null or Woolovers.GEBJAHR ='')

alter table Woolovers add 
	alter_kl char(10),
	urn numeric(18,0),
	score_kgm real,
	seg_kgm numeric(3,0),
	synergie int  not null  DEFAULT 0,
	syn012 int  not null  DEFAULT 0,
	syn012m int  not null  DEFAULT 0,
	ealter char(6)
	-- ,old int ,
	-- kauf_b int 

go	

update Woolovers set Woolovers.urn = ZUSATZ_1.URN from Woolovers, ZUSATZ_1 where Woolovers.urngem = ZUSATZ_1.URNGEM

update Woolovers set woolovers.kauf_b = 1 where URN in ( select distinct (URN) from TRANSACTION_1 where AFFILIATEID in (2190,2931,3271,3651,3801,2921,2922))


select urn, affiliateid into zg1 from TRANSACTION_1 where ACTIVITYTYPEID in (2,5) and affiliateid in ( 
																		1720,2030,2190,2684,2721,2722,2723,2921,2922,2931,
																		2991,3071,3231,3271,3321,3361,3641,3651,3801) and datediff(m, activitydate, getdate()) <= 12
																	group by URN, AFFILIATEID having COUNT(*) >= 2

update WoolOvers set syn012m = 1 where  URNHHGEM in (
select distinct(URNHHGEM) from PERSON_1 where urn in (select urn from zg1  group by urn ))

drop table zg1

update Woolovers set syn012 = a.anzahl from Woolovers,( select urnhhgem,COUNT(urnhhgem) as anzahl from TRANSACTION_1, PERSON_1
												where affiliateid in(	1720,2030,2190,2684,2721,2722,2723,2921,2922,2931,
																		2991,3071,3231,3271,3321,3361,3641,3651,3801) and datediff(m, activitydate, getdate()) <= 12 
																		and transaction_1.urn = PERSON_1.urn
																		group by urnhhgem) a
										  where a.URNHHGEM = Woolovers.urnhhgem 



update Woolovers set syn012 = syn012 + a.anzahl from Woolovers, (select urnhhgem,COUNT(urnhhgem) as anzahl from cluster_1
												where ClusterID in('C09') and datediff(m, activitydate, getdate()) <= 12 
																		group by urnhhgem) a
										  where a.URNHHGEM = Woolovers.urnhhgem 
	


update Woolovers set synergie = a.anzahl from Woolovers,( select urnhhgem,COUNT(urnhhgem) as anzahl from TRANSACTION_1, PERSON_1
												where affiliateid in(	1720,2030,2190,2684,2721,2722,2723,2921,2922,2931,
																		2991,3071,3231,3271,3321,3361,3641,3651,3801)
																		and transaction_1.urn = PERSON_1.urn
																		group by urnhhgem) a
										  where a.URNHHGEM = Woolovers.urnhhgem 

update Woolovers set synergie = synergie + a.anzahl from Woolovers, (select PERSON_1.urnhhgem,COUNT(PERSON_1.urnhhgem) as anzahl from INFOS_1, PERSON_1
												where affiliateid in(	1590)
																		and INFOS_1.urn = PERSON_1.urn
																		group by PERSON_1.urnhhgem) a
										  where a.URNHHGEM = Woolovers.urnhhgem 


update Woolovers set synergie =  synergie + a.anzahl from Woolovers, (select urnhhgem,COUNT(urnhhgem) as anzahl from cluster_1
												where ClusterID in('C09')
																		group by urnhhgem) a
										  where a.URNHHGEM = Woolovers.urnhhgem 


update Woolovers 
set alter_kl = 
	(case 
--when GEBJAHR >= 1981 and GEBJAHR <= 1995 and gebjahr is not null THEN '30-45'
--	  when GEBJAHR >= 1966 and GEBJAHR <= 1980 and gebjahr is not null THEN '45-60'
	  when GEBJAHR >= 1950 and GEBJAHR <= 1965 and gebjahr is not null THEN '60-75'
	  when GEBJAHR >= 1935 and GEBJAHR <= 1949 and gebjahr is not null THEN '75+'
      --when GEBJAHR IS null and [ALTER] IN ('3') THEN '30-45'
      --when GEBJAHR IS null and [ALTER] IN ('4') THEN '45-60'
      when GEBJAHR IS null and [ALTER] IN ('5','6') THEN '60-75'
	  when GEBJAHR IS null and [ALTER] IN ('7') THEN '75+'
END)


update Woolovers 
	set ealter = 
	(case when gebjahr >= 1945 and gebjahr <= 1965 and gebjahr is not null then '60-80'
				END) 



--select * from campaign_1 where affiliateid = 3581 and description2 like '%2025-09-09%' order by campaignid desc

update Woolovers set old = 1 where urngem in (Select urngem from zusatz_1 where urn in (Select urn from delivery_1 where affiliateid = 3581 and campaignid in( 147,148 )))


update Woolovers set 
	score_kgm = scores_woolovers.score_kgm,
	seg_kgm = scores_woolovers.seg_kgm
from Woolovers join scores_woolovers on (Woolovers.urngem = scores_woolovers.urngem)






-- SYNERGIE

--select
--	mb012_p.[60-75],		  mb012_p.[75+],		
--	mb012.[60-75],			  mb012.[75+],			
--	mb024_p.[60-75],		  mb024_p.[75+],		
--	mb024.[60-75],			  mb024.[75+],			
--	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
--		mb024_rest.[60-75],		  mb024_rest.[75+]	
--from 
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012_P = 1 and synergie >= 1    
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012 = 1 and synergie >= 1   
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
--where mb024_p = 1 and synergie >= 1  
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 = 1 and synergie >= 1  
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024_p is null and synergie >= 1  
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 is null and synergie >= 1  
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
--mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
--and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
--and mb012_p.gendertypeid=1
--order by mb012_p.seg_kgm

select 
	mb012_p.[60-75],		  mb012_p.[75+],		
	mb012.[60-75],			  mb012.[75+],			
	mb024_p.[60-75],		  mb024_p.[75+],		
	mb024.[60-75],			  mb024.[75+],			
	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
		mb024_rest.[60-75],		  mb024_rest.[75+]	

from 
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012_P = 1 and synergie >= 1   
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012 = 1 and synergie >= 1   
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
where mb024_p = 1 and synergie >= 1  
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 = 1 and synergie >= 1  
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p is null and synergie >= 1  
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 is null and synergie >= 1  
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm



-- SYNERGIE

--select
--	mb012_p.[60-75],		  mb012_p.[75+],		
--	mb012.[60-75],			  mb012.[75+],			
--	mb024_p.[60-75],		  mb024_p.[75+],		
--	mb024.[60-75],			  mb024.[75+],			
--	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
--		mb024_rest.[60-75],		  mb024_rest.[75+]	
--from 
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012_P = 1 and synergie >= 1    
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012 = 1 and synergie >= 1   
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
--where mb024_p = 1 and synergie >= 1  
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 = 1 and synergie >= 1  
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024_p is null and synergie >= 1  
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 is null and synergie >= 1  
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
--mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
--and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
--and mb012_p.gendertypeid=1
--order by mb012_p.seg_kgm


--syn012

select 
	mb012_p.[60-75],		  mb012_p.[75+],		
	mb012.[60-75],			  mb012.[75+],			
	mb024_p.[60-75],		  mb024_p.[75+],		
	mb024.[60-75],			  mb024.[75+],			
	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
		mb024_rest.[60-75],		  mb024_rest.[75+]				
from 
(select gendertypeid, seg_kgm,  [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012_P = 1 and syn012 >= 1 
) b pivot(count(urngem) for alter_kl in([60-75],[75+])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012 = 1 and syn012 >= 1  
) b pivot(count(urngem) for alter_kl in([60-75],[75+])) p) mb012,
(select gendertypeid, seg_kgm,  [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p = 1 and syn012 >= 1 
) b pivot(count(urngem) for alter_kl in([60-75],[75+]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 = 1 and syn012 >= 1  
) b pivot(count(urngem) for alter_kl in([60-75],[75+]))P) mb024,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p is null and syn012 >= 1  
) b pivot(count(urngem) for alter_kl in([60-75],[75+]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 is null and syn012 >= 1  
) b pivot(count(urngem) for alter_kl in([60-75],[75+]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm


--select 
--	mb012_p.[60-75],		  mb012_p.[75+],		
--	mb012.[60-75],			  mb012.[75+],			
--	mb024_p.[60-75],		  mb024_p.[75+],		
--	mb024.[60-75],			  mb024.[75+],			
--	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
--		mb024_rest.[60-75],		  mb024_rest.[75+]	
--from 
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012_P = 1 and synergie >= 1   
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012 = 1 and synergie >= 1   
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
--where mb024_p = 1 and synergie >= 1  
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 = 1 and synergie >= 1  
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024_p is null and synergie >= 1  
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 is null and synergie >= 1  
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
--mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
--and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
--and mb012_p.gendertypeid=2
--order by mb012_p.seg_kgm


-- M�nner �frei old
select
--	mb012_p.[60-75],		  mb012_p.[75+],		
--	mb012.[60-75],			  mb012.[75+],			
--	mb024_p.[60-75],		  mb024_p.[75+],		
--	mb024.[60-75],			  mb024.[75+],			
--	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
--		mb024_rest.[60-75],		  mb024_rest.[75+]	
--from 
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012_P = 1 and synergie >= 1 and old is null
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012 = 1 and synergie >= 1   and old is null
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
--where mb024_p = 1 and synergie >= 1  and old is null
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 = 1 and synergie >= 1  and old is null
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024_p is null and synergie >= 1  and old is null
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 is null and synergie >= 1  and old is null
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
--mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
--and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
--and mb012_p.gendertypeid=1
--order by mb012_p.seg_kgm

--Frauen �frei old
select 
	mb012_p.[60-75],		  mb012_p.[75+],		
	mb012.[60-75],			  mb012.[75+],			
	mb024_p.[60-75],		  mb024_p.[75+],		
	mb024.[60-75],			  mb024.[75+],			
	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
		mb024_rest.[60-75],		  mb024_rest.[75+]		
from 
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012_P = 1 and synergie >= 1   and old is null
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012 = 1 and synergie >= 1   and old is null
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
where mb024_p = 1 and synergie >= 1  and old is null
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 = 1 and synergie >= 1  and old is null
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p is null and synergie >= 1  and old is null
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 is null and synergie >= 1  and old is null
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm



--M�nner
--select
--	mb012_p.[60-75],		  mb012_p.[75+],		
--	mb012.[60-75],			  mb012.[75+],			
--	mb024_p.[60-75],		  mb024_p.[75+],		
--	mb024.[60-75],			  mb024.[75+],			
--	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
--		mb024_rest.[60-75],		  mb024_rest.[75+]	
--from 
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012_P = 1   and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012 = 1     and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
--where mb024_p = 1    and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 = 1    and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024_p is null    and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 is null    and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
--mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
--and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
--and mb012_p.gendertypeid=1
--order by mb012_p.seg_kgm


-- Frauen 
--select 
--	mb012_p.[60-75],		  mb012_p.[75+],		
--	mb012.[60-75],			  mb012.[75+],			
--	mb024_p.[60-75],		  mb024_p.[75+],		
--	mb024.[60-75],			  mb024.[75+],			
--	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
--		mb024_rest.[60-75],		  mb024_rest.[75+]	
--from 
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012_P = 1     and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012 = 1     and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
--where mb024_p = 1    and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 = 1    and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024_p is null    and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 is null    and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
--mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
--and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
--and mb012_p.gendertypeid=2
--order by mb012_p.seg_kgm


--M�nner �frei old
--select
--	mb012_p.[60-75],		  mb012_p.[75+],		
--	mb012.[60-75],			  mb012.[75+],			
--	mb024_p.[60-75],		  mb024_p.[75+],		
--	mb024.[60-75],			  mb024.[75+],			
--	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
--		mb024_rest.[60-75],		  mb024_rest.[75+]	
--from 
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012_P = 1  and old is null and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012 = 1    and old is null and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
--where mb024_p = 1   and old is null and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 = 1   and old is null and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024_p is null   and old is null and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 is null   and old is null and syn012 >= 1
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
--mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
--and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
--and mb012_p.gendertypeid=1
--order by mb012_p.seg_kgm


-- Frauen �frei old
select 
	mb012_p.[60-75],		  mb012_p.[75+],		
	mb012.[60-75],			  mb012.[75+],			
	mb024_p.[60-75],		  mb024_p.[75+],		
	mb024.[60-75],			  mb024.[75+],			
	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
		mb024_rest.[60-75],		  mb024_rest.[75+]	
from 
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012_P = 1    and old is null and syn012 >= 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012 = 1    and old is null and syn012 >= 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
where mb024_p = 1   and old is null and syn012 >= 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 = 1   and old is null and syn012 >= 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p is null   and old is null and syn012 >= 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 is null   and old is null and syn012 >= 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm

---kgm


--M�nner
--select
--	mb012_p.[60-75],		  mb012_p.[75+],		
--	mb012.[60-75],			  mb012.[75+],			
--	mb024_p.[60-75],		  mb024_p.[75+],		
--	mb024.[60-75],			  mb024.[75+],			
--	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
--		mb024_rest.[60-75],		  mb024_rest.[75+]	
--from 
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012_P = 1   
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012 = 1     
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
--where mb024_p = 1    
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 = 1    
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024_p is null    
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 is null    
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
--mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
--and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
--and mb012_p.gendertypeid=1
--order by mb012_p.seg_kgm


-- Frauen KGM
select 
	mb012_p.[60-75],		  mb012_p.[75+],		
	mb012.[60-75],			  mb012.[75+],			
	mb024_p.[60-75],		  mb024_p.[75+],		
	mb024.[60-75],			  mb024.[75+]	

from 
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012_P = 1     
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012 = 1     
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
where mb024_p = 1    
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 = 1    
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p is null    
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 is null    
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm


--M�nner �frei old
--select
--	mb012_p.[60-75],		  mb012_p.[75+],		
--	mb012.[60-75],			  mb012.[75+],			
--	mb024_p.[60-75],		  mb024_p.[75+],		
--	mb024.[60-75],			  mb024.[75+],			
--	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
--		mb024_rest.[60-75],		  mb024_rest.[75+]	
--from 
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012_P = 1  and old is null 
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb012 = 1    and old is null 
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
--where mb024_p = 1   and old is null 
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 = 1   and old is null 
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024_p is null   and old is null 
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
--(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
--where mb024 is null   and old is null 
--) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
--mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
--and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
--and mb012_p.gendertypeid=1
--order by mb012_p.seg_kgm


-- Frauen �frei old
select 
mb012_p.[60-75],		  mb012_p.[75+],		
	mb012.[60-75],			  mb012.[75+],			
	mb024_p.[60-75],		  mb024_p.[75+],		
	mb024.[60-75],			  mb024.[75+]	
from 
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012_P = 1    and old is null 
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012 = 1    and old is null 
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
where mb024_p = 1   and old is null 
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 = 1   and old is null 
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p is null   and old is null 
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 is null   and old is null 
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm

--kauf_b
--synergie
select 
	mb012_p.[60-75],		  mb012_p.[75+],		
	mb012.[60-75],			  mb012.[75+],			
	mb024_p.[60-75],		  mb024_p.[75+],		
	mb024.[60-75],			  mb024.[75+],			
	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
		mb024_rest.[60-75],		  mb024_rest.[75+]	

from 
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012_P = 1 and synergie >= 1  and kauf_b = 1 
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012 = 1 and synergie >= 1   and kauf_b = 1 
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
where mb024_p = 1 and synergie >= 1  and kauf_b = 1 
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 = 1 and synergie >= 1  and kauf_b = 1 
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p is null and synergie >= 1  and kauf_b = 1 
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 is null and synergie >= 1  and kauf_b = 1 
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm



--synerge �frei
--Frauen �frei old
select 
	mb012_p.[60-75],		  mb012_p.[75+],		
	mb012.[60-75],			  mb012.[75+],			
	mb024_p.[60-75],		  mb024_p.[75+],		
	mb024.[60-75],			  mb024.[75+],			
	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
		mb024_rest.[60-75],		  mb024_rest.[75+]		
from 
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012_P = 1 and synergie >= 1   and old is null and kauf_b=1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012 = 1 and synergie >= 1   and old is null and kauf_b=1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
where mb024_p = 1 and synergie >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 = 1 and synergie >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p is null and synergie >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 is null and synergie >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm




--synerg12
select 
	mb012_p.[60-75],		  mb012_p.[75+],		
	mb012.[60-75],			  mb012.[75+],			
	mb024_p.[60-75],		  mb024_p.[75+],		
	mb024.[60-75],			  mb024.[75+],			
	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
		mb024_rest.[60-75],		  mb024_rest.[75+]				
from 
(select gendertypeid, seg_kgm,  [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012_P = 1 and syn012 >= 1  and kauf_b = 1
) b pivot(count(urngem) for alter_kl in([60-75],[75+])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012 = 1 and syn012 >= 1   and kauf_b = 1
) b pivot(count(urngem) for alter_kl in([60-75],[75+])) p) mb012,
(select gendertypeid, seg_kgm,  [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p = 1 and syn012 >= 1  and kauf_b = 1
) b pivot(count(urngem) for alter_kl in([60-75],[75+]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 = 1 and syn012 >= 1   and kauf_b = 1
) b pivot(count(urngem) for alter_kl in([60-75],[75+]))P) mb024,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p is null and syn012 >= 1   and kauf_b = 1
) b pivot(count(urngem) for alter_kl in([60-75],[75+]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 is null and syn012 >= 1   and kauf_b = 1
) b pivot(count(urngem) for alter_kl in([60-75],[75+]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm



--synerge12 �frei

select 
	mb012_p.[60-75],		  mb012_p.[75+],		
	mb012.[60-75],			  mb012.[75+],			
	mb024_p.[60-75],		  mb024_p.[75+],		
	mb024.[60-75],			  mb024.[75+],			
	mb024_p_rest.[60-75],	  mb024_p_rest.[75+],	
		mb024_rest.[60-75],		  mb024_rest.[75+]	
from 
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012_P = 1    and old is null and syn012 >= 1 and kauf_b=1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012 = 1    and old is null and syn012 >= 1 and kauf_b=1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
where mb024_p = 1   and old is null and syn012 >= 1 and kauf_b=1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 = 1   and old is null and syn012 >= 1 and kauf_b=1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p is null   and old is null and syn012 >= 1 and kauf_b=1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 is null   and old is null and syn012 >= 1 and kauf_b=1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm

-- Frauen KGM
select 
	mb012_p.[60-75],		  mb012_p.[75+],		
	mb012.[60-75],			  mb012.[75+],			
	mb024_p.[60-75],		  mb024_p.[75+],		
	mb024.[60-75],			  mb024.[75+]	

from 
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012_P = 1      and kauf_b = 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012 = 1      and kauf_b = 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
where mb024_p = 1     and kauf_b = 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 = 1     and kauf_b = 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p is null     and kauf_b = 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 is null     and kauf_b = 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm



-- Frauen �frei old
select 
mb012_p.[60-75],		  mb012_p.[75+],		
	mb012.[60-75],			  mb012.[75+],			
	mb024_p.[60-75],		  mb024_p.[75+],		
	mb024.[60-75],			  mb024.[75+]	
from 
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012_P = 1    and old is null  and kauf_b = 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) P) mb012_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb012 = 1    and old is null  and kauf_b = 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+])) p) mb012,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers 
where mb024_p = 1   and old is null  and kauf_b = 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_p,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 = 1   and old is null  and kauf_b = 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024_p is null   and old is null  and kauf_b = 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P)mb024_p_rest,
(select gendertypeid, seg_kgm, [60-75],[75+] from (select gendertypeid, seg_kgm, alter_kl, urngem from Woolovers
where mb024 is null   and old is null  and kauf_b = 1
) b pivot(count(urngem) for alter_kl in ([60-75],[75+]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm






--echtalter synergie

select 
	mb012_p.[60-80],			
	mb012.[60-80],				
	mb024_p.[60-80],			
	mb024.[60-80],				
	mb024_p_rest.[60-80],		
	mb024_rest.[60-80]			
from 
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012_P = 1 and synergie >= 1 
) b pivot(count(urngem) for ealter in([60-80])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012 = 1 and synergie >= 1  
) b pivot(count(urngem) for ealter in([60-80])) p) mb012,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p = 1 and synergie >= 1 
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 = 1 and synergie >= 1  
) b pivot(count(urngem) for ealter in([60-80]))P) mb024,
(select gendertypeid, seg_kgm, [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p is null and synergie >= 1  
) b pivot(count(urngem) for ealter in([60-80]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 is null and synergie >= 1  
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm




--echtalter sy012 

select 
	mb012_p.[60-80],			
	mb012.[60-80],				
	mb024_p.[60-80],			
	mb024.[60-80],				
	mb024_p_rest.[60-80],		
	mb024_rest.[60-80]			
from 
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012_P = 1 and syn012 >= 1 
) b pivot(count(urngem) for ealter in([60-80])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012 = 1 and syn012 >= 1  
) b pivot(count(urngem) for ealter in([60-80])) p) mb012,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p = 1 and syn012 >= 1 
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 = 1 and syn012 >= 1  
) b pivot(count(urngem) for ealter in([60-80]))P) mb024,
(select gendertypeid, seg_kgm, [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p is null and syn012 >= 1  
) b pivot(count(urngem) for ealter in([60-80]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 is null and syn012 >= 1  
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm


--echtalter KGM

select 
	mb012_p.[60-80],			
	mb012.[60-80],				
	mb024_p.[60-80],			
	mb024.[60-80]		
from 
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012_P = 1 
) b pivot(count(urngem) for ealter in([60-80])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012 = 1  
) b pivot(count(urngem) for ealter in([60-80])) p) mb012,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p = 1  
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 = 1 
) b pivot(count(urngem) for ealter in([60-80]))P) mb024,
(select gendertypeid, seg_kgm, [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p is null  
) b pivot(count(urngem) for ealter in([60-80]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 is null  
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm

--echtalter syn �frei

select 
	mb012_p.[60-80],			
	mb012.[60-80],				
	mb024_p.[60-80],			
	mb024.[60-80],				
	mb024_p_rest.[60-80],		
	mb024_rest.[60-80]			
from 
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012_P = 1 and synergie >= 1 and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012 = 1 and synergie >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) p) mb012,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p = 1 and synergie >= 1 and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 = 1 and synergie >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024,
(select gendertypeid, seg_kgm, [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p is null and synergie >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 is null and synergie >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm



--echtalter syn12 �frei
select 
	mb012_p.[60-80],			
	mb012.[60-80],				
	mb024_p.[60-80],			
	mb024.[60-80],				
	mb024_p_rest.[60-80],		
	mb024_rest.[60-80]			
from 
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012_P = 1 and syn012 >= 1 and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012 = 1 and syn012 >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) p) mb012,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p = 1 and syn012 >= 1 and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 = 1 and syn012 >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024,
(select gendertypeid, seg_kgm, [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p is null and syn012 >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 is null and syn012 >= 1  
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm


---kgm �frei 
select 
	mb012_p.[60-80],			
	mb012.[60-80],				
	mb024_p.[60-80],			
	mb024.[60-80]		
from 
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012_P = 1 and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012 = 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) p) mb012,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p = 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 = 1 and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024,
(select gendertypeid, seg_kgm, [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p is null  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 is null  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm

--echtalter synergie kauf

select 
	mb012_p.[60-80],			
	mb012.[60-80],				
	mb024_p.[60-80],			
	mb024.[60-80],				
	mb024_p_rest.[60-80],		
	mb024_rest.[60-80]			
from 
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012_P = 1 and synergie >= 1  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012 = 1 and synergie >= 1  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) p) mb012,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p = 1 and synergie >= 1 and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 = 1 and synergie >= 1  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024,
(select gendertypeid, seg_kgm, [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p is null and synergie >= 1  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 is null and synergie >= 1  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm




--echtalter sy012 

select 
	mb012_p.[60-80],			
	mb012.[60-80],				
	mb024_p.[60-80],			
	mb024.[60-80],				
	mb024_p_rest.[60-80],		
	mb024_rest.[60-80]			
from 
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012_P = 1 and syn012 >= 1 and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012 = 1 and syn012 >= 1  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) p) mb012,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p = 1 and syn012 >= 1 and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 = 1 and syn012 >= 1  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024,
(select gendertypeid, seg_kgm, [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p is null and syn012 >= 1  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 is null and syn012 >= 1  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm


--echtalter KGM

select 
	mb012_p.[60-80],			
	mb012.[60-80],				
	mb024_p.[60-80],			
	mb024.[60-80]		
from 
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012_P = 1 and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012 = 1  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) p) mb012,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p = 1  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 = 1 and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024,
(select gendertypeid, seg_kgm, [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p is null  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 is null  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm

--echtalter syn �frei

select 
	mb012_p.[60-80],			
	mb012.[60-80],				
	mb024_p.[60-80],			
	mb024.[60-80],				
	mb024_p_rest.[60-80],		
	mb024_rest.[60-80]			
from 
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012_P = 1 and synergie >= 1 and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012 = 1 and synergie >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) p) mb012,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p = 1 and synergie >= 1 and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 = 1 and synergie >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024,
(select gendertypeid, seg_kgm, [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p is null and synergie >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 is null and synergie >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm



--echtalter syn12 �frei
select 
	mb012_p.[60-80],			
	mb012.[60-80],				
	mb024_p.[60-80],			
	mb024.[60-80],				
	mb024_p_rest.[60-80],		
	mb024_rest.[60-80]			
from 
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012_P = 1 and syn012 >= 1 and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012 = 1 and syn012 >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) p) mb012,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p = 1 and syn012 >= 1 and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 = 1 and syn012 >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024,
(select gendertypeid, seg_kgm, [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p is null and syn012 >= 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 is null and syn012 >= 1  and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm


---kgm �frei 
select 
	mb012_p.[60-80],			
	mb012.[60-80],				
	mb024_p.[60-80],			
	mb024.[60-80]		
from 
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012_P = 1 and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) P) mb012_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb012 = 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80])) p) mb012,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p = 1  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_p,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 = 1 and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024,
(select gendertypeid, seg_kgm, [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024_p is null  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P)mb024_p_rest,
(select gendertypeid, seg_kgm,  [60-80] from (select gendertypeid, seg_kgm, ealter, urngem from Woolovers
where mb024 is null  and old is null and kauf_b=1
) b pivot(count(urngem) for ealter in([60-80]))P) mb024_rest where 
mb012_p.GENDERTYPEID=mb012.GENDERTYPEID and mb012.GENDERTYPEID=mb024_p.GENDERTYPEID and mb024_p.GENDERTYPEID=mb024.GENDERTYPEID and mb024.GENDERTYPEID=mb024_p_rest.GENDERTYPEID 
and mb024_p_rest.GENDERTYPEID=mb024_rest.GENDERTYPEID
and mb012_p.seg_kgm=mb012.seg_kgm and mb012.seg_kgm=mb024_p.seg_kgm and mb024_p.seg_kgm=mb024.seg_kgm and mb024.seg_kgm=mb024_p_rest.seg_kgm and mb024_p_rest.seg_kgm=mb024_rest.seg_kgm
and mb012_p.gendertypeid=2
order by mb012_p.seg_kgm



exec sp_rename 'Woolovers','2025-12-02-036_WoolOvers'








WITH shmayzer as (
	SELECT DISTINCT p.URNHHGEM from PERSON_1 p JOIN TRANSACTION_1 t on p.urn=t.urn 
	where t.affiliateid in (12,313)

	UNION

	SELECT DISTINCT p.URNHHGEM from PERSON_1 p join INFOS_1 ON p.urn=n.urn
	WHERE n.affiliateid in (10)


)
select * into shmayzer_final from MB_GES_2020 m join shmayzer sh on m.URNHHGEM=sh.URNHHGEM 
where mb0242 = 1 or LIGHT24=1 

deine_Wahl = input("M fuer Männer oder F fuer Frauen pr B fuer Beide\n").lower() 
if deine_Wahl =='M'.lower(): 
	df_men = run_complex_age_report(engine,ages,1,alter_colu,sql_eingabe,f_type) 
	df_men = df_men.set_index('seg_kgm')
	df_men.columns=[f"Men_{c}" for c in df_men.columns]
elif deine_Wahl == 'F'.lower(): 
	df_women = run_complex_age_report(engine,ages,2,alter_colu,sql_eingabe,f_type) 
	df_women =df_women.set_index('seg_kgm')
	df_women.columns=[f"women_{c}" for c in df_women.columns]
else:
	 df_men = run_complex_age_report(engine,ages,1,alter_colu,sql_eingabe,f_type)
	 df_women = run_complex_age_report(engine,ages,2,alter_colu,sql_eingabe,f_type)
	 	df_men = df_men.set_index('seg_kgm')
			df_women =df_women.set_index('seg_kgm')
				df_men.columns=[f"Men_{c}" for c in df_men.columns]
					df_women.columns=[f"women_{c}" for c in df_women.columns]
					df= pd.concat([df_men,df_women],axis=1)






SELECT *
INTO Woolovers
FROM MB_GES_2020
WHERE MB024 = 1;(1,5)

-- Step 2: إضافة أشخاص مؤهلين
INSERT INTO Woolovers
SELECT *
FROM MB_GES_2020
WHERE (MB024 = 1 OR LIGHT24 = 1 OR LIGHT24_HH = 1)(2,3,6,7,9,4,10)
  AND URNgem NOT IN (SELECT URNgem FROM Woolovers)=> (1,2,3,4,5,6,7,9,10),(H1,H2,H3,H4,H5)
  AND URNHHGEM IN (
      SELECT DISTINCT p.URNHHGEM
      FROM PERSON_1 p
      WHERE p.URN IN (SELECT URN FROM TRANSACTION_1 WHERE affiliateid = 100) => (H1,H2,H4)
         OR p.URN IN (SELECT URN FROM INFOS_1 WHERE affiliateid = 200) => (H3,H5)
         OR p.URN IN (SELECT URN FROM CLUSTER_1 WHERE ClusterID = 'C03') => (H5)
  );


=> URNHHGEM(H1,H2,H3,H4,H5)
=>URN(1,2,3,4,5,6,7,9,10)