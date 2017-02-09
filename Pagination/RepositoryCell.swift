import UIKit

class RepositoryCell: UITableViewCell, BindableCell {
    func bind(_ repository: Repository) {
        textLabel?.text = repository.fullName
        detailTextLabel?.text = "🌟\(repository.stargazersCount)"
    }
}
