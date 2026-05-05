export interface MaintenanceItem {
  system: string;
  category: string;
  name: string;
  description: string;
  role: string;
  reason: string;
  quantity: number;
  unit_price: number;
  total_price: number;
}

export interface DriverSummary {
  one_line: string;
  reason: string;
  work_done: string;
  impact: string;
  cost_explanation: string;
}

export interface AnalysisResult {
  is_valid: true;
  language: string;
  date: string | null;
  garage_name: string | null;
  garage_address: string | null;
  mechanic: string | null;
  mileage: number;
  items: MaintenanceItem[];
  total_cost: number;
  currency: string;
  car_brand: string | null;
  car_model: string | null;
  car_year: number | null;
  license_plate: string | null;
  driver_summary: DriverSummary;
}

export type AnalysisResponse = { is_valid: false } | AnalysisResult;
