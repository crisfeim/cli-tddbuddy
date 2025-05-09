// © 2025  Cristian Felipe Patiño Rojas. Created on 9/5/25.


import Foundation

public protocol Persistor {
    func persist(_ string: String, outputURL: URL) throws
}