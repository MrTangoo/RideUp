import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        // Initialize Supabase client with service role key for admin access
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
        )

        // Get current time
        const now = new Date()

        // Fetch notifications that need to be sent
        const { data: notifications, error: notificationsError } = await supabaseClient
            .from('notifications')
            .select('*')
            .eq('sent', false)
            .lte('scheduled_time', now.toISOString())
            .limit(100)

        if (notificationsError) throw notificationsError

        if (!notifications || notifications.length === 0) {
            return new Response(
                JSON.stringify({
                    success: true,
                    message: 'No notifications to send',
                    count: 0,
                }),
                {
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                    status: 200,
                }
            )
        }

        // Send notifications via FCM
        const results = await Promise.all(
            notifications.map(async (notification) => {
                try {
                    // In a real implementation, you would:
                    // 1. Get user's FCM token from a tokens table
                    // 2. Send notification via Firebase Admin SDK
                    // 3. Mark notification as sent

                    // For now, we'll just mark as sent
                    await supabaseClient
                        .from('notifications')
                        .update({ sent: true })
                        .eq('id', notification.id)

                    return {
                        id: notification.id,
                        success: true,
                    }
                } catch (error) {
                    console.error(`Failed to send notification ${notification.id}:`, error)
                    return {
                        id: notification.id,
                        success: false,
                        error: error.message,
                    }
                }
            })
        )

        const successCount = results.filter((r) => r.success).length
        const failureCount = results.filter((r) => !r.success).length

        return new Response(
            JSON.stringify({
                success: true,
                message: `Processed ${notifications.length} notifications`,
                stats: {
                    total: notifications.length,
                    success: successCount,
                    failed: failureCount,
                },
                results,
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

/* 
 * This Edge Function should be triggered by a cron job
 * Set up in Supabase Dashboard:
 * - Go to Edge Functions
 * - Set up a cron trigger for this function
 * - Schedule: */5 * * * * (every 5 minutes)
 */
