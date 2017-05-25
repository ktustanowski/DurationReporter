//: Playground - noun: a place where people can play

import Foundation
import DurationReporter

DurationReporter.begin(event: "Video", action: "Buffering")
DurationReporter.end(event: "Video", action: "Buffering")

DurationReporter.begin(event: "Video", action: "Buffering")
sleep(1)
DurationReporter.end(event: "Video", action: "Buffering")

DurationReporter.begin(event: "Video", action: "Buffering")
sleep(2)
DurationReporter.end(event: "Video", action: "Buffering")

DurationReporter.begin(event: "Video", action: "Buffering")
DurationReporter.end(event: "Video", action: "Buffering")

DurationReporter.begin(event: "Video", action: "Buffering")
DurationReporter.end(event: "Video", action: "Buffering")

let report = DurationReporter.report()

print(report)


let collectedData = DurationReporter.reportData()