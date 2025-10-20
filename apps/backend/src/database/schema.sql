-- ============================================
-- Miyabi Restaurant Review - Database Schema
-- ============================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================
-- Users Table
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(500),
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'moderator', 'admin')),
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- ============================================
-- Categories Table
-- ============================================
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon VARCHAR(50),
    description TEXT,
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categories_slug ON categories(slug);
CREATE INDEX idx_categories_parent ON categories(parent_id);

-- ============================================
-- Restaurants Table
-- ============================================
CREATE TABLE restaurants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,

    -- Location
    address VARCHAR(500),
    city VARCHAR(100),
    prefecture VARCHAR(50),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    location GEOGRAPHY(POINT, 4326),

    -- Contact
    phone VARCHAR(50),
    website VARCHAR(500),
    email VARCHAR(255),

    -- Business Info
    opening_hours JSONB,
    price_range VARCHAR(20) CHECK (price_range IN ('budget', 'moderate', 'expensive', 'luxury')),
    accepts_reservations BOOLEAN DEFAULT false,
    accepts_credit_cards BOOLEAN DEFAULT false,
    has_parking BOOLEAN DEFAULT false,
    has_wifi BOOLEAN DEFAULT false,
    is_smoking_allowed BOOLEAN DEFAULT false,

    -- Stats (denormalized for performance)
    average_rating DECIMAL(3, 2) DEFAULT 0.00,
    review_count INTEGER DEFAULT 0,
    favorite_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,

    -- Status
    is_active BOOLEAN DEFAULT true,
    verified BOOLEAN DEFAULT false,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_restaurants_category ON restaurants(category_id);
CREATE INDEX idx_restaurants_location ON restaurants USING GIST(location);
CREATE INDEX idx_restaurants_rating ON restaurants(average_rating DESC);
CREATE INDEX idx_restaurants_city ON restaurants(city);
CREATE INDEX idx_restaurants_prefecture ON restaurants(prefecture);
CREATE INDEX idx_restaurants_created_at ON restaurants(created_at DESC);

-- ============================================
-- Reviews Table
-- ============================================
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,

    -- Review Content
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    visit_date DATE,

    -- Ratings breakdown (optional)
    taste_rating INTEGER CHECK (taste_rating >= 1 AND taste_rating <= 5),
    service_rating INTEGER CHECK (service_rating >= 1 AND service_rating <= 5),
    atmosphere_rating INTEGER CHECK (atmosphere_rating >= 1 AND atmosphere_rating <= 5),
    value_rating INTEGER CHECK (value_rating >= 1 AND value_rating <= 5),

    -- Stats
    helpful_count INTEGER DEFAULT 0,
    unhelpful_count INTEGER DEFAULT 0,

    -- Status
    is_published BOOLEAN DEFAULT true,
    is_verified_visit BOOLEAN DEFAULT false,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Ensure one review per user per restaurant
    UNIQUE(user_id, restaurant_id)
);

CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_restaurant ON reviews(restaurant_id);
CREATE INDEX idx_reviews_rating ON reviews(rating DESC);
CREATE INDEX idx_reviews_created_at ON reviews(created_at DESC);
CREATE INDEX idx_reviews_helpful ON reviews(helpful_count DESC);

-- ============================================
-- Images Table
-- ============================================
CREATE TABLE images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    review_id UUID REFERENCES reviews(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    url VARCHAR(1000) NOT NULL,
    thumbnail_url VARCHAR(1000),
    caption VARCHAR(500),
    width INTEGER,
    height INTEGER,
    file_size INTEGER,
    mime_type VARCHAR(100),

    display_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT false,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CHECK (restaurant_id IS NOT NULL OR review_id IS NOT NULL)
);

CREATE INDEX idx_images_restaurant ON images(restaurant_id);
CREATE INDEX idx_images_review ON images(review_id);
CREATE INDEX idx_images_user ON images(user_id);

-- ============================================
-- Favorites Table
-- ============================================
CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,

    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(user_id, restaurant_id)
);

CREATE INDEX idx_favorites_user ON favorites(user_id);
CREATE INDEX idx_favorites_restaurant ON favorites(restaurant_id);
CREATE INDEX idx_favorites_created_at ON favorites(created_at DESC);

-- ============================================
-- Tags Table
-- ============================================
CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tags_slug ON tags(slug);
CREATE INDEX idx_tags_usage ON tags(usage_count DESC);

-- ============================================
-- Restaurant Tags (Junction Table)
-- ============================================
CREATE TABLE restaurant_tags (
    restaurant_id UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (restaurant_id, tag_id)
);

CREATE INDEX idx_restaurant_tags_restaurant ON restaurant_tags(restaurant_id);
CREATE INDEX idx_restaurant_tags_tag ON restaurant_tags(tag_id);

-- ============================================
-- Review Helpfulness (Votes)
-- ============================================
CREATE TABLE review_votes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_helpful BOOLEAN NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(review_id, user_id)
);

CREATE INDEX idx_review_votes_review ON review_votes(review_id);
CREATE INDEX idx_review_votes_user ON review_votes(user_id);

-- ============================================
-- Notifications Table
-- ============================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT,
    link VARCHAR(500),
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- ============================================
-- Triggers for updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_restaurants_updated_at BEFORE UPDATE ON restaurants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Function to update restaurant stats
-- ============================================
CREATE OR REPLACE FUNCTION update_restaurant_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE restaurants
    SET
        average_rating = (
            SELECT COALESCE(AVG(rating), 0)
            FROM reviews
            WHERE restaurant_id = NEW.restaurant_id AND is_published = true
        ),
        review_count = (
            SELECT COUNT(*)
            FROM reviews
            WHERE restaurant_id = NEW.restaurant_id AND is_published = true
        )
    WHERE id = NEW.restaurant_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_restaurant_stats_on_review
    AFTER INSERT OR UPDATE OR DELETE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_restaurant_stats();

-- ============================================
-- Function to update tag usage count
-- ============================================
CREATE OR REPLACE FUNCTION update_tag_usage_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE tags SET usage_count = usage_count + 1 WHERE id = NEW.tag_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE tags SET usage_count = usage_count - 1 WHERE id = OLD.tag_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_tag_usage_on_restaurant_tag
    AFTER INSERT OR DELETE ON restaurant_tags
    FOR EACH ROW
    EXECUTE FUNCTION update_tag_usage_count();

-- ============================================
-- Function to update review helpfulness counts
-- ============================================
CREATE OR REPLACE FUNCTION update_review_helpfulness()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE reviews
    SET
        helpful_count = (
            SELECT COUNT(*) FROM review_votes
            WHERE review_id = NEW.review_id AND is_helpful = true
        ),
        unhelpful_count = (
            SELECT COUNT(*) FROM review_votes
            WHERE review_id = NEW.review_id AND is_helpful = false
        )
    WHERE id = NEW.review_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_review_helpfulness_on_vote
    AFTER INSERT OR UPDATE OR DELETE ON review_votes
    FOR EACH ROW
    EXECUTE FUNCTION update_review_helpfulness();
