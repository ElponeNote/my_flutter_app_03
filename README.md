# Thread-Style SNS Flutter App

## 프로젝트 개요
- 트위터/쓰레드 스타일의 간단한 SNS 앱
- 블랙 테마의 미니멀 디자인
- 텍스트/이미지/영상 업로드, 무한 스크롤 피드, 프로필 편집 등 기본 SNS 기능 구현

## 주요 기능 및 작업 내역

### 1. 프로젝트 구조 및 세팅
- `lib/models`, `lib/screens`, `lib/widgets`, `lib/utils`, `lib/theme` 등 폴더 구조 설계
- `main.dart`에서 Riverpod, go_router, 테마 적용 및 네비게이션 구현

### 2. 홈 피드
- 더미 데이터 기반 무한 스크롤 피드 (`infinite_scroll_pagination`)
- 게시글: 텍스트, 이미지, 영상, 작성자 정보, 시간 표시
- 각 게시글에 좋아요/댓글/리포스트/공유 아이콘 및 동작 구현

### 3. 포스팅(업로드)
- 텍스트 입력, 이미지 업로드(`image_picker`), 영상 업로드(`image_picker`, `video_player`)
- 업로드 시 프로필 정보(이름, 사진, 소개글)도 함께 저장
- 업로드 후 피드에 즉시 반영

### 4. 프로필
- 프로필 사진 업로드(갤러리 선택)
- 프로필 편집(이름, 소개글, 사진 변경)
- 내 게시글 리스트 표시(프로필 정보와 일치하는 게시글만)

### 5. 기타 화면
- 바텀 네비게이션: 홈, 검색, 포스트, 알림, 프로필 탭
- 각 탭별 라우팅(go_router)
- 다크/라이트 테마 지원

### 6. 상태 관리
- Riverpod(StateProvider)로 전역 상태 관리(게시글, 프로필 등)

### 7. 사용 패키지
- flutter_riverpod
- go_router
- image_picker
- video_player
- infinite_scroll_pagination
- intl

## 앞으로 참고할 내용
- 실제 서버 연동/DB 연동은 미구현(더미 데이터 기반)
- 공유, 알림, 댓글 등은 UI/UX 위주, 실제 데이터 저장은 미구현
- 추가 기능(팔로우, 알림, 검색 등) 확장 가능

---

> 이 README.md는 현재까지의 작업 내역과 구조를 요약한 것으로, 이후 작업 시 참고용으로 활용하세요.

## 실행 방법
```bash
flutter pub get
flutter run
```

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
