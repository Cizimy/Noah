-- Enable foreign key support
PRAGMA foreign_keys = ON;

-- KEYWORDSテーブル作成
CREATE TABLE IF NOT EXISTS keywords (
    keyword_id TEXT PRIMARY KEY,
    base_keyword TEXT NOT NULL UNIQUE,
    global_emotion_score INTEGER CHECK(global_emotion_score BETWEEN 0 AND 100),
    first_registered DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_accessed DATETIME,
    lifecycle_status TEXT CHECK(lifecycle_status IN ('active','inactive','archived')),
    semantic_vector BLOB
);

-- INTERPRETATIONSテーブル作成
CREATE TABLE IF NOT EXISTS interpretations (
    interp_id TEXT PRIMARY KEY,
    keyword_id TEXT,
    interpretation TEXT NOT NULL,
    emotion_profile TEXT CHECK(json_valid(emotion_profile)),
    context_tags TEXT CHECK(json_valid(context_tags)),
    valid_from DATETIME NOT NULL,
    valid_to DATETIME CHECK(valid_to >= valid_from),
    FOREIGN KEY(keyword_id) REFERENCES keywords(keyword_id)
);

-- NARRATIVESテーブル作成
CREATE TABLE IF NOT EXISTS narratives (
    narrative_id TEXT PRIMARY KEY,
    interp_id TEXT,
    summary TEXT NOT NULL,
    full_story TEXT,
    story_coherence REAL CHECK(story_coherence BETWEEN 0 AND 1),
    derived_elements TEXT CHECK(json_valid(derived_elements)),
    last_accessed_date DATETIME,
    derived_from TEXT,
    FOREIGN KEY(interp_id) REFERENCES interpretations(interp_id),
    FOREIGN KEY(derived_from) REFERENCES narratives(narrative_id)
);

-- RELATED_KEYWORDSテーブル作成
CREATE TABLE IF NOT EXISTS related_keywords (
    relation_id TEXT PRIMARY KEY,
    source_interp_id TEXT,
    target_keyword_id TEXT,
    relation_strength REAL CHECK(relation_strength BETWEEN 0 AND 1),
    established_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    context TEXT CHECK(json_valid(context)),
    FOREIGN KEY(source_interp_id) REFERENCES interpretations(interp_id),
    FOREIGN KEY(target_keyword_id) REFERENCES keywords(keyword_id)
);

-- METADATAテーブル作成
CREATE TABLE IF NOT EXISTS metadata (
    meta_id TEXT PRIMARY KEY,
    interp_id TEXT,
    creation_info TEXT NOT NULL CHECK(json_valid(creation_info)),
    usage_history TEXT CHECK(json_valid(usage_history)),
    version_log TEXT CHECK(json_valid(version_log)),
    reference_integrity TEXT CHECK(json_valid(reference_integrity)),
    data_quality_score REAL CHECK(data_quality_score BETWEEN 0 AND 1),
    last_quality_check DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(interp_id) REFERENCES interpretations(interp_id)
);

-- NARRATIVE_VERSIONSテーブル作成
CREATE TABLE IF NOT EXISTS narrative_versions (
    version_id TEXT PRIMARY KEY,
    narrative_id TEXT,
    delta_changes TEXT NOT NULL,
    version_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    change_reason TEXT CHECK(LENGTH(change_reason) <= 500),
    FOREIGN KEY(narrative_id) REFERENCES narratives(narrative_id)
);

-- AUDIT_LOGSテーブル作成
CREATE TABLE IF NOT EXISTS audit_logs (
    log_id TEXT PRIMARY KEY,
    meta_id TEXT,
    event_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    event_type TEXT CHECK(event_type IN ('create','update','delete')),
    user_role TEXT NOT NULL,
    before_state TEXT CHECK(json_valid(before_state)),
    after_state TEXT CHECK(json_valid(after_state)),
    severity_level TEXT CHECK(severity_level IN ('info', 'warning', 'error')) DEFAULT 'info',
    performance_impact REAL CHECK(performance_impact BETWEEN 0 AND 1) DEFAULT 0,
    FOREIGN KEY(meta_id) REFERENCES metadata(meta_id)
);

-- SYSTEM_HEALTH_METRICSテーブル作成
CREATE TABLE IF NOT EXISTS system_health_metrics (
    metric_id TEXT PRIMARY KEY,
    metric_name TEXT NOT NULL,
    metric_value REAL,
    measure_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    threshold_warning REAL,
    threshold_critical REAL,
    CHECK (metric_value >= 0)
);

-- インデックス作成
CREATE INDEX IF NOT EXISTS idx_base_keyword ON keywords(base_keyword);
CREATE INDEX IF NOT EXISTS idx_emotion_score ON keywords(global_emotion_score);
CREATE INDEX IF NOT EXISTS idx_keyword_relation ON interpretations(keyword_id);
CREATE INDEX IF NOT EXISTS idx_validity_range ON interpretations(valid_from, valid_to);
CREATE INDEX IF NOT EXISTS idx_coherence_score ON narratives(story_coherence);
CREATE INDEX IF NOT EXISTS idx_derived_relation ON narratives(derived_from);
CREATE INDEX IF NOT EXISTS idx_relation_strength ON related_keywords(relation_strength);
CREATE INDEX IF NOT EXISTS idx_keyword_pair ON related_keywords(source_interp_id, target_keyword_id);