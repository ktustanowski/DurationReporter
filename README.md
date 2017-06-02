# DurationReporter
Have you ever wanted to know how long:
* does it take for you app to finish initial configuration
* user has to wait after tapping play to actually see the video
* your view controller is doing stuff before user can see it

Measuring how long does it take for a function to *do stuff* is easy. Measuring duration of whole **flows** in the application is much more complex. Especially if it has to work across different components and screens. 

Take a look at this console log. If this looks useful to you keep reading. You will see how easy you can generate similar reports with **DurationReporter**.
```
🚀 Application Start - 3207ms
1. Loading 1006ms 31.37%
2. Loading Home 2001ms 62.39%
3. Preparing Home 200ms 6.24%

🚀 Video - 33003ms
1. Loading 2001ms 6.06%
2. Buffering 1001ms 3.03%
3. Playing 30001ms 90.90%

🚀 Share Video - 1302ms
1. Loading providers 501ms 38.48% 
2. Sending 801ms 61.52% 
```

# How it works
1. Indicate that event started. 
1. Indicate that event ended. 

💥 and it's done

## Simple reporting
First you indicate action start:

```
DurationReporter.begin(event: "ApplicationStart", action: "Setup")
```

When it's done you indicate that action did end:

```
DurationReporter.end(event: "ApplicationStart", action: "Setup")
```

When you want to see the results you just print the report:
```
print(DurationReporter.generateReport())
```
```
🚀 ApplicationStart - 1005ms
1. Setup 1005ms 100.00%
```
You can also retrieve raw collected data:
```
let collectedData = DurationReporter.reportData()
```
and use it to create custom report that suits your needs best.

## Reporting with custom payload
There might be sutuations like:
* making reporting calls to analytics after report is finished
* making more detailed reports

where passing event and action name `just won't be enough`. For situations like this you can pass your custom `payload` on `begin` & `end`. Then you just have to retrieve this payload from report using `beginPayload` and `endPayload`.
```
DurationReporter.begin(event: "Video", action: "Watch", payload: "Sherlock S01E01")
[...]
DurationReporter.end(event: "Video", action: "Watch")
[...]
DurationReporter.begin(event: "Video", action: "Watch", payload: "Sherlock S01E02")
[...]
DurationReporter.end(event: "Video", action: "Watch")
[...]
DurationReporter.begin(event: "Video", action: "Watch", payload: "Sherlock S01E03")
[...]
DurationReporter.end(event: "Video", action: "Watch")
```
In normal report you will see no difference
```
🚀 Video - 3009ms
1. Watch 1007ms 33.47%
2. Watch2 1001ms 33.27%
3. Watch3 1001ms 33.27%
```
But if you replace default reporting algorithm with slightly modified version (just add `\((report.beginPayload as? String) ?? "")` when reporting actions) you will see this:
```
🚀 Video - 3009ms
1. Watch 1007ms 33.47% Sherlock S01E01
2. Watch2 1001ms 33.27% Sherlock S01E02
3. Watch3 1001ms 33.27% Sherlock S01E03
```
## Grouped reporting
Events gathers actions so instead of just knowing how long did whole application configuration take we can do this:
```
[...]
DurationReporter.begin(event: "ApplicationStart", action: "Load config from API")
[...]
DurationReporter.end(event: "ApplicationStart", action: "Load config from API")
[...]
DurationReporter.begin(event: "ApplicationStart", action: "Save configuration")
[...]
DurationReporter.end(event: "ApplicationStart", action: "Save configuration")
[...]
```
And the result:
```
🚀 ApplicationStart - 3041ms
1. Load config from API 2041ms 67.12%
2. Save configuration 1000ms 32.88%
```
## Grouped reporting with duplications
Duplication is possible only when previous action of this kind is completed. Starting two identical actions at the same time is impossible. There is no way to determine which one should be completed when `DurationReporter.end` is called.
When one action ends another identical can be reported:

```
DurationReporter.begin(event: "Video", action: "Play")
[...]
DurationReporter.end(event: "Video", action: "Play")
[...]
DurationReporter.begin(event: "Video", action: "Play")
[...]
DurationReporter.end(event: "Video", action: "Play")
[...]
DurationReporter.begin(event: "Video", action: "Play")
[...]
DurationReporter.end(event: "Video", action: "Play")

```
Duplicated actions have 2, 3, 4... suffix:
```
🚀 Video::SherlockS01E01 - 3008ms
1. Play 1006ms 33.44%
2. Play2 1001ms 33.28%
3. Play3 1001ms 33.28%
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
ApplicationStart::Load config from API 🚀
ApplicationStart::Load config from API 🎉
ApplicationStart::Save configuration 🚀
ApplicationStart::Save configuration 🎉

🚀 ApplicationStart - 3007ms
1. Load config from API 2006ms 66.71%
2. Save configuration 1001ms 33.29%
```
This is just simple example of how to add simple console logging. But why just print to console when we can do so much better i.e.:
```
DurationReporter.onReportEnd = { name, report in /* send report to analytic tool */ }
DurationReporter.onReportEnd = { name, report in /* persist report in local / external storage */ }
```
## Lost actions
If action is not completed it appear with 🔴 in report:
```
🚀 ApplicationStart - 2006ms
1. Load config from API 2006ms 100.00%
2. 🔴 Save configuration - ?
```
## Clear
You can purge current reporting data and start collecting new one:
```
DurationReporter.clear()
```
