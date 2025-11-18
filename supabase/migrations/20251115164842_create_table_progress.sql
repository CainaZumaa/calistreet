CREATE TYPE progress_status AS ENUM ('IN_PROGRESS', 'COMPLETED', 'SKIPPED');

-- Table: progress
CREATE TABLE IF NOT EXISTS progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    workout_id UUID REFERENCES workouts(id) ON DELETE CASCADE,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    status progress_status DEFAULT 'IN_PROGRESS',
    notes TEXT,
    share_url TEXT
);