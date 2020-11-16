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

    private var showDetailView = false
    private var cellsPerRow: CGFloat = 2
    
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
        collectionView.useGridLayout(withCellsPerRow: cellsPerRow)
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
    
    private func loadFirstPageOfImages(forTag tag: String) {
        
        imageInteractor.getFirstPageOfResults(forTag: tag) { (viewModels, error) in
            guard let images = viewModels, error == nil else {
                // Set error state
                return
            }
            // Loading new search, don't append
            self.applySnapshot(images: images)
        }
    }
    
    private func loadNextPageOfImages() {
        
        imageInteractor.getNextPageOfResults { (viewModels, error) in
            guard let images = viewModels, error == nil else {
                // Set error state
                return
            }
            // Get current results and append new ones
            var current = self.dataSource.snapshot()
            current.appendItems(images)
            self.applySnapshot(images: current.itemIdentifiers)
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
    
    private func configureCell(_ cell:ImageCollectionViewCell, withViewModel vm: ImageViewModel) {
        
        guard let url = URL(string: vm.largeSquare) else {
            // Set error state for cell?
            return
        }
        
        cell.delegate = self
        cell.titleLabel.text = vm.title
        cell.isLoading = true
        
        self.imageInteractor.getImage(withUrl: url) { (image, error) in
            cell.isLoading = false
            cell.mainImageView.image = image
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
            
            // Animate imageView in and out using alpha to avoid flash when larger image loads
            selectedCell.mainImageView.fadeOutAndInToImage(imageToDisplay)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let aboutToDisplayLastCell = indexPath.row == dataSource.collectionView(collectionView, numberOfItemsInSection: 0) - 1
        
        if aboutToDisplayLastCell {
            self.loadNextPageOfImages()
        }
    }
}

extension ImageSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text?.lowercased(), searchText != "" {
            
            loadFirstPageOfImages(forTag: searchText)
        }
        searchBar.resignFirstResponder()
    }
}

extension ImageSearchViewController: ImageCollectionViewCellDelegate {
    
    func imageCellDidTapShareButton(WithSelectedImage image: UIImage) {
        let ac = UIActivityViewController(activityItems: ["Check out this photo from Flickr! 📷",image],
                                          applicationActivities: nil)
        present(ac, animated: true)
    }
}

extension ImageSearchViewController { // Animation helpers
    
    private func toggleDetailView(forIndexPath ip: IndexPath) {
        
        showDetailView.toggle()
        
        searchBar.isUserInteractionEnabled = !showDetailView
        collectionView.isScrollEnabled = !showDetailView
        
        UIView.animate(withDuration: showDetailView ? 0.4 : 0.6,
                       delay: 0,
                       usingSpringWithDamping: showDetailView ? 0.9 : 0.8,
                       initialSpringVelocity: showDetailView ? 0.0 : 1.0,
                       options: .curveEaseInOut) {
            
            self.searchBar.alpha = self.showDetailView ? 0.2 : 1.0
            
            self.collectionView.useGridLayout(withCellsPerRow: self.showDetailView ? 1 : self.cellsPerRow)
            
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
