--student summary

select distinct st.StudentID,st.FirstName,st.LastName
	,CONCAT(st.StudentID,'-',av.TermId) as StudentTermId
	,CONCAT(st.StudentID,'-',av.TermCode) as StudentTermCode
	,cs.ConstructID
	,cs.ConstructName
	,av.DomainID
	,av.DomainName
	,av.TermId
    ,av.GradeLevelCode
    ,av.AssessmentName
	,av.AssessmentDisplayOrder
	,av.TermName
	,CONCAT(av.SchoolYearCode,'-',av.SchoolYearCode+1) as SchoolYearName
	,st.AdministrationMethod 
	,ar.Score
	,ar.Status
	,av.MaximumScore
	,case when ar.Score<=br.CutOffScore then 1 else 0 end as InstructionalIndicate
	,br.CutOffScore
	,getDate() AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' as DateTimeStamp
from Students st
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join AssessmentVersions  av 
	on av.SchoolYearId=sa.SchoolYearId
		and av.TermId=sa.TermId
		and av.GradeLevelId=sa.GradeLevelId
inner join Constructs cs on cs.DomainName=av.DomainName and cs.Subtest=av.AssessmentName
left outer join BenchmarkRanges br 
	on br.AssessmentName=av.AssessmentName 
	and br.GradeLevelCode=av.GradeLevelCode 
	and br.SchoolYearCode=av.SchoolYearCode 
    and br.TermCode=av.TermCode
left outer  join AssessmentResults  ar on ar.AssessmentVersionId=av.AssessmentVersionId and ar.StudentID=sa.StudentID
where av.SchoolYearId=@SchoolYearId
and av.TermId<=@TermId
and st.StudentId in 
(select distinct st2.StudentID
from Students st2
inner join StudentAssignments sa2 on sa2.StudentId=st2.StudentId
inner join Classrooms c on c.ClassroomId=sa2.ClassroomId
where sa2.SchoolYearId=@SchoolYearId
and c.ClassroomId=@ClassroomId
and sa2.TermCode=(case @TermId when 1 then 'F' when 2 then 'M' when 3 then 'S' end)
)