public enum FaroError: Error, Equatable {
    case general
    case invalidUrl(String)
    case invalidResponseData(Data?)
    case invalidAuthentication
    case shouldOverride
    case nonFaroError(Error)
}

public func == (lhs: FaroError, rhs: FaroError) -> Bool {
    switch (lhs, rhs) {
    case (.general, .general):
        return true
    case (.invalidAuthentication, .invalidAuthentication):
        return true
    case (.invalidUrl(let url_lhs), .invalidUrl(let url_rhs)): // tailor:disable
        return url_lhs == url_rhs
    case (.invalidResponseData (_), .invalidResponseData (_)):
        return true
    default:
        return false
    }
}
