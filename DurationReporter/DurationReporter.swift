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
    public static var onReportStart: ((String, DurationReport) -> ())?
    /// Called right after report .end()
    public static var onReportEnd: ((String, DurationReport) -> ())?
    
    /// Begin time tracking. Supports multiple actions grouping. When added action that was already
    /// tracked 1, 2, 3... will be added to action name to indicate this fact. Another action can be 
    /// added only after the previous one is finished. Tracking `Buffering`, `Loading` at the same time 
    /// is fine but to track another `buffering` the first one must complete first.
    ///
    /// - Parameters:
    ///   - event: action group name i.e Video_Identifier::Play
    ///   - action: concrete action name i.e. Buffering, ContentLoading etc.
    public static func begin(event: String, action: String) {
        var eventReports = reports[event] ?? []
        let actionReports = eventReports.filter({ $0.title.contains(action) })
        let similarProcessIsTracked = actionReports.filter({ $0.duration == nil }).count > 0
        
        guard !similarProcessIsTracked else {
            print("Can't add action - another \(action) is already tracked.")
            return }
        
        let actionCount = actionReports.count
        
        var actionUniqueName = action
        if actionCount > 0 {
            actionUniqueName += "\(actionCount + 1)"
        }
        
        let report = DurationReport(title: actionUniqueName)
        report.begin()
        onReportStart?(event, report)
        eventReports.append(report)
        
        reports[event] = eventReports
    }
    
    /// Finish time tracking.
    ///
    /// - Parameters:
    ///   - event: action group name i.e Video_Identifier::Play
    ///   - action: concrete action name i.e. Buffering, ContentLoading etc.
    public static func end(event: String, action: String) {
        let eventReports = reports[event]
        let report = eventReports?.filter({ $0.title.contains(action) && !$0.isComplete }).last
        report?.end()
        
        guard let properReport = report else {
            print("Can't end process - \(action) didn't find.")
            return
        }
        
        onReportEnd?(event, properReport)
    }
    
    /// Generate report string from collected data
    ///
    /// - Returns: report string
    public static func report() -> String {
        var output = ""
        reports.forEach { event, reports in
            output += "=======================================\n"
            output += "\(event) [\(reports.count)]\n"
            output += "=======================================\n"
            reports.forEach({ report in
                output += ":: \(report.title) duration: \(String(describing: report.duration))\n"
            })
        }
        return output
    }
}
