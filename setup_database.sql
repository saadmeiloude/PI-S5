-- Supabase Database Setup Script
-- Run this in your Supabase SQL Editor

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  birth_date TIMESTAMPTZ,
  profile_image TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Create doctors table
CREATE TABLE IF NOT EXISTS doctors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  specialty TEXT NOT NULL,
  location TEXT NOT NULL,
  rating DECIMAL(3,2) DEFAULT 0.0,
  review_count INTEGER DEFAULT 0,
  profile_image TEXT,
  qualifications TEXT NOT NULL,
  experience_years INTEGER NOT NULL,
  bio TEXT,
  clinic_address TEXT,
  consultation_fee DECIMAL(10,2),
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for doctors
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;

-- Create policies for doctors
CREATE POLICY "Doctors are viewable by all" ON doctors
  FOR SELECT USING (true);

CREATE POLICY "Doctors can update own profile" ON doctors
  FOR UPDATE USING (auth.uid() = user_id);

-- Insert sample doctors
INSERT INTO doctors (name, specialty, location, qualifications, experience_years, bio, clinic_address, consultation_fee) VALUES
('الدكتور أحمد محمد', 'طبيب قلب', 'الرياض', 'بكالوريوس الطب والجراحة', 15, 'طبيب قلب متخصص في علاج أمراض القلب والشرايين', 'عيادة الرياض الطبية، الرياض', 200.00),
('الدكتورة فاطمة علي', 'طبيبة نساء وتوليد', 'جدة', 'بكالوريوس الطب والجراحة، تخصص نساء وتوليد', 12, 'طبيبة نساء متخصصة في الرعاية الصحية للمرأة', 'مستشفى الملك فهد، جدة', 150.00),
('الدكتور محمد حسن', 'طبيب أطفال', 'الدمام', 'بكالوريوس الطب والجراحة، تخصص طب الأطفال', 10, 'طبيب أطفال متخصص في رعاية الأطفال حديثي الولادة والأطفال', 'مركز الدمام الطبي، الدمام', 120.00);

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_doctors_updated_at BEFORE UPDATE ON doctors
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();