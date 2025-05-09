// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.


import XCTest
import Core

class Iterator {
    var currentCount = 0
    func start(maxCount: Int, until condition: () -> Bool, action: () async throws -> Void) async throws {
        while currentCount < maxCount && !condition() {
            currentCount += 1
            try await action()
        }
    }
}

class IteratorTests: XCTestCase {
    
    func test_iterator_iteratesNtimes() async throws {
        let iterator = Iterator()
        try await iterator.start(maxCount: 5, until: neverFullfillsCondition, action: {})
        XCTAssertEqual(iterator.currentCount, 5)
    }
    
    func test_iterator_stopsWhenConditionIsMet() async throws {
        let iterator = Iterator()
        try await iterator.start(maxCount: 5, until: { iterator.currentCount == 1 }, action: {})
        XCTAssertEqual(iterator.currentCount, 1)
    }
    
    private func neverFullfillsCondition() -> Bool { false }
}
