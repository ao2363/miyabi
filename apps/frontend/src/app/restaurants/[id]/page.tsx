'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';

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

interface Review {
  id: string;
  userId: string;
  rating: number;
  title: string;
  content: string;
  visitDate?: string;
  createdAt: string;
}

export default function RestaurantDetail() {
  const params = useParams();
  const [restaurant, setRestaurant] = useState<Restaurant | null>(null);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (params.id) {
      fetchRestaurantDetails();
    }
  }, [params.id]);

  const fetchRestaurantDetails = async () => {
    try {
      const [restaurantRes, reviewsRes] = await Promise.all([
        fetch(`http://localhost:3001/api/restaurants/${params.id}`),
        fetch(`http://localhost:3001/api/reviews/restaurant/${params.id}`)
      ]);

      if (restaurantRes.ok) {
        const restaurantData = await restaurantRes.json();
        setRestaurant(restaurantData);
      }

      if (reviewsRes.ok) {
        const reviewsData = await reviewsRes.json();
        setReviews(reviewsData.data || []);
      }
    } catch (error) {
      console.error('Failed to fetch data:', error);
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

  const renderStars = (rating: number) => {
    return '★'.repeat(rating) + '☆'.repeat(5 - rating);
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-gray-500">読み込み中...</p>
      </div>
    );
  }

  if (!restaurant) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <p className="text-gray-500 mb-4">レストランが見つかりませんでした</p>
          <Link href="/" className="text-red-600 hover:underline">
            トップページに戻る
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4">
          <div className="flex justify-between items-center">
            <Link href="/" className="text-2xl font-bold text-red-600">
              雅 Miyabi
            </Link>
            <nav className="flex gap-4">
              <Link href="/auth/login" className="text-gray-600 hover:text-red-600">
                ログイン
              </Link>
            </nav>
          </div>
        </div>
      </header>

      {/* Restaurant Info */}
      <main className="container mx-auto px-4 py-8">
        <div className="bg-white rounded-lg shadow-lg overflow-hidden mb-8">
          <div className="h-64 bg-gradient-to-r from-red-100 to-orange-100 flex items-center justify-center">
            <span className="text-8xl">🍽️</span>
          </div>
          <div className="p-6">
            <h1 className="text-3xl font-bold mb-2">{restaurant.name}</h1>
            <p className="text-gray-600 mb-4">{restaurant.description}</p>

            <div className="grid grid-cols-2 gap-4 mb-4">
              <div>
                <span className="text-sm text-gray-500">カテゴリ:</span>
                <p className="font-semibold">{restaurant.category}</p>
              </div>
              <div>
                <span className="text-sm text-gray-500">価格帯:</span>
                <p className="font-semibold">{getPriceRangeLabel(restaurant.priceRange)}</p>
              </div>
              <div>
                <span className="text-sm text-gray-500">評価:</span>
                <p className="font-semibold text-yellow-500">
                  ★ {restaurant.rating.toFixed(1)} ({restaurant.reviewCount} 件)
                </p>
              </div>
              <div>
                <span className="text-sm text-gray-500">住所:</span>
                <p className="text-sm">{restaurant.address}</p>
              </div>
            </div>

            <Link
              href={`/restaurants/${restaurant.id}/review`}
              className="inline-block bg-red-600 text-white px-6 py-3 rounded-lg hover:bg-red-700 font-semibold"
            >
              レビューを書く
            </Link>
          </div>
        </div>

        {/* Reviews Section */}
        <div className="bg-white rounded-lg shadow-lg p-6">
          <h2 className="text-2xl font-bold mb-6">レビュー一覧</h2>

          {reviews.length === 0 ? (
            <p className="text-gray-500 text-center py-8">まだレビューがありません</p>
          ) : (
            <div className="space-y-6">
              {reviews.map((review) => (
                <div key={review.id} className="border-b pb-6 last:border-b-0">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-yellow-500 font-bold text-lg">
                      {renderStars(review.rating)}
                    </span>
                    <span className="text-sm text-gray-500">
                      {new Date(review.createdAt).toLocaleDateString('ja-JP')}
                    </span>
                  </div>
                  <h3 className="font-bold text-lg mb-2">{review.title}</h3>
                  <p className="text-gray-700">{review.content}</p>
                  {review.visitDate && (
                    <p className="text-sm text-gray-500 mt-2">
                      訪問日: {new Date(review.visitDate).toLocaleDateString('ja-JP')}
                    </p>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
