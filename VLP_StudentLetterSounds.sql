select av.TermId,av.TermName, sg.QuestionText as Letter
	,(case sg.Value when 1 then '' else 1 end) as Correct
	,(case sg.QuestionText when 'ch' then 'zzzch' when 'sh' then 'zzzsh' when 'th' then 'zzzth' else sg.QuestionText end) as sortableLetter
from Students st
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearId=sa.SchoolYearId
		and av.TermId=sa.TermId
		and av.GradeLevelId=sa.GradeLevelId
inner  join AssessmentResults  ar on ar.AssessmentVersionId=av.AssessmentVersionId and ar.StudentID=sa.StudentID
inner  join SimpleGridResults sg on sg.AssessmentResultId=ar.AssessmentResultId
where st.StudentID=@StudentId
and av.TermId<=@TermId
and st.AdministrationMethod<>'Exempt'
and av.AssessmentName = 'Letter Sounds'
order by sortableLetter,TermName