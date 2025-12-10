-- Table: achievements
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name varchar(255) NOT NULL,
    description TEXT,
    icon_name varchar(255),
    target_exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    threshold_count INTEGER NOT NULL,
    is_time_based BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_achievements_target_exercise_id ON achievements(target_exercise_id);

-- Table: user_achievements
CREATE TABLE IF NOT EXISTS user_achievements (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, achievement_id)
);

-- Table: progress_exercises
CREATE TABLE IF NOT EXISTS progress_exercises (
    progress_id UUID NOT NULL REFERENCES progress(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
    sets_completed INTEGER NOT NULL DEFAULT 0,
    repetitions_completed INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (progress_id, exercise_id)
);

CREATE INDEX IF NOT EXISTS idx_progress_exercises_progress_id ON progress_exercises(progress_id);
CREATE INDEX IF NOT EXISTS idx_progress_exercises_exercise_id ON progress_exercises(exercise_id);

-- ======================================================
-- Row Level Security (RLS) e policies
-- ======================================================

-- Ativa RLS
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_exercises ENABLE ROW LEVEL SECURITY;

-- Usuários só podem acessar suas próprias conquistas
CREATE POLICY "Users can view own achievements" ON user_achievements
    FOR SELECT USING (auth.uid() = user_id);

-- Usuários só podem inserir suas próprias conquistas
CREATE POLICY "Users can insert own achievements" ON user_achievements
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Usuários só podem acessar seus próprios progress_exercises através do progress_id
CREATE POLICY "Users can view own progress_exercises" ON progress_exercises
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM progress p
            WHERE p.id = progress_id AND p.user_id = auth.uid()
        )
    );

-- Usuários só podem inserir/update seus próprios progress_exercises
CREATE POLICY "Users can insert/update own progress_exercises" ON progress_exercises
    FOR INSERT, UPDATE WITH CHECK (
        EXISTS (
            SELECT 1 FROM progress p
            WHERE p.id = progress_id AND p.user_id = auth.uid()
        )
    );

-- ======================================================
-- Função: sum_user_reps
-- ======================================================
CREATE OR REPLACE FUNCTION sum_user_reps(
    user_id_param UUID,
    exercise_id_param UUID
) RETURNS INTEGER
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT COALESCE(SUM(pe.repetitions_completed), 0)
        FROM progress_exercises pe
        JOIN progress p ON pe.progress_id = p.id
        WHERE p.user_id = user_id_param
          AND pe.exercise_id = exercise_id_param
          AND p.status = 'COMPLETED'
    );
END;
$$;
