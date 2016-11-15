# MKLocalSearchLimitsDemo

Xcode 8.1, Swift 3.0.1

## What the app does

Demonstrates apparent search limits for MKLocalSearch processing.

The app performs two individual searches: one for "coffee", and one for "grocery". These two searches demonstrate that individual searches are limited to 10 results.

Next, the app runs 151 non-identical location searches for each of "coffee" and "grocery". In addition to only receiving 10 results from any one search, this step demonstrates that searches do indeed get throttled.

The app displays an alert when all searches have completed.


## Setup

Clone the app and run it. The selected simulator will open, but the important information is in the debug prints.

