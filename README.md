# DurationReporter
Have you ever wanted to know how long:
* does it take for you app to finish initial configuration
* user has to wait after tapping play to actually see the video
* your view controller is `dong stuff` before user can see it

Measuring how long does it take for a function to *do stuff* is easy. But measuring duration of whole *flows* in the application is much more complex. Especially if it has to work across different classes. When you just want to measure this stuff once... well... it's fine. It can be messy because it won't make to production codebase. 

But...

What if you want to measure this times constantly? What if you also want to report them to some analytics tool? Or you just want print the report to have all the data in one place. Ready to be analyzed.

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
   ApplicationStart [2]
⏱ setup - 5006 ms
```
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
