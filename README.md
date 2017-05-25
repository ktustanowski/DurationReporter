# DurationReporter
Have you ever wanted to know how long:
* does it take for you app to finish initial configuration
* user has to wait after tapping play to actually see the video
* your view controller is `doing stuff` before user can see it

Measuring how long does it take for a function to *do stuff* is easy. But measuring duration of whole *flows* in the application is much more complex. Especially if it has to work across different classes. When you just want to measure this stuff once... well... it's fine. It can be messy because it won't make to production codebase. 

But what if you want to measure this times constantly? What if you also want to report them to some analytics tool? Or you just want print the report to have all the data in one place. Ready to be analyzed.

Then it gets really messy. All this dates, measurements, lots of additional code. Then you have to make a report out of it or just scan the console for printouts. *Been there, done that* ☹️ thats why I created *Duration Reporter*. It's only purpose is to make measuring duration of *flows* fast & easy 🚀.

# How it works
## Simple reporting
First you indicate action start:

```
DurationReporter.begin(event: "ApplicationStart", action: "setup")
```

When it's done you indicate that action did end:

```
DurationReporter.end(event: "ApplicationStart", action: "setup")
```

When you want to see the results you just print the report:
```
print(DurationReporter.report())
```
```
   ApplicationStart [1]
⏱ setup - 5006 ms
```
You can also retrieve raw collected data:
```
let collectedData = DurationReporter.reportData()
```
and use it to create custom report that suits your needs best.

## Grouped reporting
Events gathers actions so instead of just knowing how long did whole application configuration take we can do this:
```
[...]
DurationReporter.begin(event: "ApplicationStart", action: "load config from API")
[...]
DurationReporter.end(event: "ApplicationStart", action: "load config from API")
[...]
DurationReporter.begin(event: "ApplicationStart", action: "save configuration")
[...]
DurationReporter.end(event: "ApplicationStart", action: "save configuration")
[...]
```
And the result:
```
   ApplicationStart [3]
⏱ load config from API - 2008 ms
⏱ save configuration - 1000 ms
```
## Grouped reporting with duplications
Duplication is possible only when previous action of this kind is completed. Starting two identical actions at the same time is impossible. There is no way to determine which one should be completed when `DurationReporter.end` is called.
When one action ends another identical can be reported:

```
DurationReporter.begin(event: "Video::SherlockS01E01", action: "play")
[...]
DurationReporter.end(event: "Video::SherlockS01E01", action: "play")
[...]
DurationReporter.begin(event: "Video::SherlockS01E01", action: "play")
[...]
DurationReporter.end(event: "Video::SherlockS01E01", action: "play")
[...]
DurationReporter.begin(event: "Video::SherlockS01E01", action: "play")
[...]
DurationReporter.end(event: "Video::SherlockS01E01", action: "play")

```
Duplicated actions have 2, 3, 4... suffix:
```
  Video::SherlockS01E01 [3]
⏱ play - 1007 ms
⏱ play2 - 1001 ms
⏱ play3 - 1001 ms
```

## Handling report begin & end
Right after dispatching `begin` for action
```
public static var onReportBegin: ((String, DurationReport) -> ())?
```
closure is called. After dispatching `end` for action
```
public static var onReportEnd: ((String, DurationReport) -> ())?
```
is called.
This basically mean that you can make custom actions while report is being created. Let's consider the example with application configuration again but let's set this two closures before
```
DurationReporter.onReportBegin = { name, report in print("\(name)::\(report.title) 🚀") }
DurationReporter.onReportEnd = { name, report in print("\(name)::\(report.title) 🎉") }
```
and the result we get:
```
ApplicationStart::load config from API 🚀
ApplicationStart::load config from API 🎉
ApplicationStart::save configuration 🚀
ApplicationStart::save configuration 🎉
   ApplicationStart [2]
⏱ load config from API - 1005 ms
⏱ save configuration - 1001 ms
```
This is just simple example of how to add simple console logging. But why just print to console when we can do so much better i.e.:
```
DurationReporter.onReportEnd = { name, report in /* send report to analytic tool */ }
DurationReporter.onReportEnd = { name, report in /* persist report in local / external storage */ }
```
## Lost actions
If action is not completed it appear with 🔴 in report:
```
   ApplicationStart [2]
⏱ load config from API - 1000 ms
🔴 save configuration - ? ms
```
## Clear
You can purge current reporting data and start collecting new one:
```
DurationReporter.clear()
```
