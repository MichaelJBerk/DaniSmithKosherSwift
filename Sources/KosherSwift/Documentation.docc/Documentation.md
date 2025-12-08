# ``KosherSwift``

A Swift version of KosherJava
Heavily referenced KosherDart, which I also previously contributed to.

Also check out [KosherCocoa](https://github.com/MosheBerman/KosherCocoa) (an Objective C port) and the other [KosherSwift](https://github.com/Elyahu41/KosherSwift) that I didn't know existed when I created this.

## Overview

There is still a small handfull of things I would like to add, but this library is definitely usable. I am in the process of implementing KosherSwift into my app, [YidKit](http://yidkit.com).

If you've got any enhancements to offer, bugs to fix, or general contributions, feel free to contact me with a pull request or an email.

## Topics

### Zmanim
Calculate times for Zmanim

- ``ZmanimCalendar``
- ``ComplexZmanimCalendar``
- ``Molad``
- ``MoladDate``
- ``GeoLocation``

### Jewish Calendar & Holidays
Calculate the dates for Jewish holidays, Daf Yomi, and Parasha 

- ``JewishCalendar``
- ``DafYomiCalculator``
- ``Parsha``
- ``Daf``
- ``DafType``
- ``JewishDate``
- ``JewishMonth``
- ``JewishHoliday``
- ``HebrewDateFormatter``
- ``HebrewFormatterError``
- ``DayOfWeek``

### Astonomical Calculations
Calculate non-religious astronomical times

- ``AstronomicalCalendar``
- ``AstronomicalCalculator``
- ``AstronomicalCalculatorConstants``
- ``NOAACalculator``
- ``Zenith``

### Tefilla
Determine which Tefillos are said on a given day

- ``TefilaRules``
