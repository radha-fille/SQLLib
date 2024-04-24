select av.TermId, av.TermName
	,ag.QuestionText as Letter
	,(case ag.Value when 1 then '' else 1 end) as Correct
	,case CONCAT(ag.[Row], '-', ag.[Column], '-', ag.[QuestionText])
		when '2-5-a' then 'z'+ag.[QuestionText] 
		when '4-8-b' then 'z'+ag.[QuestionText] 
		when '0-2-c' then 'z'+ag.[QuestionText] 
		when '5-0-d' then 'z'+ag.[QuestionText] 
		when '1-0-e' then 'z'+ag.[QuestionText] 
		when '4-6-f' then 'z'+ag.[QuestionText] 
		when '5-2-g' then 'z'+ag.[QuestionText] 
		when '2-4-h' then 'z'+ag.[QuestionText] 
		when '0-1-i' then 'z'+ag.[QuestionText]		
		when '0-6-j' then 'z'+ag.[QuestionText] 
		when '3-8-k' then 'z'+ag.[QuestionText] 
		when '1-7-l' then 'z'+ag.[QuestionText] 		
		when '3-7-m' then 'z'+ag.[QuestionText] 
		when '4-1-n' then 'z'+ag.[QuestionText] 
		when '4-4-o' then 'z'+ag.[QuestionText] 
		when '1-3-p' then 'z'+ag.[QuestionText] 
		when '4-3-q' then 'z'+ag.[QuestionText] 
		when '4-5-r' then 'z'+ag.[QuestionText] 		
		when '3-3-s' then 'z'+ag.[QuestionText] 		
		when '3-2-t' then 'z'+ag.[QuestionText] 		
		when '1-8-u' then 'z'+ag.[QuestionText] 		
		when '2-7-v' then 'z'+ag.[QuestionText] 		
		when '3-4-w' then 'z'+ag.[QuestionText] 		
		when '3-5-x' then 'z'+ag.[QuestionText] 		
		when '0-8-y' then 'z'+ag.[QuestionText] 		
		when '0-5-z' then 'z'+ag.[QuestionText] 		
		else ag.[QuestionText] end as sortableKey
from Students st
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearId=sa.SchoolYearId
		and av.TermId=sa.TermId
		and av.GradeLevelId=sa.GradeLevelId
inner  join AssessmentResults  ar on ar.AssessmentVersionId=av.AssessmentVersionId and ar.StudentID=sa.StudentID
inner  join SimpleGridResults ag on ag.AssessmentResultId=ar.AssessmentResultId
where st.StudentID=@StudentId
and av.TermId<=@TermId
and st.AdministrationMethod<>'Exempt'
and av.AssessmentName = 'Letter Names'
order by ag.QuestionText, sortableKey