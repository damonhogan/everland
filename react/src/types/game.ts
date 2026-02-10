export interface Item {
  id: string;
  name: string;
  description?: string;
  type?: string;
  value?: number;
  stackable?: boolean;
  tags?: string[];
  [key: string]: any;
}

export interface NPC {
  id: string;
  name: string;
  description?: string;
  level?: number;
  hp?: number;
  location?: string;
  [key: string]: any;
}

export interface Quest {
  id: string;
  title: string;
  description?: string;
  requirements?: Record<string, any>;
  rewards?: {
    gold?: number;
    items?: Array<string | Item>;
  };
  [key: string]: any;
}

export interface Recipe {
  id: string;
  output: string;
  inputs: Record<string, number>;
  [key: string]: any;
}

export interface GameData {
  items?: Record<string, Item>;
  npcs?: NPC[];
  quests?: Quest[];
  recipes?: Recipe[];
}

export type LoadStatus = 'idle' | 'loading' | 'error' | 'ready';

export interface GameDataState {
  data?: GameData;
  status: LoadStatus;
  error?: string;
  refresh?: () => Promise<void>;
  setQuests?: (q: any[] | ((q: any[]) => any[])) => void;
  questsDispatch?: (action: { type: string; payload?: any; actionId?: string }) => void;
  syncToServer?: (quests: any[]) => Promise<void>;
  pendingActions?: Array<{ actionId:string; type:string; payload?:any }>;
  pendingSyncs?: number;
}
