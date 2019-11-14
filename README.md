# ccLib


Some useful Delphi units and components offered by Cornelius Concepts, LLC.

----------

This library contains units and components I've developed that come in handy in many situations. But they go beyond just being useful--they also teach. There are comments and samples, and the components show several aspects of how to write Delphi components, such the separation of packages between run-time and design-time, how to integrate component help activated by right-clicking on the component, and even integration into Delphi's splash screen and About box. 

First, a word about the stand-alone units.

## WebGen

This folder contains two units, udmCustomWebGenerator and udmDBISAMWebGenerator. They are Data Modules and the first is a base class with a couple of WebBroker components, a TPageProducer and TDataSetTableProducer. These were written many years ago before Content Management Systems (CMSs) were popular and I was trying to use Delphi for all my web development. It turned out to be more work than it's worth for large projects and there are vast number of great web tools out there now, so it's not used much anymore.  However, there are still occasional tasks that find these routines useful, so I keep them around. 

These classes expand the WebBroker usefulness by building in a link between HTML tags and databases. The only database I ever used in this fashion was DBISAM. I haven't used DBISAM for several years, so I don't know if it still compiles, but it does show how the base class can be descended for your particular needs.

Please read the comments in the code for further information.

## Miscellaneous

The "misc" folder contains three units (more may be added later): **uSearchRecList**, **uXmlDates**, and **uTestUtils**. 

The first one, **uSearchRecList**, contains a couple of procedure type declarations and one procedure: GetSearchRecs.

    TPathStatusProc = reference to procedure (const Path: string; var Stop: Boolean);
	TFileFoundProc = reference to procedure (FileInfo: TSearchRec);
	procedure GetSearchRecs(const Path, Pattern: string; const Recursive: Boolean; PathStatusProc: TPathStatusProc; FileFoundProc: TFileFoundProc);

GetSearchRecs traverses a directory tree looking for files matching a pattern and calls PathStatusProc for every path found and FileFoundProc for every file found that matches the pattern.

Here's an example call that would delete old log files:

    GetSearchRecs(LogFolder, '*.log', False, nil, 
		procedure (FileInfo: TSearchRec)
		begin
		  if FileInfo.TimeStamp < Now - 90 then
			FileDelete(TPath.Combine(LogFolder, FileInfo.Name), True);
		end);

The second unit, **uXmlDates**, makes it easy to work with dates found in XML files. The common format is: yyyy-mm-dd"T"hh:mm:ss, but the method, ConvertToDelphiDateFromXml, can take a string without the time part.

The third unit, **uTestUtils**, provides some functions used in a few projects where I need to generate test data such as dates, times, numbers, payment types, etc.  They're just handy to have around.

## Component: LayoutSaver

Simply drop this component on a form and it's size and position are automatically saved when closed and restored when opened. Additionally save other values with convenient methods. There are two variations:

* **ccRegistryLayoutSaver** - saves settings to the windows registry, under the CURRENT_USER/SOFTWARE key.
* **ccIniLayoutSaver** - saves settings to an INI file (text file with NAME=Value pairs). You can control where the file lives or set it to the default of the application data path.

Both of these components have defaults to save files or registry settings in appropriate places with minimal settings and create keys or sections based on the name of the form. So you can quickly and easily drop one of these components on each form.

With the additional methods for saving/restoring integer, string, and Boolean values, it makes remembering simple user data very easy:

    - procedure SaveStrValue(const Name:string;const Value:string); 
    - procedure SaveIntValue(const Name:string;const Value: Integer); 
    - procedure SaveBoolValue(const Name:string;const Value: Boolean); 
    - function RestoreStrValue(const Name:string; const Default: string = ''):string; 
    - function RestoreIntValue(const Name:string; const Default: Integer = 0): Integer; 
    - function RestoreBoolValue(const Name:string; const Default: Boolean = False): Boolean;

## Component: CloseApplication

This component includes routines written by someone named Neil on the DBISAM newsgroups several years ago. Turned into a component, this attaches to some keyboard and mouse Windows hooks to watch for inactivity on the computer and pops up a message with a count-down timer to close the application.  One use case is a 2-tier database applications that leave files and records open.

## Component: ElapsedTimer (DEPRECATED)

*This component was removed from the Delphi 10.3 Rio version in favor of using Delphi's TStopWatch class.*

This is a very simple component that hides the details of timing an operation.  Simply call Start, do your stuff, then call Stop and you have the following properties available:

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

### Component: ccDBISAMTableLookup (DEPRECATED)

A long time ago, I used the InfoPower suite of components which had a really nice incremental search component that would list matching records as you type.  I patterned this component off that idea but also added user-defined buttons and many other features. I also used Raize Controls for some extra nice display features--and tied it all very closely to the DBISAM database components. It was for a specific project at the time, but I used it and variations of it (like switching out DBISAM for ElevateDB components) in other projects since then.

This might be an interesting component to look at because it's a good example of how to build a compound component.

### Component: ccTextMerge (DEPRECATED)

Written to support an old project many years ago, this allows simple merging of NAME=VALUE pairs with delimiters. Deprecated in favor of using TStringList.

### Component: ccTextFileLogger (DEPRECATED)

Provides quick and easy logging to a text file. Deprecated because newer libraries and methods of logging are preferred.

### Component: ccTextViewer (DEPRECATED)

A simple text file viewer in a pop-up modal window.
