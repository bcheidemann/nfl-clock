use std::{collections::HashSet, path::PathBuf};

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Hash, PartialEq, Eq)]
pub struct TeamId(String);

#[derive(Serialize, Deserialize)]
pub struct AlarmRegistry {
    scheduled_alarms: HashSet<TeamId>,
}

impl AlarmRegistry {
    pub fn new() -> Self {
        Self::load_or_init_registry()
    }

    pub fn set_alarm_scheduled_for_team(&mut self, team_id: TeamId, scheduled: bool) {
        if scheduled {
            self.scheduled_alarms.insert(team_id);
        } else {
            self.scheduled_alarms.remove(&team_id);
        }
        self.save_to_disk();
    }

    pub fn is_alarm_scheduled_for_team(&self, team_id: &TeamId) -> bool {
        self.scheduled_alarms.contains(team_id)
    }

    fn get_registry_dir() -> PathBuf {
        std::env::home_dir()
            .expect("Current user does not have a home directory")
            .join(".nfl-clock")
    }

    fn get_registry_file_path() -> PathBuf {
        Self::get_registry_dir().join("alarm-registry.json")
    }

    fn load_or_init_registry() -> Self {
        let Ok(registry_json) = std::fs::read_to_string(Self::get_registry_file_path()) else {
            return Self::init_registry();
        };

        let Ok(registry) = serde_json::from_slice(registry_json.as_ref()) else {
            return Self::init_registry();
        };

        registry
    }

    fn init_registry() -> Self {
        let registry = Self {
            scheduled_alarms: Default::default(),
        };

        registry.save_to_disk();

        registry
    }

    fn save_to_disk(&self) {
        std::fs::create_dir_all(Self::get_registry_dir())
            .expect("Failed to create registry directory.");

        let registry_json = serde_json::to_string(&self).expect("Failed to serialize registry");

        std::fs::write(Self::get_registry_file_path(), registry_json)
            .expect("Failed to save registry");
    }
}
