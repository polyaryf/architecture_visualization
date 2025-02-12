//
//  UMLNodeView.swift
//  ArchitectureVisualization
//
//  Created by Полина Рыфтина on 10.02.2025.
//
import SwiftUI

struct UMLNodeView: View {
    let node: Node

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(node.name) // Название файла
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                    .lineLimit(1) // Убираем перенос строки, если название длинное
                    .truncationMode(.tail) // Если название длинное, показывать многоточие в конце

                // Пояснение типа Swift элемента
                if let swiftFileType = node.swiftFileType {
                    Text(swiftFileTypeDescription(swiftFileType)) // Тег с типом Swift элемента
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.top, 5)
                }
            }
            .padding(10)
            .frame(width: geometry.size.width) // Делаем размер вьюшки динамическим по ширине
            .background(getBackgroundColor(for: node)) // Цвет фона в зависимости от типа Swift элемента
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(getBorderColor(for: node), lineWidth: 2)
            )
            .shadow(radius: 5) // Для улучшения внешнего вида
        }
        .frame(minWidth: 120) // Устанавливаем минимальную ширину
        .fixedSize(horizontal: false, vertical: true) // Делаем размер вьюшки динамическим по вертикали
        .padding(.bottom, 15) // Отступ снизу между ячейками
    }

    // Получаем текстовое описание типа Swift элемента
    private func swiftFileTypeDescription(_ type: SwiftFileType) -> String {
        switch type {
        case .protocol: return "Protocol"
        case .struct: return "Struct"
        case .enum: return "Enum"
        case .class: return "Class"
        case .extension: return "Extension"
        default: return "Unknown"
        }
    }

    // Функция для получения цвета фона для разных типов Swift элементов
    private func getBackgroundColor(for node: Node) -> Color {
        guard case NodeType.swiftFile(let type) = node.nodeType else {
            return Color.gray.opacity(0.2) // Для не-Swift элементов
        }
        switch type {
        case .protocol:
            return Color.blue.opacity(0.3)
        case .struct:
            return Color.green.opacity(0.3)
        case .enum:
            return Color.purple.opacity(0.3)
        case .class:
            return Color.orange.opacity(0.3)
        case .extension:
            return Color.yellow.opacity(0.3)
        default:
            return Color.clear
        }
    }

    // Цвет обводки для разных типов Swift элементов
    private func getBorderColor(for node: Node) -> Color {
        guard case NodeType.swiftFile(let type) = node.nodeType else {
            return Color.gray
        }
        switch type {
        case .protocol:
            return Color.blue
        case .struct:
            return Color.green
        case .enum:
            return Color.purple
        case .class:
            return Color.orange
        case .extension:
            return Color.yellow
        default:
            return Color.clear
        }
    }
}
