#' handles instances where there are multiple in a list and collapses them int a string
#' @param x
#' @param paste

handle_multiple <- function(x, paste = T) {
  if (paste) {
    if (is.list(x) && length(x) > 0) return(paste(sapply(x, paste, collapse = " "), collapse = " "))
    else return(x)
  } else return(x)
}


#'
#'
#'
#'

# write a thing to

handle_one <- function(x) {
  if (!is.null(names(x))) x <- list(x)
  return(x)
}


msgout <- function(out) {
  message(paste("    Returning", nrow(out), "rows."))
}


#' @param x

null2na <- function(x) {
  if (is.null(x)) return(NA)
  # account for when the element is present but empty or there are orphan closing tags
  else if (is.list(x) & length(x) == 0) return(NA)
  else if (is.character(x) && length(x) == 1 && trimws(x) == "") return(NA)
  else return(x)
}


#' Parse packageId
#' @description Take the packageId field in EML and break it down into scope, id, and revision number. If packageId does not conform to the scope, id, revision number pattern, the function will just return the whole ID in the "id" field and NAs in the "scope" and "rev" fields.
#'
#' @param full_id (character) Package ID in EML style, e.g. "knb-lter-mcr.1.1"
#' @return List of three named items: "scope", "id", "rev".
#' @importFrom stringr str_extract

parse_packageId <- function(full_id) {
  stopifnot(is.character(full_id), length(full_id) == 1)
  if(!grepl("[^A-Za-z0-9 . -]", full_id) && # check that string only has A-Z, a-z, numeric, dashes, and periods
     nchar(gsub("[^.]", "", full_id)) == 2  && # check that string has exactly two periods
     !startsWith(full_id, ".") && # doesnt start with a period
     !endsWith(full_id, ".") # doesnt end with a period
     ) {
    x <- list(
      scope = sub("\\..*$", "", full_id), # string before first period
      datasetid = stringr::str_extract(full_id, "(?<=\\.)(.+)(?=\\.)"), # number between the two periods
      rev = sub(".*\\.", "", full_id) # number after second period
    )
  } else x <- list(scope = NA,
                   datasetid = full_id,
                   rev = NA)

  return(x)
}

#' A generic parse function
#'
#' @param x (list) node to parse
#'
#' @return (data.frame) Parsed node
#' @export
#'
#' @examples
parse_generic <- function(x){

  unlisted <- unlist(x,
                     recursive = TRUE,
                     use.names = TRUE)
  names(unlisted) <- gsub(".+\\.+",
                          "",
                          names(unlisted))
  as.data.frame(t(unlisted))
}

# parse_generic <- function(x) {
#   df <- data.frame()
#   if (!is.list(x)) {
#
#   } else {
#   for (i in seq_along(x)) {
#     if (!is.null(names(x)[[i]])) {
#       df <- data.table::rbindlist(lapply(seq_along(x[[i]]), function(y){
#         parse_generic(x[[i]])
#       }))
#     } else {
#       unlisted <- unlist(x[[i]],
#                          recursive = FALSE,
#                          use.names = TRUE)
#       names(unlisted) <- gsub(".+\\.+",
#                               "",
#                               names(unlisted))
#       as.data.frame(t(unlisted))
#     }
#   }
#   }
# }

#' Parse textType node
#'
#' @param x (list or character) text node
#'
#' @return
#'
#' @examples
parse_text <- function(x) {
  try({
    a <- type <- NA
    if (is.character(x)) {
      a <- x
      type <- "plaintext"
    }
    if (is.list(x)) {
      if ("markdown" %in% names(x)) {
        a <- as.character(x[["markdown"]])
        type <- "markdown"
      } else {
        a <- a[!names(a) %in% c("@context", "@type")]
        a <- as.character(emld::as_xml(x))
        a <- gsub("<?xml version=\"1.0\" encoding=\"UTF-8\"?>", "", a)
        a <- stringr::str_remove(a, ".*xsd\">")
        a <- stringr::str_remove(a, "</eml:eml>")
        substr(a, 1, 40) <- ""
        type <- "docbook"
      }
    } else {
      a <- as.character(x)
    }
    return(list(text = a, type = type))
  })
}
#' Check if chain of descending element names is present in node
#'
#' @param x (list) node to check
#' @param element_names (character) Name or vector of descending names to check
#'
#' @return (logical) TRUE if chain of element names are present in the node in that order, FALSE if not.
#'
#' @examples
recursive_check <- function(x, element_names) {
  stopifnot(is.list(x), is.character(element_names))
  check <- TRUE
  for (i in seq_along(element_names)) {
    if (i == 1) {
      if (!element_names[[1]] %in% names(x))
        check <- FALSE
    }
    else {
      if (!element_names[[i]] %in% names(x[[element_names[1:(i - 1)]]]))
        check <- FALSE
    }
  }
  return(check)
}


#' Remove context
#'
#' @param x
#'
#' @return
#' @examples
remove_context <- function(x){


}

#' resolve reference in a node
#'
#' @param x (list) node of element
#' @param eml (list) full EML document
#' @param element_name (character) name of element
#'
#' @return (list) If the node contains a reference to some other element in the document, the function returns the same node, just with the reference replaced by the contents of the referenced node. If not, this returns the exact same node and does nothing to it.
#'
#' @examples
resolve_reference <- function(x, element_name, eml) {
  if ("references" %in% names(x)) {
    ref <- x$references
    allx <- EML::eml_get(eml, element_name)
    for (i in seq_along(allx)) {
      xi <- handle_one(allx[[i]])
      for (j in seq_along(xi)) {
        xj <- xi[[j]]
        if ("id" %in% names(xj)) {
          if (xj$id == ref) {
            x <- xj
            break
          }
        }
      }
    }
  }
  return(x)
}

#' Resolve all references in a EML document
#'
#' @param eml full EML document
#'
#' @return (list) full EML document with all references resolved and replaced with each respective referenced node
#' @export
#'
#' @examples
resolve_reference_all <- function(eml) {
  rrapply::rrapply(
    object = eml,
    f = function(x, .xname) {
      if (!is.null(.xname)) {
        resolve_reference(x = x,
                          element_name = .xname,
                          eml = eml)
      }
    }
    ,
    how = "recurse",
    classes = "list"
  )
}
