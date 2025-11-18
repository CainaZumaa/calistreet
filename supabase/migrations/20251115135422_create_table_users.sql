-- Table: users (authentication)
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email varchar(255) UNIQUE NOT NULL,
  password varchar(255),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TYPE user_profile_gender AS ENUM ('male', 'female', 'other');

CREATE TYPE level_enum AS ENUM ('beginner', 'intermediate', 'advanced'); 

-- Table: user_profiles (profile data)
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  name varchar(255) NOT NULL,
  weight DOUBLE PRECISION NOT NULL,
  height DOUBLE PRECISION NOT NULL,
  date_of_birth DATE NOT NULL,
  gender user_profile_gender NOT NULL,
  goal varchar(255) NOT NULL,
  level level_enum NOT NULL,
  training_location varchar(255),
  equipment varchar[],
  onboarding_complete BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index to search profile by user_id
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);

-- Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Access policies (users can only access their own data)
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);