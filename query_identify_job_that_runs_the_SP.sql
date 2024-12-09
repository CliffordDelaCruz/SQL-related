USE msdb;
GO

-- Replace 'YourStoredProcedureName' with the name of your stored procedure
DECLARE @StoredProcedureName NVARCHAR(128) = 'yourstoredprocedurehere'; --input your stored procedure here!

-- Query to find jobs that execute the stored procedure
SELECT 
    j.name AS JobName,
    j.enabled AS JobEnabled,
    CASE 
        WHEN j.enabled = 1 THEN 'Enabled'
        ELSE 'Disabled'
    END AS JobStatus,
    s.step_id,
    s.step_name,
    s.command
FROM 
    sysjobs j
JOIN 
    sysjobsteps s ON j.job_id = s.job_id
WHERE 
    s.command LIKE '%' + @StoredProcedureName + '%';
