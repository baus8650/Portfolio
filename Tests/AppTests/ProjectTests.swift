@testable import App
import XCTVapor

final class ProjectTests: XCTestCase {
    let testProject1 = ProjectBuilder().build()
    let testProject2 = ProjectBuilder().name("Second Project").yearCompleted(2021).build()
    let projectTypeBuild = ApplicationTypeBuilder().build()
    let projectsURI = "/api/projects/"
    let skillsURI = "/api/skills/"
    var app: Application!
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testProjectsCanBeRetrievedFromAPI() throws {
        /// project needs a type to attach to first
        let applicationType = ApplicationType(id: projectTypeBuild.id, name: projectTypeBuild.name)
        try applicationType.save(on: app.db).wait()
        
        let project1 = Project(name: testProject1.name, yearCompleted: testProject1.yearCompleted, shortDescription: testProject1.shortDescription, longDescription: testProject1.longDescription, appLink: testProject1.appLink, repoLink: testProject1.repoLink, appIcon: testProject1.appIcon, applicationType: projectTypeBuild.id)
        try project1.save(on: app.db).wait()
        
        let project2 = Project(name: testProject2.name, yearCompleted: testProject2.yearCompleted, shortDescription: testProject2.shortDescription, longDescription: testProject2.longDescription, appLink: testProject2.appLink, repoLink: testProject2.repoLink, appIcon: testProject2.appIcon, applicationType: projectTypeBuild.id)
        try project2.save(on: app.db).wait()
            
        try app.test(.GET, projectsURI, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let projects = try response.content.decode([Project].self)
            XCTAssertEqual(projects.count, 2)
            XCTAssertEqual(projects[0].name, "Test Project")
            XCTAssertEqual(projects[0].yearCompleted, 2022)
            XCTAssertEqual(projects[0].id, project1.id)
            XCTAssertEqual(projects[1].name, "Second Project")
            XCTAssertEqual(projects[1].yearCompleted, 2021)
            XCTAssertEqual(projects[1].id, project2.id)
            
        })
    }
    
    func testProjectCanBeSavedWithAPI() throws {
        /// project needs a type to attach to first
        let applicationType = ApplicationType(id: projectTypeBuild.id, name: projectTypeBuild.name)
        try applicationType.save(on: app.db).wait()
        
        let project = Project(id: testProject1.id, name: testProject1.name, yearCompleted: testProject1.yearCompleted, shortDescription: testProject1.shortDescription, longDescription: testProject1.longDescription, appLink: testProject1.appLink, repoLink: testProject1.repoLink, appIcon: testProject1.appIcon, applicationType: projectTypeBuild.id)
        try app.test(.POST, projectsURI, beforeRequest: { req in
            try req.content.encode(project)
        }, afterResponse: { response in
            let receivedProject = try response.content.decode(Project.self)
            XCTAssertEqual(receivedProject.name, testProject1.name)
            XCTAssertEqual(receivedProject.yearCompleted, testProject1.yearCompleted)
            XCTAssertEqual(receivedProject.id, testProject1.id)
            
            try app.test(.GET, projectsURI, afterResponse: { secondResponse in
                let projects = try secondResponse.content.decode([Project].self)
                XCTAssertEqual(projects.count, 1)
                XCTAssertEqual(projects[0].name, "Test Project")
                XCTAssertEqual(projects[0].yearCompleted, 2022)
                XCTAssertEqual(projects[0].id, testProject1.id)
            })
        })
    }
    
    func testUpdatingAProject() throws {
        /// project needs a type to attach to first
        let applicationType = ApplicationType(id: projectTypeBuild.id, name: projectTypeBuild.name)
        try applicationType.save(on: app.db).wait()
        
        let project1 = Project(id: testProject1.id, name: testProject1.name, yearCompleted: testProject1.yearCompleted, shortDescription: testProject1.shortDescription, longDescription: testProject1.longDescription, appLink: testProject1.appLink, repoLink: testProject1.repoLink, appIcon: testProject1.appIcon, applicationType: projectTypeBuild.id)
        try project1.save(on: app.db).wait()
        
        let newName = "Edited Project Name"
        let updatedProjectData = Project(name: newName, yearCompleted: project1.yearCompleted, shortDescription: project1.shortDescription, longDescription: project1.longDescription, appLink: project1.appLink, repoLink: project1.repoLink, appIcon: project1.appIcon, applicationType: projectTypeBuild.id)
        
        try app.test(.GET, "\(projectsURI)\(project1.id!)", afterResponse: { response in
            let returnedProject = try response.content.decode(Project.self)
            XCTAssertEqual(returnedProject.name, project1.name)
            XCTAssertEqual(returnedProject.yearCompleted, project1.yearCompleted)
        })
        
        try app.test(.PUT, "\(projectsURI)\(project1.id!)", beforeRequest: { request in
            try request.content.encode(updatedProjectData)
        })
        
        try app.test(.GET, "\(projectsURI)\(project1.id!)", afterResponse: { response in
            let returnedProject = try response.content.decode(Project.self)
            XCTAssertEqual(returnedProject.name, newName)
            XCTAssertEqual(returnedProject.yearCompleted, project1.yearCompleted)
        })
    }
    
    func testProjectCanBeDeletedWithAPI() throws {
        /// project needs a type to attach to first
        let applicationType = ApplicationType(id: projectTypeBuild.id, name: projectTypeBuild.name)
        try applicationType.save(on: app.db).wait()
        
        let project1 = Project(name: testProject1.name, yearCompleted: testProject1.yearCompleted, shortDescription: testProject1.shortDescription, longDescription: testProject1.longDescription, appLink: testProject1.appLink, repoLink: testProject1.repoLink, appIcon: testProject1.appIcon, applicationType: projectTypeBuild.id)
        try project1.save(on: app.db).wait()
        
        let project2 = Project(name: testProject2.name, yearCompleted: testProject2.yearCompleted, shortDescription: testProject2.shortDescription, longDescription: testProject2.longDescription, appLink: testProject2.appLink, repoLink: testProject2.repoLink, appIcon: testProject2.appIcon, applicationType: projectTypeBuild.id)
        try project2.save(on: app.db).wait()
        
        try app.test(.GET, projectsURI, afterResponse: { response in
            let projects = try response.content.decode([Project].self)
            XCTAssertEqual(projects.count, 2)
        })
        
        try app.test(.DELETE, "\(projectsURI)\(project1.id!)")
        
        try app.test(.GET, projectsURI, afterResponse: { response in
            let projects = try response.content.decode([Project].self)
            XCTAssertEqual(projects.count, 1)
            XCTAssertEqual(projects[0].name, "Second Project")
        })
    }
}
