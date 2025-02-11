//
//  TestItemIdentifierType.swift
//  ArchitectureVisualizationTests
//
//  Created by Полина Рыфтина on 14.01.2025.
//

import Foundation

struct TestItemIdentifierType: Hashable {
    
    let id: String
    let name: String
}

class File {
    let name: String
    init(name: String) {
        self.name = name
    }
}

class Folder {
    let name: String
    var files: [File] = []
    var subfolders: [Folder] = []
    
    init(name: String) {
        self.name = name
    }
    
    func addFile(_ file: File) {
        files.append(file)
    }
    
    func addSubfolder(_ folder: Folder) {
        subfolders.append(folder)
    }
}

// Функция для генерации случайной иерархии файлов
func generateFolderStructure(folderName: String, depth: Int, breadth: Int) -> Folder {
    let folder = Folder(name: folderName)
    
    // Добавляем файлы в папку
    for i in 0..<breadth {
        let file = File(name: "File_\(i).txt")
        folder.addFile(file)
    }
    
    // Рекурсивно добавляем подпапки, если не достигли максимальной глубины
    if depth > 0 {
        for i in 0..<breadth {
            let subfolder = generateFolderStructure(folderName: "Folder_\(i)", depth: depth - 1, breadth: breadth)
            folder.addSubfolder(subfolder)
        }
    }
    
    return folder
}

// Алгоритм для преобразования структуры в линейный массив
func flattenFolderStructure(_ folder: Folder) -> [String] {
    var result: [String] = []
    result.append(folder.name) // Добавляем имя текущей папки
    
    // Добавляем имена файлов
    for file in folder.files {
        result.append("\(folder.name)/\(file.name)")
    }
    
    // Рекурсивно обрабатываем подпапки
    for subfolder in folder.subfolders {
        let subfolderContent = flattenFolderStructure(subfolder)
        result.append(contentsOf: subfolderContent)
    }
    
    return result
}
