# windows/build.ps1

$origDir = Get-Location
$buildDir = "build"

# Clean previous build
if (Test-Path $buildDir) {
    Remove-Item $buildDir -Recurse -Force
}

# Recreate build directory
New-Item -ItemType Directory -Path $buildDir | Out-Null

# Configure and build
Push-Location $buildDir
cmake ../api/src/striped_generator -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release
Pop-Location
