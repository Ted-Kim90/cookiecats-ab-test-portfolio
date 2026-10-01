"""
prepare_for_mysql.py

Kaggle 원본 cookie_cats.csv의 retention_1 / retention_7 컬럼은
TRUE/FALSE 문자열로 되어 있습니다. MySQL의 LOAD DATA INFILE은
TINYINT 컬럼에 'TRUE'/'FALSE' 문자열을 바로 적재하지 못하고
0으로 잘못 변환해버리므로(묵시적 캐스팅 경고), 적재 전에
1/0 정수로 미리 변환합니다.

사용법:
    python prepare_for_mysql.py

같은 폴더 상위의 data/cookie_cats.csv를 읽어
data/cookie_cats_mysql.csv를 생성합니다.
"""

import pandas as pd

SRC = "../data/cookie_cats.csv"
DST = "../data/cookie_cats_mysql.csv"

df = pd.read_csv(SRC)
df["retention_1"] = df["retention_1"].astype(bool).astype(int)
df["retention_7"] = df["retention_7"].astype(bool).astype(int)

df.to_csv(DST, index=False)
print(f"완료: {DST} 생성 ({len(df):,}행)")
