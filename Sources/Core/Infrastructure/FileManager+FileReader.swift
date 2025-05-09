// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.

import Foundation

extension FileManager: FileReader {
    public func read(_ url: URL) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }
}
