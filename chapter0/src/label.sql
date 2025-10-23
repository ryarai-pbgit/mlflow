USE DATABASE TESTDB;

-- 1. 質問リストを格納するテーブル
CREATE OR REPLACE TABLE query_validation_list (
    query_id INT AUTOINCREMENT,
    query_text VARCHAR(2000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- 2. 内部ステージからデータをインポート
COPY INTO query_validation_list (query_text)
FROM '@TESTDB.PUBLIC.MY_FILE_STAGE/natural_language_queries.txt'
FILE_FORMAT = (TYPE = CSV FIELD_DELIMITER = '|' SKIP_HEADER = 1);

-- 3. Verified Queriesとの類似度チェック
WITH verified_queries AS (
    SELECT 
        '延滞しているユーザーの属性（年齢、収入、職業など）とクレジットカード決済による取引カテゴリーの関係性を分析したい' AS vq_text
    UNION ALL
    SELECT '一番取引が多いユーザは誰で、どのような取引をしていますか？'
    UNION ALL
    SELECT 'クレジットカードの延滞がある人とない人の特徴を分析したい'
    UNION ALL
    SELECT 'マルチデバイスユーザーの延滞率は他と比べて低いですか？'
    UNION ALL
    SELECT '売上が少ない地域の特徴は？'
    UNION ALL
    SELECT '学歴別の平均取引額を教えてください'
    UNION ALL
    SELECT 'Food & Drink購入者が次に買うカテゴリは？'
    UNION ALL
    SELECT '世帯年収と個人年収の違いを考慮した分析は？'
    UNION ALL
    SELECT 'Food & Drinkカテゴリの売上推移の分析結果は'
    UNION ALL
    SELECT '延滞ユーザーの年齢分布を把握したい'
),
similarity_check AS (
    SELECT 
        q.query_id,
        q.query_text,
        vq.vq_text AS verified_query,
        -- Levenshtein距離で類似度計算
        EDITDISTANCE(q.query_text, vq.vq_text) AS edit_distance,
        -- 文字列の長さで正規化
        1.0 - (EDITDISTANCE(q.query_text, vq.vq_text) * 1.0 / GREATEST(LENGTH(q.query_text), LENGTH(vq.vq_text))) AS similarity_score
    FROM query_validation_list q
    CROSS JOIN verified_queries vq
)
SELECT 
    query_id,
    query_text,
    MAX(similarity_score) AS best_match_score,
    MAX_BY(verified_query, similarity_score) AS matched_verified_query,
    CASE 
        WHEN MAX(similarity_score) > 0.8 THEN 'EXACT_MATCH'
        WHEN MAX(similarity_score) > 0.2 THEN 'SIMILAR'
        ELSE 'NO_MATCH'
    END AS match_status
FROM similarity_check
GROUP BY query_id, query_text
ORDER BY best_match_score DESC;