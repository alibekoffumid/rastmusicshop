import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://femydkrpjevzzesnbqdi.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZlbXlka3JwamV2enplc25icWRpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExNzE5NjksImV4cCI6MjA5Njc0Nzk2OX0.7YOW6SNLyYD9tlKYrB8hTHwPyKGq1n1BY3G0jfH6qO0'; // gitleaks:allow

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
