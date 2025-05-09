// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.


import XCTest
import Core

class Iterator {
    private var currentCount = 0
    var count: Int { currentCount }
    func start(maxCount: Int, until condition: () -> Bool, action: () async throws -> Void) async throws {
        while currentCount < maxCount && !condition() {
            currentCount += 1
            try await action()
        }
    }
}

class IteratorTests: XCTestCase {
    
    func test_iterator_iteratesNtimes() async throws {
        let sut = Iterator()
        try await sut.start(maxCount: 5, until: neverFullfillsCondition, action: {})
        XCTAssertEqual(sut.count, 5)
    }
    
    func test_iterator_stopsWhenConditionIsMet() async throws {
        let sut = Iterator()
        try await sut.start(maxCount: 5, until: { sut.count == 1 }, action: {})
        XCTAssertEqual(sut.count, 1)
    }
    
    private func neverFullfillsCondition() -> Bool { false }
}
