# ===================================================================
# 🚀 SCRIPT DE AUTOMATIZACIÓN COMPLETO PARA ENTITY FRAMEWORK
# ===================================================================
# 💡 Ideado por: jescalante (el visionario)
# 🤖 Desarrollado por: Claude (Anthropic) - tu asistente AI favorito
# 🤝 Colaboración épica entre humano y AI
# Versión: 1.0
# Descripción: Automatiza mapeo de tablas y generación de controladores
# ===================================================================

# Colores para output
$ErrorColor = "Red"
$SuccessColor = "Green" 
$InfoColor = "Cyan"
$WarningColor = "Yellow"
$MenuColor = "Magenta"

# Función para mostrar banner
function Show-Banner {
    Clear-Host
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $MenuColor
    Write-Host "║               🚀 ENTITY FRAMEWORK AUTOMATION 🚀               ║" -ForegroundColor $MenuColor
    Write-Host "║                                                              ║" -ForegroundColor $MenuColor
    Write-Host "║  💡 Ideado por: jescalante    🤖 Coded by: Claude (AI)       ║" -ForegroundColor $MenuColor
    Write-Host "║  Automatiza el mapeo de tablas y generación de controladores ║" -ForegroundColor $MenuColor
    Write-Host "║                    🤝 Dream Team v1.0 🤝                     ║" -ForegroundColor $MenuColor
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $MenuColor
    Write-Host ""
}

# Función para verificar si estamos en la ubicación correcta
function Test-ProjectLocation {
    if (!(Test-Path "*.csproj")) {
        Write-Host "❌ ERROR: No se encontró archivo .csproj" -ForegroundColor $ErrorColor
        Write-Host "💡 Asegúrate de ejecutar este script desde la raíz de tu proyecto" -ForegroundColor $WarningColor
        return $false
    }
    
    $csprojFile = Get-ChildItem "*.csproj" | Select-Object -First 1
    Write-Host "✅ Proyecto encontrado: $($csprojFile.Name)" -ForegroundColor $SuccessColor
    return $true
}

# Función para verificar/instalar dependencias
function Install-Dependencies {
    Write-Host "🔍 Verificando dependencias..." -ForegroundColor $InfoColor
    
    # Verificar si dotnet está disponible
    try {
        $dotnetVersion = dotnet --version
        Write-Host "✅ .NET CLI encontrado: v$dotnetVersion" -ForegroundColor $SuccessColor
    }
    catch {
        Write-Host "❌ .NET CLI no encontrado. Instálalo desde: https://dotnet.microsoft.com/" -ForegroundColor $ErrorColor
        return $false
    }
    
    # Verificar herramientas globales
    $tools = dotnet tool list --global
    if ($tools -notlike "*dotnet-aspnet-codegenerator*") {
        Write-Host "📦 Instalando dotnet-aspnet-codegenerator..." -ForegroundColor $InfoColor
        dotnet tool install --global dotnet-aspnet-codegenerator
        Write-Host "✅ dotnet-aspnet-codegenerator instalado" -ForegroundColor $SuccessColor
    } else {
        Write-Host "✅ dotnet-aspnet-codegenerator ya está instalado" -ForegroundColor $SuccessColor
    }
    
    # Verificar paquetes NuGet requeridos
    $csprojContent = Get-Content "*.csproj" -Raw
    
    $requiredPackages = @(
        "Microsoft.EntityFrameworkCore.SqlServer",
        "Microsoft.EntityFrameworkCore.Design", 
        "Microsoft.VisualStudio.Web.CodeGeneration.Design"
    )
    
    foreach ($package in $requiredPackages) {
        if ($csprojContent -notlike "*$package*") {
            Write-Host "📦 Instalando $package..." -ForegroundColor $InfoColor
            dotnet add package $package
            Write-Host "✅ $package instalado" -ForegroundColor $SuccessColor
        } else {
            Write-Host "✅ $package ya está instalado" -ForegroundColor $SuccessColor
        }
    }
    
    Write-Host ""
    return $true
}

# Función para crear directorios si no existen
function Initialize-Directories {
    $directories = @("Models", "Controllers", "Data")
    
    foreach ($dir in $directories) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
            Write-Host "📁 Directorio creado: $dir" -ForegroundColor $InfoColor
        }
    }
}

# Función para construir cadena de conexión
function Get-ConnectionString {
    Write-Host "🔗 CONFIGURACIÓN DE CADENA DE CONEXIÓN" -ForegroundColor $MenuColor
    Write-Host "═══════════════════════════════════════" -ForegroundColor $MenuColor
    
    Write-Host "1. Ingresar cadena de conexión completa"
    Write-Host "2. Construir cadena paso a paso"
    Write-Host ""
    
    do {
        $option = Read-Host "Selecciona una opción (1-2)"
    } while ($option -notin @("1", "2"))
    
    if ($option -eq "1") {
        Write-Host ""
        Write-Host "💡 Ejemplo: Server=localhost;Database=MiDB;User Id=usuario;Password=pass;TrustServerCertificate=True;Encrypt=False;" -ForegroundColor $WarningColor
        Write-Host ""
        $connectionString = Read-Host "Ingresa la cadena de conexión completa"
    }
    else {
        Write-Host ""
        $server = Read-Host "Servidor (ej: localhost, 192.168.1.100)"
        $database = Read-Host "Base de datos"
        $userId = Read-Host "Usuario"
        $password = Read-Host "Contraseña" -AsSecureString
        $passwordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
        
        $connectionString = "Server=$server;Database=$database;User Id=$userId;Password=$passwordText;TrustServerCertificate=True;Encrypt=False;"
    }
    
    return $connectionString
}

# Función para obtener lista de tablas de la base de datos
function Get-DatabaseTables {
    param($connectionString)
    
    Write-Host "📋 Obteniendo lista de tablas..." -ForegroundColor $InfoColor
    
    try {
        # Comando SQL para obtener tablas
        $query = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_NAME"
        
        # Crear comando temporal para obtener tablas
        $tempFile = "temp_tables.sql"
        $query | Out-File -FilePath $tempFile -Encoding UTF8
        
        # Ejecutar usando sqlcmd si está disponible, sino mostrar instrucciones
        try {
            $tables = sqlcmd -S $server -d $database -U $userId -P $passwordText -Q $query -h -1 -W | Where-Object { $_.Trim() -ne "" }
            Remove-Item $tempFile -ErrorAction SilentlyContinue
            return $tables
        }
        catch {
            Write-Host "⚠️  No se pudo obtener automáticamente la lista de tablas" -ForegroundColor $WarningColor
            Write-Host "💡 Puedes obtener las tablas manualmente ejecutando:" -ForegroundColor $InfoColor
            Write-Host "   SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'" -ForegroundColor $InfoColor
            Remove-Item $tempFile -ErrorAction SilentlyContinue
            return $null
        }
    }
    catch {
        Write-Host "❌ Error conectando a la base de datos" -ForegroundColor $ErrorColor
        return $null
    }
}

# Función para mapear tablas
function Invoke-TableMapping {
    $connectionString = Get-ConnectionString
    
    if ([string]::IsNullOrEmpty($connectionString)) {
        Write-Host "❌ Cadena de conexión requerida" -ForegroundColor $ErrorColor
        return
    }
    
    Write-Host ""
    Write-Host "📊 SELECCIÓN DE TABLAS" -ForegroundColor $MenuColor
    Write-Host "═══════════════════════" -ForegroundColor $MenuColor
    Write-Host "1. Mapear TODAS las tablas"
    Write-Host "2. Mapear tablas específicas"
    Write-Host ""
    
    do {
        $mappingOption = Read-Host "Selecciona una opción (1-2)"
    } while ($mappingOption -notin @("1", "2"))
    
    # Configurar parámetros base
    $contextName = Read-Host "Nombre del contexto (default: ApplicationDbContext)"
    if ([string]::IsNullOrEmpty($contextName)) { $contextName = "ApplicationDbContext" }
    
    $outputDir = Read-Host "Directorio de modelos (default: Models)"
    if ([string]::IsNullOrEmpty($outputDir)) { $outputDir = "Models" }
    
    $contextDir = Read-Host "Directorio del contexto (default: Data)"
    if ([string]::IsNullOrEmpty($contextDir)) { $contextDir = "Data" }
    
    # Construir comando base
    $baseCommand = "Scaffold-DbContext `"$connectionString`" Microsoft.EntityFrameworkCore.SqlServer -OutputDir $outputDir -Context $contextName -ContextDir $contextDir -Force -NoOnConfiguring"
    
    if ($mappingOption -eq "2") {
        Write-Host ""
        Write-Host "💡 Ingresa las tablas separadas por comas (ej: usuarios,productos,categorias)" -ForegroundColor $InfoColor
        $tablesInput = Read-Host "Tablas a mapear"
        
        if (![string]::IsNullOrEmpty($tablesInput)) {
            $baseCommand += " -Tables $tablesInput"
        }
    }
    
    Write-Host ""
    Write-Host "🚀 Ejecutando mapeo de tablas..." -ForegroundColor $InfoColor
    Write-Host "Comando: $baseCommand" -ForegroundColor $WarningColor
    Write-Host ""
    
    try {
        Invoke-Expression $baseCommand
        Write-Host ""
        Write-Host "✅ ¡Mapeo de tablas completado exitosamente!" -ForegroundColor $SuccessColor
        
        # Mostrar archivos generados
        Write-Host ""
        Write-Host "📁 Archivos generados:" -ForegroundColor $InfoColor
        if (Test-Path $outputDir) {
            Get-ChildItem "$outputDir\*.cs" | ForEach-Object { Write-Host "   - $($_.Name)" -ForegroundColor $SuccessColor }
        }
        if (Test-Path "$contextDir\$contextName.cs") {
            Write-Host "   - $contextDir\$contextName.cs" -ForegroundColor $SuccessColor
        }
    }
    catch {
        Write-Host ""
        Write-Host "❌ Error durante el mapeo: $($_.Exception.Message)" -ForegroundColor $ErrorColor
        Write-Host "💡 Verifica la cadena de conexión y permisos de base de datos" -ForegroundColor $WarningColor
    }
}

# Función para obtener modelos disponibles
function Get-AvailableModels {
    if (!(Test-Path "Models")) {
        Write-Host "❌ No se encontró la carpeta Models" -ForegroundColor $ErrorColor
        return @()
    }
    
    $modelFiles = Get-ChildItem "Models\*.cs" | Where-Object { $_.Name -ne "ErrorViewModel.cs" }
    $models = @()
    
    foreach ($file in $modelFiles) {
        $className = $file.BaseName
        $models += $className
    }
    
    return $models
}

# Función para generar controladores
function Invoke-ControllerGeneration {
    Write-Host "🎮 GENERACIÓN DE CONTROLADORES" -ForegroundColor $MenuColor
    Write-Host "═══════════════════════════════" -ForegroundColor $MenuColor
    
    # Obtener modelos disponibles
    $availableModels = Get-AvailableModels
    
    if ($availableModels.Count -eq 0) {
        Write-Host "❌ No se encontraron modelos en la carpeta Models" -ForegroundColor $ErrorColor
        Write-Host "💡 Primero ejecuta el mapeo de tablas (opción 1)" -ForegroundColor $WarningColor
        return
    }
    
    Write-Host "📋 Modelos disponibles:" -ForegroundColor $InfoColor
    for ($i = 0; $i -lt $availableModels.Count; $i++) {
        Write-Host "   $($i + 1). $($availableModels[$i])" -ForegroundColor $SuccessColor
    }
    
    Write-Host ""
    Write-Host "Opciones:" -ForegroundColor $InfoColor
    Write-Host "1. Generar controladores para TODOS los modelos"
    Write-Host "2. Seleccionar modelos específicos"
    Write-Host "3. Ingresar nombres manualmente"
    Write-Host ""
    
    do {
        $option = Read-Host "Selecciona una opción (1-3)"
    } while ($option -notin @("1", "2", "3"))
    
    $selectedModels = @()
    
    switch ($option) {
        "1" {
            $selectedModels = $availableModels
        }
        "2" {
            Write-Host ""
            Write-Host "💡 Ingresa los números separados por comas (ej: 1,3,5)" -ForegroundColor $InfoColor
            $indices = Read-Host "Modelos a generar"
            
            $indexList = $indices.Split(',') | ForEach-Object { $_.Trim() }
            foreach ($index in $indexList) {
                if ($index -match '^\d+$' -and [int]$index -le $availableModels.Count -and [int]$index -gt 0) {
                    $selectedModels += $availableModels[[int]$index - 1]
                }
            }
        }
        "3" {
            Write-Host ""
            Write-Host "💡 Ingresa los nombres de modelos separados por comas" -ForegroundColor $InfoColor
            $manualInput = Read-Host "Nombres de modelos"
            $selectedModels = $manualInput.Split(',') | ForEach-Object { $_.Trim() }
        }
    }
    
    if ($selectedModels.Count -eq 0) {
        Write-Host "❌ No se seleccionaron modelos" -ForegroundColor $ErrorColor
        return
    }
    
    # Obtener nombre del contexto
    $contextName = Read-Host "Nombre del contexto (default: ApplicationDbContext)"
    if ([string]::IsNullOrEmpty($contextName)) { $contextName = "ApplicationDbContext" }
    
    Write-Host ""
    Write-Host "🚀 Generando controladores..." -ForegroundColor $InfoColor
    Write-Host ""
    
    $successCount = 0
    $errorCount = 0
    
    foreach ($model in $selectedModels) {
        $controllerName = $model + "Controller"
        $command = "dotnet aspnet-codegenerator controller -name $controllerName -m $model -dc $contextName -api --relativeFolderPath Controllers"
        
        Write-Host "📝 Generando: $controllerName" -ForegroundColor $InfoColor
        
        try {
            Invoke-Expression $command 2>$null
            Write-Host "   ✅ $controllerName generado exitosamente" -ForegroundColor $SuccessColor
            $successCount++
        }
        catch {
            Write-Host "   ❌ Error generando $controllerName" -ForegroundColor $ErrorColor
            Write-Host "      $($_.Exception.Message)" -ForegroundColor $ErrorColor
            $errorCount++
        }
    }
    
    Write-Host ""
    Write-Host "📊 RESUMEN:" -ForegroundColor $MenuColor
    Write-Host "   ✅ Exitosos: $successCount" -ForegroundColor $SuccessColor
    Write-Host "   ❌ Errores: $errorCount" -ForegroundColor $ErrorColor
    
    if ($successCount -gt 0) {
        Write-Host ""
        Write-Host "🎉 ¡Controladores generados! Puedes probarlos con Swagger UI" -ForegroundColor $SuccessColor
    }
}

# Función para mostrar información del proyecto
function Show-ProjectInfo {
    Write-Host "📋 INFORMACIÓN DEL PROYECTO" -ForegroundColor $MenuColor
    Write-Host "═══════════════════════════" -ForegroundColor $MenuColor
    
    # Información del proyecto
    $csprojFile = Get-ChildItem "*.csproj" | Select-Object -First 1
    Write-Host "📁 Proyecto: $($csprojFile.Name)" -ForegroundColor $InfoColor
    Write-Host "📍 Ubicación: $(Get-Location)" -ForegroundColor $InfoColor
    
    # Verificar directorios
    Write-Host ""
    Write-Host "📂 Estructura de directorios:" -ForegroundColor $InfoColor
    $directories = @("Controllers", "Models", "Data")
    foreach ($dir in $directories) {
        if (Test-Path $dir) {
            $fileCount = (Get-ChildItem $dir -Filter "*.cs" -ErrorAction SilentlyContinue).Count
            Write-Host "   ✅ $dir ($fileCount archivos .cs)" -ForegroundColor $SuccessColor
        } else {
            Write-Host "   ❌ $dir (no existe)" -ForegroundColor $ErrorColor
        }
    }
    
    # Información de modelos
    if (Test-Path "Models") {
        $models = Get-AvailableModels
        Write-Host ""
        Write-Host "🎯 Modelos disponibles ($($models.Count)):" -ForegroundColor $InfoColor
        $models | ForEach-Object { Write-Host "   - $_" -ForegroundColor $SuccessColor }
    }
    
    # Información de controladores
    if (Test-Path "Controllers") {
        $controllers = Get-ChildItem "Controllers\*.cs" | Where-Object { $_.Name -ne "WeatherForecastController.cs" }
        Write-Host ""
        Write-Host "🎮 Controladores disponibles ($($controllers.Count)):" -ForegroundColor $InfoColor
        $controllers | ForEach-Object { Write-Host "   - $($_.BaseName)" -ForegroundColor $SuccessColor }
    }
}

# Función para mostrar menú principal
function Show-MainMenu {
    Write-Host "🎯 MENÚ PRINCIPAL" -ForegroundColor $MenuColor
    Write-Host "═════════════════" -ForegroundColor $MenuColor
    Write-Host "1. 🗺️  Mapear tablas a entidades (Database First)"
    Write-Host "2. 🎮 Generar controladores automáticamente"
    Write-Host "3. 📋 Ver información del proyecto"
    Write-Host "4. 🔧 Verificar/Instalar dependencias"
    Write-Host "5. ❌ Salir"
    Write-Host ""
}

# Función principal
function Main {
    Show-Banner
    
    # Verificar ubicación del proyecto
    if (!(Test-ProjectLocation)) {
        Read-Host "Presiona Enter para salir"
        return
    }
    
    # Inicializar directorios
    Initialize-Directories
    
    do {
        Write-Host ""
        Show-MainMenu
        
        $choice = Read-Host "Selecciona una opción (1-5)"
        
        switch ($choice) {
            "1" {
                Clear-Host
                Show-Banner
                Invoke-TableMapping
                Write-Host ""
                Read-Host "Presiona Enter para continuar"
                Clear-Host
                Show-Banner
            }
            "2" {
                Clear-Host
                Show-Banner
                Invoke-ControllerGeneration
                Write-Host ""
                Read-Host "Presiona Enter para continuar"
                Clear-Host
                Show-Banner
            }
            "3" {
                Clear-Host
                Show-Banner
                Show-ProjectInfo
                Write-Host ""
                Read-Host "Presiona Enter para continuar"
                Clear-Host
                Show-Banner
            }
            "4" {
                Clear-Host
                Show-Banner
                if (Install-Dependencies) {
                    Write-Host "✅ Todas las dependencias están listas" -ForegroundColor $SuccessColor
                }
                Write-Host ""
                Read-Host "Presiona Enter para continuar"
                Clear-Host
                Show-Banner
            }
            "5" {
                Write-Host ""
                Write-Host "🎉 ¡Hasta luego! Creado con ❤️ por el Dream Team:" -ForegroundColor $MenuColor
                Write-Host "   💡 jescalante (la mente brillante)" -ForegroundColor $InfoColor  
                Write-Host "   🤖 Claude AI (las manos mágicas)" -ForegroundColor $InfoColor
                Write-Host "   🚀 ¡Juntos somos imparables!" -ForegroundColor $SuccessColor
                break
            }
            default {
                Write-Host "❌ Opción inválida. Selecciona 1-5" -ForegroundColor $ErrorColor
            }
        }
    } while ($choice -ne "5")
}

# Ejecutar script principal
Main