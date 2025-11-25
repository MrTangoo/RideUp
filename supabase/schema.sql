-- ============================================
-- RideUp Database Schema
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE (extends auth.users)
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    plan TEXT NOT NULL DEFAULT 'free' CHECK (plan IN ('free', 'premium')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- HORSES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.horses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    breed TEXT,
    sex TEXT,
    age INTEGER,
    weight DOUBLE PRECISION,
    height DOUBLE PRECISION,
    photo_url TEXT,
    health_info TEXT,
    particularities TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ACTIVITIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    horse_id UUID NOT NULL REFERENCES public.horses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    distance DOUBLE PRECISION DEFAULT 0,
    max_speed DOUBLE PRECISION DEFAULT 0,
    avg_speed DOUBLE PRECISION DEFAULT 0,
    calories DOUBLE PRECISION DEFAULT 0,
    workload DOUBLE PRECISION DEFAULT 0,
    elevation_gain DOUBLE PRECISION DEFAULT 0,
    duration_seconds INTEGER DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ACTIVITY POINTS TABLE (GPS tracking data)
-- ============================================
CREATE TABLE IF NOT EXISTS public.activity_points (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES public.activities(id) ON DELETE CASCADE,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    speed DOUBLE PRECISION DEFAULT 0,
    altitude DOUBLE PRECISION,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- HEALTH EVENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.health_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    horse_id UUID NOT NULL REFERENCES public.horses(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    notes TEXT,
    next_due TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- DOCUMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    horse_id UUID NOT NULL REFERENCES public.horses(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_type TEXT,
    file_size INTEGER,
    document_type TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- PLANNING TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.planning (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    horse_id UUID NOT NULL REFERENCES public.horses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    description TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    scheduled_time TIMESTAMP WITH TIME ZONE NOT NULL,
    sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_plan ON public.users(plan);

-- Horses indexes
CREATE INDEX IF NOT EXISTS idx_horses_user_id ON public.horses(user_id);
CREATE INDEX IF NOT EXISTS idx_horses_created_at ON public.horses(created_at DESC);

-- Activities indexes
CREATE INDEX IF NOT EXISTS idx_activities_user_id ON public.activities(user_id);
CREATE INDEX IF NOT EXISTS idx_activities_horse_id ON public.activities(horse_id);
CREATE INDEX IF NOT EXISTS idx_activities_start_time ON public.activities(start_time DESC);

-- Activity points indexes
CREATE INDEX IF NOT EXISTS idx_activity_points_activity_id ON public.activity_points(activity_id);
CREATE INDEX IF NOT EXISTS idx_activity_points_timestamp ON public.activity_points(timestamp);

-- Health events indexes
CREATE INDEX IF NOT EXISTS idx_health_events_horse_id ON public.health_events(horse_id);
CREATE INDEX IF NOT EXISTS idx_health_events_date ON public.health_events(date DESC);
CREATE INDEX IF NOT EXISTS idx_health_events_next_due ON public.health_events(next_due);

-- Documents indexes
CREATE INDEX IF NOT EXISTS idx_documents_horse_id ON public.documents(horse_id);

-- Planning indexes
CREATE INDEX IF NOT EXISTS idx_planning_user_id ON public.planning(user_id);
CREATE INDEX IF NOT EXISTS idx_planning_horse_id ON public.planning(horse_id);
CREATE INDEX IF NOT EXISTS idx_planning_date ON public.planning(date);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_scheduled_time ON public.notifications(scheduled_time);
CREATE INDEX IF NOT EXISTS idx_notifications_sent ON public.notifications(sent);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.horses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.planning ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Horses policies
CREATE POLICY "Users can view own horses" ON public.horses
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own horses" ON public.horses
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own horses" ON public.horses
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own horses" ON public.horses
    FOR DELETE USING (auth.uid() = user_id);

-- Activities policies
CREATE POLICY "Users can view own activities" ON public.activities
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own activities" ON public.activities
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own activities" ON public.activities
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own activities" ON public.activities
    FOR DELETE USING (auth.uid() = user_id);

-- Activity points policies
CREATE POLICY "Users can view own activity points" ON public.activity_points
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.activities
            WHERE activities.id = activity_points.activity_id
            AND activities.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own activity points" ON public.activity_points
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.activities
            WHERE activities.id = activity_points.activity_id
            AND activities.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own activity points" ON public.activity_points
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.activities
            WHERE activities.id = activity_points.activity_id
            AND activities.user_id = auth.uid()
        )
    );

-- Health events policies
CREATE POLICY "Users can view own health events" ON public.health_events
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.horses
            WHERE horses.id = health_events.horse_id
            AND horses.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own health events" ON public.health_events
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.horses
            WHERE horses.id = health_events.horse_id
            AND horses.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own health events" ON public.health_events
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.horses
            WHERE horses.id = health_events.horse_id
            AND horses.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own health events" ON public.health_events
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.horses
            WHERE horses.id = health_events.horse_id
            AND horses.user_id = auth.uid()
        )
    );

-- Documents policies
CREATE POLICY "Users can view own documents" ON public.documents
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.horses
            WHERE horses.id = documents.horse_id
            AND horses.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own documents" ON public.documents
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.horses
            WHERE horses.id = documents.horse_id
            AND horses.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own documents" ON public.documents
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.horses
            WHERE horses.id = documents.horse_id
            AND horses.user_id = auth.uid()
        )
    );

-- Planning policies
CREATE POLICY "Users can view own planning" ON public.planning
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own planning" ON public.planning
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own planning" ON public.planning
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own planning" ON public.planning
    FOR DELETE USING (auth.uid() = user_id);

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notifications" ON public.notifications
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own notifications" ON public.notifications
    FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_horses_updated_at BEFORE UPDATE ON public.horses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_activities_updated_at BEFORE UPDATE ON public.activities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_health_events_updated_at BEFORE UPDATE ON public.health_events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_planning_updated_at BEFORE UPDATE ON public.planning
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- STORAGE BUCKETS
-- ============================================

-- Create storage bucket for photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('photos', 'photos', true)
ON CONFLICT (id) DO NOTHING;

-- Create storage bucket for documents
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for photos
CREATE POLICY "Users can upload own photos" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'photos' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view own photos" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'photos' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete own photos" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'photos' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Storage policies for documents
CREATE POLICY "Users can upload own documents" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'documents' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can view own documents" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'documents' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete own documents" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'documents' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );
