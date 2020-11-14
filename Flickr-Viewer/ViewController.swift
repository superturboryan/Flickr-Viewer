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

class ViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ImageViewModel>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ImageViewModel>
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: DataSource!
    private var snapshot = DataSourceSnapshot()
    
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
        
        collectionView.useGridLayout(withCellsPerRow: 2,
                                     cellPadding: 5.0)
        
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "ImageCollectionViewCell")
        
        dataSource = DataSource(collectionView: collectionView,
                                cellProvider: { (collectionView,
                                                 ip,
                                                 imageModel) -> UICollectionViewCell? in
            let url = URL(string: imageModel.largeSquare)!
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell",
                                                          for: ip) as! ImageCollectionViewCell
            
            cell.setLoading(true)
            ImageServiceClient.shared.fetchImage(withUrl: url) { (image, error) in
                cell.setLoading(false)
                cell.mainImageView.image = image
            }
                                    
            return cell
        })
    }
    
    func loadImages(forTag tag: String) {
        
        ImageServiceClient.shared.fetchImageInfo(forTag: tag, page: 1) { (result, error) in
            
            guard let imageInfos = result?.imagesInfo else {
                
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
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        guard let imageModel = dataSource.itemIdentifier(for: indexPath) else { return }
        // Do something after tapping cell
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let searchText = searchBar.text?.lowercased() {
            
            loadImages(forTag: searchText)
        }
        
        searchBar.resignFirstResponder()
    }
}
