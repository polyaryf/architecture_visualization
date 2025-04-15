//
//  Presenter.swift
//  TestProject
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import Foundation

protocol IPresenter: AnyObject {
    func show(model: Model)
}

final class Presenter: IPresenter {
    
    weak var view: ViewController?
    
    private let service: IService
    
    init(service: IService) {
        self.service = service
    }
    
    func show(model: Model) {
        view?.showAlert()
    }
}
