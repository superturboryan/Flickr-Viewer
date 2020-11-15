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
    
    private var dataSource: DataSource!
    private var snapshot = DataSourceSnapshot()
    
    private var imageInteractor = ImageInteractor(client: ImageServiceClient.shared)
    
    private var searchedTag = ""
    private var pageToLoad = 1
    private var showDetail = false
    
    private let cellPadding:CGFloat = 2.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollectionView()
    }
    
    private func setupView() {
        
        hideKeyboardWhenTapped()
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
    }
    
    private func setupCollectionView() {
        
        collectionView.delegate = self
        
        collectionView.useGridLayout(withCellsPerRow: 2,
                                     cellPadding: cellPadding)
        
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
            ImageServiceClient.shared.fetchImage(withUrl: url) { (image, error) in
                cell.isLoading = false
                cell.mainImageView.image = image
            }
                                    
            return cell
        })
    }
    
    private func loadImages(forTag tag: String, andPage page: Int) {
        
        imageInteractor.getImageViewModels(forTag: tag, andPage: page) { (viewModels, error) in
            
            guard let images = viewModels, error == nil else {
                // Set error state
                return
            }
            
            self.pageToLoad += 1
            
            if page == 1 { // If loading new search, don't append
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
    
    // Used to hide/show cells when selecting cell
    private func toggleShowingCells(exceptFor ip: IndexPath) {
        
        UIView.animate(withDuration: showDetail ? 0.5 : 0.65,
                       delay: 0,
                       usingSpringWithDamping: showDetail ? 0.9 : 0.75,
                       initialSpringVelocity: showDetail ? 0.0 : 1.0,
                       options: .curveEaseInOut) {
            
            self.collectionView.useGridLayout(withCellsPerRow: self.showDetail ? 1 : 2,
                                              cellPadding: 5.0)
            
            self.searchBar.alpha = self.showDetail ? 0.2 : 1.0
            
            self.collectionView.visibleCells
                .filter({ self.collectionView.indexPath(for: $0)?.row != ip.row })
                .forEach { (cell) in
                    
                    let imageCell = cell as! ImageCollectionViewCell
                    imageCell.isUserInteractionEnabled = !self.showDetail
                    imageCell.mainImageView.alpha = self.showDetail ? 0.2 : 1.0;
                }
            
        } completion: { (finished) in
            
        }
    }
}

extension ImageSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        showDetail.toggle()
        
        // Don't allow scrolling when showing detail
        searchBar.isUserInteractionEnabled = !showDetail
        collectionView.isScrollEnabled = !showDetail
        
        guard let selectedViewModel = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        
        toggleShowingCells(exceptFor: indexPath)
        
        selectedCell.showTitleLabel = self.showDetail
        
        guard let url = URL(string: showDetail ? selectedViewModel.large : selectedViewModel.largeSquare) else {
            // Some images don't have all sizes so we won't load a different detail image for now
            return
        }
        
        selectedCell.isLoading = true
        
        imageInteractor.getImage(withUrl: url) { (image, error) in
            
            selectedCell.isLoading = false
            
            guard let imageToDisplay = image, error == nil else { return }
            
            // Animate imageView in and out using alpha
            // to avoid flash when larger image loads
            selectedCell.mainImageView.fadeOutAndInToImage(imageToDisplay) {
                // Completion
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let aboutToDisplayLastCell = indexPath.row == dataSource.collectionView(collectionView, numberOfItemsInSection: 0) - 1
        
        if aboutToDisplayLastCell {
            
            self.loadImages(forTag: self.searchedTag, andPage: self.pageToLoad)
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
