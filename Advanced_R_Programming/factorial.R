# loop version of factorial
Factorial_loop <- function(n) {
	out = 1
	if (n == 0) {
		return(out)
	}
	for (i in 1:n) {
		out = out * i
	}
	return(out)
}

# reduce() version of factorial
Factorial_reduce <- function(v) {
	v[v == 0] <- 1
	Reduce(function(x, y) {x * y}, v)
}


# recursive version of factorial
Factorial_func <- function(n) {
	if (n == 0) {
		return(1)
	} else {
		return(n * factorial(n-1))
	}
}

# memoization version of factorial
factorial_table <- c(1,2,rep(NA, 98))
Factorial_mem <- function(n) {
	if (n == 0) {
		return(1)
	}
	if (!is.na(factorial_table[n])) {
		factorial_table[n]
	} else {
		factorial_table[n] <<- n * Factorial_mem(n-1)
		factorial_table[n]
	}
}

library(microbenchmark)
file.create('benchmark_results.txt')
write.table(summary(microbenchmark(Factorial_loop(0),
								   Factorial_reduce(0),
								   Factorial_func(0),
								   Factorial_mem(0))
					),
			file = 'benchmark_results.txt',
			sep = ",",
			row.names = FALSE
)

write.table(summary(microbenchmark(Factorial_loop(15),
								   Factorial_reduce(1:15),
								   Factorial_func(15),
								   Factorial_mem(15))
					),
			file = 'benchmark_results.txt',
			sep = ",",
			append = TRUE,
			col.names = FALSE,
			row.names = FALSE
)

write.table(summary(microbenchmark(Factorial_loop(50),
								   Factorial_reduce(1:50),
								   Factorial_func(50),
								   Factorial_mem(50))
					),
			file = 'benchmark_results.txt',
			sep = ",",
			append = TRUE,
			col.names = FALSE,
			row.names = FALSE
)
