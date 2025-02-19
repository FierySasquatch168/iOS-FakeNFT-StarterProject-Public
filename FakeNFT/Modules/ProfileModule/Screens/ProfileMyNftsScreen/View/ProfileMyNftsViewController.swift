//
//  ProfileMyNftsViewController.swift
//  FakeNFT
//
//  Created by Aleksandr Eliseev on 17.07.2023.
//

import UIKit
import Combine

protocol ProfileMyNftsCoordinatable: AnyObject {
    var onSort: (() -> Void)? { get set }
    var onError: ((NetworkError) -> Void)? { get set }
    func setupSortDescriptor(_ sortDescriptor: NftSortValue)
}

final class ProfileMyNftsViewController: UIViewController, ProfileMyNftsCoordinatable, Reloadable {
    
    var onSort: (() -> Void)?
    var onError: ((NetworkError) -> Void)?

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
    
    private lazy var loadingView: CustomAnimatedView = {
        let view = CustomAnimatedView(frame: .zero)
        return view
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
        reload()
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
    
    func setupSortDescriptor(_ sortDescriptor: NftSortValue) {
        viewModel.setupSortDescriptor(sortDescriptor)
    }
    
    // MARK: Bind
    private func bind() {
        viewModel.$visibleRows
            .receive(on: DispatchQueue.main)
            .sink { [weak self] visibleRows in
                self?.updateUI(with: visibleRows)
            }
            .store(in: &cancellables)
        
        viewModel.$requestResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] requestResult in
                guard let self else { return }
                self.showOrHideAnimation(self.loadingView, for: requestResult)
            }
            .store(in: &cancellables)
        
        viewModel.$myNftError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.headOnError(error)
            }
            .store(in: &cancellables)
    }
    
    func reload() {
        viewModel.load()
    }
}

// MARK: - Ext DataSource
private extension ProfileMyNftsViewController {
    func updateUI(with rows: [MyNfts]) {
        dataSource.updateTableView(with: rows)
        scrollToTableBottom(rows)
    }
    
    func createDataSource() {
        dataSource.createDataSource(for: tableView, with: viewModel.visibleRows)
    }
    
    func scrollToTableBottom(_ rows: [MyNfts]) {
        guard !rows.isEmpty else { return }
        let indexPath = IndexPath(row: rows.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - Ext TableView delegate
extension ProfileMyNftsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        dataSource.getRowHeight(.profileMyNft)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? UITableView else { return }

        let lastVisibleRow = tableView.indexPathsForVisibleRows?.last?.row
        if viewModel.isLastLoadedIndexPath(lastVisibleRow) { viewModel.load() }
        
    }
}

// MARK: - Ext NavigationBar
private extension ProfileMyNftsViewController {
    func setupNavigationBar() {
        setupLeftNavBarItem(title: K.Titles.profileMyNfts, action: #selector(cancelTapped))
        setupRightFilterNavBarItem(title: nil, action: #selector(filterTapped))
    }
}

// MARK: - Ext objc
@objc private extension ProfileMyNftsViewController {
    func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func filterTapped() {
        onSort?()
    }
}

// MARK: - Ext Error handling
private extension ProfileMyNftsViewController {
    func headOnError(_ error: NetworkError?) {
        guard let error else { return }
        onError?(error)
    }
}

// MARK: - Ext Constraints
private extension ProfileMyNftsViewController {
    func setupConstraints() {
        setupTableView()
        setupLoadingView()
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
    
    func setupLoadingView() {
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            loadingView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingView.heightAnchor.constraint(equalToConstant: 50),
            loadingView.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}
