import Vapor
import Fluent

/// An instance of a "project" or an application to showcase
final class ApplicationType: Model, Content {
    static let schema = "applicationTypes"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$applicationType)
    var projects: [Project]
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
