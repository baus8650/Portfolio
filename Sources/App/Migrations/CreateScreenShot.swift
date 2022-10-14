import Fluent

struct CreateScreenShot: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("screenshots")
            .id()
            .field("description", .string, .required)
            .field("image", .string, .required)
            .field("projectID", .uuid, .required, .references("projects", "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("screenshots").delete()
    }
}
