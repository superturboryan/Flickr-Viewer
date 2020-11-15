//
//  ViewController.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import UIKit

enum Section {
    case main
}

typealias DataSource = UICollectionViewDiffableDataSource<Section, ImageViewModel>
typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ImageViewModel>

class ImageSearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    private var imageInteractor = ImageInteractor(client: ImageClient.shared)
    
    private var dataSource: DataSource!
    private var snapshot = DataSourceSnapshot()

    private var searchedTag = ""
    private var pageToLoad = 1
    private var showDetailView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder() // Focus searchBar
    }
    
    private func setupView() {
        
        hideKeyboardWhenTapped()
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
    }
    
    private func setupCollectionView() {
        
        collectionView.delegate = self
        collectionView.useGridLayout(withCellsPerRow: 2)
        collectionView.register(UINib(nibName: ImageCollectionViewCell.id, bundle: nil),
                                forCellWithReuseIdentifier: ImageCollectionViewCell.id)
        
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView,
                                                 ip,
                                                 imageModel) -> UICollectionViewCell? in
            
            let url = URL(string: imageModel.largeSquare)!
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.id,
                                                          for: ip) as! ImageCollectionViewCell
            
            cell.titleLabel.text = imageModel.title
            cell.isLoading = true
            
            self.imageInteractor.getImage(withUrl: url) { (image, error) in
                cell.isLoading = false
                cell.mainImageView.image = image
            }
                                    
            return cell
        })
    }
    
    private func loadImages(forTag tag: String, andPage fetchedPage: Int) {
        
        imageInteractor.getImageViewModels(forTag: tag, andPage: fetchedPage) { (viewModels, error) in
            
            guard let images = viewModels, error == nil else {
                // Set error state
                return
            }
            
            self.pageToLoad += 1
            
            if fetchedPage == 1 { // Loading new search, don't append
                self.applySnapshot(images: images)
            }
            else { // Get current snapshot and append!
                var current = self.dataSource.snapshot()
                current.appendItems(images)
                self.applySnapshot(images: current.itemIdentifiers)
            }
        }
    }

    private func applySnapshot(images: [ImageViewModel]) {
        
        snapshot = DataSourceSnapshot()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(images)
        dataSource.apply(snapshot, animatingDifferences: true) {
            // Completion
        }
    }
}

extension ImageSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        toggleShowingCells(exceptFor: indexPath)
        
        guard let selectedViewModel = dataSource.itemIdentifier(for: indexPath),
              let selectedCell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell,
              let url = URL(string: showDetailView ? selectedViewModel.large : selectedViewModel.largeSquare) else { return }

        selectedCell.showTitleLabel = showDetailView
        selectedCell.isLoading = true
        
        imageInteractor.getImage(withUrl: url) { (image, error) in
            
            selectedCell.isLoading = false
            
            guard let imageToDisplay = image, error == nil else { return }
            
            // Animate imageView in and out using alpha to avoid flash when larger image loads
            selectedCell.mainImageView.fadeOutAndInToImage(imageToDisplay)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let aboutToDisplayLastCell = indexPath.row == dataSource.collectionView(collectionView, numberOfItemsInSection: 0) - 1
        
        if aboutToDisplayLastCell {
            self.loadImages(forTag: searchedTag, andPage: pageToLoad)
        }
    }
}

extension ImageSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        pageToLoad = 1 // Reset current page
        
        if let searchText = searchBar.text?.lowercased() {
            
            self.searchedTag = searchText
            loadImages(forTag: searchText, andPage: pageToLoad)
        }
        searchBar.resignFirstResponder()
    }
}

extension ImageSearchViewController { // Animation helpers
    
    private func toggleShowingCells(exceptFor ip: IndexPath) {
        
        showDetailView.toggle()
        
        searchBar.isUserInteractionEnabled = !showDetailView
        collectionView.isScrollEnabled = !showDetailView
        
        UIView.animate(withDuration: showDetailView ? 0.4 : 0.6,
                       delay: 0,
                       usingSpringWithDamping: showDetailView ? 0.9 : 0.8,
                       initialSpringVelocity: showDetailView ? 0.0 : 1.0,
                       options: .curveEaseInOut) {
            
            self.searchBar.alpha = self.showDetailView ? 0.2 : 1.0
            
            self.collectionView.useGridLayout(withCellsPerRow: self.showDetailView ? 1 : 2)
            
            self.collectionView.visibleCells
                .filter({ self.collectionView.indexPath(for: $0)?.row != ip.row })
                .forEach { (cell) in
                    
                    guard let imageCell = cell as? ImageCollectionViewCell else { return }
                    imageCell.isUserInteractionEnabled = !self.showDetailView
                    imageCell.mainImageView.alpha = self.showDetailView ? 0.1 : 1.0;
                }
            
        } completion: { (finished) in /* Completion */ }
    }
}
