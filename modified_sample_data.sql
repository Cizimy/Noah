-- KEYWORDSテーブルのサンプルデータ
INSERT INTO keywords (keyword_id, base_keyword, global_emotion_score, first_registered, last_accessed, lifecycle_status)
VALUES 
('KW-0001', '猫', 75, '2024-12-01 10:00:00', '2025-01-23 13:00:00', 'active'),
('KW-0002', '雨', 45, '2024-12-01 10:30:00', '2025-01-22 15:30:00', 'active'),
('KW-0003', '公園', 65, '2024-12-02 09:15:00', '2025-01-23 10:20:00', 'active');

-- INTERPRETATIONSテーブルのサンプルデータ
INSERT INTO interpretations (interp_id, keyword_id, interpretation, emotion_profile, context_tags, valid_from, valid_to)
VALUES
('INT-0001', 'KW-0001', '路地裏で出会った野良猫との温かな触れ合い',
'{
  "joy": 0.8,
  "sadness": 0.2,
  "surprise": 0.3,
  "anger": 0.0,
  "expectation": 0.6
}',
'{
  "timeContext": "過去",
  "spaceContext": "屋外",
  "participants": ["話者", "通行人"]
}',
'2024-12-01 10:00:00', NULL),

('INT-0002', 'KW-0002', '梅雨時期の切ない帰り道',
'{
  "joy": 0.2,
  "sadness": 0.7,
  "surprise": 0.1,
  "anger": 0.1,
  "expectation": 0.4
}',
'{
  "timeContext": "現在",
  "spaceContext": "屋外",
  "participants": ["話者"]
}',
'2024-12-01 10:30:00', NULL);

-- NARRATIVESテーブルのサンプルデータ
INSERT INTO narratives (narrative_id, interp_id, summary, full_story, story_coherence, derived_elements, last_accessed_date, derived_from)
VALUES
('NAR-0001', 'INT-0001', '雨上がりの路地裏での猫との出会い',
'その日は雨上がりで、路地には水たまりが点々と残っていた。そこで出会った三毛猫は、濡れた体を丁寧に毛づくろいしていた。近づくと警戒することなく、むしろ人なつっこい様子で寄ってきた。',
0.95,
'{
  "symbolism": "予期せぬ出会い",
  "metaphor": "心の潤い",
  "lifeLesson": "偶然の出会いが心を温める"
}',
'2025-01-23 13:00:00', NULL);

-- RELATED_KEYWORDSテーブルのサンプルデータ
INSERT INTO related_keywords (relation_id, source_interp_id, target_keyword_id, relation_strength, established_date, context)
VALUES
('REL-0001', 'INT-0001', 'KW-0002', 0.7, '2024-12-01 10:30:00',
'{
  "commonContexts": ["屋外", "静けさ", "癒し"],
  "temporalOverlap": 0.8
}');

-- METADATAテーブルのサンプルデータ
INSERT INTO metadata (meta_id, interp_id, creation_info, usage_history, version_log, reference_integrity, data_quality_score)
VALUES
('META-0001', 'INT-0001',
'{
  "createdBy": "system",
  "createdVia": "auto",
  "editHistory": [
    {
      "timestamp": "2024-12-01 10:00:00",
      "editor": "system",
      "action": "create"
    }
  ]
}',
'{
  "accessCount": 15,
  "last5Accessors": ["user1", "user2", "user3", "user1", "user4"],
  "hotnessScore": 0.85
}',
'{
  "currentVersion": "1.0",
  "previousVersions": []
}',
'{
  "isConsistent": true,
  "validationReport": "All references valid and up-to-date"
}',
0.95);

-- NARRATIVE_VERSIONSテーブルのサンプルデータ
INSERT INTO narrative_versions (version_id, narrative_id, delta_changes, version_date, change_reason)
VALUES
('VER-0001', 'NAR-0001', 'Initial version of the story', '2024-12-01 10:00:00', 'Initial creation');

-- AUDIT_LOGSテーブルのサンプルデータ
INSERT INTO audit_logs (log_id, meta_id, event_time, event_type, user_role, before_state, after_state, severity_level, performance_impact)
VALUES
('LOG-0001', 'META-0001', '2024-12-01 10:00:00', 'create', 'system',
'{
  "state": "non-existent"
}',
'{
  "state": "created",
  "details": {
    "interp_id": "INT-0001",
    "creation_time": "2024-12-01 10:00:00"
  }
}',
'info',
0.1);

-- SYSTEM_HEALTH_METRICSテーブルのサンプルデータ
INSERT INTO system_health_metrics 
(metric_id, metric_name, metric_value, threshold_warning, threshold_critical)
VALUES
('METRIC-001', 'データベース応答時間', 0.15, 0.5, 1.0),
('METRIC-002', 'メモリ使用率', 45.5, 80.0, 90.0),
('METRIC-003', 'ストレージ使用率', 35.2, 75.0, 85.0);