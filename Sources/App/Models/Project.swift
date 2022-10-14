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
    
    @Field(key: "shortDescription")
    var shortDescription: String
    
    @Field(key: "longDescription")
    var longDescription: String
    
    @Field(key: "appLink")
    var appLink: String
    
    @Field(key: "repoLink")
    var repoLink: String?
    
    @Field(key: "appIcon")
    var appIcon: String?

    @Parent(key: "applicationTypeID")
    var applicationType: ApplicationType
        
    @Children(for: \.$project)
    var screenShots: [ScreenShot]
    
    @Children(for: \.$project)
    var reviews: [Review]
    
    @Siblings(through: ProjectSkillPivot.self, from: \.$project, to: \.$skill)
    var skills: [Skill]
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, name: String, yearCompleted: Int, shortDescription: String, longDescription: String, appLink: String, repoLink: String?, appIcon: String?, applicationType: ApplicationType.IDValue) {
        self.id = id
        self.name = name
        self.yearCompleted = yearCompleted
        self.shortDescription = shortDescription
        self.longDescription = longDescription
        self.appLink = appLink
        self.repoLink = repoLink
        self.appIcon = appIcon
        self.$applicationType.id = applicationType
    }
}
