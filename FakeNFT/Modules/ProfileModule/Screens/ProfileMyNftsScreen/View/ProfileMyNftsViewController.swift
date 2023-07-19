//
//  ProfileMyNftsViewController.swift
//  FakeNFT
//
//  Created by Aleksandr Eliseev on 17.07.2023.
//

import UIKit
import Combine

protocol ProfileMyNftsCoordinatable {
    var onCancel: (() -> Void)? { get set }
    var onFilter: (() -> Void)? { get set }
}

final class ProfileMyNftsViewController: UIViewController, ProfileMyNftsCoordinatable {
    
    var onCancel: (() -> Void)?
    var onFilter: (() -> Void)?

    private let viewModel: ProfileMyNftsViewModel
    private let dataSource: GenericTableViewDataSourceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProfileMyNftTableViewCell.self, forCellReuseIdentifier: ProfileMyNftTableViewCell.defaultReuseIdentifier)
        tableView.separatorStyle = .none
        tableView.delegate = self
        return tableView
    }()
    
    // MARK: Init
    init(viewModel: ProfileMyNftsViewModel, dataSource: GenericTableViewDataSourceProtocol) {
        self.viewModel = viewModel
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupConstraints()
        setupNavigationBar()
        load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bind()
        createDataSource()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancellables.forEach({ $0.cancel() })
        cancellables.removeAll()
    }
    
    // MARK: Bind
    private func bind() {
        viewModel.$visibleRows
            .receive(on: DispatchQueue.main)
            .sink { [weak self] visibleRows in
                self?.updateUI(with: visibleRows)
            }
            .store(in: &cancellables)
    }
    
    private func load() {
        viewModel.load()
    }
}

// MARK: - Ext DataSource
private extension ProfileMyNftsViewController {
    private func updateUI(with rows: [VisibleSingleNfts]) {
        dataSource.updateTableView(with: rows)
    }
    
    private func createDataSource() {
        dataSource.createDataSource(for: tableView, with: viewModel.visibleRows)
    }
}

// MARK: - Ext TableView delegate
extension ProfileMyNftsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        dataSource.getRowHeight(for: tableView, in: .profileMyNft)
    }
}

// MARK: - Ext NavigationBar
private extension ProfileMyNftsViewController {
    func setupNavigationBar() {
        setupLeftNavBarItem(title: K.Titles.profileMyNfts, action: #selector(cancelTapped))
        setupRightFilterNavBarItem(title: nil, action: #selector(filterTapped))
    }
}

@objc private extension ProfileMyNftsViewController {
    func cancelTapped() {
        onCancel?()
    }
    
    func filterTapped() {
        onFilter?()
    }
}

// MARK: - Ext Constraints
private extension ProfileMyNftsViewController {
    func setupConstraints() {
        setupTableView()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
