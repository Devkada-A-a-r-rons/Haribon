-- SQL to create the geocoding_data table in Supabase
-- Run this in the Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.geocoding_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.geocoding_data ENABLE ROW LEVEL SECURITY;

-- Allow public read access (anon)
CREATE POLICY "Public read access" 
ON public.geocoding_data 
FOR SELECT 
TO anon
USING (true);

-- Allow service role full access
CREATE POLICY "Service role full access" 
ON public.geocoding_data 
FOR ALL 
TO service_role 
USING (true)
WITH CHECK (true);
