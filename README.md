# 📺 Cronograma UNIR.TV

Este repositorio contiene la visualización interactiva del cronograma del proyecto UNIR.TV, incluyendo un diagrama de Gantt dinámico y el organigrama del equipo.

## 🎯 Descripción del Proyecto

UNIR.TV es un proyecto de televisión digital que incluye el desarrollo de una plataforma de streaming, creación de contenidos educativos y estrategias de comunicación. Este repositorio proporciona una visualización completa del cronograma de desarrollo y la estructura organizacional.

## 📊 Contenido del Repositorio

### Archivos Principales

- **`gantt_unirtv.html`** - Diagrama de Gantt interactivo del cronograma del proyecto
- **`Cronograma UNIR TV.xlsx`** - Datos fuente del cronograma en formato Excel
- **`organigrama_unirtv.png`** - Organigrama del equipo en formato PNG
- **`organigrama_unirtv.svg`** - Organigrama del equipo en formato vectorial

### Scripts de Generación

- **`Gantt UNIR TV.r`** - Script R para generar el diagrama de Gantt interactivo
- **`Gantt UNIR TV con equipo.r`** - Versión alternativa del script con información del equipo
- **`Organigrama.r`** - Script R para generar el organigrama del equipo

### Recursos

- **`favicon-unir.png`** - Favicon personalizado de UNIR

## 🚀 Visualización en Vivo

El diagrama de Gantt interactivo está disponible en GitHub Pages:
**[Ver Cronograma UNIR.TV](https://javicanton.github.io/cronograma-unirtv/gantt_unirtv.html)**

## 🛠️ Tecnologías Utilizadas

- **R** - Procesamiento de datos y generación de visualizaciones
- **Plotly** - Creación de gráficos interactivos
- **ggplot2** - Generación de gráficos estáticos
- **HTML/CSS/JavaScript** - Interfaz web interactiva
- **Excel** - Fuente de datos del cronograma

## 📋 Características del Diagrama de Gantt

- **Interactividad**: Zoom, pan y hover para detalles
- **Categorización**: Tareas agrupadas por tipo (Desarrollo, Contenidos, Comunicación, etc.)
- **Hitos**: Marcadores especiales para hitos importantes
- **Timeline**: Vista cronológica con marcas bimestrales
- **Responsive**: Adaptable a diferentes tamaños de pantalla

## 👥 Estructura del Equipo

### Área de Contenidos

- **Responsable**: Inma Berlanga
- **Miembros**: Alicia Moreno, Isabel de Azcárraga, Pavel Sidorenko

### Área de Desarrollo

- **Responsable**: Isabel de Azcárraga
- **Miembros**: Rubén Ortega, Brenda Vázquez

### Área de Comunicación

- **Responsable**: Pavel Sidorenko
- **Miembros**: María Abellán, Javi Cantón

### Área de Investigación

- **Miembros**: Todo el equipo participa en actividades de investigación

## 🔧 Cómo Usar

### Visualización

1. Abre el archivo `gantt_unirtv.html` en tu navegador web
2. Utiliza las herramientas de zoom y pan para navegar por el cronograma
3. Pasa el cursor sobre las tareas para ver detalles específicos

### Regeneración de Gráficos

1. Instala las dependencias de R necesarias:

   ```r
   install.packages(c("readxl", "dplyr", "plotly", "lubridate", "ggplot2", "stringr", "ggtext", "svglite", "htmlwidgets"))
   ```

2. Ejecuta los scripts R para regenerar las visualizaciones:

   ```r
   # Para el diagrama de Gantt
   source("Gantt UNIR TV.r")
   
   # Para el organigrama
   source("Organigrama.r")
   ```

## 📝 Actualización de Datos

Para actualizar el cronograma:

1. Modifica el archivo `Cronograma UNIR TV.xlsx`
2. Ejecuta el script `Gantt UNIR TV.r`
3. El archivo HTML se actualizará automáticamente

## 🎨 Personalización

Los scripts R incluyen variables de configuración para personalizar:

- Colores de las categorías
- Tamaños de fuente
- Espaciado y márgenes
- Formato de fechas
- Estilos visuales

## 📄 Licencia

Este proyecto es propiedad de UNIR (Universidad Internacional de La Rioja) y está destinado para uso interno del proyecto UNIR.TV.

## 🤝 Contribuciones

Para contribuir al proyecto:

1. Haz fork del repositorio
2. Crea una rama para tu contribución
3. Realiza los cambios necesarios
4. Envía un pull request

## 📞 Contacto

Para consultas sobre el proyecto, contacta con el equipo de desarrollo de UNIR.TV.

---

*Última actualización: $(date +"%d de %B de %Y")*
