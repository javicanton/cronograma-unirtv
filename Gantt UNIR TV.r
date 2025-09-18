library(readxl)
library(dplyr)
library(plotly)
library(lubridate)
library(rstudioapi)

# ---- Ruta ----
# Obtener el directorio donde se encuentra este script
script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
if (script_dir == "") {
  # Si no se puede obtener el directorio del script, usar el directorio de trabajo actual
  script_dir <- getwd()
}
xlsx_path <- file.path(script_dir, "Cronograma UNIR TV.xlsx")

# ---- Lectura y normalización ----
df0 <- read_excel(xlsx_path) %>%
  rename(
    `Fecha inicio` = matches("^Fecha\\s*inicio$", ignore.case = TRUE),
    `Fecha fin`    = matches("^Fecha\\s*fin$",    ignore.case = TRUE),
    Subtarea       = matches("^Subtarea$",        ignore.case = TRUE),
    Tarea          = matches("^Tarea$",           ignore.case = TRUE)
  ) %>%
  mutate(
    `Fecha inicio` = as_date(`Fecha inicio`),
    `Fecha fin`    = as_date(`Fecha fin`)
  ) %>%
  filter(!is.na(`Fecha inicio`), !is.na(`Fecha fin`), !is.na(Subtarea)) %>%
  arrange(`Fecha inicio`)

# ---- Hitos: barra de 3 días ----
df_hito <- df0 %>% filter(Tarea == "Hito") %>%
  mutate(`Fecha fin` = `Fecha inicio` + days(2))
df      <- df0 %>% filter(Tarea != "Hito")

# ---- Orden cronológico arriba -> abajo ----
niveles <- df0 %>% arrange(`Fecha inicio`) %>% pull(Subtarea) %>% unique()
niveles_plot <- rev(niveles)  # plotly pone el primer nivel abajo
df      <- df      %>% mutate(Subtarea = factor(Subtarea, levels = niveles_plot))
df_hito <- df_hito %>% mutate(Subtarea = factor(Subtarea, levels = niveles_plot))

# ---- Eje X: español, bimestral y 45º ----
invisible(try(Sys.setlocale("LC_TIME", "es_ES.UTF-8"), silent = TRUE))
xmin <- floor_date(min(df0$`Fecha inicio`), "month")
xmax <- ceiling_date(max(df0$`Fecha fin`), "month")
ticks_m <- seq(xmin, xmax, by = "1 month")
ticks   <- ticks_m[month(ticks_m) %in% c(1,3,5,7,9,11)]
ticktext <- format(ticks, "%b %Y")

# Poner enero en negrita
is_january <- month(ticks) == 1
ticktext[is_january] <- paste0("<b>", ticktext[is_january], "</b>")

# ---- Posición de etiquetas: SIEMPRE después del FIN (2 días) ----
labels_all <- bind_rows(df, df_hito) %>%
  transmute(
    Subtarea = factor(Subtarea, levels = niveles_plot),
    x_lab    = `Fecha fin` + days(2),     # 2 días después del final para más separación
    textpos  = "middle right"             # etiquetas a la derecha del punto
  )

# Para tareas con el mismo nombre, mostrar solo una etiqueta centrada
# Agrupar por nombre de tarea y calcular punto medio
labels_grouped <- labels_all %>%
  group_by(Subtarea) %>%
  summarise(
    x_lab = mean(x_lab),  # Punto medio entre las fechas
    textpos = first(textpos),
    .groups = 'drop'
  )

# Reemplazar labels_all con la versión agrupada
labels_all <- labels_grouped

# Solo cambiar las etiquetas específicas
# Para "Emisiones en directo" - 15 días antes del inicio
idx_emisiones <- grepl("Emisiones en directo.*captación.*posicionamiento", as.character(labels_all$Subtarea))
if(any(idx_emisiones)) {
  fecha_inicio <- df$`Fecha inicio`[grepl("Emisiones en directo.*captación.*posicionamiento", as.character(df$Subtarea))][1]
  labels_all$x_lab[idx_emisiones] <- fecha_inicio - days(165)
}

# Para "Resolución problemas técnicos + Mejora plataforma" - 200 días antes
idx_resolucion <- grepl("Resolución problemas técnicos.*Mejora plataforma", as.character(labels_all$Subtarea))
if(any(idx_resolucion)) {
  fecha_inicio <- df$`Fecha inicio`[grepl("Resolución problemas técnicos.*Mejora plataforma", as.character(df$Subtarea))][1]
  labels_all$x_lab[idx_resolucion] <- fecha_inicio + days(185)
}

# Para "Análisis consumo y objetivos" - 200 días antes
idx_analisis <- grepl("Análisis consumo y objetivos", as.character(labels_all$Subtarea))
if(any(idx_analisis)) {
  fecha_inicio <- df$`Fecha inicio`[grepl("Análisis consumo y objetivos", as.character(df$Subtarea))][1]
  labels_all$x_lab[idx_analisis] <- fecha_inicio + days(155)
}


# ---- Gráfico ----
p <- plot_ly()

# Barras normales
p <- p %>%
  add_segments(
    data  = df,
    x     = ~`Fecha inicio`, xend = ~`Fecha fin`,
    y     = ~Subtarea,       yend = ~Subtarea,
    color = ~Tarea,
    mode  = "lines",
    line  = list(width = 12),
    text  = ~paste0(
      "<b>", Subtarea, "</b><br>",
      "Categoría: ", Tarea, "<br>",
      "Inicio: ", format(`Fecha inicio`, "%d-%m-%Y"), "<br>",
      "Fin: ",    format(`Fecha fin`,    "%d-%m-%Y")
    ),
    hovertemplate = "%{text}<extra></extra>"
  )

# Barras Hito (3 días), sin leyenda
if (nrow(df_hito) > 0) {
  p <- p %>%
    add_segments(
      data  = df_hito,
      x     = ~`Fecha inicio`, xend = ~`Fecha fin`,
      y     = ~Subtarea,       yend = ~Subtarea,
      inherit = FALSE,
      line  = list(width = 12),
      showlegend = FALSE,
      text  = ~paste0(
        "<b>", Subtarea, "</b><br>",
        "Hito <br>",
        "Inicio: ", format(`Fecha inicio`, "%d-%m-%Y"), "<br>",
        "Fin: ",    format(`Fecha fin`,    "%d-%m-%Y")
      ),
      hovertemplate = "%{text}<extra></extra>"
    )
}

# Etiquetas SIEMPRE a la derecha del fin
p <- p %>%
  add_trace(
    data  = labels_all,
    x     = ~x_lab,
    y     = ~Subtarea,
    type  = "scatter",
    mode  = "text",
    text  = ~as.character(Subtarea),
    textposition = ~textpos,
    textfont = list(
      size = 12,
      color = "black",
      family = "Arial"
    ),
    # Fondo semitransparente para mejor legibilidad
    texttemplate = ~paste0(
      "<span style='background-color: rgba(255, 255, 255, 0.8); padding: 2px 4px; border-radius: 3px;'>",
      as.character(Subtarea),
      "</span>"
    ),
    showlegend = FALSE,
    hoverinfo = "skip",
    cliponaxis = FALSE
  ) %>%
  layout(
    title = list(
      text = "Evolución proyecto UNIR.TV",
      x = 0.5,
      xanchor = "center",
      font = list(size = 20)
    ),
    margin = list(t = 100),  # Margen superior aumentado
    xaxis = list(
      title = "Fecha",
      tickmode = "array",
      tickvals = ticks,
      ticktext = ticktext,
      tickangle = 45
    ),
    yaxis = list(
      title = "",            # sin título en Y
      showticklabels = FALSE
    ),
    legend = list(
      orientation = "h", 
      y = 1.02,
      x = 0.5,
      xanchor = "center",
      yanchor = "bottom"
    )
  )

p

# ---- Exportar a HTML ----
# Usar el directorio del script para guardar los archivos
html_file <- file.path(script_dir, "gantt_unirtv.html")

# Exportar el gráfico a HTML en la misma carpeta con título personalizado
htmlwidgets::saveWidget(
  p, 
  html_file, 
  selfcontained = TRUE,
  title = "UNIR.TV"
)

# Añadir favicon personalizado (favicon-unir.png)
favicon_path <- file.path(script_dir, "favicon-unir.png")
if(file.exists(favicon_path)) {
  # Leer el HTML generado
  html_content <- readLines(html_file)
  
  # Añadir la línea del favicon antes del </head>
  favicon_line <- '<link rel="icon" type="image/png" href="favicon-unir.png">'
  
  # Insertar la línea del favicon
  head_end <- grep("</head>", html_content)
  if(length(head_end) > 0) {
    html_content <- c(
      html_content[1:(head_end-1)],
      favicon_line,
      html_content[head_end:length(html_content)]
    )
    
    # Escribir el HTML modificado
    writeLines(html_content, html_file)
    cat("✅ Favicon UNIR añadido al HTML\n")
  }
} else {
  cat("💡 Para añadir favicon: coloca 'favicon-unir.png' en la carpeta del proyecto\n")
}

cat("✅ Diagrama de Gantt generado exitosamente\n")
cat("📁 Directorio:", script_dir, "\n")
cat("📄 Archivo generado:", basename(html_file), "\n")
cat("🌐 Abre el HTML en tu navegador para visualizar y editar\n")