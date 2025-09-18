# Script de prueba para verificar la detección de duplicados
areas <- list(
  list(
    titulo = "ÁREA DE CONTENIDOS",
    responsable = "Inma Berlanga",
    miembros = c("Alicia Moreno", "Isabel de Azcárraga", "Pavel Sidorenko"),
    color = "#FC8D62"
  ),
  list(
    titulo = "ÁREA DE DESARROLLO",
    responsable = "Isabel de Azcárraga",
    miembros = c("Rubén Ortega", "Brenda Vázquez"),
    color = "#8DA0CB"
  ),
  list(
    titulo = "ÁREA DE COMUNICACIÓN",
    responsable = "Pavel Sidorenko",
    miembros = c("María Abellán", "Javi Cantón"),
    color = "#66C2A5"
  )
)

# Simular la lógica del script original
resp_nombres <- sapply(areas, function(a) sub("\\n.*$", "", a$responsable))
miembros     <- unlist(lapply(areas, `[[`, "miembros"))
nombres_invest <- unique(c(resp_nombres, miembros))

cat("Responsables:\n")
print(resp_nombres)
cat("\nMiembros:\n")
print(miembros)
cat("\nNombres únicos para investigación:\n")
print(nombres_invest)
cat("\n¿Hay duplicados?\n")
cat("Longitud original:", length(c(resp_nombres, miembros)), "\n")
cat("Longitud única:", length(nombres_invest), "\n")
cat("Duplicados eliminados:", length(c(resp_nombres, miembros)) - length(nombres_invest), "\n")
