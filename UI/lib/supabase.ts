import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

console.log('Supabase URL:', supabaseUrl);
console.log('Supabase Key:', supabaseAnonKey);

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export type GatePassStatus = 'created' | 'approved' | 'checked_in' | 'checked_out';

export interface GatePass {
  id: string;
  pass_number: string;
  created_at: string;
  effective_date: string;
  department: string;
  contact_person: string;
  purpose: string;
  status: GatePassStatus;
  created_by: string;
  approved_by?: string;
  checked_in_by?: string;
  checked_out_by?: string;
  checked_in_at?: string;
  checked_out_at?: string;
  updated_at: string;
  creator?: {
    full_name: string;
  };
}

export async function getGatePassStats() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  try {
    // Get all gate passes for today
    const { data: gatePasses, error } = await supabase
      .from('gate_passes')
      .select('status, created_at, checked_out_at')
      .gte('created_at', today.toISOString());

    if (error) throw error;

    // Calculate stats from the fetched data
    const stats = {
      totalToday: 0,
      active: 0,
      pending: 0,
      completedToday: 0
    };

    gatePasses?.forEach(pass => {
      // Count total passes created today
      stats.totalToday++;

      // Count by status
      if (pass.status === 'created') {
        stats.pending++;
      } else if (pass.status === 'checked_in') {
        stats.active++;
      } else if (pass.status === 'checked_out' && pass.checked_out_at && new Date(pass.checked_out_at) >= today) {
        stats.completedToday++;
      }
    });

    return stats;
  } catch (error) {
    console.error('Error in getGatePassStats:', error);
    throw error;
  }
}

export async function getRecentGatePasses() {
  try {
    // First, get the gate passes
    const { data: passes, error: passesError } = await supabase
      .from('gate_passes')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(10);

    if (passesError) throw passesError;

    // Then, get the creators' information
    if (passes && passes.length > 0) {
      const creatorIds = Array.from(new Set(passes.map(pass => pass.created_by)));
      const { data: creators, error: creatorsError } = await supabase
        .from('users')
        .select('id, full_name')
        .in('id', creatorIds);

      if (creatorsError) throw creatorsError;

      // Map creators to passes
      const passesWithCreators = passes.map(pass => ({
        ...pass,
        creator: creators?.find(creator => creator.id === pass.created_by)
      }));

      return passesWithCreators;
    }

    return passes || [];
  } catch (error) {
    console.error('Error in getRecentGatePasses:', error);
    throw error;
  }
} 