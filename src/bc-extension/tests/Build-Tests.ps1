param(
    [string]$CompilerPath = (Join-Path $env:USERPROFILE '.vscode/extensions/ms-dynamics-smb.al-18.1.2842859/bin/alc.exe')
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$testBuildRoot = Join-Path ([IO.Path]::GetTempPath()) ('PensionFlowTests-' + [guid]::NewGuid().ToString('N'))
$testProject = Join-Path $testBuildRoot 'project'
$symbolCache = Join-Path $testBuildRoot 'symbols'
New-Item -ItemType Directory -Path $testProject, $symbolCache | Out-Null
Copy-Item -Path (Join-Path $projectRoot '.alpackages/*.app') -Destination $symbolCache
$extensionPackage = Join-Path $symbolCache 'PensionFlow.app'
& $CompilerPath "/project:$projectRoot" "/packagecachepath:$symbolCache" "/out:$extensionPackage"
if ($LASTEXITCODE -ne 0) { throw 'Extension compilation failed.' }
$mainManifest = Get-Content (Join-Path $projectRoot 'app.json') -Raw | ConvertFrom-Json
$testManifest = @{
    id = 'dc8489de-b79e-434e-abde-08415aa5a4b7'
    name = 'PensionFlow Tests'
    publisher = 'PensionFlow Labs'
    version = '1.0.0.0'
    platform = $mainManifest.platform
    application = $mainManifest.application
    runtime = $mainManifest.runtime
    idRanges = @(@{ from = 50200; to = 50249 })
    dependencies = @(@{
        id = $mainManifest.id
        name = $mainManifest.name
        publisher = $mainManifest.publisher
        version = $mainManifest.version
    })
}
$testManifest | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $testProject 'app.json')
Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.altest' | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $testProject ($_.BaseName + '.Codeunit.al'))
}
$testPackage = Join-Path $testBuildRoot 'PensionFlow.Tests.app'
& $CompilerPath "/project:$testProject" "/packagecachepath:$symbolCache" "/out:$testPackage"
if ($LASTEXITCODE -ne 0) { throw 'Test compilation failed.' }
Write-Output "Extension package: $extensionPackage"
Write-Output "Test package: $testPackage"
