-- =============================================
-- Storage Buckets & Policies
-- =============================================

-- 1. Create Buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
    ('receipts', 'receipts', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('cars', 'cars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('profiles', 'profiles', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- 2. Receipts Bucket Policies
CREATE POLICY "Users can upload receipts"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'receipts' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view own receipts"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'receipts' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete own receipts"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'receipts' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Public can view receipts"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'receipts');

-- 3. Cars Bucket Policies
CREATE POLICY "Users can upload car images"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'cars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view own car images"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'cars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete own car images"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'cars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Public can view car images"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'cars');

-- 4. Profiles Bucket Policies
CREATE POLICY "Users can upload profile images"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'profiles' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view own profile images"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'profiles' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can update own profile images"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (
        bucket_id = 'profiles' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete own profile images"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'profiles' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Public can view profile images"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'profiles');
