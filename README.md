# BayStream 🚢

**Aplicación de Gestión de Carga Marítima** - Proyecto de Tesis de Ingeniería

## Descripción

BayStream es una aplicación Flutter para la gestión y visualización de carga marítima, con capacidad de parsear archivos BAPLIE 2.2.1 (estándar EDIFACT para intercambio de información de estiba de contenedores).

## Stack Tecnológico

- **Frontend:** Flutter 3.x
- **Backend/Database:** Firebase Firestore (NoSQL)
- **State Management:** Riverpod
- **Arquitectura:** Clean Architecture

## Estructura del Proyecto

```
lib/
├── core/
│   ├── app.dart                    # Configuración de la app
│   ├── constants/
│   │   └── baplie_constants.dart   # Constantes EDIFACT BAPLIE
│   ├── errors/
│   │   ├── exceptions.dart         # Excepciones personalizadas
│   │   └── failures.dart           # Clases de fallo (Either pattern)
│   └── utils/
│       └── iso_coordinate_parser.dart  # Parser de coordenadas BBBRRTT
├── features/
│   └── vessel/
│       ├── data/
│       │   ├── repositories/
│       │   │   └── vessel_repository_impl.dart
│       │   └── services/
│       │       └── baplie_parser_service.dart  # Parser BAPLIE principal
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── bay.dart            # Modelo de bahía
│       │   │   ├── container_slot.dart # Modelo de celda/slot
│       │   │   ├── container_unit.dart # Modelo de contenedor
│       │   │   ├── vessel.dart         # Modelo de buque
│       │   │   └── vessel_voyage.dart  # Modelo de viaje completo
│       │   └── repositories/
│       │       └── vessel_repository.dart
│       └── presentation/
│           ├── pages/
│           │   └── vessel_overview_page.dart
│           └── providers/
│               └── vessel_providers.dart
└── main.dart
```

## Estándar BAPLIE 2.2.1 Implementado

### Separadores EDIFACT
| Separador | Carácter | Uso |
|-----------|----------|-----|
| Segmento | `'` | Fin de cada segmento |
| Elemento | `+` | Separa elementos de datos |
| Componente | `:` | Separa componentes dentro de un elemento |

### Segmentos Parseados

| Segmento | Descripción | Datos Extraídos |
|----------|-------------|-----------------|
| `TDT` | Transport Details | Nombre del buque, Nº de viaje |
| `LOC+147` | Stowage Position | Coordenada ISO (BBBRRTT) |
| `EQD+CN` | Equipment Details | ID contenedor, Tipo ISO, Estado |
| `MEA+WT` | Gross Weight | Peso bruto (kg) |
| `MEA+VGM` | Verified Gross Mass | Peso verificado SOLAS (kg) |

### Formato de Coordenadas ISO (BBBRRTT)
- **BBB** (3 dígitos): Número de bahía (Bay)
- **RR** (2 dígitos): Número de fila (Row)
- **TT** (2 dígitos): Número de nivel (Tier)

Ejemplo: `0120006` → Bay: 12, Row: 00, Tier: 06

## Instalación

```bash
# Clonar el repositorio
git clone <repo-url>
cd BayStream

# Instalar dependencias
flutter pub get

# Ejecutar la aplicación
flutter run
```

## Ejecutar Tests

```bash
flutter test
```

## Uso del Parser

```dart
import 'package:baystream/features/vessel/data/services/baplie_parser_service.dart';

final parser = BaplieParserService();
final voyage = parser.parse(baplieFileContent);

print('Buque: ${voyage.vessel.name}');
print('Viaje: ${voyage.voyageNumber}');
print('Total contenedores: ${voyage.totalContainers}');

for (final container in voyage.containers) {
  print('${container.containerId} - ${container.stowagePosition?.displayFormat}');
}
```

## Función `parseIsoCoordinates`

```dart
import 'package:baystream/core/utils/iso_coordinate_parser.dart';

final coord = parseIsoCoordinates('0120006');
print(coord.bay);   // 12
print(coord.row);   // 0
print(coord.tier);  // 6
print(coord.displayFormat); // "Bay 012, Row 00, Tier 06"
```

## Licencia

Este proyecto es parte de una tesis de ingeniería.

---
Desarrollado con Flutter 💙
