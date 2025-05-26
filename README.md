# my_flutter_app_03

Thread 스타일의 SNS 앱 (Flutter)

## 프로젝트 개요
- 블랙 위주의 심플한 디자인, Material 3 기반
- 홈 피드, 검색, 포스팅, 활동(알림), 프로필 탭 제공
- 게시글 작성(텍스트/이미지), 무한 스크롤, 상태 관리(Riverpod), go_router 기반 라우팅

## 주요 기능
- 홈 피드: 게시글 리스트, 무한 스크롤
- 검색: 게시글/작성자 검색
- 포스팅: 텍스트/이미지 업로드, 업로드 시 피드 반영
- 활동: 게시글 작성 알림
- 프로필: 내 정보, 내가 쓴 게시글 리스트

## 실행 방법
```bash
flutter pub get
flutter run
```

## 주요 사용 패키지
- flutter_riverpod
- go_router
- image_picker
- infinite_scroll_pagination
- intl

## 폴더 구조
```
lib/
├── main.dart
├── models/
├── screens/
├── widgets/
├── utils/
└── theme/
```

## 간단한 사용법
- 하단 네비게이션으로 각 탭 이동
- 포스팅 탭에서 글/이미지 업로드
- 검색 탭에서 키워드로 게시글/작성자 검색
- 프로필 탭에서 내 게시글 확인

---

## Getting Started (Flutter 기본 안내)

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
