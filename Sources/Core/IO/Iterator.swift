// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

public class Iterator: Coordinator.Iterator {
    private var currentCount = 0
    public var count: Int { currentCount }
    public init() {}
    public func iterate(nTimes n: Int, until condition: () -> Bool, action: () async throws -> Void) async throws {
        while currentCount < n && !condition() {
            currentCount += 1
            try await action()
        }
    }
}
