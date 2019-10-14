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
