/* --
Create tables script [Using PostgreSQL syntax]
Order matters due to foreign keys

Order
-----

-- */

USE "ikanobuntai";

-- TRAINER tables

CREATE TABLE "Elo" (
  "EloID" SERIAL PRIMARY KEY,
  "Divider" SMALLINT NOT NULL,
  "K" SMALLINT NOT NULL
)

CREATE TABLE "Rank" (
  "RankID" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE "Tier" (
  "TierID" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE "Stage" (
  "StageID" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE "Title" (
  "TitleID" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50) NOT NULL UNIQUE,
  "TierID" BIGINT NOT NULL REFERENCES "Tier" ("TierID"),
  "DateTitleLastChanged" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC')
);

CREATE TABLE "Configuration" (
  "ConfigurationID" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50) NOT NULL,
  "Value" VARCHAR(50) NOT NULL,
  "Type" VARCHAR(50) NOT NULL,
  "TierID" BIGINT NOT NULL REFERENCES "Tier" ("TierID"),
  UNIQUE ("Name", "TierID")
);

CREATE TABLE "League" (
  "LeagueID" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50) NOT NULL UNIQUE,
  "StageID" BIGINT NOT NULL REFERENCES "Stage" ("StageID"),
  "TierID" BIGINT NOT NULL REFERENCES "Tier" ("TierID"),
  "EloID" BIGINT NOT NULL REFERENCES "Elo" ("EloID")
);

CREATE TABLE "TrainerUser" (
  "TrainerUserID" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50) NOT NULL UNIQUE,
  "Email" VARCHAR(300) NOT NULL UNIQUE,
  "PasswordHash" CHAR(64) NOT NULL,
  "PasswordSalt" CHAR(64) NOT NULL,
  "OAuthID" CHAR(64) NOT NULL
);

CREATE TABLE "Trainer" (
  "TrainerID" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50) NOT NULL UNIQUE,
  "TrainerUserID" BIGINT NOT NULL REFERENCES "TrainerUser" ("TrainerUserID"),
  "TierID" BIGINT NOT NULL REFERENCES "Tier" ("TierID"),
  "RankID" BIGINT NOT NULL REFERENCES "Rank" ("RankID"),
  "Rating" SMALLINT NOT NULL DEFAULT 1000 CHECK ("Rating" >= 1000)
);

CREATE TABLE "TrainerTitle" (
  "TrainerTitleID" SERIAL PRIMARY KEY,
  "TrainerID" BIGINT NOT NULL REFERENCES "Trainer" ("TrainerID"),
  "TitleID" BIGINT NOT NULL REFERENCES "Title" ("TitleID"),
  "DateTitleWon" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
  "DateTitleLost" TIMESTAMP WITHOUT TIME ZONE
);

CREATE TRIGGER "TRG_WON_TITLE"
  BEFORE INSERT ON "TrainerTitle"
  BEGIN
    IF NEW."DateTitleLost" IS NOT NULL
      THEN SIGNAL 'Titles cannot be lost when won!'
    END IF;
  END;

CREATE TABLE "BattleRating" (
  "BattleRatingID" SERIAL PRIMARY KEY,
  "DefenderTitleID" BIGINT NOT NULL REFERENCES "Title" ("TitleID"),
  "ChallengerTitleID" BIGINT NOT NULL REFERENCES "Title" ("TitleID"),
  "LeagueID" BIGINT NOT NULL REFERENCES "League" ("LeagueID"),
  "Value" SMALLINT NOT NULL,
  CHECK ("DefenderTitleID" <> "ChallengerTitleID")
)

CREATE TABLE "Battle" (
  "BattleID" SERIAL PRIMARY KEY,
  "DefenderID" BIGINT NOT NULL REFERENCES "Trainer" ("TrainerID"),
  "ChallengerID" BIGINT NOT NULL REFERENCES "Trainer" ("TrainerID"),
  "WinnerID" BIGINT NOT NULL REFERENCES "Trainer" ("TrainerID"),
  "RankID" BIGINT NOT NULL REFERENCES "Rank" ("RankID"),
  "Value" SMALLINT NOT NULL,
  "DateFought" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
  CHECK ("DefenderID" <> "ChallengerID")
)

-- POKEMON tables

CREATE TABLE "Ability" (
  "AbilityID" SERIAL PRIMARY KEY,
  "Name" VARCHAR(20) NOT NULL UNIQUE,
  "Description" VARCHAR(200) NOT NULL
);

CREATE TYPE "STAT" AS ENUM (
  'HP',
  'Attack',
  'Defense',
  'SpecialAttack',
  'SpecialDefense',
  'Speed'
);

CREATE TABLE "Nature" (
  "NatureID" SERIAL PRIMARY KEY,
  "Name" VARCHAR(20) NOT NULL UNIQUE,
  "RiseStat" STAT NOT NULL,
  "DropStat" STAT NOT NULL
);

CREATE TABLE "IndividualValue" (
  "IndividualValueID" SERIAL PRIMARY KEY,
  "HP" SMALLINT NOT NULL CHECK ("HP" BETWEEN 0 AND 31)
  "Attack" SMALLINT NOT NULL CHECK ("Attack" BETWEEN 0 AND 31)
  "Defense" SMALLINT NOT NULL CHECK ("Defense" BETWEEN 0 AND 31)
  "SpecialAttack" SMALLINT NOT NULL CHECK ("SpecialAttack" BETWEEN 0 AND 31)
  "SpecialDefense" SMALLINT NOT NULL CHECK ("SpecialDefense" BETWEEN 0 AND 31)
  "Speed" SMALLINT NOT NULL CHECK ("Speed" BETWEEN 0 AND 31)
);

CREATE TYPE "POKETYPE" AS ENUM (
  'GRASS',
  'FIRE',
  'WATER',
  'ELECTRIC',
  'NORMAL',
  'GROUND',
  'ROCK',
  'FIGHTING',
  'FLYING',
  'ICE',
  'POISON',
  'BUG',
  'PSYCHIC',
  'GHOST',
  'DRAGON',
  'DARK',
  'STEEL',
  'FAIRY'
);

CREATE TABLE "Pokemon" (
  "PokemonID" SERIAL PRIMARY KEY,
  "Name" VARCHAR(50) NOT NULL,
  "MainType" POKETYPE NOT NULL,
  "SubType" POKETYPE,
  "AbilityID" BIGINT NOT NULL REFERENCES "Ability" ("AbilityID"),
  "HiddenAbilityID" BIGINT REFERENCES "Ability" ("AbilityID"),
  "HPBaseStat" SMALLINT NOT NULL CHECK ("HPBaseStat" BETWEEN 0 AND 255),
  "AttackBaseStat" SMALLINT NOT NULL CHECK ("AttackBaseStat" BETWEEN 0 AND 255),
  "DefenseBaseStat" SMALLINT NOT NULL CHECK ("DefenseBaseStat" BETWEEN 0 AND 255),
  "SpecialAttackBaseStat" SMALLINT NOT NULL CHECK ("SpecialAttackBaseStat" BETWEEN 0 AND 255),
  "SpecialDefenseBaseStat" SMALLINT NOT NULL CHECK ("SpecialDefenseBaseStat" BETWEEN 0 AND 255),
  "SpeedBaseStat" SMALLINT NOT NULL CHECK ("SpeedBaseStat" BETWEEN 0 AND 255),
  "PrevolvedPokemonID" BIGINT REFERENCES "Pokemon" ("PokemonID")
);

CREATE TABLE "PokemonTier" (
  "PokemonID" BIGINT NOT NULL REFERENCES "Pokemon" ("PokemonID"),
  "TierID" BIGINT NOT NULL REFERENCES "Tier" ("TierID")
);

CREATE TABLE "PokemonTrainer" (
  "PokemonID" BIGINT NOT NULL REFERENCES "Pokemon" ("PokemonID"),
  "TrainerID" BIGINT NOT NULL REFERENCES "Trainer" ("TrainerID"),
  "NatureID" BIGINT NOT NULL REFERENCES "Nature" ("NatureID"),
  "IndividualValueID" BIGINT NOT NULL REFERENCES "IndividualValue" ("IndividualValueID")
);
