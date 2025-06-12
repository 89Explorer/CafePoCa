//
//  HomeViewController.swift
//  CafePoCa
//
//  Created by 권정근 on 6/5/25.
//

import UIKit
import CoreLocation
import Combine

class HomeViewController: UIViewController {
    
    
    // MARK: - Variable
    private let locationManager: CLLocationManager = CLLocationManager()
    private var geocoder: CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var userLocation: String? {
        didSet {
            reloadHomeHeaderSection()
        }
    }
    
    private var homeVM: HomeViewModel = HomeViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    
    // MARK: - UI Component
    //private var homeHeaderView: HomeHeaderView = HomeHeaderView()
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<CafeSectionType, CafeItemType>!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        hideKeyboard()
        setupUIComponent()
        //fetchRegionCodes()
        bindViewModel()
        createDataSource()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocation()
    }
    
    // 상황별로 네비게이션 바 숨김처리
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //homeHeaderView.searchTextField.text = ""
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    // 상태바 숨기기
    //    override var prefersStatusBarHidden: Bool {
    //        return true
    //    }
    
    
    // MARK: - Function
    private func checkLocation() {
        LocationManagerService.shared.setHandlers(
            onUpdate: { [weak self] address, coordinate in
                print("✅ 주소: \(address)")
                print("📍 위도: \(coordinate.latitude), 경도: \(coordinate.longitude)")
                
                self?.userLocation = address
                self?.geocoder = coordinate
                
                // 데이터 가져오기
                self?.fetchRegionCodes()
            },
            onFail: { message in
                if message == "LocationDenied" {
                    self.showRequestLocationServiceAlert()
                } else {
                    print("❌ \(message)")
                }
            }
        )
    }
    
    private func reloadHomeHeaderSection() {
        guard var snapshot = dataSource?.snapshot() else { return }
        
        // 만약 .headerview 섹션이 존재한다면, 그 섹션을 reload
        if snapshot.sectionIdentifiers.contains(.headerview) {
            snapshot.reloadSections([.headerview])
            dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    // MARK: - Action Method
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


// MARK: - CollectionView 설정
extension HomeViewController {
    
    private func setupUIComponent() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompostionalLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.register(CafeBasedOnCurrentLocationCell.self, forCellWithReuseIdentifier: CafeBasedOnCurrentLocationCell.reuseIdentifier)
        collectionView.register(
            HomeHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeHeaderReusableView.reuseIdentifier
        )
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.reuseIdentifier)
        
        //collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
    }
    
    private func reloadData() {
        
        guard let cafeSection = homeVM.homeTotalModel.first(where: { $0.type == .cafe }) else {
            print("⚠️ .cafe 섹션이 없습니다.")
            return
        }
        
        guard let regionSection = homeVM.homeTotalModel.first(where: { $0.type == .region }) else {
            print("⚠️ .region 섹션이 없습니다.")
            return
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<CafeSectionType, CafeItemType>()
        
        snapshot.appendSections([.headerview, .cafe, .region])
        snapshot.appendItems(cafeSection.item, toSection: .cafe)
        snapshot.appendItems(regionSection.item, toSection: .region)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<CafeSectionType, CafeItemType>(
            collectionView: collectionView) {
                collectionView, indexPath, item in
                switch item {
                case .cafe(let cafeInfo):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CafeBasedOnCurrentLocationCell.reuseIdentifier,
                        for: indexPath) as? CafeBasedOnCurrentLocationCell else { return UICollectionViewCell() }
                    cell.configure(with: cafeInfo)
                    return cell
                case .region(let regionInfo):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CategoryCell.reuseIdentifier,
                        for: indexPath) as? CategoryCell else { return UICollectionViewCell() }
                    cell.configure(with: regionInfo)
                    return cell
                }
            }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let sectionType = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            if sectionType == .headerview, kind == UICollectionView.elementKindSectionHeader {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: HomeHeaderReusableView.reuseIdentifier,
                    for: indexPath
                ) as? HomeHeaderReusableView else {
                    return nil
                }
                headerView.delegate = self
                headerView.configure(with: self.userLocation ?? "위치 확인중...")
                return headerView
            }
            
            
            if kind == UICollectionView.elementKindSectionHeader {
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                    for: indexPath) as? SectionHeaderView else {
                    return nil
                }
                
                switch sectionType {
                case .cafe:
                    headerView.configure(with: "내 주변 카페 ☕️")
                case .region:
                    headerView.configure(with: "지역 구분 🌐")
                case .headerview:
                    headerView.configure(with: "")
                }
                return headerView
            }
            return nil
        }
    }
    
    private func createCompostionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            sectionIndex, environment in
            let sectionIdentifier = CafeSectionType.allCases[sectionIndex]
            
            switch sectionIdentifier {
            case .headerview:
                return self.createHeaderSection()
            case .cafe:
                return self.createCafeSection()
            case .region:
                return self.createRegionSection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 8
        layout.configuration = config
        return layout
    }
    
    private func createHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.93),
            heightDimension: .absolute(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        //layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        let layoutGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.93),
            heightDimension: .absolute(1)
        )
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize, subitems: [layoutItem])
        let section = NSCollectionLayoutSection(group: layoutGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(140))
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        section.boundarySupplementaryItems = [header]
        return section
        
    }
    
    private func createCafeSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.93),
            heightDimension: .absolute(350.0))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4)
        
        let layoutGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.93),
            heightDimension: .absolute(350.0)
        )
        
        let layoutGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: layoutGroupSize,
            subitems: [layoutItem]
        )
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0)

        let layoutSectionHeader = createSectionHeader()
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        
        return layoutSection
    }
    
    private func createRegionSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.97 / 2.0), heightDimension: .fractionalHeight(1.0))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let horizontalGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(45)
        )
        
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: horizontalGroupSize,
            subitems: [layoutItem, layoutItem] )
        
        let verticalGroupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.93),
            heightDimension: .estimated(150)
        )
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: verticalGroupSize,
            subitems: [horizontalGroup, horizontalGroup, horizontalGroup]
        )
        
        
        let layoutSection = NSCollectionLayoutSection(group: verticalGroup)
        layoutSection.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
        layoutSection.boundarySupplementaryItems = [createSectionHeader()]
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0)
        return layoutSection
    }

    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(80))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        return layoutSectionHeader
    }
    
    func showRequestLocationServiceAlert() {
        let alert = UIAlertController(
            title: "위치 정보 이용",
            message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.",
            preferredStyle: .alert
        )
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .default) { [weak self] _ in
            self?.reloadDataIfNeeded()
        }
        alert.addAction(cancel)
        alert.addAction(goSetting)
        
        present(alert, animated: true)
    }
    
    // `reloadData` 대체용 (선택사항)
    private func reloadDataIfNeeded() {
        // 권한이 거부된 후 UI를 갱신하거나 데이터를 다시 로드하고 싶다면 여기에 작성
        print("🔄 위치 권한 거부: UI 갱신 필요 시 이곳에서 처리")
    }
}


// MARK: - DataSource
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemPink
        cell.layer.cornerRadius = 12
        return cell
    }
}


// MARK: - UIScrollViewDelegate
//extension HomeViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let yOffset = scrollView.contentOffset.y
//
//        if yOffset > 0 {
//            homeHeaderView.transform = CGAffineTransform(translationX: 0, y: -yOffset)
//        } else {
//            homeHeaderView.transform = .identity
//        }
//    }
//}


// MARK: - 셀 클래스
final class LabelCell: UICollectionViewCell {
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemRed
        contentView.layer.cornerRadius = 8
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String) {
        label.text = text
    }
}


// MARK: - Extension
extension HomeViewController: HomeHeaderViewDelegate {
    func didTappedProfileImage() {
        print("✅ 프로필 창이 눌렸습니다.")
        let vc = ProfileViewController()
        vc.modalTransitionStyle = .coverVertical
        //vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
        //present(vc, animated: true)
    }
    
    func didTappedLocationImage() {
        print("✅ 현재 위치 확인 이미지를 눌렀습니다.")
        let vc = LocationSearchViewController()
        vc.delegate = self
        if let sheet = vc.sheetPresentationController {
            //sheet.detents = [.medium(), .large()]
            sheet.detents = [.custom(resolver: { context in
                120.0
            })]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        present(vc, animated: true)
    }
    
    func didTappedSearchButton(with keyword: String) {
        print("✅ 현재 눌린 검색어: \(keyword)")
        UIView.animate(withDuration: 0.25) {
            self.view.endEditing(true)
        }
        let vc = KeywordSearchViewController(with: keyword)
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - Extension: LocationSearchDelegate
extension HomeViewController: LocationSearchDelegate {
    func checkCurrentLocation(with address: String, coordinate: CLLocationCoordinate2D) {
        print("🎉 성공!")
        print("✅ 주소 재확인: \(address)")
        print("📍 위도 재확인: \(coordinate.latitude), 경도: \(coordinate.longitude)")
        
        self.userLocation = address
        self.geocoder = coordinate
    }
}


// MARK: - Extension: API check
extension HomeViewController {
    private func fetchRegionCodes() {
        
        let lat: String = String(geocoder.latitude)
        let lon: String = String(geocoder.longitude)
        
        Task {
            async let region: () = homeVM.fetchRegionList()
            async let cafeBasedLocationList: () =  homeVM.fetchCafeList(mapX: lon , mapY: lat)
            
            await region
            await cafeBasedLocationList
            
            homeVM.makeAllSection()
        }
    }
    
    private func bindViewModel() {
        homeVM.$homeTotalModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.reloadData()
                //print(items)
                
            }
            .store(in: &cancellables)
    }
    
}
