mod alarm_registry;

use std::{io::Cursor, sync::Mutex};

use lazy_static::lazy_static;
use rodio::Decoder;

use crate::alarm_registry::{AlarmRegistry, TeamId};

lazy_static! {
    static ref OUTPUT_STREAM: rodio::OutputStream =
        rodio::OutputStreamBuilder::open_default_stream().expect("open default audio stream");
    static ref AUDIO_SINK: rodio::Sink = rodio::Sink::connect_new(&OUTPUT_STREAM.mixer());
    static ref ALARM_REGISTRY: Mutex<AlarmRegistry> = Mutex::new(AlarmRegistry::new());
}

#[tauri::command]
fn play_alarm() {
    AUDIO_SINK.clear();
    let alarm_bytes = Cursor::new(include_bytes!("../assets/alarm.mp3").as_ref());
    let alarm = Decoder::new(alarm_bytes).unwrap();
    AUDIO_SINK.append(alarm);
    AUDIO_SINK.play();
}

#[tauri::command]
fn stop_alarm() {
    AUDIO_SINK.clear();
}

#[tauri::command]
fn set_alarm_scheduled_for_team(team_id: TeamId, scheduled: bool) {
    ALARM_REGISTRY
        .lock()
        .expect("Failed to acquire mutex lock on alarm registry")
        .set_alarm_scheduled_for_team(team_id, scheduled)
}

#[tauri::command]
fn is_alarm_scheduled_for_team(team_id: TeamId) -> bool {
    ALARM_REGISTRY
        .lock()
        .expect("Failed to acquire mutex lock on alarm registry")
        .is_alarm_scheduled_for_team(&team_id)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![
            play_alarm,
            stop_alarm,
            set_alarm_scheduled_for_team,
            is_alarm_scheduled_for_team
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
