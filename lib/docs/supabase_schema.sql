# Supabase Database Schema for Healthcare App

## Required Tables

### 1. users table
```sql
CREATE TABLE users (
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
```

### 2. doctors table
```sql
CREATE TABLE doctors (
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

-- Enable RLS
ALTER TABLE doctors ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Doctors are viewable by all" ON doctors
  FOR SELECT USING (true);

CREATE POLICY "Doctors can update own profile" ON doctors
  FOR UPDATE USING (auth.uid() = user_id);
```

### 3. doctor_working_hours table
```sql
CREATE TABLE doctor_working_hours (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  doctor_id UUID REFERENCES doctors(id) ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL, -- 0=Sunday, 1=Monday, etc.
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_closed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE doctor_working_hours ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Working hours viewable by all" ON doctor_working_hours
  FOR SELECT USING (true);

CREATE POLICY "Doctors can manage own working hours" ON doctor_working_hours
  FOR ALL USING (
    doctor_id IN (
      SELECT id FROM doctors WHERE user_id = auth.uid()
    )
  );
```

### 4. appointments table
```sql
CREATE TABLE appointments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  doctor_id UUID REFERENCES doctors(id) ON DELETE CASCADE,
  appointment_date DATE NOT NULL,
  appointment_time TIME NOT NULL,
  status TEXT DEFAULT 'scheduled', -- scheduled, confirmed, completed, cancelled, rescheduled
  notes TEXT,
  consultation_reason TEXT,
  symptoms TEXT,
  prescription TEXT,
  follow_up_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own appointments" ON appointments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create appointments" ON appointments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own appointments" ON appointments
  FOR UPDATE USING (auth.uid() = user_id);

-- For doctors to view their appointments
CREATE POLICY "Doctors can view their appointments" ON appointments
  FOR SELECT USING (
    doctor_id IN (
      SELECT id FROM doctors WHERE user_id = auth.uid()
    )
  );
```

### 5. consultations table
```sql
CREATE TABLE consultations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  doctor_id UUID REFERENCES doctors(id) ON DELETE CASCADE,
  type TEXT NOT NULL, -- chat, voice, video
  subject TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'active', -- active, completed, cancelled
  started_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE consultations ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can manage own consultations" ON consultations
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Doctors can manage their consultations" ON consultations
  FOR ALL USING (
    doctor_id IN (
      SELECT id FROM doctors WHERE user_id = auth.uid()
    )
  );
```

### 6. reviews table
```sql
CREATE TABLE reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  doctor_id UUID REFERENCES doctors(id) ON DELETE CASCADE,
  appointment_id UUID REFERENCES appointments(id) ON DELETE SET NULL,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review_text TEXT,
  likes INTEGER DEFAULT 0,
  dislikes INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Reviews viewable by all" ON reviews
  FOR SELECT USING (true);

CREATE POLICY "Users can manage own reviews" ON reviews
  FOR ALL USING (auth.uid() = user_id);
```

### 7. notifications table
```sql
CREATE TABLE notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL, -- appointment, consultation, reminder, system
  is_read BOOLEAN DEFAULT false,
  data JSONB, -- Additional data as JSON
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);
```

## Functions and Triggers

### 1. Function to update doctor rating
```sql
CREATE OR REPLACE FUNCTION update_doctor_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE doctors 
  SET 
    rating = (
      SELECT COALESCE(AVG(rating::decimal), 0) 
      FROM reviews 
      WHERE doctor_id = NEW.doctor_id
    ),
    review_count = (
      SELECT COUNT(*) 
      FROM reviews 
      WHERE doctor_id = NEW.doctor_id
    )
  WHERE id = NEW.doctor_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER update_doctor_rating_trigger
  AFTER INSERT OR UPDATE OR DELETE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_doctor_rating();
```

### 2. Function to update timestamps
```sql
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

CREATE TRIGGER update_appointments_updated_at BEFORE UPDATE ON appointments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_consultations_updated_at BEFORE UPDATE ON consultations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Storage Buckets

Create the following storage buckets in Supabase Storage:

1. **avatars** - For user profile images
2. **doctor-images** - For doctor profile images
3. **documents** - For medical documents and files
4. **prescriptions** - For prescription images

## Environment Variables

Set these environment variables in your Supabase project:

```
SUPABASE_URL=https://vsdxqgjzttpdabcxwxro.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

## Setup Instructions

1. Go to your Supabase dashboard
2. Navigate to the SQL Editor
3. Run all the CREATE TABLE statements above
4. Run the functions and triggers
5. Configure Row Level Security (RLS) policies
6. Create storage buckets
7. Set up authentication providers (email/password, Google, etc.)

## API Integration

The app is now configured to use Supabase for:
- User authentication (signup, login, logout, password reset)
- User profile management
- Doctor listings and details
- Appointment scheduling and management
- Consultation tracking
- Reviews and ratings
- Real-time notifications

All database operations are handled through the `SupabaseService` class in `lib/services/supabase_service.dart`.