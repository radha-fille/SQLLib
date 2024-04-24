select av.SchoolYearCode as SchoolYear,av.TermId
	,c.SiteName as School
	,av.GradeLevelCode
,av.TermName as AssessmentWindow
	,c.PrimaryTeacherFirstName+' '+c.PrimaryTeacherLastName as Teacher
	,st.FirstName+' '+st.LastName as Student	
	,st.BelowBenchmarkCount as PALSID
	,st.AssessmentCount,st.CurrentHighRisk
	,(case Identified when 0 then 'No' when 'False' then 'No' when 1 then 'Yes' when 'True'  then 'Yes' end) as PALSIDStatus
	,(case st.AdministrationMethod when 'Standard' then 0 when 'Non-Standard' then 1 when 'Exempt' then 2 end) as AdministrationCondition
	,(case st.AdministrationMethod 
			when '' then ''
			when 'Non-Standard' then (case count(av.AssessmentName) when 0 then 0 else 2 end) 
			when 'Exempt' then '' 
			when 'Standard' then 
			(case count(distinct ar.AssessmentStop) when 12 then 1 else 0 end)
		end) as Completed
	,vw.RiskBand
	,(case vw.RiskBand when 'High Risk' then 1 when 'Moderate Risk' then 2 when 'Low Risk' then 3 else 4 end) as sortableRiskBand
	,UPPER(c.PrimaryTeacherLastName) as sortableTeacherLName
	,UPPER(st.LastName) as sortableStudentLName
	,sum(case av.AssessmentName when 'Letter Sounds' then ar.Score end) as [Letter Sounds]
	,sum(case av.AssessmentName when 'Letter Sounds' then ar.CutOffScore end) as [Letter Sounds Cutoff]	
	,sum(case av.AssessmentName when 'Phoneme Segmenting' then ar.Score end) as [Phoneme Segmenting]
	,sum(case av.AssessmentName when 'Phoneme Segmenting' then ar.CutOffScore end) as [Phoneme Segmenting Cutoff]
	,sum(case av.AssessmentName when 'Encoding' then ar.Score end) as Encoding
	,sum(case av.AssessmentName when 'Encoding' then ar.CutOffScore end) as [Encoding Cutoff]
	,sum(case av.AssessmentName when 'Real Word Decoding' then ar.Score end) as [Real Word Decoding]
	,sum(case av.AssessmentName when 'Real Word Decoding' then ar.CutOffScore end) as [Real Word Decoding Cutoff]
	,sum(case av.AssessmentName when 'Pseudoword Decoding' then ar.Score end) as [Pseudoword Decoding]
	,sum(case av.AssessmentName when 'Pseudoword Decoding' then ar.CutOffScore end) as [Pseudoword Decoding Cutoff]
	,sum(case av.AssessmentName when 'Oral Reading Fluency: Passage 1' then ar.Score end) as [Oral Reading Fluency: Passage 1]	
	,sum(case av.AssessmentName when 'Oral Reading Fluency: Passage 1' then ar.CutOffScore end) as [Oral Reading Fluency: Passage 1 Cutoff]	
	,sum(case av.AssessmentName when 'Oral Reading Fluency: Passage 2' then ar.Score end) as [Oral Reading Fluency: Passage 2]	
	,sum(case av.AssessmentName when 'Oral Reading Fluency: Passage 2' then ar.CutOffScore end) as [Oral Reading Fluency: Passage 2 Cutoff]	
	,sum(case av.AssessmentName when 'Passage Retell' then ar.Score end) as [Passage Retell]
	,sum(case av.AssessmentName when 'Passage Retell' then ar.CutOffScore end) as [Passage Retell Cutoff]
	,sum(case av.AssessmentName when 'Expressive Comprehension Questions' then ar.Score end) as [Expressive Comprehension Questions]
	,sum(case av.AssessmentName when 'Expressive Comprehension Questions' then ar.CutOffScore end) as [Expressive Comprehension Questions Cutoff]
	,sum(case av.AssessmentName when 'Nonsense Sentences' then ar.Score end)  as [Nonsense Sentences]
	,sum(case av.AssessmentName when 'Nonsense Sentences' then ar.CutOffScore end)  as [Nonsense Sentences Cutoff]
	,sum(case av.AssessmentName when 'Relational Vocabulary' then ar.Score end) as [Relational Vocabulary]
	,sum(case av.AssessmentName when 'Relational Vocabulary' then ar.CutOffScore end) as [Relational Vocabulary Cutoff]
	,sum(case av.AssessmentName when 'Vocabulary Fluency' then ar.Score end) as [Vocabulary Fluency]
	,sum(case av.AssessmentName when 'Vocabulary Fluency' then ar.CutOffScore end) as [Vocabulary Fluency Cutoff]
	,sum(case av.AssessmentName when 'Rapid Automatized Naming (RAN): Letters' then ar.Score end) as [Rapid Automatized Naming (RAN): Letters]
	,sum(case av.AssessmentName when 'Rapid Automatized Naming (RAN): Letters' then ar.CutOffScore end) as [Rapid Automatized Naming (RAN): Letters Cutoff]	
	,getDate() AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' as DateTimeStamp 
from Students st
inner join StudentAssignments sa on sa.StudentId=st.StudentId
inner join Classrooms c on c.ClassroomId=sa.ClassroomId
inner join AssessmentVersions  av 
	on av.SchoolYearId=sa.SchoolYearId
		and av.TermId=sa.TermId
		and av.GradeLevelId=sa.GradeLevelId
left outer join vw_RiskBandScore vw on vw.SchoolYearCode=av.SchoolYearCode
		and vw.TermCode=av.TermCode
		and vw.GradeLevelCode=av.GradeLevelCode
		and vw.StudentID=st.StudentID
left outer  join vw_AssessmentResult  ar on ar.AssessmentVersionId=av.AssessmentVersionId and ar.StudentID=sa.StudentID
where  av.GradeLevelCode='1'
and c.SiteID=@SiteId
and av.TermId=@TermId
and av.SchoolYearId=@SchoolYearId
group by c.SiteName,av.TermId,st.StudentId,av.GradeLevelCode,av.SchoolYearCode,c.DivisionID,c.SiteID,st.AdministrationMethod,av.TermName,st.LastName, st.FirstName,
st.AdministrationMethod,c.PrimaryTeacherLastName, c.PrimaryTeacherFirstName,
st.AssessmentCount,st.CurrentHighRisk,st.BelowBenchmarkCount,Identified,vw.RiskBand
order by c.PrimaryTeacherLastName,c.PrimaryTeacherFirstName,st.LastName,st.FirstName