# lubridate Reference Guide

## Overview

lubridate makes working with dates and times in R easier by providing:
- Intuitive parsing functions
- Arithmetic with dates and times
- Accessor and setter functions
- Time zone handling
- Duration, period, and interval calculations

**Core Philosophy:**
- Make date-time manipulation intuitive
- Handle common edge cases automatically
- Consistent function naming
- Integration with tidyverse

---

## Parsing Dates & Times

### ymd() Family - Parse Dates

Parse dates from strings with flexible formats.

```r
# Year-Month-Day
ymd("2024-01-15")
ymd("20240115")
ymd("2024/01/15")
ymd("2024 Jan 15")
# All return: 2024-01-15

# Month-Day-Year
mdy("01-15-2024")
mdy("January 15, 2024")
mdy("1/15/24")
# All return: 2024-01-15

# Day-Month-Year
dmy("15-01-2024")
dmy("15 January 2024")
dmy("15/1/24")
# All return: 2024-01-15

# Vectorized
dates <- c("2024-01-15", "2024-02-20", "2024-03-25")
ymd(dates)

# With times
ymd_hms("2024-01-15 10:30:45")
ymd_hm("2024-01-15 10:30")
ymd_h("2024-01-15 10")

mdy_hms("01/15/2024 10:30:45")
dmy_hms("15-01-2024 10:30:45")

# Practical: parse various formats
log_dates <- c(
  "2024-01-15 10:30:45",
  "2024-01-15 11:22:33",
  "2024-01-15 14:55:12"
)
ymd_hms(log_dates)

# Handle failures gracefully
dates <- c("2024-01-15", "not a date", "2024-02-20")
ymd(dates, quiet = TRUE)  # Returns NA for failed parses
# Returns: c("2024-01-15", NA, "2024-02-20")
```

---

### parse_date_time() - Flexible Parsing

More flexible parsing when format is variable.

```r
# Specify possible orders
dates <- c("2024-01-15", "01/15/2024", "January 15, 2024")
parse_date_time(dates, orders = c("ymd", "mdy", "Bdy"))

# Multiple possible formats
logs <- c(
  "2024-01-15 10:30:45",
  "01/15/2024 10:30",
  "15-Jan-2024 10:30:45"
)
parse_date_time(logs, orders = c("ymd HMS", "mdy HM", "dby HMS"))

# Practical: handle messy data
mixed_dates <- c(
  "2024-01-15",
  "15/01/2024",
  "Jan 15, 2024",
  "20240115"
)
parse_date_time(mixed_dates, orders = c("ymd", "dmy", "mdy"))
```

---

## Extracting Components

### Extract Date Parts

```r
# Create example
dt <- ymd_hms("2024-03-15 14:30:45")

# Year
year(dt)        # 2024

# Month
month(dt)       # 3
month(dt, label = TRUE)        # Mar
month(dt, label = TRUE, abbr = FALSE)  # March

# Day
day(dt)         # 15
mday(dt)        # 15 (day of month, same as day())
wday(dt)        # 6 (day of week, 1=Sunday)
wday(dt, label = TRUE)         # Fri
wday(dt, label = TRUE, abbr = FALSE)   # Friday
wday(dt, week_start = 1)       # 5 (Monday = 1)
yday(dt)        # 75 (day of year)

# Week
week(dt)        # 11
isoweek(dt)     # 11 (ISO 8601 week)
epiweek(dt)     # 11 (epidemiological week)

# Quarter
quarter(dt)     # 1
quarter(dt, with_year = TRUE)  # "2024.1"

# Time components
hour(dt)        # 14
minute(dt)      # 30
second(dt)      # 45

# AM/PM
am(dt)          # FALSE
pm(dt)          # TRUE

# Semester
semester(dt)    # 1

# Practical: extract for grouping
sales_data |>
  mutate(
    year = year(date),
    month = month(date, label = TRUE),
    quarter = quarter(date),
    weekday = wday(date, label = TRUE)
  )

# Group by time period
sales_data |>
  group_by(
    year = year(date),
    month = month(date)
  ) |>
  summarize(total = sum(revenue))
```

---

## Setting Components

### Modify Date Parts

```r
# Start with date
dt <- ymd_hms("2024-03-15 14:30:45")

# Set year
year(dt) <- 2025
# Result: 2025-03-15 14:30:45

# Set month
month(dt) <- 6
# Result: 2025-06-15 14:30:45

# Set day
day(dt) <- 20
# Result: 2025-06-20 14:30:45

# Set hour
hour(dt) <- 9
# Result: 2025-06-20 09:30:45

# Set minute
minute(dt) <- 15
# Result: 2025-06-20 09:15:45

# Set second
second(dt) <- 0
# Result: 2025-06-20 09:15:00

# Practical: normalize times
logs |>
  mutate(
    # Set all times to midnight
    date_only = update(timestamp, hour = 0, minute = 0, second = 0)
  )

# Set multiple components at once
update(dt, year = 2024, month = 1, day = 1)
# Result: 2024-01-01 09:15:00
```

---

## Date Arithmetic

### Adding & Subtracting

```r
# Add/subtract days
today() + days(5)
today() - days(10)

# Add weeks
today() + weeks(2)

# Add months (handles month lengths)
ymd("2024-01-31") + months(1)
# Result: 2024-02-29 (leap year)

ymd("2024-01-31") + months(2)
# Result: 2024-03-31

# Add years
today() + years(1)

# Combine
today() + years(1) + months(2) + days(3)

# Vectorized
dates <- ymd(c("2024-01-15", "2024-02-20", "2024-03-25"))
dates + months(1)

# Practical: calculate due dates
invoice_dates <- ymd(c("2024-01-15", "2024-02-20"))
due_dates <- invoice_dates + days(30)

# Follow-up dates
appointments |>
  mutate(
    followup = appointment_date + weeks(2)
  )
```

---

### Sequences of Dates

```r
# Daily sequence
seq(ymd("2024-01-01"), ymd("2024-01-10"), by = "day")

# Weekly sequence
seq(ymd("2024-01-01"), ymd("2024-03-01"), by = "week")

# Monthly sequence
seq(ymd("2024-01-01"), ymd("2024-12-01"), by = "month")

# Quarterly
seq(ymd("2024-01-01"), ymd("2024-12-01"), by = "quarter")

# By 2 weeks
seq(ymd("2024-01-01"), ymd("2024-03-01"), by = "2 weeks")

# Length out
seq(ymd("2024-01-01"), by = "month", length.out = 12)

# Practical: create date range
date_range <- tibble(
  date = seq(ymd("2024-01-01"), ymd("2024-12-31"), by = "day")
)

# Fill in missing dates
sales_complete <- sales_data |>
  complete(
    date = seq(min(date), max(date), by = "day"),
    fill = list(revenue = 0)
  )
```

---

## Rounding & Truncating

### floor_date() / ceiling_date() / round_date()

```r
# Example datetime
dt <- ymd_hms("2024-03-15 14:30:45")

# Floor (round down)
floor_date(dt, "year")    # 2024-01-01 00:00:00
floor_date(dt, "month")   # 2024-03-01 00:00:00
floor_date(dt, "week")    # 2024-03-10 00:00:00 (Sunday)
floor_date(dt, "day")     # 2024-03-15 00:00:00
floor_date(dt, "hour")    # 2024-03-15 14:00:00

# Ceiling (round up)
ceiling_date(dt, "year")  # 2025-01-01 00:00:00
ceiling_date(dt, "month") # 2024-04-01 00:00:00
ceiling_date(dt, "day")   # 2024-03-16 00:00:00

# Round (nearest)
round_date(dt, "hour")    # 2024-03-15 15:00:00
round_date(dt, "day")     # 2024-03-16 00:00:00

# Week starting Monday
floor_date(dt, "week", week_start = 1)

# Practical: aggregate by time period
sales_data |>
  mutate(
    month_start = floor_date(date, "month"),
    week_start = floor_date(date, "week")
  ) |>
  group_by(month_start) |>
  summarize(total = sum(revenue))

# Round times to nearest 15 minutes
appointments |>
  mutate(
    time_rounded = round_date(timestamp, "15 minutes")
  )

# Group by hour
logs |>
  mutate(hour_block = floor_date(timestamp, "hour")) |>
  count(hour_block)
```

---

## Durations, Periods & Intervals

### Durations - Exact Time Spans

Durations represent exact number of seconds.

```r
# Create durations
dseconds(30)    # 30 seconds
dminutes(5)     # 300 seconds
dhours(2)       # 7200 seconds
ddays(1)        # 86400 seconds
dweeks(1)       # 604800 seconds
dyears(1)       # 31557600 seconds (365.25 days)

# Arithmetic
now() + dhours(2)
now() - dminutes(30)

# Combine
dhours(2) + dminutes(30)  # 2.5 hours in seconds

# Time differences return durations
end_time <- ymd_hms("2024-01-15 14:30:00")
start_time <- ymd_hms("2024-01-15 10:00:00")
duration <- end_time - start_time
# Result: 4.5 hours (in seconds)

as.numeric(duration, "hours")  # 4.5
as.numeric(duration, "minutes")  # 270

# Practical: calculate elapsed time
process_data |>
  mutate(
    duration = end_time - start_time,
    duration_hours = as.numeric(duration, "hours")
  )
```

---

### Periods - Human-Readable Time Spans

Periods represent time spans in human units (handle irregularities).

```r
# Create periods
seconds(30)
minutes(5)
hours(2)
days(1)
weeks(1)
months(1)   # Handles different month lengths
years(1)    # Handles leap years

# Arithmetic
today() + months(1)  # Handles Feb, leap years, etc.
today() + years(1)   # Handles leap years

# Difference from durations
ymd("2024-01-31") + months(1)
# Result: 2024-02-29 (period handles month length)

ymd("2024-01-31") + days(31)
# Result: 2024-03-02 (duration is exact days)

# Combine
hours(2) + minutes(30) + seconds(15)

# Create from duration
as.period(dhours(2.5))  # "2H 30M 0S"

# Practical: subscription periods
subscriptions |>
  mutate(
    renewal_date = start_date + months(subscription_months)
  )

# Age calculations
people |>
  mutate(
    age = as.period(today() - birth_date),
    age_years = year(age)
  )
```

---

### Intervals - Time Span with Start & End

Intervals represent time span between two specific dates.

```r
# Create interval
start <- ymd("2024-01-01")
end <- ymd("2024-12-31")
interval <- start %--% end

# Or
interval <- interval(start, end)

# Check if date is in interval
ymd("2024-06-15") %within% interval  # TRUE
ymd("2025-01-01") %within% interval  # FALSE

# Interval arithmetic
interval / days(1)      # Number of days in interval
interval / months(1)    # Number of months
interval / years(1)     # Number of years (fractional)

# Overlapping intervals
int1 <- ymd("2024-01-01") %--% ymd("2024-06-30")
int2 <- ymd("2024-04-01") %--% ymd("2024-09-30")

int_overlaps(int1, int2)  # TRUE

# Practical: check availability
booking_period <- start_date %--% end_date

available_slots |>
  filter(!(slot_start %within% booking_period))

# Project duration
projects |>
  mutate(
    project_interval = start_date %--% end_date,
    duration_days = project_interval / days(1),
    duration_weeks = project_interval / weeks(1)
  )

# Overlap detection
meetings |>
  mutate(
    meeting_int = start_time %--% end_time
  ) |>
  inner_join(
    meetings |> mutate(meeting_int2 = start_time %--% end_time),
    by = character(),
    suffix = c("_1", "_2")
  ) |>
  filter(
    id_1 < id_2,
    int_overlaps(meeting_int_1, meeting_int_2)
  )
```

---

## Time Zones

### Working with Time Zones

```r
# Get current timezone
Sys.timezone()

# Parse with timezone
ymd_hms("2024-01-15 10:30:00", tz = "America/New_York")
ymd_hms("2024-01-15 10:30:00", tz = "Europe/London")
ymd_hms("2024-01-15 10:30:00", tz = "UTC")

# Convert timezone (changes display, not instant)
dt_ny <- ymd_hms("2024-01-15 10:30:00", tz = "America/New_York")

with_tz(dt_ny, "UTC")
# Changes how time is displayed in new timezone

with_tz(dt_ny, "Asia/Tokyo")

# Force timezone (changes instant, not display)
force_tz(dt_ny, "UTC")
# Treats the same clock time as different instant

# Default timezone
now()  # Current time in local timezone
now("UTC")  # Current time in UTC

# Practical: normalize to UTC
logs |>
  mutate(
    timestamp_utc = with_tz(timestamp, "UTC")
  )

# Convert user input to system timezone
user_time <- ymd_hms("2024-01-15 10:30:00", tz = "America/New_York")
system_time <- with_tz(user_time, Sys.timezone())

# List available timezones
OlsonNames() |> head(20)
```

---

## Special Functions

### today() / now()

```r
# Current date (no time)
today()
# Result: 2024-03-09

# With timezone
today("America/New_York")
today("UTC")

# Current datetime
now()
# Result: 2024-03-09 14:30:45 EST

# With timezone
now("UTC")
now("Asia/Tokyo")
```

---

### make_datetime() / make_date()

```r
# Create from components
make_date(year = 2024, month = 3, day = 15)
# Result: 2024-03-15

make_datetime(
  year = 2024, month = 3, day = 15,
  hour = 14, min = 30, sec = 45,
  tz = "UTC"
)
# Result: 2024-03-15 14:30:45 UTC

# Vectorized
years <- c(2024, 2024, 2024)
months <- c(1, 2, 3)
days <- c(15, 20, 25)

make_date(year = years, month = months, day = days)

# Practical: construct from separate columns
data |>
  mutate(
    date = make_date(year, month, day),
    datetime = make_datetime(year, month, day, hour, minute, second)
  )
```

---

### date() - Extract Date from Datetime

```r
# Get date part only
dt <- ymd_hms("2024-03-15 14:30:45")
date(dt)
# Result: 2024-03-15

# Practical: group by date
logs |>
  mutate(date = date(timestamp)) |>
  group_by(date) |>
  summarize(count = n())
```

---

### leap_year()

```r
# Check if leap year
leap_year(2024)  # TRUE
leap_year(2023)  # FALSE
leap_year(2000)  # TRUE
leap_year(1900)  # FALSE

# Vectorized
years <- 2020:2025
leap_year(years)
# Result: c(TRUE, FALSE, FALSE, FALSE, TRUE, FALSE)

# Practical: adjust for leap years
dates |>
  mutate(
    is_leap = leap_year(year(date)),
    days_in_year = if_else(is_leap, 366, 365)
  )
```

---

## Practical Workflows

### Age Calculation

```r
# Calculate precise age
birth_date <- ymd("1990-03-15")
age <- today() - birth_date
age_years <- as.numeric(age, "days") / 365.25

# Or using intervals
age_interval <- birth_date %--% today()
age_years <- age_interval / years(1)

# Complete workflow
people |>
  mutate(
    age_days = as.numeric(today() - birth_date, "days"),
    age_years = floor(age_days / 365.25),
    age_period = as.period(today() - birth_date)
  )
```

---

### Business Days

```r
# Calculate business days between dates
# (requires additional package like bizdays)

# Simple version (excluding weekends)
dates <- seq(ymd("2024-01-01"), ymd("2024-01-31"), by = "day")
business_days <- dates[wday(dates) %in% 2:6]  # Mon-Fri

# Count business days
data |>
  mutate(
    all_days = seq(start_date, end_date, by = "day"),
    business_days = map_int(all_days, ~ sum(wday(.x) %in% 2:6))
  )
```

---

### Fiscal Year

```r
# Fiscal year starting April 1
fiscal_year <- function(date) {
  year(date) + if_else(month(date) >= 4, 1, 0)
}

data |>
  mutate(
    fy = fiscal_year(date),
    fy_label = paste0("FY", fy)
  )

# Fiscal quarter
fiscal_quarter <- function(date) {
  m <- month(date)
  case_when(
    m %in% 4:6 ~ "Q1",
    m %in% 7:9 ~ "Q2",
    m %in% 10:12 ~ "Q3",
    TRUE ~ "Q4"
  )
}
```

---

### Time Since Event

```r
# Format time elapsed
time_since <- function(past_date) {
  diff <- as.numeric(today() - past_date, "days")

  case_when(
    diff < 1 ~ "Today",
    diff < 2 ~ "Yesterday",
    diff < 7 ~ paste(floor(diff), "days ago"),
    diff < 30 ~ paste(floor(diff / 7), "weeks ago"),
    diff < 365 ~ paste(floor(diff / 30), "months ago"),
    TRUE ~ paste(floor(diff / 365), "years ago")
  )
}

posts |>
  mutate(
    time_ago = time_since(post_date)
  )
```

---

### Recurring Events

```r
# Generate monthly recurring dates
start <- ymd("2024-01-15")
end <- ymd("2024-12-31")

recurring_dates <- seq(start, end, by = "month")

# Every 2 weeks
biweekly <- seq(start, end, by = "2 weeks")

# Quarterly
quarterly <- seq(start, end, by = "3 months")

# Practical: subscription billing dates
subscriptions |>
  mutate(
    billing_dates = map(start_date, ~ {
      seq(.x, .x + years(1), by = "month")
    })
  ) |>
  unnest(billing_dates)
```

---

## Best Practices

1. **Always specify timezone** - Especially for timestamps
2. **Use periods for human time** - months(1) not days(30)
3. **Use durations for exact time** - dhours(2) for precise calculations
4. **Parse dates early** - Convert strings to dates at import
5. **Store in UTC** - Convert to local timezone for display only
6. **Handle NA dates explicitly** - Check for parsing failures
7. **Use floor_date() for grouping** - More reliable than extracting parts
8. **Consider leap years** - Use periods, not fixed day counts
9. **Document timezone assumptions** - Especially for international data
10. **Test edge cases** - Month end dates, leap years, DST changes

---

## Common Pitfalls

1. **Mixing periods and durations** - They behave differently
2. **Not specifying timezone** - Defaults may cause issues
3. **Assuming 365 days/year** - Use periods or account for leap years
4. **Not handling DST** - Daylight saving time can cause issues
5. **Using wrong parsing function** - Match format to function (ymd, mdy, dmy)
6. **Forgetting to handle NA** - Parsing failures return NA
7. **Month arithmetic errors** - Jan 31 + 1 month = Feb 28/29, not Mar 3
8. **Comparing dates with times** - Truncate times first if needed

---

## Quick Reference Card

| Task | Function | Example |
|------|----------|---------|
| Parse YMD | `ymd()` | `ymd("2024-01-15")` |
| Parse MDY | `mdy()` | `mdy("01/15/2024")` |
| Parse DMY | `dmy()` | `dmy("15-01-2024")` |
| With time | `ymd_hms()` | `ymd_hms("2024-01-15 10:30:45")` |
| Current date | `today()` | `today()` |
| Current datetime | `now()` | `now()` |
| Extract year | `year()` | `year(date)` |
| Extract month | `month()` | `month(date)` |
| Extract day | `day()` | `day(date)` |
| Weekday | `wday()` | `wday(date, label = TRUE)` |
| Add days | `+ days()` | `date + days(7)` |
| Add months | `+ months()` | `date + months(1)` |
| Floor | `floor_date()` | `floor_date(dt, "month")` |
| Ceiling | `ceiling_date()` | `ceiling_date(dt, "day")` |
| Round | `round_date()` | `round_date(dt, "hour")` |
| Duration | `dhours()` | `now() + dhours(2)` |
| Period | `hours()` | `today() + months(1)` |
| Interval | `%--% ` | `start %--% end` |
| Within interval | `%within%` | `date %within% interval` |
| Convert TZ | `with_tz()` | `with_tz(dt, "UTC")` |
| Force TZ | `force_tz()` | `force_tz(dt, "UTC")` |
| Make date | `make_date()` | `make_date(2024, 3, 15)` |
| Extract date | `date()` | `date(datetime)` |
| Leap year | `leap_year()` | `leap_year(2024)` |
