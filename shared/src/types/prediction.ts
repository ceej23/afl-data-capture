export interface Team {
  id: string;
  name: string;
  shortName: string;
  logo?: string;
  homeGround?: string;
}

export interface Match {
  id: string;
  round: number;
  season: number;
  homeTeam: Team;
  awayTeam: Team;
  venue: string;
  date: Date;
  status: MatchStatus;
  result?: MatchResult;
}

export enum MatchStatus {
  SCHEDULED = 'scheduled',
  LIVE = 'live',
  COMPLETED = 'completed',
  POSTPONED = 'postponed',
  CANCELLED = 'cancelled',
}

export interface MatchResult {
  homeScore: number;
  awayScore: number;
  winner: 'home' | 'away' | 'draw';
  margin: number;
}

export interface Prediction {
  id: string;
  userId: string;
  formulaId: string;
  matchId: string;
  predictedWinner: 'home' | 'away';
  predictedMargin: number;
  confidence: number;
  probability: {
    home: number;
    away: number;
  };
  metrics: PredictionMetric[];
  createdAt: Date;
  result?: PredictionResult;
}

export interface PredictionMetric {
  metricId: string;
  metricName: string;
  value: number;
  weight: number;
  contribution: number;
}

export interface PredictionResult {
  correct: boolean;
  actualMargin: number;
  marginError: number;
  confidenceAccuracy: number;
}