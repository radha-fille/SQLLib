--high risk

select distinct st.StudentId
,st.Gender
,st.Ethnicity
,st.Race as RaceId
,(case sm.ServiceEIRI when NULL then 0 else sm.ServiceEIRI end) as Service_EIRI
,(case sm.ServiceEsl when NULL then 0 else sm.ServiceEsl end) as Service_ESL
,(case sm.ServiceTitleI when NULL then 0 else sm.ServiceTitleI end) as Service_TitleI
,(case sm.ServiceTutor when NULL then 0 else sm.ServiceTutor end) as Service_Tutor
,(case sm.ServiceNone when NULL then 0 else sm.ServiceNone end) as Service_None
,(case sm.ServiceOther when NULL then 0 else sm.ServiceOther end) as Service_Other
from  Students st
inner join StudentMetadata sm on sm.StudentId=st.StudentId 
inner join AssessmentGroupVersionResults agvr 
	on agvr.StudentId=st.StudentId 
	and agvr.AssessmentGroupStatus='Complete' 
	and agvr.AdministrationMethod='Standard'
	and agvr.RiskBandName='High Risk'
inner join AssessmentGroupVersions agv 
	on agv.AssessmentGroupVersionId=agvr.AssessmentGroupVersionId
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearCode=agv.SchoolYearCode
		and av.TermCode=agv.TermCode
		and av.GradeLevelCode=agv.GradeLevelCode
		and av.TermCode=sm.TermCode				
where c.DivisionID=@DivisionID
and av.GradeLevelCode=@GradeLevelCode
and av.SchoolYearId=@SchoolYearId
and av.TermId =(case @TermId when 2 then 1 else @TermId end)



--mod risk
select distinct st.StudentId
,st.Gender
,st.Ethnicity
,st.Race as RaceId
,(case sm.ServiceEIRI when NULL then 0 else sm.ServiceEIRI end) as Service_EIRI
,(case sm.ServiceEsl when NULL then 0 else sm.ServiceEsl end) as Service_ESL
,(case sm.ServiceTitleI when NULL then 0 else sm.ServiceTitleI end) as Service_TitleI
,(case sm.ServiceTutor when NULL then 0 else sm.ServiceTutor end) as Service_Tutor
,(case sm.ServiceNone when NULL then 0 else sm.ServiceNone end) as Service_None
,(case sm.ServiceOther when NULL then 0 else sm.ServiceOther end) as Service_Other
from  Students st
inner join StudentMetadata sm on sm.StudentId=st.StudentId 
inner join AssessmentGroupVersionResults agvr 
	on agvr.StudentId=st.StudentId 
	and agvr.AssessmentGroupStatus='Complete' 
	and agvr.AdministrationMethod='Standard'
	and agvr.RiskBandName='Moderate Risk'
inner join AssessmentGroupVersions agv 
	on agv.AssessmentGroupVersionId=agvr.AssessmentGroupVersionId
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearCode=agv.SchoolYearCode
		and av.TermCode=agv.TermCode
		and av.GradeLevelCode=agv.GradeLevelCode
		and av.TermCode=sm.TermCode				
where c.DivisionID=@DivisionID
and av.GradeLevelCode=@GradeLevelCode
and av.SchoolYearId=@SchoolYearId
and av.TermId =(case @TermId when 2 then 1 else @TermId end)

--low risk

select distinct st.StudentId
,st.Gender
,st.Ethnicity
,st.Race as RaceId
,(case sm.ServiceEIRI when NULL then 0 else sm.ServiceEIRI end) as Service_EIRI
,(case sm.ServiceEsl when NULL then 0 else sm.ServiceEsl end) as Service_ESL
,(case sm.ServiceTitleI when NULL then 0 else sm.ServiceTitleI end) as Service_TitleI
,(case sm.ServiceTutor when NULL then 0 else sm.ServiceTutor end) as Service_Tutor
,(case sm.ServiceNone when NULL then 0 else sm.ServiceNone end) as Service_None
,(case sm.ServiceOther when NULL then 0 else sm.ServiceOther end) as Service_Other
from  Students st
inner join StudentMetadata sm on sm.StudentId=st.StudentId 
inner join AssessmentGroupVersionResults agvr 
	on agvr.StudentId=st.StudentId 
	and agvr.AssessmentGroupStatus='Complete' 
	and agvr.AdministrationMethod='Standard'
	and agvr.RiskBandName='Low Risk'
inner join AssessmentGroupVersions agv 
	on agv.AssessmentGroupVersionId=agvr.AssessmentGroupVersionId
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearCode=agv.SchoolYearCode
		and av.TermCode=agv.TermCode
		and av.GradeLevelCode=agv.GradeLevelCode
		and av.TermCode=sm.TermCode				
where c.DivisionID=@DivisionID
and av.GradeLevelCode=@GradeLevelCode
and av.SchoolYearId=@SchoolYearId
and av.TermId =(case @TermId when 2 then 1 else @TermId end)

--