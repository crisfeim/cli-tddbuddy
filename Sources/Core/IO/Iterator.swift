// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

open class Iterator: Coordinator.Iterator {
    public init() {}
    open func iterate(nTimes n: Int, until condition: () -> Bool, action: () async throws -> Void) async throws {
        var currentCount = 0
        while currentCount < n && !condition() {
            currentCount += 1
            try await action()
        }
    }
}
