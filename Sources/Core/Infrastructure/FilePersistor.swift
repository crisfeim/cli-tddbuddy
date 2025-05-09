// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.


import XCTest

public class FilePersistor: Persistor {
    public init() {}
    public func persist(_ string: String, outputURL: URL) throws {
        try string.write(to: outputURL, atomically: true, encoding: .utf8)
    }
}
