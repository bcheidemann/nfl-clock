use std::io::Cursor;

use lazy_static::lazy_static;
use rodio::Decoder;

lazy_static! {
    static ref OUTPUT_STREAM: rodio::OutputStream =
        rodio::OutputStreamBuilder::open_default_stream().expect("open default audio stream");
    static ref AUDIO_SINK: rodio::Sink = rodio::Sink::connect_new(&OUTPUT_STREAM.mixer());
}

#[tauri::command]
fn play_alarm() {
    AUDIO_SINK.clear();
    let alarm_bytes = Cursor::new(include_bytes!("../assets/alarm.mp3").as_ref());
    let alarm = Decoder::new(alarm_bytes).unwrap();
    AUDIO_SINK.append(alarm);
    AUDIO_SINK.play();
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![play_alarm])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
