# Squiggle AFL API — Markdown Reference (v1.11.0)

* **Base URL:** `https://api.squiggle.com.au/` ([Squiggle API][1])
* **Version:** v1.11.0 (released Apr 2024; see *Changelog*). ([Squiggle API][1])
* **Auth:** None (public). **Identify your client** with a meaningful `User-Agent` or you may be blocked. ([Squiggle API][1])
* **Formats:** JSON (default), XML, CSV via `format=`. Example: `?q=teams;format=csv`. ([Squiggle API][1])
* **General form:** `GET /?q=<queryType>[;param=value[;param=value...]]`

  * Exclude values by prefixing with `!`. Example: `?q=games;year=2020;round=!1` (everything except R1). ([Squiggle API][1])
  * Omit optional filters at your own risk; defaults may change. Prefer explicit parameters. ([Squiggle API][1])

---

## Query Types (Standard / REST)

### 1) `q=teams` — Teams metadata

Returns current/historical team info.

**Parameters**

* `team` — Team ID (filter).
* `year` — A season (enables historically correct names/logos). ([Squiggle API][1])

**Fields (JSON)**

* `id` (int) — Team ID.
* `name` (str) — Team name.
* `abbrev` (str) — e.g., `ADE`.
* `logo` (str) — Relative path to team logo (historical if `year` given).
* `debut` (int), `retirement` (int) — First/last year (9999 = still active). ([Squiggle API][2])

**Examples**

```bash
curl "https://api.squiggle.com.au/?q=teams"
curl "https://api.squiggle.com.au/?q=teams;year=2000"
curl "https://api.squiggle.com.au/?q=teams;format=csv"
```

([Squiggle API][2])

---

### 2) `q=games` — Fixtures & results

Returns games for a year/round/team, including live/in-progress.

**Parameters**

* `year` — Season year (supports special `2020-original` for pre-pandemic fixture). ([Squiggle API][1])
* `round` — Round number/name (e.g., `1`).
* `game` — Game ID.
* `team` — Team ID (either side).
* `complete` — Percent complete (e.g., `100` for finished; `!100` for not finished). ([Squiggle API][1])
* `live` — In-progress filter. ([Squiggle API][1])

**Fields (typical)**

* Teams: `hteam`, `ateam` (names); `hteamid`, `ateamid` (IDs).
* Scoring: `hscore`, `ascore`, `hgoals`, `hbehinds`, `agoals`, `abehinds`.
* State: `complete` (0–100), `winner`/`winnerteamid`, `is_final`, `is_grand_final`.
* Timing: `date` (UTC ISO), `localtime` (venue local), `tz` (offset), `unixtime`, `timestr` (human string), `updated`.
* Context: `year`, `round`, `roundname`, `venue`. ([Squiggle API][3])

**Finals flags**

* `is_final`: 0 = not a final; 2 = Elim; 3 = Qual; 4 = Semi; 5 = Prelim; 6 = GF.
* `is_grand_final`: 0/1. ([Squiggle API][1])

**Examples**

```bash
# All 2018 completed games
curl "https://api.squiggle.com.au/?q=games;year=2018;complete=100"

# Non-complete (future or in-progress)
curl "https://api.squiggle.com.au/?q=games;complete=!100"

# 2020 original fixture
curl "https://api.squiggle.com.au/?q=games;year=2020-original"
```

([Squiggle API][4])

---

### 3) `q=sources` — Models providing tips/power/ladder

**Fields**

* `id` (int), `name` (str), `url` (str), `icon` (str). ([Squiggle API][5])

**Examples**

```bash
curl "https://api.squiggle.com.au/?q=sources"
curl "https://api.squiggle.com.au/?q=sources;source=!8"  # all except id=8
```

([Squiggle API][5])

---

### 4) `q=tips` — Model predictions per game

**Parameters**

* `year`, `round`, `game`, `team`, `source`, `complete` (as per *games*). ([Squiggle API][1])

**Fields (common)**

* Identity: `gameid`, `year`, `round`, `source`, `sourceid`.
* Teams: `hteam`, `ateam`, `hteamid`, `ateamid`, `team`/`tip` (string of predicted winner), `tipteamid`.
* Prediction metrics: `margin` (pts), `bits` (info gain), `err` (abs. error once known), `hconfidence` (probability for home team).
* Timing/venue: `date`, `venue`, `updated`. ([Squiggle API][6])

**Examples**

```bash
curl "https://api.squiggle.com.au/?q=tips;year=2019;round=1"
curl "https://api.squiggle.com.au/?q=tips;source=8;year=2022;team=8"
```

([Squiggle API][7])

---

### 5) `q=standings` — Actual ladder at a point in time

**Parameters**

* `year`, `round` (see *Note on round*). ([Squiggle API][1])

**Fields**

* `id` (team id), `name`, `rank`, `played`, `wins`, `losses`, `draws`, `pts`, `for`, `against`, `percentage`,
  plus splits: `goals_for/against`, `behinds_for/against`. ([Squiggle API][8])

**Examples**

```bash
curl "https://api.squiggle.com.au/?q=standings;round=1"
curl "https://api.squiggle.com.au/?q=standings;year=2020;round=final"
```

([Squiggle API][9])

---

### 6) `q=ladder` — Projected ladders (model outputs)

**Parameters**

* `year`, `round`, `source`, `dummy` (placeholder flag). ([Squiggle API][1])

**Fields**

* `team`, `teamid`, `rank`, `wins`, `percentage`, `mean_rank`, `source`, `sourceid`, `updated`, `dummy`, and (often) a `swarms` distribution over finishing positions. ([Squiggle API][10])

**Examples**

```bash
curl "https://api.squiggle.com.au/?q=ladder;year=2019;round=15;source=1"
curl "https://api.squiggle.com.au/?q=ladder;year=2024;round=-1"   # preseason 2024
```

([Squiggle API][11])

---

### 7) `q=power` — Model power rankings

**Parameters**

* `year`, `round`, `source`, `team`, `dummy`. ([Squiggle API][1])

**Fields**

* `team`, `teamid`, `rank`, `power` (model-specific scale), `source`, `sourceid`, `year`, `round`, `updated`, `dummy`. ([Squiggle API][12])

**Example**

```bash
curl "https://api.squiggle.com.au/?q=power"
```

([Squiggle API][12])

---

## Event API (Server-Sent Events / SSE)

Use SSE for low-latency live updates.

**Channels**

* `GET /sse/games` — Stream of games in progress or starting soon.
  Optional: `/sse/games/<teamId>` for a single club. ([Squiggle API][1])
* `GET /sse/events` — Stream of in-game events (scores, time updates).
  Optional: `/sse/events/<gameId>` for one match. ([Squiggle API][1])
* `GET /sse/test` — Random data for wiring tests. ([Squiggle API][1])

**Event types (examples)**

* `games` (array on join), `addGame`, `removeGame` with full game snapshots.
* `game` (state), `score` (with `type=goal|behind`, side, `score{...}`), `timestr`, `complete`, `winner`.
* `complete` is 0–100 (% of match elapsed). ([Squiggle API][1])

**cURL**

```bash
# Live game list (keep-open connection)
curl -N -H "Accept: text/event-stream" "https://api.squiggle.com.au/sse/games"

# One game’s events
curl -N -H "Accept: text/event-stream" "https://api.squiggle.com.au/sse/events/<gameId>"
```

([Squiggle API][1])

**Notes**

* Connections can restart; implement auto-reconnect and resume using standard SSE semantics. ([Squiggle API][1])

---

## Semantics & Conventions

* **Time & TZ.** `date` is ISO UTC; `localtime` and `tz` give venue local time/offset. Prefer `unixtime` for ordering. ([Squiggle API][3])
* **Round parameter semantics.** For `standings`, `ladder`, `power`, `round` refers to the **most recently completed** round at that point in time.
  Pre-season: use `round=0` for years up to 2023, and `round=-1` from 2024 (AFL introduced Round 0 in 2024). Omitting `round` returns final/current. ([Squiggle API][1])
* **Finals flags.** See mapping under `games`. ([Squiggle API][1])
* **Special fixtures.** `year=2020-original` returns the pre-COVID original 2020 fixture. ([Squiggle API][1])

---

## Importing to Spreadsheets

**Google Sheets (XML)**

```excel
=IMPORTXML("https://api.squiggle.com.au/?q=tips;year=2022;source=1;format=xml","/*/*")
```

**Excel (JSON)**

* Data → Get & Transform → From File → From JSON → paste URL (e.g., `?q=tips;year=2018;source=1`). ([Squiggle API][1])

---

## Operational Guidance (“How to be nice”)

1. **Identify your bot** with a contactable `User-Agent` (e.g., “Acme Footy App — [dev@acme.com](mailto:dev@acme.com)”).
2. **Cache** responses; don’t refetch static data repeatedly.
3. **Batch sensibly** (e.g., fetch one season in one request, not one request per game).
4. **Request only what you need** (e.g., filter by `game` instead of whole `year`).
5. **Handle errors** without spamming retries.

> v1.11.0 explicitly blocks common scraper UAs. ([Squiggle API][1])

---

## Changelog (selected)

* **1.11.0 (Apr 2024):** Blocks generic scraper UAs; see User-Agent guidance.
* **1.10.x (Jan–Jul 2022):** `teams` supports historical names/logos; `games` added `unixtime`/`timestr`; added `team` param to `games/tips/power`.
* **1.8.0 (May 2022):** `power` added; `live` param on `games`.
* **1.7.0 (Apr 2022):** Event API (SSE).
* **1.3.0 (Jun 2019):** `standings` (actual ladder).
* **1.1.0 (May 2019):** `ladder` (projections). ([Squiggle API][1])

---

## Quick Recipes

```bash
# Current ladder (actual)
curl "https://api.squiggle.com.au/?q=standings"

# Model ladder projections after Round 10, 2019
curl "https://api.squiggle.com.au/?q=ladder;year=2019;round=10"

# Aggregate power rankings for 2025
curl "https://api.squiggle.com.au/?q=power;year=2025"

# All tips for a specific game
curl "https://api.squiggle.com.au/?q=tips;game=<gameId>"
```

([Squiggle API][8])

> **Useful links & look-ups**
> – [Squiggle API home](https://api.squiggle.com.au/) • [site\:api.squiggle.com.au search](https://www.google.com/search?q=site%3Aapi.squiggle.com.au) ([Squiggle API][1])
> – Example responses: [teams](https://www.google.com/search?q=%22%7B%5C%22teams%5C%22%3A%5B%7B%22+site%3Aapi.squiggle.com.au), [games](https://www.google.com/search?q=%22%7B%5C%22games%5C%22%3A%5B%7B%22+site%3Aapi.squiggle.com.au), [tips](https://www.google.com/search?q=%22%7B%5C%22tips%5C%22%3A%5B%7B%22+site%3Aapi.squiggle.com.au), [standings](https://www.google.com/search?q=%22%7B%5C%22standings%5C%22%3A%5B%7B%22+site%3Aapi.squiggle.com.au) ([Squiggle API][2])
> – Live SSE reference (games/events/test): [event stream docs](https://www.google.com/search?q=Event+API+site%3Aapi.squiggle.com.au) • [SSE protocol](https://www.google.com/search?q=Server-Sent+Events+MDN) ([Squiggle API][1])
> – R client (fitzRoy) integration notes: [Using the Squiggle API — fitzRoy vignette](https://www.google.com/search?q=Using+the+Squiggle+API+fitzRoy) ([CRAN][13])

[1]: https://api.squiggle.com.au/ "Squiggle API"
[2]: https://api.squiggle.com.au/?q=teams&utm_source=chatgpt.com "api.squiggle.com.au"
[3]: https://api.squiggle.com.au/?q=games%3Bcomplete%3D%21100&utm_source=chatgpt.com "api.squiggle.com.au"
[4]: https://api.squiggle.com.au/?q=games%3Byear%3D2018%3Bcomplete%3D100&utm_source=chatgpt.com "api.squiggle.com.au"
[5]: https://api.squiggle.com.au/?q=sources&utm_source=chatgpt.com "api.squiggle.com.au"
[6]: https://api.squiggle.com.au/?q=tips%3Byear%3D2020%3Bround%3D1&utm_source=chatgpt.com "api.squiggle.com.au"
[7]: https://api.squiggle.com.au/?q=tips%3Byear%3D2019%3Bround%3D1&utm_source=chatgpt.com "Squiggle"
[8]: https://api.squiggle.com.au/?q=standings&utm_source=chatgpt.com "Squiggle API"
[9]: https://api.squiggle.com.au/?q=standings%3Bround%3D1&utm_source=chatgpt.com "api.squiggle.com.au"
[10]: https://api.squiggle.com.au/?q=ladder%3Byear%3D2019%3Bround%3D10&utm_source=chatgpt.com "api.squiggle.com.au"
[11]: https://api.squiggle.com.au/?q=ladder%3Byear%3D2019%3Bround%3D15%3Bsource%3D1&utm_source=chatgpt.com "api.squiggle.com.au"
[12]: https://api.squiggle.com.au/?q=power&utm_source=chatgpt.com "api.squiggle.com.au"
[13]: https://cran.r-project.org/web//packages/fitzRoy/vignettes/using-squiggle-api.html?utm_source=chatgpt.com "Using the Squiggle API"
