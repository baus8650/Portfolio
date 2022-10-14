import Vapor

struct ApplicationTypesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let typesRoute = routes.grouped("api", "types")
        typesRoute.post(use: createHandler)
        typesRoute.get(use: getAllHandler)
        typesRoute.get(":typeID", use: getHandler)
        typesRoute.put(":typeID", use: updateHandler)
        typesRoute.delete(":typeID", use: deleteHandler)
        
        typesRoute.get(":typeID", "projects", use: getProjectsHandler)
    }
    
    func createHandler(_ req: Request)
    throws -> EventLoopFuture<ApplicationType> {
        let type = try req.content.decode(ApplicationType.self)
        return type.save(on: req.db).map { type }
    }
    
    func getAllHandler(_ req: Request)
    -> EventLoopFuture<[ApplicationType]> {
        ApplicationType.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request)
    -> EventLoopFuture<ApplicationType> {
        ApplicationType.find(req.parameters.get("typeID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<ApplicationType> {
        let updatedType = try req.content.decode(ApplicationType.self)
        return ApplicationType.find(req.parameters.get("typeID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { type in
                type.name = updatedType.name
                return type.save(on: req.db).map { type }
            }
    }
    
    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        ApplicationType.find(req.parameters.get("typeID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { type in
                type.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    // MARK: - Projects Handlers
    
    func getProjectsHandler(_ req: Request) -> EventLoopFuture<[Project]> {
        ApplicationType.find(req.parameters.get("typeID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { type in
                type.$projects.get(on: req.db)
            }
    }
}
