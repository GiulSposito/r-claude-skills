# stringr Reference Guide

## Overview

stringr provides a cohesive set of functions for string manipulation in R. All functions:
- Start with `str_` prefix for easy discovery
- Take string as first argument (pipe-friendly)
- Return consistent output types
- Use ICU regex by default
- Handle NA values gracefully

**Core Philosophy:**
- Simple, consistent API
- Vectorized operations
- Sensible defaults

---

## String Basics

### str_length() - String Length

```r
# Basic length
str_length("hello")
# Returns: 5

# Vectorized
str_length(c("hello", "world", "R"))
# Returns: c(5, 5, 1)

# Handles NA
str_length(c("hello", NA, "world"))
# Returns: c(5, NA, 5)

# Empty string
str_length("")
# Returns: 0

# Multibyte characters
str_length("café")  # é is one character
# Returns: 4
```

---

### str_c() - Concatenate Strings

```r
# Basic concatenation
str_c("Hello", "world")
# Returns: "Helloworld"

# With separator
str_c("Hello", "world", sep = " ")
# Returns: "Hello world"

# Multiple strings
str_c("a", "b", "c", sep = "-")
# Returns: "a-b-c"

# Vectorized
str_c(c("Hello", "Goodbye"), c("world", "moon"))
# Returns: c("Helloworld", "Goodbyemoon")

# Collapse vector to single string
str_c(c("a", "b", "c"), collapse = ", ")
# Returns: "a, b, c"

# Handle NA
str_c("Hello", NA)
# Returns: NA

str_c("Hello", NA, sep = " ")
# Returns: NA

# Ignore NA with str_flatten
str_flatten(c("a", NA, "b"), collapse = ", ", na.rm = TRUE)
# Returns: "a, b"

# Practical examples
# Build file paths
str_c("data/", c("file1", "file2", "file3"), ".csv")
# Returns: c("data/file1.csv", "data/file2.csv", "data/file3.csv")

# Create labels
str_c("Patient ", 1:5, " (n=", c(100, 120, 95, 110, 105), ")")
```

---

### str_sub() - Extract/Replace by Position

```r
# Extract substring
str_sub("Hello world", 1, 5)
# Returns: "Hello"

# Negative indices (from end)
str_sub("Hello world", -5, -1)
# Returns: "world"

# Vectorized
str_sub(c("apple", "banana", "cherry"), 1, 3)
# Returns: c("app", "ban", "che")

# Extract single character
str_sub("Hello", 2, 2)
# Returns: "e"

# From position to end
str_sub("Hello world", 7)
# Returns: "world"

# Assignment (replacement)
x <- "Hello world"
str_sub(x, 1, 5) <- "Goodbye"
x
# Returns: "Goodbye world"

# Vectorized replacement
x <- c("abc", "def", "ghi")
str_sub(x, 1, 1) <- "X"
x
# Returns: c("Xbc", "Xef", "Xhi")

# Practical: extract year from date
dates <- c("2020-01-15", "2021-03-22", "2022-07-30")
str_sub(dates, 1, 4)
# Returns: c("2020", "2021", "2022")
```

---

## Detection & Matching

### str_detect() - Detect Pattern

```r
# Basic detection
str_detect("Hello world", "world")
# Returns: TRUE

str_detect("Hello world", "moon")
# Returns: FALSE

# Vectorized
fruits <- c("apple", "banana", "cherry")
str_detect(fruits, "a")
# Returns: c(TRUE, TRUE, FALSE)

# Use in filter
starwars |>
  filter(str_detect(name, "Skywalker"))

# Multiple patterns with regex
str_detect("test@email.com", "@")
# Returns: TRUE

# Case sensitive by default
str_detect("Hello", "hello")
# Returns: FALSE

# Case insensitive with regex
str_detect("Hello", regex("hello", ignore_case = TRUE))
# Returns: TRUE

# Or use str_to_lower
str_detect(str_to_lower("Hello"), "hello")
# Returns: TRUE

# Negate
str_detect("Hello", "bye", negate = TRUE)
# Returns: TRUE

# Practical: filter data
emails <- c("user@gmail.com", "admin@company.com", "test")
str_detect(emails, "@")
# Returns: c(TRUE, TRUE, FALSE)
```

---

### str_starts() / str_ends() - Match Position

```r
# Starts with
str_starts("Hello world", "Hello")
# Returns: TRUE

# Vectorized
fruits <- c("apple", "apricot", "banana")
str_starts(fruits, "ap")
# Returns: c(TRUE, TRUE, FALSE)

# Ends with
str_ends("test.csv", ".csv")
# Returns: TRUE

# Multiple files
files <- c("data.csv", "data.xlsx", "report.csv")
str_ends(files, ".csv")
# Returns: c(TRUE, FALSE, TRUE)

# Negate
str_starts("hello", "bye", negate = TRUE)
# Returns: TRUE

# Case insensitive
str_starts("Hello", regex("hello", ignore_case = TRUE))
# Returns: TRUE

# Practical: filter columns
df <- tibble(
  user_id = 1:3,
  user_name = c("Alice", "Bob", "Charlie"),
  admin_role = c(TRUE, FALSE, TRUE),
  created_at = Sys.Date()
)

df |>
  select(where(~ is.character(.x) &&
                any(str_starts(names(df)[cur_column()], "user"))))
```

---

### str_count() - Count Matches

```r
# Count occurrences
str_count("banana", "a")
# Returns: 3

# Vectorized
fruits <- c("apple", "banana", "cherry")
str_count(fruits, "a")
# Returns: c(1, 3, 0)

# Count multiple patterns
text <- "The quick brown fox"
str_count(text, "\\w+")  # Count words
# Returns: 4

# Practical: count vowels
text <- c("hello", "world", "R programming")
str_count(text, "[aeiou]")
# Returns: c(2, 1, 3)

# Count lines
text <- "line1\nline2\nline3"
str_count(text, "\n") + 1
# Returns: 3
```

---

## Extraction

### str_extract() - Extract First Match

```r
# Extract first match
str_extract("Email: test@example.com", "\\w+@\\w+\\.\\w+")
# Returns: "test@example.com"

# Vectorized
text <- c("Price: $10.99", "Cost: $25.50", "No price")
str_extract(text, "\\$[0-9.]+")
# Returns: c("$10.99", "$25.50", NA)

# Extract numbers
str_extract("Order #12345", "\\d+")
# Returns: "12345"

# No match returns NA
str_extract("hello", "\\d+")
# Returns: NA

# Practical: extract phone numbers
contacts <- c("Call me at 555-1234", "Email: test@email.com", "Phone: 555-9876")
str_extract(contacts, "\\d{3}-\\d{4}")
# Returns: c("555-1234", NA, "555-9876")
```

---

### str_extract_all() - Extract All Matches

```r
# Extract all matches (returns list)
str_extract_all("Call 555-1234 or 555-5678", "\\d{3}-\\d{4}")
# Returns: list(c("555-1234", "555-5678"))

# Simplify to vector when possible
str_extract_all("Get 10, 20, or 30", "\\d+")[[1]]
# Returns: c("10", "20", "30")

# Vectorized (returns list)
text <- c("abc123def456", "xyz789")
str_extract_all(text, "\\d+")
# Returns: list(c("123", "456"), "789")

# Simplify to matrix
str_extract_all(text, "\\d+", simplify = TRUE)
# Returns: matrix with padding

# Practical: extract all emails
text <- "Contact us: admin@site.com or support@site.com"
str_extract_all(text, "\\w+@\\w+\\.\\w+")[[1]]
# Returns: c("admin@site.com", "support@site.com")

# Extract hashtags
tweet <- "Love #rstats and #datascience! #tidyverse is great"
str_extract_all(tweet, "#\\w+")[[1]]
# Returns: c("#rstats", "#datascience", "#tidyverse")
```

---

### str_match() - Extract with Groups

```r
# Match with capture groups
str_match("test@example.com", "(\\w+)@(\\w+)\\.(\\w+)")
# Returns: matrix with full match and groups
#   [,1]              [,2]   [,3]      [,4]
#   "test@example.com" "test" "example" "com"

# Vectorized
emails <- c("alice@company.com", "bob@test.org")
str_match(emails, "(\\w+)@(\\w+)")
# Returns: 2x3 matrix

# Named groups (tidier!)
pattern <- "(?<user>\\w+)@(?<domain>\\w+\\.\\w+)"
result <- str_match(emails, pattern)

# Practical: parse dates
dates <- c("2020-01-15", "2021-03-22")
str_match(dates, "(\\d{4})-(\\d{2})-(\\d{2})")
# Returns: matrix with year, month, day columns

# Parse log entries
logs <- "2024-01-15 10:30:25 ERROR Connection failed"
str_match(logs, "(\\d{4}-\\d{2}-\\d{2}) (\\d{2}:\\d{2}:\\d{2}) (\\w+)")
```

---

## Replacement

### str_replace() / str_replace_all() - Replace Patterns

```r
# Replace first match
str_replace("Hello world world", "world", "moon")
# Returns: "Hello moon world"

# Replace all matches
str_replace_all("Hello world world", "world", "moon")
# Returns: "Hello moon moon"

# Vectorized
fruits <- c("apple", "apricot", "avocado")
str_replace(fruits, "a", "A")
# Returns: c("Apple", "Apricot", "Avocado")  # Only first 'a'

str_replace_all(fruits, "a", "A")
# Returns: c("Apple", "Apricot", "AvocAdo")  # All 'a's

# Multiple patterns with named vector
text <- "Hello world!"
str_replace_all(text, c("Hello" = "Goodbye", "world" = "moon"))
# Returns: "Goodbye moon!"

# Using backreferences
str_replace("abc123def", "(\\d+)", "NUM:\\1")
# Returns: "abcNUM:123def"

# Remove pattern (replace with "")
str_replace_all("Hello  world", "\\s+", " ")
# Returns: "Hello world" (multiple spaces to one)

# Practical: clean phone numbers
phones <- c("(555) 123-4567", "555.123.4567", "555-123-4567")
str_replace_all(phones, "[^0-9]", "")
# Returns: c("5551234567", "5551234567", "5551234567")

# Fix typos
text <- "The quik brown fox"
str_replace(text, "quik", "quick")

# Anonymize data
names <- c("Alice Smith", "Bob Jones")
str_replace_all(names, "\\w+", "XXX")
# Returns: c("XXX XXX", "XXX XXX")
```

---

### str_remove() / str_remove_all() - Remove Patterns

```r
# Remove first match
str_remove("Hello world world", "world")
# Returns: "Hello  world"

# Remove all matches
str_remove_all("Hello world world", "world")
# Returns: "Hello  "

# Remove prefix
str_remove("Mr. Smith", "^Mr\\.\\s*")
# Returns: "Smith"

# Remove suffix
str_remove("data.csv", "\\.csv$")
# Returns: "data"

# Vectorized
files <- c("data.csv", "report.xlsx", "notes.txt")
str_remove(files, "\\.[a-z]+$")
# Returns: c("data", "report", "notes")

# Remove whitespace
str_remove_all("a b c d", "\\s+")
# Returns: "abcd"

# Practical: clean column names
cols <- c("Column.1", "Column.2", "Column.3")
str_remove(cols, "Column\\.")
# Returns: c("1", "2", "3")

# Remove special characters
str_remove_all("hello@world!", "[^a-z]")
# Returns: "helloworld"
```

---

## Whitespace & Trimming

### str_trim() - Remove Leading/Trailing Whitespace

```r
# Trim both sides (default)
str_trim("  hello world  ")
# Returns: "hello world"

# Trim left only
str_trim("  hello world  ", side = "left")
# Returns: "hello world  "

# Trim right only
str_trim("  hello world  ", side = "right")
# Returns: "  hello world"

# Vectorized
text <- c("  a  ", "  b", "c  ")
str_trim(text)
# Returns: c("a", "b", "c")

# Practical: clean user input
user_input <- c("  alice@email.com  ", "bob@email.com  ", "  charlie@email.com")
str_trim(user_input)
```

---

### str_squish() - Remove Excess Whitespace

```r
# Remove leading, trailing, and reduce internal whitespace
str_squish("  hello    world  ")
# Returns: "hello world"

# Handles various whitespace characters
str_squish("hello\n\nworld")
# Returns: "hello world"

# Vectorized
text <- c("a  b  c", "  x   y  ", "p\n\nq")
str_squish(text)
# Returns: c("a b c", "x y", "p q")

# Practical: clean text data
comments <- c("Great   product!  ", "  Very    good  ", "Love\n\nit")
str_squish(comments)
# Returns: c("Great product!", "Very good", "Love it")
```

---

### str_pad() - Add Padding

```r
# Pad to width (left padding by default)
str_pad("5", width = 3, pad = "0")
# Returns: "005"

# Right padding
str_pad("5", width = 3, side = "right", pad = "0")
# Returns: "500"

# Both sides
str_pad("hello", width = 9, side = "both")
# Returns: "  hello  "

# Vectorized
str_pad(1:10, width = 2, pad = "0")
# Returns: c("01", "02", ..., "10")

# Practical: create IDs
ids <- 1:100
str_pad(ids, width = 5, pad = "0")
# Returns: "00001", "00002", ..., "00100"

# Align text
names <- c("Alice", "Bob", "Charlotte")
str_pad(names, width = 10, side = "right")
```

---

## Case Conversion

### str_to_lower() / str_to_upper() / str_to_title()

```r
# To lowercase
str_to_lower("Hello World")
# Returns: "hello world"

# To uppercase
str_to_upper("Hello World")
# Returns: "HELLO WORLD"

# To title case
str_to_title("hello world")
# Returns: "Hello World"

# Vectorized
text <- c("HELLO", "world", "R Programming")
str_to_lower(text)
# Returns: c("hello", "world", "r programming")

# Sentence case (first letter upper)
str_to_sentence("hello world. how are you?")
# Returns: "Hello world. How are you?"

# Practical: normalize input
user_input <- c("Alice", "ALICE", "alice")
str_to_lower(user_input)  # All become "alice"

# Clean column names
cols <- c("First Name", "Last Name", "Email Address")
str_to_lower(cols) |> str_replace_all("\\s+", "_")
# Returns: c("first_name", "last_name", "email_address")
```

---

## Splitting & Wrapping

### str_split() - Split Strings

```r
# Basic split (returns list)
str_split("a,b,c", ",")
# Returns: list(c("a", "b", "c"))

# Access elements
str_split("a,b,c", ",")[[1]]
# Returns: c("a", "b", "c")

# Vectorized (returns list)
text <- c("a,b,c", "x,y")
str_split(text, ",")
# Returns: list(c("a", "b", "c"), c("x", "y"))

# Simplify to matrix
str_split(text, ",", simplify = TRUE)
# Returns: 2x3 matrix (shorter vectors padded with "")

# Limit splits
str_split("a,b,c,d", ",", n = 2)
# Returns: list(c("a", "b,c,d"))

# Split by regex
str_split("one123two456three", "\\d+")
# Returns: list(c("one", "two", "three"))

# Practical: parse CSV line
csv_line <- '"John","Doe","john@email.com"'
str_split(csv_line, ",")[[1]] |> str_remove_all('"')

# Split sentences
text <- "Hello world. How are you? I'm fine."
str_split(text, "\\. |\\? ")[[1]]
```

---

### str_split_fixed() - Split to Fixed Number

```r
# Split to fixed number of pieces (returns matrix)
str_split_fixed("a,b,c", ",", n = 3)
# Returns: 1x3 matrix

# Vectorized
text <- c("a,b,c", "x,y,z")
str_split_fixed(text, ",", n = 3)
# Returns: 2x3 matrix

# Fewer pieces than n
str_split_fixed("a,b", ",", n = 3)
# Returns: matrix("a", "b", "")  # Padded with empty

# More pieces than n
str_split_fixed("a,b,c,d", ",", n = 2)
# Returns: matrix("a", "b,c,d")  # Extra kept together

# Practical: parse fixed format
data <- c("John:30:Engineer", "Jane:25:Designer")
str_split_fixed(data, ":", n = 3)
# Returns: matrix with name, age, role columns
```

---

### str_wrap() - Wrap Text

```r
# Wrap to width
text <- "This is a very long sentence that needs to be wrapped to fit within a certain width."
str_wrap(text, width = 30)
# Returns: string with line breaks

# With indent
str_wrap(text, width = 30, indent = 2)
# Indents first line

# With exdent (hanging indent)
str_wrap(text, width = 30, exdent = 2)
# Indents all but first line

# Practical: format paragraphs
paragraph <- "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
str_wrap(paragraph, width = 40)
```

---

## Locale & Ordering

### str_sort() / str_order() - Sort Strings

```r
# Sort strings
str_sort(c("apple", "banana", "cherry"))
# Returns: c("apple", "banana", "cherry")

# Descending order
str_sort(c("apple", "banana", "cherry"), decreasing = TRUE)
# Returns: c("cherry", "banana", "apple")

# Order (returns indices)
str_order(c("cherry", "apple", "banana"))
# Returns: c(2, 3, 1)

# Case-insensitive sort
str_sort(c("Apple", "banana", "Cherry"))
# Returns: c("Apple", "banana", "Cherry")

# Numeric order
str_sort(c("file10", "file2", "file1"), numeric = TRUE)
# Returns: c("file1", "file2", "file10")

# Practical: natural sorting
files <- c("file1.txt", "file10.txt", "file2.txt")
str_sort(files, numeric = TRUE)
# Returns: c("file1.txt", "file2.txt", "file10.txt")
```

---

## Working with Regex

### Common Regex Patterns

```r
# Match digits
str_extract_all("abc123def456", "\\d+")

# Match word characters
str_extract_all("hello world", "\\w+")

# Match whitespace
str_split("one  two\nthree", "\\s+")

# Match email
str_extract("Contact: test@example.com", "\\w+@\\w+\\.\\w+")

# Match URL
str_extract("Visit https://www.example.com", "https?://[\\w.]+")

# Match phone
str_extract("Call 555-1234", "\\d{3}-\\d{4}")

# Match date (YYYY-MM-DD)
str_extract("Date: 2024-01-15", "\\d{4}-\\d{2}-\\d{2}")

# Non-greedy matching
str_extract("<tag>content</tag>more", "<.+?>")  # Returns: "<tag>"

# Anchors
str_detect("hello", "^h")    # Starts with h
str_detect("hello", "o$")    # Ends with o
str_detect("hello", "^hello$")  # Exact match

# Character classes
str_detect("test123", "[0-9]")     # Contains digit
str_detect("test", "[a-z]+")       # Lowercase letters
str_detect("TEST", "[A-Z]+")       # Uppercase letters
str_detect("test@", "[^a-z]")      # Non-lowercase

# Quantifiers
str_extract("helllo", "l{2,}")     # 2 or more l's
str_extract("hello", "l{2}")       # Exactly 2 l's
str_extract("hello", "l{1,2}")     # 1 or 2 l's
```

---

### regex() - Control Regex Options

```r
# Case insensitive
str_detect("Hello", regex("hello", ignore_case = TRUE))
# Returns: TRUE

# Multiline mode
text <- "line1\nline2"
str_extract_all(text, regex("^line", multiline = TRUE))

# Comments mode
pattern <- regex("
  \\d{3}   # area code
  -        # separator
  \\d{4}   # number
", comments = TRUE)

str_extract("555-1234", pattern)

# Dotall mode (. matches \n)
str_extract("a\nb", regex("a.b", dotall = TRUE))
```

---

## Best Practices

1. **Use str_c() over paste()** - More consistent, better NA handling
2. **Prefer str_detect() for filtering** - Cleaner than grepl()
3. **Use fixed() for literal matching** - Faster than regex when possible
4. **Name capture groups** - Makes str_match() output clearer
5. **Vectorize operations** - Don't loop, let stringr handle it
6. **Handle NA explicitly** - Be aware of how functions handle NA
7. **Test regex patterns** - Use str_view() to visualize matches
8. **Trim user input** - Always clean strings from external sources
9. **Use raw strings r"(...)"** - For complex regex (R 4.0+)

---

## Common Pitfalls

1. **Forgetting to escape backslashes** - Use `\\d` not `\d`
2. **Mixing str_extract() and str_extract_all()** - Different return types
3. **Case sensitivity** - Patterns are case-sensitive by default
4. **Greedy vs non-greedy** - Use `?` for non-greedy: `.*?`
5. **Not handling NA** - Check NA behavior in your use case
6. **Forgetting anchors** - Use `^` and `$` for exact matches
7. **Using wrong replacement order** - str_replace_all() with named vector

---

## Quick Reference Card

| Task | Function | Example |
|------|----------|---------|
| Length | `str_length()` | `str_length("hello")` |
| Concatenate | `str_c()` | `str_c("a", "b", sep = " ")` |
| Substring | `str_sub()` | `str_sub("hello", 1, 3)` |
| Detect | `str_detect()` | `str_detect("hello", "h")` |
| Starts/Ends | `str_starts()` | `str_starts("hello", "he")` |
| Count | `str_count()` | `str_count("banana", "a")` |
| Extract | `str_extract()` | `str_extract("abc123", "\\d+")` |
| Extract all | `str_extract_all()` | `str_extract_all(x, "\\d+")` |
| Match groups | `str_match()` | `str_match(x, "(\\w+)@(\\w+)")` |
| Replace | `str_replace()` | `str_replace("hello", "h", "H")` |
| Replace all | `str_replace_all()` | `str_replace_all(x, "a", "A")` |
| Remove | `str_remove()` | `str_remove("hello", "h")` |
| Remove all | `str_remove_all()` | `str_remove_all(x, "\\s+")` |
| Trim | `str_trim()` | `str_trim("  hello  ")` |
| Squish | `str_squish()` | `str_squish("a  b  c")` |
| Pad | `str_pad()` | `str_pad("5", 3, pad = "0")` |
| To lower | `str_to_lower()` | `str_to_lower("HELLO")` |
| To upper | `str_to_upper()` | `str_to_upper("hello")` |
| To title | `str_to_title()` | `str_to_title("hello world")` |
| Split | `str_split()` | `str_split("a,b,c", ",")` |
| Split fixed | `str_split_fixed()` | `str_split_fixed(x, ",", 3)` |
| Sort | `str_sort()` | `str_sort(c("b", "a", "c"))` |
