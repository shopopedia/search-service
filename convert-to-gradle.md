# Convert a Blank Spring Boot Project to Gradle

This guide describes how to turn a blank checkout into a Gradle-based Spring Boot project.

## What This Creates

- `build.gradle`
- `settings.gradle`
- `.gitignore`
- `src/main/java/.../*Application.java`
- `src/main/resources/application.yml`
- Gradle wrapper files when `gradle` is available

## Script

Use [convert-to-gradle.ps1](./convert-to-gradle.ps1) from the project root.

## Prerequisites

- PowerShell
- JDK installed
- Optional: local `gradle` command for generating the wrapper automatically

## Example Usage

```powershell
.\convert-to-gradle.ps1 -ProjectName user-service -GroupId com.shopopedia -ApplicationPackage com.shopopedia.user -JavaVersion 21 -SpringBootVersion 4.0.6
```

## What The Script Does

1. Detects the current project directory.
2. Writes `settings.gradle` with the project name.
3. Writes `build.gradle` with standard Spring Boot dependencies.
4. Writes `.gitignore` for Gradle output and IDE files.
5. Creates the Spring Boot main class under `src/main/java`.
6. Creates `src/main/resources/application.yml` with the configured server port.
7. Generates the Gradle wrapper when `gradle` is available.

## After Running

Run these commands to verify the build:

```bash
./gradlew tasks
./gradlew build
```

## Notes

- If the wrapper is not generated automatically, install Gradle locally and run `gradle wrapper`.
- You can reuse the script in other Spring Boot repositories by changing `-ProjectName`, `-GroupId`, and `-ApplicationPackage`.
