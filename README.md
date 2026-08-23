# ccLib

[![RAD Studio](https://img.shields.io/badge/RAD%20Studio-Delphi-red.svg)](https://www.embarcadero.com/products/rad-studio)
[![Platform](https://img.shields.io/badge/Platform-Windows-blue.svg)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Some useful Delphi units and components offered by Cornelius Concepts, LLC.

## Components

### LayoutSaver

Simply drop a component onto a VCL form and it's size and position are automatically saved when closed and restored when opened. Additionally save other values with convenient methods. There are two variations:

* **`TccRegistryLayoutSaver`** - saves settings to the windows registry, under the HKCU/SOFTWARE key.
* **`TccIniLayoutSaver`** - saves settings to an INI file (text file with NAME=Value pairs). You can control where the file lives or set it to the default of the application data path.

Additional methods for saving/restoring integer, string, and Boolean values makes remembering simple user data very easy:

  - `procedure SaveStrValue(const Name:string;const Value:string);`
  - `procedure SaveIntValue(const Name:string;const Value: Integer);`
  - `procedure SaveBoolValue(const Name:string;const Value: Boolean);`
  - `function RestoreStrValue(const Name:string; const Default: string = ''):string;`
  - `function RestoreIntValue(const Name:string; const Default: Integer = 0): Integer;`
  - `function RestoreBoolValue(const Name:string; const Default: Boolean = False): Boolean;`

### CloseApplication

This includes routines written by someone named Neil on the DBISAM newsgroups several years ago. Turned into a `TCloseApplication` component that can be dropped on the main form of a VCL application, it attaches to some keyboard and mouse Windows hooks to watch for inactivity on the computer and pops up a message with a count-down timer to close the application.  One use case is a 2-tier database applications that leave files and records open.

## Units

### XmlDates

This small single-unit library makes it easy to work with dates found in XML files. The common format is: `yyyy-mm-dd"T"hh:mm:ss`, but the method, `ConvertToDelphiDateFromXml`, can take a string without the time part.

### TestUtils

This single-unit library provides some functions used in a few projects where I needed to generate test data such as dates, times, numbers, payment types, etc.  They're just handy to have around. However, for a rich set of test data generators, please check out the  [Delphi Fake Data Utils](https://github.com/danieleteti/delphi_fake_data_utils) repository by Daniele Teti.

### SearchRecList

The **`uSearchRecList`** unit, contains a couple of procedure type declarations and one procedure: `GetSearchRecs`.

    TPathStatusProc = reference to procedure (const Path: string; var Stop: Boolean);
	TFileFoundProc = reference to procedure (FileInfo: TSearchRec);
	procedure GetSearchRecs(const Path, Pattern: string; const Recursive: Boolean; PathStatusProc: TPathStatusProc; FileFoundProc: TFileFoundProc);

**`GetSearchRecs`** traverses a directory tree looking for files matching a pattern and calls `PathStatusProc` for every path found and `FileFoundProc` for every file found that matches the pattern.

Here's an example call that would delete old log files:

    GetSearchRecs(LogFolder, '*.log', False, nil,
		procedure (FileInfo: TSearchRec)
		begin
		  if FileInfo.TimeStamp < Now - 90 then
			FileDelete(TPath.Combine(LogFolder, FileInfo.Name), True);
		end);


## To Build

These components support every version of Delphi from version 5 up to the latest Delphi 13 Florence (I no longer have access to Delphi 6, 2009, or 2010 to test with but I'm sure those will work just fine). There are project groups containing packages for each of these up to Delphi 12 Athens. After that, the packages support auto-numbering so we don't really need specific packages for the newer versions of Delphi; therefore, I renamed the project group for Delphi 12 to "Delphi12plus" meaning that you can use the same packages for Delphi 12 Athens, Delphi 13 Florence, and future versions of Delphi.

Simply load the package group for your version of Delphi, compile both run-time (`ccLib_R`) and design-time (`ccLib_D`), then install the design-time one and you're set to go. The run-time package has a Build Event to copy the `.dfm` for the `AppIdleWarn` form out to the BPL folder so it'll be found when compiling/linking.

## DPM

Support has been added for [DPM](https://docs.delphi.dev/). To add as your own local packages, run `dpm pack ccLib.dspec` from the `Packages` folder, then call `dpm push ccLib.Utils-delphi<version>.dpkg` for each generated package of the compiler(s) you need. 

---

## Deprecated

The following components are no longer supported and have been removed from recent packages.

#### ElapsedTimer (DEPRECATED)

*This component was removed from the Delphi 10.3 Rio package (and newer) in favor of using Delphi's TStopWatch class.*

This is a very simple component that hides the details of timing an operation.  Simply call Start, do your stuff, then call Stop and you have the following properties available:

* ElapsedTime: TDateTime
* ElapsedSeconds: Double
* ElapsedMinutes: Double
* ElapsedHours: Double
* ElapsedDays: Double
* ElapsedMonths: Double
* ElapsedYears: Double

This component does NOT check for change in time zones (if used on a mobile device) or account for Daylight Savings Time. It was designed for fairly short operations (less than an hour).

#### ccDBISAMTableLookup (DEPRECATED)

*This component was only supported up through Delphi XE and removed from newer packages.*

A long time ago, I used the InfoPower suite of components which had a really nice incremental search component that would list matching records as you type.  I patterned this component off that idea but also added user-defined buttons and many other features. I also used Raize Controls for some extra nice display features--and tied it all very closely to the DBISAM database components. It was for a specific project at the time, but I used it and variations of it (like switching out DBISAM for ElevateDB components) in other projects since then.

This might be an interesting component to look at because it's a good example of how to build a compound component.

#### ccTextMerge (DEPRECATED)

*This component was only supported up through Delphi XE and removed from newer packages.*

Written to support an old project many years ago, this allows simple merging of NAME=VALUE pairs with delimiters. Deprecated in favor of using `TStringList`.

#### ccTextFileLogger (DEPRECATED)

Provides quick and easy logging to a text file. Deprecated because newer libraries and methods of logging are preferred. 

Here are some alternatives:

- [LoggerPro](https://github.com/danieleteti/loggerpro)
- [QuickLib.Log](https://github.com/exilon/QuickLib/blob/master/Quick.Log.pas)

### Component: ccTextViewer (DEPRECATED)

A simple text file viewer in a pop-up modal window.

----------

Finally, a word about a very old set of classes built to extend the [WebBroker](https://docwiki.embarcadero.com/RADStudio/Seattle/en/Creating_Web_Broker_Applications) technology.

## WebGen

This folder contains two units, udmCustomWebGenerator and udmDBISAMWebGenerator. They are Data Modules and the first is a base class with a couple of WebBroker components, a TPageProducer and TDataSetTableProducer. These were written many years ago before Content Management Systems (CMSs) were popular and I was trying to use Delphi for all my web development. It turned out to be more work than it's worth for large projects and there are vast number of great web tools out there now (like [WebStencils](https://docwiki.embarcadero.com/RADStudio/Florence/en/WebStencils)), so it's not used anymore.  However, there are still occasional tasks that find these routines useful, so I keep them around.

These classes expand the WebBroker usefulness by building in a link between HTML tags and databases. The only database I ever used in this fashion was DBISAM. I haven't used DBISAM for several years, so I don't know if it still compiles, but it does show how the base class can be descended for your particular needs.

Please read the comments in the code for further information.

