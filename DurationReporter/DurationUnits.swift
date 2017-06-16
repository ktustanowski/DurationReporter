//
//  DurationUnits.swift
//  DurationReporter
//
//  Created by Kamil Tustanowski on 16.06.2017.
//  Copyright © 2017 ktustanowski. All rights reserved.
//

import Foundation

public protocol DurationUnit {
    
    /// In reports Mach Absolute Time is converted to nanoseconds. 
    /// This divider is used to calculate other units by dividing nanoseconds.
    var divider: UInt64 { get }
    /// Time unit symbol i.e. `ns` for nanosecond. It will be used in reports.
    var symbol: String { get }
}

public struct Nanosecond: DurationUnit {

    public var divider: UInt64 { return 1 }
    public var symbol: String { return "ns" }
    
    public init() { }
}

public struct Microsecond: DurationUnit {
    
    public var divider: UInt64 { return 1_000 }
    public var symbol: String { return "μs" }
    
    public init() { }
}

public struct Millisecond: DurationUnit {
    
    public var divider: UInt64 { return 1_000_000 }
    public var symbol: String { return "ms" }
    
    public init() { }
}

public struct Second: DurationUnit {
    
    public var divider: UInt64 { return 1_000_000_000 }
    public var symbol: String { return "s" }
    
    public init() { }
}
