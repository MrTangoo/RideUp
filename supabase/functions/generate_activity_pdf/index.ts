import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface ActivityData {
    activityId: string
}

serve(async (req) => {
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { activityId }: ActivityData = await req.json()

        if (!activityId) {
            throw new Error('Activity ID is required')
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

        // Fetch activity data
        const { data: activity, error: activityError } = await supabaseClient
            .from('activities')
            .select(`
        *,
        horses:horse_id (name, breed),
        activity_points (lat, lng, speed, altitude, timestamp)
      `)
            .eq('id', activityId)
            .single()

        if (activityError) throw activityError

        // Generate PDF content (simplified - in production, use a PDF library)
        const pdfContent = {
            activity: {
                horseName: activity.horses.name,
                breed: activity.horses.breed,
                date: new Date(activity.start_time).toLocaleDateString('fr-FR'),
                duration: formatDuration(activity.duration_seconds),
                distance: `${(activity.distance / 1000).toFixed(2)} km`,
                avgSpeed: `${activity.avg_speed.toFixed(1)} km/h`,
                maxSpeed: `${activity.max_speed.toFixed(1)} km/h`,
                calories: `${activity.calories.toFixed(0)} kcal`,
                elevationGain: `${activity.elevation_gain.toFixed(0)} m`,
                pointsCount: activity.activity_points.length,
            },
        }

        // In a real implementation, you would use a PDF generation library here
        // For now, we return the data that would be used to generate the PDF
        return new Response(
            JSON.stringify({
                success: true,
                message: 'PDF data generated successfully',
                data: pdfContent,
                // In production, return: pdfUrl or pdfBase64
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

function formatDuration(seconds: number): string {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    const secs = seconds % 60

    if (hours > 0) {
        return `${hours}h ${minutes}min`
    } else if (minutes > 0) {
        return `${minutes}min ${secs}s`
    } else {
        return `${secs}s`
    }
}
