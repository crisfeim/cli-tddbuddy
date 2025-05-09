// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.


import XCTest
import Core

class IteratorTests: XCTestCase {
    
    class Iterator {
        let maxCount: Int
        let action: () async throws -> Void
        
        init(maxCount: Int, action: @escaping () async throws -> Void) {
            self.maxCount = maxCount
            self.action = action
        }
        
        func start() async throws {
            var currentCount = 0
            while currentCount < maxCount {
                currentCount += 1
                try await action()
            }
        }
    }
    
    func test_iterator() async throws {
        var currentIteration = 0
        let action = { currentIteration += 1 }
        let iterator = Iterator(maxCount: 5, action: action)
        try await iterator.start()
        XCTAssertEqual(currentIteration, 5)
    }
}