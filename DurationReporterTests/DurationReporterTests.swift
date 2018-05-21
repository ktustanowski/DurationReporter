//
//  DurationReportingFlowTests.swift
//  DurationReporter
//
//  Created by Kamil Tustanowski on 24.05.2017.
//  Copyright © 2017 ktustanowski. All rights reserved.
//

import XCTest
@testable import DurationReporter

class DurationReporterTests: XCTestCase {
    
    override func tearDown() {
        DurationReporter.clear()
        DurationReporter.onReportEnd = nil
        DurationReporter.onReportBegin = nil
        
        super.tearDown()
    }

    func testThatInformsWhenEventBegins() {
        var receivedEventName: String? = nil
        var receivedReport: DurationReport? = nil
        DurationReporter.onReportBegin = { eventName, report in
            receivedEventName = eventName
            receivedReport = report
        }
        
        DurationReporter.begin(event: "EventName", action: "TestAction")
        
        XCTAssertEqual(receivedEventName, "EventName")
        XCTAssertNotNil(receivedReport)
        XCTAssertEqual(receivedReport?.title, "TestAction")
    }

    func testThatInformsWhenEventEnds() {
        var receivedEventName: String? = nil
        var receivedReport: DurationReport? = nil
        DurationReporter.onReportEnd = { eventName, report in
            receivedEventName = eventName
            receivedReport = report
        }
        DurationReporter.begin(event: "EventName", action: "TestAction")
        
        DurationReporter.end(event: "EventName", action: "TestAction")
        
        XCTAssertEqual(receivedEventName, "EventName")
        XCTAssertNotNil(receivedReport)
        XCTAssertEqual(receivedReport?.title, "TestAction")
    }

    func testThatBeginReportsEvent() {
        DurationReporter.begin(event: "EventName", action: "TestAction")
        
        XCTAssertEqual(reportData.count, 1)
        XCTAssertEqual(reportData["EventName"]?.count, 1)
        XCTAssertEqual(reportData["EventName"]?.first?.title, "TestAction")
    }

    func testThatCanRetrieveCollectedData() {
        DurationReporter.begin(event: "EventName", action: "TestAction")
        
        let data = DurationReporter.reportData()
        
        XCTAssertEqual(data.count, 1)
        XCTAssertEqual(data["EventName"]?.count, 1)
        XCTAssertEqual(data["EventName"]?.first?.title, "TestAction")
    }
    
    func testThatBeforeEndingEventItsIncomplete() {
        DurationReporter.begin(event: "EventName", action: "TestAction")
        
        XCTAssertEqual(reportData["EventName"]?.first?.isComplete, false)
    }

    func testThatEndingCompletesEvent() {
        DurationReporter.begin(event: "EventName", action: "TestAction")
        DurationReporter.end(event: "EventName", action: "TestAction")
        
        XCTAssertEqual(reportData["EventName"]?.first?.isComplete, true)
    }

    func testThatCanReportMultipleDifferentActionsForEventAtTheSameTime() {
        DurationReporter.begin(event: "EventName", action: "TestAction")
        DurationReporter.begin(event: "EventName", action: "SecondTestAction")
        
        XCTAssertEqual(reportData["EventName"]?.count, 2)
    }
    
    func testThatWhenReportingIdenticalActionAsTheUnfinishedOneNewActionIsAdded() {
        DurationReporter.begin(event: "EventName", action: "TestAction")
        DurationReporter.begin(event: "EventName", action: "TestAction")
        DurationReporter.begin(event: "EventName", action: "TestAction")
        DurationReporter.end(event: "EventName", action: "TestAction")
        
        XCTAssertEqual(reportData["EventName"]?.filter { !$0.isComplete }.count, 2)
        XCTAssertEqual(reportData["EventName"]?.filter { $0.isComplete }.count, 1)
    }

    func testThatWhenAddingActionSameAsUnfinishedTheUnfinishedIsLeftUnfinishedAndReportedTimeIsCountedForNewAction() {
        DurationReporter.begin(event: "EventName", action: "TestAction")
        sleep(1) //In tests we shouldn't wait, it's bad practice - but without it duration would be 0 and test would test nothing.
        DurationReporter.begin(event: "EventName", action: "TestAction")
        DurationReporter.begin(event: "EventName", action: "TestAction")
        DurationReporter.begin(event: "EventName", action: "TestAction")
        sleep(1) //Check comment ^
        DurationReporter.end(event: "EventName", action: "TestAction")
        
        let report = (reportData["EventName"]?.filter { $0.isComplete }.first)!
        XCTAssertGreaterThanOrEqual(report.duration!, 1.0)
        XCTAssertLessThan(report.duration!, 1.2)
    }

    func testThatCanReportMultipleIdenticalActionsForEventOneByOne() {
        DurationReporter.begin(event: "EventName", action: "TestAction")
        DurationReporter.end(event: "EventName", action: "TestAction")
        DurationReporter.begin(event: "EventName", action: "TestAction")
        
        DurationReporter.end(event: "EventName", action: "TestAction")
        
        XCTAssertEqual(reportData["EventName"]?.count, 2)
    }

    func testThatIdenticalReportedActionsNamesHaveIncrementalNumericSuffix() {
        DurationReporter.begin(event: "EventName", action: "TestAction")
        DurationReporter.end(event: "EventName", action: "TestAction")
        DurationReporter.begin(event: "EventName", action: "TestAction")
        
        DurationReporter.end(event: "EventName", action: "TestAction")
        
        XCTAssertEqual(reportData["EventName"]?.last?.title, "TestAction2")
    }
    
    func testThatCantEndAgainAlreadyCompletedReport() {
        DurationReporter.begin(event: "EventName", action: "TestAction")
        usleep(1000) //In tests we shouldn't wait, it's bad practice - but without it duration would be 0 and test would test nothing.
        DurationReporter.end(event: "EventName", action: "TestAction")
        let completedDuration = reportData["EventName"]?.first?.duration
        usleep(1000) //Check comment ^
        
        DurationReporter.end(event: "EventName", action: "TestAction")
        
        XCTAssertEqual(completedDuration, reportData["EventName"]?.first?.duration)
    }
    
    func testThatReportsCorrectDuration() {
        DurationReporter.begin(event: "EventName", action: "TestAction")
        sleep(1) //In tests we shouldn't wait, it's bad practice - but without it duration would be 0 and test would test nothing.
        
        DurationReporter.end(event: "EventName", action: "TestAction")
        
        XCTAssertGreaterThanOrEqual(reportData["EventName"]!.first!.duration!, 1.0)
        XCTAssertLessThan(reportData["EventName"]!.first!.duration!, 1.2)
    }

    func testThatCanProvideCustomreporGeneratingAlgorithm() {
        DurationReporter.reportGenerator = { _ in return "test report" }
        
        XCTAssertEqual(DurationReporter.generateReport(), "test report")
    }
  
    func testThatCanPassCustomPayloadOnBegin() {        
        DurationReporter.begin(event: "EventName", action: "TestAction", payload: "TestPayload")
        
        XCTAssertGreaterThanOrEqual(reportData["EventName"]!.first!.beginPayload as! String , "TestPayload")
    }

    func testThatCanPassCustomPayloadOnEnd() {
        DurationReporter.begin(event: "EventName", action: "TestAction")
        DurationReporter.end(event: "EventName", action: "TestAction", payload: "TestPayload")
        
        XCTAssertGreaterThanOrEqual(reportData["EventName"]!.first!.endPayload as! String , "TestPayload")
    }
}

extension DurationReporterTests {
    
    var reportData: [String : [DurationReport]] {
        return DurationReporter.reportData()
    }
    
}


