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
