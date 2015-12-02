# ccComponents


Some useful Delphi components along with IDE about screen registration.

----------

Not only are the following components useful, they also show several aspects of how to write Delphi components. They include separate packages for run-time and design-time properties, component help activated by right-clicking on the component, and even integration into Delphi's splash screen and About box. 

## LayoutSaver

Simply drop this component on a form and it's size and position are automatically saved when closed and restored when opened. Additionally save other values with convenient methods. There are two variations:

* ccRegistryLayoutSaver - saves settings to the windows registry, under the CURRENT_USER/SOFTWARE key.
* ccIniLayoutSaver - saves settings to an INI file (text file with NAME=Value pairs). You can control where the file lives or set it to the default of the application data path.

Both of these components have defaults to save files or registry settings in appropriate places with minimal settings and create keys or sections based on the name of the form. So you can quickly and easily drop one of these components on each form.

With the additional methods for saving/restoring integer, string, and boolean values, it makes remembering user data very easy.

## IdleClose

This component includes routines written by someone named Neil on the DBISAM newsgroups several years ago. Turned into a component, this attaches to some keyboard and mouse Windows hooks to watch for inactivity on the computer and pops up a message with a count-down timer to close the application.  This can be useful for 2-tier database applications that leave files and records open.

## ElapsedTimer

This is a very simple component that hides the details of timeing an operation.  Simply call Start, do your stuff, then call Stop and you have the following properties available:

* ElapsedTime: TDateTime
* ElapsedSeconds: Double
* ElapsedMinutes: Double
* ElapsedHours: Double
* ElapsedDays: Double
* ElapsedMonths: Double
* ElapsedYears: Double

This component does NOT check for change in time zones (if used on a mobile device) or account for Daylight Savings Time. It was designed for fairly short operations (less than an hour). 

## Other Components

The following components were only supported up through Delphi XE and removed from newer packages.

### ccDBISAMTableLookup

A long time ago, I used the InfoPower suite of components which had a really nice incremental search component that would list matching records as you type.  I patterned this component off that idea but also added user-defined buttons and many other features. I also used Raize Controls for some extra nice display features--and tied it all very closely to the DBISAM database components. It was for a specific project at the time, but I used it and variations of it (like switching out DBISAM for ElevateDB components) in other projects since then.

This might be an interesting component to look at because it's a good example of how to build a compound component.

### ccTextMerge

Written to support an old project many years ago, this allows simple merging of NAME=VALUE pairs with delimters. Obsoleted in favor of using TStringList.

### ccTextFileLogger

Provides quick and easy logging to a text file. Deprecated because newer libraries and methods of logging are preferred.

### ccTextViewer

A simple text file viewer in a pop-up modal window.