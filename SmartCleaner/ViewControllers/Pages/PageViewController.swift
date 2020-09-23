//
//  PageViewController.swift
//  SmartCleaner
//
//  Created by Max Khizhniakov on 26.08.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    // MARK: - Properties
    fileprivate lazy var pages: [UIViewController] = {
        return [self.getViewController(withIdentifier: "Page1"),
                self.getViewController(withIdentifier: "Page2"),
                self.getViewController(withIdentifier: "Page3")]
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // MARK: - Methods
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
}

// MARK: - Extensions
extension PageViewController: UIPageViewControllerDelegate {}
extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        guard pages.count > previousIndex else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
        guard pages.count > nextIndex else { return nil }
        
        return pages[nextIndex]
    }
}
extension PageViewController {
    func goToNextPage(withIndex index: Int) {
        setViewControllers([pages[index]], direction: .forward, animated: true, completion: nil)
    }
}
