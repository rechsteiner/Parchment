import UIKit

enum Example: CaseIterable {
    case basic
    case selfSizing
    case calendar
    case sizeDelegate
    case images
    case icons
    case storyboard
    case navigationBar
    case largeTitles
    case scroll
    case header
    case multipleCells
    case pageViewController

    var title: String {
        switch self {
        case .basic:
            return "Basic"
        case .selfSizing:
            return "Self sizing cells"
        case .calendar:
            return "Calendar"
        case .sizeDelegate:
            return "Size delegate"
        case .images:
            return "Images"
        case .icons:
            return "Icons"
        case .storyboard:
            return "Storyboard"
        case .navigationBar:
            return "Navigation bar"
        case .largeTitles:
            return "Large titles"
        case .scroll:
            return "Hide menu on scroll"
        case .header:
            return "Header above menu"
        case .multipleCells:
            return "Multiple cells"
        case .pageViewController:
            return "PageViewController"
        }
    }
}

final class ExamplesViewController: UITableViewController {
    static let CellIdentifier = "CellIdentifier"

    var isUITesting: Bool {
        return ProcessInfo.processInfo.arguments.contains("--ui-testing")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.CellIdentifier)

        if isUITesting {
            let viewController = createViewController(for: .basic)
            navigationController?.setViewControllers([viewController], animated: false)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.CellIdentifier, for: indexPath)
        let example = Example.allCases[indexPath.row]
        cell.textLabel?.text = example.title
        return cell
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return Example.allCases.count
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = Example.allCases[indexPath.row]
        let viewController = createViewController(for: example)
        viewController.title = example.title

        switch example {
        case .largeTitles:
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(handleDismiss)
            )
            present(navigationController, animated: true)
        default:
            viewController.view.backgroundColor = .white
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func createViewController(for example: Example) -> UIViewController {
        switch example {
        case .basic:
            return BasicViewController(nibName: nil, bundle: nil)
        case .calendar:
            return CalendarViewController(nibName: nil, bundle: nil)
        case .selfSizing:
            return SelfSizingViewController()
        case .sizeDelegate:
            return SizeDelegateViewController(nibName: nil, bundle: nil)
        case .images:
            return UnsplashViewController(nibName: nil, bundle: nil)
        case .icons:
            return IconsViewController(nibName: nil, bundle: nil)
        case .storyboard:
            return StoryboardViewController(nibName: nil, bundle: nil)
        case .navigationBar:
            return NavigationBarViewController(nibName: nil, bundle: nil)
        case .largeTitles:
            return LargeTitlesViewController(nibName: nil, bundle: nil)
        case .scroll:
            return ScrollViewController(nibName: nil, bundle: nil)
        case .header:
            return HeaderViewController(nibName: nil, bundle: nil)
        case .multipleCells:
            return MultipleCellsViewController(nibName: nil, bundle: nil)
        case .pageViewController:
            return PageViewExampleViewController(nibName: nil, bundle: nil)
        }
    }

    @objc private func handleDismiss() {
        dismiss(animated: true)
    }
}

final class NavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.tintColor = .white
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }

    // For debugging purposes. Adds a hook to push a new view
    // controller to debug navigation controller related issues.
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let viewController = UIViewController()
            viewController.title = "Page"
            viewController.view.backgroundColor = .white
            pushViewController(viewController, animated: true)
        }
    }
}
