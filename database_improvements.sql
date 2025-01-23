-- 1. データバリデーションの強化
-- 感情プロファイルのバリデーション
ALTER TABLE interpretations
ADD CONSTRAINT valid_emotion_profile
CHECK (
    json_valid(emotion_profile) AND 
    json_extract(emotion_profile, '$.joy') BETWEEN 0 AND 1 AND
    json_extract(emotion_profile, '$.sadness') BETWEEN 0 AND 1 AND
    json_extract(emotion_profile, '$.surprise') BETWEEN 0 AND 1 AND
    json_extract(emotion_profile, '$.anger') BETWEEN 0 AND 1 AND
    json_extract(emotion_profile, '$.expectation') BETWEEN 0 AND 1
);

-- コンテキストタグのバリデーション
ALTER TABLE interpretations
ADD CONSTRAINT valid_context_tags
CHECK (
    json_valid(context_tags) AND
    json_extract(context_tags, '$.timeContext') IN ('過去', '現在', '未来') AND
    json_extract(context_tags, '$.spaceContext') IN ('屋内', '屋外', '仮想') AND
    json_type(json_extract(context_tags, '$.participants')) = 'array'
);

-- 2. パフォーマンス最適化
-- アクティブなキーワードの意味ベクトル検索用インデックス
CREATE INDEX idx_semantic_search 
ON keywords (semantic_vector)
WHERE lifecycle_status = 'active';

-- 感情値範囲検索用インデックス
CREATE INDEX idx_emotion_range
ON keywords (global_emotion_score)
WHERE lifecycle_status = 'active';

-- 時間範囲検索用インデックス
CREATE INDEX idx_interpretation_validity
ON interpretations (valid_from, valid_to)
WHERE valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP;

-- 3. メタデータ管理の拡張
-- データ品質スコアの追加
ALTER TABLE metadata
ADD COLUMN data_quality_score REAL
CHECK (data_quality_score BETWEEN 0 AND 1);

-- メタデータの更新日時追加
ALTER TABLE metadata
ADD COLUMN last_quality_check DATETIME
DEFAULT CURRENT_TIMESTAMP;

-- 4. 監査機能の強化
-- 重要度レベルの追加
ALTER TABLE audit_logs
ADD COLUMN severity_level TEXT
CHECK (severity_level IN ('info', 'warning', 'error'))
DEFAULT 'info';

-- パフォーマンス影響度の追加
ALTER TABLE audit_logs
ADD COLUMN performance_impact REAL
CHECK (performance_impact BETWEEN 0 AND 1)
DEFAULT 0;

-- システムヘルスメトリクスの追加
CREATE TABLE system_health_metrics (
    metric_id TEXT PRIMARY KEY,
    metric_name TEXT NOT NULL,
    metric_value REAL,
    measure_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    threshold_warning REAL,
    threshold_critical REAL,
    CHECK (metric_value >= 0)
);

-- サンプルデータの更新
UPDATE metadata 
SET data_quality_score = 0.95,
    last_quality_check = CURRENT_TIMESTAMP
WHERE meta_id = 'META-0001';

UPDATE audit_logs
SET severity_level = 'info',
    performance_impact = 0.1
WHERE log_id = 'LOG-0001';

INSERT INTO system_health_metrics 
(metric_id, metric_name, metric_value, threshold_warning, threshold_critical)
VALUES
('METRIC-001', 'データベース応答時間', 0.15, 0.5, 1.0),
('METRIC-002', 'メモリ使用率', 45.5, 80.0, 90.0),
('METRIC-003', 'ストレージ使用率', 35.2, 75.0, 85.0);