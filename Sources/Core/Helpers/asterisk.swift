// © 2025  Cristian Felipe Patiño Rojas. Created on 26/5/25.

infix operator .*: AdditionPrecedence

@discardableResult
public func .*<T>(lhs: T, rhs: (inout T) -> Void) -> T {
  var copy = lhs
  rhs(&copy)
  return copy
}
