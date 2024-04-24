WITH 
CTE_AssessmentCounts
AS 
(
	SELECT AV.[SchoolYearId], AV.[TermId], AV.[GradeLevelId], COUNT(AV.[AssessmentVersionId]) [AssessmentCount]
	FROM [AssessmentVersions] AV
	WHERE [TermName] in ('Fall','Spring')
	GROUP BY AV.[SchoolYearId], AV.[TermId], AV.[GradeLevelId]
),
CTE_RiskBandInclusions
AS 
(
	SELECT AV.[AssessmentVersionId], AV.[SchoolYearId], AV.[SchoolYearCode], AV.[TermId], AV.[TermCode], AV.[GradeLevelId], AV.[GradeLevelCode], CASE AV.[AssessmentName] WHEN 'Encoding' THEN 1 ELSE 0 END AS [ScoreType]
	FROM [AssessmentVersions] AV
	INNER JOIN [RiskBandInclusions] RBI
	  ON AV.[AssessmentName] = RBI.[AssessmentName] 
	  AND AV.[SchoolYearCode] = RBI.[SchoolYearCode]
	  AND AV.[TermCode] = RBI.[TermCode]
	  AND AV.[GradeLevelCode] = RBI.[GradeLevelCode]
	WHERE RBI.[Included] = 1
),
CTE_RiskBandRanges
AS 
(
	SELECT RBI.[SchoolYearId], RBI.[TermId], RBI.[GradeLevelId], RBR.[HighRange], RBR.[LowRange], RBR.[RiskBand]
	FROM CTE_RiskBandInclusions RBI
	INNER JOIN [RiskBandRanges] RBR
	  ON RBI.[SchoolYearCode] = RBR.[SchoolYearCode]
	  AND RBI.[TermCode] = RBR.[TermCode]
	  AND RBI.[GradeLevelCode] = RBR.[GradeLevelCode]
	GROUP BY RBI.[SchoolYearId], RBI.[TermId], RBI.[GradeLevelId], RBR.[HighRange], RBR.[LowRange], RBR.[RiskBand]
),
CTE_AssessmentResults
AS
(
	SELECT S.[StudentId],
				SA.[SchoolYearId], SA.[TermId],  SA.[GradeLevelId], 
				C.[DivisionId], C.[SiteId], C.[ClassroomId], C.[PrimaryTeacherUserId],
				AR.[AssessmentResultId], AR.[AssessmentVersionId], AR.[Score], 0 [ScoreType]
	FROM [Students] S
	INNER JOIN [StudentAssignments] SA
	  ON S.[StudentId] = SA.[StudentId]
	INNER JOIN [AssessmentVersions] AV
	  ON SA.[GradeLevelId] = AV.[GradeLevelId]
AND SA.[TermId]=AV.[TermId]
	INNER JOIN [Classrooms] C
	  ON SA.[ClassroomId] = C.[ClassroomId]
	INNER JOIN [AssessmentResults] AR
	  ON SA.[StudentId] = AR.[StudentId]
	  AND AV.[AssessmentVersionId] = AR.[AssessmentVersionId]
                WHERE S.[AdministrationMethod] = 'Standard'
),
CTE_Students
AS
(
	SELECT [StudentId], [PrimaryTeacherUserId], [SchoolYearId], [TermId], 
				[GradeLevelId], [DivisionId], [SiteId], [ClassroomId], COUNT([AssessmentResultId]) [CompletedCount]
	FROM CTE_AssessmentResults
	GROUP BY [StudentId], [PrimaryTeacherUserId],
					  [SchoolYearId], [TermId], [GradeLevelId], [DivisionId], [SiteId], [ClassroomId]
),
CTE_CompletedStudents
AS
(
	SELECT S.[StudentId], S.[PrimaryTeacherUserId], S.[SchoolYearId], S.[TermId], S.[GradeLevelId], S.[DivisionId], S.[SiteId], S.[ClassroomId]
	FROM CTE_AssessmentCounts AC
	INNER JOIN CTE_Students S
	  ON S.[CompletedCount] = AC.[AssessmentCount]
	  AND S.[SchoolYearId] = AC.[SchoolYearId]
	  AND S.[TermId] = AC.[TermId]
	  AND S.[GradeLevelId] = AC.[GradeLevelId]
),
CTE_RiskBandAssessmentResults
AS
(
	SELECT AR.[StudentId], AR.[DivisionId], AR.[SiteId], AR.[SchoolYearId], AR.[TermId], AR.[GradeLevelId], AR.[Score], AR.[AssessmentVersionId], AR.[AssessmentResultId], RBI.[ScoreType]
	FROM CTE_AssessmentResults AR
	INNER JOIN CTE_RiskBandInclusions RBI
	  ON AR.[AssessmentVersionId] = RBI.[AssessmentVersionId]
	  AND AR.[SchoolYearId] = RBI.[SchoolYearId]
	  AND AR.[TermId] = RBI.[TermId]
	  AND AR.[GradeLevelId] = RBI.[GradeLevelId]
),
CTE_RiskBandScores
AS 
(
	SELECT RBAR.[StudentId], RBAR.[DivisionId], RBAR.[SiteId], RBAR.[SchoolYearId], 
		RBAR.[TermId], RBAR.[GradeLevelId], RBAR.[Score]
	FROM CTE_RiskBandAssessmentResults RBAR
	WHERE RBAR.[ScoreType] = 0
	
	UNION ALL 
	
	SELECT RBAR.[StudentId], RBAR.[DivisionId], RBAR.[SiteId], RBAR.[SchoolYearId], 
		RBAR.[TermId], RBAR.[GradeLevelId], CAST(ARM.[Value] AS INT) [Score]
	FROM CTE_RiskBandAssessmentResults RBAR
	INNER JOIN [AssessmentResultMetadata] ARM
	  ON RBAR.[AssessmentResultId] = ARM.[AssessmentResultId]
	WHERE RBAR.[ScoreType] = 1
	  AND ARM.[Key] = 'reportingScore'
),
CTE_RiskBandScoreSummary
AS 
(
	SELECT RBS.[StudentId], CS.[PrimaryTeacherUserId], CS.[ClassroomId],
	RBS.[DivisionId], RBS.[SiteId], RBS.[SchoolYearId], RBS.[TermId], RBS.[GradeLevelId], SUM(RBS.[Score]) [RiskBandScore]
	FROM CTE_RiskBandScores RBS
	INNER JOIN CTE_CompletedStudents CS
	  ON RBS.[StudentId] = CS.[StudentId]
	  AND RBS.[DivisionId] = CS.[DivisionId]
	  AND RBS.[SiteId] = CS.[SiteId]
	  AND RBS.[SchoolYearId] = CS.[SchoolYearId]
	  AND RBS.[TermId] = CS.[TermId]
	  AND RBS.[GradeLevelId] = CS.[GradeLevelId]
	GROUP BY RBS.[StudentId], CS.[PrimaryTeacherUserId], RBS.[DivisionId], RBS.[SiteId], RBS.[SchoolYearId], 
		RBS.[TermId], RBS.[GradeLevelId], CS.[ClassroomId]
)

SELECT RBSS.[StudentId], RBSS.[PrimaryTeacherUserId], RBSS.[DivisionId], RBSS.[SiteId], RBSS.[SchoolYearId],RBSS.[TermId], RBSS.[GradeLevelId], RBSS.[ClassroomId], RBR.[RiskBand]
FROM CTE_RiskBandScoreSummary RBSS
INNER JOIN CTE_RiskBandRanges RBR
	ON RBSS.[SchoolYearId] = RBR.[SchoolYearId]
	AND RBSS.[TermId] = RBR.[TermId]
	AND RBSS.[GradeLevelId] = RBR.[GradeLevelId]
	AND RBSS.[RiskBandScore] BETWEEN RBR.[LowRange] AND RBR.[HighRange]
WHERE RBR.[RiskBand]='High Risk'
AND RBSS.[SiteId]=@SiteId