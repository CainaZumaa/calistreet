-- Table: exercises
CREATE TABLE IF NOT EXISTS exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name varchar(255) NOT NULL UNIQUE,
    description TEXT,
    muscle_group varchar(255) NOT NULL,
    subgroup varchar(255) NOT NULL,
    required_equipment varchar(255),
    video_url varchar(255),
    level level_enum NOT NULL
);

-- Table: workout_exercises (junction table between workouts and exercises)
CREATE TABLE IF NOT EXISTS workout_exercises (
    workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    sequence_order SMALLINT NOT NULL,
    sets SMALLINT NOT NULL,
    repetitions SMALLINT NOT NULL,
    PRIMARY KEY (workout_id, exercise_id)
);