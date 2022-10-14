import Vapor
import Fluent

/// An instance of a "project" or an application to showcase
final class ScreenShot: Model, Content {
    static let schema = "screenshots"
    
    @ID
    var id: UUID?
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "image")
    var image: String
    
    @Parent(key: "projectID")
    var project: Project
    
    
    init() {}
    
    init(id: UUID? = nil, description: String, image: String, project: Project.IDValue) {
        self.id = id
        self.description = description
        self.image = image
        self.$project.id = project
    }
}
