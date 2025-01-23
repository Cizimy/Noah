-- 1. データバリデーションの強化
-- 感情プロファイルのバリデーション（既存の制約を使用）
CREATE TRIGGER validate_emotion_profile
BEFORE INSERT ON interpretations
FOR EACH ROW
WHEN NEW.emotion_profile IS NOT NULL
BEGIN
    SELECT CASE 
        WHEN NOT json_valid(NEW.emotion_profile) THEN
            RAISE(ABORT, 'Invalid emotion_profile JSON format')
        WHEN NOT (
            json_extract(NEW.emotion_profile, '$.joy') BETWEEN 0 AND 1 AND
            json_extract(NEW.emotion_profile, '$.sadness') BETWEEN 0 AND 1 AND
            json_extract(NEW.emotion_profile, '$.surprise') BETWEEN 0 AND 1 AND
            json_extract(NEW.emotion_profile, '$.anger') BETWEEN 0 AND 1 AND
            json_extract(NEW.emotion_profile, '$.expectation') BETWEEN 0 AND 1
        ) THEN
            RAISE(ABORT, 'Emotion values must be between 0 and 1')
    END;
END;

-- コンテキストタグのバリデーション
CREATE TRIGGER validate_context_tags
BEFORE INSERT ON interpretations
FOR EACH ROW
WHEN NEW.context_tags IS NOT NULL
BEGIN
    SELECT CASE
        WHEN NOT json_valid(NEW.context_tags) THEN
            RAISE(ABORT, 'Invalid context_tags JSON format')
        WHEN NOT (
            json_extract(NEW.context_tags, '$.timeContext') IN ('過去', '現在', '未来') AND
            json_extract(NEW.context_tags, '$.spaceContext') IN ('屋内', '屋外', '仮想') AND
            json_type(json_extract(NEW.context_tags, '$.participants')) = 'array'
        ) THEN
            RAISE(ABORT, 'Invalid context_tags values')
    END;
END;

-- 2. パフォーマンス最適化
-- アクティブなキーワードの意味ベクトル検索用インデックス
CREATE INDEX IF NOT EXISTS idx_semantic_search 
ON keywords (semantic_vector)
WHERE lifecycle_status = 'active';

-- 感情値範囲検索用インデックス
CREATE INDEX IF NOT EXISTS idx_emotion_range
ON keywords (global_emotion_score)
WHERE lifecycle_status = 'active';

-- 時間範囲検索用インデックス（静的な条件のみ）
CREATE INDEX IF NOT EXISTS idx_interpretation_validity
ON interpretations (valid_from, valid_to)
WHERE valid_to IS NULL;

-- 3. メタデータ管理の拡張
-- 既存のカラムは schema.sql で作成済みのため、ここではスキップ

-- 4. 監査機能の強化
-- 既存のカラムは schema.sql で作成済みのため、ここではスキップ

-- 5. データ品質チェックトリガーの追加
CREATE TRIGGER check_data_quality
AFTER INSERT ON metadata
BEGIN
    UPDATE metadata 
    SET last_quality_check = CURRENT_TIMESTAMP,
        data_quality_score = (
            CASE 
                WHEN json_valid(NEW.creation_info) 
                AND json_valid(NEW.usage_history)
                AND json_valid(NEW.version_log)
                AND json_valid(NEW.reference_integrity)
                THEN 1.0
                ELSE 0.5
            END
        )
    WHERE meta_id = NEW.meta_id;
END;

-- 6. システムヘルスメトリクス更新トリガー
CREATE TRIGGER update_health_metrics
AFTER INSERT ON audit_logs
BEGIN
    UPDATE system_health_metrics
    SET metric_value = (
        SELECT COUNT(*) * 1.0 / 
            (strftime('%s', 'now') - strftime('%s', datetime('now', '-1 hour')))
        FROM audit_logs
        WHERE event_time >= datetime('now', '-1 hour')
    )
    WHERE metric_name = 'データベース応答時間';
END;