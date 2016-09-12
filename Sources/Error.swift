public enum Error: ErrorType, Equatable {
    case General
    case InvalidUrl(String)
    case InvalidResponseData(NSData?)
    case ErrorNS(NSError?)
    case Error(ErrorType)
    case InvalidAuthentication
    case ShouldOverride
}

public func == (lhs: Error, rhs: Error) -> Bool {
    switch (lhs, rhs) {
    case (.General, .General):
        return true
    case (.InvalidAuthentication, .InvalidAuthentication):
        return true
    case (.InvalidUrl(let url_lhs), .InvalidUrl(let url_rhs)): // tailor:disable
        return url_lhs == url_rhs
    case (.Error(_), .Error(_)):
        return true
    case (.ErrorNS(let error_lhs), .ErrorNS(let error_rhs)): // tailor:disable
        return error_lhs?.code == error_rhs?.code
    case (.InvalidResponseData (_), .InvalidResponseData (_)):
        return true
    default:
        return false
    }
}