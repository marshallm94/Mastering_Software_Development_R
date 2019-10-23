library(dplyr)
library(tidyr)
library(readr)

make_LD <- function(data_frame) {
	object <- structure(data_frame, class = c('LongitudinalData','data.frame'))
	return(object)
}

make_subject <- function(x, subject_id) {
	stopifnot(class(x) == c("LongitudinalData", "data.frame"),
			  class(subject_id) == "numeric")
	object <- structure(list(id = subject_id,
							 subset = x[x$id == subject_id,]),
						class = 'subject')
	return(object)
}

print.subject <- function(x) {
	return(paste("Subject ID:", x$id))
}

summary.subject <- function(x) {
	x$subset %>%
		group_by(visit, room) %>%
		summarize(mean = mean(value)) %>%
		spread(key=room, value=mean)
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

print.LongitudinalData <- function(x){
	return(paste("Longitudinal dataset with", length(unique(x$id)), "subjects."))
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
	x[x$id == subject_id,] %>%
		group_by(visit, room) %>%
		summarize(mean = mean(value)) %>%
		spread(key=room, value=mean)
}
