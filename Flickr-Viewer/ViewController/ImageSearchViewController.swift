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
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var dataSource: DataSource!
    private var snapshot = DataSourceSnapshot()

    private var showDetailView = false
    
    private var imageInteractor = ImageInteractor(client: ImageClient.shared)

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
        loadingView.isHidden = true
        activityIndicator.hidesWhenStopped = false
    }
    
    private func setupCollectionView() {
        
        collectionView.keyboardDismissMode = .interactive
        collectionView.delegate = self
        collectionView.useGridLayout(withCellsPerRow: Constants.ImageGridUI.cellsPerRow)
        collectionView.register(UINib(nibName: ImageCollectionViewCell.id, bundle: nil),
                                forCellWithReuseIdentifier: ImageCollectionViewCell.id)
        
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView,
                                                 ip,
                                                 viewModel) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.id,
                                                          for: ip) as! ImageCollectionViewCell
            self.configureCell(cell, withViewModel: viewModel)
                                    
            return cell
        })
    }
    
    private func configureCell(_ cell:ImageCollectionViewCell, withViewModel vm: ImageViewModel) {
        
        guard let url = URL(string: vm.largeSquare) else {
            // Invalid URL - Set error state for cell?
            return
        }
        cell.delegate = self
        cell.titleLabel.text = vm.title
        
        cell.isLoading = true
        self.imageInteractor.getImage(withUrl: url) { (image, error) in
            cell.isLoading = false
            guard error == nil else { return }
            cell.mainImageView.image = image
        }
    }
    
    private func applySnapshot(images: [ImageViewModel]) {
        
        DispatchQueue.main.async {
            self.snapshot = DataSourceSnapshot()
            self.snapshot.appendSections([Section.main])
            self.snapshot.appendItems(images)
            self.dataSource.apply(self.snapshot, animatingDifferences: true) { /* Completion */ }
        }
    }
}


extension ImageSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        toggleDetailView(forIndexPath: indexPath)
        
        guard let selectedViewModel = dataSource.itemIdentifier(for: indexPath),
              let selectedCell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else { return }

        collectionView.bringSubviewToFront(selectedCell)
        
        selectedCell.showTitleLabel = showDetailView
        selectedCell.showShareButton = showDetailView
        
        guard let url = URL(string: showDetailView ? selectedViewModel.large : selectedViewModel.largeSquare) else { return }
        
        selectedCell.isLoading = true
        imageInteractor.getImage(withUrl: url) { (image, error) in
            
            selectedCell.isLoading = false
            guard let imageToDisplay = image, error == nil else { return }
            // Animate imageView in and out using alpha to avoid flash when new image loads
            selectedCell.mainImageView.fadeOutAndInToImage(imageToDisplay)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let aboutToDisplayLastCell = indexPath.row == dataSource.collectionView(collectionView, numberOfItemsInSection: 0) - 1
        
        if aboutToDisplayLastCell {
            loadNextPageOfImages()
        }
    }
}


extension ImageSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text?.lowercased(), searchText != "" {
            Haptics.impact(forStyle: .soft)
            loadFirstPageOfImages(forTag: searchText)
        }
        searchBar.resignFirstResponder()
    }
}


extension ImageSearchViewController: ImageCollectionViewCellDelegate {
    
    func imageCellDidTapShareButton(WithSelectedImage image: UIImage) {
        let ac = UIActivityViewController(activityItems: ["Check out this photo from Flickr! 📷", image],
                                          applicationActivities: nil)
        present(ac, animated: true)
    }
}


private extension ImageSearchViewController { // Loading image/pages helpers
    
    func loadFirstPageOfImages(forTag tag: String) {
        toggleLoadingAnimation(true)
        imageInteractor.getFirstPageOfResults(forTag: tag) { (viewModels, error) in
            self.toggleLoadingAnimation(false)
            guard let images = viewModels, error == nil else {
                // Set error state
                return
            }
            // Loading new search, don't append to prev snapshot
            self.applySnapshot(images: images)
        }
    }
    
    func loadNextPageOfImages() {
        if imageInteractor.noMoreImagesForTag {
            return
        }
        Haptics.impact(forStyle: .light)
        toggleLoadingAnimation(true)
        imageInteractor.getNextPageOfResults { (viewModels, error) in
            self.toggleLoadingAnimation(false)
            guard let images = viewModels, error == nil else {
                // Set error state
                return
            }
            // Get current snapshot and append new images
            var current = self.dataSource.snapshot()
            current.appendItems(images)
            self.applySnapshot(images: current.itemIdentifiers)
        }
    }
}


extension ImageSearchViewController { // Animation helpers
    
    private func toggleLoadingAnimation(_ animation: Bool) {
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseOut) {
            self.loadingView.isHidden = !animation
            animation ?
                self.activityIndicator.startAnimating() :
                self.activityIndicator.stopAnimating()
        } completion: { (finished) in /* Completion */ }
    }
    
    private func toggleDetailView(forIndexPath ip: IndexPath) {
        
        showDetailView.toggle()
        
        searchBar.isUserInteractionEnabled = !showDetailView
        collectionView.isScrollEnabled = !showDetailView
        // Allow first cell title to be shown outside collectionView
        collectionView.clipsToBounds = !showDetailView
        
        UIView.animate(withDuration: showDetailView ? 0.4 : 0.5,
                       delay: 0,
                       usingSpringWithDamping: showDetailView ? 0.9 : 0.85,
                       initialSpringVelocity: showDetailView ? 0.0 : 1.0,
                       options: .curveEaseInOut) {
            
            self.searchBar.alpha = self.showDetailView ? 0.2 : 1.0
            
            self.collectionView.useGridLayout(withCellsPerRow: self.showDetailView ?
                                                1 : Constants.ImageGridUI.cellsPerRow)
            
            self.fadeCells(exceptFor: ip)
            
        } completion: { (finished) in /* Completion */ }
    }
    
    private func fadeCells(exceptFor ip: IndexPath) {
        
        self.collectionView.visibleCells
            .filter({ self.collectionView.indexPath(for: $0)?.row != ip.row })
            .forEach { (cell) in
                
                guard let imageCell = cell as? ImageCollectionViewCell else { return }
                imageCell.isUserInteractionEnabled = !self.showDetailView
                imageCell.mainImageView.alpha = self.showDetailView ? 0.1 : 1.0;
            }
    }
}
