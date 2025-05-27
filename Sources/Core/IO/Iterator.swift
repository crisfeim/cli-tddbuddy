// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

public class Iterator {
    public init() {}
    public func iterate<T>(nTimes n: Int, until condition: (T) -> Bool, action: () async throws -> T) async throws -> T {
        var results = [T]()
        while results.count < n {
            let result = try await action()
            if condition(result) { return result }
            results.append(result)
        }
        return results.first!
    }
}
