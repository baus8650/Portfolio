import Fluent

struct CreateProjectSkillPivot: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("project-skill-pivot")
            .id()
            .field("projectID", .uuid, .required, .references("projects", "id", onDelete: .cascade))
            .field("skillID", .uuid, .required, .references("skills", "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("project-skill-pivot").delete()
    }
}
