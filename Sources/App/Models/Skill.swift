import Vapor
import Fluent

final class Skill: Model, Content {
    static let schema = "skills"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Siblings(through: ProjectSkillPivot.self, from: \.$skill, to: \.$project)
    var projects: [Project]
    
    init() {}
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
