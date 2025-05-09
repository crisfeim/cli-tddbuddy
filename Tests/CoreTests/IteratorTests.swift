// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.


import XCTest
import Core

class Iterator {
    var currentCount = 0
    func start(maxCount: Int, action: () async throws -> Void) async throws {
        while currentCount < maxCount {
            currentCount += 1
            try await action()
        }
    }
}

class IteratorTests: XCTestCase {
    
    func test_iterator_iteratesNtimes() async throws {
        var currentIteration = 0
        let action = { currentIteration += 1 }
        let iterator = Iterator()
        try await iterator.start(maxCount: 5, action: action)
        XCTAssertEqual(currentIteration, 5)
    }
}
