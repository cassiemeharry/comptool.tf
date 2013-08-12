-- User tables
CREATE TABLE IF NOT EXISTS players (
	steam_id BIGINT PRIMARY KEY,
	name VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS users (
	steam_id BIGINT PRIMARY KEY REFERENCES players(steam_id),
	avatar_url VARCHAR(128),

	caster_access_requested BOOLEAN DEFAULT FALSE,
	caster_access BOOLEAN DEFAULT FALSE
);
