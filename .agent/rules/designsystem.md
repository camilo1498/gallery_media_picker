---
trigger: always_on
---

Design System
1. Gestión de Colores y Temas (AppColorScheme)
Prohibición de Colores Hardcoded: Nunca generes colores usando Colors.xyz o Color(0xFF...). Usa siempre Theme.of(context).colorScheme.
Mapeo de Superficies:
Usa .background para el fondo de las páginas.
Usa .surface para las tarjetas principales (Card, Container).
Usa .surfaceVariant para elementos anidados (ej. micro-tarjetas dentro de DNA Musical) y fondos de TextField.
Jerarquía de Texto:
Usa siempre .onSurface para títulos principales.
Usa siempre .onSurfaceVariant para subtítulos, etiquetas y metadatos (BPM, Key).
Estados Semánticos:
.tertiary para estados "Completados" (Verde).
.error para acciones de eliminación o errores (Rojo).
.onSecondaryContainer para estados "Incompletos/Advertencias" (Naranja).
Gráficas: Para gradientes de gráficas, usa primaryContainer (inicio) y secondaryContainer (fin).
2. Sistema de Dimensiones y Espaciado (AppSpacing & AppRadius)
Radios de Curvatura:
Tarjetas principales del Dashboard: AppRadius.xl (28.r).
Elementos internos/anidados: AppRadius.lg (16.r).
Botones principales: AppRadius.full (100.r - StadiumBorder).
Espaciado Dinámico:
Usa AppSpacing.of(context).pagePadding para el margen exterior de las vistas.
Usa AppSpacing.of(context).md (12-24px) para el espacio entre tarjetas (Gap).
Usa AppSpacing.of(context).lg (16-32px) para el padding interno de las tarjetas principales.
Gaps: Prefiere el uso de AppSpacing.of(context).gapMd en lugar de SizedBox manuales.
3. Tipografía (AppTextTheme)
Escalado Dinámico: Utiliza Theme.of(context).textTheme en lugar de crear estilos TextStyle locales.
Datos Técnicos: Siempre que se muestren números (BPM, Tiempos, Keys), el código debe usar bodySmall o un estilo que herede la fuente Monrope con FontFeature.tabularFigures() para asegurar alineación numérica.
Headers: Usa displaySmall para saludos de usuario y headlineMedium para títulos de sección.
4. Responsividad (AppLayout)
Navegación:
Mobile: Implementar Drawer con botón hamburguesa.
Tablet: Implementar NavigationRail.
Desktop: Implementar Sidebar permanente (PermanentDrawer).
Grid System: Usa AppLayout.of(context).gridColumns para determinar el conteo de columnas en GridView.
UX de Gráficas: Para evitar estiramientos innecesarios, las gráficas grandes deben estar envueltas en un AspectRatio condicional basado en context.isDesktop.