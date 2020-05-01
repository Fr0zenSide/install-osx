class Template {
    // MARK: - Variables
    // Private variables
    
    
    // Public variables
    
    
    // MARK: - Getter & Setter methods
    
    
    // MARK: - Constructors
    /**
     Method to create an abstract model
     
     */
    init() {
        
    }
    
    
    // MARK: - Public methods
    
    /**
     Method to get the url of this ressource
     
     - Parameter id: identifier of your resource
     - Returns: url to request this ressource on api
     - Warning: This is an abstract methods, you need to override it on every child.
     
     */
    public func example(_ id: String) -> String {
        fatalError("Error! If you see this message, you need to overrige the method example in \(type(of:self)) class")
    }
    
    
    // MARK: - Private methods
}