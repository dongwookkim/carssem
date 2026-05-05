-- =============================================
-- 카쎔 (CarSSEM) Database Schema
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- 1. Users Table
-- =============================================
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    name TEXT,
    profile_image TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS for users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- =============================================
-- 2. Cars Table
-- =============================================
CREATE TABLE public.cars (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER NOT NULL,
    license_plate TEXT,
    current_mileage INTEGER NOT NULL DEFAULT 0,
    image TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_cars_user_id ON public.cars(user_id);

-- RLS for cars
ALTER TABLE public.cars ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own cars"
    ON public.cars FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cars"
    ON public.cars FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cars"
    ON public.cars FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cars"
    ON public.cars FOR DELETE
    USING (auth.uid() = user_id);

-- =============================================
-- 3. Garages Table
-- =============================================
CREATE TABLE public.garages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    average_rating DOUBLE PRECISION DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for search
CREATE INDEX idx_garages_name ON public.garages(name);

-- RLS for garages (public read, authenticated write)
ALTER TABLE public.garages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view garages"
    ON public.garages FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Authenticated users can insert garages"
    ON public.garages FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- =============================================
-- 4. Maintenance Records Table
-- =============================================
CREATE TABLE public.maintenance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    car_id UUID NOT NULL REFERENCES public.cars(id) ON DELETE CASCADE,
    garage_id UUID REFERENCES public.garages(id) ON DELETE SET NULL,
    date DATE NOT NULL,
    mileage INTEGER NOT NULL,
    total_cost INTEGER NOT NULL DEFAULT 0,
    receipt_image TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_maintenance_records_car_id ON public.maintenance_records(car_id);
CREATE INDEX idx_maintenance_records_date ON public.maintenance_records(date DESC);

-- RLS for maintenance_records
ALTER TABLE public.maintenance_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own maintenance records"
    ON public.maintenance_records FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.cars
            WHERE cars.id = maintenance_records.car_id
            AND cars.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own maintenance records"
    ON public.maintenance_records FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.cars
            WHERE cars.id = car_id
            AND cars.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own maintenance records"
    ON public.maintenance_records FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.cars
            WHERE cars.id = maintenance_records.car_id
            AND cars.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own maintenance records"
    ON public.maintenance_records FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.cars
            WHERE cars.id = maintenance_records.car_id
            AND cars.user_id = auth.uid()
        )
    );

-- =============================================
-- 5. Maintenance Items Table
-- =============================================
CREATE TABLE public.maintenance_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    record_id UUID NOT NULL REFERENCES public.maintenance_records(id) ON DELETE CASCADE,
    category TEXT NOT NULL CHECK (category IN ('부품', '공임', '기타')),
    name TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price INTEGER NOT NULL DEFAULT 0,
    total_price INTEGER NOT NULL DEFAULT 0
);

-- Index for faster queries
CREATE INDEX idx_maintenance_items_record_id ON public.maintenance_items(record_id);

-- RLS for maintenance_items
ALTER TABLE public.maintenance_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own maintenance items"
    ON public.maintenance_items FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.maintenance_records mr
            JOIN public.cars c ON c.id = mr.car_id
            WHERE mr.id = maintenance_items.record_id
            AND c.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own maintenance items"
    ON public.maintenance_items FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.maintenance_records mr
            JOIN public.cars c ON c.id = mr.car_id
            WHERE mr.id = record_id
            AND c.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own maintenance items"
    ON public.maintenance_items FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.maintenance_records mr
            JOIN public.cars c ON c.id = mr.car_id
            WHERE mr.id = maintenance_items.record_id
            AND c.user_id = auth.uid()
        )
    );

-- =============================================
-- 6. Reviews Table
-- =============================================
CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    garage_id UUID NOT NULL REFERENCES public.garages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    record_id UUID REFERENCES public.maintenance_records(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    content TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX idx_reviews_garage_id ON public.reviews(garage_id);
CREATE INDEX idx_reviews_user_id ON public.reviews(user_id);

-- RLS for reviews
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view reviews"
    ON public.reviews FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Users can insert own reviews"
    ON public.reviews FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reviews"
    ON public.reviews FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reviews"
    ON public.reviews FOR DELETE
    USING (auth.uid() = user_id);

-- =============================================
-- 7. Function: Update garage rating
-- =============================================
CREATE OR REPLACE FUNCTION update_garage_rating()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        UPDATE public.garages
        SET
            average_rating = (
                SELECT COALESCE(AVG(rating)::DOUBLE PRECISION, 0)
                FROM public.reviews
                WHERE garage_id = NEW.garage_id
            ),
            review_count = (
                SELECT COUNT(*)
                FROM public.reviews
                WHERE garage_id = NEW.garage_id
            )
        WHERE id = NEW.garage_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.garages
        SET
            average_rating = (
                SELECT COALESCE(AVG(rating)::DOUBLE PRECISION, 0)
                FROM public.reviews
                WHERE garage_id = OLD.garage_id
            ),
            review_count = (
                SELECT COUNT(*)
                FROM public.reviews
                WHERE garage_id = OLD.garage_id
            )
        WHERE id = OLD.garage_id;
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Trigger for auto-updating garage rating
CREATE TRIGGER trigger_update_garage_rating
    AFTER INSERT OR UPDATE OR DELETE ON public.reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_garage_rating();

-- =============================================
-- 8. Function: Auto-create user profile
-- =============================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', '')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for auto-creating user profile on signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- =============================================
-- 9. Storage Buckets
-- =============================================
-- Run these in Supabase Dashboard > Storage

-- INSERT INTO storage.buckets (id, name, public) VALUES ('receipts', 'receipts', false);
-- INSERT INTO storage.buckets (id, name, public) VALUES ('cars', 'cars', false);
-- INSERT INTO storage.buckets (id, name, public) VALUES ('profiles', 'profiles', false);

-- Storage policies (run in SQL Editor)
-- CREATE POLICY "Users can upload receipts" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'receipts' AND auth.uid()::text = (storage.foldername(name))[1]);
-- CREATE POLICY "Users can view own receipts" ON storage.objects FOR SELECT USING (bucket_id = 'receipts' AND auth.uid()::text = (storage.foldername(name))[1]);
