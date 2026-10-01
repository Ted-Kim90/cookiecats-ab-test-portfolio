-- Cookie Cats A/B 테스트 포트폴리오 프로젝트: CSV 데이터 적재
--
-- 원본 CSV의 retention_1 / retention_7 컬럼은 TRUE/FALSE 문자열이라
-- TINYINT 컬럼에 바로 적재하면 묵시적 캐스팅으로 전부 0 처리되는 문제가 있어,
-- scripts/prepare_for_mysql.py로 1/0 정수로 먼저 변환한 cookie_cats_mysql.csv를 사용했습니다.
--
-- 사전 준비:
--   SHOW VARIABLES LIKE 'secure_file_priv'; 로 확인한 폴더(예: /var/lib/mysql-files/)에
--   cookie_cats_mysql.csv 파일을 복사해 둘 것

USE cookiecats;

LOAD DATA INFILE '/var/lib/mysql-files/cookie_cats_mysql.csv'
INTO TABLE ab_test_results
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 적재 검증
SELECT COUNT(*) FROM ab_test_results;  -- 90,189
