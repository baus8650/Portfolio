import Fluent

struct CreateProject: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("projects")
            .id()
            .field("name", .string, .required)
            .field("yearCompleted", .int, .required)
            .field("shortDescription", .string, .required)
            .field("longDescription", .string, .required)
            .field("appLink", .string, .required)
            .field("repoLink", .string)
            .field("appIcon", .string)
            .field("applicationTypeID", .uuid, .required, .references("applicationTypes", "id"))
            .field("deleted_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("projects").delete()
    }
}
