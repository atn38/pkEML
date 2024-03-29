% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/import_corpus.R
\name{import_corpus}
\alias{import_corpus}
\title{Import a corpus of EML documents from a folder of .xml files.}
\usage{
import_corpus(path, revision_pk = F)
}
\arguments{
\item{path}{(character) Path to directory containing EML documents in .xml file format. Each document in the directory should have a unique packageId (e.g. "knb-lter-mcr.1.1" should only occur once). If there are duplicates, the output tables will have duplicated values in the identifying columns (scope, id, revision), which will result in error should you try and import the tables into a relational database system and assign primary keys.}

\item{revision_pk}{(boolean) Defaults to FALSE. TRUE/FALSE whether you want to log more than one revision of the same data package in a relational database downstream, or in other words, would revision be a part of the primary key in your system later? For example, "knb-lter-mcr.1" is a unique package, and "knb-lter-mcr.1.1" is a unique revision of the former). This setting does not change any output from pkEML. If TRUE, pkEML only warns the user at import if the packageIds in your corpus contain revisions from the same data package and advises removal before proceeding. If FALSE, pkEML warns the user at import if the packageIds including revision in the corpus are not all unique and advises removal before proceeding.}
}
\value{
List of EML documents represented in the EMLD (JSON-LD) format. Each child in the list is named according to the package ID listed in EML, e.g. "knb-lter-mcr.1.1".
}
\description{
Import a corpus of EML documents from a folder of .xml files.
}
