//
//  ViewController.swift
//  TestProject
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import UIKit

class ViewController: UIViewController {
    
    private let presenter: IPresenter
    
    init(presenter: IPresenter) {
        self.presenter = presenter
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Alert", message: "Hi", preferredStyle: .alert)
        present(alert, animated: true)
    }
}

