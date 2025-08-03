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

foreach ($file in $jsonFiles) {
    $secretName = $file.BaseName  # Nombre del archivo sin extensión
    $filePath = $file.FullName
    
    Write-Host "📄 Procesando: $($file.Name)" -ForegroundColor White
    
    try {
        # Crear el secreto
        aws --endpoint-url $endpoint secretsmanager create-secret `
            --name $secretName `
            --description "Secret from $($file.Name)" `
            --secret-string file://$filePath 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✅ Secreto '$secretName' creado exitosamente" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host "   ❌ Error al crear secreto '$secretName'" -ForegroundColor Red
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
if ($errorCount -eq 0) {
    Write-Host "🎉 Proceso completado exitosamente!" -ForegroundColor Green
    Write-Host "✅ $successCount secreto(s) creado(s)" -ForegroundColor Green
} else {
    Write-Host "⚠️  Proceso completado con errores" -ForegroundColor Yellow
    Write-Host "✅ $successCount secreto(s) creado(s)" -ForegroundColor Green
    Write-Host "❌ $errorCount error(es)" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 Para verificar los secretos creados:" -ForegroundColor Cyan
Write-Host "aws --endpoint-url $endpoint secretsmanager list-secrets" -ForegroundColor Gray