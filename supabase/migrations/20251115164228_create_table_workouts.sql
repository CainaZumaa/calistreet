-- Table: workouts
CREATE TABLE IF NOT EXISTS workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name varchar(255) NOT NULL,
    description TEXT,
    level level_enum,
    created_by_id UUID NOT NULL DEFAULT auth.uid() REFERENCES users(id) ON DELETE CASCADE,
    is_template BOOLEAN NOT NULL DEFAULT false,
    schedule_days TEXT[]
);