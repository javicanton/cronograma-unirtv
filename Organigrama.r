library(ggplot2)
library(dplyr)
library(stringr)
library(ggtext)
library(svglite)

setwd("/Users/javiercanton/Library/CloudStorage/OneDrive-UNIR/UNIR/TV-UNIR")

# ================== DATOS EDITABLES ==================
areas <- list(
  list(
    titulo = "ÁREA DE CONTENIDOS",
    responsable = "Inma Berlanga",
    miembros = c("Alicia Moreno", "Isabel de Azcárraga", "Pavel Sidorenko"),
    color = "#FC8D62"  # Contenidos (naranja)
  ),
  list(
    titulo = "ÁREA DE DESARROLLO",
    responsable = "Isabel de Azcárraga",
    miembros = c("Rubén Ortega", "Brenda Vázquez"),
    color = "#8DA0CB"  # Desarrollo (azul)
  ),
  list(
    titulo = "ÁREA DE COMUNICACIÓN",
    responsable = "Pavel Sidorenko",
    miembros = c("María Abellán", "Javi Cantón"),
    color = "#66C2A5"  # Comunicación (verde)
  )
)
color_investigacion <- "#E78AC3"            # rosa
titulo_investigacion <- "ÁREA DE INVESTIGACIÓN"
wrap_header <- 26
wrap_item   <- 22

# ==== TIPOGRAFÍA (ajusta aquí) ====
size_header     <- 4.4   # cabeceras (antes 3.6)
size_item       <- 4.2   # miembros  (antes 3.6)
size_inv_header <- 4.8   # cabecera INVESTIGACIÓN (antes 4.0)
size_inv_body   <- 4.2   # texto INVESTIGACIÓN (antes 3.6)

# Parámetros de layout
gap_col  <- 7.0
gap_v    <- 1.40   # ↑ (antes 1.25) para dar aire con la letra más grande
pad_header <- 0.25
pad_item   <- 0.18
radius_pt  <- 7

# Posiciones base de columnas
col_x <- (seq_along(areas) - 1) * gap_col

# Preparar data de cabeceras e items
make_column <- function(i, info, y_start){
  x <- col_x[i]
  lab_head <- paste0(
    "<span style='color:white'><b>",
    str_replace_all(str_wrap(info$titulo, width = wrap_header), "\n", "<br>"),
    "</b><br>",
    str_replace_all(str_wrap(info$responsable, width = wrap_header), "\n", "<br>"),
    "</span>"
  )
  df_head <- tibble(
    tipo = "header",
    x = x, y = y_start,
    label = lab_head,
    fill = info$color,
    label_colour = "#333333"
  )
  n <- length(info$miembros)
  if (n > 0) {
    ys <- y_start - seq_len(n) * gap_v
    labs_items <- vapply(info$miembros, function(s) str_wrap(s, width = wrap_item), character(1))
    df_items <- tibble(
      tipo = "item",
      x = x, y = ys,
      label = labs_items,
      fill = "white",
      label_colour = "#333333"
    )
    bind_rows(df_head, df_items)
  } else df_head
}

top_y <- 0
col_dfs <- lapply(seq_along(areas), function(i) make_column(i, areas[[i]], y_start = top_y))
boxes <- bind_rows(col_dfs)

# Puntos separadores
sep_points <- boxes %>%
  group_by(x) %>%
  arrange(desc(y)) %>%
  mutate(y_next = lead(y)) %>%
  filter(!is.na(y_next)) %>%
  transmute(x = x, y = (y + y_next)/2)

# INVESTIGACIÓN: lista de nombres
resp_nombres <- sapply(areas, function(a) sub("\\n.*$", "", a$responsable))
miembros     <- unlist(lapply(areas, `[[`, "miembros"))
nombres_invest <- unique(c(resp_nombres, miembros))
nombres_wrapped <- str_wrap(paste(nombres_invest, collapse = ", "), width = 90)

# Posición INVESTIGACIÓN (subida)
inv_x <- mean(range(col_x))
inv_offset <- 1.0
inv_y_header <- min(boxes$y) - inv_offset
inv_y_body   <- inv_y_header - gap_v

df_invest <- tibble(
  tipo = c("inv_header","inv_body"),
  x = c(inv_x, inv_x),
  y = c(inv_y_header, inv_y_body),
  label = c(
    paste0("<span style='color:white'><b>", titulo_investigacion, "</b></span>"),
    nombres_wrapped
  ),
  fill = c(color_investigacion, "white"),
  label_colour = c("#333333", "#333333")
)

# ======= PLOT =======
g <- ggplot() +
  ggtext::geom_richtext(
    data = boxes %>% filter(tipo == "header"),
    aes(x = x, y = y, label = label),
    fill = boxes$fill[boxes$tipo == "header"],
    label.colour = boxes$label_colour[boxes$tipo == "header"],
    colour = NA,
    label.padding = unit(pad_header, "lines"),
    label.r = unit(radius_pt, "pt"),
    size = size_header, lineheight = 1.0
  ) +
  ggtext::geom_richtext(
    data = boxes %>% filter(tipo == "item"),
    aes(x = x, y = y, label = label),
    fill = "white",
    label.colour = "#333333",
    colour = "#222222",
    label.padding = unit(pad_item, "lines"),
    label.r = unit(radius_pt, "pt"),
    size = size_item, lineheight = 1.0
  ) +
  geom_point(
    data = sep_points, aes(x = x, y = y),
    colour = "grey55", size = 1.7
  ) +
  ggtext::geom_richtext(
    data = df_invest %>% filter(tipo == "inv_header"),
    aes(x = x, y = y, label = label),
    fill = color_investigacion,
    label.colour = "#333333",
    colour = NA,
    label.padding = unit(pad_header, "lines"),
    label.r = unit(radius_pt, "pt"),
    size = size_inv_header
  ) +
  ggtext::geom_richtext(
    data = df_invest %>% filter(tipo == "inv_body"),
    aes(x = x, y = y, label = label),
    fill = "white",
    label.colour = "#333333",
    colour = "#222222",
    label.padding = unit(0.22, "lines"),
    label.r = unit(radius_pt, "pt"),
    size = size_inv_body, lineheight = 1.05
  ) +
  coord_equal(
    xlim = c(min(col_x) - 4, max(col_x) + 4),
    ylim = c(min(df_invest$y) - 1.0, top_y + 2.7),
    expand = FALSE
  ) +
  theme_void(base_size = 12) +
  theme(plot.background = element_rect(fill = "#F7F7F7", colour = NA),
        plot.margin = margin(20, 30, 20, 30))

g

# ======= EXPORTAR =======
svglite::svglite("organigrama_unirtv.svg", width = 12, height = 7.5)
print(g)
dev.off()
ggsave("organigrama_unirtv.png", g, width = 12, height = 7.5, dpi = 300)