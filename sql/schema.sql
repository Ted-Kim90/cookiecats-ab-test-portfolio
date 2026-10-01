-- Cookie Cats A/B 테스트 포트폴리오 프로젝트: 테이블 스키마
-- 데이터셋: Mobile Games A/B Testing - Cookie Cats (Kaggle, 90,189행)

CREATE DATABASE IF NOT EXISTS cookiecats;
USE cookiecats;

CREATE TABLE ab_test_results (
    userid         BIGINT PRIMARY KEY,
    version        VARCHAR(16) NOT NULL,   -- 'gate_30' or 'gate_40'
    sum_gamerounds INT NOT NULL,
    retention_1    TINYINT(1) NOT NULL,    -- 1일 리텐션 (TRUE/FALSE -> 1/0)
    retention_7    TINYINT(1) NOT NULL     -- 7일 리텐션 (TRUE/FALSE -> 1/0)
);
