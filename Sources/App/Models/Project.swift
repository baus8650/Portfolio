import Vapor
import Fluent

/// An instance of a "project" or an application to showcase
final class Project: Model, Content {
    static let schema = "projects"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "yearCompleted")
    var yearCompleted: Int
    
    @Siblings(through: ProjectSkillPivot.self, from: \.$project, to: \.$skill)
    var skills: [Skill]
    
    init() {}
    
    init(id: UUID? = nil, name: String, yearCompleted: Int) {
        self.id = id
        self.name = name
        self.yearCompleted = yearCompleted
    }
}
