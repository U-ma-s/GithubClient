
import Foundation
enum Stateful<Value> {
    case idel
    case loading
    case failed(Error)
    case loaded(Value)
}
