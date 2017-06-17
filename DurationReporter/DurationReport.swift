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

public class DurationReport {
    
    fileprivate var beginTime: TimeInterval?
    fileprivate var endTime: TimeInterval?
    
    /// Action name which duration is measured in report
    public let title: String
    
    /// Data passed on begin
    public var beginPayload: Any?
    
    /// Data passed on end
    public var endPayload: Any?
    
    /// Is report complete (did begin and then end)
    public var isComplete: Bool {
        return duration != nil
    }
        
    /// Total duration of action in seconds (s)
    public var duration: TimeInterval? {
        guard let endTime = endTime, let beginTime = beginTime else { return nil }
        let duration = endTime - beginTime
        
        return duration
    }
        
    /// Mark that action did start
    public func begin() {
        guard beginTime == nil else {
            print("Can't start already started report.")
            return
        }
        
        beginTime = CACurrentMediaTime()
    }
    
    /// Mark that action did end
    public func end() {
        guard endTime == nil else {
            print("Can't end already started report.")
            return
        }

        endTime = CACurrentMediaTime()
    }
    
    /// Initializer
    ///
    /// - Parameter title: action name
    public init(title: String) {
        self.title = title
    }
}
