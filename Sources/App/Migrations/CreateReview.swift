import Fluent

struct CreateReview: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("reviews")
            .id()
            .field("ratingValue", .int, .required)
            .field("ratingComment", .string, .required)
            .field("reviewTitle", .string, .required)
            .field("projectID", .uuid, .required, .references("projects", "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("reviews").delete()
    }
}
