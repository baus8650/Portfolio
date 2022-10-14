@testable import App
import XCTVapor

final class SkillTests: XCTestCase {
    let testSkill1 = SkillBuilder().build()
    let testSkill2 = SkillBuilder().name("Second Skill").build()
    let skillsURI = "/api/skills/"
    var app: Application!
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testSkillsCanBeRetrievedFromAPI() throws {
        let skill1 = Skill(name: testSkill1.name)
        try skill1.save(on: app.db).wait()
        
        let skill2 = Skill(name: testSkill2.name)
        try skill2.save(on: app.db).wait()
        
        try app.test(.GET, skillsURI, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let skills = try response.content.decode([Skill].self)
            
            XCTAssertEqual(skills.count, 2)
            XCTAssertEqual(skills[0].name, "Test Skill")
            XCTAssertEqual(skills[0].id, skill1.id)
            XCTAssertEqual(skills[1].name, "Second Skill")
            XCTAssertEqual(skills[1].id, skill2.id)
            
        })
    }
    
    func testProjectCanBeSavedWithAPI() throws {
        let skill = Skill(id: testSkill1.id, name: testSkill1.name)
        try app.test(.POST, skillsURI, beforeRequest: { req in
            try req.content.encode(skill)
        }, afterResponse: { response in
            let receivedSkills = try response.content.decode(Skill.self)
            XCTAssertEqual(receivedSkills.name, testSkill1.name)
            XCTAssertEqual(receivedSkills.id, testSkill1.id)
            
            try app.test(.GET, skillsURI, afterResponse: { secondResponse in
                let skills = try secondResponse.content.decode([Skill].self)
                XCTAssertEqual(skills.count, 1)
                XCTAssertEqual(skills[0].name, "Test Skill")
                XCTAssertEqual(skills[0].id, testSkill1.id)
            })
        })
    }
    
    func testUpdatingASkill() throws {
        let skill1 = Skill(name: testSkill1.name)
        try skill1.save(on: app.db).wait()
        
        let newName = "Edited Skill Name"
        let updatedSkillData = Skill(id: skill1.id, name: newName)
        
        try app.test(.GET, "\(skillsURI)\(skill1.id!)", afterResponse: { response in
            let returnedSkill = try response.content.decode(Skill.self)
            XCTAssertEqual(returnedSkill.name, skill1.name)
        })
        
        try app.test(.PUT, "\(skillsURI)\(skill1.id!)", beforeRequest: { request in
            try request.content.encode(updatedSkillData)
        })
        
        try app.test(.GET, "\(skillsURI)\(skill1.id!)", afterResponse: { response in
            let returnedSkill = try response.content.decode(Skill.self)
            XCTAssertEqual(returnedSkill.name, newName)
        })
    }
    
    func testProjectCanBeDeletedWithAPI() throws {
        let skill1 = Skill(id: testSkill1.id, name: testSkill1.name)
        try skill1.save(on: app.db).wait()
        
        let skill2 = Skill(id: testSkill2.id, name: testSkill2.name)
        try skill2.save(on: app.db).wait()
        
        try app.test(.GET, skillsURI, afterResponse: { response in
            let skills = try response.content.decode([Skill].self)
            XCTAssertEqual(skills.count, 2)
        })
        
        try app.test(.DELETE, "\(skillsURI)\(skill1.id!)")
        
        try app.test(.GET, skillsURI, afterResponse: { response in
            let skills = try response.content.decode([Skill].self)
            XCTAssertEqual(skills.count, 1)
            XCTAssertEqual(skills[0].name, "Second Skill")
        })
    }
}
