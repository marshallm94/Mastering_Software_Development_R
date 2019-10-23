library(dplyr)
library(tidyr)
library(readr)

make_LD <- function(data_frame) {
	object <- structure(data_frame, class = c('LongitudinalData','data.frame'))
	return(object)
}

print.LongitudinalData <- function(x){
	return(paste("Longitudinal dataset with", length(unique(x$id)), "subjects."))
}

make_subject <- function(x, id) {
	stopifnot(class(x) == c("LongitudinalData", "data.frame"),
			  class(id) == "numeric")
	object <- structure(x[x$id == id,],
						list(id = id),
						class = 'subject')
	return(object)
}

subject <- function(x, id) UseMethod("subject")

subject.LongitudinalData <- function(x, id) {
	stopifnot(class(x) == c("LongitudinalData", "data.frame"),
			  class(id) == "numeric")
	if (!id %in% unique(x$id)) {
		return(NULL)
	} else if (id %in% unique(x$id)) {
		object <- make_subject(x, id)
		return(object)
	}
}

print.subject <- function(x) {
	stopifnot(class(x) == 'subject')
	return(paste("Subject ID:", x$id))
}

make_visit <- function(x) {
	object <- structure(x, class = 'visit')
	return(object)
}

make_room <- function(x) {
	object <- structure(x, class = 'room')
	return(object)
}

summary.LongitudinalData <- function(x) {
	data$data_frame[data$data_frame$id == subject_id,] %>%
		group_by(visit, room) %>%
		summarize(mean = mean(value)) %>%
		spread(key=room, value=mean)
}
