$libDir = "d:\Uniclub\Application\jibble\lib"
$files = Get-ChildItem -Path $libDir -Recurse -Filter *.dart

# 1. Build a map of filename -> full package path
$fileMap = @{}
foreach ($file in $files) {
    # e.g., features\auth\presentation\screens\login_page.dart
    $relativePath = $file.FullName.Substring($libDir.Length + 1).Replace('\', '/')
    $packagePath = "package:jibble/$relativePath"
    $fileMap[$file.Name] = $packagePath
}

# 2. Iterate through all dart files and fix imports
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $modified = $false

    # Search for all import statements
    # Match: import 'something'; or import "something";
    $matches = [regex]::Matches($content, 'import\s+[''"]([^''"]+)[''"];')
    
    foreach ($m in $matches) {
        $importPath = $m.Groups[1].Value
        
        # If it's a relative import (doesn't start with package: or dart:)
        if (-not $importPath.StartsWith("package:") -and -not $importPath.StartsWith("dart:")) {
            # Extract just the filename
            $fileName = Split-Path $importPath -Leaf
            
            # Check if we know about this file
            if ($fileMap.ContainsKey($fileName)) {
                $newImport = "import '" + $fileMap[$fileName] + "';"
                $oldLine = $m.Value
                
                # Replace exactly this import line (using string replace to avoid regex collision on the content)
                $content = $content.Replace($oldLine, $newImport)
                $modified = $true
            }
        }
    }

    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "Fixed relative imports in $($file.Name)"
    }
}
