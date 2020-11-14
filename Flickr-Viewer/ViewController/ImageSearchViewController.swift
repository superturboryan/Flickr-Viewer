//
//  ViewController.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import UIKit

struct ImageViewModel: Hashable {
    var largeSquare: String
    var large: String
    var title: String
}

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
    
    private var currentPage = 1
    private var showDetail = false
    
    private let cellPadding:CGFloat = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupCollectionView()
    }
    
    private func setupView() {
        
        hideKeyboardWhenTappedAround()
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
    }
    
    private func setupCollectionView() {
        
        collectionView.clipsToBounds = false
        
        collectionView.useGridLayout(withCellsPerRow: 2,
                                     cellPadding: cellPadding)
        
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        collectionView.delegate = self
        
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView,
                                                 ip,
                                                 imageModel) -> UICollectionViewCell? in
            let url = URL(string: imageModel.largeSquare)!
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell",
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
    
    func loadImages(forTag tag: String, andPage page: Int) {
        
        ImageServiceClient.shared.fetchImageInfo(forTag: tag, page: page) { (result, error) in
            
            guard let imageInfos = result?.imagesInfo, error == nil else {
                
                // Set error state?
                return
            }
            
            var viewModels = [ImageViewModel]()
            
            let group = DispatchGroup.init()
            
            for imageInfo in imageInfos {
                
                group.enter()
                
                ImageServiceClient.shared.fetchImageSizeInfo(forId: imageInfo.id) { (sizeInfoResult, error) in
                    
                    if let sizeInfos = sizeInfoResult {
                    
                        viewModels.append(ImageViewModel(largeSquare: sizeInfos.urlStringForType(ImageSize.LargeSquare),
                                                         large: sizeInfos.urlStringForType(ImageSize.Large),
                                                         title: imageInfo.title))
                    }
                    
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                
                self.applySnapshot(images: viewModels)
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
        
        UIView.animate(withDuration: 0.5) {
            
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
        }
    }
}

extension ImageSearchViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        showDetail.toggle()
        
        guard let selectedViewModel = dataSource.itemIdentifier(for: indexPath) else { return }
        guard let url = URL(string: showDetail ? selectedViewModel.large : selectedViewModel.largeSquare) else { return }
        let selectedCell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
        
        toggleShowingCells(exceptFor: indexPath)
        
        selectedCell.showTitleLabel = self.showDetail
        
        searchBar.isUserInteractionEnabled = !showDetail
        collectionView.isScrollEnabled = !showDetail
        
        selectedCell.isLoading = true
        
        ImageServiceClient.shared.fetchImage(withUrl: url) { (image, error) in
            
            selectedCell.isLoading = false
            
            if (error == nil) {
                
                selectedCell.mainImageView.image = image
            }
        }
    }
}

extension ImageSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        currentPage = 1 // Reset current page
        
        if let searchText = searchBar.text?.lowercased() {
            
            loadImages(forTag: searchText, andPage: currentPage)
        }
        searchBar.resignFirstResponder()
    }
}
