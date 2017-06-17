//  MIT License
//
//  Copyright (c) 2017 ktustanowski
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.//
//  DispatchQueue+Once.swift
//  SwiftyOnce
//
//  Created by Kamil Tustanowski on 20.01.2017.
//  Copyright © 2017 ktustanowski. All rights reserved.
//

import Foundation

public struct DurationReporter {
    
    fileprivate static var reports: [String : [DurationReport]] = [:]
    
    /// Called right after report .begin()
    public static var onReportBegin: ((String, DurationReport) -> ())?
    /// Called right after report .end()
    public static var onReportEnd: ((String, DurationReport) -> ())?
    
    public static var timeUnit: DurationUnit = Millisecond()
    
    /// Begin time tracking. Supports multiple actions grouping. When added action that was already
    /// tracked 2, 3, 4... will be added to action name to indicate this fact. Another action can be
    /// added only after the previous one is finished. Tracking `Buffering`, `Loading` at the same
    /// time is fine but to track another `Buffering` the first one must complete first.
    ///
    /// - Parameters:
    ///   - event: action group name i.e Video_Identifier::Play
    ///   - action: concrete action name i.e. Buffering, ContentLoading etc.
    public static func begin(event: String, action: String, payload: Any? = nil) {
        var eventReports = reports[event] ?? []
        let actionReports = eventReports.filter({ $0.title.contains(action) })
        let actionAlreadyTracked = actionReports.filter({ $0.duration == nil }).count > 0
        
        guard !actionAlreadyTracked else {
            print("Can't add action - another \(action) is already tracked.")
            return }
        
        let actionCount = actionReports.count
        
        var actionUniqueName = action
        if actionCount > 0 {
            actionUniqueName += "\(actionCount + 1)"
        }
        
        let report = DurationReport(title: actionUniqueName)
        report.beginPayload = payload
        report.begin()
        onReportBegin?(event, report)
        eventReports.append(report)
        
        reports[event] = eventReports
    }
    
    /// Finish time tracking.
    ///
    /// - Parameters:
    ///   - event: action group name i.e Video_Identifier::Play
    ///   - action: concrete action name i.e. Buffering, ContentLoading etc.
    public static func end(event: String, action: String, payload: Any? = nil) {
        let eventReports = reports[event]
        let report = eventReports?.filter({ $0.title.contains(action) && !$0.isComplete }).last
        report?.endPayload = payload
        report?.end()
        
        guard let properReport = report else {
            print("Can't end action - \(action) didn't find.")
            return
        }
        
        onReportEnd?(event, properReport)
    }
    
    /// Report generating closure
    /// - Returns: report string
    public static var reportGenerator: ([String : [DurationReport]]) -> (String) = {reports in
        var output = ""
        
        reports.forEach { eventName, eventReports in
            let eventDuration = eventReports.flatMap { $0.duration }
                .reduce(TimeInterval(0), +)
            let eventDurationToRound = Double(eventDuration * DurationReporter.timeUnit.perSecond)
            let eventDurationRounded = String(format: "%.f", eventDurationToRound)
            output += ("\n🚀 \(eventName) - \(eventDurationRounded)\(DurationReporter.timeUnit.symbol)\n")
            
            let maxTitleLength = eventReports.max(by: { $1.title.characters.count > $0.title.characters.count })?
                .title.characters.count ?? 0
            let maxCounterLength = String(eventReports.count).characters.count
            let maxDurationLength = String(format: "%.f", ((eventReports.flatMap{ $0.duration }.max(by: { $1 > $0 }) ?? 0) * DurationReporter.timeUnit.perSecond)).characters.count

            eventReports.enumerated().forEach { index, report in
                if let duration = report.duration {
                    let durationToRound = duration * DurationReporter.timeUnit.perSecond
                    let percentageRounded = String(format: "%.f", (duration / eventDuration) * 100.0)
                    let durationRounded = String(format: "%.f", durationToRound)
                    
                    let unifiedLengthTitle = report.title + String(repeating: " ", count: maxTitleLength - report.title.characters.count)
                    var counter = "\(index + 1)"
                    let unifiedLengthCounter = "\(counter)." + String(repeating: " ", count: maxCounterLength - counter.characters.count)
                    let unifiedLengthDuration = durationRounded + DurationReporter.timeUnit.symbol + String(repeating: " ", count: maxDurationLength - durationRounded.characters.count)
                    
                    output += "\(unifiedLengthCounter) \(unifiedLengthTitle) \(unifiedLengthDuration) \(percentageRounded)%\n"
                } else {
                    output += "\(index + 1). 🔴 \(report.title) - ?\n"
                }
                
            }
        }

        return output
    }
    
    /// Generate report from collected data
    ///
    /// - Returns: report string
    public static func generateReport() -> String {
        return reportGenerator(reports)
    }
    
    /// Provide collected data for further processing
    ///
    /// - Returns: collected data
    public static func reportData() -> [String : [DurationReport]] {
        return reports
    }
    
    /// Clear all gathered data
    public static func clear() {
        reports.removeAll()
    }
}
