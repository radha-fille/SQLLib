--letter sounds

select st.FirstName+' '+st.LastName as Student,ar.Score	
from Students st
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearId=sa.SchoolYearId
		and av.TermId=sa.TermId
		and av.GradeLevelId=sa.GradeLevelId
inner join vw_AssessmentResult  ar on ar.AssessmentVersionId=av.AssessmentVersionId and ar.StudentID=sa.StudentID
where  st.AdministrationMethod='Standard'
and av.AssessmentName='Letter Sounds'
and ar.Score <=ar.CutOffScore
and c.SiteId=@SiteId
and av.TermId=@TermId
and av.SchoolYearId=@SchoolYearId
and sa.GradeLevelCode=@GradeID
order by ar.Score,st.LastName,st.FirstName

--phoneme segmenting

select st.FirstName+' '+st.LastName as Student,ar.Score	
from Students st
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearId=sa.SchoolYearId
		and av.TermId=sa.TermId
		and av.GradeLevelId=sa.GradeLevelId
inner join vw_AssessmentResult  ar on ar.AssessmentVersionId=av.AssessmentVersionId and ar.StudentID=sa.StudentID
where  st.AdministrationMethod='Standard'
and av.AssessmentName='Phoneme Segmenting'
and ar.Score <=ar.CutOffScore
and c.SiteId=@SiteId
and av.TermId=@TermId
and av.SchoolYearId=@SchoolYearId
and sa.GradeLevelCode=@GradeID
order by ar.Score,st.LastName,st.FirstName

--encoding

select st.FirstName+' '+st.LastName as Student,ar.Score	
from Students st
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearId=sa.SchoolYearId
		and av.TermId=sa.TermId
		and av.GradeLevelId=sa.GradeLevelId
inner join vw_AssessmentResult  ar on ar.AssessmentVersionId=av.AssessmentVersionId and ar.StudentID=sa.StudentID
where  st.AdministrationMethod='Standard'
and av.AssessmentName='Encoding'
and ar.Score <=ar.CutOffScore
and c.SiteId=@SiteId
and av.TermId=@TermId
and av.SchoolYearId=@SchoolYearId
and sa.GradeLevelCode=@GradeID
order by ar.Score,st.LastName,st.FirstName

--real world encoding

select st.FirstName+' '+st.LastName as Student,ar.Score	
from Students st
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearId=sa.SchoolYearId
		and av.TermId=sa.TermId
		and av.GradeLevelId=sa.GradeLevelId
inner join vw_AssessmentResult  ar on ar.AssessmentVersionId=av.AssessmentVersionId and ar.StudentID=sa.StudentID
where  st.AdministrationMethod='Standard'
and av.AssessmentName='Real Word Decoding'
and ar.Score <=ar.CutOffScore
and c.SiteId=@SiteId
and av.TermId=@TermId
and av.SchoolYearId=@SchoolYearId
and sa.GradeLevelCode=@GradeID
order by ar.Score,st.LastName,st.FirstName

--pseudo word encoding

select st.FirstName+' '+st.LastName as Student,ar.Score	
from Students st
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearId=sa.SchoolYearId
		and av.TermId=sa.TermId
		and av.GradeLevelId=sa.GradeLevelId
inner join vw_AssessmentResult  ar on ar.AssessmentVersionId=av.AssessmentVersionId and ar.StudentID=sa.StudentID
where  st.AdministrationMethod='Standard'
and av.AssessmentName='Pseudoword Decoding'
and ar.Score <=ar.CutOffScore
and c.SiteId=@SiteId
and av.TermId=@TermId
and av.SchoolYearId=@SchoolYearId
and sa.GradeLevelCode=@GradeID
order by ar.Score,st.LastName,st.FirstName

--ORF

select st.StudentID, st.FirstName+' '+st.LastName as Student, sum(ar.Score)/2 as Score
from Students st
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearId=sa.SchoolYearId
		and av.TermId=sa.TermId
		and av.GradeLevelId=sa.GradeLevelId
inner join vw_AssessmentResult  ar on ar.AssessmentVersionId=av.AssessmentVersionId and ar.StudentID=sa.StudentID
where  st.AdministrationMethod='Standard'
and av.AssessmentName like 'Oral Reading Fluency%'
and c.SiteId=@SiteId
and av.TermId=@TermId
and av.SchoolYearId=@SchoolYearId
and sa.GradeLevelCode=@GradeID
group by st.StudentID, st.FirstName, st.LastName
having sum(ar.Score) <=sum(ar.CutOffScore)
order by sum(ar.Score),st.LastName,st.FirstName