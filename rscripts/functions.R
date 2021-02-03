### -----------------------------------------------------------
### Collection of generic functions useful in data processing
### -----------------------------------------------------------

#### Get boundaries
f_get_admin_df <- function(admin_sp) {
  admin_sp$area_sqkm <- area(admin_sp) / 1000000
  cents <- coordinates(admin_sp)
  cents_sp <- SpatialPointsDataFrame(coords = cents, data = admin_sp@data, proj4string = CRS(proj_str))
  cents_name <- over(cents_sp, admin_sp)
  admin_df <- as.data.frame(cents_sp)

  admin_df <- admin_df %>%
    dplyr::select(starts_with("NAME"), "GID_0", "coords.x1", "coords.x2", "area_sqkm") %>%
    dplyr::rename("cent_long" = coords.x1, "cent_lat" = coords.x2)

  return(admin_df)
}


#### Helper functions
#' f_compareNames
#'
#' @description Comparing two character strings, does not return an objects but prints non-matches to the console
#'
#' @param A
#' @param B
#' @param showNames c("none","both","AB", "BA")
#'
#' @example
#' f_compareNames(A=c("Hello","beautiful","world","!"), B=c("Hello","amazing","world"), showNames="both")
#'
f_compareNames <- function(A, B, showNames = "none") {
  A <- unique(as.character(A))
  B <- unique(as.character(B))

  AinB <- which(A %in% B)
  BinA <- which(B %in% A)

  AnotinB <- which(!(A %in% B))
  BnotinA <- which(!(B %in% A))

  print(paste0("A in B n= ", length(AinB)))
  print(paste0("B in A n= ", length(BinA)))

  print(paste0("A not in B n= ", length(AnotinB)))
  print(paste0("B not in A n= ", length(BnotinA)))

  if (showNames == "both") {
    print(paste0("A not in B: "))
    print(A[AnotinB])

    print(paste0("B not in A: "))
    print(B[BnotinA])
  }
  if (showNames == "AB") {
    print(paste0("A not in B: "))
    print(A[AnotinB])
  }
  if (showNames == "BA") {
    print(paste0("B not in A: "))
    print(B[BnotinA])
  }

  # outlist = list("A"=A,"B"=B,"AinB"=AinB, "BinA"=BinA, "AnotinB"=AnotinB, "BnotinA"=BnotinA)
}


f_mergevars <- function(datX, datY) {
  mergevars <- colnames(datX)[colnames(datX) %in% colnames(datY)]
  return(mergevars)
}


f_addVar <- function(datX, datY, allX = TRUE) {
  nrowB <- dim(datX)[1]
  mergevars <- f_mergevars(datX, datY)

  out <- dplyr::left_join(datX, datY, by = mergevars, all.x = TRUE)

  if (dim(out)[1] != nrowB) warning("Number of rows do not match")
  message(paste0("Message: x nrow= ", dim(out)[1], " and y nrow=", dim(datX)[1], "\n Number of variables added: ", dim(out)[2] - dim(datX)[2]))

  return(out)
}
