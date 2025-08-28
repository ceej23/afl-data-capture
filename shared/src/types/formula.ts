export interface Metric {
  id: string;
  name: string;
  description: string;
  category: MetricCategory;
  dataType: 'number' | 'percentage' | 'boolean';
  unit?: string;
  minValue?: number;
  maxValue?: number;
}

export enum MetricCategory {
  OFFENSE = 'offense',
  DEFENSE = 'defense',
  FORM = 'form',
  HEAD_TO_HEAD = 'head_to_head',
  VENUE = 'venue',
  WEATHER = 'weather',
  HISTORICAL = 'historical',
}

export interface FormulaMetric {
  id: string;
  metricId: string;
  weight: number;
  operator: 'add' | 'subtract' | 'multiply' | 'divide';
  condition?: MetricCondition;
}

export interface MetricCondition {
  type: 'threshold' | 'range' | 'comparison';
  operator: '>' | '<' | '>=' | '<=' | '==' | '!=' | 'between';
  value: number | [number, number];
  action: 'include' | 'exclude' | 'modify';
  modifier?: number;
}

export interface Formula {
  id: string;
  userId: string;
  name: string;
  description?: string;
  metrics: FormulaMetric[];
  isPublic: boolean;
  isTemplate: boolean;
  confidence: number;
  backtestResults?: BacktestSummary;
  createdAt: Date;
  updatedAt: Date;
}

export interface BacktestSummary {
  totalGames: number;
  correctPredictions: number;
  accuracy: number;
  avgConfidence: number;
  profitLoss: number;
  roi: number;
}