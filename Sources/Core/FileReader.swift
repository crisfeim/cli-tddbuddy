// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.


import Foundation

public protocol FileReader {
    func read(_ url: URL) throws -> String
}