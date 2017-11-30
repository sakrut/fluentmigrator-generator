function psAddMig
{
    [CmdletBinding(DefaultParameterSetName = 'Version')]
    param (
        [parameter(Position = 0,
            Mandatory = $true)]
        [string] $Version,
        [string] $ProjectName)
    $timestamp = (Get-Date -Format yyyyMMddHHmmss)

    if ($ProjectName) {
        $project = Get-Project $ProjectName
        if ($project -is [array])
        {
            throw "More than one project '$ProjectName' was found. Please specify the full name of the one to use."
        }
    }
    else {
        $project = Get-Project
    }
	$rootNamespace = $project.Properties.Item("DefaultNamespace").Value.ToString()
    $namespace = $rootNamespace + ".MigrationClasses"
    $projectPath = [System.IO.Path]::GetDirectoryName($project.FullName)
    $migrationsPath = [System.IO.Path]::Combine($projectPath, "MigrationClasses")
	$migrationScriptsPath = [System.IO.Path]::Combine($projectPath, "MigrationScripts")

    $outputPath = [System.IO.Path]::Combine($migrationsPath, "mig$Version.cs")
	$sqlUpdateName = "mig$Version"
	$outputPathSql = [System.IO.Path]::Combine($migrationScriptsPath, "$sqlUpdateName.sql")

    if (-not (Test-Path $migrationsPath))
    {
        [System.IO.Directory]::CreateDirectory($migrationsPath)
    }
	
	if (-not (Test-Path $migrationScriptsPath))
    {
        [System.IO.Directory]::CreateDirectory($migrationScriptsPath)
    }

    "using FluentMigrator;
using $rootNamespace.Properties;

namespace $namespace
{
    [Migration($Version)]
    public class mig$Version : Migration
    {
        public override void Up()
        {
			Execute.Sql(Resources.$sqlUpdateName);
        }

        public override void Down()
        {
        }
    }
}" | Out-File -Encoding "UTF8" -Force $outputPath

    "--Migration $Version" | Out-File -Encoding "UTF8" -Force $outputPathSql

    $project.ProjectItems.AddFromFile($outputPath)
	$sqlFile = $project.ProjectItems.AddFromFile($outputPathSql)
	$sqlFile.Properties.Item("BuildAction").Value = [int]3
    $project.Save()

	$DTE.ExecuteCommand("File.OpenFile", $outputPathSql)
}

Export-ModuleMember @( 'psAddMig' )
