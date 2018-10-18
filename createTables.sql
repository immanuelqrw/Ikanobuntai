USE "Ikanobuntai";

-- TRAINER tables

CREATE TABLE "Elo" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "divider" SMALLINT NOT NULL,
  "k" SMALLINT NOT NULL,
) INHERITS ("Base");

CREATE TABLE "Rank" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "name" VARCHAR(64) NOT NULL UNIQUE,
);

CREATE TABLE "Tier" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "name" VARCHAR(64) NOT NULL UNIQUE,
);

CREATE TABLE "Stage" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "name" VARCHAR(64) NOT NULL UNIQUE,
);

CREATE TABLE "Title" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "name" VARCHAR(64) NOT NULL UNIQUE,
  "tierId" BIGINT NOT NULL REFERENCES "Tier" ("id"),
);

CREATE TABLE "Configuration" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "name" VARCHAR(64) NOT NULL,
  "value" VARCHAR(64) NOT NULL,
  "type" VARCHAR(32) NOT NULL,
  "tierId" BIGINT NOT NULL REFERENCES "Tier" ("id"),
  UNIQUE KEY "uq_name_tier" ("name", "tierId"),
);

CREATE TABLE "League" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "name" VARCHAR(64) NOT NULL UNIQUE,
  "stageId" BIGINT NOT NULL REFERENCES "Stage" ("id"),
  "tierId" BIGINT NOT NULL REFERENCES "Tier" ("id"),
  "eloId" BIGINT NOT NULL REFERENCES "Elo" ("id"),
);

CREATE TABLE "TrainerUser" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "name" VARCHAR(64) NOT NULL UNIQUE,
  "email" VARCHAR(300) NOT NULL UNIQUE,
  "passwordHash" CHAR(64) NOT NULL,
  "passwordSalt" CHAR(64) NOT NULL,
  "oAuthId" CHAR(64) NOT NULL,
);

CREATE TABLE "Trainer" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "name" VARCHAR(64) NOT NULL UNIQUE,
  "trainerUserId" BIGINT NOT NULL REFERENCES "TrainerUser" ("id"),
  "tierId" BIGINT NOT NULL REFERENCES "Tier" ("id"),
  "rankId" BIGINT NOT NULL REFERENCES "Rank" ("id"),
  "rating" SMALLINT NOT NULL DEFAULT 1000 CHECK ("rating" >= 1000),
);

CREATE TABLE "TrainerTitle" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "trainerId" BIGINT NOT NULL REFERENCES "Trainer" ("id"),
  "titleId" BIGINT NOT NULL REFERENCES "Title" ("id"),
  "wonOn" TIMESTAMP NOT NULL,
  "lostOn" TIMESTAMP,
);

CREATE TRIGGER "TRG_WON_TITLE"
  BEFORE INSERT ON "TrainerTitle"
  BEGIN
    IF NEW."lostOn" IS NOT NULL
      THEN SIGNAL 'Titles cannot be lost when won!'
    END IF;
  END;

CREATE TABLE "BattleRating" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "defenderTitleId" BIGINT NOT NULL REFERENCES "Title" ("id"),
  "challengerTitleId" BIGINT NOT NULL REFERENCES "Title" ("id"),
  "leagueId" BIGINT NOT NULL REFERENCES "League" ("id"),
  "value" SMALLINT NOT NULL,
  CHECK ("DefenderTitleId" <> "ChallengerTitleId"),
)

CREATE TABLE "Battle" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "defenderId" BIGINT NOT NULL REFERENCES "Trainer" ("id"),
  "challengerId" BIGINT NOT NULL REFERENCES "Trainer" ("id"),
  "winnerId" BIGINT NOT NULL REFERENCES "Trainer" ("id"),
  "rankId" BIGINT NOT NULL REFERENCES "Rank" ("id"),
  "value" SMALLINT NOT NULL,
  "foughtOn" TIMESTAMP NOT NULL,
  CHECK ("DefenderId" <> "ChallengerId"),
)

-- POKEMON tables

CREATE TABLE "Ability" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "name" VARCHAR(32) NOT NULL UNIQUE,
  "description" VARCHAR(256) NOT NULL,
);

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
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "name" VARCHAR(20) NOT NULL UNIQUE,
  "riseStat" STAT NOT NULL,
  "dropStat" STAT NOT NULL,
);

CREATE TABLE "IndividualValue" (
  "id" BIGSERIAL PRIMARY KEY
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "hp" SMALLINT NOT NULL CHECK ("hp" BETWEEN 0 AND 31)
  "attack" SMALLINT NOT NULL CHECK ("attack" BETWEEN 0 AND 31)
  "defense" SMALLINT NOT NULL CHECK ("defense" BETWEEN 0 AND 31)
  "specialAttack" SMALLINT NOT NULL CHECK ("specialAttack" BETWEEN 0 AND 31)
  "specialDefense" SMALLINT NOT NULL CHECK ("specialDefense" BETWEEN 0 AND 31)
  "speed" SMALLINT NOT NULL CHECK ("speed" BETWEEN 0 AND 31),
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
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "name" VARCHAR(32) NOT NULL,
  "mainType" POKETYPE NOT NULL,
  "subType" POKETYPE,
  "abilityId" BIGINT NOT NULL REFERENCES "Ability" ("id"),
  "hiddenAbilityId" BIGINT REFERENCES "Ability" ("id"),
  "hpBaseStat" SMALLINT NOT NULL CHECK ("hpBaseStat" BETWEEN 0 AND 255),
  "attackBaseStat" SMALLINT NOT NULL CHECK ("attackBaseStat" BETWEEN 0 AND 255),
  "defenseBaseStat" SMALLINT NOT NULL CHECK ("defenseBaseStat" BETWEEN 0 AND 255),
  "specialAttackBaseStat" SMALLINT NOT NULL CHECK ("specialAttackBaseStat" BETWEEN 0 AND 255),
  "specialDefenseBaseStat" SMALLINT NOT NULL CHECK ("specialDefenseBaseStat" BETWEEN 0 AND 255),
  "speedBaseStat" SMALLINT NOT NULL CHECK ("speedBaseStat" BETWEEN 0 AND 255),
  "prevolvedPokemonId" BIGINT REFERENCES "Pokemon" ("id"),
);

CREATE TABLE "PokemonTier" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "pokemonId" BIGINT NOT NULL REFERENCES "Pokemon" ("id"),
  "tierId" BIGINT NOT NULL REFERENCES "Tier" ("id"),
);

CREATE TABLE "PokemonTrainer" (
  "id" BIGSERIAL PRIMARY KEY,
  "createdOn" TIMESTAMP NOT NULL,
  "lastModifiedOn" TIMESTAMP NOT NULL,
  "removedOn" TIMESTAMP,
  "pokemonId" BIGINT NOT NULL REFERENCES "Pokemon" ("id"),
  "trainerId" BIGINT NOT NULL REFERENCES "Trainer" ("id"),
  "natureId" BIGINT NOT NULL REFERENCES "Nature" ("id"),
  "individualValueId" BIGINT NOT NULL REFERENCES "IndividualValue" ("id"),
);