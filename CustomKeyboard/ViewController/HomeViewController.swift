//
//  HomeViewController.swift
//  CustomKeyboard
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    private let viewModel = HomeViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        viewModel.fetch()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReviewViewController" {
            guard let reviewViewController = segue.destination as? ReviewViewController else {
                return
            }
            reviewViewController.delegate = self
        }
    }
    
    @IBAction func touchSubmitButton(_ sender: UIButton) {
        viewModel.submit(contentString: reviewButton.currentTitle ?? "")
    }
}

// MARK: - Private

extension HomeViewController {
    private func configure() {
        configureTableView()
        configureButtons()
        bind()
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.allowsSelection = false
    }
    
    private func configureButtons() {
        [reviewButton, submitButton].forEach { button in
            button?.backgroundColor = UIColor.systemGray6
            button?.layer.cornerRadius = 15
            button?.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        }
        submitButton.isEnabled = false
        reviewButton.titleLabel?.lineBreakMode = .byCharWrapping
    }
    
    private func bind() {
        viewModel.$reviewList
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.tableView.reloadData()
            }
            .store(in: &cancellable)
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reviewListCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.identifier, for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        
        let review = viewModel.review(at: indexPath.row)
        cell.configureCell(review)
        return cell
    }
}

// MARK: - ReviewViewControllerDelegate

extension HomeViewController: ReviewViewControllerDelegate {
    func reviewViewControllerDismiss(_ text: String) {
        if text.isEmpty {
            reviewButton.setTitle("이 테마가 마음에 드시나요?", for: .normal)
            reviewButton.setTitleColor(.lightGray, for: .normal)
            submitButton.isEnabled = false
        } else {
            reviewButton.setTitle(text, for: .normal)
            reviewButton.setTitleColor(.black, for: .normal)
            submitButton.isEnabled = true
        }
    }
}
