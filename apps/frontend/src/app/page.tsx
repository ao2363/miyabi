'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';

interface Restaurant {
  id: string;
  name: string;
  description: string;
  category: string;
  address: string;
  rating: number;
  priceRange: string;
  reviewCount: number;
}

export default function Home() {
  const [restaurants, setRestaurants] = useState<Restaurant[]>([]);
  const [loading, setLoading] = useState(true);
  const [keyword, setKeyword] = useState('');
  const [category, setCategory] = useState('');

  useEffect(() => {
    fetchRestaurants();
  }, [keyword, category]);

  const fetchRestaurants = async () => {
    try {
      let url = 'http://localhost:3001/api/restaurants?';
      if (keyword) url += `keyword=${encodeURIComponent(keyword)}&`;
      if (category) url += `category=${encodeURIComponent(category)}&`;

      const response = await fetch(url);
      const data = await response.json();
      setRestaurants(data.data || []);
    } catch (error) {
      console.error('Failed to fetch restaurants:', error);
    } finally {
      setLoading(false);
    }
  };

  const getPriceRangeLabel = (range: string) => {
    const labels: Record<string, string> = {
      budget: '¥',
      moderate: '¥¥',
      expensive: '¥¥¥',
      luxury: '¥¥¥¥'
    };
    return labels[range] || range;
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4">
          <div className="flex justify-between items-center">
            <h1 className="text-2xl font-bold text-red-600">雅 Miyabi</h1>
            <nav className="flex gap-4">
              <Link href="/auth/login" className="text-gray-600 hover:text-red-600">
                ログイン
              </Link>
              <Link href="/auth/register" className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700">
                新規登録
              </Link>
            </nav>
          </div>
        </div>
      </header>

      {/* Search Bar */}
      <div className="bg-white border-b">
        <div className="container mx-auto px-4 py-6">
          <div className="flex gap-4">
            <input
              type="text"
              placeholder="レストラン名、料理で検索"
              value={keyword}
              onChange={(e) => setKeyword(e.target.value)}
              className="flex-1 px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-red-600"
            />
            <select
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-red-600"
            >
              <option value="">全てのカテゴリ</option>
              <option value="寿司">寿司</option>
              <option value="焼肉">焼肉</option>
              <option value="ラーメン">ラーメン</option>
              <option value="イタリアン">イタリアン</option>
              <option value="フレンチ">フレンチ</option>
            </select>
            <button
              onClick={fetchRestaurants}
              className="bg-red-600 text-white px-6 py-2 rounded-lg hover:bg-red-700"
            >
              検索
            </button>
          </div>
        </div>
      </div>

      {/* Restaurant List */}
      <main className="container mx-auto px-4 py-8">
        <h2 className="text-2xl font-bold mb-6">レストラン一覧</h2>

        {loading ? (
          <div className="text-center py-12">
            <p className="text-gray-500">読み込み中...</p>
          </div>
        ) : restaurants.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-500">レストランが見つかりませんでした</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {restaurants.map((restaurant) => (
              <Link
                key={restaurant.id}
                href={`/restaurants/${restaurant.id}`}
                className="bg-white rounded-lg shadow hover:shadow-lg transition-shadow overflow-hidden"
              >
                <div className="h-48 bg-gradient-to-r from-red-100 to-orange-100 flex items-center justify-center">
                  <span className="text-4xl">🍽️</span>
                </div>
                <div className="p-4">
                  <h3 className="font-bold text-lg mb-2">{restaurant.name}</h3>
                  <p className="text-sm text-gray-600 mb-2">{restaurant.description}</p>
                  <div className="flex items-center justify-between mb-2">
                    <span className="inline-block bg-red-100 text-red-600 text-xs px-2 py-1 rounded">
                      {restaurant.category}
                    </span>
                    <span className="text-yellow-500 font-bold">
                      ★ {restaurant.rating.toFixed(1)}
                    </span>
                  </div>
                  <div className="flex items-center justify-between text-sm text-gray-500">
                    <span>{getPriceRangeLabel(restaurant.priceRange)}</span>
                    <span>{restaurant.reviewCount} 件のレビュー</span>
                  </div>
                  <p className="text-xs text-gray-400 mt-2">{restaurant.address}</p>
                </div>
              </Link>
            ))}
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className="bg-gray-800 text-white py-8 mt-12">
        <div className="container mx-auto px-4 text-center">
          <p>&copy; 2025 Miyabi Restaurant Reviews. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
