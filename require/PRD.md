# Project overview 

1. '쓰레드' 스타일의 SNS 앱 (UI만 디자인)
2. 간단한 포스팅 기능만 구현
3. 블랙 위주의 심플한 디자인

# Core functionalities

1. 사용자는 홈 피드에서 다른 사람의 게시글을 볼 수 있다. 
   (개발 환경에서는 더미로 다른 사용자의 게시글을 생성)
2. 홈 피드에서는 스크롤을 통해 게시글을 볼 수 있으며, 
   스크롤을 아래로 내리면서 새로운 게시글이 로딩된다.
3. 하단 네비게이션 바는 홈, 검색, 포스팅, 활동, 프로필 탭으로 구성된다.
4. 포스팅 탭에서는 새로운 게시글을 작성할 수 있으며, 
   이미지 촬영 및 업로드 기능이 포함되어 있다.

# 작업 체크리스트

- [x] 1. 프로젝트 기본 구조 세팅 (폴더/파일 생성)  
      - lib/ 하위 폴더 및 주요 파일 생성 완료 (main.dart, models, screens, widgets, utils, theme)
      - main.dart에서 폴더 구조에 맞는 기본 라우팅/네비게이션 틀 적용 완료
- [x] 2. 다크 테마 및 디자인 가이드라인 적용  
      - app_theme.dart에 Material 3, 다크 테마, 색상(Black/White/Blue), 폰트, 버튼, 네비게이션바 등 디자인 가이드라인 반영 완료
- [x] 3. 하단 네비게이션 바 구현  
      - BottomNavBar 위젯을 다크 테마 및 디자인 가이드라인에 맞게 개선(색상, 라벨, 효과 등)
- [x] 4. 홈 피드 UI 및 더미 데이터 표시  
      - HomeScreen에서 더미 데이터(dummyPosts)를 활용해 피드 리스트(ListView) 및 PostItem 위젯으로 게시글 표시 완료
- [x] 5. 무한 스크롤(페이징) 기능 구현  
      - infinite_scroll_pagination 패키지로 HomeScreen에 무한 스크롤(페이징) 기능 적용 완료
- [x] 6. 포스팅(글쓰기) 화면 및 기능 구현  
      - PostScreen에서 텍스트 입력 및 업로드 기능 구현, 업로드 시 홈 피드에 새 게시글 반영 및 자동 이동 처리 완료
- [x] 7. 이미지 촬영/업로드 기능 구현  
      - image_picker 패키지로 포스팅 시 이미지 선택/촬영 및 미리보기, 업로드 시 이미지 포함 기능 구현 완료
- [x] 8. 상태 관리(예: Riverpod) 적용  
      - Riverpod로 게시글 상태를 전역에서 관리하도록 구조 개선 완료
- [x] 9. 라우팅(go_router) 적용
- [x] 10. 기타(프로필, 검색, 활동 등) 화면 틀 구현
- [x] 11. 코드/구조 정리 및 주석 추가

# Doc

## 필수 패키지 및 라이브러리

1. **Flutter 기본 패키지**
   - `flutter/material.dart`  
     (UI, 다크 테마, 네비게이션, 리스트 등)

2. **이미지 촬영 및 업로드**
   - [`image_picker`](https://pub.dev/packages/image_picker)  
     (카메라/갤러리에서 이미지 선택 및 촬영)

3. **상태 관리**
   - 간단한 경우 `StatefulWidget`과 `setState`  
   - 구조 확장 시 [`provider`](https://pub.dev/packages/provider) 등도 고려 가능

4. **더미 데이터 생성**
   - 직접 List로 생성하거나, [`faker`](https://pub.dev/packages/faker) 패키지로 더미 데이터 생성 가능

---

### 추가 필수 패키지

- `flutter_riverpod: ^2.4.9` (상태 관리)
- `go_router: ^13.0.1` (라우팅)
- `cached_network_image: ^3.3.1` (이미지 캐싱)
- `image_picker: ^1.0.7` (이미지 선택/촬영)
- `infinite_scroll_pagination: ^4.0.0` (무한 스크롤)
- `shared_preferences: ^2.2.2` (로컬 데이터 저장)

---

## 참고 문서

- [Flutter 공식 문서](https://docs.flutter.dev/)
- [BottomNavigationBar 위젯](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html)
- [ListView.builder](https://api.flutter.dev/flutter/widgets/ListView-class.html)
- [ImagePicker 패키지 사용법](https://pub.dev/packages/image_picker)
- [다크 테마 적용 가이드](https://docs.flutter.dev/cookbook/design/themes)
- [Provider 패키지 사용법](https://pub.dev/packages/provider) (선택)
- [Faker 패키지 사용법](https://pub.dev/packages/faker) (선택)

---

## 예시 pubspec.yaml 의존성

```yaml
dependencies:
  flutter:
    sdk: flutter
  image_picker: ^1.0.4
  # provider: ^6.0.5      # (필요시)
  # faker: ^2.1.0         # (필요시)
  flutter_riverpod: ^2.4.9
  go_router: ^13.0.1
  cached_network_image: ^3.3.1
  infinite_scroll_pagination: ^4.0.0
  shared_preferences: ^2.2.2
```

---

# 디자인 가이드라인

- **Material Design 3**
- **다크 테마 기반**
- **기본 색상:** Black (`#000000`)
- **보조 색상:** White (`#FFFFFF`)
- **강조 색상:** Blue (`#2196F3`)

---

# Current file structure (현재 파일 구조)

아래는 요구사항에 맞는 추천 파일 구조 예시입니다.

```
lib/
├── main.dart                # 앱 진입점, 테마 및 네비게이션 설정
├── models/
│   └── post.dart            # 게시글(Post) 데이터 모델
├── screens/
│   ├── home_screen.dart     # 홈 피드 화면
│   ├── search_screen.dart   # 검색 화면
│   ├── post_screen.dart     # 포스팅(글쓰기) 화면
│   ├── activity_screen.dart # 활동(알림 등) 화면
│   └── profile_screen.dart  # 프로필 화면
├── widgets/
│   ├── post_item.dart       # 게시글(피드) 아이템 위젯
│   └── bottom_nav_bar.dart  # 하단 네비게이션 바 위젯
├── utils/
│   └── dummy_data.dart      # 더미 데이터 생성 유틸
└── theme/
    └── app_theme.dart       # 다크 테마 등 앱 전체 테마 설정
```

// ... 기타 프로젝트 루트 및 플랫폼별 디렉토리 생략

---

## 진행 상황

- 2024-06-13: 1번 작업(프로젝트 기본 구조 세팅) 완료. 
  - 폴더 및 파일 구조 생성, main.dart 라우팅/네비게이션 적용.
- 2024-06-13: 2번 작업(다크 테마 및 디자인 가이드라인 적용) 완료. 
  - app_theme.dart에 다크 테마, 색상, 폰트, 버튼, 네비게이션바 등 디자인 가이드라인 반영.
- 2024-06-13: 3번 작업(하단 네비게이션 바 구현) 완료. 
  - BottomNavBar 위젯을 다크 테마 및 디자인 가이드라인에 맞게 개선(색상, 라벨, 효과 등).
- 2024-06-13: 4번 작업(홈 피드 UI 및 더미 데이터 표시) 완료. 
  - HomeScreen에서 더미 데이터(dummyPosts)를 활용해 피드 리스트(ListView) 및 PostItem 위젯으로 게시글 표시 완료.
- 2024-06-13: 5번 작업(무한 스크롤(페이징) 기능 구현) 완료. 
  - infinite_scroll_pagination 패키지로 HomeScreen에 무한 스크롤(페이징) 기능 적용 완료.
- 2024-06-13: 6번 작업(포스팅(글쓰기) 화면 및 기능 구현) 완료. 
  - PostScreen에서 텍스트 입력 및 업로드 기능 구현, 업로드 시 홈 피드에 새 게시글 반영 및 자동 이동 처리 완료.
- 2024-06-13: 7번 작업(이미지 촬영/업로드 기능 구현) 완료. 
  - image_picker 패키지로 포스팅 시 이미지 선택/촬영 및 미리보기, 업로드 시 이미지 포함 기능 구현 완료.
- 2024-06-13: 8번 작업(상태 관리(Riverpod) 적용) 완료. 
  - Riverpod로 게시글 상태를 전역에서 관리하도록 구조 개선 완료.

---

## 다음 작업 제안

- 9번: 라우팅(go_router) 적용
  - go_router 패키지를 활용해 각 화면 간 라우팅 구조 개선
