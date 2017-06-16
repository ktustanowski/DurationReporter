//: Playground - noun: a place where people can play

import Foundation
import DurationReporter

DurationReporter.begin(event: "Application Start", action: "Loading", payload: "🚀")
sleep(1)
DurationReporter.end(event: "Application Start", action: "Loading", payload: "💥")

DurationReporter.begin(event: "Application Start", action: "Loading Home")
sleep(2)
DurationReporter.end(event: "Application Start", action: "Loading Home")

DurationReporter.begin(event: "Application Start", action: "Preparing Home")
usleep(200000)
DurationReporter.end(event: "Application Start", action: "Preparing Home")

DurationReporter.begin(event: "Problematic Code", action: "Executing 💥")
/* no end event for Problematic Code on purpose */

// Print regular / default report
print(":: Default report")
print(DurationReporter.generateReport())

print(":: Custom report #1")
// Print regular / default report
let collectedData = DurationReporter.reportData()
collectedData.forEach { eventName, reports in
    reports.enumerated().forEach { index, report in
        if let reportDuration = report.duration {
            print("\(eventName) → \(index). \(report.title) \(reportDuration)ns \((report.beginPayload as? String) ?? "") \((report.endPayload as? String) ?? "")")
        } else {
            print("\(eventName) → \(index). 🔴 \(report.title) - ?\n")
        }
        
    }
}

print("\n:: Custom report #2")
// Print regular / default report
DurationReporter.reportGenerator = { collectedData in
    var output = ""
    collectedData.forEach { eventName, reports in
        reports.enumerated().forEach { index, report in
            if let reportDuration = report.duration {
                output += "\(eventName) → \(index). \(report.title) \(reportDuration)ns\n"
            } else {
                output += "\(eventName) → \(index). 🔴 \(report.title) - ?\n"
            }
        }
    }
    return output
}

print(DurationReporter.generateReport())
