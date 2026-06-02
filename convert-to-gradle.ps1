param(
    [string]$ProjectName = $(Split-Path -Leaf (Get-Location)),
    [string]$GroupId = "com.shopopedia",
    [string]$Version = "0.0.1-SNAPSHOT",
    [int]$JavaVersion = 21,
    [string]$SpringBootVersion = "4.0.6",
    [string]$DependencyManagementVersion = "1.1.7",
    [string]$GradleVersion = "9.4.1",
    [string]$ServerPort = "8084",
    [string]$ApplicationPackage = "",
    [string]$DatasourceUrl = "jdbc:oracle:thin:@localhost:1521/FREEPDB1",
    [string]$DatasourceUsername = "search_service",
    [string]$DatasourcePassword = "search_service_pass",
    [string]$DatasourceDriverClassName = "oracle.jdbc.OracleDriver",
    [string]$HibernateDdlAuto = "update",
    [string]$HibernateDialect = "org.hibernate.dialect.OracleDialect",
    [string]$ManagementExposure = "health,info",
    [switch]$SkipWrapperGeneration
)

$ErrorActionPreference = "Stop"

function Normalize-PackageName {
    param([string]$Value)

    $normalized = $Value.ToLowerInvariant()
    $normalized = $normalized -replace '[^a-z0-9\.]+', '.'
    $normalized = $normalized -replace '\.+', '.'
    $normalized = $normalized.Trim('.')
    return $normalized
}

function Get-PrimaryProjectSegment {
    param([string]$Value)

    $segments = [regex]::Matches($Value, '[A-Za-z0-9]+') | ForEach-Object {
        $_.Value.ToLowerInvariant()
    }

    if (-not $segments -or $segments.Count -eq 0) {
        return ""
    }

    return $segments[0]
}

function Get-ApplicationPackage {
    param(
        [string]$GroupIdValue,
        [string]$ProjectNameValue,
        [string]$ExplicitPackage
    )

    if ($ExplicitPackage -and $ExplicitPackage.Trim()) {
        return (Normalize-PackageName $ExplicitPackage)
    }

    $group = (Normalize-PackageName $GroupIdValue)
    $project = (Get-PrimaryProjectSegment $ProjectNameValue)
    if ([string]::IsNullOrWhiteSpace($group)) {
        return $project
    }

    if ([string]::IsNullOrWhiteSpace($project)) {
        return $group
    }

    return "$group.$project"
}

$applicationPackageName = Get-ApplicationPackage -GroupIdValue $GroupId -ProjectNameValue $ProjectName -ExplicitPackage $ApplicationPackage
$packagePath = $applicationPackageName -replace '\.', [IO.Path]::DirectorySeparatorChar
$nameParts = [regex]::Matches($ProjectName, '[A-Za-z0-9]+') | ForEach-Object {
    $part = $_.Value
    if ($part.Length -gt 0) {
        $part.Substring(0, 1).ToUpperInvariant() + $part.Substring(1).ToLowerInvariant()
    }
}

if (-not $nameParts -or $nameParts.Count -eq 0) {
    $appClassName = "Application"
} else {
    $appClassName = ($nameParts -join '') + "Application"
}

$buildGradle = @"
plugins {
    id 'java'
    id 'org.springframework.boot' version '$SpringBootVersion'
    id 'io.spring.dependency-management' version '$DependencyManagementVersion'
}

group = '$GroupId'
version = '$Version'
description = '$ProjectName'

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of($JavaVersion)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'

    runtimeOnly 'com.oracle.database.jdbc:ojdbc11'

    compileOnly 'org.projectlombok:lombok'
    annotationProcessor 'org.projectlombok:lombok'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

tasks.named('test') {
    useJUnitPlatform()
}
"@

$settingsGradle = "rootProject.name = '$ProjectName'"

$gitignore = @"
.gradle/
build/
out/
.idea/
*.iml
*.log
.DS_Store
"@

Set-Content -Path (Join-Path $PWD "build.gradle") -Value $buildGradle -Encoding ascii
Set-Content -Path (Join-Path $PWD "settings.gradle") -Value $settingsGradle -Encoding ascii
Set-Content -Path (Join-Path $PWD ".gitignore") -Value $gitignore -Encoding ascii

$mainJavaDir = Join-Path $PWD (Join-Path "src/main/java" $packagePath)
$mainResourcesDir = Join-Path $PWD "src/main/resources"
New-Item -ItemType Directory -Force -Path $mainJavaDir | Out-Null
New-Item -ItemType Directory -Force -Path $mainResourcesDir | Out-Null

$mainClassPath = Join-Path $mainJavaDir "$appClassName.java"
if (-not (Test-Path $mainClassPath)) {
    $mainClassContent = @"
package $applicationPackageName;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class $appClassName {

    public static void main(String[] args) {
        SpringApplication.run($appClassName.class, args);
    }
}
"@
    Set-Content -Path $mainClassPath -Value $mainClassContent -Encoding ascii
}

$applicationYmlPath = Join-Path $mainResourcesDir "application.yml"
if (-not (Test-Path $applicationYmlPath)) {
    $applicationYml = @"
server:
  port: $ServerPort

spring:
  application:
    name: $ProjectName

  datasource:
    url: $DatasourceUrl
    username: $DatasourceUsername
    password: $DatasourcePassword
    driver-class-name: $DatasourceDriverClassName

  jpa:
    hibernate:
      ddl-auto: $HibernateDdlAuto
    show-sql: true
    properties:
      hibernate:
        format_sql: true
        dialect: $HibernateDialect

management:
  endpoints:
    web:
      exposure:
        include: $ManagementExposure
"@
    Set-Content -Path $applicationYmlPath -Value $applicationYml -Encoding ascii
}

if (-not $SkipWrapperGeneration) {
    $gradleCmd = Get-Command gradle -ErrorAction SilentlyContinue
    $wrapperGenerated = $false
    if ($null -ne $gradleCmd) {
        & gradle wrapper --gradle-version $GradleVersion
        if ($LASTEXITCODE -eq 0) {
            $wrapperGenerated = $true
        } else {
            Write-Warning "Gradle wrapper generation failed with exit code $LASTEXITCODE. Writing wrapper properties only."
        }
    }

    if (-not $wrapperGenerated) {
        New-Item -ItemType Directory -Force -Path (Join-Path $PWD "gradle/wrapper") | Out-Null
        $wrapperProps = @"
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-$GradleVersion-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
"@
        Set-Content -Path (Join-Path $PWD "gradle/wrapper/gradle-wrapper.properties") -Value $wrapperProps -Encoding ascii
        if ($null -eq $gradleCmd) {
            Write-Host "Gradle is not installed. Wrapper properties were created, but gradlew and gradle-wrapper.jar still need to be generated."
        } else {
            Write-Host "Gradle wrapper properties were created after wrapper generation failed. gradlew and gradle-wrapper.jar may still need to be generated."
        }
    }
}

Write-Host "Gradle Spring Boot project scaffold created for $ProjectName."
