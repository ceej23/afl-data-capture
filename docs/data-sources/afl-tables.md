# What’s on AFL Tables (and why it matters for schema)

* **Season pages** enumerate rounds with each game’s quarter-by-quarter scores, date/time (often with a secondary local time), venue and attendance, and a “Match stats” link per game. Good source for fixtures & Q1–Q4 splits. ([AFL Tables][1])
* **Match pages** include: team totals, **per-player match statistics** (KI, MK, HB, DI, GL, BH, HO, TK, RB, IF, CL, CG, FF, FA, CP, UP, CM, MI, 1%, BO, GA, %P, SU), **field umpires**, and a second panel with **“Player Details”** (age, career games/goals, club games/goals) plus a **timestamped scoring progression** (goal/behind/rushed, quarter time marks). This gives you event granularity if you want play-by-play. ([AFL Tables][2])
* **Player stats index / team lists** provide **season aggregates per player** with the same metric set and abbreviations legend; they also link to “Players Game by Game” and “Team Game by Game”. ([AFL Tables][3])
* **All-time player lists** expose **DOB, height, weight, debut/last game, career totals**—great for a Player dimension. ([AFL Tables][4])
* **Attendances** are summarized by season (and broken down elsewhere by team/venue/state). Keep this as a fact you can recompute or ingest. ([AFL Tables][5])
* **Brownlow** winner/votes information (with historical voting system notes) is available; per-game 3-2-1 can be modeled separately and linked to matches/players. ([AFL Tables][6])

# Canonical relational model (3 layers)

## 1) Dimensions

**Team**

* `team_id` (PK, surrogate)
* `aflt_team_code` (e.g., “RI”, “CW” when available), `name_official`, `name_common`
* Slowly changing **TeamNameHistory** (team\_id, name, start\_date, end\_date) for Footscray/Western Bulldogs etc.

**Player**

* `player_id` (PK) – deterministic hash of `{full_name|dob}` to avoid dupes
* `full_name`, `dob`, `height_cm`, `weight_kg`, `debut_date`, `last_game_date` (from all-time lists), optional birthplace/recruit info if you later expand
  — Source shape: see the Adelaide all-time list with DOB/HT/WT and debut/last. ([AFL Tables][4])

**Venue**

* `venue_id` (PK), `name`, `city`, `state`
* **VenueNameAlias** for Docklands/Etihad/Marvel naming changes.

**Season**

* `season_year` (PK), `competition` (VFL/AFL), `season_type` (home\_away, finals, pre-season)

**Umpire**

* `umpire_id` (PK), `full_name`
* Many-to-many to matches (role = field/boundary/goal; match pages show **field umpires** explicitly). ([AFL Tables][2])

**Coach** (optional if needed day-one)

* `coach_id`, `full_name`; **CoachTenure** (team\_id, coach\_id, start\_date, end\_date)

## 2) Match-level facts

**Round**

* `round_id` (PK), `season_year` (FK), `round_number` (int), `round_name` (e.g., “Qualifying Final”), `is_finals` (bool)

**Match**

* `match_id` (PK, deterministic): e.g., hash of afltables **match URL path** like `/afl/stats/games/2019/091420190920.html` to ensure stable joins
* `season_year` (FK), `round_id` (FK), `date_time_local`, `venue_id` (FK), `attendance`, `notes` (e.g., “After extra time”), `source_url`
* `home_team_id`, `away_team_id`
* Final scores: `home_goals`, `home_behinds`, `home_points`, same for away
  — All present on season and match pages. ([AFL Tables][1])

**MatchQuarterScore** (one row per team × quarter)

* `match_id`, `team_id`, `quarter` (1–4; allow 5+ for extra time), `goals`, `behinds`, `points`
  — Quarter splits exist on both season and match pages. ([AFL Tables][1])

**UmpireAssignment**

* `match_id`, `umpire_id`, `role` = 'field' | 'boundary' | 'goal' (start with 'field' per page data)
  — Field umpires displayed with game tallies. ([AFL Tables][2])

**TeamMatchTotals**

* `match_id`, `team_id` → totals for KI, MK, HB, DI, GL, BH, HO, TK, RB, IF, CL, CG, FF, FA, CP, UP, CM, MI, one\_percenters, BO, GA
  — Totals row appears at bottom of team tables on match pages. ([AFL Tables][2])

**PlayerMatchStat** (aka “appearance”)

* `match_id`, `team_id`, `player_id`, `jumper_no`
* Per-player metrics: KI, MK, HB, DI, GL, BH, HO, TK, RB, IF, CL, CG, FF, FA, **CP**, **UP**, **CM**, **MI**, `one_percenters`, **BO**, **GA**, **pct\_time\_played** (`%P`), **sub\_status** (`SU`, with ↑/↓ semantics)
  — Exact field list and abbreviations are standardized on AFL Tables. ([AFL Tables][2])

**PlayerMatchBioSnapshot** (optional, denormalized for analytics)

* `match_id`, `player_id`, `age_y`, `career_games`, `career_goals`, `club_games`, `club_goals`
  — These values are shown in **Player Details** on each match page and can be captured to freeze “as of match” context. ([AFL Tables][2])

**ScoringEvent** (play-by-play scoring progression)

* `event_id` (PK), `match_id`, `quarter`, `clock_q_mmss`, `team_id`, `player_id` (nullable for “Rushed behind”), `event_type` ('goal'|'behind'|'rushed'), `points`, `score_home_after`, `score_away_after`, optional `raw_text`
  — All present in the “Scoring progression” section with timestamps and running score. ([AFL Tables][2])

**BrownlowVote** (if you ingest per-game votes)

* `match_id`, `player_id`, `votes` in {3,2,1}, `notes`
  — The Brownlow hub covers winners and voting systems; per-match 3-2-1 can be stored here when sourced. ([AFL Tables][6])

**LadderStanding** (optional convenience snapshot)

* `season_year`, `round_number`, `team_id`, `played`, `points_for`, `points_against`, `percentage`, `wins`, `losses`, `draws`, `ladder_pos`
  — Round ladder blocks appear within season pages. ([AFL Tables][1])

## 3) Season aggregates

**PlayerSeasonStat**

* `season_year`, `team_id`, `player_id` + the full metric vector (KI…GA, %P, SU counts, BR if provided per season)
  — Exactly matches the “Player Stats” tables for a given year. ([AFL Tables][3])

**TeamSeasonSummary / AttendanceSeason** (optional)

* Store pre-computed season totals/averages or recompute from matches. Attendance season aggregates are provided (home-and-away vs finals vs overall). ([AFL Tables][5])

**JumperNumberHistory** (optional if you plan guernsey analytics)

* `player_id`, `team_id`, `number`, `first_season`, `last_season`
  — Align with the “Games and Goals by Number” listings. ([AFL Tables][7])

# Identifier & provenance strategy

* **Primary keys**: Use deterministic hashes of the **source URL path** for `match_id` and of `{name|dob}` for `player_id`. Persist the exact `source_url` on every fact for auditability and re-scrape/repair.
* **Time zones**: store `date_time_local`, `venue_tz`, and normalise to UTC for analytics; season pages sometimes show a secondary time in parentheses—capture and prefer the venue’s local time. ([AFL Tables][1])
* **Name drift**: create **alias tables** for teams and venues to handle historical renames.
* **Metrics vector**: keep a single, consistent metric set across `PlayerMatchStat`, `TeamMatchTotals`, and `PlayerSeasonStat` to match AFL Tables’ abbreviations; backfill missing fields as NULL for older eras.

# Edge cases & scraping notes

* **Finals round names** (Qualifying, Semi, Prelim, Grand Final) vs numeric rounds—model both `round_number` and `round_name`. ([AFL Tables][8])
* **Extra time** appears occasionally (e.g., 2017 semi noted on season page). Add `period > 4` in `MatchQuarterScore`. ([AFL Tables][8])
* **Byes**: season pages explicitly list byes; you can keep a `TeamRoundParticipation` table if needed for full fixture modelling. ([AFL Tables][1])
* **Rushed behinds** lack a scorer; set `player_id` NULL and `event_type='rushed'`. ([AFL Tables][2])
* **Brownlow system changes**: keep `BrownlowVote.voting_system_version` if you intend cross-era analytics (AFL Tables documents changes). ([AFL Tables][6])
* **Plain-text dump**: each season exposes a `*_stats.txt` for players; ideal for bulk ingest to seed `PlayerSeasonStat`. (See “2025 stats in plain text”.) ([AFL Tables][9])

# Minimal DDL sketch (Postgres-style)

```sql
-- Core
create table team (
  team_id bigserial primary key,
  aflt_team_code text null,
  name_official text not null,
  name_common text null
);

create table player (
  player_id text primary key,  -- hash(name|dob)
  full_name text not null,
  dob date null,
  height_cm int null,
  weight_kg int null,
  debut_date date null,
  last_game_date date null
);

create table venue (
  venue_id bigserial primary key,
  name text not null,
  city text null,
  state text null
);

create table season (
  season_year int primary key,
  competition text not null default 'AFL',
  season_type text not null default 'home_away'
);

create table round (
  round_id bigserial primary key,
  season_year int references season(season_year),
  round_number int null,
  round_name text null,
  is_finals boolean not null default false
);

create table match (
  match_id text primary key,   -- hash of afltables URL path
  season_year int references season(season_year),
  round_id bigint references round(round_id),
  date_time_local timestamptz,
  venue_id bigint references venue(venue_id),
  attendance int null,
  notes text null,
  source_url text not null,
  home_team_id bigint references team(team_id),
  away_team_id bigint references team(team_id),
  home_goals int, home_behinds int, home_points int,
  away_goals int, away_behinds int, away_points int
);

create table match_quarter_score (
  match_id text references match(match_id),
  team_id bigint references team(team_id),
  quarter int,
  goals int, behinds int, points int,
  primary key (match_id, team_id, quarter)
);

create table team_match_totals (
  match_id text references match(match_id),
  team_id bigint references team(team_id),
  ki int, mk int, hb int, di int, gl int, bh int, ho int, tk int, rb int, if50 int,
  cl int, cg int, ff int, fa int, cp int, up int, cm int, mi int, one_p int, bo int, ga int,
  primary key (match_id, team_id)
);

create table player_match_stat (
  match_id text references match(match_id),
  team_id bigint references team(team_id),
  player_id text references player(player_id),
  jumper_no int null,
  ki int, mk int, hb int, di int, gl int, bh int, ho int, tk int, rb int, if50 int,
  cl int, cg int, ff int, fa int, cp int, up int, cm int, mi int, one_p int, bo int, ga int,
  pct_time_played numeric(5,2) null, sub_status text null,  -- %P and SU
  primary key (match_id, player_id)
);

create table scoring_event (
  event_id bigserial primary key,
  match_id text references match(match_id),
  quarter int not null,
  clock_q_mmss text not null,
  team_id bigint references team(team_id),
  player_id text null references player(player_id),
  event_type text check (event_type in ('goal','behind','rushed')),
  points int not null,
  score_home_after int not null,
  score_away_after int not null,
  raw_text text null
);

create table brownlow_vote (
  match_id text references match(match_id),
  player_id text references player(player_id),
  votes int check (votes in (1,2,3)),
  voting_system_version text null,
  primary key (match_id, player_id)
);

create table player_season_stat (
  season_year int references season(season_year),
  team_id bigint references team(team_id),
  player_id text references player(player_id),
  gm int,
  ki int, mk int, hb int, di int, gl int, bh int, ho int, tk int, rb int, if50 int,
  cl int, cg int, ff int, fa int, br int, cp int, up int, cm int, mi int, one_p int, bo int, ga int,
  pct_time_played numeric(5,2) null, su_on int null, su_off int null,
  primary key (season_year, player_id, team_id)
);
```

# Practical scrape plan

1. **Seed dimensions**

* Parse **all-time player lists** per team for biographicals (DOB/HT/WT, debut/last) to build Players and a first Team roster. ([AFL Tables][4])
* Normalise **venues** and **team aliases** once; capture known renames.

2. **Ingest seasons**

* From each **season page**, create Rounds and Matches (date/time, venue, attendance, teams, Q1–Q4 splits). ([AFL Tables][1])

3. **Per match deep-dive**

* From the **match page**, ingest Team totals, **PlayerMatchStat**, **UmpireAssignment**, **ScoringEvent**. ([AFL Tables][2])

4. **Aggregates**

* Populate **PlayerSeasonStat** from the season’s player list (or cross-check your own aggregates vs the season “Player Stats” pages / plain-text dump). ([AFL Tables][3])

5. **Brownlow**

* Add **BrownlowVote** where per-match votes are available; otherwise start with season winners and extend. ([AFL Tables][6])

# Notes to future-proof analytics

* Treat the **metric vector** as first-class. AFL Tables is consistent about abbreviations; prefer wide tables for speed, backed by views for tall/unpivoted analytics. ([AFL Tables][3])
* Keep **provenance** (exact `source_url` and scrape timestamp) on every row.
* Expect **era variance** (missing metrics in early decades; different match administration like umpire count; finals naming). Use NULLs and a small dictionary table for finals round names. ([AFL Tables][8])
* For event data, **rushed behind** lines omit a scorer—allow `player_id` NULL and rely on `raw_text` to reconcile edge cases. ([AFL Tables][2])

> **Good starting anchors & references**
> – [AFL Tables index](https://www.google.com/search?q=AFL%20Tables%20site%3Aafltables.com)
> – [2025 season scores (rounds, venues, attendance, Q1–Q4)](https://www.google.com/search?q=2025%20Season%20Scores%20site%3Aafltables.com) ([AFL Tables][1])
> – **Match page** with per-player stats, umpires, and scoring progression: [example](https://www.google.com/search?q=Richmond%20v%20Collingwood%202017%20site%3Aafltables.com) ([AFL Tables][2])
> – **Player stats index** (definitions & season aggregates): [example 2025](https://www.google.com/search?q=2025%20Player%20Stats%20site%3Aafltables.com) ([AFL Tables][3])
> – **All-time player list** (DOB/HT/WT, debut/last): [Adelaide example](https://www.google.com/search?q=All%20Time%20Player%20List%20Adelaide%20site%3Aafltables.com) ([AFL Tables][4])
> – **Attendances summary** (season totals): [overview](https://www.google.com/search?q=Attendances%20summary%20site%3Aafltables.com) ([AFL Tables][5])
> – **Brownlow** winners & voting notes: [hub](https://www.google.com/search?q=Brownlow%20Medal%20Winners%20site%3Aafltables.com) ([AFL Tables][6])

[1]: https://afltables.com/afl/seas/2025.html "AFL Tables -  2025 Season Scores"
[2]: https://afltables.com/afl/stats/games/2017/041420170330.html "AFL Tables - Richmond v Collingwood - Thu, 30-Mar-2017 7:20 PM (6:20 PM) - Match Stats"
[3]: https://afltables.com/afl/stats/2025.html "AFL Tables - 2025 Stats - Player Lists"
[4]: https://afltables.com/afl/stats/alltime/adelaide.html "AFL Tables - All Time Player List - Adelaide"
[5]: https://afltables.com/afl/crowds/summary.html "AFL Tables - Crowds 1921-2025"
[6]: https://afltables.com/afl/brownlow/brownlow_idx.html "AFL Tables - Brownlow Medal Winners"
[7]: https://afltables.com/afl/stats/numbers.html "AFL Tables - Jumper Numbers"
[8]: https://afltables.com/afl/seas/2017.html?utm_source=chatgpt.com "AFL Tables - 2017 Season Scores"
[9]: https://afltables.com/afl/stats/stats_idx.html "AFL Tables - Player, Coach and Umpire Stats"
