# FluentMigrator.Generator

[FluentMigrator](https://github.com/schambers/fluentmigrator) is a SQL migration framework designed to help version an application's database. This package allows a developer to quickly create a new migration from within Visual Studio's Package Manager console. 

A few notable features:

- Timestamp generation
- Migration file named correctly with timestamp
- Migration added to `Migrations` folder under current active project

It couldn't be easier!

## Getting Started

```console
PM > Install-Package FluentMigrator.Generator.Sakrut -Version 0.0.1
```

Once installed, open the `Package Manager Console` in Visual Studio. To get there, go to `View > Other Windows > Package Manager Console`. **Remember to select the active project via the `Default Project` dropdown.**

In the new window, type `psAddMig` followed by the Version of your migration.

```console
psAddMig 15
```

You should see the following structure in the `Default Project` project.

```
ConsoleApplication1
|- /MigrationClasses
    |- mig15.cs
|- /MigrationScripts
    |- mig15.sql
```

The migration file contents should look like the following.

```csharp
using FluentMigrator;

namespace ConsoleApplication1.Migrations
{
    [Migration(15)]
    public class mig15 : Migration
    {
        public override void Up()
        {
			Execute.Sql(Resources.mig15);
        }
        public override void Down()
        {
        }
    }
}
```

Fill in the migration appropriately.
