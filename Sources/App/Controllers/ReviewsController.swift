import Vapor

struct ReviewsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let screenShotsRoute = routes.grouped("api", "reviews")
        screenShotsRoute.post(use: createHandler)
        screenShotsRoute.get(use: getAllHandler)
        screenShotsRoute.get(":reviewID", use: getHandler)
        screenShotsRoute.put(":reviewID", use: updateHandler)
        screenShotsRoute.delete("delete", ":reviewID", use: deleteHandler)
    }
    
    func createHandler(_ req: Request)
    throws -> EventLoopFuture<Review> {
        let screenShot = try req.content.decode(Review.self)
        return screenShot.save(on: req.db).map { screenShot }
    }
    
    func getAllHandler(_ req: Request)
    -> EventLoopFuture<[Review]> {
        Review.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request)
    -> EventLoopFuture<Review> {
        Review.find(req.parameters.get("reviewID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Review> {
        let updatedReview = try req.content.decode(Review.self)
        return Review.find(req.parameters.get("reviewID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { review in
                review.ratingValue = updatedReview.ratingValue
                review.ratingComment = updatedReview.ratingComment
                return review.save(on: req.db).map { review }
            }
    }
    
    func deleteHandler(_ req: Request) -> EventLoopFuture<Response> {
        Review.find(req.parameters.get("reviewID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { screenshot in
                screenshot.delete(on: req.db).transform(to: req.redirect(to: "/admin"))
            }
    }
}
