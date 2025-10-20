# 🍽️ Miyabi Restaurant Review Site

食べログ風のレストランレビューサイト

## 技術スタック

- **Frontend**: Next.js 14 + React + TypeScript + Tailwind CSS
- **Backend**: Node.js + Express + TypeScript
- **Database**: PostgreSQL 16
- **Infrastructure**: Docker + Docker Compose
- **Package Manager**: pnpm (monorepo)

## プロジェクト構成

```
miyabi/
├── apps/
│   ├── frontend/     # Next.js アプリケーション
│   └── backend/      # Express API サーバー
├── packages/
│   └── shared/       # 共有ライブラリ（型定義等）
├── docker-compose.yml
└── pnpm-workspace.yaml
```

## セットアップ

### 前提条件

- Node.js >= 18.0.0
- pnpm >= 8.0.0
- Docker & Docker Compose

### 1. 依存関係のインストール

```bash
pnpm install
```

### 2. 環境変数の設定

```bash
cp .env.example .env
# .envファイルを編集して必要な値を設定
```

### 3. Dockerコンテナの起動

```bash
docker-compose up -d
```

### 4. 開発サーバーの起動

```bash
pnpm dev
```

- Frontend: http://localhost:3000
- Backend API: http://localhost:3001
- PostgreSQL: localhost:5432

## 開発コマンド

```bash
# 開発サーバー起動（全アプリ）
pnpm dev

# ビルド
pnpm build

# テスト実行
pnpm test

# Lint実行
pnpm lint

# クリーンアップ
pnpm clean
```

## データベース

PostgreSQLがDockerコンテナで起動します：

- **Host**: localhost
- **Port**: 5432
- **Database**: miyabi_restaurant_review
- **User**: miyabi
- **Password**: miyabi_dev_password

## API エンドポイント

- `GET /health` - ヘルスチェック
- `GET /api` - API情報

（実装が進むにつれて追加されます）

## Issue進捗

- [x] #1 プロジェクト基盤セットアップ
- [ ] #2 データベーススキーマ設計
- [ ] #3 ユーザー認証システムの実装
...

## ライセンス

Private
