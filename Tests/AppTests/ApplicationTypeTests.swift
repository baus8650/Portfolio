@testable import App
import XCTVapor

final class ApplicationTypeTests: XCTestCase {
    let testType1 = ApplicationTypeBuilder().build()
    let testType2 = ApplicationTypeBuilder().name("Second Type").build()
    let typesURI = "/api/types/"
    var app: Application!
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testTypesCanBeRetrievedFromAPI() throws {
        let type1 = ApplicationType(name: testType1.name)
        try type1.save(on: app.db).wait()
        
        let type2 = ApplicationType(name: testType2.name)
        try type2.save(on: app.db).wait()
        
        try app.test(.GET, typesURI, afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let types = try response.content.decode([ApplicationType].self)
            
            XCTAssertEqual(types.count, 2)
            XCTAssertEqual(types[0].name, "iOS Application")
            XCTAssertEqual(types[0].id, type1.id)
            XCTAssertEqual(types[1].name, "Second Type")
            XCTAssertEqual(types[1].id, type2.id)
            
        })
    }
    
    func testProjectCanBeSavedWithAPI() throws {
        let type = ApplicationType(id: testType1.id, name: testType1.name)
        try app.test(.POST, typesURI, beforeRequest: { req in
            try req.content.encode(type)
        }, afterResponse: { response in
            let receivedTypes = try response.content.decode(ApplicationType.self)
            XCTAssertEqual(receivedTypes.name, testType1.name)
            XCTAssertEqual(receivedTypes.id, testType1.id)
            
            try app.test(.GET, typesURI, afterResponse: { secondResponse in
                let types = try secondResponse.content.decode([ApplicationType].self)
                XCTAssertEqual(types.count, 1)
                XCTAssertEqual(types[0].name, "iOS Application")
                XCTAssertEqual(types[0].id, testType1.id)
            })
        })
    }
    
    func testUpdatingAApplicationType() throws {
        let type1 = ApplicationType(name: testType1.name)
        try type1.save(on: app.db).wait()
        
        let newName = "Edited Type Name"
        let updatedTypeData = ApplicationType(id: type1.id, name: newName)
        
        try app.test(.GET, "\(typesURI)\(type1.id!)", afterResponse: { response in
            let returnedType = try response.content.decode(ApplicationType.self)
            XCTAssertEqual(returnedType.name, type1.name)
        })
        
        try app.test(.PUT, "\(typesURI)\(type1.id!)", beforeRequest: { request in
            try request.content.encode(updatedTypeData)
        })
        
        try app.test(.GET, "\(typesURI)\(type1.id!)", afterResponse: { response in
            let returnedType = try response.content.decode(ApplicationType.self)
            XCTAssertEqual(returnedType.name, newName)
        })
    }
    
    func testProjectCanBeDeletedWithAPI() throws {
        let type1 = ApplicationType(id: testType1.id, name: testType1.name)
        try type1.save(on: app.db).wait()
        
        let type2 = ApplicationType(id: testType2.id, name: testType2.name)
        try type2.save(on: app.db).wait()
        
        try app.test(.GET, typesURI, afterResponse: { response in
            let types = try response.content.decode([ApplicationType].self)
            XCTAssertEqual(types.count, 2)
        })
        
        try app.test(.DELETE, "\(typesURI)\(type1.id!)")
        
        try app.test(.GET, typesURI, afterResponse: { response in
            let types = try response.content.decode([ApplicationType].self)
            XCTAssertEqual(types.count, 1)
            XCTAssertEqual(types[0].name, "Second Type")
        })
    }
}
