import Foundation

enum ConfigurationError: Error {
	case noValidBaseUrl(String)
}
/// Use for different configurations for the specific environment you want to use for *Call*
open class Configuration {

    /// For now we only support JSON. Can be Changed in the future
    @available(*, deprecated: 3.0, message: "Use JSONDecoder")
    open let adaptor: Adaptable
    open let decoder = JSONDecoder()
    open var baseURL: String

    public init(baseURL: String, adaptor: Adaptable = JSONAdaptor()) {
        self.baseURL = baseURL
        self.adaptor = adaptor
    }
    
}
