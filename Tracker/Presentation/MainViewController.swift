//
//  MainViewController.swift
//  Tracker
//
//  Created by Simon Butenko on 02.08.2024.
//

import UIKit

final class MainViewController: UIViewController {
    // MARK: - UI Components

    private lazy var tabBar: UITabBar = {
        let tabBar = UITabBar()
        tabBar.tintColor = .ypBlue
        tabBar.items = [
            UITabBarItem(title: NSLocalizedString("Trackers", comment: "Trackers tab bar item"), image: .ypTrackers, tag: 0),
            UITabBarItem(title: NSLocalizedString("Statistics", comment: "Statistics tab bar item"), image: .ypStatistics, tag: 1)
        ]
        tabBar.selectedItem = tabBar.items?.first
        tabBar.delegate = self
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - View Controllers

    private lazy var trackersViewController = TrackersViewController()
    private lazy var statisticsViewController: UIViewController = {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        let label = UILabel()
        label.text = NSLocalizedString("Statistics", comment: "Statistics tab bar item")
        label.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        return viewController
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        switchToTab(at: 0)
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        [containerView, tabBar].forEach { view.addSubview($0) }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),

            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Tab Switching

    private func switchToTab(at index: Int) {
        guard let viewController = viewControllerForTab(at: index) else { return }

        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }

    private func viewControllerForTab(at index: Int) -> UIViewController? {
        switch index {
        case 0: return trackersViewController
        case 1: return statisticsViewController
        default: return nil
        }
    }
}

// MARK: - UITabBarDelegate

extension MainViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switchToTab(at: item.tag)
    }
}
