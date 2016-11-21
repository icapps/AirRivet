public enum FaroError: Error, Equatable {
    case general
    case invalidUrl(String)
    case invalidResponseData(Data?)
    case invalidAuthentication
    case shouldOverride
    case nonFaroError(Error)
    case rootNodeNotFound(json: Any)
    case networkError(Int, data: Data?)
    case emptyKey
    case emptyValue(key: String)
    case emptyCollection
    case malformed(info: String)
    case serializationError
    case updateNotPossible(json: Any, model: Any)
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
    case (.networkError(let lStatusCode, _ ), .networkError(let rStatusCode, _ )):
        return lStatusCode == rStatusCode
    default:
        return false
    }
}
