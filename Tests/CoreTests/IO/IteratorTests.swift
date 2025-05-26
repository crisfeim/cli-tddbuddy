// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.


import XCTest
import Core



class IteratorTests: XCTestCase {
    
    func test_iterator_iteratesNtimes() async throws {
        let sut = Iterator()
        var iterationCount = 0
        try await sut.iterate(
            nTimes: 5,
            until: neverFullfillsCondition,
            action: { iterationCount += 1 }
        )
        XCTAssertEqual(iterationCount, 5)
    }
    
    func test_iterator_stopsWhenConditionIsMet() async throws {
        let sut = Iterator()
        var iterationCount = 0
        try await sut.iterate(
            nTimes: 5,
            until: { iterationCount == 1 },
            action: { iterationCount += 1 })
        XCTAssertEqual(iterationCount, 1)
    }
    
    private func neverFullfillsCondition() -> Bool { false }
}
