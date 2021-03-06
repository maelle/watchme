% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summaryEventTable.R
\name{watchme_summarize_events}
\alias{watchme_summarize_events}
\title{Creates a table with summary statistics for event of each (sub)category.}
\usage{
watchme_summarize_events(eventTable)
}
\arguments{
\item{eventTable}{a table of events created with the\code{watchme_aggregate} function (or having the same structure).}
}
\value{
A data table with the (sub)category, the number of identified events, the average number of pictures, and the average duration in seconds.
}
\description{
Creates a table with summary statistics for event of each (sub)category.
}
\examples{
data('coding_example')
eventTable <- watchme_aggregate(df = coding_example)
watchme_summarize_events(eventTable)
}
