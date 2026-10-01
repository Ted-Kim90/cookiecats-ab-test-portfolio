-- Cookie Cats A/B 테스트 포트폴리오 프로젝트: 분석 쿼리
USE cookiecats;

-- ============================================================
-- 1. 그룹별 샘플 수 (SRM 체크용 기초 데이터)
-- 왜 물었나: A/B 테스트 분석 전, 두 그룹이 설계대로(50:50) 배정됐는지
--            가장 먼저 확인해야 함. 비율이 깨져 있으면 이후 모든 검정을
--            신뢰할 수 없음
-- 발견: gate_30 44,700명 / gate_40 45,489명 (약 49.6% : 50.4%)
--       → 카이제곱 검정(Python)으로 추가 검증 필요한 수준의 근소한 불균형
-- ============================================================
SELECT version, COUNT(*) AS n
FROM ab_test_results
GROUP BY version;


-- ============================================================
-- 2. 그룹별 1일 / 7일 리텐션율
-- 왜 물었나: 게이트 위치(레벨 30 vs 40)가 유저 리텐션에 미치는 핵심 효과를
--            SQL 집계로 바로 확인. 유의성 검정 자체는 Python(statsmodels)에서
--            비율 차이 검정으로 수행하지만, 비교의 기초가 되는 집계는 SQL로 처리
-- 발견: 1일 리텐션 gate_30 44.82% vs gate_40 44.23% (근소한 차이)
--       7일 리텐션 gate_30 19.02% vs gate_40 18.20% (gate_30이 더 높음)
-- ============================================================
SELECT
    version,
    COUNT(*)                               AS n,
    ROUND(AVG(retention_1) * 100, 2)       AS retention_1_pct,
    ROUND(AVG(retention_7) * 100, 2)       AS retention_7_pct
FROM ab_test_results
GROUP BY version;


-- ============================================================
-- 3. 그룹별 참여도(가드레일 지표: sum_gamerounds) 요약 통계
-- 왜 물었나: 리텐션 개선/악화와 별개로, 게이트 위치가 유저의 실제 플레이
--            참여도 자체를 해치지는 않는지 가드레일 지표로 확인
-- 발견: 평균 라운드 수는 gate_30 52.5 / gate_40 51.3으로 비슷하지만,
--       gate_30의 표준편차(256.7)가 gate_40(103.3)보다 훨씬 큼
--       → 쿼리 4에서 확인한 극단 이상치(49,854라운드, gate_30 소속) 1건의 영향.
--       이상치를 제외한 평균/중앙값 재계산은 Python에서 수행
-- ============================================================
SELECT
    version,
    COUNT(*)                     AS n,
    ROUND(AVG(sum_gamerounds), 1) AS avg_rounds,
    MIN(sum_gamerounds)           AS min_rounds,
    MAX(sum_gamerounds)           AS max_rounds,
    ROUND(STDDEV(sum_gamerounds), 1) AS stddev_rounds
FROM ab_test_results
GROUP BY version;


-- ============================================================
-- 4. 이상치 식별: 참여도 상위 5명
-- 왜 물었나: 극단적으로 큰 값이 평균/분산을 왜곡시킬 수 있어, 분석 전
--            이상치 존재 여부와 규모를 먼저 확인
-- 발견: 1명이 49,854라운드(2위 기록의 약 17배)를 기록 — 봇/QA 계정으로 추정,
--       참여도 분석에서 제외하고 그 근거를 README에 기록
-- ============================================================
SELECT userid, version, sum_gamerounds, retention_1, retention_7
FROM ab_test_results
ORDER BY sum_gamerounds DESC
LIMIT 5;


-- ============================================================
-- 5. 데이터 품질 체크: NULL / 중복 유저 확인
-- 왜 물었나: 분석에 들어가기 전 결측치와 PK 중복 여부를 검증해 데이터 신뢰도 확보
-- 발견: NULL 없음, userid 중복 없음(PRIMARY KEY 제약 통과) — 90,189행 모두 분석 가능
-- ============================================================
SELECT
    SUM(CASE WHEN version IS NULL THEN 1 ELSE 0 END)        AS null_version,
    SUM(CASE WHEN sum_gamerounds IS NULL THEN 1 ELSE 0 END) AS null_rounds,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT userid) AS distinct_users
FROM ab_test_results;
