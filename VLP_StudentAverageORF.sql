select sa.TermCode, st.FirstName + ' ' + st.LastName as Student, (concat(av.TermName,' ',(case sa.TermCode when 'F' then sa.SchoolYearCode else sa.SchoolYearCode+1 end))) as AssessmentWindow, sum(ar.Score)/2 as ORF
  from Students st
  inner join StudentAssignments sa on st.StudentId=sa.StudentId
  inner join AssessmentResults ar on sa.StudentId=ar.StudentId
  inner join AssessmentGroupVersions agv 
	on agv.SchoolYearCode=sa.SchoolYearCode
	and agv.TermCode=sa.TermCode
  inner join AssessmentGroupVersionResults agvr  
	on agvr.StudentId=sa.StudentId
	and agvr.AssessmentGroupVersionId=agv.AssessmentGroupVersionId
inner join AssessmentVersions av 
	on av.AssessmentVersionId=ar.AssessmentVersionId
	and av.TermId=sa.TermId
	and av.SchoolYearId=sa.SchoolYearId
	and av.GradeLevelId=sa.GradeLevelId
where av.AssessmentName in ('Oral Reading Fluency: Passage 1','Oral Reading Fluency: Passage 2')
and  sa.StudentId=@StudentId
and av.TermId<=@TermId
and av.SchoolYearId<=@SchoolYearId
and agvr.AdministrationMethod='Standard'
group by st.FirstName, st.LastName, av.TermName, sa.TermCode, sa.SchoolYearCode