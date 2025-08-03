# Crear secretos en LocalStack basados en archivos JSON
$secretsPath = "$PSScriptRoot/secrets"
$endpoint = "http://localhost:4566"

# Verificar que la carpeta secrets existe
if (-not (Test-Path $secretsPath)) {
    Write-Host "❌ La carpeta secrets no existe: $secretsPath" -ForegroundColor Red
    exit 1
}

# Verificar conexión a LocalStack usando IPv4 específicamente
Write-Host "🔍 Verificando conexión a LocalStack..." -ForegroundColor Cyan
try {
    $testConnection = Test-NetConnection -ComputerName "127.0.0.1" -Port 4566 -InformationLevel Quiet
    if ($testConnection) {
        Write-Host "✅ LocalStack está ejecutándose en puerto 4566" -ForegroundColor Green
    } else {
        Write-Host "❌ No se puede conectar al puerto 4566" -ForegroundColor Red
        Write-Host "⚠️  Ejecuta: docker-compose up -d localstack" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Error al verificar conexión: $_" -ForegroundColor Red
    exit 1
}

# Obtener todos los archivos JSON en la carpeta secrets
$jsonFiles = Get-ChildItem -Path $secretsPath -Filter "*.json"

if ($jsonFiles.Count -eq 0) {
    Write-Host "⚠️  No se encontraron archivos JSON en: $secretsPath" -ForegroundColor Yellow
    exit 0
}

Write-Host "🚀 Creando secretos en LocalStack..." -ForegroundColor Cyan
Write-Host "📁 Carpeta: $secretsPath" -ForegroundColor Gray
Write-Host "🌐 Endpoint: $endpoint" -ForegroundColor Gray
Write-Host ""

$successCount = 0
$errorCount = 0
$skippedCount = 0

foreach ($file in $jsonFiles) {
    $secretName = $file.BaseName  # Nombre del archivo sin extensión
    $filePath = $file.FullName
    
    Write-Host "📄 Procesando: $($file.Name)" -ForegroundColor White
    
    # Validar que el nombre del archivo no contenga espacios
    if ($secretName -match '\s') {
        Write-Host "   ❌ Error: El nombre del archivo no puede contener espacios en blanco" -ForegroundColor Red
        Write-Host "   💡 Renombra '$($file.Name)' a '$(($file.Name) -replace '\s', '-')'" -ForegroundColor Yellow
        $skippedCount++
        Write-Host ""
        continue
    }
    
    try {
        # Capturar tanto stdout como stderr
        $result = aws --endpoint-url $endpoint secretsmanager create-secret `
            --name $secretName `
            --description "Secret from $($file.Name)" `
            --secret-string file://$filePath 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Secreto '$secretName' creado exitosamente" -ForegroundColor Green
            $successCount++
        } else {
            # Mostrar el error específico
            $errorMessage = $result | Out-String
            if ($errorMessage -match "already exists") {
                Write-Host "   ⚠️  El secreto '$secretName' ya existe" -ForegroundColor Yellow
                Write-Host "   💡 Para actualizarlo usa: aws --endpoint-url $endpoint secretsmanager update-secret --secret-id $secretName --secret-string file://$filePath" -ForegroundColor Gray
            } elseif ($errorMessage -match "InvalidParameterException") {
                Write-Host "   ❌ Error: Parámetros inválidos en '$secretName'" -ForegroundColor Red
                Write-Host "   📋 Detalle: $($errorMessage.Trim())" -ForegroundColor Gray
            } else {
                Write-Host "   ❌ Error al crear secreto '$secretName'" -ForegroundColor Red
                Write-Host "   📋 Detalle: $($errorMessage.Trim())" -ForegroundColor Gray
            }
            $errorCount++
        }
    }
    catch {
        Write-Host "   ❌ Excepción al crear secreto '$secretName': $_" -ForegroundColor Red
        $errorCount++
    }
    
    Write-Host ""
}

# Mostrar resumen final
Write-Host "📊 Resumen de procesamiento:" -ForegroundColor Cyan
if ($errorCount -eq 0 -and $skippedCount -eq 0) {
    Write-Host "🎉 Proceso completado exitosamente!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Proceso completado con advertencias/errores" -ForegroundColor Yellow
}

Write-Host "✅ $successCount secreto(s) creado(s)" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "❌ $errorCount error(es)" -ForegroundColor Red
}
if ($skippedCount -gt 0) {
    Write-Host "⏭️  $skippedCount archivo(s) omitido(s) por nombres inválidos" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Para verificar los secretos creados:" -ForegroundColor Cyan
Write-Host "aws --endpoint-url $endpoint secretsmanager list-secrets" -ForegroundColor Gray