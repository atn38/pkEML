% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_coverage_tax.R
\name{parse_taxonomic_classification}
\alias{parse_taxonomic_classification}
\title{Recursively parse taxonomicClassification nodes}
\usage{
parse_taxonomic_classification(x, i, j)
}
\arguments{
\item{x}{(list) one taxonomicClassification node}

\item{i}{(numeric) a number denoting the position of the given taxonomicClassification within the big tree}

\item{j}{(numeric) another number}
}
\value{
(data.frame) parsed node
}
\description{
Recursively parse taxonomicClassification nodes
}
\details{
Will keep calling itself on child taxonomicClassification nodes, until there are no more
}
