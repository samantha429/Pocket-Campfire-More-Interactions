/// @description Close Video

// If the video is already closed, proceed immediately.
if(video_get_status() == video_status_closed)
{
    video_close_pending = false;
    event_user(1);
    return;
}

// Request the current video to close.
if(!video_close_pending)
{
    video_close();
    video_close_pending = true;
}

// Wait until the video is actually closed.
if(video_get_status() != video_status_closed)
{
    alarm[0] = 1; // Retry after 1 frame
    return;
}

// The old video is definitely closed.
video_close_pending = false;
event_user(1);