-- ============================================
-- Seed Data for Miyabi Restaurant Review
-- ============================================

-- Categories
INSERT INTO categories (id, name, slug, icon, display_order) VALUES
    ('11111111-1111-1111-1111-111111111111', '和食', 'japanese', '🍱', 1),
    ('22222222-2222-2222-2222-222222222222', '洋食', 'western', '🍝', 2),
    ('33333333-3333-3333-3333-333333333333', '中華', 'chinese', '🥟', 3),
    ('44444444-4444-4444-4444-444444444444', 'カフェ', 'cafe', '☕', 4),
    ('55555555-5555-5555-5555-555555555555', 'イタリアン', 'italian', '🍕', 5),
    ('66666666-6666-6666-6666-666666666666', 'フレンチ', 'french', '🥐', 6),
    ('77777777-7777-7777-7777-777777777777', '焼肉', 'yakiniku', '🥩', 7),
    ('88888888-8888-8888-8888-888888888888', 'ラーメン', 'ramen', '🍜', 8),
    ('99999999-9999-9999-9999-999999999999', '寿司', 'sushi', '🍣', 9),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '居酒屋', 'izakaya', '🍶', 10);

-- Tags
INSERT INTO tags (name, slug) VALUES
    ('デート向け', 'date-friendly'),
    ('子連れOK', 'family-friendly'),
    ('個室あり', 'private-rooms'),
    ('深夜営業', 'late-night'),
    ('テイクアウト可', 'takeout'),
    ('デリバリー可', 'delivery'),
    ('ベジタリアン対応', 'vegetarian'),
    ('ハラル対応', 'halal'),
    ('駅近', 'near-station'),
    ('駐車場あり', 'parking-available'),
    ('WiFiあり', 'wifi-available'),
    ('禁煙', 'non-smoking'),
    ('貸切可', 'private-hire'),
    ('予約推奨', 'reservation-recommended'),
    ('行列店', 'popular-queue');

-- Sample Users (passwords are hashed 'password123')
INSERT INTO users (id, username, email, password_hash, role, email_verified) VALUES
    ('u0000001-0001-0001-0001-000000000001', 'admin', 'admin@miyabi.test', '$2b$10$rZ1YqJqGDe5xN8xqK.YcTOqNZvY8XqJ7vQgN5qYqJ7vQgN5qYqJ7v', 'admin', true),
    ('u0000002-0002-0002-0002-000000000002', 'foodlover', 'foodlover@example.com', '$2b$10$rZ1YqJqGDe5xN8xqK.YcTOqNZvY8XqJ7vQgN5qYqJ7vQgN5qYqJ7v', 'user', true),
    ('u0000003-0003-0003-0003-000000000003', 'gourmet_critic', 'critic@example.com', '$2b$10$rZ1YqJqGDe5xN8xqK.YcTOqNZvY8XqJ7vQgN5qYqJ7vQgN5qYqJ7v', 'user', true),
    ('u0000004-0004-0004-0004-000000000004', 'ramen_enthusiast', 'ramen@example.com', '$2b$10$rZ1YqJqGDe5xN8xqK.YcTOqNZvY8XqJ7vQgN5qYqJ7vQgN5qYqJ7v', 'user', true),
    ('u0000005-0005-0005-0005-000000000005', 'sushi_master', 'sushi@example.com', '$2b$10$rZ1YqJqGDe5xN8xqK.YcTOqNZvY8XqJ7vQgN5qYqJ7vQgN5qYqJ7v', 'moderator', true);

-- Sample Restaurants
INSERT INTO restaurants (id, name, description, category_id, address, city, prefecture, postal_code, latitude, longitude, phone, price_range, average_rating, review_count, is_active, verified) VALUES
    ('r0000001-0001-0001-0001-000000000001',
     '銀座 鮨処 雅',
     '伝統的な江戸前寿司を提供する老舗。厳選されたネタと熟練の技が光る。',
     '99999999-9999-9999-9999-999999999999',
     '東京都中央区銀座4-1-1',
     '中央区',
     '東京都',
     '104-0061',
     35.6712,
     139.7650,
     '03-1234-5678',
     'luxury',
     4.8,
     150,
     true,
     true),

    ('r0000002-0002-0002-0002-000000000002',
     'ラーメン二郎 三田本店',
     '伝説的な二郎系ラーメンの総本山。圧倒的なボリュームとこってりスープが特徴。',
     '88888888-8888-8888-8888-888888888888',
     '東京都港区三田2-16-4',
     '港区',
     '東京都',
     '108-0073',
     35.6503,
     139.7409,
     '03-3456-7890',
     'budget',
     4.5,
     500,
     true,
     true),

    ('r0000003-0003-0003-0003-000000000003',
     'カフェ ド フルール',
     'フレンチスタイルのおしゃれなカフェ。手作りスイーツとこだわりのコーヒーが人気。',
     '44444444-4444-4444-4444-444444444444',
     '東京都渋谷区神宮前5-10-1',
     '渋谷区',
     '東京都',
     '150-0001',
     35.6656,
     139.7101,
     '03-5678-9012',
     'moderate',
     4.3,
     200,
     true,
     true);

-- Sample Reviews
INSERT INTO reviews (id, user_id, restaurant_id, rating, title, content, visit_date, taste_rating, service_rating, atmosphere_rating, value_rating, is_published) VALUES
    ('rv000001-0001-0001-0001-000000000001',
     'u0000002-0002-0002-0002-000000000002',
     'r0000001-0001-0001-0001-000000000001',
     5,
     '最高の江戸前寿司体験',
     'カウンター席で職人の技を目の前で見ながらいただく寿司は格別でした。特に大トロの握りは口の中でとろけるような食感で感動しました。',
     '2024-01-15',
     5, 5, 5, 4,
     true),

    ('rv000002-0002-0002-0002-000000000002',
     'u0000003-0003-0003-0003-000000000003',
     'r0000001-0001-0001-0001-000000000001',
     5,
     '予約必須の名店',
     'おまかせコースを注文。季節の旬のネタを使った創作寿司も素晴らしかったです。',
     '2024-02-20',
     5, 5, 5, 4,
     true),

    ('rv000003-0003-0003-0003-000000000003',
     'u0000004-0004-0004-0004-000000000004',
     'r0000002-0002-0002-0002-000000000002',
     5,
     '二郎系の真髄',
     'ラーメン小でもボリューム満点。麺は極太でモチモチ、スープは濃厚でパンチが効いています。',
     '2024-03-10',
     5, 4, 4, 5,
     true),

    ('rv000004-0004-0004-0004-000000000004',
     'u0000005-0005-0005-0005-000000000005',
     'r0000003-0003-0003-0003-000000000003',
     4,
     '雰囲気の良いカフェ',
     'インスタ映えする素敵な内装。ケーキセットがおすすめです。',
     '2024-03-25',
     4, 4, 5, 4,
     true);

-- Sample Favorites
INSERT INTO favorites (user_id, restaurant_id) VALUES
    ('u0000002-0002-0002-0002-000000000002', 'r0000001-0001-0001-0001-000000000001'),
    ('u0000002-0002-0002-0002-000000000002', 'r0000003-0003-0003-0003-000000000003'),
    ('u0000003-0003-0003-0003-000000000003', 'r0000001-0001-0001-0001-000000000001'),
    ('u0000004-0004-0004-0004-000000000004', 'r0000002-0002-0002-0002-000000000002');

-- Sample Restaurant Tags
INSERT INTO restaurant_tags (restaurant_id, tag_id) VALUES
    ('r0000001-0001-0001-0001-000000000001', (SELECT id FROM tags WHERE slug = 'date-friendly')),
    ('r0000001-0001-0001-0001-000000000001', (SELECT id FROM tags WHERE slug = 'reservation-recommended')),
    ('r0000002-0002-0002-0002-000000000002', (SELECT id FROM tags WHERE slug = 'popular-queue')),
    ('r0000002-0002-0002-0002-000000000002', (SELECT id FROM tags WHERE slug = 'near-station')),
    ('r0000003-0003-0003-0003-000000000003', (SELECT id FROM tags WHERE slug = 'wifi-available')),
    ('r0000003-0003-0003-0003-000000000003', (SELECT id FROM tags WHERE slug = 'non-smoking'));
