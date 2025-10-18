# SimpleMemoApp

Flutter × SQLite で作るシンプルなメモ帳アプリ

[![Flutter](https://img.shields.io/badge/Flutter-3.35.6-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📝 概要

SimpleMemoAppは、Flutter と SQLite を使用したクロスプラットフォーム対応のメモ帳アプリケーションです。メモの作成・編集・削除、カテゴリ管理、検索・並び替え、お気に入り機能など、基本的なメモ管理機能を備えています。また、ライトモード・ダークモードのテーマ切り替えにも対応しています。

## 🎯 開発の目的

このプロジェクトは、**Flutter と Cursor AI エディタに慣れるため**の学習目的で開発されました。まずはシンプルなアプリケーションを作成することで、以下のスキルを習得することを目指しています：

- Flutter の基本的な UI コンポーネントと状態管理
- SQLite を使用したローカルデータベース管理
- 画面遷移とナビゲーション
- テーマ切り替えとユーザー設定の永続化
- Git/GitHub によるバージョン管理
- Cursor AI を活用した効率的な開発ワークフロー

## ✨ 主な機能

### メモ管理
- ✅ **メモの作成**: タイトル・内容・カテゴリを設定して新規メモを作成
- ✅ **メモの編集**: 既存メモの内容を編集・更新
- ✅ **メモの削除**: 不要なメモを削除（確認ダイアログ付き）
- ✅ **メモの一覧表示**: 保存されている全メモをリスト表示

### 検索・フィルタリング
- 🔍 **キーワード検索**: タイトル・内容でメモを検索
- 📁 **カテゴリフィルター**: カテゴリ別にメモを絞り込み
- 📊 **並び替え**: 作成日時・更新日時・お気に入り順で並び替え

### カテゴリ管理
- 📂 **カテゴリ作成**: メモを分類するカテゴリを追加
- ✏️ **カテゴリ編集**: カテゴリ名を変更
- 🗑️ **カテゴリ削除**: 不要なカテゴリを削除

### その他の機能
- ⭐ **お気に入り機能**: よく使うメモをお気に入り登録
- 🎨 **テーマ切り替え**: ライトモード・ダークモードの切り替え
- 💾 **データ管理**: データのエクスポート・インポート・リセット
- ℹ️ **アプリ情報**: バージョン・開発者情報・ライセンス表示

## 🛠️ 技術スタック

### フレームワーク・言語
- **Flutter**: 3.35.6
- **Dart**: 3.9.2

### データベース
- **sqflite**: ^2.3.0 - SQLite データベース
- **path**: ^1.8.3 - ファイルパス操作

### ユーザー設定
- **shared_preferences**: ^2.2.2 - ユーザー設定の永続化

### プラットフォーム対応
- Android
- iOS
- Windows
- macOS
- Linux
- Web

## 📁 プロジェクト構成

```
memo_sample_app/
├── lib/
│   ├── main.dart                # エントリポイント
│   ├── models/
│   │   ├── note.dart            # メモモデル
│   │   └── category.dart        # カテゴリモデル
│   ├── pages/
│   │   ├── memo_list_page.dart  # メモ一覧画面
│   │   ├── memo_edit_page.dart  # メモ作成・編集画面
│   │   ├── category_page.dart   # カテゴリ管理画面
│   │   └── settings_page.dart   # 設定画面
│   ├── widgets/
│   │   ├── note_item.dart       # メモアイテムWidget
│   │   └── category_dropdown.dart # カテゴリ選択Widget
│   └── db/
│       └── database_helper.dart # データベースヘルパー
├── pubspec.yaml
└── README.md
```

## 🚀 セットアップ方法

### 前提条件

- Flutter SDK (3.35.6 以上)
- Dart SDK (3.9.2 以上)
- Android Studio / VS Code
- Git

### インストール手順

1. **リポジトリのクローン**
```bash
git clone https://github.com/hidek1/SimpleMemoApp.git
cd SimpleMemoApp
```

2. **依存関係のインストール**
```bash
flutter pub get
```

3. **アプリの起動**
```bash
# デバイス/エミュレータを起動してから
flutter run
```

### データベース

初回起動時に自動的にSQLiteデータベースが作成され、以下のテストデータが挿入されます：

- **カテゴリ**: 生活、仕事、学習、その他
- **メモ**: 5件のサンプルメモ

## 📱 画面構成

### メモ一覧画面
- 検索バー
- カテゴリフィルター
- 並び替えドロップダウン
- メモリスト（お気に入り・編集・削除ボタン付き）
- 新規作成ボタン（FAB）

### メモ作成・編集画面
- タイトル入力欄
- カテゴリ選択
- 内容入力欄
- お気に入りトグル
- 保存ボタン

### カテゴリ管理画面
- カテゴリ追加フォーム
- カテゴリ一覧（編集・削除ボタン付き）

### 設定画面
- テーマ設定（明るい色/暗い色）
- データ管理（エクスポート/インポート/リセット）
- アプリ情報

## 🗄️ データベース設計

### notes テーブル
| カラム名      | 型      | 説明                     |
|--------------|---------|--------------------------|
| id           | INTEGER | 主キー（自動増分）        |
| title        | TEXT    | メモのタイトル            |
| content      | TEXT    | メモ本文                 |
| category     | TEXT    | カテゴリ名               |
| is_favorite  | INTEGER | お気に入りフラグ（0/1）   |
| created_at   | TEXT    | 作成日時（ISO8601）       |
| updated_at   | TEXT    | 更新日時（ISO8601）       |

### categories テーブル
| カラム名 | 型      | 説明                |
|---------|---------|---------------------|
| id      | INTEGER | 主キー（自動増分）   |
| name    | TEXT    | カテゴリ名          |

## 🎨 スクリーンショット

（スクリーンショットを追加予定）

## 📝 今後の開発予定

- [ ] データのエクスポート/インポート機能の完全実装
- [ ] メモの共有機能
- [ ] タグ機能の追加
- [ ] リマインダー機能
- [ ] 画像添付機能
- [ ] バックアップ機能（クラウド連携）
- [ ] 多言語対応

## 🤝 コントリビューション

プルリクエストは歓迎します。大きな変更の場合は、まずissueを開いて変更内容を議論してください。

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下でライセンスされています。詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 👨‍💻 開発者

- **hidek1** - [GitHub](https://github.com/hidek1)

## 🙏 謝辞

- [Flutter](https://flutter.dev/) - クロスプラットフォームUIフレームワーク
- [sqflite](https://pub.dev/packages/sqflite) - SQLiteプラグイン
- [shared_preferences](https://pub.dev/packages/shared_preferences) - 設定保存プラグイン
- [Cursor AI](https://cursor.sh/) - AI支援開発エディタ

---

**Note**: このアプリは学習目的で開発されたものです。Flutter と Cursor AI エディタに慣れるため、シンプルな機能から段階的に開発を進めています。
