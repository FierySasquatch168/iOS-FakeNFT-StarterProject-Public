//
//  ModulesFactory.swift
//  FakeNFT
//
//  Created by Aleksandr Eliseev on 17.06.2023.
//

import UIKit

protocol CoordinatableProtocol {
    // передача универсальных событий в координатор: returnOnCancel, returnOnSuccess etc.
    var onFilter: (() -> Void)? { get set }
    var onDelete: (() -> Void)? { get set }
    func setupFilter(_ filter: CartFilter)
}

protocol ModulesFactoryProtocol {
    func makeCatalogScreenView() -> UIViewController // TODO: потом заменить на протокол CoordinatableProtocol
    func makeCartScreenView() -> Presentable & CoordinatableProtocol
    
    // TODO: добавить два метода с основными экранами - профиль и статистика
    
    // Здесь создаем основной экран модуля таббара, затем здесь же можно создавать экраны для дальнейших переходов в рамках модуля
    
}

// MARK: Инъекция зависимостей тут
final class ModulesFactory: ModulesFactoryProtocol {
    func makeCatalogScreenView() -> UIViewController {
        // можно настроить экран перед созданием - все зависимые свойства, делегаты и пр.
        return CatalogViewController()
    }
    
    func makeCartScreenView() -> Presentable & CoordinatableProtocol {
        // можно настроить экран перед созданием - все зависимые свойства, делегаты и пр.
        let dataSource = CartDataSourceManager()
        let viewModel = CartViewModel()
        return CartViewController(dataSource: dataSource, viewModel: viewModel)
    }
}
