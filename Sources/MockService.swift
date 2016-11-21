open class MockService: Service {

    /// If you provide this variable before calling `perform` we will use this instead of the file content.
    public var mockDictionary: Any?
    internal var bundle: Bundle!

    public init(mockDictionary: Any? = nil, for bundle: Bundle = Bundle.main) {
        self.mockDictionary = mockDictionary
        self.bundle = bundle
        super.init(configuration: Configuration(baseURL: ""))
    }

    /// This method is overridden to return json or errors like as if we would do a network call.
    override open func performJsonResult<M : Deserializable>(_ call: Call, jsonResult: @escaping (Result<M>) -> ()) {
        if let mockDictionary = mockDictionary {
            jsonResult(.json(mockDictionary))
            return
        }

        let request = call.request(withConfiguration: configuration)

        guard let url = request?.url?.absoluteString else {
            let faroError = FaroError.malformed(info: "No valid url")
            printFaroError(faroError)
            jsonResult(.failure(faroError))
            return
        }

        guard let mockJSON = JSONReader.parseFile(named: url, for: bundle!) else {
            let faroError = FaroError.malformed(info: "Could not find dummy file at \(url)")
            printFaroError(faroError)
            jsonResult(.failure(faroError))
            return
        }

        jsonResult(.json(mockJSON))
    }
    
}
