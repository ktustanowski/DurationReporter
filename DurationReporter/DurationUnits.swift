//
//  DurationUnits.swift
//  DurationReporter
//
//  Created by Kamil Tustanowski on 16.06.2017.
//  Copyright © 2017 ktustanowski. All rights reserved.
//

import Foundation

public protocol DurationUnit {
    

    /// Units contained in a second
    var perSecond: TimeInterval { get }
    /// Time unit symbol i.e. `ns` for nanosecond. It will be used in reports.
    var symbol: String { get }
}

public struct Nanosecond: DurationUnit {

    public var perSecond: TimeInterval { return TimeInterval(NSEC_PER_SEC) }
    public var symbol: String { return "ns" }
    
    public init() { }
}

public struct Microsecond: DurationUnit {
    
    public var perSecond: TimeInterval { return TimeInterval(NSEC_PER_SEC) }
    public var symbol: String { return "μs" }
    
    public init() { }
}

public struct Millisecond: DurationUnit {
    
    public var perSecond: TimeInterval { return TimeInterval(1000) }
    public var symbol: String { return "ms" }
    
    public init() { }
}
