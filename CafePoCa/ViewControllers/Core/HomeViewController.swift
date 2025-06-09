//
//  HomeViewController.swift
//  CafePoCa
//
//  Created by 권정근 on 6/5/25.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    
    
    // MARK: - Variable
    private let locationManager: CLLocationManager = CLLocationManager()
    private var geocoder: CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var userLocation: String? {
        didSet {
            homeHeaderView.configure(with: userLocation ?? "주소 확인 중...")
        }
    }
    
    
    // MARK: - UI Component
    private var homeHeaderView: HomeHeaderView = HomeHeaderView()
    private var collectionView: UICollectionView!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        //locationManager.delegate = self
        
        setupCollectionView()
        setupHeaderView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocation()
    }
    
    // 상태바 숨기기
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Function
    private func checkLocation() {
        LocationManagerService.shared.setHandlers(
            onUpdate: { [weak self] address, coordinate in
                print("✅ 주소: \(address)")
                print("📍 위도: \(coordinate.latitude), 경도: \(coordinate.longitude)")
                      
                self?.userLocation = address
                self?.geocoder = coordinate
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
    
}


// MARK: - CollectionView 설정
extension HomeViewController {
    
    private func setupCollectionView() {
        let layout = createCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 셀 & 헤더 등록
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        //collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    private func setupHeaderView() {
        homeHeaderView.delegate = self
        view.addSubview(homeHeaderView)
        homeHeaderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            homeHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeHeaderView.topAnchor.constraint(equalTo: view.topAnchor),
            homeHeaderView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(80))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(80))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            // ✅ 헤더뷰 설정
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(160))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [sectionHeader]
            //section.contentInsets = NSDirectionalEdgeInsets(top: -10, leading: 0, bottom: 0, trailing: 0)
            
            return section
        }
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
extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        
        if yOffset > 0 {
            homeHeaderView.transform = CGAffineTransform(translationX: 0, y: -yOffset)
        } else {
            homeHeaderView.transform = .identity
        }
    }
}


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
    }
}


// MARK: - Extension: LocationSearchDelegate
extension HomeViewController: LocationSearchDelegate {
    func checkCurrentLocation(with address: String, coordinate: CLLocationCoordinate2D) {
        print("🎉 성공!")
        print("✅ 주소 재확인: \(address)")
        print("📍 위도 재확인: \(coordinate.latitude), 경도: \(coordinate.longitude)")
              
        self.userLocation = address
    }
}


// MARK: - Extension: CLLocationManagerDelegate


//extension HomeViewController: CLLocationManagerDelegate {
//
//    /*
//    func checkUserDeviceLocationServiceAuthorization() {
//        // 1. 디바이스 차원의 위치 서비스가 켜져 있는지 확인
//        guard CLLocationManager.locationServicesEnabled() else {
//            showRequestLocationServiceAlert()
//            return
//        }
//
//        // 2. 위치 권한 요청 (결과는 delegate 메서드에서 처리)
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//    }
//    */
//
//    // iOS 14 이상 권한 변경 감지 콜백
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        handleAuthorizationStatus(manager.authorizationStatus)
//    }
//
//    // iOS 14 미만 권한 변경 감지 콜백
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        handleAuthorizationStatus(status)
//    }
//
//    // 실제 권한 상태에 따라 분기 처리하는 함수
//    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
//        switch status {
//        case .notDetermined:
//            // 사용자가 아직 권한 선택을 하지 않은 상태 (다시 request 요청함)
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.requestWhenInUseAuthorization()
//
//        case .restricted, .denied:
//            // 설정에서 위치 권한을 꺼뒀거나 제한된 경우
//            showRequestLocationServiceAlert()
//
//        case .authorizedWhenInUse, .authorizedAlways:
//            // 권한이 허용된 상태 → 위치 정보 요청
//            locationManager.startUpdatingLocation()
//
//        default:
//            print("Unhandled status: \(status.rawValue)")
//        }
//    }
//
//    // 위치 업데이트 콜백
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        if let coordinate = locations.last?.coordinate {
//            // ⭐️ 사용자 위치 정보 활용
//            print("사용자 위치: \(coordinate.latitude), \(coordinate.longitude)")
//
//            reverseGeocode(location: location) { [weak self] address in
//                guard let self = self else { return }
//                if let address = address {
//                    print("✅ 변환주소: \(address)")
//                    homeHeaderView.configure(with: address)
//
//                } else {
//                    print("⚠️ 주소 변환 실패")
//                }
//            }
//        }
//        locationManager.stopUpdatingLocation()
//    }
//
//    // 위치 요청 실패 콜백
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("❌ 위치 정보 가져오기 실패: \(error.localizedDescription)")
//    }
//
    // 위치 권한이 꺼져있는 경우 사용자 설정 유도
    
//
 
//
//    // 위도와 경도를 주소로 변환하는 메서드
//    func reverseGeocode(location: CLLocation, completion: @escaping (String?) -> Void) {
//        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
//            if let error = error {
//                print("Reverse geocoding failed: \(error.localizedDescription)")
//                completion(nil) // 에러가 발생한 경우 nil을 반환
//                return
//            }
//
//            guard let placemark = placemarks?.first else {
//                print("No placemark found")
//                completion(nil) // placemark가 없는 경우 nil을 반환
//                return
//            }
//
//            // 지번 주소 구성
//            // let country = placemark.country ?? ""
//            let administrativeArea = placemark.administrativeArea ?? ""
//            let locality = placemark.locality ?? ""
//            let subLocality = placemark.subLocality ?? ""
//            // thoroughfare와 subThoroughfare는 생략
//
//            let jibunAddress = "\(administrativeArea) \(locality)"
//
//            // userLocation에 값을 할당
//            self.userLocation = jibunAddress
//
//            // 완료된 후 jibunAddress를 completion handler로 전달
//            completion(jibunAddress)
//        }
//    }
//}



