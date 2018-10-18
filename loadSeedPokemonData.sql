USE "Ikanobuntai";

-- ABILITY
INSERT INTO
  "Ability" ("name", "description")
VALUES
  ();

-- NATURE
INSERT INTO
  "Nature" ("name", "riseStat", "dropStat")
VALUES
  ('Hardy',   NULL,             NULL),
  ('Lonely',  'Attack',         'Defense'),
  ('Brave',   'Attack',         'Speed'),
  ('Adamant', 'Attack',         'SpecialAttack'),
  ('Naughty', 'Attack',         'SpecialDefense'),

  ('Bold',    'Defense',        'Attack'),
  ('Docile',  NULL,             NULL),
  ('Relaxed', 'Defense',        'Speed'),
  ('Impish',  'Defense',        'SpecialAttack'),
  ('Lax',     'Defense',        'SpecialDefense'),

  ('Timid',   'Speed',          'Attack'),
  ('Hasty',   'Speed',          'Defense'),
  ('Serious', NULL,             NULL),
  ('Jolly',   'Speed',          'SpecialAttack'),
  ('Naive',   'Speed',          'SpecialDefense'),

  ('Modest',  'SpecialAttack',  'Attack'),
  ('Mild',    'SpecialAttack',  'Defense'),
  ('Quiet',   'SpecialAttack',  'Speed'),
  ('Bashful', NULL,             NULL),
  ('Rash',    'SpecialAttack',  'SpecialDefense'),

  ('Calm',    'SpecialDefense', 'Attack'),
  ('Gentle',  'SpecialDefense', 'Defense'),
  ('Sassy',   'SpecialDefense', 'Speed'),
  ('Careful', 'SpecialDefense', 'SpecialAttack'),
  ('Quirky',  NULL,             NULL);