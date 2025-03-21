import Foundation

public struct ResultCodeError: Error {
    public let code: ResultCode
    public let message: String

    public init(code: ResultCode) {
        self.code = code
        self.message = code.description
    }

    public static func from(_ resultCode: ResultCode) -> ResultCodeError {
        return ResultCodeError(code: resultCode)
    }
}
