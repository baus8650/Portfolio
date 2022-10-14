import Vapor
import Fluent

/// A notable skill utilized when building a `Project`
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

extension Skill {
    static func addSkill(_ name: String, to project: Project, on req: Request) -> EventLoopFuture<Void> {
        return Skill.query(on: req.db)
            .filter(\.$name == name)
            .first()
            .flatMap { foundSkill in
                if let existingSkill = foundSkill {
                    return project.$skills
                        .attach(existingSkill, on: req.db)
                } else {
                    let skill = Skill(name: name)
                    return skill.save(on: req.db).flatMap {
                        project.$skills
                            .attach(skill, on: req.db)
                    }
                }
            }
    }
}
