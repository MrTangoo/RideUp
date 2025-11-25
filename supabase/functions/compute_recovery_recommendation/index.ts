import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface RecoveryRequest {
    horseId: string
    days?: number
}

serve(async (req) => {
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { horseId, days = 7 }: RecoveryRequest = await req.json()

        if (!horseId) {
            throw new Error('Horse ID is required')
        }

        // Initialize Supabase client
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_ANON_KEY') ?? '',
            {
                global: {
                    headers: { Authorization: req.headers.get('Authorization')! },
                },
            }
        )

        // Fetch recent activities for the horse
        const startDate = new Date()
        startDate.setDate(startDate.getDate() - days)

        const { data: activities, error: activitiesError } = await supabaseClient
            .from('activities')
            .select('workload, duration_seconds, distance, start_time')
            .eq('horse_id', horseId)
            .gte('start_time', startDate.toISOString())
            .order('start_time', { ascending: false })

        if (activitiesError) throw activitiesError

        // Calculate recovery recommendation
        const recommendation = calculateRecovery(activities)

        return new Response(
            JSON.stringify({
                success: true,
                data: recommendation,
            }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 200,
            }
        )
    } catch (error) {
        return new Response(
            JSON.stringify({
                success: false,
                error: error.message,
            }),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 400,
            }
        )
    }
})

function calculateRecovery(activities: any[]): any {
    if (!activities || activities.length === 0) {
        return {
            recommendedRestHours: 0,
            workloadLevel: 'none',
            message: 'Aucune activité récente. Le cheval est bien reposé.',
            canRide: true,
        }
    }

    // Calculate average workload
    const totalWorkload = activities.reduce((sum, act) => sum + (act.workload || 0), 0)
    const avgWorkload = totalWorkload / activities.length

    // Calculate total distance and duration
    const totalDistance = activities.reduce((sum, act) => sum + (act.distance || 0), 0)
    const totalDuration = activities.reduce((sum, act) => sum + (act.duration_seconds || 0), 0)

    // Get time since last activity
    const lastActivity = activities[0]
    const hoursSinceLastRide = (Date.now() - new Date(lastActivity.start_time).getTime()) / (1000 * 60 * 60)

    let recommendedRestHours = 0
    let workloadLevel = 'light'
    let message = ''
    let canRide = true

    // Determine workload level and rest recommendation
    if (avgWorkload < 30) {
        workloadLevel = 'light'
        recommendedRestHours = 12
        message = 'Charge de travail légère. Le cheval peut reprendre l\'entraînement.'
    } else if (avgWorkload < 60) {
        workloadLevel = 'moderate'
        recommendedRestHours = 24
        message = 'Charge de travail modérée. Un jour de repos est recommandé.'
    } else if (avgWorkload < 80) {
        workloadLevel = 'intense'
        recommendedRestHours = 48
        message = 'Charge de travail intense. Deux jours de repos sont recommandés.'
    } else {
        workloadLevel = 'very_intense'
        recommendedRestHours = 72
        message = 'Charge de travail très intense. Trois jours de repos minimum sont nécessaires.'
    }

    // Check if enough rest has been taken
    if (hoursSinceLastRide < recommendedRestHours) {
        canRide = false
        const remainingHours = Math.ceil(recommendedRestHours - hoursSinceLastRide)
        message += ` Il reste ${remainingHours}h de repos recommandé.`
    } else {
        canRide = true
        message += ' Le cheval est suffisamment reposé.'
    }

    return {
        recommendedRestHours,
        workloadLevel,
        message,
        canRide,
        stats: {
            activitiesCount: activities.length,
            avgWorkload: avgWorkload.toFixed(1),
            totalDistance: (totalDistance / 1000).toFixed(2) + ' km',
            totalDuration: formatDuration(totalDuration),
            hoursSinceLastRide: hoursSinceLastRide.toFixed(1),
        },
    }
}

function formatDuration(seconds: number): string {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)

    if (hours > 0) {
        return `${hours}h ${minutes}min`
    } else {
        return `${minutes}min`
    }
}
