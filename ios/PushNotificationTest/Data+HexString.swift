import Foundation

extension Data {
    func toHexString() -> String {
        return self.map { String(format: "%02.2hhx", $0) }.joined()
    }
}
