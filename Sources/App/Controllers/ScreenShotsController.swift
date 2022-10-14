import Vapor

struct ScreenShotsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let screenShotsRoute = routes.grouped("api", "screenshots")
        let authSessionsRoutes = routes.grouped(User.sessionAuthenticator())
        let protectedRoutes = authSessionsRoutes.grouped(User.redirectMiddleware(path: "/login"))
        protectedRoutes.post(use: createHandler)
        protectedRoutes.get(use: getAllHandler)
        protectedRoutes.get(":screenshotID", use: getHandler)
        protectedRoutes.put(":screenshotID", use: updateHandler)
        protectedRoutes.delete("delete", ":screenshotID", use: deleteHandler)
    }
    
    func createHandler(_ req: Request)
    throws -> EventLoopFuture<ScreenShot> {
        let screenShot = try req.content.decode(ScreenShot.self)
        return screenShot.save(on: req.db).map { screenShot }
    }
    
    func getAllHandler(_ req: Request)
    -> EventLoopFuture<[ScreenShot]> {
        ScreenShot.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request)
    -> EventLoopFuture<ScreenShot> {
        ScreenShot.find(req.parameters.get("screenshotID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<ScreenShot> {
        let updatedScreenShot = try req.content.decode(ScreenShot.self)
        return ScreenShot.find(req.parameters.get("screenshotID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { screenShot in
                screenShot.description = updatedScreenShot.description
                return screenShot.save(on: req.db).map { screenShot }
            }
    }
    
    func deleteHandler(_ req: Request) -> EventLoopFuture<Response> {
        ScreenShot.find(req.parameters.get("screenshotID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { screenshot in
                screenshot.delete(on: req.db).transform(to: req.redirect(to: "/admin"))
            }
    }
}
