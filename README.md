# SAP API

Una API REST desarrollada en .NET 8 para gestionar datos de SAP Business One (SBO), específicamente para el manejo de días festivos y calendarios laborales.

## Descripción

Este proyecto proporciona una interfaz REST para interactuar con las tablas OHLD (Holiday Header) y HLD1 (Holiday Lines) de SAP Business One. La API permite realizar operaciones CRUD completas sobre estos datos, facilitando la gestión de calendarios laborales y días festivos desde aplicaciones externas.

## Tecnologías Utilizadas

- **.NET 8** - Framework principal
- **ASP.NET Core Web API** - Framework para la API REST
- **Entity Framework Core 9.0.8** - ORM para acceso a datos
- **SQL Server** - Base de datos (SBO_FIBRAFIL)
- **Swagger/OpenAPI** - Documentación de API
- **CORS** - Configurado para permitir acceso desde cualquier origen

## Estructura del Proyecto

```
Sap-api/
├── Sap-api/                 # Proyecto principal de la API
│   ├── Controllers/         # Controladores REST
│   │   ├── OhldController.cs
│   │   ├── HldController.cs
│   │   └── WeatherForecastController.cs
│   ├── Data/               # Contexto de Entity Framework
│   │   └── ApplicationDbContext.cs
│   ├── Properties/         # Configuración de lanzamiento
│   └── Program.cs          # Punto de entrada de la aplicación
├── Entity/                 # Modelos de entidad
│   └── Ohld/
│       ├── Ohld.cs         # Entidad principal (Holiday Header)
│       └── Hld1.cs         # Entidad de detalle (Holiday Lines)
└── Dtos/                   # Data Transfer Objects
    └── OHLD/
        └── OhldDTO.cs      # DTOs para transferencia de datos
```

## Modelos de Datos

### OHLD (Holiday Header)
Tabla principal que contiene la información de configuración de días festivos:
- **HldCode**: Código identificador único del calendario (Primary Key)
- **WndFrm**: Ventana desde
- **WndTo**: Ventana hasta
- **IsCurYear**: Indica si es del año actual
- **IgnrWnd**: Ignorar ventana
- **WeekNoRule**: Regla del número de semana

### HLD1 (Holiday Lines)
Tabla de detalle que contiene las fechas específicas de días festivos:
- **HldCode**: Código del calendario (Foreign Key)
- **StrDate**: Fecha de inicio del día festivo
- **EndDate**: Fecha de fin del día festivo
- **Rmrks**: Observaciones o comentarios

## Endpoints de la API

### OHLD Controller (`/api/Ohlds`)

- **GET** `/api/Ohlds` - Obtiene todos los calendarios con sus días festivos
- **GET** `/api/Ohlds/{id}` - Obtiene un calendario específico por HldCode
- **POST** `/api/Ohlds` - Crea un nuevo calendario
- **PUT** `/api/Ohlds/{id}` - Actualiza un calendario existente
- **DELETE** `/api/Ohlds/{id}` - Elimina un calendario

### HLD1 Controller (`/api/Hld1s`)

- **GET** `/api/Hld1s` - Obtiene todos los días festivos
- **GET** `/api/Hld1s/{hldCode}/{strDate}/{endDate}` - Obtiene un día festivo específico
- **POST** `/api/Hld1s` - Crea un nuevo día festivo
- **PUT** `/api/Hld1s/{hldCode}/{strDate}/{endDate}` - Actualiza un día festivo
- **DELETE** `/api/Hld1s/{hldCode}/{strDate}/{endDate}` - Elimina un día festivo

## Configuración

### Cadena de Conexión
La aplicación se conecta a la base de datos SAP Business One configurada en `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=192.168.1.6;Database=SBO_FIBRAFIL;User Id=jescalante;Password=Fibra76095492;TrustServerCertificate=True;Encrypt=False;"
  }
}
```

### CORS
La API está configurada con una política CORS permisiva que permite:
- Cualquier origen
- Cualquier método HTTP
- Cualquier header
- Exposición del header `x-pagination`

## Instalación y Ejecución

### Prerrequisitos
- .NET 8 SDK
- SQL Server con acceso a la base de datos SBO_FIBRAFIL
- Visual Studio 2022 o VS Code (opcional)

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd Sap-api
   ```

2. **Restaurar dependencias**
   ```bash
   dotnet restore
   ```

3. **Configurar la cadena de conexión**
   - Editar `appsettings.json` con los datos de tu base de datos SAP

4. **Ejecutar la aplicación**
   ```bash
   dotnet run --project Sap-api
   ```

   La API estará disponible en:
   - HTTP: http://localhost:5031
   - Swagger UI: http://localhost:5031/swagger

### Perfiles de Ejecución

- **Development**: Puerto 5031, entorno de desarrollo
- **IIS Express**: Puerto 9060, entorno de producción

## Documentación de API

La documentación interactiva de la API está disponible a través de Swagger UI una vez que la aplicación esté ejecutándose. Accede a `/swagger` para explorar todos los endpoints disponibles.

## Funcionalidades Principales

1. **Gestión de Calendarios**: CRUD completo para calendarios de días festivos
2. **Gestión de Días Festivos**: CRUD completo para fechas específicas
3. **Relaciones**: Manejo automático de relaciones entre calendarios y días festivos
4. **DTOs**: Transferencia optimizada de datos con objetos DTO especializados
5. **Validaciones**: Validaciones de clave primaria compuesta y integridad referencial

## Desarrollo

### Estructura de DTOs

```csharp
public class OhldDTO
{
    public string HldCode { get; set; }
    public string? WndFrm { get; set; }
    public string? WndTo { get; set; }
    public string? IsCurYear { get; set; }
    public string? IgnrWnd { get; set; }
    public string? WeekNoRule { get; set; }
    public ICollection<DetailedOhldDTO> Hld1s { get; set; }
}
```

### Relaciones Entity Framework

La aplicación utiliza Entity Framework Core con configuraciones específicas para:
- Claves primarias compuestas en HLD1
- Relaciones uno a muchos entre OHLD y HLD1
- Eliminación en cascada
- Collation específica para SQL Server

## Consideraciones de Seguridad

⚠️ **Importante**: La cadena de conexión contiene credenciales en texto plano. Para entornos de producción se recomienda:
- Usar Azure Key Vault o similar
- Implementar autenticación y autorización
- Configurar HTTPS
- Restringir las políticas CORS

## Contacto y Soporte

Este proyecto está diseñado para integrarse con SAP Business One y proporcionar acceso programático a los datos de calendarios laborales.