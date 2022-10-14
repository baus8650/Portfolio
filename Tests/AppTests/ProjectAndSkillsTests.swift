@testable import App
import XCTVapor

final class ProjectAndSkillTests: XCTestCase {
    let projectsURI = "/api/projects/"
    let skillsURI = "/api/skills/"
    var app: Application!
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testGettingProjectSkillsFromTheAPI() throws {
        /// project needs a type to attach to first
        let projectTypeBuild = ApplicationTypeBuilder().build()
        let applicationType = ApplicationType(id: projectTypeBuild.id, name: projectTypeBuild.name)
        try applicationType.save(on: app.db).wait()
        
        let buildProject = ProjectBuilder().build()
        let project = Project(name: buildProject.name, yearCompleted: buildProject.yearCompleted, shortDescription: buildProject.shortDescription, longDescription: buildProject.longDescription, appLink: buildProject.appLink, repoLink: buildProject.repoLink, appIcon: buildProject.appIcon, applicationType: projectTypeBuild.id)
        try project.save(on: app.db).wait()
        
        let buildSkill = SkillBuilder().build()
        let skill = Skill(name: buildSkill.name)
        try skill.save(on: app.db).wait()
        
        let buildUnassociatedSkill = SkillBuilder().build()
        let newSkill = Skill(name: buildUnassociatedSkill.name)
        try newSkill.save(on: app.db).wait()
        
        try app.test(.POST, "/api/projects/\(project.id!)/skills/\(skill.id!)")
        
        try app.test(.GET, "\(projectsURI)\(project.id!)/skills", afterResponse: { response in
            let skills = try response.content.decode([Skill].self)
            XCTAssertEqual(skills.count, 1)
            XCTAssertEqual(skills[0].id, skill.id)
            XCTAssertEqual(skills[0].name, buildSkill.name)
        })
    }
    
    func testGettingSkillsProjectFromTheAPI() throws {
        /// project needs a type to attach to first
        let projectTypeBuild = ApplicationTypeBuilder().build()
        let applicationType = ApplicationType(id: projectTypeBuild.id, name: projectTypeBuild.name)
        try applicationType.save(on: app.db).wait()
        
        let buildProject = ProjectBuilder().build()
        let project = Project(name: buildProject.name, yearCompleted: buildProject.yearCompleted, shortDescription: buildProject.shortDescription, longDescription: buildProject.longDescription, appLink: buildProject.appLink, repoLink: buildProject.repoLink, appIcon: buildProject.appIcon, applicationType: projectTypeBuild.id)
        try project.save(on: app.db).wait()
        
        let buildSkill = SkillBuilder().build()
        let skill = Skill(name: buildSkill.name)
        try skill.save(on: app.db).wait()
        
        let buildUnassociatedSkill = SkillBuilder().build()
        let newSkill = Skill(name: buildUnassociatedSkill.name)
        try newSkill.save(on: app.db).wait()
        
        try app.test(.POST, "\(projectsURI)\(project.id!)/skills/\(skill.id!)")
        
        try app.test(.GET, "\(skillsURI)\(skill.id!)/projects", afterResponse: { response in
            let projects = try response.content.decode([Project].self)
            XCTAssertEqual(projects.count, 1)
            XCTAssertEqual(projects[0].id, project.id)
            XCTAssertEqual(projects[0].name, buildProject.name)
        })
    }
}
