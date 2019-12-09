# Course: The R Programming Environment

In R, it is important to recognize that there are differences betweent the R
object itself and what is actually printed to the console. There are many
functions in R that print in a very "human-intuitive" manner, with bells and 
whistles that aren't part of the R object itself.

There are 5 "atomic" classes in R:
1. character
2. numeric
3. integer
4. complex
5. logical/boolean

Vectors in R can only contain objects of the same class (lists being the
exception to the rule).

Number in R are generally double precision floating point numbers,
even if they are represented as integers (i.e. a `1` is actually a `1.00`). If
you would specifically like an integer, you must specify the 'L' suffix:

```R
# x is a numeric object (double float)
x <- 1

# x is an integer
x <- 1L
```

the `c()` function (*concatenate*) is used to create vectors. `vector()` also
works to initialize vectors. Note that R will implicitly coerce objects to the
necessary class to keep vectors homogeneous. For example:

```R
x <- c(1, 2, TRUE)
# casts TRUE to its numeric equivalent, 1
> x
[1] 1 2 1
```

If a character is in the vector, all objects will be cast to characters (serves
as the "catch all" class.) If R can't figure out how to coerce objects into a
homogeneous class, NAs could be introduced. Objects can be explicitly coerced
to the desired class using the `as.<desired_class>()` functions, if available.

**You can find the attributes of an object using the `attributes()` function**,
which can be useful when working with R interactively to determine what is
printed to the console for the users convenience vs. what will actually be
available to you in a script/program. Note that **not all objects have attributes**.

```R
m <- matrix(1:6, nrow = 2, ncol = 3) 
m
     [,1] [,2] [,3]
[1,]    1    3    5
[2,]    2    4    6
dim(m)
[1] 2 3
attributes(m)
$dim
[1] 2 3
```

Matrices are constructed column-wise (start at X[1,1] fill all column 1, then
move to top of column 2, etc.) Vectors can be made into matrices by giving them
a `dim()` attribute:

```R
m <- 1:10 
m
 [1]  1  2  3  4  5  6  7  8  9 10
dim(m) <- c(2, 5)
m
     [,1] [,2] [,3] [,4] [,5]
[1,]    1    3    5    7    9
[2,]    2    4    6    8   10
```
**Lists** can contain objects of different classes (similiar to Python) and can
be created with the `list()` function. To access an element within a list, you
must use the syntax `<list_name>[<index>][[1]]`.

**Factors** are used to represent categorical data (i.e. attributes that would
be one hot encoded) and they can be ordered or unordered. **The order of the
levels in a factor can be set using the `levels` argument** - this can be useful
for modeling purposes (when plotted, factors are plotted according to their 
levels).

**Missing values** can be eithere NA or NaN (Not a Number). **A NaN value is
also a NA value but a NA value is not a NaN value**. To test for NA/NaNs, use
`is.na()` and `is.nan()` respectively.

"Data frames are represented as a special type of list where every element of
the list has to have the same length. Each element of the list can be thought
of as a column and the length of each element of the list is the number of rows."

To convert a data frame to a a matrix, use `data.matrix()` instead of `as.matrix()`.

The `names()` function can be used to add names to objects, making code more
readable in the context of the problem domain. While matrices use `colnames()`
and `rownames()` to set names, data frames use `names()` for the column names
and `row.names()` for the row names.

# Tidyverse

"Tidy" data, is the unifying concept of the tidyverse and is deifned as:

1. Each variable forms a column.
2. Each observation forms a row.
3. Each type of observational unit forms a table.

The [tidyverse](https://www.tidyverse.org/) is composed of multiple
[packages](https://www.tidyverse.org/packages/), the "big 3" being:

* ggplot2 - Plotting package
* tidyr - A package that helps you "get to" tidy data.
* dplyr - A package of (fast) functions that assist in working with data frames
(data that is already "tidy")

## readr

`read_csv()` is the defacto function for reading tabular data. Generaly, you
should explicitly set the type of each column using the `col_types` argument,
however, this isn't necessary (doing so could be a good way of catching any
errors at the outset that could manifest later on and become hardert to deal
with).

Column types can be specified in a more explicit manner using `readr`s column
specific functions such as `col_date(), col_double(), col_factor()`, etc.

`read_csv()` can also read compressed/zipped data without need it be
decompressed/unzipped.

### Web-Based Data

Using an API means the general rule of thumb is RTFM, however if the API's
manual isn't great, you can experiment by clicking through various parameter
options on the website and looking at the URL for what is being sent to the
server.

When requesting data from an API, you should store the API key in a file in the
home directory of your machine called `.Renviron`. This file should be a plain
text file and **must** end in a blank line. An example would be:

```txt
MY_API_KEY = "this_is_an_example"
# keep the line below empty

```

Once this is done, you can acess that variable within R using the `Sys.getenv()`
function, assign it to a variale and use it as you please.

**GET requests can be sent using the `GET()` function that is part of the `httr`
package.**

The `rvest` package has some good functions for dealing with data that was
scraped from some webpage. Data that is scraped from the web will usually come
in the form of JSON, XML or HTML and is usually parsed into a list in R (due
to the flexibility of that class). `jsonlite` and `xml2` are two example packages
for this process.

The logical operator "or" is expressed with a single pipe `|` or a double pipe
`||` (for the non-vectorized version). The logical operator "and" is expressed
with `&` or the double ampersand `&&` (for the non-vectorized version). Check
[this stack overflow post][https://stackoverflow.com/questions/6558921/boolean-operators-and]
on when to use which. **All AND operators are evaluated before OR operators**.
R has the function `xor()` for the exclusive OR operator.

**R uses one-based indexing (as opposed to zero-based indexing like Python)**

## dplyr/tidyr

**The `%>%` operator is a hallmark of the tidyverse and is used to chain actions
together (analogous to the '|' pipe in Linux/Unix systems).** The operator passes
the output of the function before it as the first argument to the function on the
after it.

The `summarize()` function is one of the main functions that can be used for
EDA and is used in the following manner:

```R
<data_object> %>%
  summarize(n_obs = n(),
            <output_attribute_name1> = max(<input_variable>),
            <output_attribute_name2> = min(<input_variable>))
```

You can use the `group_by()` prior to using the `summarize()` function to get
summary statistics based on some stratification of the data:


```R
<data_object> %>%
  group_by(<factor_variable>) %>%
  summarize(n_obs = n(),
            <output_attribute_name1> = max(<input_variable>),
            <output_attribute_name2> = min(<input_variable>))
```

`select()` can be used to select a subset of the columns while `filter()` can
be used to create subset of the observations. `filter()` can be used with the
expected logical operators based on the possible values within a given column
and there are various functions such as `starts_with(), ends_with(), contains()`
etc. that can be used within `select()` instead of writing out all the names of
the desired columns (especially useful in high-dimensional space). Note that
filtering or the data (by observations using `filter()` or by columns using
`select()`) can be performed before or after the `summarize()` function is used.

"If you are trying to check if one thing is equal to one of several things, use
the `%in%` operator instead of the equality operator (`==`)."

The `mutate()` from dplyr is used to add/change columns to a tibble (a version
of data frames). The `rename()` function is used to rename columns.

The `gather()` function can be used to gather information that is spread across
multiple attributes into one attribute. The `spread()` function is less
common but can be used in a similar way that `table(<variable_1>, <variable_2>)`
would be used.

**Merging data** can be used with the `left_join(), right_join(), inner_join(),
full_join()` functions, which have the expected 'SQL-esque' joining logic. When
merging data frames, it is best if the attributes are being joined on are the
same class.

"Remember that if you are using piping, the first data frame (“left” for these 
functions) is by default the dataframe created by the code right before the pipe.
**When you merge data frames as a step in piped code, therefore, the “left” data
frame is the one piped into the function while the “right” data frame is the
one stated in the `*_join()` function call."**

The `unite()` function can be used (unsurprisingly) combine multiple columns
into one column.

## Dates & Times with lubridate

The `lubridate` package (also a part of the tidyverse) is the de facto package
for working with dates and times. There are various functions that can convert
character objects into the POSIXlt and POSIXct datetime classes such as
`ymd_hm(), ymd_hms()` etc. Converting date attribute to the appropriate class
is worthwile in that it allows other functions to easily pull various 'components'
out of the the object. Some example functions are:

* `year(<datetime_variable>)`
* `months(<datetime_variable>)`
* `mday(<datetime_variable>)`
* `wday(<datetime_variable>)`
* `weekdays(<datetime_variable>)`
* `hour(<datetime_variable>)`
* `minute(<datetime_variable>)`
* `second(<datetime_variable>)`

The `with_tz()` can be used to work with timezones. It takes a time from UTC
to the desired time zone.

More info can be found by downloading the PDF [here](https://www.jstatsoft.org/article/view/v040i03).

Using the `summary(<data_frame>)` function shows the distribution of data for
each attribute in the `<data_frame>`.

**If you installed R/RStudio using Anaconda, downloading packages from CRAN
can prove troublesome. If that doesn't work, try `conda search -f r-<package_name>`
to see if Anaconda has that package. If it does, install using
`conda install -c r r-<package_name>`.

# Text Processing

The `nchar()` function will return the number of characters in a string variable.
`toupper()` and `tolower()` have the expected affect on string variables.

## Regex Expressions

`grepl()` takes two arguments, a string ana a regular expression, and return
`TRUE` or `FALSE` depending on if a match is made (think "grep *logical*").

Metacharacters:

* `.` - Any character (other than a new line).
* `+` - One or more of the preceding expression.
* `*` - Zero or more of the preceding expression.
* `{}` - How many times should the preceding expression occur:
	* `{n}` - Preceding expression occurs *n* times.
	* `{n,m}` - Preceding expression occurs between *n* and *m* times.
	* `{n,}` - Preceding expression occurs *at least n* times.
* `()` - Used to create a capturing group:
	* `"(abc){2,}"` - Search for the string "abd" at least 2 times.
* `\\w` - The 'words' character set, which specifies any letter, digit, or an
underscore. The complement of this character set is `\\W` - **not** words.

	* Example:
	```R
	grepl("\\w", "abcdefghijklmnopqrstuvwxyz")

	[1] TRUE

	grepl("\\W", "abcdefghijklmnopqrstuvwxyz")

	[1] FALSE
	```

* `\\d` - The 'digits' character set, which specified any digits 0 - 9. The
complement of this charcter set is `\\D` - **not** digits.

	* Example:
	```R
	grepl("\\d", "abcdefghijklmnopqrstuvwxyz")

	[1] FALSE

	grepl("\\D", "abcdefghijklmnopqrstuvwxyz")

	[1] TRUE
	```

* `\\s` - The 'whitespace' character set, which specifies any whitespace
characters such as tabs, spaces, line breaks, etc. The complement of this
character set is `\\S` - **not** whitespace.

	* Example:
	```R
	grepl("\\s", "\n\n  \t")

	[1] TRUE

	grepl("\\S", "\n\n  \t")

	[1] FALSE
	```

* `[]` - Used to specify a custom character set. If you want to search for 
a moderately large set of order characters, use the hyphen `-`. For example,
`grepl('[a-d]', 'string')` searches for any of the characters between `a` and `d`.
* `^` - The negation symbol in regex (i.e. `grepl('[^a]', 'string')` searches for
**not** 'a' in the string 'string'). **Must be used in brackets.**
* `\\` - The escape charcters in order to enable the search of metacharacters
as strings. i.e. `grepl('\\.', 'string.')` - search for the period in 'string.'
* `^` - The start of the line symbol.
* `$` - The end of the line symbol.
* `|` - The OR metacharacter - i.e. `grepl('abc|cba', 'string')` search for 'abc'
or 'cba' in 'string'.

![](images/regex_characters.png)

## Regex Functions

`grep()` - Returns the indices of the matches.
`sub()` - Replaces **a** matches to a regex with replacement.
`gsub()` - Replaces **all** matches to a regex with replacement.
`strsplit()` - Splits a string pased on a regex.

## stringr package (Tidyverse)

Most functions in the stringr package start with `str_*`, i.e. `str_extract(),
str_order(), str_pad()` etc. Most of the functions also have the string argument
as the first argument and the regex as the second argument.

# Physical Memory in R

The pryr package has various functions that are useful in understanding the
memory that the current R session is working with (most notable `mem_used()`).

Use the `object.size(<object_name>)` function to see how much memory an object
is using. The pryr package also has a function for this - `object_size()`.
To see the top N objects that are occupying the most memory:

`sapply(ls(), function(x) object.size(get(x))) %>% sort %>% tail(N)`

The `rm()` function can be used to delete object and free up memory. The
`mem_change(rm())` function can be used in conjunction with `rm()` to see how
much memory was freed up.

In R (appears to be same as C++):

* integers are 4 bytes.
* numerics are 8 bytes (recall numeric == double floating point integer in R).
* characters are 1 byte per character.

R has a garbage collector which runs automatically in the background, however
it can be explicitly called using the `gc()` function.

## Working with Big Data in R

The `fread()` function in the `data.table` package is useful for reading in large
data sets.

**Note that many of the function in the `data.table` package, along with those
in `dplyr` use non-standard evaluation, which will require extra steps when 
employing them in custom packages.**

The `Rcpp` package allows you to write code in C++ and connect it with R (useful
for larger data sets).

Check out [this link](https://cran.r-project.org/web/views/HighPerformanceComputing.html)
for high performance computing (HPC) packages in R.

The `DBI` package is a generic R-to-Database interface (similar to `Rpostgres`).

**The `bigmemory` package (and its associates) can be used to work with data that
is stored on disk as opposed to pullling it into memory.**

# Course: Advanced R Programming

**First and foremost: R is a functional programming language**

Curly braces `{}` are not necessary for one line for loops. Example:

	`for(i in 1:10) print(i)`

`next` is used to go to the next iteration in a loop (analogous to `continue`
in Python). `break` exits loop immediately.

You can write some code (or better yet, a function to put within other functions)
that ensures that the necessary packages are loaded, and if they aren't, installs
them.

```R
check_pkg_deps <- function() {
        if(!require(readr)) {
                message("installing the 'readr' package")
                install.packages("readr")
        }
        if(!require(dplyr))
                stop("the 'dplyr' package needs to be installed first")
}
```

The `require()` function returns `TRUE` or `FALSE` depending on whether a package
can be loaded or not (as opposed to `library()` which returns an error message).

R can partially match parameter names when calling functions.

Use the `args()` function to see the parameters of a functions:

`args(<function_name_without_parens>)`

You can pass functions as arguments to other functions (make sure they are
passed without parenthesis but are called with them within the function).

"Anonymous" functions are those that aren't assigned a name. These should typically
be kept to logic that can fit on one line. The syntax is:

```R
function(x){#do stuff with x}
```

The `...` (ellipses) allows an indefinite number of arguments to be passed to a
function (analogous to `*args` in Python). In order to use the arguments that are
passed to the `...` parameter, simply use the parameter name as you normally would.
**Note that all of the arguments that are passed to `...` will be used wherever
`...` is used in your function; there is no way of separating them out**.


You can make a `list()` have named elements by using the below synatx:

```R
x = list(bing='bong',bloop='floop')

# or...

x = list('bing'='bong','bloop'='floop')

# both of the above are valid and can be accessed using the normal syntax:
x[['bing']]
x[['bloop']]
```

**To make your own binary operator**:

```R
%<operator_symbol>% <- function(left, right) {
	# code that uses the left and right arguments
}

# for example
%p% <- function(left, right){
	paste(left, right, sep = " ")
}
```

## Functional Programming

Functional programming "treats computation as the evaluation of mathematical
functions and avoids changing-state and mutable data."

The `purr` package has many functions centered around functional programming.

the `map_*()` family of functions (in the `purr` package - `map_at(), map_lgl(), map_chr()` etc.)
applies a function to a vector/list and returns a vector/list with element *i* 
of the returned vector/list being the result of putting element *i* of the 
input list as the argument to the function.

Similarly, the `map2_*()` family of functions can map a function onto two vectors
of the same length. The `pmap_*()` family of functions can do the same thing for
an arbitrary number of vectors/lists (the first argument to these functions
is a list of vector/lists).

Contrasting to `map_*()`-esque functions, the `reduce()` function iteratively 
reduces a list/vector down into one element (i.e. the first element is combined
with second element, that combination is combined with the third element, that
combination is combined with the fourth, etc). Example:

```R
reduce(c(1, 3, 5, 7), function(x, y){
  message("x is ", x)
  message("y is ", y)
  message("")
  x + y
})
x is 1
y is 3

x is 4
y is 5

x is 9
y is 7

[1] 16
```

By default, the `reduce()` function starts with the first element and moves to
the last, however the `.dir` parameter allows you to reversed the direction if
desired:

```R
reduce(c(1,2,3,4), <some_function> , .dir = 'backward')

# or ...

reduce(rev(c(1,2,3,4)), <some_function>)
```

The `has_element()` function is used on a vector/list ot see if an element exits.

### Filter Functions

The filter group of functions take a vector/list and a predicate function
(returns TRUE/FALSE based on input) and return a vector of the elements in the 
input vector that meet the criteria. Example:

```R
# using the keep function...
keep(1:20, function(x){
  x %% 2 == 0
})
 [1]  2  4  6  8 10 12 14 16 18 20

# using the discard function (think opposite of keep())...
discard(1:20, function(x){
  x %% 2 == 0
})
 [1]  1  3  5  7  9 11 13 15 17 19
```

**The `compose()` function can be used to combine any number of functions into
one function**

## Recursion

```R
fibonacci <- function(n) {
	stopifnot(n > 0)
	if (n == 1) {
		return(0)
	} else if (n == 2) {
		return(1)
	} else {
		return(fibonacci(n-1) + fibonacci(n-2))
	}
}
```

One way to speed up recursive functions is to take advantage of [memoization](https://en.wikipedia.org/wiki/Memoization)
which stores the result of a recursive function in a table once it has been
calculated. This can drastically decrease computation time for inputs to 
recursive functions that have to go through many iterations of calling themselves.

```R
fib_tbl <- c(0, 1, rep(NA, 23))

fib_mem <- function(n){
  stopifnot(n > 0)
  
  if(!is.na(fib_tbl[n])){
    fib_tbl[n]
  } else {
	# the <<- operator is used to modify objects outside the scope of 
	# the current function
    fib_tbl[n - 1] <<- fib_mem(n - 1)
    fib_tbl[n - 2] <<- fib_mem(n - 2)
    fib_tbl[n - 1] + fib_tbl[n - 2]
  }
}

map_dbl(1:12, fib_mem)
 [1]  0  1  1  2  3  5  8 13 21 34 55 89
```

**The `source(<filepath.R>)` is how you run a script that you are
working on in an interactive R session (or bring functions written in a separate
script into the current namespace).**

The `microbenchmark` package can be used for benchmarking R code performance.

## Expressions and Environments

### Expressions

Using expressions allows you to manipulate code using code:

The `quote()` function is used to create an expression.

The `eval()` function is then used to evaluate the expression created by `quote()`.

You can reverse this process using the `deparse()` function (turns a quoted
expression into its original 'source' code).

### Environments

While most variables you use are part of the global environment (i.e. namespace)
you can create a new environment using the `new.env()` function. Once this is
created, you can assign variables to that environment using the familiar syntax:

```R
data_env <- new.env()
data_env$main_df <- read_csv(<whatever>)

# or...
assign("main_df", read_csv(<whatever>), data_env)
```

To retrieve a variable from an environment you have one of two options:


```R
data_env$main_df

# or...
get("main_df", envir = data_env)
```

The `<<-` is called the *complex assignment operator* and is used to modify
(or even create) variable in the parent environment/namespace (i.e. modify a
global variable within a function).

## Error Handling

There are a few essential functions for handling errors and exceptions in R:

* `stop(<message>)` - Returns and error with <message>.
* `stopifnot(<logical_expression>)` - Stops a program is one of a series of
logical arguments are not met.
* `warning()` - Prints a warning to the console (does **not** stop the execution
of the script).
* `message()` - prints a message to the console.

Checking to ensure the arguments for a function are correct can be accomplished
by using something similar to:

```R
## Check arguments
if(!is.character(arg1))
		stop("'arg1' should be character")
if(!is.character(arg2))
		stop("'arg2' should be numeric")
if(length(arg3) != 1)
		stop("'arg3' should be length 1")
```

The above could (and should) be implement using the `stopifnot()` function above.

**The `tryCatch()` function is the workhorse of handling errors and warnings in R.**

The first argument to `tryCatch()` is *any* R expression, followed by conditions
which specify how to handle an error or warning.

```R
beera <- function(expr){
  tryCatch(expr,
         error = function(e){
           message("An error occurred:\n", e)
         },
         warning = function(w){
           message("A warning occured:\n", w)
         },
         finally = {
           message("Finally done!")
         })
}
```

## Debugging in R

R comes with a few builtin tools to help the debugging process:

* `browser()` - an interactive debugging environment that allows you to step
through code one expression at a time. **Once you are within a "browser() window"
in R, type `c` to exit and return to the normal console**.

* `debug()/debugonce()` - a function that initiates the browser within a function.

* `trace(<function_name_in_quotes>)` - a function that allows you to temporarily insert pieces of code into
a function to modify their behavior.
	* Calling `trace("f")` will print a message to the console everytime the funciton
	`f()` is called.

* `recover()` - a function for navigating the function call stack after a function
has thrown an error.

* `traceback()` - a function that prints out the function call stack after an 
error occurs but does nothing if there is no error.
	* Should be called immediately after an error occurs.

`trace()` is the main function that is used for tracking down bugs in packages
that you did not author.

## Profiling and Benchmarking

Two main benchmarking packages are `microbenchmark` and `profvis`.

The `microbenchmark()` function (within the `microbenchmark` package) will
repeatedly run a section of code multiple times (100 is the default, can be changed
with the `times` parameters) and provide summary statistics on how long the
code took to run. You can include multiple lines of code in the `microbenchmark()`
function, however line must be separated by a comma.

```R
library(microbenchmark)
microbenchmark(a <- rnorm(1000), 
               b <- mean(rnorm(1000)))
Unit: microseconds
                   expr    min      lq     mean median      uq     max
       a <- rnorm(1000) 74.489 75.2365 77.30950 75.656 76.9050  92.557
 b <- mean(rnorm(1000)) 80.306 81.1345 86.85133 81.873 88.7785 129.834
 neval
   100
   100
```

Or, comparing to functions that perform the same task:


```R
record_temp_perf <- microbenchmark(find_records_1(example_data, 27), 
                                   find_records_2(example_data, 27))
record_temp_perf
Unit: microseconds
                             expr      min        lq     mean   median
 find_records_1(example_data, 27)  674.628  704.5445  770.646  719.366
 find_records_2(example_data, 27) 1064.935 1095.5015 1183.014 1131.834
       uq      max neval
  753.949 4016.827   100
 1190.596 4249.408   100
```

The `microbenchmark()` function returned an object that can be plotted using
`autoplot(<output_of_microbenchmark_call>)` (note that `autoplot()` requires
`ggplot2` to be loaded)

###`profvis`

The `profvis()` function (a part of the `profvis`) package is useful for determining
which parts of a function (or piece of code) are bottlenecks. **Requires RStudio**

To use `profvis()` on multiple lines of code, enclose them in curly braces`{}`.

The `profvis()` has two options with which one can profile your code. The
toggle button to choose between these two options will pop up when you profile
your code:

* **Data** option - The data option allows you to view the time usage of each
first level functin call. Each of these calls can be expanded and you can "dig
down" within each function to determine which portions are the bottlenecks.

* **Flame Graph** option - This option opens up two panels. The top panel shows
the code with the memory and time used for that section of code. The bottom panel
also visualized the code but has time on the horizontal axis and shows the full
call stack at each time sample.

Check out the following websites for more info:

* [Sections on Performant Code](http://adv-r.had.co.nz/Performance.html)
* ["FasteR, HigheR, StrongeR"](https://www.noamross.net/archives/2013-04-25-faster-talk/)

Generally, the `microbenchmark()` function should be used for smaller portions
of code, while `profvis()` can be used for more extensive chunks of code.

## Non-standard Evaluation

Many functions within the tidyverse use non-standard evaluation and these should
be avoided when writing functions for other people. **Most tidyverse functions
have a standard evaluation alternative with the same name followed by an
underscore `mutate()` to `mutate_()`.**

To learn more, try [Advanced R](http://adv-r.had.co.nz/Computing-on-the-language.html).

## OOP in R

### S3

S3 and S4 are the "older" OOP frameworks in R, while "RC" (also called "R5") 
is the new system for OOP.

In the S3 system, you can arbitrarily assign a class to any object (goes against
most OOP principals). This is performed using the `structure()` function:

```R
special_char_a <- structure('a', class = 'special_char')
class(special)
```

You can create a constructor (a function that initializes an object of the
designated class) as you would a normal function:

```R
car_s3 <- function(make, model, color, weight, axels=2) {
	structure(list('make'=make,
				   'model'=model,
				   'color'=color,
				   'weight'=weight,
				   'axels'=axels),
			  class = 'car_s3')
}

my_car <- car_s3('toyota','land cruiser','white',6000)
```

To create a method that is associated with an already existing class, you use R's
**generic methods** system.

```R
# creating name of method
<name_of_method> <- function(x) UseMethod("<name_of_method")
```

Note that in the above, `x` is analogous to `self` in Python's OOP framework.

Once the name of the method has been defined, the logic can be written.
**Contrasting Python, R defines methods using `<method_name>.<class_name>`**

```R
# defining name of method
is_SUV <- function(x) UseMethod("is_SUV")

is_SUV.car_s3 <- function(x){
	if (x$weight > 5000) {
		return(TRUE)
	} else if (x$weight <= 5000) {
		return(FALSE)
	}
}

# testing the function on my_car
is_SUV(my_car)
[1] TRUE
```

You can specify a default for a method (in case an object of the wrong class is
passed to the method) using the following syntax:

```R
is_SUV.default <- function(x) {
	return(NA)
}
```

Additionally, you can rewrite generic methods (e.g. `print()`) to handle objects
of your custom class differently:

```R
print.car_s3 <- function(x) {
	cat(x$color, x$make, x$model)
	return(invisible(x))
}
```

**It is convention for `print()` methods to return the object itself invisibly.**
(see above)

The S3 class doesn't have a formal system for defining class attributes, however
a `list()` is the most common way to implement this.

The `summary()` method can also be redefined for user-defined classes however
this method **returns an object of class "summary_<class_name>" by convention**

### S4

Contrary to the S3 system, the S4 system uses the `setClass()` function to create
a new class. This function has three parameters:

1. `Class` - The name of the class as a string.
2. `slots` - A named list of attributes for the class with the class of each
attribute specified.
3. `contains` - (optional) The super-class that the current class inherits from
(if applicable).


```R
setClass("vehicle",
		 slots = list(purpose = 'character',
					  material = 'character',
					  propulsion_system = 'character'))

setClass("car",
		 slots = list(type = 'character',
					  color = 'character',
					  number_wheels = 'numeric',
					  number_seats = 'numeric'),
		 contains = 'vehicle')
```

Once the classes have been setup, you can create a new instance of a class using
the `new()` function.

```R
my_car <- new("car", type="SUV",
					 color='white',
					 number_wheels=4,
					 number_seats=5)
```

**Unlike S3 (and most of R objects), you can access different attributes of an
S4 class using the `@` operator**:

```R
my_car@color
```

Similar to S3 OOP, you need to declare an method prior to defining the logic for
that method. In S4, you do this using the `setGeneric()` and `standardGeneric()`
functions:

```R
setGeneric("<new_generic_method_name>", function(x) {
	standardGeneric("<new_generic_method_name>")
})
```
Note that if you want to define a method using an already existing function name
(e.g. `print()`), you can do so using the below manner:

```R
setGeneric("print")
```

Once the method is declared, you define the logic for it using the `setMethod()`
function:

```R
setMethod("<new_generic_method_name",
		  signature="<name_of_class_as_character>",
		  definition = function(x){
			# put all your logic here
})
```

### Reference Classes

The `setRefClass()` follows a more modern approach to OOP, which allows you to
define the classes fields, methods and super-classes:

```R
Student <- setRefClass("Student",
					   contains = "<super_class_name_as_character",
					   fields = list(name = 'character',
									 grad_year = 'numeric',
									 credits = 'numeric',
									 id = 'character',
									 courses = 'list'),
					   methods = list(
									  hello = function() {
										  paste("Hi! my name is", name)
									  },
									  add_credits = function(n) {
										  credits <<- credits + n
									  },
									  get_email = function() {
										  paste0(id, "@gmail.com")
									  }
									  )
)
```

**Note that the `add_credits()` function uses the `<<-` operator in order to change
the state of the instance (the credits field specifically)**

The `contains` argument is optional (for those classes with super-classes).

Once the class has been defined, you can create a new instance using the `new()`
**method**:

```R
jason_bourne <- Student$new(name = "Jason Bourne",
							grad_year = 2000,
							credits = 1000,
							id = 'TREADSTONE',
							courses = list("Assassination 101",
										   "Hand Fighting 412",
										   "Government Deception 500"))
```

You can access the fields and methods using the traditional `$` operator:

```R
jason_bourne$add_credits(100)
```

# Course: Building R Packages

A **comprehensive** guide to the details of building an R package can be found
[here](https://cran.r-project.org/doc/manuals/r-release/R-exts.html).

To build packages using RStudio (makes things easier), follow the steps outlined
[here](https://github.com/rdpeng/daprocedures/blob/master/lists/Rpackage_preflight.md).

**General Outline**m

1. Open an R console and run the following commands

```R
library(devtools)

# Creates the appropriate directory framework for your package
create("<package_name")

# creates the test/ directory, creates test/testthat.R, adds testthat to the
# DESCRIPTION file in the Suggests field
use_testthat()
```

2. Write/Move any .R files that should be included in your package into the R/
directory that was just created.

3. Write the documentation in the proper `roxygen2` format (including data,
if needed).

4. Once all code and documentation is complete, go to the package's main directory,
open up the R console (`R`) and run the following commands:

```R
library(devtools)

# checks to see if all tests pass
test()

# checks to see if all files that are needed are present, tests pass, ...
# everything needed for a packages to be successfully installed.
check()
```

Change the code/tests as needed until there are no warnings, notes or errors.
If your github is connected to [Travis](https://travis-ci.org), a build will
start automatically.

Building the package and then checking it will allows the build process to ignore
any hidden objects (e.g. git objects) so they aren't checked in the checking process.

## Basic Structure of an R Package

R packages begin life as a directory on your computer with (at least) 4 files:

* `R` - A directory that contains all of your R code. These can be all in one
file, but probably should be in seperate files based on some grouping logic.

* `man` - A directory that contains the documentation for all the **exported**
objects/functions within a package (i.e. if your package has 100 functions but
only 25 of those are exported, you would only need documentation for those 25).

**Use the `roxygen2` package to auto-generate documentation.**

* `NAMESPACE` - A file the defines what the user has access to. Any function that
you (the creator of a package) want the user to have access to will be in an `export()`
statement within this file. For example:

```R
# my_function would be defined in a file within the R directory
export("my_function")
```

If the package your are writing depends on any functions from other packages,
they are imported within this file. For example:

```R
importFrom("<package_name",
		   "<function_needed_within_package_name>",
		   "<another_function_needed_within_package_name>")

```

It is better to use `importFrom()` and be specific about what external functions
your packages relies upon than to use `import()` and import an entire package.

**Generally speaking, you want to minimize the number of functions you export/allow
the user to have access to.**

* `DESCRIPTION` - A file containing metadata regarding the package (author,
version number, date of release, dependencies/imports, etc).

If there are two functions (or objects of any type for that matter) that have
the same name, you can use *scope resolution operator* to define the full
function/object name:

```R
<package_name>::<function/object_name>
```

**Loading vs. Attaching a Package Namespace**
Importing package namespace Y into another package X gives package X access to
all the functions/objects within package Y. When package Y is loaded, **it is only
available to package X**. Attaching package namespace Y to package X puts package
Y on the search list and (for better or worse), gives the user access to all those
functions when they use package X.

## The `devtools` Package

Find Hadley Wickham's book for developing R packages [here](http://r-pkgs.had.co.nz).

The `devtools` package has many useful functions for facilitating package development,
a few of which are:

* `create(<dir_name>)` - Creates the directory framework for a package
(`R` directory, NAMESPACE and DESCRIPTION files, etc).

## Documentation

for function specific help files, use the `roxygen2` package. More in depth
documentation (README's and vignettes (long form guides)). If you decide to create
a vignette (or multiple vignettes, depending on the size of your package), these
will go in a `vignettes` subdirectory within the package directory.

```R
devtools::use_vignette()
```

### `roxygen2`

When using `roxygen2` to documente your R functions, place the "docstring" for
the function **directly** above the function it accompanies. All lines that
start with `#'` (pound sign and an apostrophe) will be considered part of the
documentation.

```R
#' Print "Hello world" 
#'
#' This is a simple function that, by default, prints "Hello world". You can 
#' customize the text to print (using the \code{to_print} argument) and add
#' an exclamation point (\code{excited = TRUE}).
#'
#' @param to_print A character string giving the text the function will print
#' @param excited Logical value specifying whether to include an exclamation
#'    point after the text
#' 
#' @return This function returns a phrase to print, with or without an 
#'    exclamation point added. As a side effect, this function also prints out
#'    the phrase. 
#'
#' @examples
#' hello_world()
#' hello_world(excited = TRUE)
#' hello_world(to_print = "Hi world")
#'
#' @export
hello_world <- function(to_print = "Hello world", excited = FALSE){
    if(excited) to_print <- paste0(to_print, "!")
    print(to_print)
}
```

Running `devtools::document()` will render the documentation files **which will
populate in the `man/` subdirectory** of the package directory.

[Here](https://bookdown.org/rdpeng/RProgDA/documentation.html#common-roxygen2-tags)
are a few common tags used in `roxygen2` documentation. A few to be wary of:

* *Always* use the `@examples` instead of the `@example` tag to demonstrate
code within documentation

* The `@inheritParams` tag allows you to inherit the parameter documentation you
wrote if you are using the same (or some of the same) parameters in the current
function.

* Using the `@export` tag at the end of the documentation (directly above the
function) will allow `roxygen2` to create the NAMESPACE file for you.

## Data Within a Package

Since most packages group functions together that manipulate similar data, it
is usually a good idea to include some data to demonstrate how functions are used.

Data that is included in packages should be documented so that users can use
common functionality like `?<data_set_name>` and will be able to view some useful
information.

```R
#' Production and farm value of maple products in Canada
#'
#' @source Statistics Canada. Table 001-0008 - Production and farm value of
#'  maple products, annual. \url{http://www5.statcan.gc.ca/cansim/}
#' @format A data frame with columns:
#' \describe{
#'  \item{Year}{A value between 1924 and 2015.}
#'  \item{Syrup}{Maple products expressed as syrup, total in thousands of gallons.}
#'  \item{CAD}{Gross value of maple products in thousands of Canadian dollars.}
#'  \item{Region}{Postal code abbreviation for territory or province.}
#' }
#' @examples
#' \dontrun{
#'  maple
#' }
"maple"
```

Data frames that you include in your package should follow the general schema above where the documentation page has the following attributes:

* An informative title describing the object.

* A @source tag describing where the data was found.

* A @format tag which describes the data in each column of the data frame.

* And then finally a string with the name of the object

## Software Testing with `testhat`

Check out [this link](https://journal.r-project.org/archive/2011-1/RJournal_2011-1_Wickham.pdf)
for an introduction to the `testhat` package

Tests are usually kept in their own `.R` file. Multiple tests should be in the
`tests` subdirectory.

Individual files can have their test run using the `test_file()` function while
a directory of tests can all be tested together using the `test_dir()` function.

All tests can be run using the 'check' button on the build tab (implicitly runs
`R CMD check`).

Both Travis and AppVeyor connect with your GitHub account.

* Use [Travis](https://travis-ci.org) to test your package in a Linux environment.
    * When using Travis, your package repo will need a YAML file. Using 
    `devtools::use_travis()` within your package directory will create a basic
    `travix.yml` file for you.
 
* Use [AppVeyor](https://www.appveyor.com) to test your package in a Windows
environment.
    * When using AppVeyor, your package repo will need a YAML file. Using 
    `devtools::use_appveyor()` within your package directory will create a basic
    `travix.yml` file for you.

## Cross Platform Development

Although R will run the same on any OS, filepaths should be created using R's
builtin functions instread of manually creating them (granted that is the case
with any language...)

The `select.list()` function is a good option for when you want to create
functions that interact with your user (i.e. ask permission to create a file
or directory).

The `rappdirs` package contains functions that allow access to other directories
if the package you are creating needs to.

The `install.packages()` function can install packages that are compressed as a
zip file.

If you are writing some function/package for which you will need system/hardware
information, you can use the `.Platform` or `.Machine` environment variables.
(Both of these are objects with various attributes that can be accessed using the
standard `$` operator - i.e. `.Platform$OS.type`).

# Course: Building Data Visualization Tools

The aesthetics that are required will depend on the graph that you want to
create. For example:

* color - color of **border** of element.
* fill - color of **fill** of element.
* alpha - transparency of element.

**All of the above aesthetics can be passed data frame attributes to add more
information to your plots**.

If you would like to show different subsets of a dataframe (for example, when
a qualitative variable is equal to one of multiple factors), use the `gridExtra`
package. For example:

(notice how the data argument can be used in the geom_x() function (instead of
the ggplot() function) to specify different subsets of a data frame - or a 
separate data frame altogether).

```r
library(gridExtra)

plot1 <- ggplot() +
  geom_line(data = val_loss_subset[val_loss_subset$method == 'constant',],
             aes(x= epoch, y = value, color = 'Constant LR')) +
  geom_line(data = val_loss_subset[val_loss_subset$method == 'cyclic',],
             aes(x= epoch, y = value, color = 'Cyclic LR')) +
  labs(x = NULL, y = "Loss", title = 'Nesterov | Constant vs. Cyclic Learning Rates')


plot2 <- ggplot() +
  geom_line(data = val_acc_subset[val_acc_subset$method == 'constant',],
            aes(x= epoch, y = value, color = 'Constant LR')) +
  geom_line(data = val_acc_subset[val_acc_subset$method == 'cyclic',],
            aes(x= epoch, y = value, color = 'Cyclic LR')) +
  labs(x = 'Epoch', y = 'Accuracy')

grid.arrange(plot1, plot2, nrow=2)
```

`xlab()`, `ylab()` and `ggtitle()` are the `ggplot2` way of adding labels to
your plots.

Where applicable, the `fill` attribute references the color you would like
your plot to be filled with (as the name implies) while the `color` attribute
refers to the **outline color** or your plot aesthetics.

**Usefull `ggplot2` extensions to look into**:

* `GGally` - the `ggpairs()` function allows you to see some useful EDA plots
with minimal coding. For example:

```r
# show pairwise plots of the sex, wt, ht and age variables
library(GGally)
ggpairs(nepali %>% select(sex, wt, ht, age))
```




