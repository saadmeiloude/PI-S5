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

-- Insert sample users (for testing - replace with actual auth users)
-- Note: These are placeholder UUIDs. In production, use real user IDs from auth.users
INSERT INTO users (id, email, name, phone) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'patient@example.com', 'المريض التجريبي', '+966501234567'),
('550e8400-e29b-41d4-a716-446655440001', 'doctor1@example.com', 'الدكتور أحمد محمد', '+966507654321'),
('550e8400-e29b-41d4-a716-446655440002', 'doctor2@example.com', 'الدكتورة فاطمة علي', '+966509876543');

-- Insert sample appointments
INSERT INTO appointments (user_id, doctor_id, doctor_name, specialty, appointment_date, time, status, notes) VALUES
('550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001', 'الدكتور أحمد محمد', 'طبيب قلب', NOW() + INTERVAL '1 day', '10:00', 'scheduled', 'فحص دوري'),
('550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440002', 'الدكتورة فاطمة علي', 'طبيبة نساء وتوليد', NOW() + INTERVAL '3 days', '14:30', 'scheduled', 'استشارة');

-- Insert sample consultations
INSERT INTO consultations (user_id, doctor_id, doctor_name, specialty, status, notes) VALUES
('550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001', 'الدكتور أحمد محمد', 'طبيب قلب', 'active', 'استشارة حول ألم في الصدر');

-- Insert sample chat rooms
INSERT INTO chat_rooms (doctor_id, patient_id, doctor_name, patient_name) VALUES
('550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'الدكتور أحمد محمد', 'المريض التجريبي'),
('550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', 'الدكتورة فاطمة علي', 'المريض التجريبي');

-- Insert sample messages
INSERT INTO messages (chat_room_id, sender_id, receiver_id, message, timestamp, status) VALUES
((SELECT id FROM chat_rooms WHERE doctor_id = '550e8400-e29b-41d4-a716-446655440001' LIMIT 1), '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'مرحباً، كيف يمكنني مساعدتك؟', NOW() - INTERVAL '10 minutes', 'read'),
((SELECT id FROM chat_rooms WHERE doctor_id = '550e8400-e29b-41d4-a716-446655440001' LIMIT 1), '550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001', 'أشعر بألم في الصدر', NOW() - INTERVAL '8 minutes', 'read'),
((SELECT id FROM chat_rooms WHERE doctor_id = '550e8400-e29b-41d4-a716-446655440001' LIMIT 1), '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'منذ متى تشعر بهذا الألم؟', NOW() - INTERVAL '5 minutes', 'delivered');

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create appointments table
CREATE TABLE IF NOT EXISTS appointments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  doctor_id UUID NOT NULL,
  doctor_name TEXT NOT NULL,
  specialty TEXT NOT NULL,
  appointment_date TIMESTAMPTZ NOT NULL,
  time TEXT NOT NULL,
  status TEXT DEFAULT 'scheduled',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for appointments
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- Create policies for appointments
CREATE POLICY "Users can view own appointments" ON appointments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own appointments" ON appointments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own appointments" ON appointments
  FOR UPDATE USING (auth.uid() = user_id);

-- Create consultations table
CREATE TABLE IF NOT EXISTS consultations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  doctor_id UUID NOT NULL,
  doctor_name TEXT NOT NULL,
  specialty TEXT NOT NULL,
  consultation_date TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'active',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for consultations
ALTER TABLE consultations ENABLE ROW LEVEL SECURITY;

-- Create policies for consultations
CREATE POLICY "Users can view own consultations" ON consultations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own consultations" ON consultations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create chat_rooms table
CREATE TABLE IF NOT EXISTS chat_rooms (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  doctor_id UUID NOT NULL,
  patient_id UUID REFERENCES users(id) ON DELETE CASCADE,
  doctor_name TEXT NOT NULL,
  patient_name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for chat_rooms
ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;

-- Create policies for chat_rooms
CREATE POLICY "Users can view own chat rooms" ON chat_rooms
  FOR SELECT USING (auth.uid() = doctor_id OR auth.uid() = patient_id);

CREATE POLICY "Users can create chat rooms" ON chat_rooms
  FOR INSERT WITH CHECK (auth.uid() = doctor_id OR auth.uid() = patient_id);

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  chat_room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL,
  receiver_id UUID NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'text',
  attachment_url TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'sent',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for messages
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Create policies for messages
CREATE POLICY "Users can view messages in own chat rooms" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM chat_rooms
      WHERE chat_rooms.id = messages.chat_room_id
      AND (chat_rooms.doctor_id = auth.uid() OR chat_rooms.patient_id = auth.uid())
    )
  );

CREATE POLICY "Users can send messages in own chat rooms" ON messages
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM chat_rooms
      WHERE chat_rooms.id = messages.chat_room_id
      AND (chat_rooms.doctor_id = auth.uid() OR chat_rooms.patient_id = auth.uid())
    )
  );

-- Create consultation_sessions table
CREATE TABLE IF NOT EXISTS consultation_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  chat_room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  doctor_id UUID NOT NULL,
  patient_id UUID REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  start_time TIMESTAMPTZ DEFAULT NOW(),
  end_time TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for consultation_sessions
ALTER TABLE consultation_sessions ENABLE ROW LEVEL SECURITY;

-- Create policies for consultation_sessions
CREATE POLICY "Users can view own consultation sessions" ON consultation_sessions
  FOR SELECT USING (auth.uid() = doctor_id OR auth.uid() = patient_id);

CREATE POLICY "Users can create consultation sessions" ON consultation_sessions
  FOR INSERT WITH CHECK (auth.uid() = doctor_id OR auth.uid() = patient_id);

-- Create triggers for tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_doctors_updated_at BEFORE UPDATE ON doctors
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_consultations_updated_at BEFORE UPDATE ON consultations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_rooms_updated_at BEFORE UPDATE ON chat_rooms
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_consultation_sessions_updated_at BEFORE UPDATE ON consultation_sessions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();