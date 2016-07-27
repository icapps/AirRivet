//
//  CoreDataEntitySpec.swift
//  AirRivet
//
//  Created by Stijn Willems on 19/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Quick
import Nimble
import CoreData
import AirRivet

@testable import AirRivet_Example

class CoreDataSQLitePopulatorSpec: QuickSpec {
    
    class MockPopulatorWithSQLite : CoreDataFromPopulatedSQLite {
        override func allModelNameSQLiteFilesInDocumentsFolder() -> [NSURL]? {
            return [NSURL.fileURLWithPath("file:bla/1_Test.sqlite")]
        }
    }
    
    class MockPopulatorWithNO_versionPrefix_SQLite : CoreDataFromPopulatedSQLite {
        override func allModelNameSQLiteFilesInDocumentsFolder() -> [NSURL]? {
            return [NSURL.fileURLWithPath("file:bla/Test.sqlite")]
        }
    }
    
    class MockPopulatorNO_SQLiteFiles : CoreDataFromPopulatedSQLite {
        override func allModelNameSQLiteFilesInDocumentsFolder() -> [NSURL]? {
            return nil
        }
    }
    
    class MockPopulatorWithMultipleSQLiteFiles : CoreDataFromPopulatedSQLite {
        override func allModelNameSQLiteFilesInDocumentsFolder() -> [NSURL]? {
            let u1 = NSURL.fileURLWithPath("file:bla/1_Test.sqlite")
            let u2 = NSURL.fileURLWithPath("file:bla/2_Test.sqlite")
            let u3 = NSURL.fileURLWithPath("file:bla/3_Test.sqlite")
            
            return [u1, u2, u3]
        }
    }
    
    override func spec() {
        describe("CoreDataSQLitePopulatorSpec") {
            
            it("should reuse sqlite of the same version", closure: {
                let populator = MockPopulatorWithSQLite(modelName: "Test", version: "1")
                
                expect(populator.reuseSQLite()).to(beTrue())
            })
            
            
            it("should NOT reuse sqlite with different version", closure: {
                let populator = MockPopulatorWithSQLite(modelName: "Test", version: "2")
                
                expect(populator.reuseSQLite()).to(beFalse())
            })
            
            it("should NOT reuse sqlite when multiple files available", closure: {
                let populator = MockPopulatorWithMultipleSQLiteFiles(modelName: "Test", version: "1")
                
                expect(populator.reuseSQLite()).to(beFalse())
            })
            
            it("should NOT reuse sqlite when no files available", closure: {
                let populator = MockPopulatorNO_SQLiteFiles(modelName: "Test", version: "1")
                
                expect(populator.reuseSQLite()).to(beFalse())
            })
            
            
            it("should NOT reuse sqlite when no files available", closure: {
                let populator = MockPopulatorWithNO_versionPrefix_SQLite(modelName: "Test", version: "1")
                
                expect(populator.reuseSQLite()).to(beFalse())
            })
            
        }
    }
    
}