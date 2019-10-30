library(dplyr)
library(tidyr)
library(readr)

make_LD <- function(data_frame) {
 object <- structure(data_frame, class = c('LongitudinalData','data.frame'))
 return(object)
}

make_subject <- function(x, subject_id) {
 object <- structure(filter(x, id == subject_id), class = c('subject', 'data.frame'))
 return(object)
}

print.subject <- function(x) {
 return(paste("Subject ID:", unique(x$id)))
}

summary.LongitudinalData <- function(x) {
 x[x$id == subject_id,] %>%
  group_by(visit, room) %>%
  summarize(mean = mean(value)) %>%
  spread(key=room, value=mean)
}

summary.subject <- function(x) {
 x %>%
  group_by(visit, room) %>%
  summarize(mean = mean(value)) %>%
  spread(key=room, value=mean)
}

subject <- function(x, id) UseMethod("subject")

subject.LongitudinalData <- function(x, subject_id) {
 if (!subject_id %in% unique(x$id)) {
  return(NULL)
 } else if (subject_id %in% unique(x$id)) {
  object <- make_subject(x, subject_id)
  return(object)
 }
}

print.LongitudinalData <- function(x){
 return(paste("Longitudinal dataset with", length(unique(x$id)), "subjects."))
}

visit <- function(x, visit_id) UseMethod("visit")

visit.subject <- function(x, visit_id) {
 if (!visit_id %in% unique(x$visit)) {
  return(NULL)
 } else if (visit_id %in% unique(x$visit)) {
  object <- make_visit(x, visit_id)
  return(object)
 }
}

make_visit <- function(x, visit_id) {
 object <- structure(filter(x, visit == visit_id), class = c('visit', 'data.frame'))
 return(object)
}

room <- function(x, room_id) UseMethod("room")

make_room <- function(x, bedroom_id) {
 object <- structure(filter(x, room == bedroom_id), class = c('room', 'data.frame'))
 return(object)
}

room.visit <- function(x, room_id) {
 if (!room_id %in% unique(x$room)) {
  return(NULL)
 } else if (room_id %in% unique(x$room)) {
  object <- make_room(x, room_id)
  return(object)
 }
}

print.room <- function(x) {
 id <- unique(x$id)
 visit <- unique(x$visit)
 room <- unique(x$room)
 cat(
   paste(
     paste("ID:", id),
     paste("Visit:", visit),
     paste("Room:", room, "\n"), sep = "\n")
 )
}

summary.room <- function(x) {
 summary(x$value)
}

