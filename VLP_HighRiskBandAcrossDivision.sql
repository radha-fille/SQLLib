WITH CTE_AssessmentResults
AS
(
	SELECT SA.[StudentId], SA.[SchoolYearId], SA.[TermId], SA.[GradeLevelId], C.[DivisionId], C.[SiteId], C.[ClassroomId], AR.[AssessmentResultId], AR.[AssessmentVersionId], AR.[Score], 0 [ScoreType]
	FROM [Students] S
	INNER JOIN [StudentAssignments] SA
	  ON S.[StudentId] = SA.[StudentId]
	INNER JOIN [AssessmentVersions] AV
	  ON SA.[GradeLevelId] = AV.[GradeLevelId]
AND SA.[TermId] = AV.[TermId]
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
	SELECT [StudentId], [SchoolYearId], [TermId], [GradeLevelId], [DivisionId], [SiteId], [ClassroomId], COUNT([AssessmentResultId]) [CompletedCount]
	FROM CTE_AssessmentResults AR
	GROUP BY [StudentId], [SchoolYearId], [TermId], [GradeLevelId], [DivisionId], [SiteId], [ClassroomId]
),
CTE_AssessmentCounts 
AS 
(
	SELECT AV.[SchoolYearId], AV.[TermId], AV.[GradeLevelId], COUNT(AV.[AssessmentVersionId]) [AssessmentCount]
	FROM [AssessmentVersions] AV
	GROUP BY AV.[SchoolYearId], AV.[TermId], AV.[GradeLevelId]
),
CTE_CompletedStudents
AS
(
	SELECT S.[StudentId], S.[SchoolYearId], S.[TermId], S.[GradeLevelId], S.[DivisionId], S.[SiteId]
	FROM CTE_AssessmentCounts AC
	INNER JOIN CTE_Students S
	  ON S.[CompletedCount] = AC.[AssessmentCount]
	  AND S.[SchoolYearId] = AC.[SchoolYearId]
	  AND S.[TermId] = AC.[TermId]
	  AND S.[GradeLevelId] = AC.[GradeLevelId]
),
CTE_CompletedSummary
AS
(
	SELECT COUNT(S.[StudentId]) [Count], S.[SchoolYearId], S.[TermId], S.[GradeLevelId], S.[DivisionId], S.[SiteId]
	FROM CTE_CompletedStudents S
	GROUP BY S.[SchoolYearId], S.[TermId], S.[GradeLevelId], [DivisionId], [SiteId]
),
CTE_CompletedSummary_Division -- 5. get number of students who completed assessment per grade and division
AS
(
	SELECT COUNT(S.[StudentId]) [Count], S.[SchoolYearId], S.[TermId], S.[GradeLevelId], S.[DivisionId]
	FROM CTE_CompletedStudents S
	GROUP BY S.[SchoolYearId], S.[TermId], S.[GradeLevelId], [DivisionId]
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
	SELECT RBAR.[StudentId], RBAR.[DivisionId], RBAR.[SiteId], RBAR.[SchoolYearId], RBAR.[TermId], RBAR.[GradeLevelId], RBAR.[Score]
	FROM CTE_RiskBandAssessmentResults RBAR
	WHERE RBAR.[ScoreType] = 0
	
	UNION ALL 
	
	SELECT RBAR.[StudentId], RBAR.[DivisionId], RBAR.[SiteId], RBAR.[SchoolYearId], RBAR.[TermId], RBAR.[GradeLevelId], CAST(ARM.[Value] AS INT) [Score]
	FROM CTE_RiskBandAssessmentResults RBAR
	INNER JOIN [AssessmentResultMetadata] ARM
	  ON RBAR.[AssessmentResultId] = ARM.[AssessmentResultId]
	WHERE RBAR.[ScoreType] = 1
	  AND ARM.[Key] = 'reportingScore'
),
CTE_RiskBandScoreSummary
AS 
(
	SELECT RBS.[StudentId], RBS.[DivisionId], RBS.[SiteId], RBS.[SchoolYearId], RBS.[TermId], RBS.[GradeLevelId], SUM(RBS.[Score]) [RiskBandScore]
	FROM CTE_RiskBandScores RBS
	INNER JOIN CTE_CompletedStudents CS
	  ON RBS.[StudentId] = CS.[StudentId]
	  AND RBS.[DivisionId] = CS.[DivisionId]
	  AND RBS.[SiteId] = CS.[SiteId]
	  AND RBS.[SchoolYearId] = CS.[SchoolYearId]
	  AND RBS.[TermId] = CS.[TermId]
	  AND RBS.[GradeLevelId] = CS.[GradeLevelId]
	GROUP BY RBS.[StudentId], RBS.[DivisionId], RBS.[SiteId], RBS.[SchoolYearId], RBS.[TermId], RBS.[GradeLevelId]
),
CTE_RiskBands
AS
(
	SELECT [DivisionId], [SiteId], [SchoolYearId], [TermId], [GradeLevelId], [High Risk]
	FROM 
	(
		SELECT RBSS.[StudentId], RBSS.[DivisionId], RBSS.[SiteId], RBSS.[SchoolYearId], RBSS.[TermId], RBSS.[GradeLevelId], RBR.[RiskBand]
		FROM CTE_RiskBandScoreSummary RBSS
		INNER JOIN CTE_RiskBandRanges RBR
		  ON RBSS.[SchoolYearId] = RBR.[SchoolYearId]
		  AND RBSS.[TermId] = RBR.[TermId]
		  AND RBSS.[GradeLevelId] = RBR.[GradeLevelId]
		  AND RBSS.[RiskBandScore] BETWEEN RBR.[LowRange] AND RBR.[HighRange]
	) AS S
	PIVOT
	(
		COUNT([StudentId])
		FOR [RiskBand] IN ([High Risk])
	) AS P
),
CTE_RiskBands_Division
AS
(
	SELECT [DivisionId], [SchoolYearId], [TermId], [GradeLevelId], [High Risk]
	FROM 
	(
		SELECT RBSS.[StudentId], RBSS.[DivisionId], RBSS.[SchoolYearId], RBSS.[TermId], RBSS.[GradeLevelId], RBR.[RiskBand]
		FROM CTE_RiskBandScoreSummary RBSS
		INNER JOIN CTE_RiskBandRanges RBR
		  ON RBSS.[SchoolYearId] = RBR.[SchoolYearId]
		  AND RBSS.[TermId] = RBR.[TermId]
		  AND RBSS.[GradeLevelId] = RBR.[GradeLevelId]
		  AND RBSS.[RiskBandScore] BETWEEN RBR.[LowRange] AND RBR.[HighRange]
	) AS S
	PIVOT
	(
		COUNT([StudentId])
		FOR [RiskBand] IN ([High Risk])
	) AS P
),
CTE_Report
AS
(
	SELECT CS.[DivisionId], CS.[SiteId], CS.[SchoolYearId], CS.[TermId], CS.[GradeLevelId], CS.[Count], RB.[High Risk]
	FROM CTE_CompletedSummary CS
	INNER JOIN CTE_RiskBands RB
	  ON CS.[DivisionId] = RB.[DivisionId]
	  AND CS.[SiteId] = RB.[SiteId]
	  AND CS.[SchoolYearId] = RB.[SchoolYearId]
	  AND CS.[TermId] = RB.[TermId]
	  AND CS.[GradeLevelId] = RB.[GradeLevelId]
),
CTE_Report_Division
AS
(
	SELECT CS.[DivisionId], CS.[SchoolYearId], CS.[TermId], CS.[GradeLevelId], CS.[Count], RB.[High Risk]
	FROM CTE_CompletedSummary_Division CS
	INNER JOIN CTE_RiskBands_Division RB
	  ON CS.[DivisionId] = RB.[DivisionId]
	  AND CS.[SchoolYearId] = RB.[SchoolYearId]
	  AND CS.[TermId] = RB.[TermId]
	  AND CS.[GradeLevelId] = RB.[GradeLevelId]
),
CTE_LocationLookups
AS
(
	SELECT DISTINCT [DivisionId], [DivisionName], [SiteId], [SiteName]
	FROM [Classrooms]
)
SELECT	LL.[SiteName] [sortableEntity],
		LL.[SiteName] [Entity],
		R.[TermId],
		R.[SchoolYearId],
		R.[GradeLevelId],
		R.[Count] AS [Assessed],
		R.[High Risk] AS [EIRI_Total],		
		getDate() AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' as DateTimeStamp
FROM CTE_Report R
INNER JOIN CTE_LocationLookups LL
  ON R.[DivisionId] = LL.[DivisionId]
  AND R.[SiteId] = LL.[SiteId]
WHERE R.[DivisionId] = @DivisionId
AND R.[SchoolYearId] = @SchoolYearID
UNION 
SELECT	'ZZ'+LL.[DivisionName] [sortableEntity],
		LL.[DivisionName] [Entity],
		R.[TermId],
		R.[SchoolYearId],
		R.[GradeLevelId],
		R.[Count] AS [Assessed],
		R.[High Risk] AS [EIRI_Total],		
		getDate() AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' as DateTimeStamp
FROM CTE_Report_Division R
INNER JOIN CTE_LocationLookups LL
  ON R.[DivisionId] = LL.[DivisionId]  
WHERE R.[DivisionId] = @DivisionId
AND R.[SchoolYearId] = @SchoolYearID