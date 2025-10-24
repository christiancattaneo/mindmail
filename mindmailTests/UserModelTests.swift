//
//  UserModelTests.swift
//  mindmailTests
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Testing
import Foundation
@testable import mindmail

struct UserModelTests {
    
    // MARK: - Valid User Creation
    
    @Test func testValidUserCreation() async throws {
        let user = try User(name: "Alex")
        #expect(user.name == "Alex")
        #expect(user.createdAt <= Date())
    }
    
    @Test func testValidUserWithSpaces() async throws {
        let user = try User(name: "  Alex  ")
        #expect(user.name == "Alex") // Should trim whitespace
    }
    
    @Test func testValidUserWithHyphen() async throws {
        let user = try User(name: "Mary-Jane")
        #expect(user.name == "Mary-Jane")
    }
    
    @Test func testValidUserWithApostrophe() async throws {
        let user = try User(name: "O'Connor")
        #expect(user.name == "O'Connor")
    }
    
    @Test func testValidUserMaxLength() async throws {
        let longName = String(repeating: "A", count: 50)
        let user = try User(name: longName)
        #expect(user.name.count == 50)
    }
    
    // MARK: - Invalid User Creation (Should Throw)
    
    @Test func testEmptyNameThrows() async throws {
        #expect(throws: ValidationError.self) {
            _ = try User(name: "")
        }
    }
    
    @Test func testWhitespaceOnlyNameThrows() async throws {
        #expect(throws: ValidationError.self) {
            _ = try User(name: "   ")
        }
    }
    
    @Test func testNameTooLongThrows() async throws {
        let tooLongName = String(repeating: "A", count: 51)
        #expect(throws: ValidationError.self) {
            _ = try User(name: tooLongName)
        }
    }
    
    @Test func testNameWithNumbersThrows() async throws {
        #expect(throws: ValidationError.self) {
            _ = try User(name: "Alex123")
        }
    }
    
    @Test func testNameWithSpecialCharsThrows() async throws {
        #expect(throws: ValidationError.self) {
            _ = try User(name: "Alex@Email")
        }
    }
    
    @Test func testNameWithEmojiThrows() async throws {
        #expect(throws: ValidationError.self) {
            _ = try User(name: "Alex😊")
        }
    }
    
    // MARK: - Security Tests
    
    @Test func testNameWithHTMLThrows() async throws {
        #expect(throws: ValidationError.self) {
            _ = try User(name: "<script>alert('xss')</script>")
        }
    }
    
    @Test func testNameWithControlCharactersThrows() async throws {
        #expect(throws: ValidationError.self) {
            _ = try User(name: "Alex\u{0000}Test")
        }
    }
    
    // MARK: - Codable Tests
    
    @Test func testUserEncodingDecoding() async throws {
        let user = try User(name: "Alex")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(user)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedUser = try decoder.decode(User.self, from: data)
        
        #expect(decodedUser.name == user.name)
        #expect(decodedUser.createdAt.timeIntervalSince1970 == user.createdAt.timeIntervalSince1970)
    }
}

