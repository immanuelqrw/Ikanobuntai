USE "Ikanobuntai";


CREATE TABLE "TableBase" (
  "createdOn" TIMESTAMP NOT NULL,
  "modifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
);

-- TRAINER tables

CREATE TABLE "Elo" (
  "id" BIGSERIAL PRIMARY KEY,
  "divider" SMALLINT NOT NULL,
  "k" SMALLINT NOT NULL,
) INHERITS ("TableBase");

CREATE TABLE "Rank" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" VARCHAR(64) NOT NULL UNIQUE,
) INHERITS ("TableBase");

CREATE TABLE "Tier" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" VARCHAR(64) NOT NULL UNIQUE,
) INHERITS ("TableBase");

CREATE TABLE "Stage" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" VARCHAR(64) NOT NULL UNIQUE,
) INHERITS ("TableBase");

CREATE TABLE "Title" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" VARCHAR(64) NOT NULL UNIQUE,
  "tierId" BIGINT NOT NULL REFERENCES "Tier" ("id"),
) INHERITS ("TableBase");

CREATE TABLE "Configuration" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" VARCHAR(64) NOT NULL,
  "value" VARCHAR(64) NOT NULL,
  "type" VARCHAR(32) NOT NULL,
  "tierId" BIGINT NOT NULL REFERENCES "Tier" ("id"),
  UNIQUE KEY "uq_name_tier" ("name", "tierId"),
) INHERITS ("TableBase");

CREATE TABLE "League" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" VARCHAR(64) NOT NULL UNIQUE,
  "stageId" BIGINT NOT NULL REFERENCES "Stage" ("id"),
  "tierId" BIGINT NOT NULL REFERENCES "Tier" ("id"),
  "eloId" BIGINT NOT NULL REFERENCES "Elo" ("id"),
) INHERITS ("TableBase");

CREATE TABLE "TrainerUser" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" VARCHAR(64) NOT NULL UNIQUE,
  "email" VARCHAR(300) NOT NULL UNIQUE,
  "passwordHash" CHAR(64) NOT NULL,
  "passwordSalt" CHAR(64) NOT NULL,
  "oAuthId" CHAR(64) NOT NULL,
) INHERITS ("TableBase");

CREATE TABLE "Trainer" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" VARCHAR(64) NOT NULL UNIQUE,
  "trainerUserId" BIGINT NOT NULL REFERENCES "TrainerUser" ("id"),
  "tierId" BIGINT NOT NULL REFERENCES "Tier" ("id"),
  "rankId" BIGINT NOT NULL REFERENCES "Rank" ("id"),
  "rating" SMALLINT NOT NULL DEFAULT 1000 CHECK ("rating" >= 1000),
) INHERITS ("TableBase");

CREATE TABLE "TrainerTitle" (
  "id" BIGSERIAL PRIMARY KEY,
  "trainerId" BIGINT NOT NULL REFERENCES "Trainer" ("id"),
  "titleId" BIGINT NOT NULL REFERENCES "Title" ("id"),
  "wonOn" TIMESTAMP NOT NULL,
  "lostOn" TIMESTAMP,
) INHERITS ("TableBase");

CREATE TABLE "BattleRating" (
  "id" BIGSERIAL PRIMARY KEY,
  "defenderTitleId" BIGINT NOT NULL REFERENCES "Title" ("id"),
  "challengerTitleId" BIGINT NOT NULL REFERENCES "Title" ("id"),
  "leagueId" BIGINT NOT NULL REFERENCES "League" ("id"),
  "value" SMALLINT NOT NULL,
  CHECK ("DefenderTitleId" <> "ChallengerTitleId"),
) INHERITS ("TableBase");

CREATE TABLE "Battle" (
  "id" BIGSERIAL PRIMARY KEY,
  "defenderId" BIGINT NOT NULL REFERENCES "Trainer" ("id"),
  "challengerId" BIGINT NOT NULL REFERENCES "Trainer" ("id"),
  "winnerId" BIGINT NOT NULL REFERENCES "Trainer" ("id"),
  "rankId" BIGINT NOT NULL REFERENCES "Rank" ("id"),
  "value" SMALLINT NOT NULL,
  "foughtOn" TIMESTAMP NOT NULL,
  CHECK ("DefenderId" <> "ChallengerId"),
) INHERITS ("TableBase");

-- POKEMON tables

CREATE TABLE "Ability" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" VARCHAR(32) NOT NULL UNIQUE,
  "description" VARCHAR(256) NOT NULL,
) INHERITS ("TableBase");

CREATE TYPE "STAT" AS ENUM (
  'HP',
  'Attack',
  'Defense',
  'SpecialAttack',
  'SpecialDefense',
  'Speed',
);

CREATE TABLE "Nature" (
  "id" BIGSERIAL PRIMARY KEY,
  "name" VARCHAR(20) NOT NULL UNIQUE,
  "riseStat" STAT,
  "dropStat" STAT,
) INHERITS ("TableBase");

CREATE TABLE "IndividualValue" (
  "id" BIGSERIAL PRIMARY KEY
  "hp" SMALLINT NOT NULL CHECK ("hp" BETWEEN 0 AND 31)
  "attack" SMALLINT NOT NULL CHECK ("attack" BETWEEN 0 AND 31)
  "defense" SMALLINT NOT NULL CHECK ("defense" BETWEEN 0 AND 31)
  "specialAttack" SMALLINT NOT NULL CHECK ("specialAttack" BETWEEN 0 AND 31)
  "specialDefense" SMALLINT NOT NULL CHECK ("specialDefense" BETWEEN 0 AND 31)
  "speed" SMALLINT NOT NULL CHECK ("speed" BETWEEN 0 AND 31),
) INHERITS ("TableBase");

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

CREATE TABLE "Generation" (
  "id" BIGSERIAL PRIMARY KEY,
  "number" SMALLINT NOT NULL,
  "region" VARCHAR(8) NOT NULL,
) INHERITS ("TableBase");

-- TODO Add smogon tier generation connection -- separate join table with generation
-- TODO add unique indexes
CREATE TABLE "Pokemon" (
  "id" BIGSERIAL PRIMARY KEY,
  "number" VARCHAR(4) NOT NULL, -- maybe change to int
  "name" VARCHAR(32) NOT NULL,
  "form" VARCHAR(32),
  "isLegendary" BOOLEAN NOT NULL DEFAULT FALSE,
  "isMythical" BOOLEAN NOT NULL DEFAULT FALSE,
  "isMega" BOOLEAN NOT NULL DEFAULT FALSE,
  "prevolvedPokemonId" BIGINT REFERENCES "Pokemon" ("id"),
) INHERITS ("TableBase");

CREATE TABLE "PokemonGeneration" (
  "id" BIGSERIAL PRIMARY KEY,
  "pokemonId" BIGINT NOT NULL REFERENCES "Pokemon" ("id"),
  "generationId" BIGINT NOT NULL REFERENCES "Generation" ("id"),
  "mainType" POKETYPE NOT NULL,
  "subType" POKETYPE,
  "stage" SMALLINT NOT NULL DEFAULT 1,
  "baseStatTotal" SMALLINT NOT NULL CHECK("baseStatTotal" BETWEEN 0 AND 1530),
  "hpBaseStat" SMALLINT NOT NULL CHECK ("hpBaseStat" BETWEEN 0 AND 255),
  "attackBaseStat" SMALLINT NOT NULL CHECK ("attackBaseStat" BETWEEN 0 AND 255),
  "defenseBaseStat" SMALLINT NOT NULL CHECK ("defenseBaseStat" BETWEEN 0 AND 255),
  "specialAttackBaseStat" SMALLINT NOT NULL CHECK ("specialAttackBaseStat" BETWEEN 0 AND 255),
  "specialDefenseBaseStat" SMALLINT NOT NULL CHECK ("specialDefenseBaseStat" BETWEEN 0 AND 255),
  "speedBaseStat" SMALLINT NOT NULL CHECK ("speedBaseStat" BETWEEN 0 AND 255),
  "abilityId" BIGINT REFERENCES "Ability" ("id"),
  "secondAbilityId" BIGINT REFERENCES "Ability" ("id"),
  "hiddenAbilityId" BIGINT REFERENCES "Ability" ("id"),
) INHERITS ("TableBase");

CREATE TABLE "PokemonTier" (
  "id" BIGSERIAL PRIMARY KEY,
  "pokemonId" BIGINT NOT NULL REFERENCES "Pokemon" ("id"),
  "generationId" BIGINT NOT NULL REFERENCES "Generation" ("id"),
  "tierId" BIGINT NOT NULL REFERENCES "Tier" ("id"),
) INHERITS ("TableBase");

CREATE TABLE "PokemonTrainer" (
  "id" BIGSERIAL PRIMARY KEY,
  "pokemonId" BIGINT NOT NULL REFERENCES "Pokemon" ("id"),
  "trainerId" BIGINT NOT NULL REFERENCES "Trainer" ("id"),
  "natureId" BIGINT NOT NULL REFERENCES "Nature" ("id"),
  "abilityId" BIGINT NOT NULL REFERENCES "Ability" ("id"),
  "individualValueId" BIGINT NOT NULL REFERENCES "IndividualValue" ("id"),
) INHERITS ("TableBase");

-- Team