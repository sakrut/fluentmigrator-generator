function Add-Update-FluentMigration
{
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param (
        [parameter(Position = 0,
            Mandatory = $true)]
        [string] $Name,
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
    $namespace = $project.Properties.Item("DefaultNamespace").Value.ToString() + ".Migrations"
    $projectPath = [System.IO.Path]::GetDirectoryName($project.FullName)
    $migrationsPath = [System.IO.Path]::Combine($projectPath, "Migrations")
	$resourcesPath = [System.IO.Path]::Combine($projectPath, "Resources")
	$resourcesUpdatesPath = [System.IO.Path]::Combine($resourcesPath, "Updates")
	
    $outputPath = [System.IO.Path]::Combine($migrationsPath, "$timestamp" + "_$name.cs")
	$sqlUpdateName = "update_$timestamp" + "_$name"
	$outputPathSql = [System.IO.Path]::Combine($resourcesUpdatesPath, "$sqlUpdateName.sql")

    if (-not (Test-Path $migrationsPath))
    {
        [System.IO.Directory]::CreateDirectory($migrationsPath)
    }
	
	if (-not (Test-Path $resourcesUpdatesPath))
    {
        [System.IO.Directory]::CreateDirectory($resourcesUpdatesPath)
    }

    "using FluentMigrator;

namespace $namespace
{
    [Migration($timestamp)]
    public class $name : Migration
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

    "--Migration $timestamp $name" | Out-File -Encoding "UTF8" -Force $outputPathSql

    $project.ProjectItems.AddFromFile($outputPath)
	$sqlFile = $project.ProjectItems.AddFromFile($outputPathSql)
	$sqlFile.Properties.Item("BuildAction").Value = [int]3
    $project.Save()
}

Export-ModuleMember @( 'Add-Update-FluentMigration' )
