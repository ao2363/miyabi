# データベース ER図

## エンティティ概要

### Users（ユーザー）
ユーザー情報を管理

**主要フィールド**:
- id (UUID, PK)
- username, email (ユニーク)
- password_hash
- role (user/moderator/admin)

### Categories（カテゴリ）
レストランのカテゴリ分類

**主要フィールド**:
- id (UUID, PK)
- name, slug
- parent_id (自己参照FK) - 階層構造対応

### Restaurants（店舗）
レストラン情報

**主要フィールド**:
- id (UUID, PK)
- name, description
- category_id (FK → Categories)
- 住所・位置情報（PostGIS対応）
- 営業情報（opening_hours JSONBフィールド）
- 統計情報（average_rating, review_count等）

### Reviews（レビュー）
ユーザーによる店舗レビュー

**主要フィールド**:
- id (UUID, PK)
- user_id (FK → Users)
- restaurant_id (FK → Restaurants)
- rating (1-5)
- 詳細評価（味・サービス・雰囲気・コスパ）
- ユニーク制約: (user_id, restaurant_id)

### Images（画像）
店舗・レビューの画像

**主要フィールド**:
- id (UUID, PK)
- restaurant_id (FK → Restaurants, nullable)
- review_id (FK → Reviews, nullable)
- user_id (FK → Users)

### Favorites（お気に入り）
ユーザーのお気に入り店舗

**主要フィールド**:
- user_id (FK → Users)
- restaurant_id (FK → Restaurants)
- 複合PK: (user_id, restaurant_id)

### Tags（タグ）
フリータグ

**主要フィールド**:
- id (UUID, PK)
- name, slug
- usage_count（非正規化）

### Restaurant_Tags（店舗タグ関連）
多対多の関連テーブル

### Review_Votes（レビュー投票）
レビューの「役に立った」投票

### Notifications（通知）
ユーザーへの通知

## リレーションシップ

```
Users (1) ────< (N) Reviews
Users (1) ────< (N) Favorites
Users (1) ────< (N) Images
Users (1) ────< (N) Notifications

Categories (1) ────< (N) Restaurants
Categories (1) ────< (N) Categories (self-reference)

Restaurants (1) ────< (N) Reviews
Restaurants (1) ────< (N) Images
Restaurants (1) ────< (N) Favorites
Restaurants (N) ────< (M) Tags (through Restaurant_Tags)

Reviews (1) ────< (N) Images
Reviews (1) ────< (N) Review_Votes

Tags (1) ────< (N) Restaurant_Tags
```

## インデックス戦略

### パフォーマンス最適化
- `users(email)` - ログイン高速化
- `restaurants(category_id)` - カテゴリ検索
- `restaurants(average_rating DESC)` - ランキング表示
- `restaurants USING GIST(location)` - 地理検索（PostGIS）
- `reviews(restaurant_id)` - 店舗のレビュー一覧
- `reviews(created_at DESC)` - 新着レビュー

### ユニーク制約
- `users(email, username)` - 重複防止
- `categories(slug)` - URL対応
- `reviews(user_id, restaurant_id)` - 1ユーザー1レビュー
- `favorites(user_id, restaurant_id)` - 重複お気に入り防止

## トリガー

### 自動更新
- `updated_at` - INSERT/UPDATE時に自動更新
- `restaurants.average_rating` - レビュー変更時に自動再計算
- `restaurants.review_count` - レビュー数の自動更新
- `tags.usage_count` - タグ使用数の自動更新
- `reviews.helpful_count` - 投票数の自動更新

## データ型の特記事項

### JSONB
- `restaurants.opening_hours` - 営業時間を柔軟に保存
```json
{
  "monday": {"open": "11:00", "close": "22:00"},
  "tuesday": {"open": "11:00", "close": "22:00"},
  ...
}
```

### PostGIS
- `restaurants.location` - GEOGRAPHY(POINT) 型
- 緯度経度からの距離計算に使用

### CHECK制約
- `reviews.rating` - 1〜5の範囲
- `restaurants.price_range` - ENUM的制約
- `users.role` - ロールの制限

## セキュリティ

- パスワードは bcrypt でハッシュ化
- RLS（Row Level Security）は今後実装予定
- CASCADE DELETE で関連データも削除
