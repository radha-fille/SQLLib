select st.StudentId,c.DivisionID,c.SiteID
	,sy.SchoolYearName as SchoolYear
	,t.TermCode as AssessmentWindow
	,st.StateTestingIdentifier as STI
	,st.LastName as StudentLastName
	,st.FirstName as StudentFirstName
	,st.Gender
	,(case st.AdministrationMethod when 'Standard' then 0 when 'Non-Standard' then 1 when 'Exempt' then 2 end) as AdministrationCondition
	,st.Ethnicity
	,st.Race as RaceCode
	,CONVERT(varchar,st.DateOfBirth,101) as BirthDate
	,st.NativeEnglish
	,sm.DualLanguage
	,c.DivisionName as Division
	,c.SiteName as School
	,gl.GradeLevelCode as Grade
	,gl.GradeLevelId
	,c.PrimaryTeacherLastName as TeacherLastName
	,c.PrimaryTeacherFirstName as TeacherFirstName
	,(case sm.ServiceEIRI when 'True' then 1 when 'False' then 0 else sm.ServiceEIRI end) as Service_EIRI
	,(case sm.ServiceEsl when 'True' then 1 when 'False' then 0 else sm.ServiceEsl end) as Service_ESL
	,(case sm.ServiceTitleI when 'True' then 1 when 'False' then 0 else sm.ServiceTitleI end) as Service_TitleI
	,(case sm.ServiceTutor when 'True' then 1 when 'False' then 0 else sm.ServiceTutor end) as Service_Tutor
	,(case sm.ServiceNone when 'True' then 1 when 'False' then 0 else sm.ServiceNone end) as Service_None
	,(case sm.ServiceOther when 'True' then 1 when 'False' then 0 else sm.ServiceOther end) as Service_Other
	,sm.ServiceOtherName as Service_OtherName
	,st.BelowBenchmarkCount as PALSID
	,st.AssessmentCount as PALSAssessed
	,(case Identified when 0 then 0 when 'False' then 0 when 1 then 1 when 'True'  then 1 end) as PALSIDStatus
	,(case st.AdministrationMethod 
			when '' then ''
			when 'Non-Standard' then (case count(av.AssessmentName) when 0 then 0 else 2 end) 
			when 'Exempt' then '' 
			when 'Standard' then  (case count(distinct ar.AssessmentStop) when vwp.AssessmentCount then 1 else 0 end)
		end) as Completed
	,CONVERT(varchar,max(ar.AssessmentStop),101) as AssessmentDate
	,sum(case av.AssessmentName when 'Letter Names' then ar.Score end) as ABRC		
	,'ABRC-'+t.TermCode+'-'+gl.GradeLevelCode as ABRC_II
	,sum(case av.AssessmentName when 'Letter Sounds' then ar.Score end) as LTRS
	,'LTRS-'+t.TermCode+'-'+gl.GradeLevelCode  as LTRS_II
	,sum(case av.AssessmentName when 'Beginning Sounds Expressive' then ar.Score end) as BEGE
	,'BEGE-'+t.TermCode+'-'+gl.GradeLevelCode as BEGE_II
	,sum(case av.AssessmentName when 'Phoneme Blending' then ar.Score end)  as BLND
	,'BLND-'+t.TermCode+'-'+gl.GradeLevelCode as BLND_II
	,sum(case av.AssessmentName when 'Phoneme Segmenting' then ar.Score end)  as SGPH
	,'SGPH-'+t.TermCode+'-'+gl.GradeLevelCode as SGPH_II
	,sum(case av.AssessmentName when 'Encoding' then ar.Score end) as ENCD_Raw	
	,sum(case av.AssessmentName when 'Encoding' then (case arm.[Key] when 'reportingScore' then cast(arm.[Value] as int) end) end) as ENCD_Binary	
	,'ENCD_Raw-'+t.TermCode+'-'+gl.GradeLevelCode as ENCD_II	
	,sum(case av.AssessmentName when 'Real Word Decoding' then ar.Score end)  as DCRL
	,'DCRL-'+t.TermCode+'-'+gl.GradeLevelCode as DCRL_II
	,sum(case av.AssessmentName when 'Pseudoword Decoding' then ar.Score end)  as DCPS
	,'DCPS-'+t.TermCode+'-'+gl.GradeLevelCode as DCPS_II
	,sum(case av.AssessmentName when 'Oral Reading Fluency: Passage 1' then ar.Score end) as ORF1
	,'ORF1-'+t.TermCode+'-'+gl.GradeLevelCode as ORF1_II
	,sum(case av.AssessmentName when 'Oral Reading Fluency: Passage 2' then ar.Score end) as ORF2
	,'ORF2-'+t.TermCode+'-'+gl.GradeLevelCode as ORF2_II
	,sum(case av.AssessmentName when 'Passage Retell' then cast(ar.Score as float) end)  as LRET
	,'LRET-'+t.TermCode+'-'+gl.GradeLevelCode as LRET_II
	,sum(case av.AssessmentName when 'Expressive Comprehension Questions' then cast(ar.Score as float) end)  as LEXP
	,'LEXP-'+t.TermCode+'-'+gl.GradeLevelCode as LEXP_II
	,sum(case av.AssessmentName when 'Nonsense Sentences' then ar.Score end)  as SNTX
	,'SNTX-'+t.TermCode+'-'+gl.GradeLevelCode as SNTX_II
	,sum(case av.AssessmentName when 'Relational Vocabulary' then ar.Score end)  as REVO
	,'REVO-'+t.TermCode+'-'+gl.GradeLevelCode as REVO_II
	,sum(case av.AssessmentName when 'Vocabulary Fluency' then cast(ar.Score as float) end)  as EXVO
	,'EXVO-'+t.TermCode+'-'+gl.GradeLevelCode as EXVO_II
	,sum(case av.AssessmentName when 'Rapid Automatized Naming (RAN): Letters' then ar.Score end)  as RAN
	,'RAN-'+t.TermCode+'-'+gl.GradeLevelCode as RAN_Flag
	,(case vw.RiskBand when 'High Risk' then '1' when 'Moderate Risk' then '2' when 'Low Risk' then '3' else '' end) as BOR_CB
	,(case vw.RiskBand when 'High Risk' then 1 else 0 end) as EIRI
	,vw.RiskBandScore as SummedScore
	,CONVERT(varchar(16),(getDate() AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time'),120) as DateTimeStamp
from Students st
inner join StudentMetadata sm on sm.StudentId=st.StudentId
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearId=sa.SchoolYearId
		and av.TermId=sa.TermId
		and av.GradeLevelId=sa.GradeLevelId
        and av.TermCode=sm.TermCode	
inner join Terms t on t.TermId=sa.TermId
inner join SchoolYears sy on sy.SchoolYearId=sa.SchoolYearId
inner join GradeLevels gl on gl.GradeLevelId=sa.GradeLevelId
inner join vw_PeriodAssessmentCount vwp on vwp.GradeLevelCode=av.GradeLevelCode and vwp.SchoolYearCode=av.SchoolYearCode and vwp.TermCode=av.TermCode
left outer  join AssessmentResults  ar on ar.AssessmentVersionId=av.AssessmentVersionId and ar.StudentID=sa.StudentID
left outer join AssessmentResultMetadata arm on arm.AssessmentResultId=ar.AssessmentResultId and arm.[Key]='reportingScore'
left outer join vw_RiskBandScore vw on vw.StudentId=st.StudentId and vw.TermCode=av.TermCode and vw.SchoolYearCode=av.SchoolYearCode and vw.GradeLevelCode=av.GradeLevelCode
where c.DivisionId=@DivisionId
and av.TermID=@TermId
and av.SchoolYearId=@SchoolYearId
group by st.StudentId
	,sy.SchoolYearName
	,c.DivisionID
	,c.SiteID
	,st.AdministrationMethod
	,gl.GradeLevelCode
	,gl.GradeLevelId
	,t.TermCode
	,st.StateTestingIdentifier
	,st.LastName
	,st.FirstName
	,st.Gender
	,st.Ethnicity
	,st.Race
	,st.DateOfBirth
	,st.NativeEnglish
	,sm.DualLanguage
	,c.DivisionName
	,c.SiteName
	,c.PrimaryTeacherLastName
	,c.PrimaryTeacherFirstName
	,sm.ServiceEiri
	,sm.ServiceEsl
	,sm.ServiceTitleI
	,sm.ServiceTutor
	,sm.ServiceNone
	,sm.ServiceOther
	,sm.ServiceOtherName
	,st.AssessmentCount
	,st.BelowBenchmarkCount
	,Identified
	,vw.RiskBandScore
	,vw.RiskBand
	,vwp.AssessmentCount
order by c.SiteName
	,gl.GradeLevelId
	,c.PrimaryTeacherLastName
	,c.PrimaryTeacherFirstName
	,st.LastName
	,st.FirstName