import Vapor
import Fluent

/// An instance of a "project" or an application to showcase
final class Review: Model, Content {
    static let schema = "reviews"
    
    @ID
    var id: UUID?
    
    @Field(key: "ratingValue")
    var ratingValue: Int
    
    @Field(key: "reviewTitle")
    var reviewTitle: String
    
    @Field(key: "ratingComment")
    var ratingComment: String
    
    @Parent(key: "projectID")
    var project: Project
    
    
    init() {}
    
    init(id: UUID? = nil, ratingValue: Int, reviewTitle: String, ratingComment: String, project: Project.IDValue) {
        self.id = id
        self.ratingValue = ratingValue
        self.reviewTitle = reviewTitle
        self.ratingComment = ratingComment
        self.$project.id = project
    }
}
