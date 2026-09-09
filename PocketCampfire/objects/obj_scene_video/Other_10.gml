/// @description Close Video

// --------------------------------------------------
// VIDEO IS NOT CLOSED YET
// --------------------------------------------------
if(video_get_status() != video_status_closed)
{
    if(!video_close_pending)
    {
        video_close();
        video_close_pending = true;
    }

    alarm[0] = 1;
    return;
}


// --------------------------------------------------
// VIDEO IS CLOSED
// Give the native video player one extra frame
// to fully release before opening the next video.
// --------------------------------------------------
if(!video_close_wait)
{
    video_close_wait = true;
    alarm[0] = 1;
    return;
}


// --------------------------------------------------
// RELEASE WAIT COMPLETE
// --------------------------------------------------
video_close_wait = false;
video_close_pending = false;

event_user(1);