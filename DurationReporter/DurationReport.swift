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

public class DurationReport {
    
    fileprivate var beginTime: UInt64?
    fileprivate var endTime: UInt64?
    fileprivate var info : mach_timebase_info = mach_timebase_info(numer: 0, denom: 0)
    
    /// Action name which duration is measured in report
    public let title: String
    
    /// Is report complete (did begin and then end)
    public var isComplete: Bool {
        return duration != nil
    }
        
    /// Total duration of action
    public var duration: UInt64? {
        guard let endTime = endTime, let beginTime = beginTime else { return nil }
        let duration = endTime - beginTime
        mach_timebase_info(&info)
        
        return (duration * UInt64(info.numer) / UInt64(info.denom)) / 1_000_000
    }
    
    /// Mark that action did start
    public func begin() {
        guard beginTime == nil else {
            print("Can't start already started report.")
            return
        }
        
        beginTime = mach_absolute_time()
    }
    
    /// Mark that action did end
    public func end() {
        guard endTime == nil else {
            print("Can't end already started report.")
            return
        }

        endTime = mach_absolute_time()
    }
    
    /// Initializer
    ///
    /// - Parameter title: action name
    public init(title: String) {
        self.title = title
    }
}
