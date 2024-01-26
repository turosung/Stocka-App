//
//  SearchViewController.swift
//  Stocka
//
//  Created by Nuhu Sulemana on 25/01/2024.
//

import UIKit
import Combine
import SafariServices

class SearchViewController: UIViewController {
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.barTintColor = .green // Set the background color of the search bar
        return searchBar
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black // Set the background color of the table view
        tableView.separatorColor = .white // Set the separator color
        return tableView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .blue
        label.font = UIFont.boldSystemFont(ofSize: 18)
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: "Your Text", attributes: underlineAttribute)
        label.attributedText = underlineAttributedString
        return label
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.textAlignment = .center
        textView.textColor = .white // Set the text color
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .black // Set the background color of the text view
        return textView
    }()
    let viewModel = CompanyViewModel()
    var cancellables: Set<AnyCancellable> = []
    
    var searchResults: [SearchResultModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchBar()
        configureTableView()
        configureUIElements()
        observeViewModel()
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.isUserInteractionEnabled = true
        tableView.allowsSelection = true
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureUIElements() {
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            textView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        label.textAlignment = .left
        textView.textAlignment = .justified
        view.bringSubviewToFront(tableView)
    }
    
    private func observeViewModel() {
        viewModel.$companyDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateUI()
            }
            .store(in: &cancellables)
    }
    
    func updateUI() {
        
        guard let companyDetails = viewModel.companyDetails else {
            showNoProfileLabel()
            return
        }
        hideNoProfileLabel()
        if let imageUrl = URL(string: companyDetails.image ?? "") {
            let task = URLSession.shared.dataTask(with: imageUrl) { [weak self] (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }
            task.resume()
        }
        
        label.text = companyDetails.website
        // Add tap gesture recognizer to the label
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        
        textView.text = companyDetails.description
        
        
    }
    func showNoProfileLabel() {
        imageView.image = nil
        label.text = nil
        textView.text = nil
        let noProfileLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "There is no company profile, search again"
            label.textColor = .white
            label.textAlignment = .center
            return label
        }()
        
        view.addSubview(noProfileLabel)
        
        NSLayoutConstraint.activate([
            noProfileLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noProfileLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func hideNoProfileLabel() {
        // Remove the "There is no company profile" label if it exists
        view.subviews.first(where: { $0 is UILabel && ($0 as? UILabel)?.text == "There is no company profile, search again" })?.removeFromSuperview()
    }
    @objc private func handleTapOutside() {
        // Hide the keyboard
        searchBar.resignFirstResponder()
    }
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchResults.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        
        let searchApiURL = "\(AppConfig.baseURL)search?query=\(searchText)&apikey=\(AppConfig.apiKey)"
        
        URLSession.shared.dataTaskPublisher(for: URL(string: searchApiURL)!)
            .map(\.data)
            .decode(type: [SearchResultModel].self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .finished:
                    break // Do nothing for successful completion
                case .failure(let error):
                    self.handleSearchError(error)
                }
            } receiveValue: { [weak self] results in
                self?.searchResults = results
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.tableView.isHidden = false
                    
                }
            }
            .store(in: &cancellables)
        if searchText.isEmpty {
            tableView.isHidden = true
        }
    }
    
    @objc private func handleLabelTap() {
        guard let urlString = label.text, let url = URL(string: urlString) else {
            return
        }
        
        // Open the link in Safari ViewController
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    func handleSearchError(_ error: Error) {
        let errorMessage: String
        print("Handling search error")
        if let apiError = error as? APIError {
            errorMessage = apiError.errorMessage
        } else {
            errorMessage = "Limit Reach . Please upgrade your plan"
        }
        
        // Show an alert with the error message
        DispatchQueue.main.async {
            self.presentAlert(title: "Error", message: errorMessage)
            
        }
    }
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = searchResults[indexPath.row].symbol
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < searchResults.count else {
            print("Index out of range")
            return
        }
        tableView.isHidden = true
        searchBar.resignFirstResponder()
        let selectedSymbol = searchResults[indexPath.row].symbol
        viewModel.fetchCompanyDetails(symbol: selectedSymbol)
    }
}



