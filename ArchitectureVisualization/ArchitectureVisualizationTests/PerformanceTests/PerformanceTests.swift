//
//  PerformanceTests.swift
//  ArchitectureVisualizationTests
//
//  Created by Полина Рыфтина on 14.01.2025.
//

import XCTest

@testable import ArchitectureVisualization

final class PerformanceTests: XCTestCase {
    
    let dataSource = ListTreeDataSource<String>()
    let parent = Folder(name: "Parent")
   
    
    func test_performance_append() {
        // Given
        
        let parent = "Parent"
        dataSource.append([parent])
        let rootFolder = generateFolderStructure(folderName: "Parent/Root", depth: 6, breadth: 5)
        
        self.measure(metrics: [XCTClockMetric()]) {
            dataSource.append(flattenFolderStructure(rootFolder), to: parent)
        }
    }
}
